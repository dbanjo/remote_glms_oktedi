CREATE OR REPLACE PROCEDURE WEBSYS.CONTAINER_REPORT_PDF (p_mov in varchar2 , p_seal in varchar2, p_user in varchar2, p_filename out varchar2 )  AS

 cursor c2(v_sessid integer ) is
  select distinct umo_id, document_original_loc 
  from websys.login_session ls, websys.umo u
  where ls.sessid = v_sessid 
    and u.aid = ls.aid
    and u.report_id in (1840,1898, 1557) 
    and u.date_created between ls.DATE_CREATED and nvl(ls.date_updated,sysdate)
   order by umo_id;
      
  
 cursor c3(v_mov varchar2, v_seal varchar2) is
  select ss.shipname, m.ship_id
    from strang.movements m, strang.ships_airway ss
   where m.movement_no = v_mov
    and  nvl(m.seal,'|') = nvl(v_seal,'|')
    and  ss.ship_airway = 'S'
    and  ss.ship_id = m.ship_id;
    
 cursor c4(v_username varchar2) is
  select cp.pw as password_owner
    from websys.customer_account ca, websys.audit_customer_password cp
  where upper(username) = upper(v_username)
   and  ca.aid = cp.aid
   and  cp.DATE_CHANGED = (select max(date_changed)
                             from websys.audit_customer_password cp1
                             where cp.aid = cp1.aid);

 c1rec         customer_account%ROWTYPE;
 --c2rec         c2%ROWTYPE;
 c3rec         c3%ROWTYPE;
 c4rec         c4%ROWTYPE;

 v_user        varchar2(50) := p_user;
 v_pwd         varchar2(50); --  := 'MAY92OWA';
 v_repid       number := 1026;
 v_lvl         number := 0;
 v_p0          WEBSYS.GLBX.MYARRAY;
 v_p1          WEBSYS.GLBX.MYARRAY;
 v_ptype       WEBSYS.GLBX.MYARRAY;
 v_sts         varchar(100);
 v_session_id  integer;
 v_stype       integer;
 v_surl        varchar2(500);
 ltype	       varchar2(100);
 stype		   integer;
 owner_id	   integer;
 sts		   varchar2(100);
 
----- copied from create pdf ----
c_pdf_tk      CONSTANT varchar2(100) := 'C:\Program Files (x86)\PDFtk Server\bin';
c_html_pdf    CONSTANT varchar2(100) := 'C:\Program Files\wkhtmltopdf\bin';
c_cmd_1a       CONSTANT varchar2(1000) := 'wkhtmltopdf.exe -O Landscape -T 5mm -B 5mm -q  --zoom .85 "<source>" "<target>"';
c_cmd_1b       CONSTANT varchar2(1000) := 'wkhtmltopdf.exe -O Portrait -T 5mm -B 5mm -q  --zoom .85 "<source>" "<target>"';
c_cmd_2       CONSTANT varchar2(1000) := 'pdftk.exe';
c_max_pages   CONSTANT integer := 100; -- Break into chunks if too many invoices 
 
dir_list      ump.directory_list_arr;
orig_report   varchar2(1000);
f             utl_file.file_type;
v_cmd         varchar2(32767);
work_file     varchar2(1000);
work_dir      varchar2(1000);
pdf_array     owa.vc_arr;
outp_array    owa.vc_arr;
ctr           integer;
n_umo         integer;
pdf_trgt_1    varchar2(1000);
pdf_trgt_2    varchar2(1000);
pdf_file      varchar2(1000);
v_umo_id      integer;


----- end here!!
 
BEGIN

 open c4(v_user);
 fetch c4 into v_pwd;
 close c4;
 
 open c3( p_mov, p_seal);
 fetch c3 into c3rec;
 close c3;
 
 

