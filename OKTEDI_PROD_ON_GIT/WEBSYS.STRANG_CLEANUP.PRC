CREATE OR REPLACE procedure WEBSYS.strang_cleanup( action in varchar2 default null, starttime in varchar2 default null)
as

 cursor c1(nme varchar2 ) is select job from all_jobs where upper(what) like '%' || upper(nme) || '%';
 jobid integer;

begin

 if action is null
  then
   execute immediate 'alter system switch logfile';

 elsif action = 'STOP'
  then
   open c1( 'strang_cleanup' );
   fetch c1 into jobid;
   close c1;
   if jobid is not null then dbms_job.remove( jobid ); end if;

 elsif action = 'START'
  then
   dbms_job.submit( jobid, 'strang_cleanup;', next_date=>to_date(starttime || ' ' || to_char(sysdate,'DD-MON-YYYY'),'HH24:MI DD-MON-YYYY'), interval=>'sysdate+1' );

 end if;
 commit;

exception when others then null;
end strang_cleanup;

/
