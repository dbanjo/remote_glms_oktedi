CREATE OR REPLACE function STRANG.f_sad_po_curr_com( parm1 in number )
 return varchar2
as

 -- Parm1 = CONSOLIDATED ENTRY_No


cursor c2(  parm1 in number ) is
select curr from (
select count(r.curr) xx, r.curr
from strang.receivals r, strang.detailrs dr
where
 dr.deliveryno = r.deliveryno and
 dr.entry_no_com = parm1
 group by curr
 order by xx desc, curr asc
)
where rownum < 2
;

 cursor c3 ( parm1 number, maincurr varchar2 ) is
 select r.deliveryno, r.curr, p.recno, p.tamount, round((nvl(p.tamount,0)*l3.description/l2.description),2) new_tamount, p.delivery_charge,
 round((nvl(p.delivery_charge,0)*l3.description/l2.description),2) new_delivery_charge,p.rowid, sa.estarrive
 from strang.receivals r, strang.pos p, strang.lov l2, strang.lov l3, strang.detailrs dr, strang.ships_airway sa,
 strang.movements m
 where
    r.deliveryno = dr.deliveryno and
    r.deliveryno = p.deliveryno and
    dr.entry_no_com = parm1 and
    dr.movement_no = m.movement_no and
    nvl(m.seal,0) = nvl(dr.camov_seal,0) and
    m.ship_id = sa.ship_id and
    r.curr <> maincurr and
    l2.lov_name = 'UNRATTAB' and
    l2.code = r.curr and
    to_date(l2.cola,'DD-MON-YYYY') <= sa.estarrive and
    nvl(to_date(l2.colb,'DD-MON-YYYY'),sa.estarrive) >= sa.estarrive and
    l3.lov_name = 'UNRATTAB' and
    l3.code = maincurr and
    to_date(l3.cola,'DD-MON-YYYY') <= sa.estarrive and
    nvl(to_date(l3.colb,'DD-MON-YYYY'),sa.estarrive) >= sa.estarrive;

 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 maincurr 	varchar2(10);

begin

  open c2(parm1);
   fetch c2 into c2rec;
  close c2;

  maincurr := c2rec.curr;
    open c3(parm1, maincurr);
     fetch c3 into c3rec;
    close c3;
    for c3rec in c3(parm1,maincurr) loop
      update strang.pos set original_tamount = c3rec.tamount where c3rec.rowid = strang.pos.rowid;
      update strang.pos set tamount = c3rec.new_tamount where c3rec.rowid = strang.pos.rowid;
      update strang.pos set original_delivery_charge = c3rec.delivery_charge where c3rec.rowid = strang.pos.rowid;
      update strang.pos set delivery_charge = c3rec.new_delivery_charge where c3rec.rowid = strang.pos.rowid;
      update strang.receivals set original_curr = c3rec.curr where c3rec.deliveryno = strang.receivals.deliveryno;
      update strang.receivals set curr = maincurr where c3rec.deliveryno = strang.receivals.deliveryno;

    end loop;
    commit;
 return( maincurr );

end f_sad_po_curr_com;
/


GRANT EXECUTE ON STRANG.F_SAD_PO_CURR_COM TO WEBSYS;
