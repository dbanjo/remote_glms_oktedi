CREATE OR REPLACE procedure WEBSYS.test_duty_com(vship_id varchar2, entryno number, vcust_id integer)
as

 cursor c3( vship_id integer, entryno in number, vcust_id integer ) is
  select dr.rowid,dr.deliveryno,entry_no_com,line_no, l2.description rate, round(c.freight/l3.description,2) freight,c.insurance,c.other_costs,c.vat, c.infreight, c.deductions,
         m.bol,nvl(m.container_type,'BREAK BULK') container_type,r.supplier_customer_id_com supplier, r.curr, sa.estarrive, c.levy_rate
  from strang.detailrs dr, strang.movements m, strang.lov l, strang.ships_airway sa, strang.receivals r, strang.lov l2, strang.customers c, strang.lov l3
  where
   m.ship_id = vship_id and
   sa.ship_id = m.ship_id and
   nvl(m.container_type,'BREAK BULK') = l.code and
   l.lov_name = 'CTRTYPE' and
   l2.lov_name = 'UNRATTAB' and
   l2.code = r.curr and
   to_date(glbx.guess_date(l2.cola),'DD-MON-YYYY') <= sa.estarrive and
   nvl(to_date(glbx.guess_date(l2.colb),'DD-MON-YYYY'),sa.estarrive) >= sa.estarrive and
   l3.lov_name = 'UNRATTAB' and
   l3.code = 'USD' and
   to_date(glbx.guess_date(l3.cola),'DD-MON-YYYY') <= sa.estarrive and
   nvl(to_date(glbx.guess_date(l3.colb),'DD-MON-YYYY'),sa.estarrive) >= sa.estarrive and
   r.deliveryno = dr.deliveryno and
   r.cust_customer_id = c.customer_id and
   dr.movement_no = m.movement_no and
   nvl(dr.camov_seal,'|') = nvl(seal,'|') and
   dr.entry_no_com = entryno;

cursor c5( entryno number ) is
  select /*+ ALL_ROWS */ sum(p.tamount) tot
  from strang.pos p
  where p.deliveryno in
   (select distinct dr.deliveryno
    from strang.detailrs dr
    where dr.entry_no_com = entryno
   );

cursor c5a( entryno number ) is
  select /*+ ALL_ROWS */ sum(nvl(p.delivery_charge,0)) totdc
  from strang.pos p
  where p.deliveryno in
   (select distinct dr.deliveryno
    from strang.detailrs dr
    where dr.entry_no_com = entryno
   );

 cursor c7a( entryno number, vat number, ratio_factor number ) is
 select /*+ ALL_ROWS */ sum(kvalue) kvalue, sum(duty) duty, sum(excise) excise, sum(vat) vat,sum(old_duty) old_duty
 from
 (
  select /*+ ALL_ROWS */
       sum(tamount) * nvl(ratio_factor,1) kvalue,
       sum(tamount) * nvl(ratio_factor,1) * (nvl(to_number(t.description),0)/100) duty,
       ((sum(tamount) * nvl(ratio_factor,1)) + (sum(tamount) * nvl(ratio_factor,1) * (nvl(to_number(t.description),0)/100))) * (nvl(to_number(t.colc),0)/100) excise,
       ((sum(tamount) * nvl(ratio_factor,1)) + (sum(tamount) * nvl(ratio_factor,1) * (nvl(to_number(t.description),0)/100)) +
        (((sum(tamount) * nvl(ratio_factor,1)) + (sum(tamount) * nvl(ratio_factor,1) * (nvl(to_number(t.description),0)/100))) * (nvl(to_number(t.colc),0)/100))
       ) * (nvl(vat,0)/100) vat,
       (t.colb * sum(tamount) * nvl(ratio_factor,1)) / 100 old_duty
from strang.lov i, strang.pos p, strang.lov t
where i.code = p.inventoryno and
      i.lov_name = 'INVENT' and
      t.lov_name = 'TARIFF' and
      p.deliveryno in
         (select distinct dr.deliveryno
          from strang.detailrs dr
          where dr.entry_no_com = entryno
      ) and
      t.code = i.cola
group by i.description, t.code, p.ctry_countrycode, p.unit_unitused, t.colb, ratio_factor, t.description, t.colc, vat
  );


cursor c11b(shipid integer, entryno number, fr number ) is
  select /*+ ALL_ROWS */ sum(strang.revenue_tonne(partweight,partvolume) * nvl(fr,0)) sm
  from strang.detailrs dr, strang.movements m
  where m.ship_id=shipid and
        m.movement_no = dr.movement_no and
        nvl(dr.camov_seal,'|') = nvl(seal,'|') and
        dr.deliveryno in
         (select dr2.deliveryno from strang.detailrs dr2 where dr2.entry_no_com = entryno);

cursor c11c(shipid integer, entryno number, ifr number ) is
  select /*+ ALL_ROWS */ sum(strang.revenue_tonne(partweight,partvolume) * nvl(ifr,0)) ism
  from strang.detailrs dr, strang.movements m
  where m.ship_id=shipid and
        m.movement_no = dr.movement_no and
        nvl(dr.camov_seal,'|') = nvl(seal,'|') and
        dr.deliveryno in
         (select dr2.deliveryno from strang.detailrs dr2 where dr2.entry_no_com = entryno);



