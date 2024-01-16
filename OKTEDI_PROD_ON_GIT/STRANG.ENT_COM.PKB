CREATE OR REPLACE package body STRANG.ent_com as

function get_entry_no(v_entry_no in number, r_type in varchar2 default 'F') return varchar2
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
   v_mant := to_char(v_entry_no - trunc(v_entry_no));
   v_mant := '.' || lpad(substr(v_mant, 2), g_ent_len, '0');
   n_ent := to_number(trunc(v_entry_no) || v_mant);
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
 close c1;

 case upper(r_type)
 when 'F'
  then
   return(trim(v_ret));
 when 'E'
  then
   return(regexp_replace(trim(v_ret), '(^[[:digit:]]*)(\.)(.*)', '\3'));
 when 'X'
  then
   return( trim(leading '0' from regexp_replace(trim(v_ret), '(^[[:digit:]]*)(\.)(.*)', '\3')));
 when 'C'
  then
   return( trunc(v_entry_no));
 when 'D'
  then
   if websys.glbx.guess_number(v_entry_no) is not null
    then
	 return( lpad(websys.glbx.guess_number(v_entry_no), 7, '0') );
   else
     return(to_char(v_entry_no));
   end if;
 else
   return(to_char(v_entry_no));
 end case;
exception when others then
 websys.glbx.dbg('ENT_COM.GET_ENTRY_NO [' || v_entry_no || ']: ' || sqlerrm);
 return(to_char(v_entry_no));
end get_entry_no;

end ent_com;
/


GRANT EXECUTE ON STRANG.ENT_COM TO WEBSYS;
