CREATE OR REPLACE function STRANG.gen_add_field(vval in varchar2, max_length integer default null, delim integer default 0, is_num boolean default FALSE)
  return varchar2
  as
  v_txt varchar2(1000);
 begin
  v_txt := trim(vval);
  if max_length is not null and length(v_txt) > max_length
   then
    v_txt := substr(v_txt, 1, max_length);
  end if;
  v_txt := v_txt || gen_rep_chr(0);
  return(v_txt);
 exception when others then return(null);
 end gen_add_field;
/


GRANT EXECUTE ON STRANG.GEN_ADD_FIELD TO WEBSYS;
