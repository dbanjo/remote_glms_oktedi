CREATE OR REPLACE TRIGGER WEBSYS.EMAIL_ON_STARTUP 
after startup
on database
declare
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;
begin
    -- Email Database is up

    delete from report_queue;
    delete from report_queue_parameters;
    delete from report_queue_also_run;

    gcode(1) := 'SYSDATE';
    gparam(1) := to_char(sysdate,'DD Mon YYYY HH24:MI:SS');
    gcode(2) := 'NODE';
    gparam(2) := glbx.extract_master_parameter('NODE_NAME');
    gcode(3) := 'SIGNATURE';
    gparam(3) := glbx.extract_master_parameter('MAIL SIGNATURE');
    glbx.send( gcode, gparam, 'database_startup.tmp', glbx.extract_master_parameter('DBA_MAIL_FROM'), 'Piction Database has been restarted' || ' ' || ':' || glbx.extract_master_parameter('NODE_NAME'), glbx.extract_master_parameter('MAIL_FROM'));

exception
 when others then null;
end;
/