cursor c14( dlr integer, ent number ) is   -- partshipment query 20161021
   select min(entry_no)
   from strang.detailrs dr
   where dr.deliveryno = dlr and
         entry_no < ent;

 c3rec		c3%ROWTYPE;
 c5arec		c5a%ROWTYPE;
 c7arec		c7a%ROWTYPE;
 c11rec		c11b%ROWTYPE;
 c11crec	c11c%ROWTYPE;
 r_duty     strang.duty%ROWTYPE;
 ti		number;
 tdc		number;
 dt		number;
 rf		number;
 pin		number;
 v1		number;
 v2		number;
 v3		number;
 v4		number;
 v5		number;
 v6		number;
 lv		number;

begin

    open c3(vship_id,entryno, vcust_id);
    fetch c3 into c3rec;
    close c3;
    if c3rec.entry_no_com is null then
	dbms_output.put_line('entry_no_com is null');
	return;
	end if;
    -- dbms_output.put_line('GOT THERE : ' || C3REC.ENTRY_NO_com );

    -- Note: Do not set to 0. Must be Null, code relies on it to be NULL
-- dbms_output.put_line('Debug 1');
    pin := NULL;
    open c14(c3rec.deliveryno,c3rec.entry_no_com);
    fetch c14 into pin;
    close c14;
    if pin is not null and pin < c3rec.entry_no_com then null; else pin := null; end if;

-- dbms_output.put_line('Debug 2');
    open c5( c3rec.entry_no_com );
    fetch c5 into ti;
    close c5;

-- dbms_output.put_line('Debug 3');
    open c5a( c3rec.entry_no_com );
    fetch c5a into tdc;
    close c5a;

-- dbms_output.put_line('Debug 4');
    open c11b( vship_id, c3rec.entry_no_com, c3rec.freight );
    fetch c11b into c11rec;
    close c11b;

-- dbms_output.put_line('Debug 5');
    open c11c( vship_id, c3rec.entry_no_com, c3rec.infreight );
    fetch c11c into c11crec;
    close c11c;
-- dbms_output.put_line('Debug 6');


    v1 := ti / c3rec.rate;
-- dbms_output.put_line('Debug 7');
    v2 := c11rec.sm;
-- dbms_output.put_line('Debug 8');
    v3 := v1 * (c3rec.insurance/100);
-- dbms_output.put_line('Debug 9');
    v4 := (v1 * (c3rec.other_costs/100))+(nvl(tdc,0)/c3rec.rate);
-- dbms_output.put_line('Debug 10');
    v5 := nvl(c11crec.ism,0);
-- dbms_output.put_line('Debug 11');
    v6 := nvl(v1 * (c3rec.deductions/100),0);
-- dbms_output.put_line('Debug 12');
    if nvl(ti,0) = 0
     then
      rf := 0;
     else
      rf := round((v1+v2+v3+v4+v5-v6)/ti,8);
    end if;

dbms_output.put_line('Debug 13a: ' || c3rec.entry_no_com || '; ' || c3rec.vat || '; ' || rf);
    open c7a(c3rec.entry_no_com, c3rec.vat, rf);
dbms_output.put_line('Debug 13b: ' || c3rec.entry_no_com || '; ' || c3rec.vat || '; ' || rf);
    fetch c7a into c7arec;
dbms_output.put_line('Debug 13c: ' || c3rec.entry_no_com || '; ' || c3rec.vat || '; ' || rf);
    close c7a;

dbms_output.put_line('Debug 14');
    if pin is null
     then
      lv := nvl(((c7arec.duty + c7arec.excise + c7arec.kvalue) * c3rec.levy_rate ) / 100 , 0);
	  r_duty.total_invoice := v1;
	  r_duty.duty := c7arec.duty;
	  r_duty.ratio_factor := rf;
	  r_duty.correct_freight := round(v2,2);
	  r_duty.internal_freight := round(v5,2);
	  r_duty.other_costs := round(v4,2);
	  r_duty.insurance := round(v3,3);
	  r_duty.deductions := round(v6,2);
	  r_duty.previous_entry_no:= pin;
      r_duty.excise := c7arec.excise;
      r_duty.vat := c7arec.vat;
      r_duty.pvariance := (c7arec.duty + c7arec.excise + c7arec.vat + lv) - ((c7arec.kvalue * (1.5/100)) + c7arec.old_duty);
      r_duty.levy := lv;
      r_duty.exrate := c3rec.rate;

    else

      -- Partshipments do not have values except 9001555, form previous_entry_no
	  r_duty.total_invoice := null;
	  r_duty.duty := null;
	  r_duty.ratio_factor := null;
	  r_duty.correct_freight := null;
	  r_duty.internal_freight := null;
	  r_duty.other_costs := null;
	  r_duty.deductions := null;
	  r_duty.insurance := null;
	  r_duty.previous_entry_no:= pin;
      r_duty.excise := null;
      r_duty.vat := null;
      r_duty.pvariance := null;
      r_duty.levy := null;
      r_duty.exrate := null;
    end if;

exception when others
 then
  dbms_output.put_line('Error in Create Duty [movement.ship_id = ' || vship_id || ', detailrs.entry_no_com = ' || entryno || ']: ' || sqlerrm);
end test_duty_com;
/
