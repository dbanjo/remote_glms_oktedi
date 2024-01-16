CREATE OR REPLACE package WEBSYS.ste
as
/*
   File name   : ste.sql
   Author      : Martijn van den Boogaard
   Date/Time   : 12 Feb 2002 08:04:11
   Description : The state package contains a maintenance suite to maintain
   the state table
*/

procedure maintain_state(surl varchar2, acid integer, sid in integer default 0);
procedure update_state(surl varchar2, acid integer, sid in integer);
procedure accept_update_state(surl varchar2, acid integer, P_state_id integer, P_state_name varchar2, P_state_tlw varchar2, action varchar2 default null);
procedure insert_state(surl varchar2, acid integer, action varchar2 default null);
procedure accept_insert_state(surl varchar2, acid integer, P_state_name varchar2, P_state_tlw varchar2, action varchar2 default null);
procedure delete_state(surl varchar2, acid integer, sid integer);
procedure accept_delete_state(surl varchar2, acid integer, sid integer, action varchar2 default null);

function get_state_lov(p_name in varchar2, p_SelectedValue varchar2 default null, empty_rec boolean default FALSE) return varchar2;
function getStateTLW(pStateId integer) return varchar2;

end ste; -- end package

/
