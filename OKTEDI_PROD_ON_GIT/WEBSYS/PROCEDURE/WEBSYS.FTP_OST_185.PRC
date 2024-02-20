CREATE OR REPLACE procedure WEBSYS.ftp_ost_185(vfile in varchar2, vtype varchar2 default 'FTP')
as

 c_svr        CONSTANT varchar2(100) := 'otmlaesftpst01.blob.core.windows.net';                                             ---'securetransfer.oktedi.com';
 c_un         CONSTANT varchar2(100) := 'otmlaesftpst01.strang'; --'ftpusr1';
 c_pw         CONSTANT varchar2(100) := '0zr8WWFNmpbpfJaz+n4wfvm+LE7Yzc1Z';       ----'T3nder0tml2017';
 c_sftp       CONSTANT varchar2(100) := glbx.extract_master_parameter('BIN_DIR') || '\psftp.exe';
-- c_sftp       CONSTANT varchar2(100) := glbx.extract_master_parameter('BIN_DIR') || '\psftp.exe';
 c_dir        CONSTANT varchar2(100) := glbx.extract_master_parameter('MAIL_TEMPLATE_DIR');
 tmp_dir      CONSTANT varchar2(100) := 'c:\temp\';
 c_rdir       CONSTANT varchar2(100) := '/PowerBI/Strang/'; --    --'strang';   
 --c_rdir2      CONSTANT varchar2(100) := 'Strang';
 c_bat        CONSTANT varchar2(100) := 'ftp_ost_185.bat';
 c_cmd        CONSTANT varchar2(100) := 'C:\WINDOWS\system32\cmd.exe';
-- f2           utl_file.file_type;
-- f_dir      CONSTANT varchar2(1000) := glbx.extract_master_parameter('MAIL_TEMPLATE_DIR');
-- f_file2      CONSTANT varchar2(1000) := 'RECEIPTED_POS_EXTRACT' || to_char(sysdate, 'dd_mon_yyyy_hh24mi') || '.csv';  -- email extract
-- gcode       GLBX.MYARRAY;
-- gparam      GLBX.MYARRAY;
 v_filename  varchar2(100) := glbx.extract_fname(vfile);
 vste        varchar2(10);
 eml         varchar2(100);

 
 l_conn       UTL_TCP.connection;
 f            utl_file.file_type;
 v_cmd        varchar2(1000);
 x            varchar2(1000);
 function control_code( cd in varchar2, vste in varchar2 )
 return varchar2
as

 cursor c1( cd varchar2, vste varchar2 ) is select description from strang.lov where lov_name = 'CONTROLS' and code = cd and cola = vste;

 c1rec	c1%ROWTYPE;

begin
 open c1( cd, vste );
 fetch c1 into c1rec;
 close c1;
 return( c1rec.description );
exception
 when others
  then return( NULL );
end control_code;

begin

