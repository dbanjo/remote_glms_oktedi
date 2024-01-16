CREATE OR REPLACE package WEBSYS.rsc
as

procedure maintain_resources(surl varchar2, acid integer, rid in integer default 0);

procedure update_resources(surl varchar2, acid integer, rid in integer);

procedure accept_update_resources(surl varchar2, acid integer, rid integer, P_description varchar2, P_max_group_size number, action varchar2 default null);

procedure insert_resources(surl varchar2, acid integer, action varchar2 default null);

procedure accept_insert_resources(surl varchar2, acid integer, P_description varchar2, P_max_group_size number, action varchar2 default null);

procedure delete_resources(surl varchar2, acid integer, rid integer);

procedure accept_delete_resources(surl varchar2, acid integer, rid integer, action in varchar2 default null);

end rsc;

/
