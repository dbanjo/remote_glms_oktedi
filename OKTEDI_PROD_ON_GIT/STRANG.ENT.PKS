CREATE OR REPLACE package STRANG.ent as

g_ent_len CONSTANT integer := 7;

function get_entry_no(v_entry_no in number, r_type in varchar2 default 'F') return varchar2;

end ent;
/


GRANT EXECUTE, DEBUG ON STRANG.ENT TO WEBSYS;
