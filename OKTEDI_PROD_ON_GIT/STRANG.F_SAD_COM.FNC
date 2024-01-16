CREATE OR REPLACE function STRANG.f_sad_com( parm_id in varchar2, parm1 in number, parm1a in number )
 return varchar2
as

 -- Parm1 = FIRST ENTRY_NO
 -- Parm1a = LAST ENTRY_NO

 cursor c1( parm1 number, parm1a number ) is
  select dr.deliveryno, dr.itemno, r.supplier_customer_id, dr.entry_no
  from receivals r, detailrs dr
  where dr.deliveryno = r.deliveryno and
        entry_no >= parm1 and
        entry_no <= parm1a
        ;


 cursor c2(parm1 number, parm1a number) is
  select /*+ ALL_ROWS */ *
  from sad_com
  ;

 cursor c3( parm1 number ) is
  select /*+ ALL_ROWS */ *
  from ships_airway
  where ship_id in ( select ship_id
                     from movements m, detailrs dr
                     where entry_no = parm1 and
                           m.movement_no = dr.movement_no and
                           nvl(m.seal,'|') = nvl(dr.camov_seal,'|'));


 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;


begin
 if parm_id = 'ZZ'
  then
  -- Consolidate
  delete from sad_com;
  open c1(parm1, parm1a);
   fetch c1 into c1rec;
   close c1;
    for c1rec in c1(parm1, parm1a)
    loop
     insert into strang.sad_com
     (deliveryno, itemno, supplier_customer_id, entry_no)
     values (c1rec.deliveryno, c1rec.itemno, c1rec.supplier_customer_id, c1rec.entry_no);
     update strang.receivals
         set supplier_customer_id = 9002235
         where deliveryno = c1rec.deliveryno;
     update strang.detailrs
         set entry_no = parm1
         where deliveryno = c1rec.deliveryno and itemno = c1rec.itemno;
    end loop;
    commit;
    return( null );
   end if;

 if parm_id = 'ZZZ'
  then
  -- De-Consolidate
   open c3(parm1);
   fetch c3 into c3rec;
   close c3;
   open c2(parm1, parm1a);
   fetch c2 into c2rec;
   close c2;
    for c2rec in c2(parm1, parm1a)
    loop
     update strang.receivals
     set supplier_customer_id = c2rec.supplier_customer_id
     where deliveryno = c2rec.deliveryno;
     update strang.detailrs
     set entry_no = c2rec.entry_no
     where deliveryno = c2rec.deliveryno and itemno = c2rec.itemno;
     websys.strangp.generate_ships_manifest( c3rec.ship_id ,'EXCISE', 'SHIP', c2rec.entry_no, WEBSYS.OLTP.USER_SITE );
    end loop;
    commit;
    for c2rec in c2(parm1, parm1a)
    loop
     websys.strangp.generate_ships_manifest( c3rec.ship_id ,'EXCISE', 'SHIP', c2rec.entry_no, WEBSYS.OLTP.USER_SITE );
    end loop;
    commit;
    delete from sad_com;
    return( null );
   end if;
   delete from sad_com;
 return( null );

end f_sad_com;
/


GRANT EXECUTE ON STRANG.F_SAD_COM TO WEBSYS;
