CREATE OR REPLACE function STRANG.f_sad_sad_com_s( parm_id in varchar2, parm1 in number, parm1a in number )
 return varchar2
as

 -- Parm1 = FIRST ENTRY_NO
 -- Parm1a = LAST ENTRY_NO

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


 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 jj			number(16);
 tt			varchar2(20);


begin
 if parm_id = 'ZZ'
  then
  -- Consolidate
--   websys.glbx.dbg('ZZ Begin parm1:'|| parm1||' parm1a: '|| parm1a ||' '|| to_char(sysdate,'HH:MI:SS'));

  update strang.pos p
  set entry_item = null
  where
  p.entry_item is not null;

commit;
--
   open c3(parm1);
   fetch c3 into c3rec;
   close c3;
   websys.strangp.generate_ships_manifest( c3rec.ship_id ,'EXCISE', 'SHIP', parm1, WEBSYS.OLTP.USER_SITE );

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

  update strang.pos p
  set entry_item = null
  where
  p.entry_item is not null;

    commit;
    websys.strangp.generate_ships_manifest( c3rec.ship_id ,'EXCISE', 'SHIP', parm1, WEBSYS.OLTP.USER_SITE );
    return( null );
	end if;
 return( null );

end f_sad_sad_com_s;
/


GRANT EXECUTE ON STRANG.F_SAD_SAD_COM_S TO WEBSYS;
