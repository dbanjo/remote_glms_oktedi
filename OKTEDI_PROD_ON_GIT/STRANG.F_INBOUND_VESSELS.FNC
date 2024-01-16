CREATE OR REPLACE function STRANG.f_inbound_vessels(v_shipid integer, v_val varchar2) return varchar2
as

cursor c1(vship integer) is
 select bol
 from   strang.movements m
 where  m.ship_id = vship
 ;

cursor c2(vship integer) is
 select distinct c.customer
 from   strang.customers c
      , strang.receivals r
      , strang.detailrs dr
      , strang.movements m
 where  c.customer_id = r.supplier_customer_id
        and r.deliveryno = dr.deliveryno
        and dr.movement_no = m.movement_no
        and nvl(m.seal, '|') = nvl(dr.camov_seal, '|')
        and m.ship_id = vship
 ;

cursor c3(vship integer) is
 select distinct p.po
 from   strang.movements m
      , strang.pos p
      , strang.detailrs dr
 where  m.ship_id = vship
        and p.deliveryno = dr.deliveryno
        and dr.movement_no = m.movement_no
        and nvl(m.seal, '|') = nvl(dr.camov_seal, '|')
 ;

cursor c4(vship integer) is
 select distinct l.colc
 from   strang.movements m
      , strang.lov l
 where  m.ship_id = vship
        and m.container_type = l.code
        and l.lov_name = 'CTRTYPE'
 ;

cursor c5(vship integer, v_ctr varchar2) is
 select count(*)
 from   strang.movements m
 where  m.ship_id = vship
        and iso_container_type like v_ctr || '%'
 ;

cursor c6(vship integer) is
 select count(*)
 from   strang.movements m
 where  m.ship_id = vship
        and m.movement_type = 'CONMOV'
 ;

cursor c7(vship integer) is
 select sum(revton)
 from   strang.movements m
 where  m.ship_id = vship
 ;

cursor c8(v_po varchar2) is
 select *
 from   po_pool
 where  po_number = v_po
 ;

cursor sa(vship integer) is
 select *
 from   strang.ships_airway s
 where  s.ship_id = vship
 ;

retval        varchar2(1000);
sa_rec        sa%ROWTYPE;
c8rec         c8%ROWTYPE;

begin
 case upper(trim(v_val))
 when 'BOL'
  then
   for c1rec in c1(v_shipid) loop
    if C1%ROWCOUNT > 1
     then
      retval := 'Various';
      exit;
    else
      retval := c1rec.bol;
    end if;
   end loop;
 when 'SUPPLIER'
  then
   for c2rec in c2(v_shipid) loop
    if C2%ROWCOUNT > 1
     then
      retval := 'Consolidation';
      exit;
    else
      retval := c2rec.customer;
    end if;
   end loop;
 when 'POS'
  then
   for c3rec in c3(v_shipid) loop
   open c8(to_char(c3rec.po));
   fetch c8 into c8rec;
   close c8;
    if C3%ROWCOUNT > 1
     then
      -- retval := 'Various';
	  retval := retval || '<br>' || c3rec.po;
      exit;
    else
      retval := c3rec.po;
    end if;
   end loop;
 when 'CTR_TYPE'
  then
   for c4rec in c4(v_shipid) loop
    if C4%ROWCOUNT > 1
     then
      retval := 'Mixed Mining';
      exit;
    else
      retval := c4rec.colc;
    end if;
   end loop;
 when '20_FT'
  then
   open c5(v_shipid, '2');
   fetch c5 into retval;
   close c5;
   retval := nvl(retval, '0');
 when '40_FT'
  then
   open c5(v_shipid, '4');
   fetch c5 into retval;
   close c5;
   retval := nvl(retval, '0');
 when 'BREAK_BULK'
  then
   open c6(v_shipid);
   fetch c6 into retval;
   close c6;
   retval := nvl(retval, '0');
 when 'REVTON'
  then
   open c7(v_shipid);
   fetch c7 into retval;
   close c7;
   retval := nvl(retval, '0');
 when 'STATUS'
  then
   open sa(v_shipid);
   fetch sa into sa_rec;
   close sa;
   case upper(trim(sa_rec.status))
   when 'FINAL' then retval := '4. Completed Vessels';
   when 'CUSTOMS COMPLETE' then retval := '4. Completed Vessels';
   when 'COMPLETE' then retval := '4. Completed Vessels';
   when 'COMPLETE' then retval := '4. Completed Vessels';
   when 'SAILED' then retval := '3. Vessels en Route';
   when 'ARRIVED' then retval := '2. Vessels in Port';
   when 'INCOMPLETE' then retval := '1. Conceptual/Planned Vessels';
   else retval := '5. Others';
   end case;
   retval := '<B>' || retval || '</B>';
 else
   retval := null;
 end case;
 return(retval);
exception when others then
 return('Error');
end f_inbound_vessels;
/


GRANT EXECUTE ON STRANG.F_INBOUND_VESSELS TO WEBSYS;
