CREATE OR REPLACE procedure WEBSYS.piction_rman_status(report_dest in varchar2 default 'SCREEN',
                                                err_only in number default 0,
                                                email_recp in varchar2 default null,
                                                space_threshold in number default 10,
                                                backup_day in number default 1
                                               )
as

-- ------------------------------------------------------------
-- RMAN Status Procedure - Marty Channon 23 NOV 2015
--
-- Example:
--          exec piction_rman_status('SCREEN', 0, null, 10, 1);
--          exec piction_rman_status('EMAIL', 0, 'martin.channon@piction.com', 10, 1);
--
-- *IMPORTANT*
--  The user must be given SELECT rights on the following:
--  (Note position of underscore)
--  grant select on V_$RECOVERY_FILE_DEST      to websys;
--  grant select on V_$RMAN_STATUS             to websys;
--  grant select on V_$RMAN_BACKUP_JOB_DETAILS to websys;
--  grant select on V_$RMAN_OUTPUT             to websys;
--
-- Input Parameters:
--   report_dest:     Output SCREEN or EMAIL
--   err_only:        0  Send all messages
--                    n  only send if level n messages and above
--   space_threshold: % of remaining space before an alert is sent
--   backup_day:      Check last backup for this day of the week
--                    1 = Sunday; 7 = Saturday
--                    *** WARNING *** Some databases do not
--                    conform to SUN = 1, etc. To check:
--                    select to_char(sysdate, 'D DAY') from dual;
-- ----------------------------------------------------------------

cursor c1 is
 select name, space_limit, space_reclaimable, space_used
 from   V$RECOVERY_FILE_DEST;

cursor c2 (v_dte date) is
 select /*+ RULE */ session_recid
 from   v$rman_status
 where  to_char(start_time, 'DD-MON-YYYY') = to_char(v_dte, 'DD-MON-YYYY')
        and operation = 'BACKUP'
		and rownum < 2
 ;

cursor c3 (v_sess integer, ex_sts varchar2) is
 select /*+ RULE */ status, start_time, end_time, operation
 from   v$rman_status
 where  session_recid = v_sess
        and
        ( ex_sts is null
          or
          (ex_sts is not null and upper(status) <> upper(ex_sts))
        )
 order  by start_time
;

c1rec            c1%ROWTYPE;
c2rec            c2%ROWTYPE;
errmsg           owa.vc_arr;
msg              owa.vc_arr;
-- v48 control_parms    tpl.template_parms;
space_free       number;
err_ctr          integer;
msg_ctr          integer;
v_subj           varchar2(100);
rman_date        date;
wkday            integer;
stp              varchar2(100);
bkp_failed       boolean;

procedure add_line(v_txt in varchar2, err_msg in varchar2 default 'ERR', err_no in integer default 1, new_msg in boolean default TRUE)
is
begin
  case upper(err_msg)
  when 'MSG'
   then
    if msg.exists(err_no)
     then
      msg(err_no) := msg(err_no) || chr(10);
      if new_msg
       then
        msg(err_no) := msg(err_no) || chr(10);
      end if;
      msg(err_no) := msg(err_no) || v_txt;
    else
      msg(err_no) := v_txt;
    end if;
  when 'ERR'
   then
    if errmsg.exists(err_no)
     then
      errmsg(err_no) := errmsg(err_no) || chr(10);
      if new_msg
       then
        errmsg(err_no) := errmsg(err_no) || chr(10);
      end if;
      errmsg(err_no) := errmsg(err_no) || v_txt;
    else
      errmsg(err_no) := v_txt;
    end if;
  end case;
end add_line;

