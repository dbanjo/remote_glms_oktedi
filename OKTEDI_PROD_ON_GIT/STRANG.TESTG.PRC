CREATE OR REPLACE procedure STRANG.testg(vship_id in integer, vste in varchar2)
as

 cursor c3( vship_id integer, vste varchar2 ) is
  select /*+ ALL_ROWS */ dr.deliveryno,dr.rowid,r.supplier_customer_id,dr.itemno,dr.line_no
  from strang.detailrs dr, strang.receivals r,strang.movements m, strang.lov l2, strang.customers c
  where
   m.ship_id = vship_id and
   nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
   m.movement_no = dr.movement_no and
   dr.deliveryno = r.deliveryno and
   c.customer_type = 'CUSTOMER' and
   nvl(r.cust_customer_id,0) = c.customer_id and
   c.customer = l2.description and
   l2.lov_name = 'CONTROLS' and
   l2.cola = vste and
   l2.code = 'CUSTOMS_CUSTOMER'
  order by dr.line_no,dr.deliveryno,dr.itemno;

 cursor c4(sto varchar2) is select max(entry_no) tot from strang.detailrs;

 cursor c5( dlr integer ) is select entry_no from strang.detailrs dr where deliveryno = dlr;
 cursor c5a( dlr integer, ent integer ) is select entry_no from strang.detailrs dr where deliveryno = dlr and entry_no = ent;

 c4rec		 c4%ROWTYPE;
 c5rec		 c5%ROWTYPE;
 c5arec		 c5a%ROWTYPE;
 currsupplier    integer;
 is_partshipment boolean;
 is_loop	 boolean;
 created_duty	 boolean;

begin

open c4('x');
fetch c4 into c4rec;
close c4;
c4rec.tot := nvl(c4rec.tot,0);
currsupplier := 0;
is_partshipment := FALSE;
is_loop := FALSE;
created_duty := FALSE;

for c3rec in c3( vShip_id, vste ) loop

 c5rec.entry_no := NULL;
 c5arec.entry_no := NULL;
 open c5(c3rec.deliveryno);
 fetch c5 into c5rec;
 close c5;
 open c5a(c3rec.deliveryno,c4rec.tot);
 fetch c5a into c5arec;
 close c5a;

 if currsupplier <> c3rec.supplier_customer_id
  then
   is_partshipment := FALSE;
   is_loop := FALSE;
 end if;

 if not is_loop
  then

   if c5rec.entry_no is null
    then
     is_partshipment := FALSE;
    else
     is_partshipment := TRUE;
   end if;

   if c5arec.entry_no is null and is_partshipment
    then
     is_loop := TRUE;
    else
     is_loop := FALSE;
   end if;

 end if;

 if not (is_partshipment and is_loop)
  then

   if currsupplier = 0 or
      currsupplier = c3rec.supplier_customer_id
    then
     -- if currsupplier = 0 then if created_duty then create_duty( vship_id, c4rec.tot); end if; c4rec.tot := c4rec.tot + 1; end if;
     dbms_output.put_line( c3rec.line_no || '-' || c3rec.deliveryno || '-' || c4rec.tot );
     /*
     update strang.detailrs
      set
       entry_no = c4rec.tot
      where
      rowid = c3rec.rowid;
    */
    else
     --if created_duty then create_duty( vship_id, c4rec.tot); end if;
     c4rec.tot := c4rec.tot + 1;
     dbms_output.put_line( c3rec.line_no || '-' || c3rec.deliveryno || '-' || c4rec.tot );
     /*
     update strang.detailrs
      set
       entry_no = c4rec.tot
      where
      rowid = c3rec.rowid;
    */
    end if;
    created_duty := TRUE;

  else

     --if created_duty then create_duty( vship_id, c4rec.tot); end if;
     c4rec.tot := c4rec.tot + 1;
     dbms_output.put_line( c3rec.line_no || '-' || c3rec.deliveryno || '-' || c4rec.tot );
     /*
     update strang.detailrs
      set
       entry_no = c4rec.tot
      where
      rowid = c3rec.rowid;
    */

  created_duty := TRUE;

 end if;

 currsupplier := c3rec.supplier_customer_id;

 end loop;
 -- Last Entry No has yet to be generated
-- if created_duty then create_duty( vship_id, c4rec.tot); end if;

end testg;
/