glbx.Logon_user (  un => v_user
                 , pw => v_pwd
                 , sts => v_sts
                 , session_id => v_session_id
                 , stype => v_stype
                 , surl => v_surl);
            
    dbms_output.put_line('user name '||v_user ||' and surl is: '||v_surl);
    dbms_output.put_line('user name '||v_user ||' and session_id is: '||to_char(v_session_id));
    dbms_output.put_line('user name '||v_user ||' and sts is: '||to_char(v_sts));
    dbms_output.put_line('user name '||v_user ||' and stype is: '||to_char(v_stype));
    dbms_output.put_line('user name '||v_user ||' and password is: '||to_char(v_pwd));
     
    glbx.cookie_id( v_surl, stype, ltype, owner_id, sts, call_type=>'S', progcalled=>'OLTP.DISPLAY_REPORTS', ignore_cookie_check=>TRUE );  
    
    c1rec := glbx.get_aid( owner_id, 'S', ltype );
     
    dbms_output.put_line('owner_id is  '||owner_id);
    dbms_output.put_line('aid is  '||c1rec.aid); 
    
    v_p0(1)    := 'LOGIN.OWNER_ID';
    v_p1(1)    := c1rec.aid;
    v_ptype(1) := 'NO DISPLAY';
    v_p0(2)    := 'LOGIN.USERNAME';
    v_p1(2)    :=  v_user; 
    v_ptype(2) := 'NO DISPLAY';
    v_p0(3)    := 'LOGIN.LOOK_AND_FEEL';
    v_p1(3)    := c1rec.theme_name;
    v_ptype(3) := 'NO DISPLAY';
    v_p0(4)    := 'LOGIN.LOGIN_TYPE';
    v_p1(4)    := 'OWNER';
    v_ptype(4) := 'NO DISPLAY';
    v_p0(5)    := 'LOGIN.SURL';
    v_p1(5)    :=  v_surl;
    v_ptype(5) := 'NO DISPLAY';
    v_p0(6)    := 'LOGIN.BFTR172';
    v_p1(6)    := '';
    v_ptype(6) := 'NO DISPLAY';
    v_p0(7)    := 'LOGIN.BFTR173';
    v_p1(7)    := '';
    v_ptype(7) := 'NO DISPLAY';
    ---------------------------------
    v_p0(8)    := 'SHIP NAME';
    v_p1(8)    := c3rec.shipname;                 ---'OT IDEAAL';
    v_ptype(8) := 'C';
    ---------------------------------
    v_p0(9)    := 'SHIP_ID';
    v_p1(9)    := c3rec.ship_id;                    --'9002493';
    v_ptype(9) := 'C';
    ---------------------------------
    v_p0(10)    := 'CONTAINER NO';
    v_p1(10)    := p_mov;                  ---'KUDU1059785';
    v_ptype(10) := 'C';

     websys.oltp.webservice_run_report( surl => v_surl
                         --  , repid => v_repid
                            , name => 'INTL CONTAINER MANIFEST + INVOICES'                                                            --'INTL CONTAINER MANIFEST'
                          -- , lvl => v_lvl
                           , p1 => v_p0
                           , p2 => v_p1);
                          -- , ptype => v_ptype );
    
    websys.oltp.webservice_run_report( surl => v_surl
                         --  , repid => v_repid
                            , name => 'INTL CONTAINER PACKING DECLARATION'
                          -- , lvl => v_lvl
                           , p1 => v_p0
                           , p2 => v_p1);
                          -- , ptype => v_ptype );
                          
    websys.oltp.webservice_run_report( surl => v_surl
                         --  , repid => v_repid
                            , name => 'INTL CONTAINER WEIGHT DECLARATION'
                          -- , lvl => v_lvl
                           , p1 => v_p0
                           , p2 => v_p1);

    glbx.acct_logoff(v_surl);
    dbms_lock.sleep(1);
    
    ctr := 0;
      
      -- work_dir := nvl(glbx.extract_master_parameter('WORK_DIRECTORY'), 'c:\temp');
      work_dir := 'c:\temp';
       
    for c2rec in  c2(v_session_id) loop
    
       ctr := ctr + 1;
       if ctr = 1 then 
         v_umo_id := c2rec.umo_id;
         work_file := 'batch_' || c2rec.umo_id || '.bat';
         f := utl_file.fopen(work_dir, work_file, 'w', 32700);
         utl_file.put_line(f, '@echo off', TRUE);
         utl_file.put_line(f, 'set PATH=%PATH%;p:\piction\images;P:\Piction\strang\receival_reports;' || c_pdf_tk || ';' || c_html_pdf, TRUE);
       end if;
       

       
       orig_report := c2rec.document_original_loc || decs.UNIX_OR_NT || 'report_' || c2rec.umo_id || '.html';
       pdf_trgt_1 := c2rec.document_original_loc || decs.UNIX_OR_NT || 'report_' || c2rec.umo_id || '.pdf';
       if ctr = 1 then 
          v_cmd := replace(replace(c_cmd_1a, '<source>', orig_report), '<target>', pdf_trgt_1);
       else
          v_cmd := replace(replace(c_cmd_1b, '<source>', orig_report), '<target>', pdf_trgt_1);
       end if;
       utl_file.put_line(f, v_cmd, TRUE);
       v_cmd := null;
       
       pdf_array(ctr) := pdf_trgt_1;
     
    
    end loop;
    
    --pdf_trgt_2 := glbx.extract_master_parameter('STRANG_RECEIVALS_DIR') || decs.UNIX_OR_NT  || 'reports' || decs.UNIX_OR_NT || 'report_' || v_umo_id || '.pdf';
    pdf_trgt_2 := work_dir|| decs.UNIX_OR_NT || 'report_' || v_umo_id || '.pdf';
    p_filename := pdf_trgt_2;
    
    if pdf_array.count > 0 then
       for j in pdf_array.first..pdf_array.last loop
          
          if j = 1 then
             v_cmd := c_cmd_2 || ' "' || pdf_array(j) || '" ';
             utl_file.put(f, v_cmd);
          else
             utl_file.put(f, '"' || pdf_array(j) || '" ');
          end if;
       end loop;
   
       utl_file.put_line(f, ' output "' || pdf_trgt_2 || '"', TRUE);
   end if;
--   if pdf_array.count > 0
--    then
--     for j in pdf_array.first..pdf_array.last loop
--      utl_file.put_line(f, 'del "' || pdf_array(j) || '"');
--     end loop;
--   end if;
   utl_file.put_line(f, 'exit', TRUE);
   utl_file.fclose(f);
   
   begin utl_os.OsCmdDirectWait(work_dir || decs.UNIX_OR_NT || work_file); exception when others then null; end;
   if utl_os.delete_file(work_dir || decs.UNIX_OR_NT || work_file) then null;  end if;
   
END;
/


GRANT EXECUTE ON WEBSYS.CONTAINER_REPORT_PDF TO STX1;
