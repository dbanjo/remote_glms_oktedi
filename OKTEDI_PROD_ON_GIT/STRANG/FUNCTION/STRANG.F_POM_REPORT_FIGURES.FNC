CREATE OR REPLACE function STRANG.f_pom_report_figures( parm in varchar2 )
 return varchar2
as
 cursor c1(v1 integer) is
select count(distinct m.movement_no) ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CARGO' and
  m.customs_cleared_date is null;

 cursor c1_1(v1 integer) is
select sum( nvl(m.vgm,(nvl(m.sumweight,0)+nvl(tare,0))))/1000 wt_ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CARGO' and
  m.customs_cleared_date is null;

cursor c1_2(v1 integer) is
select sum( nvl(m.sumvolume,0)) vol_ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CARGO' and
  m.customs_cleared_date is null;

cursor c2 is
select distinct c.customer, c.customer_id
  from strang.receivals r, strang.customers c, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = c.customer_id and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CARGO' and
  m.customs_cleared_date is null
  order by c.customer;

-- -----------------------------------------------------------------------------------------------------------  BREAK BULK

 cursor c1a(v1 integer) is
select count(distinct m.movement_no) ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CONMOV' and
  m.customs_cleared_date is null;


cursor c2a is
select distinct c.customer, c.customer_id
  from strang.receivals r, strang.customers c, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = c.customer_id and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CONMOV' and
  m.customs_cleared_date is null
  order by c.customer;

 cursor c1a_1(v1 integer) is
select sum( nvl(m.vgm,nvl(m.sumweight,0)))/1000 wt_ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CONMOV' and
  m.customs_cleared_date is null;

cursor c1a_2(v1 integer) is
select sum( nvl(m.sumvolume,0)) vol_ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CONMOV' and
  m.customs_cleared_date is null;


-------------------------------------------------------------------------------  CLEARED CONTAINERS
 cursor c3(v1 integer) is
select count(distinct m.movement_no) ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CARGO' and
  m.customs_cleared_date is not null;


 cursor c3_1(v1 integer) is
select sum( nvl(m.vgm,(nvl(m.sumweight,0)+nvl(tare,0))))/1000 wt_ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CARGO' and
  m.customs_cleared_date is not null;

 cursor c3_2(v1 integer) is
select sum( nvl(m.sumvolume,0)) vol_ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CARGO' and
  m.customs_cleared_date is not null;

cursor c4 is
select distinct c.customer, c.customer_id
  from strang.receivals r, strang.customers c, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = c.customer_id and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CARGO' and
  m.customs_cleared_date is not null
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
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CONMOV' and
  m.customs_cleared_date is not null;

 cursor c3a_1(v1 integer) is
select sum( nvl(m.vgm,nvl(m.sumweight,0)))/1000 wt_ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CONMOV' and
  m.customs_cleared_date is not null;

cursor c3a_2(v1 integer) is
select sum( nvl(m.sumvolume,0)) vol_ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CONMOV' and
  m.customs_cleared_date is not null;


cursor c4a is
select distinct c.customer, c.customer_id
  from strang.receivals r, strang.customers c, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = c.customer_id and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CONMOV' and
  m.customs_cleared_date is not null
  order by c.customer;
-- ---------------------------------------------------   PRIORITY CONTAINERS TO BE CLEARED
 cursor c5(v1 integer, v2 varchar2, v3 varchar2) is
select count(distinct m.movement_no) ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CARGO' and
  m.urgency = v2 and
  m.container_type = v3 and
  m.customs_cleared_date is null;

 cursor c5_1(v1 integer, v2 varchar2, v3 varchar2) is
select sum( nvl(m.vgm,(nvl(m.sumweight,0)+nvl(tare,0))))/1000 wt_ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CARGO' and
  m.urgency = v2 and
  m.container_type = v3 and
  m.customs_cleared_date is null;

 cursor c5_2(v1 integer, v2 varchar2, v3 varchar2) is
select sum( nvl(m.sumvolume,0)) vol_ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CARGO' and
  m.urgency = v2 and
  m.container_type = v3 and
  m.customs_cleared_date is null;

cursor c6 is
select distinct c.customer, c.customer_id, m.urgency, m.container_type
  from strang.receivals r, strang.customers c, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = c.customer_id and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CARGO' and
  m.urgency <> 'STANDARD' and
  m.customs_cleared_date is null
  order by c.customer;