procedure send_email is
begin
 /* Not used in v48
 control_parms('PICTION_RMAN.EMAIL_SUBJECT') := v_subj;
 -- gl.dbg('Debug 10');
 if msg.count > 0 and err_only = 0
  then
   for j in msg.first..msg.last loop
    control_parms('PICTION_RMAN.MESSAGE') := control_parms('PICTION_RMAN.MESSAGE') || replace(replace(msg(j), chr(10), '<br>'), ' ', '&nbsp;');
   end loop;
 end if;
 -- gl.dbg('Debug 11');
 if errmsg.count > 0
  then
   for j in errmsg.first..errmsg.last loop
    control_parms('PICTION_RMAN.RMAN_ERROR') := control_parms('PICTION_RMAN.RMAN_ERROR') || replace(replace(errmsg(j), chr(10), '<br>'), ' ', '&nbsp;');
   end loop;
 end if;

 control_parms('PICTION_RMAN.RMAN_ERROR') := nvl(control_parms('PICTION_RMAN.RMAN_ERROR'), 'No Errors');
 control_parms('PICTION_RMAN.MESSAGE') := nvl(control_parms('PICTION_RMAN.MESSAGE'),'No Results');

 tpl.public_page(name=>'SYSTEM.Piction RMAN Status'
               , p1=>control_parms('PICTION_RMAN.EMAIL_SUBJECT')
               , p2=>control_parms('PICTION_RMAN.EMAIL_TO')
               , p3=>control_parms('PICTION_RMAN.EMAIL_FROM')
               , p4=>control_parms('PICTION_RMAN.HOST_DETAILS')
               , p5=>control_parms('PICTION_RMAN.RMAN_ERROR')
               , p6=>control_parms('PICTION_RMAN.MESSAGE')
                );

*/
 null;
end send_email;
begin

-- v48   control_parms('PICTION_RMAN.EMAIL_SUBJECT') := NULL;
-- v48   control_parms('PICTION_RMAN.EMAIL_TO') := NULL;
-- v48   control_parms('PICTION_RMAN.EMAIL_FROM') := NULL;
-- v48   control_parms('PICTION_RMAN.HOST_DETAILS') := NULL;
-- v48   control_parms('PICTION_RMAN.RMAN_ERROR') := NULL;
-- v48   control_parms('PICTION_RMAN.MESSAGE') := NULL;

  -- gl.dbg('Debug 1');
  v_subj := 'RMAN Status: ' || glbx.extract_master_parameter('NODE_NAME');
-- v48   control_parms('PICTION_RMAN.EMAIL_TO') := email_recp;
-- v48   control_parms('PICTION_RMAN.EMAIL_FROM') := gl.extract_master_parameter('MAIL_FROM');
-- v48   select upper(instance_name) || ' on ' || host_name into control_parms('PICTION_RMAN.HOST_DETAILS') from v$instance;
  -- gl.dbg('Debug 2');

  open c1;
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
    case upper(report_dest)
    when 'EMAIL'
     then
-- v48      control_parms('PICTION_RMAN.RMAN_ERROR') := 'Unable to access dynamic table V$RECOVERY_FILE_DEST';
     v_subj := v_subj || ' - **ERROR**';
      if email_recp is not null
       then
        send_email;
      end if;
    else
      dbms_output.put_line('Unable to access dynamic table V$RECOVERY_FILE_DEST');
    end case;
    close c1;
    return;
  end if;
  close c1;

-- Check if running low on backup space
  -- gl.dbg('Debug 3');

  space_free := 100 - ((c1rec.SPACE_USED - c1rec.SPACE_RECLAIMABLE)/c1rec.SPACE_LIMIT * 100);

  if space_free <= space_threshold
   then
    err_ctr := nvl(errmsg.last, 0) + 1;
    if err_ctr > 1
     then
      errmsg(err_ctr) := chr(10) || chr(10);
      err_ctr := err_ctr + 1;
    end if;
    add_line('WARNING: Recovery space available is critically low:', 'ERR', 1);
    add_line('         Warning threshold: ' || space_threshold || '%', 'ERR', 1, FALSE);
    add_line('         Space free       : ' || ROUND(space_free, 1) || '%', 'ERR', 1, FALSE);
  end if;

