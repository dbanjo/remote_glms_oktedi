CREATE OR REPLACE FUNCTION WEBSYS.OSCommand_Run2(Command IN STRING)
 return varchar2
as
 cursor c1(vname varchar2) is select 'x' exst from user_scheduler_jobs where job_name = vname;
 c1rec  c1%ROWTYPE;
 jname		varchar2(100) := 'SJOB';
begin
open c1(jname);
fetch c1 into c1rec;
if c1%FOUND
 then
  close c1;
  dbms_scheduler.drop_job( job_name => jname, force=>TRUE );
  commit;
 else
  close c1;
end if;

 dbms_scheduler.create_job
 (
  job_name      => jname,
  job_type      => 'EXECUTABLE',
  job_action    => 'c:\windows\system32\cmd.exe',
  enabled       => false,
  number_of_arguments => 1,
  comments      => 'Run shell-script'
 );
 dbms_scheduler.set_job_argument_value(jname,1,'/c ' || Command);
 dbms_scheduler.enable(jname);
 commit;
 for j in 1..1000 loop
  open c1(jname);
  fetch c1 into c1rec;
  if c1%NOTFOUND then close c1; exit; end if;
  close c1;
  dbms_lock.sleep(1/10);
 end loop;
 return( '0' );
exception
 when others then glbx.dbg( 'err in subjob:' || sqlerrm ); return( '1' );
end OSCommand_Run2;
/
