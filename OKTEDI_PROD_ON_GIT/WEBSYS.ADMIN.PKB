CREATE OR REPLACE package body WEBSYS.admin
as

 procedure ins_report( txt in varchar2, ctr in out integer, markup in boolean, mup in varchar2 default null, v2 in varchar2 default null );
 procedure update_question( surl in varchar2, hid in integer, pcode in varchar2, p1 in varchar2, p2 in varchar2, sqlerrm out varchar2 );
 -- procedure cookie_id( owner_id out integer, sts out varchar2 );
 procedure update_health_check( error_message out varchar2, hid in integer, pOrganisation in varchar2, pPerson_Performing_Check in varchar2, pDate_Check_Performed in date default sysdate,
                                pDatabase_Name in varchar2 Default null, pLanguage in varchar2 default 'ENGLISH', pVendor in varchar2 default 'ORACLE', pNotes_before in varchar2 Default null, pNotes_after in varchar2 Default null );
 procedure drop_health_check( error_message out varchar2, pHealth_check_id in integer );
 procedure reset_health_check( error_message out varchar2, pHealth_check_id in integer );
 procedure update_health_result( error_message out varchar2, pHealth_check_id in integer, pParameter_Code in varchar2, result in varchar2, pExtra_Note in varchar2 default null);
 procedure delete_health_result( error_message out varchar2, pHealth_check_id in integer, pParameter_Code in varchar2);
 procedure reverse_engineer_apache_logs;

 procedure health_report( pHealth_check_id in integer,markup in boolean default FALSE, include_summary in boolean default TRUE, include_all in boolean default TRUE, include_exception in boolean default TRUE,
                          include_score_by_group in boolean default TRUE, include_total_score in boolean default TRUE, include_grade in boolean default TRUE, include_complexity in boolean default TRUE );
 procedure compare_health_checks( pHealth_check_id_a in integer, pHealth_check_id_b in integer, markup in boolean default FALSE);
 function calculate_health_complexity( health_check_id in integer, error_message out varchar2, complexity_variation in varchar2 default admin.DEFAULT_VARIATION_COMPLEXITY  ) return integer;
 function calculate_health_score_perc( health_check_id in integer, error_message out varchar2, grp in varchar2 default null ) return number;
 function grade_site( score_perc in number, error_message out varchar2, grading_method in varchar2 default admin.DEFAULT_GRADE_SCORE ) return varchar2;
 function get_db_type( hid in integer )  return varchar2;

 function create_health_check( error_message out varchar2, pOrganisation in varchar2, pPerson_Performing_Check in varchar2, pDate_Check_Performed in date default sysdate,
                               pDatabase_Name in varchar2 Default null, pNotes_before in varchar2 Default null, pLanguage in varchar2 default 'ENGLISH', pVendor in varchar2 default 'ORACLE' ) return integer;
 function start_manager return varchar2;
 function stop_manager return varchar2;
 function job_status return varchar2;

 procedure general_management( error_message out varchar2, table_code in varchar2, action_type in varchar2, p1 in varchar2, p2 in varchar2,
                               p3 in varchar2 default null, p4 in varchar2 default null, p5 in varchar2 default null );
 procedure main_title( ttl in varchar2, other_elements in varchar2 default null, style in varchar2 default 'BIG' );
 procedure cleanup_piction( dly in varchar2 default 'DAY');
 procedure calculate_cost_stats( schema_name in varchar2 default null, force_stats in boolean default false );
 procedure run_sql_statement( crs in varchar2, numcols in integer );
 procedure all_report;
 procedure send_renewals;
 procedure alert_log_report( check_from in number default 1 );
 procedure cleanup_lightbox( cln in integer );
 procedure cleanup_preorders( cln in integer );
 procedure check_admin_unload( tgap in integer );
 procedure check_emails_for_load;


procedure daily_monitor
 as

  cursor c1 is
   select *
   from phg_batch_upload
   where substr(status,1,length(LNG2.PFM_TXT_061)) <> LNG2.PFM_TXT_061 and
         status <> LNG3.ADM_TXT_521
   order by date_submitted asc;
  cursor c2(phgid integer) is select ftp_load_dir from photographer where pid = phgid;
  cursor c3(acid integer) is select 'x' from customer_account where aid = acid;
  cursor c4 is select 'x' from all_jobs where upper(what) like 'ADM.ACCEPT_LARGE_LOAD(%';

  id 		integer;
  minutes	integer;
  tmp		char(1);
  cln		integer;
  worked	boolean;
  retval	varchar2(1000);
  api_job	varchar2(1000);
  c1rec		c1%ROWTYPE;
  c2rec		c2%ROWTYPE;
  stage		varchar2(100);