-- Check status of last backup

  -- Calculate date to interrogate
  -- gl.dbg('Debug 4');
  wkday := to_number(to_char(sysdate, 'D'));
  if  wkday < backup_day
   then
    rman_date := sysdate - wkday - 7 + backup_day;
  else
    rman_date := sysdate - wkday + backup_day;
  end if;

  add_line('Status of Backup run on ' || to_char(rman_date, 'Dy, DD Mon YYYY') || ': ' || chr(10), 'MSG', 1);
  add_line('Start     End       Operation                               Status', 'MSG', 1, FALSE);
  add_line('--------  --------  --------------------------------------  ---------', 'MSG', 1, FALSE);

  bkp_failed := FALSE;

  -- gl.dbg('Debug 5');

  open c2(rman_date);
  fetch c2 into c2rec;
  if c2%NOTFOUND
   then
    bkp_failed := TRUE;
    add_line('No RMAN logs found for ' || rman_date);
  end if; -- Error if no logs found
  close c2;

  for c3rec in c3(c2rec.session_recid, null) loop

    -- Report Warnings or Failures
    if upper(c3rec.status) <> 'COMPLETED'
     then
      bkp_failed := TRUE;
    end if;

    add_line(rpad(to_char(c3rec.start_time, 'hh24:mi:ss'), 10)
          || rpad(to_char(c3rec.end_time, 'hh24:mi:ss'), 10)
          || rpad(c3rec.operation, 40)
          || c3rec.status, 'MSG', 1, FALSE);
  end loop;

  -- gl.dbg('Debug 6');
  if bkp_failed
   then
    add_line('WARNING: Last backup failed to successfully complete', 'ERR');
    add_line(to_char(rman_date, 'Dy, DD Mon YYYY'),'ERR', 1, FALSE);
    add_line('Start     End       Operation                Status', 'ERR', 1);
    for c3rec in c3(c2rec.session_recid, 'COMPLETED') loop
      add_line(rpad(to_char(c3rec.start_time, 'hh24:mi:ss'), 10)
            || rpad(to_char(c3rec.end_time, 'hh24:mi:ss'), 10)
            || rpad(c3rec.operation, 25)
            || c3rec.status, 'ERR', 1, FALSE);
    end loop;
  end if;

-- Report on Recovery Destination Space

  glbx.dbg('Debug 7');
  add_line('Recovery File Destination: ' || c1rec.name, 'MSG', 1);
  add_line('Space Limit              : ' || lpad(to_char(c1rec.space_limit, '999,999,999,999,990'), 20), 'MSG', 1, FALSE);
  add_line('Space Available          : ' || lpad(to_char(c1rec.space_limit - c1rec.space_used + c1rec.space_reclaimable, '999,999,999,999,990'), 20), 'MSG', 1, FALSE);
  add_line('Space free               : ' || lpad(ROUND(space_free, 1) || '%', 20), 'MSG', 1, FALSE);

-- Send Data

  if errmsg.count > 0
   then
    if upper(report_dest) = 'SCREEN'
     then
      dbms_output.put_line('Error Messages:' || chr(10) || chr(10));
    end if;
    v_subj := v_subj || ' - **WARNING**';
    for j in errmsg.first..errmsg.last loop
     if j >= err_only
      then
       if upper(report_dest) = 'SCREEN'
        then
         dbms_output.put_line(errmsg(j));
       end if;
     end if;
    end loop;
  end if;

  glbx.dbg('Debug 8');
  if msg.count > 0 and err_only = 0
   then
    if upper(report_dest) = 'SCREEN'
     then
      dbms_output.put_line('Messages:' || chr(10) || chr(10));
    end if;
    for j in msg.first..msg.last loop
     if upper(report_dest) = 'SCREEN'
      then
       dbms_output.put_line(msg(j));
     end if;
    end loop;
  end if;

  -- gl.dbg('Debug 9');
  if upper(report_dest) = 'EMAIL'
     and
     email_recp is not null
     and
     ( errmsg.count > 0 or (msg.count > 0 and err_only = 0))
  then
    send_email;
  end if;

exception when others
 then
  glbx.dbg('Piction RMAN ERROR: ' || sqlerrm);
  case upper(report_dest)
  when 'EMAIL'
   then
-- v48     control_parms('PICTION_RMAN.RMAN_ERROR') := 'Major error: ' || sqlerrm;
    if email_recp is not null
     then
      send_email;
    end if;
  else
    dbms_output.put_line('Major error: ' || sqlerrm);
  end case;
end piction_rman_status;
/
