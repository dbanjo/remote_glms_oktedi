CREATE OR REPLACE function STRANG.f_get_info(vMovement varchar2, vSeal varchar2 default NULL, action varchar2)
   return varchar2
   as

    cursor c1(vCtr varchar2,vSeal varchar2) is
    select c.customer vendor , po
    from strang.receivals r, strang.pos p, strang.detailrs dr, strang.movements m, strang.customers c
    where dr.movement_no = m.movement_no
          and nvl(camov_seal,'|') = nvl(seal,'|')
          and dr.deliveryno = p.deliveryno
          and dr.deliveryno = r.deliveryno
          and r.supplier_customer_id = c.customer_id
          and m.movement_no = vCtr
          and nvl(m.seal,'|') = nvl(vSeal,'|')
          and rownum < 2
          order by c.customer,r.deliveryno,dr.itemno,p.recno;

    cursor c3(vCtr varchar2,vSeal varchar2) is
    select l1.colc
    from strang.lov l1, strang.movements m
    where l1.lov_name = 'CTRTYPE'
      and l1.code = nvl(m.container_type,'BREAK BULK')
      and m.movement_no = vCtr
      and nvl(m.seal,'|') = nvl(vSeal,'|')
      and l1.colc is not null;

    cursor c3a(vCtr varchar2,vSeal varchar2) is
    select distinct dr.detaildesc
    from strang.detailrs dr
    where dr.movement_no = vCtr
          and nvl(dr.camov_seal,'|') = nvl(vSeal,'|');

    cursor c4(vCtr varchar2,vSeal varchar2) is
    select distinct hazard
    from strang.detailrs dr
    where dr.movement_no = vCtr
          and nvl(dr.camov_seal,'|') = nvl(vSeal,'|');
          
    cursor c5(vCtr varchar2,vSeal varchar2) is
    select *
    from 
    (select distinct p.inventoryno
    from strang.receivals r, strang.pos p, strang.detailrs dr, strang.movements m, strang.customers c
    where dr.movement_no = m.movement_no
          and nvl(camov_seal,'|') = nvl(seal,'|')
          and dr.deliveryno = p.deliveryno
          and dr.deliveryno = r.deliveryno
          and r.supplier_customer_id = c.customer_id
          and m.movement_no = vCtr
          and nvl(m.seal,'|') = nvl(vSeal,'|')) tmp
    where rownum < 5;
          
          

 c1rec  c1%ROWTYPE;
 c3rec  c3%ROWTYPE;
 c3arec c3a%ROWTYPE;
 c4rec  c4%ROWTYPE;

 retvar	varchar2(32767);

begin
 retvar := null;
 if action = 'PO'
  then
      open c1(vMovement,vSeal);
      fetch c1 into c1rec;
      if c1%FOUND
       then retvar := c1rec.po;
      end if;
      close c1;
       return ( retvar );
  elsif action = 'VENDOR'
      then
      open c1(vMovement,vSeal);
      fetch c1 into c1rec;
      if c1%FOUND
       then retvar := c1rec.vendor;
      end if;
      close c1;
       return ( retvar );
  elsif action = 'DESCRIPTION'
      then
      open c3(vMovement,vSeal);
      fetch c3 into c3rec;
      if c3%FOUND
       then retvar := c3rec.colc;
      else
       for c3arec in c3a(vMovement,vSeal) loop
        retvar := retvar||', '|| c3arec.detaildesc;
        if length(retvar) > 300 then exit; end if;
       end loop;
      end if;
      close c3;
       return ( ltrim(nvl(retvar,' '),',') );
    --  return( substr(nvl(retvar,'&nbsp;&nbsp;&nbsp;&nbsp;'),3,500) );
  elsif action = 'HAZARDOUS'
      then
      for c4rec in c4( vMovement, vSeal ) loop
       retvar := retvar || ', ' || c4rec.hazard;
       end loop;
      return( ltrim(nvl(retvar,' '),', ') );
      
  elsif action = 'INVENTORYNO' then 
       for c5rec in c5( vMovement, vSeal ) loop
       retvar := retvar || ' ' || c5rec.inventoryno;
       end loop;
      return( ltrim(nvl(retvar,' '),', ') );
  else
      return ( null );
  end if;
  return ( null );
 end f_get_info;
/


GRANT EXECUTE ON STRANG.F_GET_INFO TO WEBSYS;
