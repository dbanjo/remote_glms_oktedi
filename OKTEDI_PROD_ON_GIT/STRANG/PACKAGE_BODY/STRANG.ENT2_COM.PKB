CREATE OR REPLACE package body STRANG.ent2_com as

function ret_entry_no(v_entry_no in number, custid in varchar2 default '1', r_type in varchar2 default 'F') return varchar2
is

cursor c1(v_ent number) is
 select *
 from   detailrs
 where  entry_no_com = v_ent
 ;

c1rec         c1%ROWTYPE;
v_mant        varchar2(100);
n_ent         number;
v_ret         varchar2(100);

begin

 open c1(v_entry_no);
 fetch c1 into c1rec;
 if c1%FOUND
  then
   v_ret := to_char(c1rec.entry_no_com, '9999999990.9999999');
 else
   v_mant := to_char(v_entry_no - trunc(v_entry_no));              -- retrieves customer id.
   if v_mant = 0 then
    v_ret := to_char(c1rec.entry_no_com, '9999999990.9999999');
   else
    v_mant := custid || '.' || lpad(v_entry_no, g_ent_len, '0');
    n_ent := to_number(v_mant);
    close c1;
    open c1(n_ent);
    fetch c1 into c1rec;
    if c1%FOUND
     then
      v_ret := to_char(c1rec.entry_no_com, '9999999990.9999999');
    else
      v_ret := to_char(v_entry_no);
    end if;
  end if;
 end if;
 close c1;
exception when others then
 websys.glbx.dbg('ENT2_COM.RET_ENTRY_NO [' || v_entry_no || ']: ' || sqlerrm);

 return(to_char(v_ret));
end ret_entry_no;

function ret_customer(v_entry_no in number) return varchar2
is

cursor c1(v_ent number) is
 select c.customer
 from   receivals r, detailrs d, customers c
 where  entry_no_com = v_ent and
		r.deliveryno = d.deliveryno and
		r.cust_customer_id = c.customer_id
 ;

c1rec         c1%ROWTYPE;
n_ent         number;
v_ret         varchar2(100);

begin

 open c1(v_entry_no);
 fetch c1 into c1rec;
 if c1%FOUND
  then
   v_ret := c1rec.customer;
 end if;
 close c1;
--exception when others then
 --websys.glbx.dbg('ENT2_COM.RET_ENTRY_NO [' || v_entry_no || ']: ' || sqlerrm);
 return(v_ret);
end ret_customer;

end ent2_com;
/


GRANT EXECUTE ON STRANG.ENT2_COM TO WEBSYS;
