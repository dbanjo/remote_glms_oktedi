CREATE OR REPLACE package STRANG.tt
as

type ttable is table of STRANG.REPLICATION%ROWTYPE INDEX BY BINARY_INTEGER;
type rtable is table of VARCHAR2(32767) INDEX BY BINARY_INTEGER;

procedure get_records( mt in out ttable, mxid integer, sname varchar2 );
procedure push_data( mt in out ttable, fl in out rtable, result out varchar2 );
procedure mass_run(fl in rtable, last_repid out integer, result out varchar2, errs in out rtable );

end;

/