begin
 stage := 'Step A';
 minutes := (to_number(to_char(sysdate,'HH24')) * 60) + to_number(to_char(sysdate,'MI'));

 -- Check and Run Daily Jobs
 if minutes >= 120 and minutes < 125
  then
   -- Run Daily Jobs
    -- 1. Cleanup
    stage := 'Step B';
    cleanup_piction( 'DAY' );

    -- 2. Calculate Cost Stats
    stage := 'Step C1';
    calculate_cost_stats( user );

    -- 3. Send out Renewal Notices
    stage := 'Step C2';
    send_renewals;
    -- 4. Extract Currency -- now redundant
    --if glbx.extract_master_parameter('MONITOR_CURRENCY') = 'TRUE' then extract_currency_rates; end if;

    -- 5. Look for new queries to run
    stage := 'Step D';
    worked := ump.check_daily_queries;

    -- 6. Anniversaries for the Anniversary Novelty
    stage := 'Step E';
    worked := anniversaries;

    -- 7. Reverse Engineer Apache Log Files
    stage := 'Step F';
    reverse_engineer_apache_logs;

    -- 8. Cull Downtime Records
    stage := 'Step G';
    if odm.cull_log_file then null; end if;

    -- 9. Cleanup old directories
    stage := 'Step G1';
    if drop_old_directories then null; end if;

    -- Run API Cleanup Job
    stage := 'Step H';
    api_job := glbx.extract_master_parameter('ADMIN_CLEANUP_API');
    if api_job is not null
     then
      begin
       execute immediate
        'begin ' ||
        ':1 := ' || trim(api_job) || '; ' ||
        'end;'
        using in out retval;
      exception
       when others then null;
      end;
    end if;

    stage := 'Step I';
    -- Run Weekly Jobs
    if (to_char(sysdate,'DY') = ADMIN.REPORT_WEEK_ON) and (minutes between 120 and 125)
     then
       -- 1. Cleanup Piction
       stage := 'Step J';
       cleanup_piction( 'WEEK' );
       stage := 'Step K';
       alert_log_report( 7 );

       -- Delete Old Lightbox Data
       cln := NULL;
       begin cln := glbx.extract_master_parameter('CULL_LIGHTBOX'); exception when others then cln := null; end;
       if cln is not null
        then
         stage := 'Step K1';
         cleanup_lightbox( cln );
       end if;

       -- Delete Old PreOrder Data
       cln := NULL;
       begin cln := glbx.extract_master_parameter('CULL_PREORDERS'); exception when others then cln := null; end;
       if cln is not null
        then
         stage := 'Step L';
         cleanup_preorders( cln );
       end if;

    end if;
 end if;

 -- Check Dynamic Reports
 stage := 'Step M';
 oltp.check_reports( to_number(TIMEGAP) );

 -- Look for Admin Unload Work to Perform
 stage := 'Step N';
 check_admin_unload( to_number(TIMEGAP) );

 -- Check site availability and the downtime monitor
 stage := 'Step O';
 if odm.check_sites then null; end if;

 -- Check Emails to Load
 stage := 'Step G1';
 check_emails_for_load;

 -- Look for Photographer Load Work to Perform
 open c1;
 fetch c1 into c1rec;
 if c1%FOUND
  then
    -- Check to make sure there are no other jobs on the queue (especially from other accounts)
    --
    close c1;
    tmp := NULL;
    open c4;
    fetch c4 into tmp;
    close c4;
    if tmp is NULL
     then
      -- Check acccount has not been deleted
      tmp := NULL;
      open c3(c1rec.aid);
      fetch c3 into tmp;
      if c3%FOUND
       then
        close c3;
        open c2(c1rec.pid);
        fetch c2 into c2rec;
        close c2;
        update phg_batch_upload
        set
          status = LNG2.PFM_TXT_062
         where pid = c1rec.pid and
               aid = c1rec.aid;
         dbms_job.submit(id,'adm.run_load_job(surl=>''' || glbx.encrypt_password( c1rec.load_id ) || ''',vload_id=>' || c1rec.load_id || ', runfrom=>''BATCH'');' );
         /*
         dbms_job.submit(id,'adm.accept_large_load(surl=>''' || null || ''',phgid=>' || c1rec.pid || ', p1=>''' || c1rec.aid || ''', p2=>''' ||
                 replace(replace( c1rec.ftp_dir,'[','[' || c2rec.ftp_load_dir),'''','''''') || ''', p3=>NULL, p4=>NULL, penbl=>''' || 'T' || ''',' ||
                'strorig=>''' || 'F' || ''', debug=>''' || 'F' || ''', ftploc=>NULL, objtype=>''' || 'PHOTO' || ''',' ||
                'p5=>''' || 'JPEG' || ''', p6=>''' || c1rec.compr_qual || ''', p6a=>NULL, p7=>''' || '140' || ''', p7a=>''' || c1rec.thmb_qual || ''',' ||
                'p8=>''' || 'F'|| ''', p9=>''' || 'p_' || ''', p40=>''' || c1rec.create_subdir || ''', p41=>''' || c1rec.incl_subdirs || ''',' ||
                'p10=>''' || 'R' || ''', p11=>''' || LNG.PHG_TXT_231 || ''', p11a=>''' || '45' || ''', p11b=>''' || LNG.PHG_TXT_451 || ''',' ||
                'p11c=>''' || LNG.PHG_TXT_385 || ''', p12=>''' || c1rec.umo_scene_id || ''', p27=>''' || '65' || ''', p28=>NULL,' ||
                'p29=>''' || c1rec.film_type || ''', p30=>''' || c1rec.film_roll || ''', p31=>''' || 'F' || ''', global_scene_id=>NULL,p42=>''BATCH-PHG'' );' );
         */
         commit;
      else
       close c3;
      end if;
    end if;
  else
   close c1;
 end if;
 stage := 'Step Q';

exception
 when others then
  glbx.error_details( 'ADMIN', 'DAILY_MONITOR',null,vaid=>null,errmsg=>sqlerrm,extdet=>c1rec.pid || '-' || c1rec.aid || ' Debug Stage:' || stage );
  dbms_output.put_line( sqlerrm );
end daily_monitor;

function start_manager
  return varchar2
 as
  cursor c1 is select job from all_jobs where what = JOB_NAME;
  c1rec		c1%ROWTYPE;
  retvar	varchar2(100);
  subid		integer;
 begin
  open c1;
  fetch c1 into c1rec;
  if c1%FOUND
   then
    retvar := LNG3.ADM_TXT_011 ||': #' || c1rec.job;
   else
    dbms_job.submit(subid,JOB_NAME,sysdate,'sysdate + ' || TIME_FREQUENCY);
    retvar := LNG3.ADM_TXT_035 || ': #' || subid;
  end if;
  close c1;
  commit;
  return(retvar);
 exception when others then retvar := sqlerrm; begin close c1; exception when others then null; end; return(retvar);
 end start_manager;

function stop_manager
  return varchar2
as
  cursor c1 is select job from all_jobs where what = JOB_NAME;
  c1rec		c1%ROWTYPE;
  retvar	varchar2(100);
begin
  open c1;
  fetch c1 into c1rec;
  if c1%FOUND
   then
    dbms_job.remove(c1rec.job);
    retvar := LNG3.ADM_TXT_037 || ': #' || c1rec.job;
   else
    retvar := LNG3.ADM_TXT_039;
  end if;
  close c1;
  commit;
  return(retvar);
 exception when others then retvar := sqlerrm; begin close c1; exception when others then null; end; return(retvar);
 end stop_manager;

function job_status
  return varchar2
 as
  cursor c1 is select * from all_jobs where what = JOB_NAME;
  c1rec		c1%ROWTYPE;
  retvar	varchar2(100);
 begin
  open c1;
  fetch c1 into c1rec;
  if c1%FOUND
   then
    retvar := htf.nl || c1rec.job || htf.nl || c1rec.what || htf.nl || LNG3.ADM_TXT_065 || '-' || c1rec.broken || htf.nl ||
              LNG3.ADM_TXT_072 || '-' || nvl(c1rec.failures,0) || htf.nl || to_char(c1rec.next_date,LNG.TSMASK);
   else
    retvar := LNG3.ADM_TXT_039;
  end if;
  close c1;
  commit;
  return(retvar);
 exception when others then retvar := sqlerrm; begin close c1; exception when others then null; end; return(retvar);
 end job_status;

 procedure submit_batch(surl varchar2)
  as
   sessid	integer;
   sts		varchar2(200);
  begin
   glbx.adm_cookie_id(surl,sessid,sts);
   if sts is not null
    then
     htp.htmlopen;
     htp.nl;
     htp.nl;
     htp.bold( sts );
     htp.nl;
     htp.nl;
     htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
     htp.nl;
     htp.htmlclose;
     return;
   end if;
   main_title( start_manager );
   htp.htmlclose;
 end submit_batch;

 procedure stop_batch(surl varchar2)
  as
   sessid	integer;
   sts		varchar2(200);
  begin
   glbx.adm_cookie_id(surl,sessid,sts);
   if sts is not null
    then
     htp.htmlopen;
     htp.nl;
     htp.nl;
     htp.bold( sts );
     htp.nl;
     htp.nl;
     htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
     htp.nl;
     htp.htmlclose;
     return;
   end if;
   main_title( stop_manager );
   htp.htmlclose;
 end stop_batch;

 procedure manage_jobs(surl varchar2)
 as

  cursor c1 is select name,value from v$parameter where name like '%job%';
  cursor c2 is select name,value from v$parameter where name like 'opt%';

  sessid	integer;
  sts		varchar2(200);

 begin
  glbx.adm_cookie_id(surl,sessid,sts);
  if sts is not null
   then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
  end if;
  adm.main_title( surl,sessid, LNG3.ADM_TXT_075 );
  htp.nl;
  htp.header( 3, LNG3.ADM_TXT_078 || ': ' || job_status, 'CENTER' );
  htp.nl;
  htp.bold( LNG3.ADM_TXT_087);htp.nl;
  for c1rec in c1 loop
   htp.italic( c1rec.name || '-' || htf.bold(c1rec.value)); htp.nl;
  end loop;
  htp.nl;
  htp.bold( LNG3.ADM_TXT_095 );htp.nl;
  for c2rec in c2 loop
   htp.italic( c2rec.name || '-' || htf.bold(c2rec.value)); htp.nl;
  end loop;
  htp.nl;
  htp.bold( LNG.LAB_TXT_001 || ':' ); htp.nl;
  htp.ulistopen;
   htp.listitem( htf.anchor2( 'admin.manage_batch_queue?surl=' || glbx.rndsurl(surl) || '&msg=',LNG5.EXT_TXT_116,ctarget=>'BATCH_WINDOW' ) );
   htp.listitem( htf.anchor2( 'admin.submit_batch?surl=' || glbx.rndsurl(surl),LNG3.ADM_TXT_107,ctarget=>'BATCH_WINDOW' ) );
   htp.listitem( htf.anchor2( 'admin.stop_batch?surl=' || glbx.rndsurl(surl),LNG3.ADM_TXT_128,ctarget=>'BATCH_WINDOW' ) );
   htp.listitem( htf.anchor( 'admin.force_storage?surl=' || glbx.rndsurl(surl),LNG3.ADM_TXT_145 ) );
   -- htp.listitem( htf.anchor( 'admin.force_opt?surl=' || glbx.rndsurl(surl),LNG3.ADM_TXT_172 ) );
   htp.listitem( htf.anchor2( 'force_opt?surl=' || glbx.rndsurl(surl) || '&v_schema=STRANG','Optimisation Figures - STRANG', ctarget=>'BATCH_WINDOW' ) );
   htp.listitem( htf.anchor2( 'force_opt?surl=' || glbx.rndsurl(surl) || '&calc_stats=T&v_schema=STRANG','Force optimisation - STRANG', ctarget=>'BATCH_WINDOW' ) );
   htp.listitem( htf.anchor2( 'force_opt?surl=' || glbx.rndsurl(surl) || '&v_schema=WEBSYS','Optimisation Figures - WEBSYS', ctarget=>'BATCH_WINDOW' ) );
   htp.listitem( htf.anchor2( 'force_opt?surl=' || glbx.rndsurl(surl) || '&calc_stats=T&v_schema=WEBSYS','Force optimisation - WEBSYS', ctarget=>'BATCH_WINDOW' ) );
   htp.listitem( htf.anchor2( 'force_opt?surl=' || glbx.rndsurl(surl) || '&calc_stats=D&v_schema=WEBSYS','Gather Dictionary Statistics', ctarget=>'BATCH_WINDOW' ) );
  htp.ulistclose;
 htp.htmlclose;
end manage_jobs;

procedure manage_batch_queue(surl in varchar2, msg in varchar2)
as
   cursor c1 is select * from all_jobs order by next_date desc;

   sessid	integer;
   sts		varchar2(200);

begin
 glbx.adm_cookie_id(surl,sessid,sts);
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( LNG5.EXT_TXT_116 );
 if msg is not null then glbx.header_msg(msg); end if;
 htp.p( '<CENTER>' );
 htp.nl;
 htp.formopen( 'admin.accept_manage_batch_queue' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'P1', null );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG5.EXT_TXT_117 ), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold( LNG5.EXT_TXT_118 ), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold( LNG5.EXT_TXT_119 ), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold( LNG5.EXT_TXT_120 ), cattributes=>glbx.QUERY_BACKGROUND );
  htp.tablerowclose;
 for c1rec in c1 loop
  htp.tablerowopen;
   htp.formhidden( 'P3', c1rec.job );
   htp.tabledata( htf.formcheckbox( 'P1', c1rec.job ), cattributes=>glbx.QUERY_CELL_BACKGROUND );
   htp.tabledata( htf.bold( c1rec.job ), cattributes=>glbx.QUERY_CELL_BACKGROUND );
   htp.tabledata( htf.formtext( 'P2', 30, 100, to_char(c1rec.next_date, LNG.TSMASK)), cattributes=>glbx.QUERY_CELL_BACKGROUND );
   htp.tabledata( c1rec.what, cattributes=>glbx.QUERY_CELL_BACKGROUND );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG5.EXT_TXT_121 );
 htp.formclose;
 htp.nl;
 htp.nl;
 htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
end manage_batch_queue;

procedure accept_manage_batch_queue(surl varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY)
as
   cursor c1 is select * from all_jobs order by next_date desc;

   sessid	integer;
   sts		varchar2(200);
   nd		date;

begin
 glbx.adm_cookie_id(surl,sessid,sts);
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 -- Remove jobs from queue
 for j in p1.first..p1.last loop
  if p1(j) is not null
   then
    begin
     dbms_job.remove( p1(j) );
    exception
     when others then manage_batch_queue(surl, p3(j) || '-' || sqlerrm ); return;
    end;
  end if;
 end loop;

 -- update job queue timings
 for j in p3.first..p3.last loop
  if p3(j) is not null
   then
    begin nd := to_date(p2(j),LNG.TSMASK ); exception when others then manage_batch_queue(surl, 'Bad Date:' || p2(j)); return; end;
    if nd is not null
     then
      begin dbms_job.change(job=>p3(j),what=>NULL,next_date=>nd,interval=>NULL); exception when others then manage_batch_queue(surl, p3(j) || '-' || sqlerrm ); return; end;
    end if;
  end if;
 end loop;
 manage_batch_queue(surl,NULL);
end accept_manage_batch_queue;

procedure force_opt(surl varchar2)
as
   cursor c1 is select table_name,num_rows,avg_row_len,blocks from user_tables order by table_name;
   sessid	integer;
   sts		varchar2(200);
begin
 glbx.adm_cookie_id(surl,sessid,sts);
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( LNG3.ADM_TXT_189 );
 htp.nl;
 calculate_cost_stats( user, TRUE );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tableheader( LNG3.ADM_TXT_296 );
  htp.tableheader( LNG3.ADM_TXT_224 );
  htp.tableheader( LNG3.ADM_TXT_301 );
  htp.tableheader( LNG3.ADM_TXT_236 );
 htp.tablerowclose;
 for c1rec in c1 loop
  htp.tablerowopen;
   htp.tabledata( htf.bold(htf.italic(c1rec.table_name)) );
   htp.tabledata( nvl(to_char(c1rec.num_rows),'[-]') );
   htp.tabledata( nvl(to_char(c1rec.avg_row_len),'[-]') );
   htp.tabledata( nvl(to_char(c1rec.blocks),'[-]') );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.htmlclose;
end force_opt;

procedure force_storage(surl varchar2)
as
   cursor c1 is select table_name,num_rows,avg_row_len,blocks from user_tables order by table_name;
   sessid	integer;
   sts		varchar2(200);
begin
 glbx.adm_cookie_id(surl,sessid,sts);
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 main_title( LNG3.ADM_TXT_239 );
 htp.nl;
 alert_log_report(1);
 htp.bold( LNG3.ADM_TXT_245 );
 htp.htmlclose;
end force_storage;

procedure cleanup_piction( dly in varchar2 default 'DAY')
 as

  cursor c1 is select * from all_directories where directory_path like GLBX.GLOBAL_DIR || '%';
  ctr	integer;

 begin
  if dly = 'WEEK'
   then
     -- Remove old email tracking records (older than 30 days). Hard code it seems to be fine.
     delete from track_email where date_stored < (sysdate-30);
     delete from dir_results;
     delete from phg_batch_upload_parms where load_id in (select load_id from phg_batch_upload where date_submitted < (sysdate-3) );
     delete from phg_batch_upload where date_submitted < (sysdate-3);
     commit;

     -- Cleanup bad foreign keys
     update photographer ph
      set logo_phid = null
      where logo_phid not in (select umo_id from umo where umo_id = ph.logo_phid) and
            logo_phid is not null;

     update customer_account ca
      set background_img = null
      where background_img not in (select umo_id from umo where umo_id = ca.background_img) and
            background_img is not null;

     update slide_master sm
      set background_gif = null
      where background_gif not in (select umo_id from umo where umo_id = sm.background_gif) and
            background_gif is not null;

    -- Cleanup old directory definitions
    for c1rec in c1 loop
     begin
      execute immediate 'drop directory ' || c1rec.directory_name;
     exception when others then null;
     end;
    end loop;

  end if;

  begin ctr := to_number(glbx.extract_master_parameter('DISCONNECT_AFTER')); exception when others then ctr := 180; end;
  ctr := nvl(ctr,180);
  update login_session
    set
     is_connected = 'F'
  where (sysdate - nvl(date_updated,date_created))*1440 > ctr and
        is_connected = 'T';
  commit;
 end cleanup_piction;

procedure calculate_cost_stats( schema_name in varchar2 default null, force_stats in boolean default false )
as

  cursor c1(tmp char) is
   select cb.schema, cb.table_name, cb.estimate_compute, cb.estimate_value_perc
   from dba_tables d, cbo cb
   where  (((d.last_analyzed is null) or
           ((d.last_analyzed is not null and (sysdate - nvl(cb.refresh_every,7) > d.last_analyzed)) and (cb.static_dynamic = 'DYNAMIC'))
          ) or tmp='T')
       and
          cb.estimate_compute in ('ESTIMATE','COMPUTE') and
          d.owner = cb.schema and
          d.table_name = cb.table_name and
          (schema_name is null or (cb.schema = schema_name));

   cursor c2(tname varchar2) is select index_name from user_indexes where index_type = 'NORMAL' and index_name like 'I_%' and table_name = tname;

 tmp char(1);

 begin
 tmp := 'F';
 if force_stats then tmp := 'T'; end if;

  for c1rec in c1(tmp) loop
    -- Will calculate all statistics for the table and includes index stats and column histogram stats.
    begin
      dbms_ddl.analyze_object('TABLE',c1rec.schema,c1rec.table_name,c1rec.estimate_compute,null,c1rec.estimate_value_perc,null,null);
      -- Perform a full analysis on any index - compute historgram statistics
      for c2rec in c2(c1rec.table_name) loop
       begin
        execute immediate 'alter index ' || c2rec.index_name || ' rebuild';
       exception
        when others then null;
       end;
       execute immediate 'analyze index ' || c2rec.index_name || ' compute statistics for all indexed columns size 100';
      end loop;
    exception
      when others then htp.p( c1rec.schema || c1rec.table_name || ':' || sqlerrm ); htp.nl;
    end;
  end loop;
exception when others then
  glbx.error_details( 'ADMIN', 'CALCULATE_COST_STATS',null,vaid=>null,errmsg=>sqlerrm,extdet=>schema_name || '-' || tmp );
end calculate_cost_stats;

procedure general_management( error_message out varchar2, table_code in varchar2, action_type in varchar2, p1 in varchar2, p2 in varchar2,
                               p3 in varchar2 default null, p4 in varchar2 default null, p5 in varchar2 default null )
 as
  tcode varchar2(10);
  atype	varchar2(1);
 begin
  -- Table Codes are: LOV, GROUP, SCORE, GRADE, COMPLEXITY
  if upper(table_code) in ( 'LOV', 'GROUP', 'SCORE', 'GRADE', 'COMPLEXITY' )
   then
    tcode := upper(table_code);
   else
    error_message := 'Unknown table_code : ' || table_code || '. Must be one of [LOV, GROUP, SCORE, GRADE, COMPLEXITY]';
    return;
  end if;
  -- Action Types are: I,Ins,Insert,U,Upd,Update,D,Del,Delete (any case)
  if upper(action_type) in ('I','INS','INSERT','U','UPD','UPDATE','D','DEL','DELETE')
   then
    atype := substr(upper(action_type),1,1);
   else
    error_message := 'Unknown action_type : ' || action_type || '. Must be one of [I,Ins,Insert,U,Upd,Update,D,Del,Delete]';
    return;
  end if;

  if    tcode = 'LOV'
   then
    if    atype = 'I'
     then
      insert into lov( lov_type, lov_value, other_value ) values ( p1, p2, p3 );
    elsif atype = 'U'
     then
      update lov set lov_value = p2, other_value = p3 where lov_type = p1;
      if sql%NOTFOUND then error_message := 'Lov Type not found: ' || p1; return; end if;
    else
      delete from lov where lov_type = p1;
      if sql%NOTFOUND then error_message := 'Lov Type not found: ' || p1; return; end if;
    end if;
  elsif tcode = 'GROUP'
   then
    if    atype = 'I'
     then
      insert into health_group( category, group_name, code, order_by ) values (p1, p2, p3, p4);
    elsif atype = 'U'
     then
      update health_group set category = p1, code=p3, order_by=p4 where group_name = p2;
      if sql%NOTFOUND then error_message := 'Group Name not found: ' || p2; return; end if;
    else
      delete from health_group where group_name = p2;
      if sql%NOTFOUND then error_message := 'Group Name not found: ' || p2; return; end if;
    end if;
  elsif tcode = 'SCORE'
   then
    if    atype = 'I'
     then
      insert into score(parameter_code,loval,highval,given_score,expected_value) values (p1,p2,p3,p4,p5);
    elsif atype = 'U'
     then
      update score
       set loval=p2,highval=p3,given_score=p4,expected_value=p5
       where (parameter_code = p1 and loval = p2 ) or (parameter_code = p1 and highval = p3 );
      if sql%NOTFOUND then error_message := 'Could not find Score Record.'; return; end if;
    else
      delete from score
       where (parameter_code = p1 and loval = p2 ) or (parameter_code = p1 and highval = p3 );
      if sql%NOTFOUND then error_message := 'Could not find Score Record.'; return; end if;
    end if;
  elsif tcode = 'GRADE'
   then
    if    atype = 'I'
     then
      insert into grade_score(grade_category,loval,highval,grade) values (p1,p2,p3,p4);
    elsif atype = 'U'
     then
      update grade_score set loval = p2, highval = p3 where grade_category = p1 and grade = p4;
      if sql%NOTFOUND
       then
        update grade_score set grade=p4 where grade_category = p1 and loval = p2 and highval = p3;
        if sql%NOTFOUND then error_message := 'Unable to find Grade Record'; return; end if;
      end if;
    else
      delete from grade_score where grade_category = p1 and grade = p4;
      if sql%NOTFOUND
       then
        delete from grade_score where grade_category = p1 and loval = p2 and highval = p3;
        if sql%NOTFOUND then error_message := 'Unable to find Grade Record'; return; end if;
      end if;
    end if;
  elsif tcode = 'COMPLEXITY'
   then
    if    atype = 'I'
     then
      insert into site_complexity(variation,parameter_code,value,weighting,log_base) values (p1,p2,p3,p4,p5);
    elsif atype = 'U'
     then
      update site_complexity set value = p3, weighting = p4, log_base = p5
       where variation = p1 and parameter_code = p2;
      if sql%NOTFOUND then error_message := 'Unable to find complexity record'; return; end if;
    else
      delete from site_complexity where variation = p1 and parameter_code = p2;
      if sql%NOTFOUND then error_message := 'Unable to find complexity record'; return; end if;
    end if;
  end if;
  commit;
 exception
  when others then error_message := sqlerrm; rollback;
 end general_management;

 procedure update_health_result( error_message out varchar2, pHealth_check_id in integer, pParameter_Code in varchar2, result in varchar2, pExtra_Note in varchar2 default null)
 as
  cursor c1 is
   select response_type
   from health_parameters
   where parameter_code = pParameter_Code;

 cursor c2 is
  select 'x'
  from lov
  where lov_type = pParameter_Code and
        lov_value = result;

 cursor c3 is
  select 'x'
  from lov
  where lov_type = 'FUZZY RESPONSE' and
        lov_value = result;

  c1rec		c1%ROWTYPE;
  tnumber	number;
  tchar		char(1);

 begin
  open c1;
  fetch c1 into c1rec;
  close c1;
  if c1rec.response_type is null
   then
    error_message := LNG3.ADM_TXT_568 || ': ' || pParameter_Code;
    return;
  end if;

  if    c1rec.response_type in ('NUMBER','SCORE')
   then
    begin
     tnumber := to_number( result );
    exception
     when others then error_message := LNG.PHG_TXT_210 || ': ' || result; return;
    end;
    update health_result
     set
      result_number = tnumber,
      extra_note = pExtra_Note
     where parameter_code = pParameter_Code and health_check_id = pHealth_Check_Id;
  elsif c1rec.response_type = 'TEXT'
   then
    update health_result
     set
      result_text = result,
      extra_note = pExtra_Note
     where parameter_code = pParameter_Code and health_check_id = pHealth_Check_Id;
  elsif c1rec.response_type = 'BOOLEAN'
   then
    tchar := NULL;
    open c3;
    fetch c3 into tchar;
    close c3;
    if tchar is null then error_message := LNG3.ADM_TXT_569 || ': ' || result; return; end if;
    update health_result
     set
      result_text = result,
      extra_note = pExtra_Note
     where parameter_code = pParameter_Code and health_check_id = pHealth_Check_Id;
  elsif c1rec.response_type = 'LOV'
   then
    tchar := NULL;
    open c2;
    fetch c2 into tchar;
    close c2;
    if tchar is null then error_message := LNG3.ADM_TXT_570 || ': ' || result; return; end if;
    update health_result
     set
      result_text = result,
      extra_note = pExtra_Note
     where parameter_code = pParameter_Code and health_check_id = pHealth_Check_Id;
  end if;
  commit;
 exception
  when others then error_message := sqlerrm;
 end update_health_result;

 procedure delete_health_result( error_message out varchar2, pHealth_check_id in integer, pParameter_Code in varchar2)
 as
 begin
  delete from health_result where parameter_code = pParameter_Code and health_check_id = pHealth_Check_Id;
  commit;
 exception
  when others then error_message := sqlerrm;
 end delete_health_result;

 function create_health_check( error_message out varchar2, pOrganisation in varchar2, pPerson_Performing_Check in varchar2, pDate_Check_Performed in date default sysdate,
                               pDatabase_Name in varchar2 Default null, pNotes_before in varchar2 Default null, pLanguage in varchar2 default 'ENGLISH', pVendor in varchar2 default 'ORACLE' )
  return integer
 as
  return_id	integer;
 begin
  select s_health_check.nextval into return_id from dual;
  insert into health_check(health_check_id, organisation, person_performing_check, database_name, date_check_performed, notes_before, notes_after, language, database_vendor ) values
   (return_id, pOrganisation, pPerson_performing_check, pDatabase_name, pDate_check_performed, pNotes_before, null, pLanguage, pVendor);
  insert into health_result (parameter_code,health_check_id)
   select parameter_code, return_id from health_parameters where language=pLanguage and database_vendor=pVendor;
  commit;
  return( return_id );
 exception
  when others then error_message := sqlerrm; return( 0 );
 end create_health_check;

 procedure update_health_check( error_message out varchar2, hid in integer, pOrganisation in varchar2, pPerson_Performing_Check in varchar2, pDate_Check_Performed in date default sysdate,
                                pDatabase_Name in varchar2 Default null, pLanguage in varchar2 default 'ENGLISH', pVendor in varchar2 default 'ORACLE', pNotes_before in varchar2 Default null, pNotes_after in varchar2 Default null )
 as
  return_id	integer;
 begin
  update health_check
   set
    organisation = pOrganisation,
    person_performing_check = pPerson_performing_check,
    database_name = pDatabase_name,
    date_check_performed = pDate_check_performed,
    language = pLanguage,
    database_vendor = pVendor,
    notes_before = pNotes_before,
    notes_after = pNotes_after
   where
    health_check_id = hid;
  commit;
 exception
  when others then error_message := sqlerrm;
 end update_health_check;


 procedure drop_health_check( error_message out varchar2, pHealth_check_id in integer )
 as
 begin
  delete from health_result hr where hr.health_check_id = pHealth_check_id;
  delete from health_check hc where hc.health_check_id = pHealth_check_id;
  commit;
 exception
  when others then error_message := sqlerrm;
 end drop_health_check;

 procedure reset_health_check( error_message out varchar2, pHealth_check_id in integer )
 as
 begin
  update health_result hr set result_fuzzy_boolean = null, result_number = null, result_text = null where hr.health_check_id = pHealth_check_id;
  commit;
 exception
  when others then error_message := sqlerrm;
 end reset_health_check;

 function grade_site( score_perc in number, error_message out varchar2, grading_method in varchar2 default admin.DEFAULT_GRADE_SCORE )
   return varchar2
 as
  cursor c1 is
   select grade
   from grade_score
   where score_perc between loval and highval and
         grade_category = grading_method;

  c1rec	c1%ROWTYPE;

 begin
  open c1;
  fetch c1 into c1rec;
  close c1;
  return( nvl(c1rec.grade,LNG3.ADM_TXT_567) );

 exception
  when others
   then
    return( LNG3.ADM_TXT_567 );
 end grade_site;

 function calculate_health_score_perc( health_check_id in integer, error_message out varchar2, grp in varchar2 default null )
   return number
 as

  cursor c1( hparm integer ) is
   select sum(nvl(score_result,0)) tot_score
   from health_result hr, health_parameters hp
   where health_check_id = hparm and
         hp.parameter_code = hr.parameter_code and
         ((grp is null) or (grp is not null and hp.group_topic=grp));

  cursor c2( hparm integer, dt varchar2 ) is
   select sum(nvl(max_score,0)) tot_score
   from health_result hr,health_parameters hp
   where hr.health_check_id = hparm and
         hp.parameter_code = hr.parameter_code and
         (hr.result_fuzzy_boolean <> 'Not Relevant' or hr.result_fuzzy_boolean is null) and
         hp.response_type = 'BOOLEAN' and
         ((grp is null) or (grp is not null and hp.group_topic=grp)) and
         ( (database_type = dt) or (database_type='In House and 3rd Party') or (dt='In House and 3rd Party') );

  cursor c3( hparm integer, dt varchar2 ) is
   select sum(nvl(sc.given_score,0)) tot_score
   from health_result hr,health_parameters hp, score sc
   where hr.health_check_id = hparm and
         hp.parameter_code = hr.parameter_code and
         hr.score_result is not null and
         hp.response_type = 'SCORE' and
         sc.parameter_code = hp.parameter_code and
         ((grp is null) or (grp is not null and hp.group_topic=grp)) and
         sc.expected_value = 'Y' and
         ( (database_type = dt) or (database_type='In House and 3rd Party') or (dt='In House and 3rd Party') );

  site_score	integer;
  tot_score2	integer;
  tot_score3	integer;
  dt		HEALTH_RESULT.RESULT_TEXT%TYPE;

 begin
  open c1( health_check_id );
  fetch c1 into site_score;
  close c1;
  dt := get_db_type( health_check_id );

  open c2( health_check_id, dt );
  fetch c2 into tot_score2;
  close c2;

  open c3( health_check_id, dt );
  fetch c3 into tot_score3;
  close c3;

  -- Now work out what the total possible score was (NULL responses are to be ignored)
  site_score := nvl(site_score,0);
  tot_score2 := nvl(tot_score2,0);
  tot_score3 := nvl(tot_score3,0);
  if (grp is not null) and ((tot_score2 + tot_score3) = 0) then return ( 100 ); end if;
  if (site_score = 0) or (tot_score2 + tot_score3 = 0) then return( 0 ); end if;
  return( nvl(round( (site_score / (tot_score2 + tot_score3)) * 100, 2),0));
 exception
  when others
   then
    return( 0 );
 end calculate_health_score_perc;

 function calculate_health_complexity( health_check_id in integer, error_message out varchar2, complexity_variation in varchar2 default admin.DEFAULT_VARIATION_COMPLEXITY  )
   return integer
 as
  cursor c1 is select distinct sc.parameter_code, hp.response_type from site_complexity sc, health_parameters hp where hp.parameter_code=sc.parameter_code and sc.variation = complexity_variation;
  cursor c2( pcode varchar2) is select weighting ,log_base from site_complexity where parameter_code = pcode and variation = complexity_variation;
  cursor c3( hparm integer, pcode varchar2 ) is select result_number, result_text from health_result where parameter_code=pcode and health_check_id=hparm;
  cursor c4( pcode varchar2, val varchar2) is select weighting from site_complexity where parameter_code = pcode and value=val and variation = complexity_variation;

  c2rec			c2%ROWTYPE;
  c3rec			c3%ROWTYPE;
  c4rec			c4%ROWTYPE;
  total_complexity 	number := 0;

 begin
  error_message := NULL;
  for c1rec in c1 loop
   open c3(health_check_id,c1rec.parameter_code);
   fetch c3 into c3rec;
   if c3%NOTFOUND
    then
     close c3;
   else
     close c3;
     if c1rec.response_type in ('LOV','TEXT')
      then
       open c4( c1rec.parameter_code, c3rec.result_text );
       fetch c4 into c4rec;
       close c4;
       total_complexity := total_complexity + nvl(c4rec.weighting,0);
      else
       open c2( c1rec.parameter_code );
       fetch c2 into c2rec;
       close c2;
       total_complexity := total_complexity + (log(nvl(c2rec.log_base,10),nvl(c3rec.result_number,1)) * c2rec.weighting);
     end if;
   end if;
  end loop;
  return( total_complexity );
 exception
  when others
   then
    error_message := sqlerrm;
    begin close c2; exception when others then null; end;
    begin close c3; exception when others then null; end;
    begin close c4; exception when others then null; end;
    return( total_complexity );
 end calculate_health_complexity;

 procedure ins_report( txt in varchar2, ctr in out integer, markup in boolean, mup in varchar2 default null, v2 in varchar2 default null )
 as
  instxt varchar2(4000);
 begin
  if (mup is null or not markup) then  if v2 is null then instxt := txt; else instxt := txt || ' ' || v2; end if;
  elsif mup = 'NL' then instxt := htf.nl;
  elsif mup = 'H2' then instxt := htf.header(2, txt, 'CENTER' );
  elsif mup = 'H3' then instxt := htf.header(3, txt, 'CENTER' );
  elsif mup = 'BOLD' then instxt := htf.bold( txt );
  elsif mup = 'ITALIC' then instxt := htf.italic( txt );
  elsif mup = 'BOLD ITALIC' then instxt := htf.bold( htf.italic( txt ) );
  elsif mup = 'TO' then instxt := htf.tableopen;
  elsif mup = 'TC' then instxt := htf.tableclose;
  elsif mup = 'TR' then instxt := htf.tablerowopen || htf.tabledata( txt ) || htf.tablerowclose;
  elsif mup = 'TRB' then instxt := htf.tablerowopen || htf.tabledata( htf.bold(txt) ) || htf.tablerowclose;
  elsif mup = 'TRI' then instxt := htf.tablerowopen || htf.tabledata( htf.italic(txt) ) || htf.tablerowclose;
  elsif mup = 'TR2' then instxt := htf.tablerowopen || htf.tabledata( txt ) || htf.tabledata( v2 ) || htf.tablerowclose;
  elsif mup = 'TR2B' then instxt := htf.tablerowopen || htf.tabledata( htf.bold(txt) ) || htf.tabledata( v2 ) || htf.tablerowclose;
  elsif mup = 'TR2RB' then instxt := htf.tablerowopen || htf.tabledata( txt ) || htf.tabledata( htf.bold(v2) ) || htf.tablerowclose;
  elsif mup = 'TR2I' then instxt := htf.tablerowopen || htf.tabledata( htf.italic(txt) ) || htf.tabledata( v2 ) || htf.tablerowclose;
  elsif mup = 'SPC1' then instxt := htf.tablerowopen || htf.tabledata( htf.bold(txt) ) || htf.tabledata( htf.fontopen( csize=>'-1') || htf.italic(v2) || htf.fontclose ) || htf.tablerowclose;
  end if;
  insert into health_report_output(order_id, report_text) values (ctr, instxt);
  ctr := ctr + 1;
 end ins_report;

 procedure health_report( pHealth_check_id in integer,markup in boolean default FALSE, include_summary in boolean default TRUE, include_all in boolean default TRUE, include_exception in boolean default TRUE,
                          include_score_by_group in boolean default TRUE, include_total_score in boolean default TRUE, include_grade in boolean default TRUE, include_complexity in boolean default TRUE )
 as
  ctr	integer;

  cursor c1 is select * from health_check where health_check_id = pHealth_check_id;

  cursor c2 is select * from health_group order by order_by;

  cursor c3(pcode varchar2 ) is
    select short_description,response_type,score_result,result_number || result_fuzzy_boolean || result_text result,extra_note,hr.parameter_code
    from health_parameters hp, health_result hr
    where hp.parameter_code = hr.parameter_code and
          substr(hr.parameter_code,1,2) = pcode and
          hr.health_check_id = pHealth_check_id
    order by to_number(substr(hr.parameter_code,3,2));

  cursor c4 is
    select short_description,score_result,result_fuzzy_boolean result,extra_note,hr.parameter_code,expected_response
    from health_parameters hp, health_result hr
    where hp.parameter_code = hr.parameter_code and
          hp.response_type = 'BOOLEAN' and
          hr.health_check_id = pHealth_check_id and
          ((hp.expected_response <> hr.result_fuzzy_boolean) or (hr.result_fuzzy_boolean is null)) and
          hr.result_fuzzy_boolean <> 'Not Relevant'
    order by substr(hr.parameter_code,1,2), to_number(substr(hr.parameter_code,3,2));

  cursor c5 is
    select short_description,score_result,to_char(result_number) result,extra_note,hr.parameter_code,expected_value
    from health_parameters hp, health_result hr, score sc
    where hp.parameter_code = hr.parameter_code and
          sc.parameter_code = hr.parameter_code and
          hp.response_type = 'SCORE' and
          hr.health_check_id = pHealth_check_id and
          sc.expected_value = 'Y' and
          ((hr.result_number not between sc.loval and sc.highval) or (hr.result_number is null))
    order by substr(hr.parameter_code,1,2), to_number(substr(hr.parameter_code,3,2));

  cursor c6 is
   select group_name from health_group order by order_by;

  c1rec		c1%ROWTYPE;
  retvar	varchar2(2000);
  tscore	number;
 begin
  commit; -- Will empty the contents of the Health_Report_Output Table
  ctr := 1;
  open c1;
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
    close c1;
    ins_report( LNG3.ADM_TXT_365 || ': ' || pHealth_check_id, ctr, markup );
    return;
  end if;
  close c1;

  if include_summary
   then
    ins_report( LNG3.ADM_TXT_328, ctr, markup, 'H2' );
    ins_report( LNG3.ADM_TXT_329 || ': ' || to_char( sysdate, 'DD Month YYYY HH24:MI:SS'), ctr, markup );
    ins_report( null, ctr, markup, 'TO' );
    ins_report( LNG3.ADM_TXT_312 || ':', ctr, markup, 'TR2B', c1rec.organisation );
    ins_report( LNG3.ADM_TXT_331 || ':', ctr, markup, 'TR2B', c1rec.person_performing_check);
    ins_report( LNG3.ADM_TXT_333 || ':', ctr, markup, 'TR2B', c1rec.database_name);
    ins_report( LNG3.ADM_TXT_334 || ':', ctr, markup, 'TR2B', to_char( c1rec.date_check_performed, 'DD Month YYYY'));
    ins_report( LNG3.ADM_TXT_336 || ':', ctr, markup, 'TR2B', c1rec.notes_before);
    ins_report( LNG3.ADM_TXT_361 || ':', ctr, markup, 'TR2B', c1rec.notes_after);
    ins_report( '', ctr, markup, 'TC' );
  end if;

  if include_all
   then
    ins_report( LNG3.ADM_TXT_362, ctr, markup, 'BOLD' );
    ins_report( null, ctr, markup, 'TO' );
    for c2rec in c2 loop
     for c3rec in c3(c2rec.code) loop
      ins_report( c3rec.parameter_code, ctr, markup, 'SPC1', c3rec.short_description  );
      ins_report( '[' || c3rec.score_result || '] ', ctr, markup, 'TR2RB', c3rec.result  );
     end loop;
     ins_report( null, ctr, markup );
   end loop;
   ins_report( null, ctr, markup, 'TC' );
  end if;

  if include_exception
   then
    ins_report( LNG3.ADM_TXT_380, ctr, markup, 'BOLD'  );
    ins_report( null, ctr, markup, 'TO' );
    ins_report( LNG3.ADM_TXT_611, ctr, markup, 'ITALIC' );
     for c4rec in c4 loop
      ins_report( c4rec.parameter_code , ctr, markup, 'SPC1',c4rec.short_description);
      ins_report( '[' || c4rec.score_result || '] ', ctr, markup, 'TR2RB', c4rec.expected_response || ' - ' || c4rec.result  );
     end loop;
    ins_report( null, ctr, markup, 'TC' );
    ins_report( null, ctr, markup, 'TO' );
    ins_report( LNG3.ADM_TXT_323, ctr, markup, 'ITALIC' );
     for c5rec in c5 loop
      ins_report( c5rec.parameter_code, ctr, markup, 'SPC1', c5rec.short_description );
      ins_report( '[' || c5rec.score_result || '] ', ctr, markup, 'TR2RB', c5rec.expected_value || ' - ' || c5rec.result );
     end loop;
     ins_report( null, ctr, markup, 'TC' );
  end if;

  if include_score_by_group
   then
    ins_report( 'Score by Group', ctr, markup, 'BOLD'  );
    ins_report( null, ctr, markup, 'TO' );
    for c6rec in c6 loop
     retvar := NULL;
     tscore := calculate_health_score_perc( pHealth_Check_Id, retvar, c6rec.group_name );
     if retvar is null then ins_report( c6rec.group_name, ctr, markup, 'TR2RB', tscore || '%'  ); else ins_report( retvar, ctr, markup ); end if;
    end loop;
    ins_report( null, ctr, markup, 'TC' );
  end if;

  if include_total_score
   then
    retvar := NULL;
    tscore := calculate_health_score_perc( pHealth_Check_Id, retvar );
    ins_report( null, ctr, markup, 'TO' );
    if retvar is null then ins_report( LNG3.ADM_TXT_381 || ' : %', ctr, markup, 'TR2RB', tscore  ); else ins_report( retvar, ctr, markup ); end if;
    ins_report( null, ctr, markup, 'TC' );
  end if;

  if include_grade
   then
    retvar := NULL;
    tscore := calculate_health_score_perc( pHealth_Check_Id, retvar );
    ins_report( null, ctr, markup, 'TO' );
    ins_report( LNG3.ADM_TXT_382 || ' :', ctr, markup, 'TR2RB', grade_site( tscore, retvar, 'UNIVERSITY' ) );
    if retvar is not null then ins_report( retvar, ctr, markup ); end if;
    retvar := NULL;
    ins_report( LNG3.ADM_TXT_394 || ' :', ctr, markup, 'TR2RB', grade_site( tscore, retvar, 'SCHOOL' ));
    if retvar is not null then ins_report( retvar, ctr, markup ); end if;
    ins_report( null, ctr, markup, 'TC' );
  end if;

  if include_complexity
   then
    retvar := NULL;
    ins_report( null, ctr, markup, 'TO' );
    ins_report( LNG3.ADM_TXT_397 || ' :', ctr, markup, 'TR2RB', to_char( calculate_health_complexity( pHealth_Check_Id, retvar ) ));
    if retvar is not null then ins_report( retvar, ctr, markup ); end if;
    ins_report( null, ctr, markup, 'TC' );
  end if;


 -- Don't handle errors. Let the calling program handle them.
 exception
  when others then htp.p( 'CTR:' || ctr );
 end health_report;

 procedure compare_health_checks( pHealth_check_id_a in integer, pHealth_check_id_b in integer, markup in boolean default FALSE)
 as
  cursor c1 is
   select cr.result_number_a || cr.result_fuzzy_boolean_a || cr.result_text_a result_a, cr.result_number_b || cr.result_fuzzy_boolean_b || cr.result_text_b result_b,
          cr.parameter_code, hp.short_description, cr.result_score_a, cr.result_score_b, cr.extra_note_a, cr.extra_note_b
   from compare_results cr, health_parameters hp
   where cr.parameter_code = hp.parameter_code
   order by substr(cr.parameter_code,1,2), to_number(substr(cr.parameter_code,3,2));
  ctr		integer;
  retvar	varchar2(2000);
  tscore	number;
 begin
 delete from compare_results;
 insert into compare_results
  (parameter_code,health_check_id_a,result_score_a,result_number_a,result_fuzzy_boolean_a,result_text_a,extra_note_a,
   health_check_id_b,result_score_b,result_number_b,result_fuzzy_boolean_b,result_text_b,extra_note_b)
   select ha.parameter_code, pHealth_check_id_a,ha.score_result, ha.result_number, ha.result_fuzzy_boolean, ha.result_text resulta, ha.extra_note,
          pHealth_check_id_b, hb.score_result, hb.result_number, hb.result_fuzzy_boolean, hb.result_text resultb, hb.extra_note
   from health_result ha, health_result hb
   where ha.parameter_code = hb.parameter_code and
         ha.health_check_id = pHealth_check_id_a and
         hb.health_check_id = pHealth_check_id_b and
         nvl(ha.result_number || ha.result_fuzzy_boolean || ha.result_text,'~') <> nvl(hb.result_number || hb.result_fuzzy_boolean || hb.result_text,'~');
 commit;
 ctr := 1;
 ins_report( LNG3.ADM_TXT_329 || ': ' || to_char( sysdate, 'DD Month YYYY HH24:MI:SS'), ctr ,markup, 'ITALIC' );
 ins_report( null, ctr ,markup, 'TO' );
 ins_report( LNG3.ADM_TXT_410 || ' A:', ctr ,markup,'TR2B', pHealth_check_id_a );
 ins_report( LNG3.ADM_TXT_410 || ' B:', ctr ,markup,'TR2B', pHealth_check_id_b );
 ins_report( null, ctr ,markup, 'TC' );
 ins_report( LNG3.ADM_TXT_634 || ': ', ctr ,markup, 'H3' );
 ins_report( null, ctr ,markup, 'TO' );
 for c1rec in c1 loop
      ins_report( c1rec.parameter_code || '-' || '[A-' || c1rec.result_score_a || ' B-' || c1rec.result_score_b || ']', ctr ,markup, 'TR2RB',c1rec.short_description  );
      ins_report( 'A-' || c1rec.result_a, ctr ,markup, 'TR2',c1rec.extra_note_a  );
      ins_report( 'B-' || c1rec.result_b, ctr ,markup, 'TR2',c1rec.extra_note_b  );
 end loop;
 ins_report( null, ctr ,markup, 'TC' );

 retvar := NULL;
 tscore := calculate_health_score_perc( pHealth_Check_Id_a, retvar );
 ins_report( 'A: ' || LNG3.ADM_TXT_323 || ' : ' || tscore, ctr ,markup, 'BOLD' );
 ins_report( 'A: ' || LNG3.ADM_TXT_382 || ' : ' || grade_site( tscore, retvar, 'UNIVERSITY' ) , ctr ,markup, 'ITALIC' );
 if retvar is not null then ins_report( retvar, ctr ,markup ); end if;
 retvar := NULL;
 ins_report( 'A: ' || LNG3.ADM_TXT_394 || ' : ' || grade_site( tscore, retvar, 'SCHOOL' ) , ctr ,markup, 'ITALIC' );
 if retvar is not null then ins_report( retvar, ctr ,markup ); end if;
 ins_report( null, ctr ,markup );
 retvar := NULL;
 tscore := calculate_health_complexity( pHealth_Check_Id_a, retvar );
 ins_report( 'A: ' || LNG3.ADM_TXT_511 || ' : ' || tscore, ctr ,markup, 'BOLD' );
 if retvar is not null then ins_report( retvar, ctr ,markup ); end if;
 ins_report( null, ctr, markup, 'NL' );
 retvar := NULL;
 tscore := calculate_health_score_perc( pHealth_Check_Id_b, retvar );
 ins_report( 'B: ' || LNG3.ADM_TXT_323 || ' : ' || tscore, ctr ,markup, 'BOLD' );
 ins_report( 'B: ' || LNG3.ADM_TXT_382 || ' : ' || grade_site( tscore, retvar, 'UNIVERSITY' ) , ctr ,markup, 'ITALIC' );
 if retvar is not null then ins_report( retvar, ctr ,markup ); end if;
 retvar := NULL;
 ins_report( 'B: ' || LNG3.ADM_TXT_394 || ' : ' || grade_site( tscore, retvar, 'SCHOOL' ) , ctr ,markup, 'ITALIC' );
 if retvar is not null then ins_report( retvar, ctr ,markup ); end if;
 ins_report( null, ctr ,markup );
 retvar := NULL;
 tscore := calculate_health_complexity( pHealth_Check_Id_b, retvar );
 ins_report( 'B: ' || LNG3.ADM_TXT_511 || ' : ' || tscore, ctr ,markup, 'BOLD' );
 if retvar is not null then ins_report( retvar, ctr ,markup ); end if;

 -- Don't handle errors. Let the calling program handle them.
 end compare_health_checks;

 --
 -- Web Based Procedures and Functions
 --

 procedure web_main(surl varchar2)
 as
  cursor c1 is select * from health_check order by date_check_performed desc, database_name;
  sc		number;
  cp		number;
  errm		varchar2(2000);
  sessid	integer;
  sts		varchar2(200);
 begin
  glbx.adm_cookie_id(surl,sessid,sts);
  if sts is not null
   then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
  end if;

  htp.htmlopen;
  htp.p( BODY_BACKGROUND );
  htp.title( LNG3.ADM_TXT_539 );
  adm.main_title( surl,sessid, LNG3.ADM_TXT_539 );
  htp.tableopen(cattributes=>'width="600" cellpadding=1 cellspacing=1 border=0 ' || glbx.TABLE_BACKGROUND );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG3.ADM_TXT_312 ),cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_313 ),cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_321 ),cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( htf.bold( LNG.ORD_TXT_188 ),cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_323 ),cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_511 ),cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_540 ),cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_540 ),cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_553 ),cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_413 ),cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_423 ),cattributes=>glbx.QUERY_BACKGROUND );
   htp.tablerowclose;
  for c1rec in c1 loop
   htp.tablerowopen;
    htp.tabledata( htf.anchor('admin.edit_header?surl=' || glbx.rndsurl(surl) || '&hid=' || c1rec.health_check_id,htf.bold(c1rec.organisation)),cattributes=>glbx.QUERY_CELL_BACKGROUND );
    htp.tabledata( c1rec.person_performing_check,cattributes=>glbx.QUERY_CELL_BACKGROUND );
    htp.tabledata( htf.italic(c1rec.database_name),cattributes=>glbx.QUERY_CELL_BACKGROUND );
    htp.tabledata( htf.italic(to_char(c1rec.date_check_performed,LNG.MASK)),cattributes=>glbx.QUERY_CELL_BACKGROUND );
    errm := NULL;
    sc := calculate_health_score_perc( c1rec.health_check_id, errm );
    htp.tabledata( nvl(errm,to_char(sc)) || '[' || grade_site(sc,errm) || ']',cattributes=>glbx.QUERY_CELL_BACKGROUND );
    errm := NULL;
    cp := calculate_health_complexity( c1rec.health_check_id, errm );
    htp.tabledata( nvl(errm,to_char(cp)),cattributes=>glbx.QUERY_CELL_BACKGROUND );
     htp.formopen( 'admin.edit_by_group' );
     htp.formhidden( 'HID', c1rec.health_check_id );
     htp.formhidden( 'SURL', glbx.rndsurl(surl));
     htp.tabledata( htf.formsubmit(null,LNG.GLB_TXT_125),cattributes=>glbx.QUERY_CELL_BACKGROUND );
     htp.formclose;
     htp.formopen( 'admin.edit_by_question' );
     htp.formhidden( 'SURL', glbx.rndsurl(surl));
     htp.formhidden( 'HID', c1rec.health_check_id );
     htp.tabledata( htf.formsubmit(null,LNG3.ADM_TXT_428),cattributes=>glbx.QUERY_CELL_BACKGROUND );
     htp.formclose;
     htp.formopen( 'admin.web_report' );
     htp.formhidden( 'SURL', glbx.rndsurl(surl));
     htp.formhidden( 'HID', c1rec.health_check_id );
     htp.tabledata( htf.formsubmit(null,LNG3.ADM_TXT_553),cattributes=>glbx.QUERY_CELL_BACKGROUND );
     htp.formclose;
     htp.formopen( 'admin.reset_check' );
     htp.formhidden( 'SURL', glbx.rndsurl(surl));
     htp.formhidden( 'HID', c1rec.health_check_id );
     htp.tabledata( htf.formsubmit(null,LNG3.ADM_TXT_413),cattributes=>glbx.QUERY_CELL_BACKGROUND );
     htp.formclose;
     htp.formopen( 'admin.confirm_delete' );
     htp.formhidden( 'SURL', glbx.rndsurl(surl));
     htp.formhidden( 'HID', c1rec.health_check_id );
     htp.tabledata( htf.formsubmit(null,'Delete'),cattributes=>glbx.QUERY_CELL_BACKGROUND );
     htp.formclose;
   htp.tablerowclose;
  end loop;
  htp.tableclose;
  htp.line;
  htp.nl;
  htp.bold( LNG3.ADM_TXT_626 ); htp.nl;
  htp.formopen( 'admin.compare_two' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.p( htf.bold( LNG3.ADM_TXT_627 || ' 1: ') || lov_health( 'P1', null )); htp.nl;
   htp.p( htf.bold( LNG3.ADM_TXT_627 || ' 2: ') || lov_health( 'P2', null )); htp.nl;
   htp.formsubmit( null, LNG3.ADM_TXT_628 );
  htp.formclose;
  htp.nl;
  htp.line;
  htp.nl;
  htp.bold( LNG3.ADM_TXT_629 ); htp.nl;
  htp.formopen( 'admin.accept_new_check' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.tableopen( cattributes=>'width="600" cellpadding=0 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG3.ADM_TXT_312 ),cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( htf.formtext( 'P1', 40, 40 ),cattributes=>glbx.QUERY_CELL_BACKGROUND );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG3. ADM_TXT_605),cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( htf.formtext( 'P2', 40, 100 ),cattributes=>glbx.QUERY_CELL_BACKGROUND );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.italic( LNG3.ADM_TXT_333 ),cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( htf.formtext( 'P3', 20, 20 ),cattributes=>glbx.QUERY_CELL_BACKGROUND );
   htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.bold( LNG3.ADM_TXT_606 ),cattributes=>glbx.QUERY_BACKGROUND );
      htp.tabledata( lov_html( 'LANGUAGE', 'P4', 'ENGLISH'),cattributes=>glbx.QUERY_CELL_BACKGROUND );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.bold( LNG3.ADM_TXT_607 ),cattributes=>glbx.QUERY_BACKGROUND );
      htp.tabledata( lov_html( 'DATABASE VENDOR', 'P5', 'ORACLE'),cattributes=>glbx.QUERY_CELL_BACKGROUND );
    htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.italic( LNG3.ADM_TXT_334 ),cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( htf.formtext( 'P6', 40, 40 ) || htf.italic(' DD-MON-YYYY'),cattributes=>glbx.QUERY_CELL_BACKGROUND );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.italic( LNG3.ADM_TXT_630 ),cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( htf.formtextarea( 'P7', 3, 40 ),cattributes=>glbx.QUERY_CELL_BACKGROUND );
   htp.tablerowclose;
  htp.tableclose;
  htp.formsubmit( null, LNG3.ADM_TXT_396 );
  htp.formclose;
  htp.nl;
  htp.line;
  htp.italic( LNG3.ADM_TXT_370 || ': ' || htf.bold(VERSION) );
  htp.nl;
  htp.htmlclose;
 exception
  when others then htp.p( sqlerrm );
 end web_main;

 procedure edit_header( surl in varchar2, hid in integer )
 as
  cursor c1 is select * from health_check where health_check_id = hid;
  c1rec	c1%ROWTYPE;
  sessid	integer;
  sts		varchar2(200);
 begin
  glbx.adm_cookie_id(surl,sessid,sts);
  if sts is not null
   then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
  end if;
  open c1;
  fetch c1 into c1rec;
  close c1;
  htp.htmlopen;
  htp.p( BODY_BACKGROUND );
  htp.title( LNG3.ADM_TXT_604 );
  htp.header(2, LNG3.ADM_TXT_604, 'CENTER' );
  htp.formopen( 'admin.accept_header' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'HID', hid );
  htp.tableopen(cattributes=>'width="600" cellpadding=1 cellspacing=1 border=0 ' || glbx.TABLE_BACKGROUND );
    htp.tablerowopen;
      htp.tabledata( htf.bold( LNG3.ADM_TXT_312 ),cattributes=>glbx.QUERY_BACKGROUND );
      htp.tabledata( htf.formtext( 'P1', 40, 40, c1rec.organisation ));
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.bold( LNG3.ADM_TXT_605 ),cattributes=>glbx.QUERY_BACKGROUND );
      htp.tabledata( htf.formtext( 'P2', 40, 100, c1rec.person_performing_check ));
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.bold( LNG3.ADM_TXT_333 ),cattributes=>glbx.QUERY_BACKGROUND );
      htp.tabledata( htf.formtext( 'P3', 20, 20, c1rec.database_name ));
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.bold( LNG3.ADM_TXT_334 ),cattributes=>glbx.QUERY_BACKGROUND );
      htp.tabledata( htf.formtext( 'P4', 20, 50, to_char(c1rec.date_check_performed, LNG.MASK) ) || ' ' || LNG.MASK);
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.bold( LNG3.ADM_TXT_606 ),cattributes=>glbx.QUERY_BACKGROUND );
      htp.tabledata( lov_html( 'LANGUAGE', 'P5', c1rec.language));
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.bold( LNG3.ADM_TXT_607 ),cattributes=>glbx.QUERY_BACKGROUND );
      htp.tabledata( lov_html( 'DATABASE VENDOR', 'P6', c1rec.database_vendor));
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.bold( LNG3.ADM_TXT_336 ),cattributes=>glbx.QUERY_BACKGROUND );
      htp.tabledata( htf.formtextareaopen( 'P7', 3, 40 ) || c1rec.notes_before || htf.formtextareaclose);
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.bold( LNG3.ADM_TXT_361 ),cattributes=>glbx.QUERY_BACKGROUND );
      htp.tabledata( htf.formtextareaopen( 'P8', 3, 40 ) || c1rec.notes_after || htf.formtextareaclose);
    htp.tablerowclose;
  htp.tableclose;
  htp.formsubmit( null, LNG3.ADM_TXT_608 );
  htp.formclose;
  htp.htmlclose;
 exception
  when others then htp.p( sqlerrm );
 end edit_header;

 procedure accept_header( surl in varchar2, hid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2, p8 in varchar2)
 as
  tdate		date;
  errmsg	varchar2(2000);
 begin
  begin
   tdate := to_date(p4, LNG.MASK );
  exception
   when others then htp.p( LNG3.ADM_TXT_633 || ': ' || p4 || ' ' || LNG3.ADM_TXT_632 || ': ' || LNG.MASK ); htp.nl; htp.nl;
                    htp.p( LNG3.ADM_TXT_631);
                    return;
  end;
  update_health_check( errmsg, hid, p1, p2, tdate, p3, p5, p6, p7, p8 );
  if errmsg is not null then htp.p (errmsg ); htp.nl; htp.nl;htp.p( LNG3.ADM_TXT_631); return; end if;
  web_main(surl);
 exception
  when others then htp.p( sqlerrm );
 end accept_header;

 procedure accept_new_check( surl in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2 )
 as
  error_message varchar2(2000);
  sts		integer;
 begin
   sts := create_health_check( error_message, p1, p2, p6, p3, p7, p4, p5 );
   if error_message is null
    then
     edit_by_question( surl,sts );
    else
     htp.bold( error_message );
   end if;
 exception
  when others then htp.p( sqlerrm );
 end accept_new_check;

 procedure edit_by_question( surl in varchar2, hid in integer )
 as
  sessid	integer;
  sts		varchar2(200);
 begin
  glbx.adm_cookie_id(surl,sessid,sts);
  if sts is not null
   then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
  end if;
  htp.title( LNG3.ADM_TXT_565 );
  htp.framesetopen('100%','30%,70%');
   htp.frame( 'admin.display_questions?surl=' || glbx.rndsurl(surl) || '&hid=' || hid,'LEFT');
   htp.frame( 'admin.instructions?surl=' || glbx.rndsurl(surl) || '&typ=Q','RIGHT');
  htp.framesetclose;
  htp.noframesopen;
   glbx.noframe(surl,'ADMIN.EDIT_BY_QUESTION');
  htp.noframesclose;
 exception
  when others then htp.p( sqlerrm );
 end edit_by_question;

 procedure edit_by_group( surl in varchar2, hid in integer )
 as
  sessid	integer;
  sts		varchar2(200);
 begin
  glbx.adm_cookie_id(surl,sessid,sts);
  if sts is not null
   then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
  end if;
  htp.title( LNG3.ADM_TXT_609 );
  htp.framesetopen('100%','20%,80%');
   htp.frame( 'admin.display_groups?surl=' || glbx.rndsurl(surl) || '&hid=' || hid,'LEFT');
   htp.frame( 'admin.instructions?surl=' || glbx.rndsurl(surl) || '&typ=G','RIGHT');
  htp.framesetclose;
  htp.noframesopen;
   glbx.noframe(surl,'ADMIN.EDIT_BY_GROUP');
  htp.noframesclose;
 exception
  when others then htp.p( sqlerrm );
 end edit_by_group;

 function get_db_type( hid in integer )
  return varchar2
 as
   cursor c1 is
    select result_text from health_result where parameter_code = 'ED02' and health_check_id = hid;
   c1rec	c1%ROWTYPE;
 begin
  open c1;
  fetch c1 into c1rec;
  close c1;
  if c1rec.result_text is null then return( 'In House and 3rd Party' ); end if;
  return( c1rec.result_text );
 end get_db_type;

 procedure display_questions( surl in varchar2, hid in integer, pcode in varchar2 default null, msg in varchar2 default null )
 as
  cursor c1(dt varchar2) is
   select hr.parameter_code,hp.short_description, result_number || result_fuzzy_boolean || result_text answered,hp.group_topic
   from health_result hr,health_parameters hp, health_group hg
   where hr.parameter_code = hp.parameter_code and
         hg.group_name = hp.group_topic and
           ( (database_type = dt) or (database_type='In House and 3rd Party') or (dt='In House and 3rd Party') ) and
         hr.health_check_id = hid
   order by hg.order_by, to_number(substr(hp.parameter_code,3,2));
   last_group	health_parameters.group_topic%TYPE;
  sessid	integer;
  sts		varchar2(200);
 begin
  glbx.adm_cookie_id(surl,sessid,sts);
  if sts is not null
   then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
  end if;
  htp.htmlopen;
  htp.p( BODY_BACKGROUND );
  htp.header(2, LNG3.ADM_TXT_565 || ' ' || htf.anchor2( 'admin.web_main?surl=' || glbx.rndsurl(surl),htf.fontopen(csize=>-2) || '[' || LNG.LAB_TXT_002 || ']' || htf.fontclose,ctarget=>'BOTTOM'), 'CENTER' );
  if msg is not null then htp.header(3, msg, 'CENTER' ); end if;
  last_group := NULL;
  htp.tableopen;
  for c1rec in c1( get_db_type( hid )) loop
   if (last_group is null) or (last_group <> c1rec.group_topic )
    then
     if substr(pcode,1,2) = substr(c1rec.parameter_code,1,2)
      then
       htp.tableclose;
       htp.p( '<A NAME="STRT"></A>' );
       htp.tableopen;
     end if;
     htp.tablerowopen;
     htp.tabledata( null );
     htp.tabledata(htf.bold( c1rec.group_topic ));
    htp.tablerowclose;
   end if;
   last_group := c1rec.group_topic;
   htp.tablerowopen;
   if c1rec.answered is null
    then
      htp.tabledata( htf.anchor2('admin.edit_question?surl=' || glbx.rndsurl(surl) || '&pcode=' || c1rec.parameter_code || '&hid=' || hid, QUESTION_NOT_DONE, ctarget=>'RIGHT') );
    else
     htp.tabledata( htf.anchor2('admin.edit_question?surl=' || glbx.rndsurl(surl) || '&pcode=' || c1rec.parameter_code || '&hid=' || hid, QUESTION_DONE, ctarget=>'RIGHT') );
   end if;
   htp.tabledata( htf.fontopen( csize=>'-2') || c1rec.short_description || htf.fontclose );
   htp.tablerowclose;
  end loop;
  htp.tableclose;
  htp.htmlclose;
 exception
  when others then htp.p( sqlerrm );
 end display_questions;

 procedure display_groups( surl in varchar2, hid in integer, msg in varchar2 default null )
 as
  cursor c1 is
   select group_name,code
   from health_group
   order by order_by;
  sessid	integer;
  sts		varchar2(200);
 begin
  glbx.adm_cookie_id(surl,sessid,sts);
  if sts is not null
   then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
  end if;
  htp.htmlopen;
  htp.p( BODY_BACKGROUND );
  htp.header(2, LNG3.ADM_TXT_609 || ' ' || htf.anchor2( 'admin.web_main?surl=' || glbx.rndsurl(surl),htf.fontopen(csize=>-2) || '[' || LNG.LAB_TXT_002 || ']' || htf.fontclose,ctarget=>'BOTTOM'), 'CENTER' );
  if msg is not null then htp.header(3, LNG3.ADM_TXT_610, 'CENTER' ); end if;
  htp.tableopen;
  for c1rec in c1 loop
    htp.tablerowopen;
     if (msg is not null) and (msg = c1rec.code)
      then
       htp.tabledata( INDICATE_GROUP );
       htp.tabledata( htf.anchor2('admin.edit_group?surl=' || glbx.rndsurl(surl) || '&pcode=' || c1rec.code || '&hid=' || hid, htf.fontopen( csize=>'-1') || c1rec.group_name || htf.fontclose , ctarget=>'RIGHT') );
      else
       htp.tabledata( null );
       htp.tabledata( htf.anchor2('admin.edit_group?surl=' || glbx.rndsurl(surl) || '&pcode=' || c1rec.code || '&hid=' || hid, htf.fontopen( csize=>'-1') || c1rec.group_name || htf.fontclose , ctarget=>'RIGHT') );
     end if;
    htp.tablerowclose;
  end loop;
  htp.tableclose;
  htp.htmlclose;
 exception
  when others then htp.p( sqlerrm );
 end display_groups;

 procedure edit_question( surl in varchar2, hid in integer, pcode in varchar2 )
 as
  cursor c1 is select * from health_parameters where parameter_code = pcode;
  cursor c2 is select * from health_result where parameter_code = pcode and health_check_id = hid;

  c1rec c1%ROWTYPE;
  c2rec c2%ROWTYPE;

  sessid	integer;
  sts		varchar2(200);
 begin
  glbx.adm_cookie_id(surl,sessid,sts);
  if sts is not null
   then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
  end if;
  open c1;
  fetch c1 into c1rec;
  close c1;
  open c2;
  fetch c2 into c2rec;
  close c2;
  htp.htmlopen;
  htp.p( BODY_BACKGROUND );
  htp.header(2, LNG3.ADM_TXT_565 || ': ' || pcode, 'CENTER' );
  htp.formopen( 'admin.accept_question#STRT', ctarget=>'LEFT' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'HID', hid );
  htp.formhidden( 'PCODE', pcode );
   htp.tableopen;
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNG3.ADM_TXT_428 || ': ' ));
     htp.tabledata( htf.bold( htf.fontopen(csize=>'+1') || c1rec.short_description || htf.fontclose ) );
    htp.tablerowclose;
   if c1rec.response_type = 'TEXT'
    then
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG.PHG_ALT_296 ) );
      htp.tabledata( htf.formtextareaopen( 'P1', 3, 40 ) || c2rec.result_text || htf.formtextareaclose);
     htp.tablerowclose;
   elsif c1rec.response_type in ('NUMBER','SCORE')
    then
     htp.tablerowopen;
      htp.tabledata( htf.bold(initcap( c1rec.response_type )) );
      htp.tabledata( htf.formtext( 'P1', 20, 40, c2rec.result_number ));
     htp.tablerowclose;
   elsif c1rec.response_type = 'BOOLEAN'
    then
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG3.ADM_TXT_611) );
      htp.tabledata( lov_html( 'FUZZY RESPONSE', 'P1', nvl(c2rec.result_fuzzy_boolean,c1rec.expected_response) ) );
     htp.tablerowclose;
   elsif c1rec.response_type = 'LOV'
    then
     htp.tablerowopen;
      htp.tabledata( htf.bold( initcap(LNG3.ADM_TXT_576) ) );
      htp.tabledata( lov_html( pcode, 'P1', c2rec.result_text ) );
     htp.tablerowclose;
   end if;
   htp.nl;
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNG3.ADM_TXT_105 || ': ' ));
     htp.tabledata( htf.formtextareaopen( 'P2', 3, 40 ) || c2rec.extra_note || htf.formtextareaclose );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNG3.ADM_TXT_105 || ': ' ));
     htp.tabledata( c1rec.help_description );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNG3.ADM_TXT_613 || ': ' ));
     htp.tabledata( c1rec.how_to_find_answer );
    htp.tablerowclose;
   htp.tableclose;
   htp.formsubmit( null, LNG3.ADM_TXT_562 );
  htp.formclose;
  htp.nl;
  htp.italic( LNG3.ADM_TXT_614 );
  htp.nl;
  htp.htmlclose;
 exception
  when others then htp.p( sqlerrm );
 end edit_question;

 procedure accept_question( surl in varchar2, hid in integer, pcode in varchar2, p1 in varchar2, p2 in varchar2 )
 as
  sqlerrm	varchar2(1000);
 begin
  sqlerrm := NULL;
  update_question( surl,hid, pcode, p1, p2, sqlerrm );
  if sqlerrm is not null
   then
    htp.htmlopen;
     htp.header( 3, LNG3.ADM_TXT_615, 'CENTER' );
     htp.bold( sqlerrm );
     htp.nl;
     htp.nl;
     htp.italic( LNG3.ADM_TXT_616 );
     htp.htmlclose;
     rollback;
     return;
  end if;
  commit;
  display_questions( surl, hid, pcode );
 exception
  when others then htp.p( sqlerrm );
 end accept_question;

 procedure update_question( surl in varchar2, hid in integer, pcode in varchar2, p1 in varchar2, p2 in varchar2, sqlerrm out varchar2 )
 as
  cursor c1 is select response_type from health_parameters where parameter_code = pcode;
  c1rec  c1%ROWTYPE;
  tnm	 number;
  enote	 varchar2(4000);
 begin
  open c1;
  fetch c1 into c1rec;
  close c1;
  enote := substr(p2, 1, 4000);
  if c1rec.response_type in ('NUMBER','SCORE')
   then
    begin
     tnm := to_number( p1 );
    exception
     when others then
      sqlerrm := htf.bold( LNG.PHG_TXT_210 || ': ' || p1 );
      return;
    end;
    update health_result set result_number = tnm, extra_note = enote where parameter_code = pcode and health_check_id = hid;
  elsif c1rec.response_type = 'BOOLEAN'
   then
    update health_result set result_fuzzy_boolean = p1, extra_note = enote where parameter_code = pcode and health_check_id = hid;
  else
    update health_result set result_text = p1, extra_note = enote where parameter_code = pcode and health_check_id = hid;
  end if;
 exception
  when others then htp.p( sqlerrm );
 end update_question;

 procedure web_report( surl in varchar2, hid in integer )
 as
  sessid	integer;
  sts		varchar2(200);
 begin
  glbx.adm_cookie_id(surl,sessid,sts);
  if sts is not null
   then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
  end if;
  htp.htmlopen;
  htp.p( BODY_BACKGROUND );
  htp.title( LNG3.ADM_TXT_617 );
  htp.header(2, LNG3.ADM_TXT_617, 'CENTER' );
  htp.header(3, LNG3.ADM_TXT_618, 'CENTER' );
  htp.formopen( 'admin.run_report' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.tableopen;
   htp.formhidden( 'HID', hid );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG3.ADM_TXT_619 ));
    htp.tabledata( htf.formcheckbox( 'Q1', 'T', 'CHECKED' ));
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG3.ADM_TXT_620 ));
    htp.tabledata( htf.formcheckbox( 'Q2', 'T', 'CHECKED' ));
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG3.ADM_TXT_621 ));
    htp.tabledata( htf.formcheckbox( 'Q3', 'T', 'CHECKED' ));
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG3.ADM_TXT_622 ));
    htp.tabledata( htf.formcheckbox( 'Q4', 'T', 'CHECKED' ));
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG3.ADM_TXT_381 ));
    htp.tabledata( htf.formcheckbox( 'Q5', 'T', 'CHECKED' ));
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG3.ADM_TXT_623 ));
    htp.tabledata( htf.formcheckbox( 'Q6', 'T', 'CHECKED' ));
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG3.ADM_TXT_511 ));
    htp.tabledata( htf.formcheckbox( 'Q7', 'T', 'CHECKED' ));
   htp.tablerowclose;
  htp.tableclose;
  htp.formsubmit( null, LNG3.ADM_TXT_624 );
  htp.formclose;
  htp.htmlclose;
 exception
   when others then htp.p( sqlerrm );
 end web_report;

 procedure run_report( surl in varchar2, hid in integer, q1 in varchar2 default 'F', q2 in varchar2 default 'F', q3 in varchar2 default 'F', q4 in varchar2 default 'F',
                       q5 in varchar2 default 'F', q6 in varchar2 default 'F', q7 in varchar2 default 'F' )
 as
  cursor c1 is select report_text from health_report_output order by order_id;

  b1	boolean := FALSE;
  b2	boolean := FALSE;
  b3	boolean := FALSE;
  b4	boolean := FALSE;
  b5	boolean := FALSE;
  b6	boolean := FALSE;
  b7	boolean := FALSE;

  sessid	integer;
  sts		varchar2(200);
 begin
  glbx.adm_cookie_id(surl,sessid,sts);
  if sts is not null
   then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
  end if;
  if q1 = 'T' then b1 := TRUE; end if;
  if q2 = 'T' then b2 := TRUE; end if;
  if q3 = 'T' then b3 := TRUE; end if;
  if q4 = 'T' then b4 := TRUE; end if;
  if q5 = 'T' then b5 := TRUE; end if;
  if q6 = 'T' then b6 := TRUE; end if;
  if q7 = 'T' then b7 := TRUE; end if;
  health_report( hid, TRUE, b1, b2, b3, b4, b5, b6, b7 );
  htp.htmlopen;
  htp.p( BODY_BACKGROUND );
  htp.title( LNG3.ADM_TXT_617 );
  htp.header(2, LNG3.ADM_TXT_617 || ' ' || htf.anchor2( 'admin.web_main?surl=' || glbx.rndsurl(surl),htf.fontopen(csize=>-2) || '[' || LNG.LAB_TXT_002 || ']' || htf.fontclose,ctarget=>'BOTTOM'), 'CENTER' );
   htp.tableopen;
    for c1rec in c1 loop
     htp.tablerowopen;
      htp.tabledata( c1rec.report_text );
     htp.tablerowclose;
    end loop;
   htp.tableclose;
  htp.htmlclose;
 exception
   when others then htp.p( sqlerrm );
 end run_report;

 procedure compare_two( surl in varchar2, p1 in varchar2, p2 in varchar2 )
 as
  cursor c1 is select report_text from health_report_output order by order_id;
  v1	integer;
  v2	integer;
  sessid	integer;
  sts		varchar2(200);
 begin
  glbx.adm_cookie_id(surl,sessid,sts);
  if sts is not null
   then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
  end if;
  v1 := to_number( substr( p1, 2, instr(p1,']')-2) );
  v2 := to_number( substr( p2, 2, instr(p2,']')-2) );
  compare_health_checks( v1, v2, TRUE );
  htp.htmlopen;
  htp.p( BODY_BACKGROUND );
  htp.title( LNG3.ADM_TXT_617 );
  htp.header(2, LNG3.ADM_TXT_625 || ' ' || htf.anchor2( 'admin.web_main?surl=' || glbx.rndsurl(surl),htf.fontopen(csize=>-2) || '[' || LNG.LAB_TXT_002 || ']' || htf.fontclose,ctarget=>'BOTTOM'), 'CENTER' );
   htp.tableopen;
    for c1rec in c1 loop
     htp.tablerowopen;
      htp.tabledata( c1rec.report_text );
     htp.tablerowclose;
    end loop;
   htp.tableclose;
  htp.htmlclose;
 exception
   when others then htp.p( sqlerrm );
 end compare_two;


 procedure edit_group( surl in varchar2, hid in integer, pcode in varchar2 )
  as
   cursor c1( dt varchar2 ) is
     select *
     from health_parameters
     where substr(parameter_code,1,2) = pcode and
           ( (database_type = dt) or (database_type='In House and 3rd Party') or (dt='In House and 3rd Party') )
     order by to_number(substr(parameter_code,3,2));
   cursor c2(pcode_id varchar2) is select * from health_result where parameter_code = pcode_id and health_check_id = hid;
   cursor c3 is select group_name from health_group where code = pcode;

   c2rec c2%ROWTYPE;
   c3rec c3%ROWTYPE;

  sessid	integer;
  sts		varchar2(200);
 begin
  glbx.adm_cookie_id(surl,sessid,sts);
  if sts is not null
   then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
  end if;
   open c3;
   fetch c3 into c3rec;
   close c3;
   htp.htmlopen;
   htp.p( BODY_BACKGROUND );
   htp.header(2, c3rec.group_name, 'CENTER' );
   htp.formopen( 'admin.accept_group', ctarget=>'LEFT' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formsubmit( null, LNG3.ADM_TXT_562 );
   htp.formhidden( 'HID', hid );
   htp.tableopen;
    htp.tablerowopen;
     htp.tableheader( LNG.PHG_TXT_479 );
     htp.tableheader( LNG3.ADM_TXT_561 );
     htp.tableheader( LNG3.ADM_TXT_473 );
     htp.tableheader( LNG3.ADM_TXT_428 );
    htp.tablerowclose;
   for c1rec in c1(get_db_type( hid )) loop
     open c2(c1rec.parameter_code);
     fetch c2 into c2rec;
     close c2;
     htp.formhidden( 'PCODE', c1rec.parameter_code );
     htp.tablerowopen;
      htp.tabledata( c1rec.parameter_code );
     if c1rec.response_type = 'TEXT'
      then
       htp.tabledata( htf.formtext( 'P1', 20, 4000, c2rec.result_text ));
    elsif c1rec.response_type in ('NUMBER','SCORE')
     then
       htp.tabledata( htf.formtext( 'P1', 20, 20, c2rec.result_number ));
    elsif c1rec.response_type = 'BOOLEAN'
     then
       htp.tabledata( lov_html( 'FUZZY RESPONSE', 'P1', nvl(c2rec.result_fuzzy_boolean,c1rec.expected_response) ) );
    elsif c1rec.response_type = 'LOV'
     then
       htp.tabledata( lov_html( c1rec.parameter_code, 'P1', c2rec.result_text ) );
    end if;
      htp.tabledata( htf.formtext( 'P2', 20, 4000, c2rec.extra_note ));
      htp.tabledata( htf.fontopen(csize=>'-1') || htf.italic(c1rec.short_description) || htf.fontclose );
    htp.tablerowclose;
    end loop;
    htp.tableclose;
    htp.formsubmit( null, LNG3.ADM_TXT_562 );
   htp.formclose;
   htp.nl;
   htp.italic( LNG3.ADM_TXT_614 );
   htp.nl;
   htp.htmlclose;
  exception
   when others then htp.p( sqlerrm );
  end edit_group;

 procedure accept_group( surl in varchar2, hid in integer, pcode in COLUMN_ARRAY, p1 in COLUMN_ARRAY, p2 in COLUMN_ARRAY )
 as
  sqlerrm	varchar2(1000);
  erred		boolean;
 begin
  sqlerrm := NULL;
  erred := FALSE;
  for j in pcode.first..pcode.last loop
   update_question( surl,hid, pcode(j), p1(j), p2(j), sqlerrm );
   if sqlerrm is not null
    then
      if not erred then htp.header( 3, LNG3.ADM_TXT_615, 'CENTER' ); end if;
      htp.bold( sqlerrm );
      htp.nl;
      erred := TRUE;
      sqlerrm := NULL;
   end if;
   end loop;
   if erred
    then
     rollback;
     return;
     htp.nl;
     htp.italic( 'Press the BACK Button and correct problem' );
     htp.htmlclose;
   end if;
   commit;
   display_groups( surl, hid, substr(pcode(1),1,2) );
  exception
   when others then htp.p( sqlerrm );
 end accept_group;

 procedure instructions( surl in varchar2, typ in varchar2 )
 as
  sessid	integer;
  sts		varchar2(200);
 begin
  glbx.adm_cookie_id(surl,sessid,sts);
  if sts is not null
   then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
  end if;
  htp.htmlopen;
  htp.p( BODY_BACKGROUND );
  htp.title( LNG3.ADM_TXT_565 );
  htp.header(2, LNG3.ADM_TXT_566, 'CENTER' );
  if typ = 'Q'
   then
    htp.italic( LNG3.ADM_TXT_563 );
  elsif typ = 'G'
   then
    htp.italic( LNG3.ADM_TXT_564 );
  end if;
  htp.htmlclose;
 exception
  when others then htp.p( sqlerrm );
 end instructions;

 function lov_html( ltype in varchar2, pname in varchar2, selected_value in varchar2 )
  return varchar2
 as
  cursor c1( ltype varchar2 ) is
   select lov_value from lov where lov_type = ltype;

  retval	varchar2(32767);
 begin
  retval := htf.formselectopen( pname );
  for c1rec in c1( ltype ) loop
   if c1rec.lov_value = selected_value
    then
     retval := retval || htf.formselectoption( c1rec.lov_value, 'SELECTED' );
    else
     retval := retval || htf.formselectoption( c1rec.lov_value );
   end if;
  end loop;
  retval := retval || htf.formselectclose;
  return( retval );
 -- Don't handle errors. Let the calling program handle them.
 end lov_html;

 function lov_health( pname in varchar2, selected_value in number )
   return varchar2
  as
   cursor c1 is select '[' || health_check_id || '] ' || to_char(date_check_performed,LNG.MASK) || '-' || person_performing_check vl,
                health_check_id from health_check order by date_check_performed desc, database_name;

   retval	varchar2(32767);
  begin
   retval := htf.formselectopen( pname );
   for c1rec in c1 loop
    if c1rec.health_check_id = selected_value
     then
      retval := retval || htf.formselectoption( c1rec.vl, 'SELECTED' );
     else
      retval := retval || htf.formselectoption( c1rec.vl );
    end if;
   end loop;
   retval := retval || htf.formselectclose;
   return( retval );
  -- Don't handle errors. Let the calling program handle them.
  end lov_health;

 procedure confirm_delete( surl in varchar2, hid in integer )
 as
  cursor c1 is select * from health_check where health_check_id = hid;
  sc		number;
  cp		number;
  errm		varchar2(2000);
  sessid	integer;
  sts		varchar2(200);
 begin
  glbx.adm_cookie_id(surl,sessid,sts);
  if sts is not null
   then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
  end if;
  htp.htmlopen;
  htp.p( BODY_BACKGROUND );
  htp.title( LNG3.ADM_TXT_285 );
  htp.header(2, LNG3.ADM_TXT_293, 'CENTER' );
  htp.tableopen(cattributes=>'width="600" cellpadding=1 cellspacing=1 border=0 ' || glbx.TABLE_BACKGROUND );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG3.ADM_TXT_312 ),cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_313 ),cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_321 ),cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( htf.bold( LNG.ORD_TXT_188),cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_323 ),cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_511 ),cattributes=>glbx.QUERY_BACKGROUND );
   htp.tablerowclose;
  for c1rec in c1 loop
   htp.tablerowopen;
    htp.tabledata( htf.bold(c1rec.organisation),cattributes=>glbx.QUERY_CELL_BACKGROUND );
    htp.tabledata( c1rec.person_performing_check,cattributes=>glbx.QUERY_CELL_BACKGROUND );
    htp.tabledata( htf.italic(c1rec.database_name),cattributes=>glbx.QUERY_CELL_BACKGROUND );
    htp.tabledata( htf.italic(to_char(c1rec.date_check_performed,LNG.MASK)),cattributes=>glbx.QUERY_CELL_BACKGROUND );
    errm := NULL;
    sc := calculate_health_score_perc( c1rec.health_check_id, errm );
    htp.tabledata( nvl(errm,to_char(sc)) || '[' || grade_site(sc,errm) || ']',cattributes=>glbx.QUERY_CELL_BACKGROUND );
    errm := NULL;
    cp := calculate_health_complexity( c1rec.health_check_id, errm );
    htp.tabledata( nvl(errm,to_char(cp)),cattributes=>glbx.QUERY_CELL_BACKGROUND );
   htp.tablerowclose;
  end loop;
  htp.tableclose;
  htp.nl;
  htp.formopen( 'admin.delete_health_check' );
   htp.formhidden( 'HID', hid );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formsubmit( null, LNG3.ADM_TXT_274);
  htp.formclose;
  htp.htmlclose;
exception
 when others then htp.p( sqlerrm );
end confirm_delete;

procedure delete_health_check( surl in varchar2, hid in integer )
as
 errmsg varchar2(1000);
begin
 drop_health_check(errmsg, hid);
 if errmsg is not null then htp.p( errmsg ); end if;
 web_main(surl);
exception
 when others then htp.p( sqlerrm );
end delete_health_check;

procedure reset_check( surl in varchar2, hid in integer )
as
 errmsg varchar2(1000);
begin
 reset_health_check(errmsg, hid);
 if errmsg is not null then htp.p( errmsg ); end if;
 web_main(surl);
exception
 when others then htp.p( sqlerrm );
end reset_check;

procedure main_title( ttl in varchar2, other_elements in varchar2 default null, style in varchar2 default 'BIG' )
as
begin
 htp.htmlopen;
 htp.print('<BODY BGCOLOR="#FFFFFF">');
 if style = 'BIG'
  then
   htp.tableopen( cattributes=>'width="100%" cellpadding=2 cellspacing=0 border=0 ' || glbx.TABLE_BACKGROUND );
    htp.tablerowopen;
     htp.tabledata('<b><font size="+1" color="#ffffff">' || ttl || '</font></b>',cattributes=>glbx.TITLE_BACKGROUND || 'valign="TOP"');
     if other_elements is not null
      then
	   htp.p( other_elements );
     end if;
    htp.tablerowclose;
   htp.tableclose;
 elsif style = 'SIMPLE'
  then
   htp.bold( ttl );
   htp.nl;
 end if;
end main_title;

procedure alert_log_report( check_from in number default 1 )
 as

  file_handler	UTL_FILE.FILE_TYPE;
  output_buffer	exception_report.txt%TYPE;
  vname		V$DATABASE.NAME%TYPE;
  tdate		date;
  found_min_dt	boolean;
  tmp		varchar2(1000);
  gcode		GLBX.MYARRAY;
  gparam	GLBX.MYARRAY;
  vdir		varchar2(1000);

 begin
  delete from exception_report;
  select name into vname from v$database where rownum < 2;

  -- Add some smarts for ALERT_LOG_DIRECTORY
  vdir := glbx.extract_master_parameter('ALERT_LOG_DIRECTORY');
  if instr(upper(vdir),'BDUMP') > 0
   then
    if substr(vdir,length(vdir),1) = DECS.UNIX_OR_NT
     then
      vdir := substr(vdir,1,length(vdir)-1);
    end if;
  elsif instr(upper(vdir),upper(vname)) > 0
   then
    if substr(vdir,length(vdir),1) = DECS.UNIX_OR_NT
     then
      vdir := substr(vdir,1,length(vdir)-1);
    end if;
    vdir := vdir || DECS.UNIX_OR_NT || 'bdump';
   else
    if substr(vdir,length(vdir),1) = DECS.UNIX_OR_NT
     then
      vdir := substr(vdir,1,length(vdir)-1);
    end if;
    vdir := vdir || DECS.UNIX_OR_NT || vname || DECS.UNIX_OR_NT || 'bdump';
  end if;

  begin
   file_handler := utl_file.fopen( vdir, vname || 'ALRT.log', 'r' );
  exception when others then
    glbx.error_details( 'ADMIN', 'MAIN_TITLE',null,vaid=>null,errmsg=>sqlerrm,extdet=>vdir );
  end;

  found_min_dt := FALSE;
  insert into exception_report (id, txt) values (s_exception_report.nextval, htf.nl );
  tmp := htf.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
  insert into exception_report (id, txt) values
  (s_exception_report.nextval, tmp ||
  htf.tabledata(htf.bold('Start Error Search Through Alert Log since date: ' || to_char(sysdate - check_from,  'Dy Mon DD HH24:MI:SS YYYY' ))) || htf.tablerowclose );
  loop
   begin
    utl_file.get_line( file_handler, output_buffer );
   exception
   when others then exit;
   end;
   if not found_min_dt
    then
     begin
      tdate := to_date( output_buffer, 'Dy Mon DD HH24:MI:SS YYYY' );
      if (sysdate - check_from) < tdate
         then
           found_min_dt := TRUE;
           insert into exception_report (id, txt) values (s_exception_report.nextval, htf.tablerowopen || htf.tabledata(htf.bold(output_buffer)) || htf.tablerowclose );
      end if;
     exception
      when others then null;
     end;
   end if;

   if found_min_dt
    then
     if instr(upper(output_buffer),'ERROR') > 0 or
        instr(upper(output_buffer),'CORRUPT') > 0 or
        instr(upper(output_buffer),'FAILURE') > 0
         then
          insert into exception_report (id, txt) values (s_exception_report.nextval, htf.tablerowopen || htf.tabledata(htf.bold(output_buffer)) || htf.tablerowclose );
     end if;
   end if;
  end loop;
  insert into exception_report (id, txt) values (s_exception_report.nextval, htf.tablerowopen || htf.tabledata(htf.italic('End of Search')) || htf.tablerowclose || htf.tableclose);
  utl_file.fclose( file_handler );

  all_report;

  gcode(1) := 'NODE_NAME';
  gparam(1) := glbx.extract_master_parameter('NODE_NAME');
  file_handler := utl_file.fopen( glbx.extract_master_parameter('MAIL_TEMPLATE_DIR'), 'report.log', 'w' );
  utl_file.put_line( file_handler, htf.htmlopen);
  utl_file.put_line( file_handler, htf.title( 'Piction Report' || ':' || glbx.extract_master_parameter('NODE_NAME') || '-' || glbx.extract_master_parameter('PAGE_TITLE')));
  utl_file.put_line( file_handler, htf.header(2,'Alert Log for' || ' : ' || to_char(sysdate, LNG.TSMASK),'CENTER') );
  utl_file.put_line( file_handler, '<CENTER>');
  for crec in (select txt from exception_report order by id) loop
   utl_file.put_line( file_handler, crec.txt );
  end loop;
  utl_file.put_line( file_handler, '</CENTER>');
  utl_file.put_line( file_handler, htf.htmlclose );
  utl_file.fclose( file_handler );
  glbx.send( gcode, gparam, 'report.log', glbx.extract_master_parameter('DBA_MAIL_FROM'), LNG3.ADM_TXT_283 || ':' || glbx.extract_master_parameter('NODE_NAME'), glbx.extract_master_parameter('MAIL_FROM'), is_attachment=>TRUE, scode=>'R1');
 end alert_log_report;

 procedure run_sql_statement( crs in varchar2, numcols in integer )
 as
  cursor_name	integer;
  rows		integer;
  c2rec	   	exception_report.txt%TYPE;
 begin
  -- Note: In this version, the number of columns is not yet supported
  cursor_name := dbms_sql.open_cursor;
  dbms_sql.parse(cursor_name, crs, dbms_sql.native );
  dbms_sql.define_column_char(cursor_name, 1, c2rec, 2000 );
  rows := dbms_sql.execute( cursor_name );
  loop
   if dbms_sql.fetch_rows(cursor_name) > 0
    then
     dbms_sql.column_value_char(cursor_name,1,c2rec);
     insert into exception_report(id,txt) values (s_exception_report.nextval,htf.tablerowopen);
     insert into exception_report(id,txt) values (s_exception_report.nextval,htf.tabledata(rtrim(c2rec)));
     insert into exception_report(id,txt) values (s_exception_report.nextval,htf.tablerowclose);
    else
     exit;
   end if;
  end loop;
  dbms_sql.close_cursor(cursor_name);

 exception
  when others
   then
    begin
     dbms_sql.close_cursor(cursor_name);
    exception
     when others then null;
    end;

 end run_sql_statement;

 procedure all_report
 as
  cursor c1( ctg varchar2) is
    select sql_statement,number_columns
    from exception_statements
    where ( (category = ctg) and (ctg is not null)) or (ctg is null);
  tmp	varchar2(1000);
 begin

  insert into exception_report(id,txt) values (s_exception_report.nextval,htf.header(3,LNG3.ADM_TXT_251,'CENTER'));
  tmp := htf.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
  insert into exception_report(id,txt) values (s_exception_report.nextval,tmp);
  for c1rec in c1( 'GENERAL' ) loop
   run_sql_statement( c1rec.sql_statement, c1rec.number_columns );
  end loop;
  insert into exception_report(id,txt) values (s_exception_report.nextval,htf.tableclose);

  insert into exception_report(id,txt) values (s_exception_report.nextval,htf.header(3,LNG3.ADM_TXT_252,'CENTER'));
  tmp := htf.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
  insert into exception_report(id,txt) values (s_exception_report.nextval,tmp);
  for c1rec in c1( 'STORAGE' ) loop
   run_sql_statement( c1rec.sql_statement, c1rec.number_columns );
  end loop;
  insert into exception_report(id,txt) values (s_exception_report.nextval,htf.tableclose);

  insert into exception_report(id,txt) values (s_exception_report.nextval,htf.header(3,LNG3.ADM_TXT_267,'CENTER'));
  tmp := htf.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
  insert into exception_report(id,txt) values (s_exception_report.nextval,tmp);
  for c1rec in c1( 'SECURITY' ) loop
   run_sql_statement( c1rec.sql_statement, c1rec.number_columns );
  end loop;
  insert into exception_report(id,txt) values (s_exception_report.nextval,htf.tableclose);

 end all_report;

procedure start_online_backup
as

TYPE cur_type 	IS REF CURSOR;
c 		cur_type;
query_str	varchar2(2000);
tname		SYS.DBA_DATA_FILES.TABLESPACE_NAME%TYPE;

begin
 query_str := 'select tablespace_name from sys.dba_tablespaces';
 open c for query_str;
 loop
   fetch c into tname;
   exit when c%NOTFOUND;
  -- dbms_output.put_line(tname);
   begin
    execute immediate 'alter tablespace ' || tname || '  begin backup';
   exception
    when others then dbms_output.put_line(sqlerrm);
   end;
 end loop;
 close c;

end start_online_backup;

procedure stop_online_backup
as

TYPE cur_type 	IS REF CURSOR;
c 		cur_type;
query_str	varchar2(2000);
tname		SYS.DBA_DATA_FILES.TABLESPACE_NAME%TYPE;

begin
 query_str := 'select tablespace_name from sys.dba_tablespaces';
 open c for query_str;
 loop
   fetch c into tname;
   exit when c%NOTFOUND;
  -- dbms_output.put_line(tname);
   begin
    execute immediate 'alter tablespace ' || tname || '  end backup';
   exception
    when others then dbms_output.put_line(sqlerrm);
   end;
 end loop;
 close c;

end stop_online_backup;

procedure send_renewals
as

 cursor c1 is select * from photographer where trunc(date_expires) = trunc(sysdate);
 cursor c2(plid integer) is select * from charge_plan where id = plid;
 cursor c3 is select * from photographer where trunc(date_expires) + 5 = trunc(sysdate); -- Hardcoded at the moment for 5 days notice

 c2rec		c2%ROWTYPE;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;

begin
 for c1rec in c1 loop
  open c2(c1rec.plan_id);
  fetch c2 into c2rec;
  close c2;
  gcode(1) := 'PHOTOGRAPHER_NAME';
  gparam(1) := c1rec.business_name;
  gcode(2) := 'RENEWAL_DATE';
  gparam(2) := to_char(c1rec.date_expires);
  gcode(3) := 'RENEWAL_CHARGE';
  gparam(3) := c2rec.plan_cost;
  gcode(4) := 'SIGNATURE';
  gparam(4) := glbx.extract_master_parameter('MAIL SIGNATURE');

  glbx.send( gcode, gparam, 'renewal_reminder.tmp', c1rec.contact_email, 'Reminder Notice', glbx.extract_master_parameter('MAIL_FROM'));

  insert into photographer_renewal_history(pid,date_renewal_sent) values (c1rec.pid,sysdate);
  commit;
 end loop;

 for c3rec in c3 loop
  open c2(c3rec.plan_id);
  fetch c2 into c2rec;
  close c2;
  gcode(1) := 'PHOTOGRAPHER_NAME';
  gparam(1) := c3rec.business_name;
  gcode(2) := 'RENEWAL_DATE';
  gparam(2) := to_char(c3rec.date_expires);
  gcode(3) := 'RENEWAL_CHARGE';
  gparam(3) := c2rec.plan_cost;
  gcode(4) := 'SIGNATURE';
  gparam(4) := glbx.extract_master_parameter('MAIL SIGNATURE');

  glbx.send( gcode, gparam, 'renewal_reminder_admin.tmp', glbx.extract_master_parameter('PICTION_EMAIL_ACCT'), 'Renewal Reminder Notice for ' || c3rec.business_name, glbx.extract_master_parameter('MAIL_FROM'));

  insert into photographer_renewal_history(pid,date_renewal_sent) values (c3rec.pid,sysdate);
  commit;
 end loop;

exception when others then
  glbx.error_details( 'ADMIN', 'SEND_RENEWALS',null,vaid=>null,errmsg=>sqlerrm );
end send_renewals;

procedure cleanup_lightbox( cln in integer )
is
begin
 delete from lightbox
  where sessid in
   (select sessid from login_session where date_created < (sysdate - cln ));
 commit;
exception
 when others then null;
end cleanup_lightbox;

procedure cleanup_preorders( cln in integer )
is
begin
 delete from shopping_basket
  where poid in
   (select poid from purchase_order where status in ('PreOrder - No Order Made') and sessid in
    (select sessid from login_session where date_created < (sysdate - cln ))
   );
 delete from purchase_audit
  where poid in
   (select poid from purchase_order where status in ('PreOrder - No Order Made') and sessid in
    (select sessid from login_session where date_created < (sysdate - cln ))
   );
 delete from purchase_order
   where status in ('PreOrder - No Order Made') and sessid in
    (select sessid from login_session where date_created < (sysdate - cln ));

 -- Note: Have to delete from login_session otherwise generation of sessid values is potentially corrupted
 delete from audit_all_activity ls where date_updated < (sysdate - cln ) and
  not exists (select 'x' from purchase_order po where ls.sessid = po.sessid);

 delete from login_session ls where date_created < (sysdate - cln ) and
  not exists (select 'x' from purchase_order po where ls.sessid = po.sessid);

 commit;
exception
 when others then null;
end cleanup_preorders;

procedure check_admin_unload( tgap in integer )
as

 cursor c1 is select * from unload_group where run_period is not null;

 run_job	boolean;
 ctime		date;
 dtime		date;
 result		boolean;

begin

for c1rec in c1 loop
 run_job := FALSE;
 if c1rec.run_period = 'H'
  then
   dtime := to_date( to_char(sysdate,'DD-MON-YYYY HH24:') || c1rec.run_every, 'DD-MON-YYYY HH24:MI' );
   ctime := sysdate;
   if dtime > (ctime - (((60 * tgap )/(24*60*60)))) and dtime < (ctime + (((60 * tgap )/(24*60*60)))) then run_job := TRUE; end if;
 elsif c1rec.run_period = 'D'
  then
   dtime := to_date( to_char(sysdate,'DD-MON-YYYY') || ' ' || c1rec.run_every, 'DD-MON-YYYY HH24:MI' );
   ctime := sysdate;
   if dtime > (ctime - (((60 * tgap )/(24*60*60)))) and dtime < (ctime + (((60 * tgap )/(24*60*60)))) then run_job := TRUE; end if;
 elsif c1rec.run_period = 'P' -- Specify the Day
  then
   if instr(c1rec.run_every,to_char(sysdate,'DY')) > 0
    then
     dtime := to_date( to_char(sysdate,'DD-MON-YYYY') || ' ' || substr(c1rec.run_every,instr(c1rec.run_every,' ')+1), 'DD-MON-YYYY HH24:MI' );
     ctime := sysdate;
     if dtime > (ctime - (((60 * tgap )/(24*60*60)))) and dtime < (ctime + (((60 * tgap )/(24*60*60)))) then run_job := TRUE; end if;
   end if;
 elsif c1rec.run_period = 'W'
  then
   if to_char(sysdate,'DY') = substr(c1rec.run_every,1,3)
    then
     dtime := to_date( to_char(sysdate,'DD-MON-YYYY') || ' ' || substr(c1rec.run_every,4), 'DD-MON-YYYY HH24:MI' );
     ctime := sysdate;
     if dtime > (ctime - (((60 * tgap )/(24*60*60)))) and dtime < (ctime + (((60 * tgap )/(24*60*60)))) then run_job := TRUE; end if;
   end if;
 elsif c1rec.run_period = 'M'
  then
   if to_char(sysdate,'DD') = lpad(substr(c1rec.run_every,1,2),2,'0')
    then
     dtime := to_date( to_char(sysdate,'DD-MON-YYYY') || ' ' || trim(substr(c1rec.run_every,2)), 'DD-MON-YYYY HH24:MI' );
     ctime := sysdate;
     if dtime > (ctime - (((60 * tgap )/(24*60*60)))) and dtime < (ctime + (((60 * tgap )/(24*60*60)))) then run_job := TRUE; end if;
   end if;
 end if;
 if run_job
  then
   result := adm.run_unload_group( c1rec.group_id );
 end if;
end loop;

exception
 when others then null;
end check_admin_unload;

function anniversaries
 return boolean
as

 cursor c1 is
  select *
  from anniversary
  where reminder_period = 'Y' and
        anniversary_type = 'E' and
        to_char(reminder_date,'DD-MON-YYYY') = to_char(sysdate + reminder_before_days,'DD-MON-YYYY')
 union all
  select *
  from anniversary
  where reminder_period = 'Y' and
        anniversary_type in ('A','B') and
        to_char( to_date(to_char(reminder_date,'DD-MON') || '-' || to_char(sysdate,'YYYY'),'DD-MON-YYYY'),'DD-MON-YYYY') = to_char(sysdate + reminder_before_days,'DD-MON-YYYY')
 union all
  select *
  from anniversary
  where reminder_period = 'M' and
        to_char( to_date(to_char(reminder_date,'DD-MON') || '-' || to_char(sysdate,'YYYY'),'DD-MON-YYYY'),'DD-MON-YYYY') = to_char(sysdate + reminder_before_days,'DD-MON-YYYY')
  ;

 cursor c2(acid integer, ltype varchar2) is select * from customer_contact where aid = acid and login_type = ltype;
 cursor c3(phgid integer) is select business_name,contact_email from photographer where pid = (select pid from customer_account where aid = phgid);

 c2rec		c2%ROWTYPE;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;
 tmp		varchar2(100);

begin
 for c1rec in c1 loop
  if c1rec.login_type = 'PHOTOGRAPHER'
   then
    open c3(c1rec.aid);
    fetch c3 into c2rec.sendto_name,c2rec.contact_email;
    close c3;
   else
    open c2(c1rec.aid,c1rec.login_type);
    fetch c2 into c2rec;
    close c2;
  end if;
  if c1rec.how_notify = 'E'
   then
    if c2rec.contact_email is not null
     then
       gcode(1) := 'NAME';
       gparam(1) := c2rec.sendto_name;
       gcode(2) := 'MESSAGE';
       gparam(2) := c1rec.reminder_message;
       gcode(3) := 'NOTIFY_DATE';
       gparam(3) := to_char(to_date(to_char(c1rec.reminder_date,'DD-MON') || '-' || to_char(sysdate,'YYYY'),'DD-MON-YYYY'),'DD-Mon-YYYY');
       gcode(4) := 'TYPE';
       if c1rec.anniversary_type = 'A'
        then
         tmp := to_char(round(round(months_between((sysdate + c1rec.reminder_before_days+1),c1rec.reminder_date))/12));
         gparam(4) := 'Anniversary' || ':' || ' ' || ' - ' || tmp;
       elsif c1rec.anniversary_type = 'B'
        then
         tmp := to_char(round(round(months_between((sysdate + c1rec.reminder_before_days+1),c1rec.reminder_date))/12));
         gparam(4) := 'Birthday' || ':' || ' ' || 'Age - ' || tmp;
       elsif c1rec.anniversary_type = 'E'
        then
         gparam(4) := 'Event';
       end if;
       gcode(5) := 'DAY';
       gparam(5) := to_char(to_date(to_char(c1rec.reminder_date,'DD-MON') || '-' || to_char(sysdate,'YYYY'),'DD-MON-YYYY'),'Day');
       gcode(6) := 'NOTIFY';
       gparam(6) := to_char(c1rec.reminder_before_days);
       gcode(7) := 'SIGNATURE';
       gparam(7) := glbx.extract_master_parameter('MAIL SIGNATURE');
       glbx.send( gcode, gparam, 'anniversary.tmp', p_to=>c2rec.contact_email, p_subj=>'Anniversary Notification', p_from=>glbx.extract_master_parameter('MAIL_FROM'), scode=>'A1');
    end if;
  end if;
 end loop;
 return( TRUE );
exception
 when others then null;
end anniversaries;

procedure reverse_engineer_apache_logs
as

 cursor c1 is select max(timestamp) mx from apache_logs;
 cursor c2 is select virtual_directory from ftp_sites where site_type = 'F';

 c1rec  c1%ROWTYPE;
 fl	UTL_FILE.FILE_TYPE;
 bfr	varchar2(32767);
 tmp	varchar2(32767);
 bfr2	varchar2(32767);
 fnd	boolean;
 ftp	glbx.myarray;
 ts	date;
 x	integer;
 y	integer;

begin
 open c1;
 fetch c1 into c1rec;
 close c1;
 c1rec.mx := nvl(c1rec.mx,sysdate-10000);

 for c2rec in c2 loop
  -- Remove the leading http:// up to the first /. Assume there is a trailing slash.
  ftp( c2%ROWCOUNT ) := substr(c2rec.virtual_directory,instr(c2rec.virtual_directory,'/',1,3));
 end loop;

 if ftp.count = 0 then return; end if; -- nothing to scan for, so exit

 begin
  fl := utl_file.fopen( glbx.extract_master_parameter('APACHE_LOG_DIRECTORY'),'access_log','r', 25000);
  --dbms_output.put_line(glbx.extract_master_parameter('APACHE_LOG_DIRECTORY'));
 exception
  when others then return;
 end;
 -- Search until latest timestamp found
 fnd := TRUE;
 loop
  begin
   utl_file.get_line( fl, bfr );
   begin
    if to_date(substr(bfr,instr(bfr,'[')+1,20),'DD/MON/YYYY:HH24:MI:SS') > c1rec.mx then fnd := TRUE; exit; end if;
   exception when others then null;
   end;
  exception
   when others then exit;
  end;
 end loop;

 -- If nothing found then exit
 if not fnd then utl_file.fclose( fl ); return; end if;

 -- Loop through reading in records
 loop
  begin
   utl_file.get_line( fl, bfr );
   x := instr(bfr,'"GET');
   if x > 0
    then
     ts := to_date(substr(bfr,instr(bfr,'[')+1,20),'DD/MON/YYYY:HH24:MI:SS');
     y := instr(bfr,'HTTP/',x,1);
     bfr2 := substr(bfr,x+5,(y-x)-5);
     tmp := substr(bfr2,1,instr(bfr2,'/',-1));
     --if instr(bfr2,'download') > 0 then dbms_output.put_line(bfr2 || '-' || tmp || '+'); end if;
     for j in ftp.first..ftp.last loop
      --dbms_output.put_line(ftp(j) || '-' || tmp);
      if ftp(j) = tmp
       then
        insert into apache_logs(timestamp,ipaddress,virtual_directory,image_name) values
         (ts,substr(bfr,1,instr(bfr,' ')-1),tmp,substr(bfr2,instr(bfr2,'/',-1)+1));
        exit;
       end if;
     end loop;
   end if;
  exception
   when others then dbms_output.put_line(sqlerrm); exit;
  end;
 end loop;
 utl_file.fclose( fl );

 commit;

end reverse_engineer_apache_logs;

procedure check_emails_for_load
as
 cursor c1 is select * from customer_account where receive_images_via_email = 'T' and receive_image_account is not null and receive_image_umo_scene is not null;
begin
 for c1rec in c1 loop
  xml.dir_email_receive( surl=>null, cusrec=>c1rec );
 end loop;
end check_emails_for_load;

function drop_old_directories
 return boolean
as
 cursor c1(nm varchar2) is select * from all_directories where directory_name like nm;
begin
 for c1rec in c1(GLBX.GLOBAL_DIR || user || '%' ) loop
  execute immediate 'drop directory ' || c1rec.directory_name;
 end loop;
 return( TRUE );
exception
 when others then return( FALSE );
end drop_old_directories;

procedure add_to_shared_pool
as
  cursor c1 is select name from v$database;
  cursor c2 is select object_name from user_objects where object_type = 'PACKAGE';

  c1rec c1%ROWTYPE;

begin
 open c1;
 fetch c1 into c1rec;
 close c1;

 -- if c1rec.name not in ('PRD1','PRD2','PRD3','PICTION') then return; end if;

 for c2rec in c2 loop

  sys.dbms_shared_pool.keep( c2rec.object_name );

 end loop;

end add_to_shared_pool;

end admin;
/
