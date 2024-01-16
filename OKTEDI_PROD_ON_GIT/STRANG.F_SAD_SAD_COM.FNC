CREATE OR REPLACE function STRANG.f_sad_sad_com( parm_id in varchar2, parm1 in number, parm1a in number )
 return varchar2
as

 -- Parm1 = FIRST ENTRY_NO
 -- Parm1a = LAST ENTRY_NO

cursor c1(  parm1 in number ) is
select count(distinct r.curr) currno
from strang.receivals r, strang.detailrs dr
where
 dr.deliveryno = r.deliveryno and
 dr.entry_no_com = parm1;

cursor c1x(  parm1 in number ) is
select nvl(count(distinct r.original_curr),0) xcurrno
from strang.receivals r, strang.detailrs dr
where
 dr.deliveryno = r.deliveryno and
 dr.entry_no_com = parm1;


 cursor c2x ( parm1 number ) is
 select r.deliveryno, r.original_curr, p.recno, p.original_tamount, p.original_delivery_charge, p.rowid
 from strang.receivals r, strang.pos p, strang.detailrs dr
 where
    r.deliveryno = dr.deliveryno and
    r.deliveryno = p.deliveryno and
    dr.entry_no_com = parm1 and
    ((r.original_curr is not null) or
    (p.original_tamount is not null) or
    (p.original_delivery_charge is not null));


 cursor c3( parm1 number ) is
  select /*+ ALL_ROWS */ *
  from ships_airway
  where ship_id in ( select ship_id
                     from movements m, detailrs dr
                     where entry_no = parm1 and
                           m.movement_no = dr.movement_no and
                           nvl(m.seal,'|') = nvl(dr.camov_seal,'|'));

 cursor c4 ( parm1 number ) is
  select r.cust_customer_id, min(dr.line_no), p.deliveryno, p.recno, l1.cola, p.rowid
 from strang.receivals r, strang.pos p, strang.lov l1, strang.detailrs dr
  where dr.entry_no = parm1 and
  r.deliveryno = p.deliveryno and
  dr.deliveryno = r.deliveryno and
  l1.lov_name = 'INVENT' and
  l1.code = p.inventoryno
  group by r.cust_customer_id, p.deliveryno, p.recno, l1.cola, p.rowid
  order by min(dr.line_no), p.deliveryno, p.recno;  --  cola could be added which would consolidate


 c1rec		c1%ROWTYPE;
 c1xrec		c1x%ROWTYPE;
 c2xrec		c2x%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 jj		number(16);
 tt		varchar2(20);
 maincurr	varchar2(10);

begin
 if parm_id = 'ZZ'
  then
  -- Consolidate
--   websys.glbx.dbg('ZZ Begin parm1:'|| parm1||' parm1a: '|| parm1a ||' '|| to_char(sysdate,'HH:MI:SS'));

  update strang.detailrs dr
  set entry_no_com = null
  where
  dr.entry_no_com is not null;

  update strang.receivals r
  set supplier_customer_id_com = null
  where
  r.supplier_customer_id_com is not null;

  update strang.duty d
  set entry_no_com = null
  where
  d.entry_no_com is not null;

  update strang.pos p
  set entry_item = null
  where
  p.entry_item is not null;


update strang.detailrs
set entry_no_com = parm1
where
entry_no >= parm1 and
entry_no <= parm1a;

update strang.receivals
set supplier_customer_id_com = 9002235
where deliveryno in
(select dr.deliveryno
from strang.receivals r, strang.detailrs dr
where
dr.entry_no >= parm1 and
dr.entry_no <= parm1a and
dr.deliveryno = r.deliveryno);

update strang.duty
set entry_no_com = parm1
where
entry_no >= parm1 and
entry_no <= parm1a;

commit;

   maincurr := null;
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   if c1rec.currno > 1 then
     maincurr := strang.f_sad_po_curr_com( parm1 );
   end if;

   open c3(parm1);
   fetch c3 into c3rec;
   close c3;

   websys.strangp.generate_ships_manifest( c3rec.ship_id ,'T_EXCISE', 'SHIP', parm1, WEBSYS.OLTP.USER_SITE );

	--
	open c4(parm1);
    fetch c4 into c4rec;
    close c4;
    jj := 0;
    tt := '';
    for c4rec in c4(parm1) loop
--   websys.glbx.dbg('loop begins customer:'|| c4rec.line_no||' delno: '|| c4rec.deliveryno ||' tariff: '|| c4rec.cola ||'  '|| to_char(sysdate,'HH:MI:SS'));
   
	if c4rec.cola = tt then
		  update strang.pos
		  set entry_item = jj
		  where c4rec.rowid = strang.pos.rowid;
		else
   		  tt := c4rec.cola;
		  jj:= jj + 1;
		  update strang.pos
		  set entry_item = jj
		  where c4rec.rowid = strang.pos.rowid;
		end if;
	end loop;
	commit;
	--
    return( null );
   end if;

 if parm_id = 'ZZZ'
  then
  -- De-Consolidate

  open c1x(parm1);
   fetch c1x into c1xrec;
  close c1x;
  if c1xrec.xcurrno <> 0 then
    for c2xrec in c2x(parm1) loop
     update strang.pos set tamount = c2xrec.original_tamount where c2xrec.rowid = strang.pos.rowid and c2xrec.original_tamount is not null;
     update strang.pos set delivery_charge = c2xrec.original_delivery_charge where c2xrec.rowid = strang.pos.rowid and c2xrec.original_delivery_charge is not null;
     update strang.receivals set curr = c2xrec.original_curr where c2xrec.deliveryno = strang.receivals.deliveryno and c2xrec.original_curr is not null;
     update strang.pos set original_tamount = null where c2xrec.rowid = strang.pos.rowid and c2xrec.original_tamount is not null;
     update strang.pos set original_delivery_charge = null where c2xrec.rowid = strang.pos.rowid and c2xrec.original_delivery_charge is not null;
     update strang.receivals set original_curr = null where c2xrec.deliveryno = strang.receivals.deliveryno and c2xrec.original_curr is not null;
    end loop;
    commit;
  end if;

  update strang.detailrs dr
  set entry_no_com = null
  where
  dr.entry_no_com is not null;

  update strang.receivals r
  set supplier_customer_id_com = null
  where
  r.supplier_customer_id_com is not null;

  update strang.duty d
  set entry_no_com = null
  where
  d.entry_no_com is not null;

  update strang.pos p
  set entry_item = null
  where
  p.entry_item is not null;

    commit;
    websys.strangp.generate_ships_manifest( c3rec.ship_id ,'EXCISE', 'SHIP', parm1, WEBSYS.OLTP.USER_SITE );
    return( null );
	end if;
 return( null );

end f_sad_sad_com;
/


GRANT EXECUTE ON STRANG.F_SAD_SAD_COM TO WEBSYS;
