CREATE OR REPLACE package body WEBSYS.utl_os as

 SHELL_TASK_ID		integer;
 SHELL			    varchar2(100) := 'RUN_SHELL';

procedure OSCmdNoWait(cmd in varchar2)
is

 jobidx	integer;

begin
 jobidx := subjob(cmd);
exception
 when others then return;
end OSCmdNoWait;

procedure OSCmdDirectWait(cmd in varchar2)
is

 cursor c1(xname varchar2) is select count('x') cnt from user_scheduler_jobs where job_name = xname;

 jobidx	integer;
 tot	integer;

begin
 jobidx := subjob(cmd);
 for j in 1..100 loop
  open c1(SHELL || jobidx);
  fetch c1 into tot;
  close c1;
  if tot = 0 then exit; end if;
  dbms_lock.sleep(j);
 end loop;
exception
 when others then return;
end OSCmdDirectWait;

procedure cleanup_shells
as
 cursor c1(xname varchar2) is select job_name from user_scheduler_jobs where job_name like xname;
begin
 for c1rec in c1( SHELL || '%' ) loop
   begin
    dbms_scheduler.drop_job( job_name => c1rec.job_name, force=>TRUE );
   exception
    when others then null;
   end;
 end loop;
 commit;
end cleanup_shells;

function findjob( vtxt varchar2 )
 return integer
as
 cursor c1(xname varchar2) is select count('x') cnt from user_scheduler_jobs where job_name = xname;
 tot	integer;
begin
 for j in 1..100 loop
  open c1(vtxt || to_char(j));
  fetch c1 into tot;
  close c1;
  if tot = 0 then return( j ); end if;
  if j = 3 then cleanup_shells; end if; -- auto cleanup rogue shells
 end loop;
exception
 when others then return( 1 );
end findjob;

function subjob( cmd in varchar2 )
 return integer
as

 jobidx		integer;
 jaction	varchar2(1000);

begin
   jobidx := findjob( SHELL );
   if DECS.UNIX_OR_NT = '\'
    then
     jaction := nvl(glbx.extract_master_parameter('XE_CMD'),'c:\windows\system32\cmd.exe');
     dbms_scheduler.create_job
     (
      job_name      => SHELL || jobidx,
      job_type      => 'EXECUTABLE',
      job_action    => jaction,
      enabled       => false,
      number_of_arguments => 2,
      comments      => 'Run shell-script'
     );
     dbms_scheduler.set_job_argument_value(SHELL || jobidx,1,'/C');
     dbms_scheduler.set_job_argument_value(SHELL || jobidx,2,cmd);

  else

     jaction := nvl(glbx.extract_master_parameter('XE_CMD'),'/bin/sh');
   dbms_scheduler.create_job
   (
      job_name      => SHELL || jobidx,
      job_type      => 'EXECUTABLE',
      job_action    => jaction,
      enabled       => false,
      number_of_arguments => 2,
      comments      => 'Run shell-script'
   );
     dbms_scheduler.set_job_argument_value(SHELL || jobidx,1,'-c');
     dbms_scheduler.set_job_argument_value(SHELL || jobidx,2,cmd);
 end if;
 dbms_scheduler.enable(SHELL || jobidx);
 return( jobidx );
end subjob;

function MkDir(filepath in varchar2)
 return boolean
is

begin
 if DECS.UNIX_OR_NT = '\'
  then
   OSCmdDirectWait( 'mkdir "' || filepath || '"');
  else
   OSCmdNoWait( 'mkdir -p "' || filepath || '"' );
 end if;
 return(TRUE);
exception
 when others then
  return( FALSE );
end MkDir;

function RenameDir(olddirectorypath in varchar2, newdirectory in varchar2)
 return boolean
is

begin
 if DECS.UNIX_OR_NT = '\'
  then
   OSCmdDirectWait( 'rename "' || olddirectorypath || '" "'||newdirectory||'"');
  else
   OSCmdNoWait( 'mv -R "'|| olddirectorypath || '" "'||newdirectory||'"');
 end if;
 return(TRUE);
exception
 when others then
  return( FALSE );
end RenameDir;

function delete_file(filepath in varchar2)
 return boolean
is

begin
 if DECS.UNIX_OR_NT = '\'
  then
   OSCmdDirectWait( 'del "' || filepath || '"');
  else
   OSCmdNoWait( 'rm.sh "' || filepath || '"');
 end if;
 return(TRUE);
exception
 when others then
  return( FALSE );
end delete_file;

end utl_os;
/


GRANT EXECUTE ON WEBSYS.UTL_OS TO STX1;