-- ------------------------------------------------------------------------------------- PRIORITY BREAK BULK TO BE CLEARED
cursor c5a(v1 integer, v2 varchar2) is
select count(distinct m.movement_no) ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CONMOV' and
  m.urgency = v2 and
  m.customs_cleared_date is null;

 cursor c5a_1(v1 integer, v2 varchar2) is
select sum( nvl(m.vgm,nvl(m.sumweight,0)))/1000 wt_ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CONMOV' and
  m.urgency = v2 and
  m.customs_cleared_date is null;

 cursor c5a_2(v1 integer, v2 varchar2) is
select sum( nvl(m.sumvolume,0)) vol_ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CONMOV' and
  m.urgency = v2 and
  m.customs_cleared_date is null;

cursor c6a is
select distinct c.customer, c.customer_id, m.urgency
  from strang.receivals r, strang.customers c, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = c.customer_id and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CONMOV' and
  m.urgency <> 'STANDARD' and
  m.customs_cleared_date is null
  order by c.customer;
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
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CARGO' and
  m.urgency = v2 and
  m.container_type = v3 and
  m.customs_cleared_date is not null;

 cursor c7_1(v1 integer, v2 varchar2, v3 varchar2) is
select sum( nvl(m.vgm,(nvl(m.sumweight,0)+nvl(tare,0))))/1000 wt_ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CARGO' and
  m.urgency = v2 and
  m.container_type = v3 and
  m.customs_cleared_date is not null;

 cursor c7_2(v1 integer, v2 varchar2, v3 varchar2) is
select sum( nvl(m.sumvolume,0)) vol_ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CARGO' and
  m.urgency = v2 and
  m.container_type = v3 and
  m.customs_cleared_date is not null;

cursor c8 is
select distinct c.customer, c.customer_id, m.urgency, m.container_type
  from strang.receivals r, strang.customers c, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = c.customer_id and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CARGO' and
  m.urgency <> 'STANDARD' and
  m.customs_cleared_date is not null
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
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CONMOV' and
  m.urgency = v2 and
  m.customs_cleared_date is not null;

 cursor c7a_1(v1 integer, v2 varchar2) is
select sum( nvl(m.vgm,nvl(m.sumweight,0)))/1000 wt_ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CONMOV' and
  m.urgency = v2 and
  m.customs_cleared_date is not null;

 cursor c7a_2(v1 integer, v2 varchar2) is
select sum( nvl(m.sumvolume,0)) vol_ttl
  from strang.receivals r, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = v1 and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CONMOV' and
  m.urgency = v2 and
  m.customs_cleared_date is not null;

cursor c8a is
select distinct c.customer, c.customer_id, m.urgency
  from strang.receivals r, strang.customers c, strang.detailrs dr, strang.movements m
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  r.cust_customer_id = c.customer_id and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.movement_type = 'CONMOV' and
  m.urgency <> 'STANDARD' and
  m.customs_cleared_date is not null
  order by c.customer;
-- ---------------------------------------------------  CONTAINERS DISCHARGE INFORMATION FOR TRANSFERRED CONTAINERS (TRANSFER DATE - DISCHARGE DATE)
 cursor c9 is
select c.customer, s.shipname||' '||s.voy ship, count(distinct m.movement_no) ttl, trunc(sysdate-trunc(nvl(m.int_ship_discharge_date,sysdate))) tdays
  from strang.receivals r, strang.detailrs dr, strang.movements m, strang.customers c, strang.ships_airway s
  where r.deliveryno = dr.deliveryno and
  dr.movement_no = m.movement_no and
  nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
  nvl(m.complete,'S') NOT IN ('H','J') and
  m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'MOTUKEA') and
  m.ship_id in (select s.ship_id from strang.ships_airway s where s.shipname <> 'LOCAL SHIPPING ONLY') and
  m.ship_id  = s.ship_id and
  m.movement_type = 'CARGO' and
  m.berth4_transfer_date is null and
   m.intl_wharf_transfer_date is null and
   m.int_ship_discharge_date is not null and
   r.cust_customer_id = c.customer_id
  group by trunc(sysdate-trunc(nvl(m.int_ship_discharge_date,sysdate))), c.customer, s.shipname||' '||s.voy
  order by c.customer, tdays desc;

