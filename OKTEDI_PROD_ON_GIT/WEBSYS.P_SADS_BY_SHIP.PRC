CREATE OR REPLACE procedure WEBSYS.p_sads_by_ship(surl varchar2, shipid number)
as

cursor c1(shipid in number) is
select distinct m.bol, min(dr.entry_no) parm1, max(dr.entry_no) parm1a
from
strang.movements m, strang.ships_airway s, strang.receivals r, strang.detailrs dr
where
s.ship_id = shipid and
m.ship_id = s.ship_id and
r.cust_customer_id = 1 and
r.deliveryno = dr.deliveryno and
m.movement_no = dr.movement_no and
nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
group by bol
order by bol;

cursor c2(shipid in number) is
select distinct c.customer
from strang.customers c
where
customer_id = 1;

c1rec		c1%ROWTYPE;
c2rec		c2%ROWTYPE;
ltype		varchar2(100);
stype		integer;
owner_id	integer;
sts		varchar2(100);

begin

  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.SHP' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  open c2(shipid);
  fetch c2 into c2rec;
  close c2;

dapi.GLOBAL_ARRAY.delete;
for c1rec in c1( shipid ) loop
  if strang.validate_entry( c2rec.customer,c1rec.parm1,c1rec.parm1a,'RANGE') < 1
   then
     htp.p('Incomplete SAD '|| c1rec.bol ||' Entry numbers '|| c1rec.parm1 ||' To '|| c1rec.parm1a); htp.nl;
  elsif strang.validate_single_customer( c2rec.customer,c1rec.parm1,c1rec.parm1a,'RANGE') < 1
   then
     htp.p('Multiple Customers for SAD '|| c1rec.bol ||' Entry numbers '|| c1rec.parm1 ||' To '|| c1rec.parm1a); htp.nl;
  else
    htp.p(c1rec.parm1 || ' CONSOLIDATE: ' || strang.f_sad_sad_com( 'ZZ', c1rec.parm1, c1rec.parm1a)); htp.nl;
    htp.p(c1rec.parm1 || ' GENERATE: ' || strang.f15_parameter_range_com( 'SAD_SAD_COM_NOEMAIL', c1rec.parm1,'Y' )); htp.nl;
    htp.p(c1rec.parm1 || ' DECONSOLIDATE: ' || strang.f_sad_sad_com( 'ZZZ', c1rec.parm1, c1rec.parm1a )); htp.nl;
  end if;
end loop;

websys.strangs.email_sad_file_multi(dapi.GLOBAL_SURL);

htp.p( 'SADs for ship emailed' ); htp.nl;

exception
  when others then htp.p( sqlerrm ); htp.nl;
end p_sads_by_ship;
/
