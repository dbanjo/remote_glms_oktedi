CREATE OR REPLACE function STRANG.gen_rep_chr(asc_chr in integer, mult in integer default 1)
  return varchar2
as
  v_txt varchar2(1000);
 begin
  v_txt := null;
  for j in 1..mult loop
   v_txt := v_txt || chr(asc_chr);
  end loop;
  return(v_txt);
 exception when others then return(null);
 end gen_rep_chr;
/


GRANT EXECUTE ON STRANG.GEN_REP_CHR TO WEBSYS;