-- =====================================================
 c1rec  c1%ROWTYPE;
 c1_1rec   c1_1%ROWTYPE;
 c1_2rec   c1_2%ROWTYPE;
 c2rec     c2%ROWTYPE;
 c1arec    c1%ROWTYPE;
 c1a_1rec  c1a_1%ROWTYPE;
 c1a_2rec  c1a_2%ROWTYPE;
 c2arec    c2%ROWTYPE;
 c3rec     c3%ROWTYPE;
 c3_1rec   c3_1%ROWTYPE;
 c3_2rec   c3_2%ROWTYPE;
 c4rec     c4%ROWTYPE;
 c3arec    c3a%ROWTYPE;
 c3a_1rec  c3a_1%ROWTYPE;
 c3a_2rec  c3a_2%ROWTYPE;
 c4arec    c4a%ROWTYPE;
 c5rec     c5%ROWTYPE;
 c5_1rec   c5_1%ROWTYPE;
 c5_2rec   c5_2%ROWTYPE;
 c6rec     c6%ROWTYPE;
 c5arec    c5a%ROWTYPE;
 c5a_1rec  c5a_1%ROWTYPE;
 c5a_2rec  c5a_2%ROWTYPE;
 c6arec    c6a%ROWTYPE;
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
 retvar1	varchar2(32000);
 retvar2	varchar2(32000);
 retvar3	varchar2(32000);
 retvar4	varchar2(32000);
 retvar5	varchar2(32000);
 retvar6	varchar2(32000);
 retvar7	varchar2(32000);
 retvar8	varchar2(32000);
 retvar9	varchar2(32000);
 retvar10	varchar2(32000);
 ctr	number;

begin
 retvar := NULL;
 retvar1 := NULL;
 retvar2 := NULL;
 retvar3 := NULL;
 retvar4 := NULL;
 retvar5 := NULL;
 retvar6 := NULL;
 retvar7 := NULL;
 retvar8 := NULL;
 retvar9 := NULL;
 retvar10 := NULL;
 tot:=0;
 totw:=0;
 totv:=0;
 totdays := 0;
 ctr  := 1;
 if parm = 'A1' then
  for c2rec in c2 loop
   open c1(c2rec.customer_id);
    fetch c1 into c1rec;
   close c1;
   open c1_1(c2rec.customer_id);
    fetch c1_1 into c1_1rec;
   close c1_1;
   open c1_2(c2rec.customer_id);
    fetch c1_2 into c1_2rec;
   close c1_2;
   if ctr = 1 then
   retvar := '<tr><td>' || c2rec.customer ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1rec.ttl,0),'999,999,999')||
     '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'||to_char(nvl(c1_1rec.wt_ttl,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1_2rec.vol_ttl,0),'999,999.999')||' CBM '  ||
   '</td></tr>';
   else
    if length(retvar) < 3500 then
     retvar := retvar || '<tr><td>' || c2rec.customer ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1rec.ttl,0),'999,999,999')||
     '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'||to_char(nvl(c1_1rec.wt_ttl,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1_2rec.vol_ttl,0),'999,999.999')||' CBM '  ||
     '</td></tr>';
