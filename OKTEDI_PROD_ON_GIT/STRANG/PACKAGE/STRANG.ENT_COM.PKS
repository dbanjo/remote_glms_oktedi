CREATE OR REPLACE package STRANG.ent_com as

g_ent_len CONSTANT integer := 7;

function get_entry_no(v_entry_no in number, r_type in varchar2 default 'F') return varchar2;

end ent_com;
/


GRANT EXECUTE ON STRANG.ENT_COM TO WEBSYS;
