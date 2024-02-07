CREATE OR REPLACE package STRANG.ent2 as

g_ent_len CONSTANT integer := 7;

function ret_entry_no(v_entry_no in number, custid in varchar2 default '1', r_type in varchar2 default 'F') return varchar2;
function ret_customer(v_entry_no in number) return varchar2;

end ent2;
/


GRANT EXECUTE, DEBUG ON STRANG.ENT2 TO WEBSYS;
