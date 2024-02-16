CREATE OR REPLACE procedure WEBSYS.ftp_ost_185(vfile in varchar2, vtype varchar2 default 'FTP')
as
 c_svr        CONSTANT varchar2(100) := 'otmlaesftpst01.blob.core.windows.net';                                             ---'securetransfer.oktedi.com';
 c_un         CONSTANT varchar2(100) := 'otmlaesftpst01.strang'; --'ftpusr1';
 c_pw         CONSTANT varchar2(100) := '0zr8WWFNmpbpfJaz+n4wfvm+LE7Yzc1Z';       ----'T3nder0tml2017';
 c_sftp       CONSTANT varchar2(100) := glbx.extract_master_parameter('BIN_DIR') || '\psftp.exe';
-- c_sftp       CONSTANT varchar2(100) := glbx.extract_master_parameter('BIN_DIR') || '\psftp.exe';
 c_dir        CONSTANT varchar2(100) := glbx.extract_master_parameter('MAIL_TEMPLATE_DIR');
 c_rdir       CONSTANT varchar2(100) := '/PowerBI/Strang/'; --    --'strang';   
 --c_rdir2      CONSTANT varchar2(100) := 'Strang';
 c_bat        CONSTANT varchar2(100) := 'ftp_ost_185.bat';
 c_cmd        CONSTANT varchar2(100) := 'C:\WINDOWS\system32\cmd.exe';


 l_conn       UTL_TCP.connection;
 f            utl_file.file_type;
 v_cmd        varchar2(1000);
 x            varchar2(1000);

begin
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
    f := utl_file.fopen(c_dir, c_bat, 'w', 1000);
    utl_file.put_line(f, 'lcd ' || c_dir);
    utl_file.put_line(f, 'cd ' || c_rdir);
   -- utl_file.put_line(f, 'cd ' || c_rdir2 );
    utl_file.put_line(f, 'put "' || vfile || '"');
    utl_file.put_line(f, 'quit');  
    utl_file.fclose(f);
    begin dbms_scheduler.create_job('job_ftp_ost_185', 'EXECUTABLE', c_cmd, 3); exception when others then null; end;
    dbms_scheduler.set_job_argument_value('job_ftp_ost_185', 1, '/Q');
    dbms_scheduler.set_job_argument_value('job_ftp_ost_185', 2, '/C');
    v_cmd := c_sftp || ' '  ||c_un||'@'|| c_svr || ' -batch -pw ' || c_pw ||' -be -b "' || c_dir || '\' || c_bat || '"';
   --    v_cmd := c_sftp || ' ' || c_svr || ' -hostkey be:8a:4d:a4:19:4d:6c:fa:da:98:8c:d8:d9:25:8c:5f -batch -l ' || c_un || ' -pw ' || c_pw || ' -P 22 -be  -b "' || c_dir || '\' || c_bat || '"';
    dbms_scheduler.set_job_argument_value('job_ftp_ost_185', 3, v_cmd);
    -- dbms_output.put_line(v_cmd);
    dbms_scheduler.enable('job_ftp_ost_185');
    dbms_scheduler.purge_log(7, job_name=>'job_ftp_ost_185');
    -- v_cmd := glbx.extract_master_parameter('WINDOWS_SHELL') || ' ' || c_sftp || ' ' || c_un || '@' || c_svr || ' -pw ' || c_pw || ' -b "' || c_dir || '\' || c_bat || '"';
    -- x := oscommand_run(v_cmd);
     utl_file.fremove(c_dir, c_bat);
  end case;
exception when others then
 begin utl_file.fclose_all; exception when others then null; end;
 dbms_output.put_line('ftp_ost_185 error: ' || sqlerrm);
 glbx.dbg('ftp_ost_185 error: ' || sqlerrm);
end ftp_ost_185;
/