eml := control_code( 'OST185_EMAIL_ADDRESS', 'BNE' );
eml := nvl( eml, glbx.extract_master_parameter('MAIL_FROM') );
--
--
-- gcode(2) := 'XXXXV'; 
-- gparam(2) := 'XXXXV';
--  f2 := utl_file.fopen( f_dir, f_file2, 'w', 32767);  -- 
-- utl_file.put_line(f2, buffer=>'F,' || to_char(sysdate,'DD.MM.YYYY') || ',' ||'10034'  );
-- utl_file.fclose( f2 );
-- open c3(sysdate);
-- fetch c3 into c3rec;
-- close c3;

  
  case vtype
  when 'FTP'
   then
    l_conn := ftp_utl.login(c_svr, '21', c_un, c_pw);
    ftp_utl.binary(p_conn => l_conn);
    ftp_utl.put(p_conn      => l_conn,
            p_from_dir  => 'MAIL_TEMPLATE',
            p_from_file => vfile,
            p_to_file   => '/' || c_rdir || '/' || vfile);
    ftp_utl.logout(l_conn);
  when 'SFTP'
   then
    -- dbms_output.put_line(c_dir || '\' || c_bat);
    -- dbms_output.put_line(c_sftp);
    
    f := utl_file.fopen(tmp_dir, c_bat, 'w', 1000);
    utl_file.put_line(f, 'lcd ' || c_dir);
    utl_file.put_line(f, 'cd ' || c_rdir);
   -- utl_file.put_line(f, 'cd ' || c_rdir2 );
    utl_file.put_line(f, 'put "' || vfile || '"');
    utl_file.put_line(f, 'quit');  
    utl_file.fclose(f);
    begin 
    
    dbms_scheduler.create_job('job_ftp_ost_185', 'EXECUTABLE', c_cmd, 3); exception when others then null; end;  -- be:8a:4d:a4:19:4d:6c:fa:da:98:8c:d8:d9:25:8c:5f
    dbms_scheduler.set_job_argument_value('job_ftp_ost_185', 1, '/Q');
    dbms_scheduler.set_job_argument_value('job_ftp_ost_185', 2, '/C');
    v_cmd := c_sftp || ' '  ||c_un||'@'|| c_svr || ' -hostkey "33:d3:f5:6a:8d:b6:06:1c:d1:d8:92:c9:52:8e:6a:58"  -batch -pw ' || c_pw ||' -be -b "' || tmp_dir || '\' || c_bat || '"';
  --   v_cmd := c_sftp || ' ' ||c_un||'@'|| c_svr || ' -hostkey "33:d3:f5:6a:8d:b6:06:1c:d1:d8:92:c9:52:8e:6a:58"  -batch -pw ' || c_pw || ' -P 22 -be  -b "' || c_dir || '\' || c_bat || '"';
   -- v_cmd := c_sftp || ' ' || c_svr || ' -hostkey 33:d3:f5:6a:8d:b6:06:1c:d1:d8:92:c9:52:8e:6a:58 -batch -l ' || c_un || ' -pw ' || c_pw || ' -P 22 -be  -b "' || c_dir || '\' || c_bat || '"';
    dbms_scheduler.set_job_argument_value('job_ftp_ost_185', 3, v_cmd);
    -- dbms_output.put_line(v_cmd);
    -----------------------------------------------------------------------------------------
 
    dbms_scheduler.add_job_email_notification(job_name         => 'job_ftp_ost_185',
                                            sender              => glbx.extract_master_parameter('MAIL_FROM'),
                                            subject             => 'Oracle Scheduler Job Notification ('||v_filename||') - %job_owner%.%job_name%.%job_subname% %event_type%',
                                            body                => 'Job: %job_owner%.%job_name%.%job_subname%
                                                                 Event: %event_type%
                                                                 Date: %event_timestamp%
                                                                 Log id: %log_id%
                                                                 Job class: %job_class_name%
                                                                 Run count: %run_count%
                                                                 Failure count: %failure_count%
                                                                 Retry count: %retry_count%
                                                                 Error code: %error_code%
                                                                  Error message:
                                                                    %error_message%',
                                            recipients       => eml,
                                            filter_condition => '',
                                            events           => 'JOB_FAILED');
                                            
     dbms_scheduler.set_attribute(name      => 'job_ftp_ost_185',
                                  attribute => 'raise_events',
                                   value     => sys.dbms_scheduler.job_failed);
   -------------------------------------------------------------------------------------------------------- 
    
    
    
    dbms_scheduler.enable('job_ftp_ost_185');
    dbms_scheduler.purge_log(7, job_name=>'job_ftp_ost_185');
    -- v_cmd := glbx.extract_master_parameter('WINDOWS_SHELL') || ' ' || c_sftp || ' ' || c_un || '@' || c_svr || ' -pw ' || c_pw || ' -b "' || c_dir || '\' || c_bat || '"';
    -- x := oscommand_run(v_cmd);
   -- utl_file.fremove(c_dir, c_bat);
  dbms_lock.sleep(10);
  utl_file.fremove(tmp_dir, c_bat);
     
  end case;
exception when others then

-- glbx.send( gcode, gparam, sqlerrm, p_to=>'dbanjo@stxgroup.com.au', p_subj=>'SFTP ERROR: '||vfile ||'_'|| c3rec.v1date || '_' || to_char(sysdate, 'hh24mi'), p_from=>glbx.extract_master_parameter('MAIL_FROM'),is_attachment=>true);
 begin utl_file.fclose_all; exception when others then  null; end;
 dbms_output.put_line('ftp_ost_185 error: ' || sqlerrm);
 glbx.dbg('ftp_ost_185 error: ' || sqlerrm);
end ftp_ost_185;
/