/*
     elsif length(retvar1) < 3500 then
     retvar1 := retvar1 || '<tr><td>' || c2rec.customer ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1rec.ttl,0),'999,999,999')||
     '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'||to_char(nvl(c1_1rec.wt_ttl,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1_2rec.vol_ttl,0),'999,999.999')||' CBM '  ||
     '</td></tr>';
     elsif length(retvar2) < 3500 then
     retvar2 := retvar2 || '<tr><td>' || c2rec.customer ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1rec.ttl,0),'999,999,999')||
     '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'||to_char(nvl(c1_1rec.wt_ttl,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1_2rec.vol_ttl,0),'999,999.999')||' CBM '  ||
     '</td></tr>';
     elsif length(retvar3) < 3500 then
     retvar3 := retvar3 || '<tr><td>' || c2rec.customer ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1rec.ttl,0),'999,999,999')||
     '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'||to_char(nvl(c1_1rec.wt_ttl,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1_2rec.vol_ttl,0),'999,999.999')||' CBM '  ||
     '</td></tr>';
     elsif length(retvar4) < 3500 then
     retvar4 := retvar4 || '<tr><td>' || c2rec.customer ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1rec.ttl,0),'999,999,999')||
     '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'||to_char(nvl(c1_1rec.wt_ttl,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1_2rec.vol_ttl,0),'999,999.999')||' CBM '  ||
     '</td></tr>';
     elsif length(retvar5) < 3500 then
     retvar5 := retvar5 || '<tr><td>' || c2rec.customer ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1rec.ttl,0),'999,999,999')||
     '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'||to_char(nvl(c1_1rec.wt_ttl,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1_2rec.vol_ttl,0),'999,999.999')||' CBM '  ||
     '</td></tr>';
     elsif length(retvar6) < 3500 then
     retvar6 := retvar6 || '<tr><td>' || c2rec.customer ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1rec.ttl,0),'999,999,999')||
     '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'||to_char(nvl(c1_1rec.wt_ttl,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1_2rec.vol_ttl,0),'999,999.999')||' CBM '  ||
     '</td></tr>';
     elsif length(retvar7) < 3500 then
     retvar7 := retvar7 || '<tr><td>' || c2rec.customer ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1rec.ttl,0),'999,999,999')||
     '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'||to_char(nvl(c1_1rec.wt_ttl,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1_2rec.vol_ttl,0),'999,999.999')||' CBM '  ||
     '</td></tr>';
     elsif length(retvar8) < 3500 then
     retvar8 := retvar8 || '<tr><td>' || c2rec.customer ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1rec.ttl,0),'999,999,999')||
     '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'||to_char(nvl(c1_1rec.wt_ttl,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1_2rec.vol_ttl,0),'999,999.999')||' CBM '  ||
     '</td></tr>';
     elsif length(retvar9) < 3500 then
     retvar9 := retvar9 || '<tr><td>' || c2rec.customer ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1rec.ttl,0),'999,999,999')||
     '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'||to_char(nvl(c1_1rec.wt_ttl,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1_2rec.vol_ttl,0),'999,999.999')||' CBM '  ||
     '</td></tr>';
*/
    end if;
   end if;
   tot:= tot + nvl(c1rec.ttl,0);
   totw:= totw + nvl(c1_1rec.wt_ttl,0);
   totv:= totv + nvl(c1_2rec.vol_ttl,0);
   ctr := ctr + 1;
   end loop;
   retvar10 := '<tr><td><B>' ||  'TOTAL' ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;><B>'|| to_char( nvl(tot,0),'999,999,999') ||
   '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;><B>'||to_char(nvl(totw,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;><B>'|| to_char(nvl(totv,0),'999,999.999')||' CBM'||
   '</B></td></tr>';
   return(retvar||retvar1||retvar2||retvar3||retvar4||retvar5||retvar6||retvar7||retvar8||retvar9||retvar10);
 elsif
  parm = 'B1' then
  for c2arec in c2a loop
   open c1a(c2arec.customer_id);
    fetch c1a into c1arec;
   close c1a;
   open c1a_1(c2arec.customer_id);
    fetch c1a_1 into c1a_1rec;
   close c1a_1;
   open c1a_2(c2arec.customer_id);
    fetch c1a_2 into c1a_2rec;
   close c1a_2;
   if ctr = 1 then
   retvar := '<tr><td>' || c2arec.customer ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1arec.ttl,0),'999,999,999')||
     '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'||to_char(nvl(c1a_1rec.wt_ttl,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1a_2rec.vol_ttl,0),'999,999.999')||' CBM '  ||
   '</td></tr>';
   else
   retvar := retvar || '<tr><td>' || c2arec.customer ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1arec.ttl,0),'999,999,999')||
     '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'||to_char(nvl(c1a_1rec.wt_ttl,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c1a_2rec.vol_ttl,0),'999,999.999')||' CBM '  ||
   '</td></tr>';
   end if;
   tot:= tot + nvl(c1arec.ttl,0);
   totw:= totw + nvl(c1a_1rec.wt_ttl,0);
   totv:= totv + nvl(c1a_2rec.vol_ttl,0);
   ctr := ctr + 1;
   end loop;
   retvar := retvar || '<tr><td><B>' ||  'TOTAL' ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;><B>'|| to_char( nvl(tot,0),'999,999,999') ||
   '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;><B>'||to_char(nvl(totw,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;><B>'|| to_char(nvl(totv,0),'999,999.999')||' CBM'||
   '</B></td></tr>';
 elsif
   parm = 'A2' then
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
   parm = 'A3' then
  for c6rec in c6 loop
   open c5(c6rec.customer_id,c6rec.urgency,c6rec.container_type );
   fetch c5 into c5rec;
  close c5;
   open c5_1(c6rec.customer_id,c6rec.urgency,c6rec.container_type );
   fetch c5_1 into c5_1rec;
  close c5_1;
   open c5_2(c6rec.customer_id,c6rec.urgency,c6rec.container_type );
   fetch c5_2 into c5_2rec;
  close c5_2;
   if ctr = 1 then
    retvar := '<tr><td>' || c6rec.customer ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| c6rec.container_type||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>' ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| c6rec.urgency||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c5rec.ttl,0),'999,999,999')||
      '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'||to_char(nvl(c5_1rec.wt_ttl,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c5_2rec.vol_ttl,0),'999,999.999')||' CBM '  ||
    '</td></tr>';
   else
    retvar := retvar || '<tr><td>' || c6rec.customer ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| c6rec.container_type||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>' ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| c6rec.urgency||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c5rec.ttl,0),'999,999,999')||
      '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'||to_char(nvl(c5_1rec.wt_ttl,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c5_2rec.vol_ttl,0),'999,999.999')||' CBM '  ||
    '</td></tr>';
   end if;
    tot:= tot + nvl(c5rec.ttl,0);
    totw:= totw + nvl(c5_1rec.wt_ttl,0);
    totv:= totv + nvl(c5_2rec.vol_ttl,0);
    ctr := ctr + 1;
   end loop;
   retvar := retvar || '<tr><td><B>' ||  'TOTAL' ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;></td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;></td><td align=right padding:0cm 3.5pt 0cm 3.5pt;></td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td><B>'|| to_char( nvl(tot,0),'999,999,999') ||
   '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;><B>'||to_char(nvl(totw,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;><B>'|| to_char(nvl(totv,0),'999,999.999')||' CBM'||
   '</B></td></tr>';
 elsif
   parm = 'B3' then
  for c6arec in c6a loop
   open c5a(c6arec.customer_id,c6arec.urgency);
   fetch c5a into c5arec;
  close c5a;
   open c5a_1(c6arec.customer_id,c6arec.urgency );
   fetch c5a_1 into c5a_1rec;
  close c5a_1;
   open c5a_2(c6arec.customer_id,c6arec.urgency );
   fetch c5a_2 into c5a_2rec;
  close c5a_2;
   if ctr = 1 then
     retvar := '<tr><td>' || c6arec.customer ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>' ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| c6arec.urgency||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c5arec.ttl,0),'999,999,999')||
     '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'||to_char(nvl(c5a_1rec.wt_ttl,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c5a_2rec.vol_ttl,0),'999,999.999')||' CBM '  ||
     '</td></tr>';
    else
     retvar := retvar || '<tr><td>' || c6arec.customer ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>' ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| c6arec.urgency||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c5arec.ttl,0),'999,999,999')||
     '</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'||to_char(nvl(c5a_1rec.wt_ttl,0),'999,999.999')||' T '||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>'|| to_char(nvl(c5a_2rec.vol_ttl,0),'999,999.999')||' CBM '  ||
     '</td></tr>';
    end if;
    tot:= tot + nvl(c5arec.ttl,0);
    totw:= totw + nvl(c5a_1rec.wt_ttl,0);
    totv:= totv + nvl(c5a_2rec.vol_ttl,0);
    ctr := ctr + 1;
   end loop;
   retvar := retvar || '<tr><td><B>' ||  'TOTAL' ||'</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;></td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=right padding:0cm 3.5pt 0cm 3.5pt;></td><td align=right padding:0cm 3.5pt 0cm 3.5pt;></td><td align=right padding:0cm 3.5pt 0cm 3.5pt;>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td><B>'|| to_char( nvl(tot,0),'999,999,999') ||
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
end f_pom_report_figures;
/


GRANT EXECUTE ON STRANG.F_POM_REPORT_FIGURES TO WEBSYS;
