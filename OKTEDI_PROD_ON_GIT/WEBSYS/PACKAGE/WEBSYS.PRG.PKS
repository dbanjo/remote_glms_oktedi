CREATE OR REPLACE package WEBSYS.prg
as

procedure maintain_program(surl varchar2, acid integer, program_type varchar2, pid integer default 0);

procedure update_program(surl varchar2, acid integer, P_program_type varchar2, pid integer);

procedure accept_update_program(
  surl                  varchar2,
  acid                  integer,
  pid                   integer,
  P_program_name        varchar2,
  P_program_description varchar2,
  P_duration            varchar2,
  P_cost_per_head       varchar2,
  P_min_nmb		varchar2,
  P_school_year         varchar2,
  P_wars_covered        varchar2,
  P_expire_date         varchar2,
  P_program_type        varchar2,
  p_curriculum_link     varchar2,
  p_url                 varchar2,
  file                  varchar2 default null,
  reload_image          varchar2 default 'N',
  action                varchar2 default null);

procedure insert_program(surl varchar2, acid integer, ptype varchar2, action varchar2 default null);

procedure accept_insert_program(
   surl varchar2,
   acid integer,
   P_program_name        varchar2,
   P_program_description varchar2,
   P_duration            varchar2,
   P_cost_per_head       varchar2,
   P_min_nmb		varchar2,
   P_school_year         varchar2,
   P_wars_covered        varchar2,
   P_program_type        varchar2,
   p_curriculum_link     varchar2,
   p_url                 varchar2,
   P_expire_date         varchar2,
   file                  varchar2 default null,
   action                varchar2 default null);

procedure delete_program(surl varchar2, acid integer, pid integer);

procedure accept_delete_program(surl varchar2, acid integer, pid integer, action varchar2 default null);

end prg;

/
