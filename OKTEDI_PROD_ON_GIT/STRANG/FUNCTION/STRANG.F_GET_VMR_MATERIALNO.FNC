CREATE OR REPLACE function STRANG.f_get_vmr_materialno (vMovement varchar2, vSeal varchar2 default NULL, vdeliveryno number, vpo_number varchar2, vpo_item varchar2, action varchar2)
   return varchar2
   as

          
    cursor c1(vCtr varchar2,vSeal varchar2, vdeliveryno number, vpo_number varchar2, vpo_item varchar2 ) is
    select *
    from 
    (select distinct p.inventoryno, l.description 
    from strang.receivals r, strang.pos p, strang.detailrs dr, strang.movements m, strang.customers c, strang.lov l
    where dr.movement_no = m.movement_no
          and nvl(camov_seal,'|') = nvl(seal,'|')
          and dr.deliveryno = p.deliveryno
          and dr.deliveryno = r.deliveryno
          and r.deliveryno = vdeliveryno
          and r.deliveryno = p.deliveryno
          and p.po = vpo_number
          and p.po_item_no = vpo_item
          and p.inventoryno = l.code
          and l.lov_name = 'INVENT'
          and l.colj = 'VMR'
          and r.supplier_customer_id = c.customer_id
          and m.movement_no = vCtr
          and nvl(m.seal,'|') = nvl(vSeal,'|')) tmp
    where rownum < 5;      

 c1rec  c1%ROWTYPE;

 retvar	varchar2(32767);

begin
 retvar := null;
 if action ='VMR_INVENTORYNO' then             
       for c1rec in c1( vMovement, vSeal,vdeliveryno , vpo_number, vpo_item ) loop
       retvar := retvar || ' ' || c1rec.inventoryno;
       end loop;
      return( ltrim(nvl(retvar,' '),', ') );
  elsif action ='VMR_INVENTORYDESC' then             
       for c1rec in c1( vMovement, vSeal,vdeliveryno , vpo_number, vpo_item ) loop
       retvar := retvar || ' ' || c1rec.description;
       end loop;
      return( ltrim(nvl(retvar,' '),', ') );
  else
      return ( null );
  end if;
  return ( null );
 end f_get_vmr_materialno;
/


GRANT EXECUTE ON STRANG.F_GET_VMR_MATERIALNO TO WEBSYS;
