CREATE OR REPLACE package body WEBSYS.glbx
as

g_init_failed_msg constant varchar2(255) default 'INIT_FAILED: Initialization of the http-callout subsystem failed';
g_request_failed_msg constant varchar2(255) default 'REQUEST_FAILED: When the HTTP call failed (e.g., Webserver down?)';
g_invalid_path_msg constant varchar2(255) default 'INVALID_PATH: File location or filename was invalid.';
g_invalid_mode_msg constant varchar2(255) default 'INVALID_MODE: The open_mode parameter in FOPEN was invalid.';
g_invalid_filehandle_msg constant varchar2(255) default 'INVALID_FILEHANDLE: The file handle was invalid.';
g_invalid_operation_msg constant varchar2(255) default 'INVALID_OPERATION: The file could not be opened or operated on as requested.';
g_read_error_msg constant varchar2(255) default 'READ_ERROR: An operating system error occurred during the read operation.';
g_write_error_msg constant varchar2(255) default 'WRITE_ERROR: An operating system error occurred during the write operation.';
g_internal_error_msg constant varchar2(255) default 'INTERNAL_ERROR: An unspecified error in PL/SQL.';

 function dquote( p_str in varchar2 ) return varchar2;
 function add_opt( p_switch in varchar2, p_value in varchar2 ) return varchar2;
 function urlencode( p_str in varchar2 ) return varchar2;
 function get_theme_types(phgid in integer) return theme_types%ROWTYPE;
 function cust_get_theme_types(acid in integer) return theme_types%ROWTYPE;
 function piction_cookie( lrec out login_session%ROWTYPE ) return varchar2;
 function cust_button( pfx in THEME%ROWTYPE, gif in varchar2, element in integer default 1 ) return varchar2;
 function category_total( acid in integer, uscid in integer) return integer;
 function meta_distinct_lov( lov_list in varchar2, value in varchar2, choose_distinct in boolean, indx in varchar2 default null ) return varchar2;

 procedure merge_template( gcode in GLBX.MYARRAY, gparam in GLBX.MYARRAY, infile in varchar2, is_sms in boolean, is_report in boolean, fname in out varchar2, type_of in varchar2, tname in varchar2, job in out varchar2, printer in varchar2, extension in varchar2, v_attachment in out varchar2);
 procedure account_expired( c1rec CUSTOMER_ACCOUNT%ROWTYPE, customer_type in varchar2 );
 procedure redirect_to(rsite_id in integer, un in varchar2, pw in varchar2, em in varchar2);
 procedure help_cookie;
 procedure rec_scene_display( surl in varchar2, lvl in integer, spc in integer, custrec in CUSTOMER_ACCOUNT%ROWTYPE, pfx in THEME%ROWTYPE, ltype in varchar2, stype in integer, owner_id in integer, bf92 in char, bf131 in varchar2, titlegif in varchar2, proftot in integer default 0, expanded_scenes in GLBX.MYARRAY, showtotal in boolean, align in varchar2 , new_nested in varchar2 default null);
 procedure phg_new_password( phgrec in PHOTOGRAPHER%ROWTYPE, msg in varchar2 default null );
 procedure transfer_acct_details( ltype in varchar2, acid in integer, profid in integer, sess_id in integer );
 procedure transfer_session_Images( ltype in varchar2, acid in integer, profid in integer, sess_id in integer );
 procedure prompt_em_country(surl in varchar2, sts in varchar2, un in varchar2, pw in varchar2, job in varchar2, em in varchar2, unsolicited_email in varchar2 default 'F', country in varchar2);
 procedure disp_news(surl in varchar2, acid in varchar2, stype in integer, ltype in varchar2, pfx in THEME%ROWTYPE, cusrec in customer_account%ROWTYPE, theme_rec in THEME_TYPES%ROWTYPE, profid in integer );
 procedure note_invalid_access(un in varchar2, pw in varchar2, jb in varchar2 default null );
 procedure meta_sql_query_update( v_umo in integer, urec in umo_attributes%ROWTYPE, utype in varchar2, upd_val in varchar2 );
 procedure add_email_log(v_disp_type in varchar2, v_template in varchar2, v_mail_file in varchar2, v_mail_from in varchar2, v_mail_to in varchar2, v_mail_subject in varchar2, v_is_sms in varchar2, v_at_step in varchar2, v_error in varchar2);
 procedure list_categories(surl in varchar2, stype in integer, ltype in varchar2, profid in integer, acid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, home_rec in home_news%ROWTYPE );
 procedure show_link( acid in integer, stype in integer, pfx in THEME%ROWTYPE, uscid in integer, showtotal in boolean, lnk in varchar2, txt in varchar2, cusloc in varchar2, istb in boolean default TRUE, aln in varchar2 default null, new_nested in varchar2 default null, bf131 in varchar2, apnd in varchar2 default null );
 procedure transfer_details( old_sessid in integer, new_sessid in integer, new_surl in varchar2, ltype in varchar2, disconnect_session in boolean default TRUE, use_existing_surl in boolean );
 procedure show_checkbox( c2rec in customer_meta_data%ROWTYPE, c3rec in umo_attributes%ROWTYPE, value in varchar2, cell in varchar2 default null );
 procedure core_portlet( phgid in integer, pname in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );
 procedure core_send_query( phgid in integer, pname in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, c1rec in portlet_definition%ROWTYPE, c6rec in out portlet_send_query%ROWTYPE );
 procedure core_news( phgid in integer, pname in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, c1rec in portlet_definition%ROWTYPE, c7rec in out portlet_news%ROWTYPE );

procedure powered_by_piction(surl in varchar2, left_api_parm in varchar2, search_total in integer, display_detail in varchar2, ltype varchar2, acid in integer)
as
begin
 htp.p( '<CENTER>' );
 htp.anchor2('http://www.piction.com',htf.img( DECS.IMAGE_LOCATION || 'admin/piction.gif',cattributes=>' border=0',calt=>'Go to the Piction Site'),ctarget=>'PICTION_WINDOW');
 htp.p( '</CENTER>' );
end powered_by_piction;

procedure send_workflow( gcode in GLBX.MYARRAY, gparam in GLBX.MYARRAY, infile in varchar2, tname  in varchar2, job in out varchar2, printer in varchar2 )
as
 fname		varchar2(1000);
 v_attachment	varchar2(100);
begin

 if tname is null then return; end if;
 merge_template(gcode, gparam, infile, FALSE, FALSE, fname, 'TABLE', tname, job, printer, null, v_attachment);

end send_workflow;

procedure email_template_determine( scode in varchar2, vp_subj in out varchar2, v_infile in out varchar2, v_pid in integer, v_aid in integer, v_profile_id in integer, gcode in GLBX.MYARRAY, gparam in GLBX.MYARRAY )
as

 cursor c1(scode varchar2) is
  select *
  from email_template
  where email_code = scode;

 cursor c2(scode varchar2, v_pid integer) is
  select *
  from email_template
  where email_code = scode and pid = v_pid;

 cursor c3(scode varchar2, v_aid integer) is
  select *
  from email_template
  where email_code = scode and aid = v_aid;

 cursor c4(scode varchar2, v_profile_id integer) is
  select *
  from email_template
  where email_code = scode and aid = v_profile_id;

crec	email_template%ROWTYPE;

function subs(ky in varchar2)
 return varchar2
as
 p_body	varchar2(4000);
begin
  p_body := ky;
  for j in gcode.first..gcode.last loop
   if gcode(j) = 'SIGNATURE' and gparam(j) is null
    then
     p_body := replace( p_body, '<' || gcode(j) || '>', glbx.extract_master_parameter('MAIL SIGNATURE'));
    else
     p_body := replace( p_body, '<' || gcode(j) || '>', gparam(j));
   end if;
  end loop;
  return( p_body );
end subs;

begin
--xxx replace key values in subject name
 if v_profile_id is not null
  then
   open c4(scode,v_profile_id);
   fetch c4 into crec;
   close c4;
   if crec.template is not null
    then
     vp_subj := subs(nvl(crec.subject_line,vp_subj));
     v_infile := nvl(crec.template,v_infile);
     return;
   end if;
 end if;

 if v_aid is not null
  then
   open c3(scode,v_aid);
   fetch c3 into crec;
   close c3;
   if crec.template is not null
    then
     vp_subj := subs(nvl(crec.subject_line,vp_subj));
     v_infile := nvl(crec.template,v_infile);
     return;
   end if;
 end if;

 if v_pid is not null
  then
   open c2(scode,v_pid);
   fetch c2 into crec;
   close c2;
   if crec.template is not null
    then
     vp_subj := subs(nvl(crec.subject_line,vp_subj));
     v_infile := nvl(crec.template,v_infile);
     return;
   end if;
 end if;

 open c1(scode);
 fetch c1 into crec;
 close c1;
 vp_subj := subs(nvl(crec.subject_line,vp_subj));
 v_infile := nvl(crec.template,v_infile);

exception
 when others then null;
end email_template_determine;

procedure send( gcode	 in GLBX.MYARRAY,
  		gparam	 in GLBX.MYARRAY,
  		infile	 in varchar2,
		p_to     in varchar2,
                p_subj   in varchar2 default NULL,
                p_from   in varchar2 default NULL,
                p_cc     in varchar2 default NULL,
                p_bcc    in varchar2 default NULL,
                is_sms   in boolean default FALSE,
                is_report in boolean default FALSE,
                ltype    in varchar2 default null,
                own_id   in integer default null,
                extension in varchar2 default null,
                is_attachment in boolean default FALSE,
                scode in varchar2 default null,
                v_pid in integer default null,
                v_aid in integer default null,
                v_profile_id in integer default null)
is

    cursor c1(v_umo integer) is select um.extras.photo_name pname from umo um where umo_id = v_umo;
    cursor c3(ownid integer, vltype varchar2, bname varchar2) is select email_address from address_book_entry abe, address_book ab where ab.abid = abe.abid and ab.ltype = vltype and ab.own_id = ownid and ab.book_name = bname;

    c1rec	      c1%ROWTYPE;
    fname    	      varchar2(1024);
    job		      varchar2(100);
    l_n               number;
    l_request 	      varchar2(4000);
    mailid	      integer;
    v_pto	      varchar2(30000);
    found_addr	      boolean;
    v_is_sms	      char(1);
    v_attachment      varchar2(20);
    vp_subj	      varchar2(1000);
    v_infile	      varchar2(1000);
    step_n   varchar2(200);

begin

 vp_subj := p_subj;
 v_infile := infile;
 if scode is not null and glbx.extract_master_parameter('NEW_EMAIL') = 'TRUE'
  then
   -- Call New Routine
   email_template_determine( scode, vp_subj, v_infile, v_pid, v_aid, v_profile_id, gcode, gparam );
 end if;

 if upper(glbx.extract_fname(infile,'SUFFIX')) = 'ZIP'
  then
   html_email.zipsend( gcode, gparam,infile,p_to,p_subj,p_from,p_cc,p_bcc,is_sms,is_report,ltype,own_id,
                extension,is_attachment,scode,v_pid,v_aid,v_profile_id);
   return;
 end if;

 if is_sms then v_is_sms := 'T'; else v_is_sms := 'F'; end if;
 if is_attachment then if is_report then v_attachment := 'TRUEX'; else v_attachment := 'TRUE'; end if; else v_attachment := 'FALSE'; end if;

 merge_template(gcode, gparam, v_infile, is_sms, is_report, fname, 'FILE', null, job, null, extension, v_attachment);
 step_n := 'Step 1a '||v_infile;
 if is_attachment
  then
   if is_report
    then
      step_n := 'Step 1y '||v_infile;
      v_attachment := 'TRUEX';
      open c1(to_number(v_infile));
      fetch c1 into c1rec;
      close c1;
      if instr(c1rec.pname,'(CSV)') > 0
       then
        v_attachment := 'TRUEXCSV';
      elsif instr(c1rec.pname,'(XML)') > 0
       then
        v_attachment := 'TRUEXXML';
      end if;
    else
     if instr(upper(v_infile),'.CSV') > 0
      then
        v_attachment := 'TRUEXCSV';
     elsif instr(upper(v_infile),'.XML') > 0
      then
        v_attachment := 'TRUEXXML';
      else
       v_attachment := 'TRUE';
     end if;
   end if;
 end if;
 if is_report and v_attachment not in ('TRUEX','TRUEXCSV','TRUEXXML') then v_attachment := 'TRUEX'; end if;
 if v_attachment = 'TRUEX'
  then
   begin
      step_n := 'Step 1zz '||v_infile;
      open c1(to_number(v_infile));
      fetch c1 into c1rec;
      close c1;
      if instr(c1rec.pname,'(CSV)') > 0
       then
        v_attachment := 'TRUEXCSV';
      elsif instr(c1rec.pname,'(XML)') > 0
       then
        v_attachment := 'TRUEXXML';
      end if;
   exception when others then null;
   end;
 end if;


 -- Check if Address Book is used (this version supports max of 30K of addresses, anything more is ignored - 2K is used for V815 subject line)
 v_pto := p_to;
 found_addr := FALSE;
 if (instr(v_pto,'@') = 0)
  then
   v_pto := NULL;
   -- Create a comma delimited list of to addr
   for c3rec in c3(own_id,ltype,upper(p_to)) loop
    found_addr := TRUE;
    begin v_pto := v_pto || ',' || c3rec.email_address; exception when others then null; end; -- Ignore it if the line goes beyond 32K (enhanced in later release)
   end loop;
   if not found_addr
    then
     v_pto := p_to;
    else
     v_pto := substr(v_pto,2);
   end if;
 else
  v_pto := p_to;
 end if;

 -- Send it
 if is_sms
  then
    glbx.send_the_mail_smtp(fname,p_from,v_pto,vp_subj,'TRUE','FALSE',null);
  else
    dbms_job.submit(mailid, 'glbx.send_the_mail_smtp(' ||
                      '''' || translate(fname,'''','''''') || ''',' ||
                      '''' || translate(p_from,'''','''''') || ''',' ||
                      '''' || translate(v_pto,'''','''''') || ''',' ||
                      '''' || translate(vp_subj,'''','''''') || ''',' ||
                      '''' || 'FALSE' || ''',' ||
                      '''' || v_attachment || ''',' ||
                      '''' || translate(v_infile,'''','''''') || '''' ||
                      ');', sysdate );
     commit;
 end if;

exception
    when utl_file.invalid_path then
     add_email_log('1 ERROR MERGE TEMPLATE',v_infile || ':' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || glbx.extract_master_parameter('SMTP_SERVER'),fname,p_from,v_pto,vp_subj,v_is_sms,'TEMPLATE','Invalid Path:' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || fname );
    when utl_file.invalid_mode then
     add_email_log('2 ERROR MERGE TEMPLATE',v_infile || ':' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || glbx.extract_master_parameter('SMTP_SERVER'),fname,p_from,v_pto,vp_subj,v_is_sms,'TEMPLATE','Invalid Mode:' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || fname );
    when utl_file.invalid_filehandle then
     add_email_log('3 ERROR MERGE TEMPLATE',v_infile || ':' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || glbx.extract_master_parameter('SMTP_SERVER'),fname,p_from,v_pto,vp_subj,v_is_sms,'TEMPLATE','Invalid File Handle:' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || fname );
    when utl_file.invalid_operation then
     add_email_log('4 ERROR MERGE TEMPLATE',v_infile || ':' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || glbx.extract_master_parameter('SMTP_SERVER'),fname,p_from,v_pto,vp_subj,v_is_sms,'TEMPLATE','Invalid Operation:' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || fname );
    when utl_file.read_error then
     add_email_log('5 ERROR MERGE TEMPLATE',v_infile || ':' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || glbx.extract_master_parameter('SMTP_SERVER'),fname,p_from,v_pto,vp_subj,v_is_sms,'TEMPLATE','Invalid Read:' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || fname );
    when utl_file.write_error then
     add_email_log('6 ERROR MERGE TEMPLATE',v_infile || ':' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || glbx.extract_master_parameter('SMTP_SERVER'),fname,p_from,v_pto,vp_subj,v_is_sms,'TEMPLATE','Invalid Write:' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || fname );
    when utl_file.internal_error then
     add_email_log('7 ERROR MERGE TEMPLATE',v_infile || ':' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || glbx.extract_master_parameter('SMTP_SERVER'),fname,p_from,v_pto,vp_subj,v_is_sms,'TEMPLATE','Internal Error:' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || fname );
    when others then
     add_email_log('8 ERROR MERGE TEMPLATE',step_n||v_infile || ':' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || glbx.extract_master_parameter('SMTP_SERVER'),fname,p_from,v_pto,vp_subj,v_is_sms,'TEMPLATE',sqlerrm || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || fname );
end send;

function base64( nmb integer ) return varchar2
 as
 begin
  return( substr('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/',nvl(nmb,0)+1,1) );
end base64;

function conv_3bytes( fbytes varchar2 ) return varchar2
 as
  nmb 	integer;
  x	integer;
  y	integer;
  z	integer;
  a	integer; --4867657
 begin
  if length(fbytes) = 3
   then
    nmb := (65536*ascii(substr(fbytes,1,1))) + (256*ascii(substr(fbytes,2,1))) + ascii(substr(fbytes,3,1));
    --dbms_output.put_line( 'X1:' || nmb );
    x := trunc(nmb/262144);
    y := trunc((nmb - (x*262144))/4096);
    z := trunc(((nmb - (x*262144) - (y*4096)))/64);
    a := nmb - (x*262144) - (y*4096) - (z*64);
    return( base64(x) || base64(y) || base64(z) || base64(a)); -- || ':' || to_char(x) || '-' || to_char(y) || '-' || to_char(z) || '-' || to_char(a)
  elsif length(fbytes) = 2
   then
    nmb := (65536*ascii(substr(fbytes,1,1))) + (256*ascii(substr(fbytes,2,1)));
    x := trunc(nmb/262144);
    y := trunc((nmb - (x*262144))/4096);
    z := trunc(((nmb - (x*262144) - (y*4096)))/64);
    a := nmb - (x*262144) - (y*4096) - (z*64);
    return( base64(x) || base64(y) || base64(z) || '=');
  elsif length(fbytes) = 1
   then
    nmb := 65536*ascii(fbytes);
    x := trunc(nmb/262144);
    y := trunc((nmb - (x*262144))/4096);
    z := trunc(((nmb - (x*262144) - (y*4096)))/64);
    a := nmb - (x*262144) - (y*4096) - (z*64);
    return( base64(x) || base64(y) || '==');
  end if;

end conv_3bytes;

function conv_base64( vl in varchar2 )
 return varchar2
as
 retstr	varchar2(32767);
 ctr	integer;
begin
 ctr := 1;
 loop
  retstr := retstr || conv_3bytes(substr(vl,ctr,3));
  if ctr > 1000 then exit; end if;
  ctr := ctr + 3;
  if ctr > length(vl) then exit; end if;
 end loop;
 return( retstr );
end conv_base64;

procedure send_the_mail_smtp(fname in varchar2, p_from in varchar2, p_to in varchar2, p_subj in varchar2, is_sms in varchar2 DEFAULT 'FALSE', is_attachment in varchar2 default 'FALSE', infile in varchar2 default null )
as
    l_template      utl_file.file_type;
    l_output2       utl_file.file_type;
    p_body	    varchar2(32767);
    c		    utl_smtp.connection;
    at_step	    varchar2(20);
    x		    integer;
    ctr		    integer;
    lastctr	    integer;
    ctr2	    integer;
 un             varchar2(100);
 pw             varchar2(100);
 rp             utl_smtp.reply;

    procedure send_header(c in out utl_smtp.connection, name in varchar2, header in varchar2, nline in boolean default TRUE) as
     begin
      if nline
       then
        utl_smtp.write_data(c,name || ':' || header || utl_tcp.CRLF );
       else
        utl_smtp.write_data(c,name || ':' || header );
      end if;
    end;

    procedure pline(c in out utl_smtp.connection, bfr in varchar2, withlf in varchar2 default 'N' )
    as
     x integer;
    begin
     -- there seems to be a natural limit of 1000 characters in sending raw data
     if length(bfr) > 1000
      then
       x := instr(bfr,' ');
       if x > 0
        then
         pline(c, substr(bfr,1,x), withlf );
         pline(c, substr(bfr,x+1), withlf );
        else
         x := instr(bfr,'>');
         if x > 0
          then
           pline(c, substr(bfr,1,x), withlf );
           pline(c, substr(bfr,x+1), withlf );
          else
           if withlf = 'TRUEXCSV'
            then
             if trim(bfr) is not null then utl_smtp.write_data(c, utl_tcp.CRLF || replace(replace(bfr,chr(13),''),chr(11),'')); end if;
            else
             utl_smtp.write_data(c, utl_tcp.CRLF || bfr);
           end if;
         end if;
       end if;
      else
       if withlf = 'TRUEXCSV'
        then
         if trim(bfr) is not null then utl_smtp.write_data(c, utl_tcp.CRLF || replace(replace(bfr,chr(13),''),chr(11),'')); end if;
        else
         utl_smtp.write_data(c, utl_tcp.CRLF || bfr);
       end if;
     end if;
    end pline;

 begin
      at_step := 'Step1';
      c := utl_smtp.open_connection(glbx.extract_master_parameter('SMTP_SERVER')); -- SMTP Server

-- Added by Marcel 28th Aug 2006 for SMTP authentication
      un := glbx.extract_master_parameter('SMTP_SERVER_USERNAME');
      pw := glbx.extract_master_parameter('SMTP_SERVER_PASSWORD');
      if un is not null and pw is not null
       then
        rp := utl_smtp.command(c,'EHLO',glbx.extract_master_parameter('SMTP_SERVER'));
        rp := utl_smtp.command(c,'AUTH','LOGIN');
        rp := utl_smtp.command(c,conv_base64( un ),null);
        rp := utl_smtp.command(c,conv_base64( pw ),null);
       else
        utl_smtp.helo(c,glbx.extract_master_parameter('SMTP_SERVER') );
      end if;

-- End add of routine
      at_step := 'Step2';
      --utl_smtp.helo(c,glbx.extract_master_parameter('SMTP_SERVER') );
      at_step := 'Step2a';
      utl_smtp.mail(c,'<' || p_from || '>');
      at_step := 'Step3';

      if instr(p_to,',') > 0
       then
        x := 1;
        lastctr := 0;
        loop
         ctr := instr(p_to,',',1,x);
         if ctr = 0
          then
           utl_smtp.rcpt(c,'<' || trim(substr(p_to,lastctr+1)) || '>');
           exit;
         end if;
         utl_smtp.rcpt(c,'<' || trim(substr(p_to,lastctr+1,(ctr-lastctr)-1)) || '>');
         x := x + 1;
         lastctr := ctr;
        end loop;
       else
        utl_smtp.rcpt(c,'<' || trim(p_to) || '>');
      end if;

      at_step := 'Step4';
      utl_smtp.open_data(c);
      at_step := 'Step5';
      send_header(c, 'From','"' || p_from || '" <' || p_from || '>');

      at_step := 'Step6';
      if instr(p_to,',') = 0
       then
        send_header(c, 'To','"' || p_to || '" <' || replace(p_to,',','><') || '>');
       else
        send_header(c, 'To','"' || substr(p_to,1,instr(p_to,',')-1) || '" <' || replace(p_to,',','><') || '>');
      end if;

      at_step := 'Step7';
      if is_attachment in ('TRUE','TRUEX','TRUEXCSV','TRUEXXML')
       then
        send_header(c, 'Subject',p_subj,FALSE);
       else
        send_header(c, 'Subject',p_subj);
      end if;
      at_step := 'Step8';

      if is_sms = 'FALSE'
       then
        at_step := 'Step8a';
        l_template := utl_file.fopen( glbx.extract_master_parameter('MAIL_OUTPUT_DIR'), fname, 'r', 25000 );

        if is_attachment in ('TRUE','TRUEX','TRUEXCSV','TRUEXXML')
         then
          pline(c,'MIME-Version: 1.1');

          -- Display Mime Type Headers
          pline(c,'Content-Type: multipart/related; boundary="----=_UMO_ID_' || '3D2D4C15C6C7EF3943C2EE26' || '"');
          pline(c, null);
          pline(c, '------=_UMO_ID_' || '3D2D4C15C6C7EF3943C2EE26');
          if is_attachment in ('TRUEXCSV')
           then
            pline(c,'Content-Type: bad/type; charset="iso-8859-1"');
            pline(c,'Content-Disposition: attachment; filename=' || 'report_' || infile || '.csv' || utl_tcp.CRLF);
            pline(c, null);
          elsif is_attachment in ('TRUEXXML') or instr(upper(fname),'.XML') > 0
           then
            pline(c,'Content-Type: text/xml; charset="iso-8859-1"');
            pline(c,'Content-Transfer-Encoding: quoted-printable');
            pline(c, null);
          elsif is_attachment in ('TRUE','TRUEX')
           then
            pline(c,'Content-Type: text/html; charset="iso-8859-1"');
            pline(c,'Content-Transfer-Encoding: quoted-printable');
            pline(c, null);
          end if;

        end if;

        ctr2 := 0;
        loop
         begin
          ctr2 := ctr2 + 1;
          p_body := NULL;
          utl_file.get_line( l_template, p_body);
          if is_attachment = 'TRUE'
           then
            --p_body := replace(p_body, chr(13) || chr(10),'<BR>');
            p_body := replace(p_body,'  ','&nbsp;&nbsp;');
          end if;

          if is_attachment in ('TRUEX','TRUE','TRUEXCSV','TRUEXXML')
           then
            p_body := replace(replace(p_body,'=','=3D'),'  ',' =20');
          end if;

          if ctr2 = 1
           then
            utl_smtp.write_data(c, utl_tcp.CRLF || p_body);
           else
            if is_attachment in ('TRUEX','TRUE','TRUEXCSV','TRUEXXML')
             then
              --utl_smtp.write_data(c,nvl(p_body,' '));
              pline( c, nvl(p_body,' '),is_attachment);
             else
              utl_smtp.write_data(c,utl_tcp.CRLF || p_body);
            end if;
          end if;

          if is_attachment = 'TRUE'
           then
            utl_smtp.write_data(c,'<BR>');
          end if;

         exception
          when others
           then exit;
         end;
        end loop;
        utl_file.fclose( l_template );
      end if;

      if is_attachment in ('TRUE','TRUEX','TRUEXCSV','TRUEXXML')
       then
         pline( c, '------=_UMO_ID_' || '3D2D4C15C6C7EF3943C2EE26' || '--' );
      end if;

      at_step := 'Step9';
      utl_smtp.close_data(c);
      utl_smtp.quit(c);

      --l_output2 := utl_file.fopen( glbx.extract_master_parameter('MAIL_OUTPUT_DIR'), 'mail_sendto.log', 'a', max_linesize=>32767 );
      --utl_file.put_line(l_output2,'Sent Email to' || ':' || glbx.extract_master_parameter('SMTP_SERVER') || ':' || 'From' || ':' || p_from || ' ' || 'To' || ':' || p_to || ' ' || p_subj );
      if is_sms = 'TRUE'
       then
         add_email_log('SMS SEND',infile || ' : ' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || glbx.extract_master_parameter('SMTP_SERVER'),fname,p_from,p_to,p_subj,is_sms,at_step,null);
        else
         add_email_log('EMAIL SEND',infile || ' : ' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || glbx.extract_master_parameter('SMTP_SERVER'),fname,p_from,p_to,p_subj,is_sms,at_step,null);
      end if;
      --utl_file.put_line(l_output2,'---');
      --utl_file.fclose( l_output2 );

  exception
   when others
    then
     add_email_log('ERROR ON SEND', infile || ' : ' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || glbx.extract_master_parameter('SMTP_SERVER'),fname,p_from,p_to,p_subj,is_sms,at_step,sqlerrm);
     /*
     l_output2 := utl_file.fopen( glbx.extract_master_parameter('MAIL_OUTPUT_DIR'), 'mail_sendto.log', 'a' );
     utl_file.put_line(l_output2, 'Unable to send email. Issue contacting Mail Server (see error message below):' || glbx.extract_master_parameter('SMTP_SERVER'));
     utl_file.put_line(l_output2, 'Mail File:' || fname);
     utl_file.put_line(l_output2, 'From:' || p_from);
     utl_file.put_line(l_output2, 'To:' || p_to);
     utl_file.put_line(l_output2, 'Subject:' || p_subj);
     utl_file.put_line(l_output2, 'Is SMS:' || is_sms);
     utl_file.put_line(l_output2, 'At Step:' || at_step);
     utl_file.put_line(l_output2,  sqlerrm);
     utl_file.put_line(l_output2,  '---');
     utl_file.fclose( l_output2 );
    */
end send_the_mail_smtp;

procedure add_email_log(v_disp_type in varchar2, v_template in varchar2, v_mail_file in varchar2, v_mail_from in varchar2, v_mail_to in varchar2, v_mail_subject in varchar2, v_is_sms in varchar2, v_at_step in varchar2, v_error in varchar2)
as
 s_mail_to	varchar2(4000);
begin
 s_mail_to := substr(v_mail_to,1,4000);
 insert into email_log(date_created,disp_type,template,mail_file,mail_from,mail_to,mail_subject,is_sms,at_step,error)
  values
   (sysdate,v_disp_type,v_template,v_mail_file,v_mail_from,s_mail_to,v_mail_subject,v_is_sms,v_at_step,v_error);
 commit;
end add_email_log;

procedure merge_template( gcode	 in GLBX.MYARRAY, gparam in GLBX.MYARRAY, infile in varchar2, is_sms in boolean, is_report in boolean, fname in out varchar2, type_of in varchar2, tname in varchar2, job in out varchar2, printer in varchar2, extension in varchar2, v_attachment in out varchar2)
as

    --cursor c2(v_umo integer) is select doc_html from umo where umo_id = v_umo;
    cursor c2(repid integer) is select doc_html from umo where umo_id = repid;

    c2rec	      c2%ROWTYPE;
    l_output          utl_file.file_type;
    l_template        utl_file.file_type;
    l_body            varchar2(32767);
    p_body	      varchar2(32767);
    nxtnum	      varchar2(1024);
    v_buffer	      varchar2(32767);
    v_count	      integer;
    v_int	      integer;
    nmb		      integer;
    n_step        varchar2(200); -- added by David Banjo

 procedure add_line( type_of in varchar2, fl in out utl_file.file_type, tname in varchar2, job in varchar2, is_report in boolean, vbuffer in varchar2 )
 as
  nmb	integer;
  bfr1	varchar2(4000);
  bfr2	varchar2(4000);
  bfr3	varchar2(4000);
  bfr4	varchar2(4000);
  bfr5	varchar2(4000);
  bfr6	varchar2(4000);
  bfr7	varchar2(4000);
  bfr8	varchar2(4000);
  bfr9	varchar2(4000);
 begin
  if type_of = 'FILE'
   then
    if is_report
     then
      utl_file.put(fl, vbuffer );
     else
      utl_file.put_line(fl, vbuffer );
    end if;

   else

    select s_workflow_insert_counter.nextval into nmb from dual;
    if nvl(length(vbuffer),0) <= 4000
     then
      execute immediate
       'insert into ' || tname || '_data (job,ctr,buffer) values (:1,:2,:3)'
       using job, nmb, vbuffer;
     else
      bfr1 := substr(vbuffer,1,4000);
      bfr2 := substr(vbuffer,4001,4000);
      bfr3 := substr(vbuffer,8001,4000);
      bfr4 := substr(vbuffer,12001,4000);
      bfr5 := substr(vbuffer,16001,4000);
      bfr6 := substr(vbuffer,20001,4000);
      bfr7 := substr(vbuffer,24001,4000);
      bfr8 := substr(vbuffer,28001,4000);
      bfr9 := substr(vbuffer,32001,4000);
      execute immediate
       'insert into ' || tname || '_data (job,ctr,buffer,buffer2,buffer3,buffer4,buffer5,buffer6,buffer7,buffer8,buffer9) values (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11)'
       using job, nmb, bfr1, bfr2, bfr3, bfr4, bfr5, bfr6, bfr7, bfr8, bfr9;
    end if;
  end if;
 exception
  when others then  -- Ignore the insert error. Every hard to trap.
   add_email_log('ERROR ADD_LINE','TNAME:' || tname || '_data Length:' || nvl(length(vbuffer),0),tname,null,null,null,null,'TEMPLATE',sqlerrm );
   --glbx.error_details( 'GLBX', 'ADD_LINE',errmsg=>sqlerrm,extdet=>'TNAME:' || tname || '_data Length:' || nvl(length(vbuffer),0));
 end add_line;

 -- Eventually to be replace with call to retrieve the template from the UMO table
 procedure extract_template_line( fl in out utl_file.file_type, vbuffer out varchar2 )
 as
 begin
   utl_file.get_line(fl,vbuffer);
 end extract_template_line;

begin
  n_step := '1a ';
  select ltrim(to_char(mailto_seq.nextval,'0000009')) into nxtnum from dual;
  fname := 'M' || nxtnum  || '.txt';

  if not is_sms
   then
    n_step := '2a ';
    if is_report
     then
      n_step := '2aa ';
      begin nmb := to_number( infile ); exception when others then nmb := NULL; end;
      if nmb is not null
       then
        if type_of = 'FILE'
         then
          n_step := '3a ';
          l_output := utl_file.fopen( glbx.extract_master_parameter('MAIL_OUTPUT_DIR'), fname, 'w', max_linesize=>32767 );
          n_step := '4a ';
        end if;
        open c2( to_number(infile) );
        fetch c2 into c2rec;
        if c2%NOTFOUND then close c2; utl_file.fclose( l_output ); return; end if;
        close c2;
        if dbms_lob.getlength( c2rec.doc_html ) = 0 then utl_file.fclose( l_output ); return; end if;
        v_count := 0;
        v_int := 32767;
        begin
          loop
           dbms_lob.read(c2rec.doc_html,v_int,(v_count*32767)+1,v_buffer);
           v_count := v_count + 1;
           --utl_file.put( l_output,v_buffer );
           add_line(type_of,l_output,tname,job,is_report,v_buffer);
         end loop;
        exception
         when no_data_found then null;
        end;
        if type_of = 'FILE'
         then
          utl_file.fclose( l_output );
        end if;

       else

        fname := infile;

      end if;

     else
      n_step := '5aa ';
      -- Attach extension to filename to give a variety of options
      if extension is null
       then

        begin
        n_step := '5aaa '||infile||' ';
        if upper(glbx.extract_fname(infile, 'SUFFIX' )) = 'TMP'
         then
          n_step := '5a ';
          l_template := utl_file.fopen( glbx.extract_master_parameter('MAIL_TEMPLATE_DIR'),
                                        glbx.extract_fname(infile, 'NO_EXTENSION') || '.' || 'html', 'r', max_linesize=>32767 );
          v_attachment := 'TRUE';
         else
           n_step := '5aaa '||infile||' '||glbx.extract_master_parameter('MAIL_TEMPLATE_DIR');
          l_template := utl_file.fopen( glbx.extract_master_parameter('MAIL_TEMPLATE_DIR'), infile, 'r', max_linesize=>32767 );
          v_attachment := 'TRUE';
        end if;
        exception
         when others then
          l_template := utl_file.fopen( glbx.extract_master_parameter('MAIL_TEMPLATE_DIR'), infile, 'r', max_linesize=>32767 );
          v_attachment := 'FALSE';
        end;

       else

        begin
         n_step := '6a ';
         if upper(glbx.extract_fname(infile, 'SUFFIX' )) = 'TMP'
          then
           begin
            n_step := '7a ';
            l_template := utl_file.fopen( glbx.extract_master_parameter('MAIL_TEMPLATE_DIR'),
                                          glbx.extract_fname(infile, 'NO_EXTENSION') || extension || '.' || '.html',
                                          'r', max_linesize=>32767 );
           v_attachment := 'TRUE';
           exception
           when others then
            l_template := utl_file.fopen( glbx.extract_master_parameter('MAIL_TEMPLATE_DIR'),
                                          glbx.extract_fname(infile, 'NO_EXTENSION') || extension || '.' || glbx.extract_fname(infile, 'SUFFIX' ),
                                          'r', max_linesize=>32767 );
            v_attachment := 'FALSE';
           end;
          else
           l_template := utl_file.fopen( glbx.extract_master_parameter('MAIL_TEMPLATE_DIR'),
                                         glbx.extract_fname(infile, 'NO_EXTENSION') || extension || '.' || glbx.extract_fname(infile, 'SUFFIX' ),
                                         'r', max_linesize=>32767 );
           v_attachment := 'TRUE';
         end if;

        exception
         when others then
          -- If it fails, its because it cant find it. Go to the default.
          n_step := '8a ';
          l_template := utl_file.fopen( glbx.extract_master_parameter('MAIL_TEMPLATE_DIR'), infile, 'r', max_linesize=>32767 );
          v_attachment := 'FALSE';
        end;

      end if;

     if type_of = 'FILE'
       then
       n_step := '9a ';
        l_output := utl_file.fopen( glbx.extract_master_parameter('MAIL_OUTPUT_DIR'), fname, 'w', max_linesize=>32767 );
       else
        select s_workflow_insert_counter.nextval into job from dual;
        execute immediate
        'insert into ' || tname || '(job,is_printed,subject,printer,timestamp) values (:1,:2,:3,:4,sysdate)'
        using job, 'F', infile, printer;
      end if;

      loop
       begin
        p_body := NULL;
        extract_template_line(l_template,p_body);
        for j in gcode.first..gcode.last loop
         if gcode(j) = 'SIGNATURE' and gparam(j) is null
          then
           p_body := replace( p_body, '<' || gcode(j) || '>', glbx.extract_master_parameter('MAIL SIGNATURE'));
          else
           p_body := replace( p_body, '<' || gcode(j) || '>', gparam(j));
         end if;
        end loop;
        --utl_file.put_line( l_output,p_body);
        add_line(type_of,l_output,tname,job,is_report,p_body);
       exception
        when others
         then exit;
      end;
     end loop;
     if type_of = 'FILE'
      then
       utl_file.fclose( l_output );
     end if;
     utl_file.fclose( l_template );
   end if;
 end if;

exception
 when utl_file.invalid_path
  then
   --glbx.error_details( 'GLBX', 'MERGE_TEMPLATE',errmsg=>'Cannot find file',extdet=>'Infile: ' || glbx.extract_master_parameter('MAIL_TEMPLATE_DIR') || '-' || infile || ' FNAME:' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || fname);
   add_email_log('ERROR MERGE TEMPLATE',n_step||'1 Cannot find file',
                 'Infile: ' || glbx.extract_master_parameter('MAIL_TEMPLATE_DIR') || '-' || infile || ' FNAME:' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || fname,
                 fname,null,infile,null,'MERGE_TEMPLATE','Invalid Path:' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || fname );
 when utl_file.write_error then
   --glbx.error_details( 'GLBX', 'MERGE_TEMPLATE',errmsg=>'Write Error',extdet=>'Infile: ' || glbx.extract_master_parameter('MAIL_TEMPLATE_DIR') || '-' || infile || ' FNAME:' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || fname);
   add_email_log('ERROR MERGE TEMPLATE',n_step||'2 Cannot find file',
                 'Infile: ' || glbx.extract_master_parameter('MAIL_TEMPLATE_DIR') || '-' || infile || ' FNAME:' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || fname,
                 fname,null,infile,null,'MERGE_TEMPLATE','Write Error' );
 when utl_file.internal_error then
   --glbx.error_details( 'GLBX', 'MERGE_TEMPLATE',errmsg=>'Internal Error',extdet=>'Infile: ' || glbx.extract_master_parameter('MAIL_TEMPLATE_DIR') || '-' || infile || ' FNAME:' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || fname);
   add_email_log('ERROR MERGE TEMPLATE',n_step||'3 Cannot find file',
                 'Infile: ' || glbx.extract_master_parameter('MAIL_TEMPLATE_DIR') || '-' || infile || ' FNAME:' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || fname,
                 fname,null,infile,null,'MERGE_TEMPLATE','Internal Error' );
 when others then
   --glbx.error_details( 'GLBX', 'MERGE_TEMPLATE',errmsg=>sqlerrm,extdet=>'Infile: ' || infile || ' FNAME:' || fname);
   add_email_log('ERROR MERGE TEMPLATE',n_step||'4 Cannot find file',
                 'Infile: ' || glbx.extract_master_parameter('MAIL_TEMPLATE_DIR') || '-' || infile || ' FNAME:' || glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || fname,
                 fname,null,infile,null,'MERGE_TEMPLATE',sqlerrm );
end merge_template;

function get_thm( acid in integer )
 return THEME%ROWTYPE
as
 cursor c1(acid integer) is select * from theme where theme_name in (select theme_name from customer_account where aid = acid);
 c1rec	THEME%ROWTYPE;
begin
 open c1(acid);
 fetch c1 into c1rec;
 close c1;
 return( c1rec );
exception when others then
 glbx.error_details( 'GLBX', 'GET_THM',vaid=>acid,errmsg=>sqlerrm);
end get_thm;

function get_thm( thm in varchar2 )
 return THEME%ROWTYPE
as
 cursor c1(thm varchar2) is select * from theme where theme_name = thm;
 c1rec	THEME%ROWTYPE;
begin
 open c1(thm);
 fetch c1 into c1rec;
 close c1;
 return( c1rec );
exception when others then
 glbx.error_details( 'GLBX', 'GET_THM',errmsg=>sqlerrm, extdet=>thm);
end get_thm;

function get_sfx( sess_id in integer )
 return varchar2
as
 pfx	THEME.DISP_PREFIX%TYPE;
begin
 pfx := 'w_d_'; -- Default Value
 open sPfx( sess_id );
 fetch sPfx into pfx;
 close sPfx;
 return( pfx );
exception when others then
 glbx.error_details( 'GLBX', 'GET_SFX',errmsg=>sqlerrm,extdet=>'Sess Id:' || sess_id);
end get_sfx;

function  get_hfx( phgid in integer )
 return varchar2
as
begin
 return( 'w_d_' );
exception when others then
 glbx.error_details( 'GLBX', 'GET_HFX',phgid,errmsg=>sqlerrm);
 end get_hfx;

function adjust_for_http( http_address in varchar2 )
 return varchar2
as
begin
 if upper(substr(http_address,1,7)) = 'HTTP://'
  then
   return( http_address );
  else
   return( 'http://' || http_address );
 end if;
end adjust_for_http;

function  photo_lf( ownid in integer )
 return THEME%ROWTYPE
as

 cursor c1(ownid integer) is select top_frame_lf from photographer where pid = ownid;
 cursor c2(tname varchar2) is select * from theme where theme_name = tname;
 cursor c3(mfid integer) is select theme_name from manufacturer where manufacturer_id = mfid;

 c1rec	c1%ROWTYPE;
 c2rec	c2%ROWTYPE;

begin
 open c1(ownid);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   open c3(ownid);
   fetch c3 into c1rec;
   if c3%NOTFOUND
    then
     c1rec.top_frame_lf := DECS.DEFAULT_PHG_THEME;
   end if;
   close c3;
 end if;
 close c1;
 open c2(c1rec.top_frame_lf);
 fetch c2 into c2rec;
 close c2;
 return( c2rec );
end photo_lf;

procedure redisplay_login_page( msg in varchar2, nodisplay in boolean default FALSE, extra_parameter in varchar2 default null )
as
begin
 htp.init;
 if glbx.extract_master_parameter('ON_LOGOUT_API') is not null
  then
   begin
    execute immediate
     'begin ' || glbx.extract_master_parameter('ON_LOGOUT_API') || '(extra_parameter=>:extra_parameter); end;'
     using extra_parameter;
    return;
   exception
    when others then null;
   end;
 end if;

 htp.htmlopen;
 if nodisplay
  then
   htp.bold( msg );
   htp.htmlclose;
   return;
 end if;
 htp.header(2, LNG.GLB_TXT_001, 'CENTER' );
 htp.nl;
 htp.header(3, msg, 'CENTER' );
 htp.nl;
 htp.header(4, LNG.GLB_TXT_002, 'CENTER' );
 htp.nl;
 htp.p( '<CENTER>' );
 login_page;

end redisplay_login_page;

function mbar( surl varchar2, mttle varchar2 )
 return varchar2
as

 cursor c1(surl varchar2, mttle varchar2 ) is
  select value
  from photographer_preference pp, login_session ls, all_preferences ap
  where ls.securl = surl and
        ls.login_type in ('OWNER','CUSTOMER') and
        ls.aid = pp.aid and
        preference_name = mttle and
        ap.prefid = pp.prefid
 union all
  select value
  from photographer_preference pp, login_session ls, customer_profile cp, all_preferences ap
  where ls.securl = surl and
        ls.login_type in ('PROFILE','PROFILEG') and
        ls.aid = cp.profile_id and
        cp.aid = pp.aid and
        preference_name = mttle and
        ap.prefid = pp.prefid;

 c1rec c1%ROWTYPE;

begin
 open c1(glbx.truncsurl(surl),mttle);
 fetch c1 into c1rec;
 close c1;
 return( c1rec.value );
end mbar;

procedure main_title( surl varchar2, ttl in varchar2, bodyb in varchar2 default null, helpid in varchar2 default null, stype in integer default 1,
                      sstyle in varchar2 default 'Times New Roman', sclr in varchar2 default 'fffccc', lnk in varchar2 default 'ACTIVE',
                      det_sstyle in varchar2 default 'Arial', det_sclr in varchar2 default '000000', det_font in varchar2 default 'ffffff',
                      h2_sstyle in varchar2 default null, h2_sclr in varchar2 default null, hover in varchar2 default 'C0C0C0', disptop in varchar2 default 'F',
                      finc in integer default 0, errclr in varchar2 default 'FF0000', errfnt in varchar2 default 'Times New Roman', instclr in varchar2 default '0000FF', instfnt in varchar2 default 'Arial', instfntinc in integer default 0,
                      jscript in varchar2 default null, title_only in boolean DEFAULT FALSE, excolour in varchar2 default null, exfont in varchar2 default null, ltype in varchar2 default null, small_link in boolean default FALSE,
                      my_class in varchar2 default null, my_font in varchar2 default null, my_size in varchar2 default null, my_colour in varchar2 default null,
                      icra_label in varchar2 default null, top_padding in integer default 5, left_padding in integer default 5, uline in varchar2 default null, sim_three_frame in char default 'F',
                      uline_active in varchar2 default null, uline_visited in varchar2 default null, retlink in varchar2 default null, ispopup in boolean default FALSE, stylesh in varchar2 default null)
as

 fsize			integer;
 lnkh			varchar2(40);
 smlsz			integer;
 expanded_scenes	GLBX.MYARRAY;

begin

 if lnk = 'ACTIVE'
  then
   lnkh := NULL;
  else
   lnkh := '; Text-Decoration : None';
 end if;

 fsize := 8 + trunc(stype/1.5) + nvl(finc,0);

 if small_link
  then
   smlsz := greatest(fsize - 2,1);
  else
   smlsz := fsize;
 end if;


 htp.p('<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">' );

 htp.htmlopen;
   htp.p( '<HEAD>' );

/* Included here for testing purposes
 htp.p( '<STYLE type="text/css">
<!--
    BODY  {  background-color: #FFFFFF;
             color: #00000;
             font-family: "Arial";}

    A:link { font-family: ' || sstyle || '; font-size: ' || smlsz || 'pt; color : ' || '#' || nvl(uline,sclr) || ' ' || lnkh || ';}
    A:visited  {  color: #000000; text-decoration: underline;}
    A:hover    {  color: #FFFFFF; text-decoration: underline;}

-->
</STYLE>
 ');
*/

-- ' A:link { font-family:  ' || sstyle || ' ; font-size: ' || smlsz || 'pt; color :  ' || '#' || nvl(uline,sclr) || '  ' || lnkh || ';}' ||
-- ' A:active { font-family:  ' || sstyle || ' ; font-size: ' || smlsz || 'pt; color :  ' || '#' || nvl(uline_active,nvl(uline,sclr)) || '  ' || lnkh || ';}' ||
-- ' A:visited { font-family:  ' || sstyle || ' ; font-size: ' || smlsz || 'pt; color :  ' || '#' || nvl(uline_visited,nvl(uline,sclr)) || '  ' || lnkh || ';}' ||
-- ' A:hover { font-family:  ' || sstyle || ' ; font-size: ' || smlsz || 'pt; color :  ' || '#' || hover || ' ;}' ||

if stylesh is null
 then
 htp.p(' <style TYPE="text/css"><!-- ' ||
 'P { page-break-after: auto; }' ||
 ' A:link { font-family:  ' || sstyle || ' ; color :  ' || '#' || nvl(uline,sclr) || '  ' || lnkh || ';}' ||
 ' A:active { font-family:  ' || sstyle || ' ; color :  ' || '#' || nvl(uline_active,nvl(uline,sclr)) || '  ' || lnkh || ';}' ||
 ' A:visited { font-family:  ' || sstyle || ' ; color :  ' || '#' || nvl(uline_visited,nvl(uline,sclr)) || '  ' || lnkh || ';}' ||
 ' A:hover { font-family:  ' || sstyle || ' ; color :  ' || '#' || hover || ' ;}' ||
 ' TD.HEADWHITE {font-size: ' || to_char(fsize+6) || 'pt; font-family:  ' || det_sstyle || ' ; color:  #' || det_font || ' ; text-align: center;}' ||
 ' TD.EXFONT {font-size: ' || to_char(fsize) || 'pt; font-family:  ' || exfont || ' ; color:  #' || excolour || ' ;}' ||
 ' BODY{font-size: ' || fsize || 'pt; font-family:  ' || sstyle || ' ; color:  #' || sclr || ' ;}' ||
 ' H1  {font-family:  ' || sstyle || ' ; font-size: ' || to_char(fsize + 6) || 'pt; color:  #' || sclr || ' ;}' ||
 ' H2  {font-family:  ' || nvl(h2_sstyle,sstyle) || ' ; font-size: ' || to_char(fsize + 6) || 'pt; color:  #' || h2_sclr || ' ;}' ||
 ' H2.ERROR {font-family:  ' || nvl(errfnt,sstyle) || ' ; font-size: ' || to_char(fsize + 6) || 'pt; color:  #' || errclr || ' ;}' ||
 ' H3  {font-family:  ' || sstyle || ' ; font-size: ' || to_char(fsize + 4) || 'pt; color:  #' || sclr || ' ;}' ||
 ' H4  {font-family:  ' || sstyle || ' ; font-size: ' || to_char(fsize + 2) || 'pt; color:  #' || sclr || ' ;}' ||
 ' H5  {font-family:  ' || sstyle || ' ; font-size: ' || to_char(fsize + 1) || 'pt; color:  #' || sclr || ' ;}' ||
 ' H6  {font-family:  ' || sstyle || ' ; font-size: ' || to_char(fsize - 2) || 'pt; font-style: italic; color:  #' || sclr || ' ;}' ||
 ' H6.INSTRUCTION  {font-family:  ' || instfnt || ' ; font-size: ' || to_char(fsize + nvl(instfntinc,0)) || 'pt; color:  #' || instclr || ' ;}' ||
 ' TD  {font-family:  ' || sstyle || ' ; font-size: ' || fsize || 'pt; color:  #' || sclr || ' ; text-align: left;}' ||
 ' TD.SMALL  {font-family:  ' || sstyle || ' ; font-size: ' || to_char(greatest(0,fsize - 2)) || 'pt; color:  #' || sclr || ' ;}' ||
 ' SMALL  {font-family:  ' || sstyle || ' ; font-size: ' || to_char(greatest(0,fsize - 2)) || 'pt; color:  #' || sclr || ' ;}' ||
 ' SUP {font-family:  ' || sstyle || ' ; font-size: ' || fsize || 'pt; color:  #' || sclr || ' ;}' ||
 ' DIV {font-family:  ' || sstyle || ' ; font-size: ' || fsize || 'pt; color:  #' || sclr || ' ;}' ||
 nvl(my_class,'MYCLASS') || '{font-family:  ' || nvl(my_font,sstyle) || ' ; font-size: ' || nvl(my_size,fsize) || 'pt; color:  #' || nvl(my_colour,sclr) || ' ;}' ||
 '--> </style>' );
else
 htp.p( '<link rel="stylesheet" href="/images/site_specific/' || stylesh || '">' );
end if;

 -- Meta Heading containing code allowing access to site as specified by Internet Content Rating Association
 if icra_label is not null or jscript = 'DISABLE'
  then
   if icra_label is not null then htp.p(icra_label); end if;
   if jscript = 'DISABLE'then htp.p( '<meta http-equiv="imagetoolbar" content="no">' ); end if;
 end if;

 if disptop = 'N' and not title_only and nvl(ltype,'!') <> 'PHOTOGRAPHER'
  then
   htp.title( nvl(ttl, nvl( mbar( surl, 'MENU_BAR' ),glbx.extract_master_parameter('BAR_TITLE')) ));
   htp.p( substr(bodyb,1,length(bodyb)-1) ||  ' TOPMARGIN="' || top_padding || '" LEFTMARGIN="' || left_padding || '">');
   cst.acct_topx(surl, stype, 'T', ttl, helpid);
 end if;
 --htp.p( '</HEAD>' );

 if jscript is not null and not title_only
  then
    if jscript = 'DISABLE'
     then
       htp.p('<SCRIPT LANGUAGE="JavaScript">
              function click(e) {
              var message="' || LNG.GLB_TXT_104 || '";
              if ( navigator.appName.substring ( 0, 9 ) == "Microsoft") {
              if (event.button == 2) {
              alert(message);
              return false;
              }
              }
              if (document.layers || navigator.appName.substring ( 0, 9 ) == "Netscape") {
              if (e.which==3) {
              alert(message);
              return false;
              }
              }
              }

function trap()
  {
  if(document.images)
    {
    for(i=0;i<document.images.length;i++)
      {
      document.images[i].onmousedown = click;
      document.images[i].onmouseup = click;
      }
    }
  }
// End -->
</SCRIPT>');
       htp.p( '</HEAD>' );
       if bodyb is not null
        then
         htp.p( substr(bodyb,1,length(bodyb)-1) || ' TOPMARGIN="' || top_padding || '" LEFTMARGIN="' || left_padding || '"' || ' MARGINHEIGHT="' || top_padding || '" MARGINWIDTH="' || left_padding || '" onload="trap()">');
        else
         htp.p( '<BODY TOPMARGIN="' || top_padding || '" LEFTMARGIN="' || left_padding || '" onload="trap()">');
       end if;
     else
       htp.print(jscript);
       htp.print( substr(bodyb,1,length(bodyb)-1) || ' TOPMARGIN="' || top_padding || '" LEFTMARGIN="' || left_padding || '"' || ' MARGINHEIGHT="' || top_padding || '" MARGINWIDTH="' || left_padding || '">');
    end if;
  else
   htp.p( '</HEAD>' );
   if bodyb is not null
    then
     htp.print( substr(bodyb,1,length(bodyb)-1) || ' TOPMARGIN="' || top_padding || '" LEFTMARGIN="' || left_padding || '"' || ' MARGINHEIGHT="' || top_padding || '" MARGINWIDTH="' || left_padding || '">');
    else
     htp.p( '<BODY TOPMARGIN="' || top_padding || '" LEFTMARGIN="' || left_padding || '"' || ' MARGINHEIGHT="' || top_padding || '" MARGINWIDTH="' || left_padding || '">' );
   end if;
 end if;
--              function trap() { if(document.images) for (i=0;i<document.images.length;i++) document.images[i].onmousedown = right; document.images[i].onmouseup = right; }

if disptop <> 'N' or nvl(ltype,'!') = 'PHOTOGRAPHER' or ispopup
 then
  if ttl is null then return; else htp.p( '<CENTER>' ); end if;
  htp.tableopen( cattributes=>'width="100%" cellpadding=0 cellspacing=0 border=0' );
   htp.tablerowopen;
    if retlink is not null
     then
      htp.tabledata( retlink, cattributes=>'bgcolor="#' || det_sclr || '" valign="MIDDLE" align="LEFT" width="5%" CLASS="HEADWHITE"' );
    end if;
    htp.tabledata('<b>&nbsp;'|| ttl || '</b>',cattributes=>'bgcolor="#' || det_sclr || '" valign="MIDDLE" align="CENTER" CLASS="HEADWHITE"');
    if helpid is not null
     then
      htp.tabledata( htf.anchor2( 'glbx.show_help?surl=' || glbx.rndsurl(surl) || '&helpid=' || helpid,htf.img( DECS.IMAGE_LOCATION || 'admin/help.gif',cattributes=>' border=0',calt=>LNG.GLB_ALT_071),ctarget=>'HELP_WINDOW' ),
                     cattributes=>'bgcolor="#' || det_sclr || '" valign="MIDDLE" align="CENTER" width="5%" CLASS="HEADWHITE"');
    end if;
   htp.tablerowclose;
  htp.tableclose;
  htp.p( '</CENTER>' );
end if;

if title_only
 then
  if ttl is null then return; else htp.p( '<CENTER>' ); end if;
  htp.tableopen( cattributes=>'width="100%" cellpadding=0 cellspacing=0 border=0' );
   htp.tablerowopen;
   htp.tabledata('<FONT SIZE="+2">' || ttl || '</FONT>',cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   htp.tablerowclose;
  htp.tableclose;
  htp.p( '</CENTER>' );
end if;

if nvl(disptop,'L') not in ('L','R') and sim_three_frame = 'T'
 then
  htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' ); -- Replace with Frame Calls
  htp.tablerowopen;
  htp.p( '<TD VALIGN="TOP">' );
  cst.acct_leftx( surl, null, expanded_scenes, null, null  ); -- Add later: expanded_scenes, left_api, left_api_parm
  htp.p( '</TD>' );
  htp.p( '<TD VALIGN="TOP">' );
end if;

exception when others then
 glbx.error_details( 'GLBX', 'MAIN_TITLE',errmsg=>sqlerrm, extdet=>'TTL:' || ttl);
end main_title;

procedure close_page( pfx in THEME%ROWTYPE )
as
begin

 if pfx.keep_lhf not in ('L','R') and pfx.sim_three_frame = 'T'
  then
   htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tableclose;
   htp.p( '</BODY>' );
   htp.htmlclose;
  else
   htp.p( '</BODY>' );
   htp.htmlclose;
 end if;

end close_page;

procedure logon_user( un in varchar2, pw in varchar2, sts out varchar2, session_id out integer, stype out integer, Click_To_Login in varchar2 default null, em in varchar2 default null, un_email in char default 'F', job in varchar2 default null, surl out varchar2, country in varchar2 default null, existing_sessid_is in integer default null )
  as

   cursor c1(un varchar2) is select * from customer_account where upper(username) = un and aid > 0;
   cursor c1p(un varchar2) is select * from customer_profile where upper(username) = un and aid > 0;
   cursor c2(un varchar2) is select * from photographer where upper(username) = un;
   cursor c3a(un varchar2, job varchar2) is select vl.aid,vl.password,vl.client_id from virtual_logon vl, customer_account ca where vl.username = un and ca.aid = vl.aid and upper(photographer_account_id) = job;
   cursor c3b(un varchar2) is select vl.aid,vl.password,vl.client_id from virtual_logon vl where vl.username = un;
   cursor c3c(acid integer) is select * from customer_account where aid = acid;
   cursor c4(phgid integer) is select restrict_to_ip_address from photographer where pid = phgid;
   cursor c5(un varchar2) is select * from manufacturer where upper(username) = un;
   cursor c6(ttype varchar2) is select theme_data from theme_types where theme_type = ttype;
   cursor c8(hostip varchar2) is select 'x' from track_ip_address where hostip like replace(ip_address,'*','%');
   cursor c9(ltype varchar2, acid integer) is select contact_email,sendto_country from customer_contact where login_type = ltype and aid = acid;
   cursor c10(ltype varchar2, acid integer) is select sessid from login_session where login_type = ltype and aid = acid order by date_created desc;
   cursor c10a(ltype varchar2, acid integer, clid integer) is select sessid from login_session where login_type = ltype and aid = acid and event_id = clid order by date_created desc;
   cursor c11(ltype varchar2, acid integer) is select sendto_country,contact_id,contact_email from customer_contact where login_type = ltype and aid = acid;

   c1rec	c1%ROWTYPE;
   c1prec	c1p%ROWTYPE;
   c2rec	c2%ROWTYPE;
   c3rec	c3a%ROWTYPE;
   c4rec	c4%ROWTYPE;
   c5rec	c5%ROWTYPE;
   c6rec	c6%ROWTYPE;
   c8rec	c8%ROWTYPE;
   c11rec	c11%ROWTYPE;
   voidrec	order_style%ROWTYPE;
   is_customer	varchar2(100) := 'CUSTOMER';
   id		integer;
   owner_id	integer;
   check_pw	varchar2(100);
   vdcid	integer;
   hostip	varchar2(100);
   xsurl	varchar2(100);
   cust_em	varchar2(100);
   cntry	varchar2(100);
   bypass_pw	char(1);
   prev_sess	integer;
   b2c_value	char(1);
   xlrec	login_session%ROWTYPE;
   def_cntry	varchar2(100);
   xxval        varchar2(1000);

  begin
   if glbx.extract_master_parameter('COOKIE_ENABLED') = 'TRUE'
    then
      xsurl := piction_cookie( xlrec );
      owa_cookie.remove(nvl(glbx.extract_master_parameter('COOKIE_NAME'),'PICTION_COOKIE'), xsurl);
   end if;
   sts := NULL;
   stype := 1;
   bypass_pw := 'F';
   -- Check Virtual Logon if Job Supplied
   if job is not null
    then
     open c3a(upper(trim(un)),upper(job));
     fetch c3a into c3rec;
     if c3a%NOTFOUND
      then
       close c3a;
       sts := LNG.GLB_TXT_003;
       note_invalid_access(upper(trim(un)),pw,upper(job));
       return;
     end if;
     close c3a;
     is_customer := 'VIRTUAL';
     owner_id := c3rec.aid;
     check_pw := c3rec.password;
     open c3c( c3rec.aid);
     fetch c3c into c1rec;
     close c3c;
     -- Make sure the Photographer has indicated that this account is to Event Based. If not reject the logon
     if nvl(c1rec.site_type,'S') = 'S' then sts := LNG.GLB_TXT_003; note_invalid_access(upper(trim(un)),pw,upper(job)); return; end if;
    else
     -- Check if Manufacturer
     open c5(upper(trim(un)));
     fetch c5 into c5rec;
     if c5%NOTFOUND
      then
        -- Check if Customer Account
        open c1(upper(trim(un)));
        fetch c1 into c1rec;
        if c1%NOTFOUND
         then
          close c1;
          -- Check if Profile
	  open c1p(upper(trim(un)));
	  fetch c1p into c1prec;
	  if c1p%NOTFOUND
	   then
	     -- Check Photographer
	     open c2(upper(trim(un)));
	     fetch c2 into c2rec;
	     if c2%NOTFOUND
	      then
	       close c2;
	       -- Check Virtual Logon without Job
	       open c3b(upper(trim(un)));
	       fetch c3b into c3rec;
	       if c3b%NOTFOUND
	        then
	         close c3b;
	         sts := LNG.GLB_TXT_003;
                 note_invalid_access(upper(trim(un)),pw,upper(job));
	         return;
	        else
                 is_customer := 'VIRTUAL';
                 owner_id := c3rec.aid;
                 check_pw := c3rec.password;
                 open c3c( c3rec.aid );
                 fetch c3c into c1rec;
                 close c3c;
                 -- Make sure the Photographer has indicated that this account is to Event Based. If not reject the logon
                 if nvl(c1rec.site_type,'S') = 'S' then sts := LNG.GLB_TXT_003; note_invalid_access(upper(trim(un)),pw,upper(job)); return; end if;
                 -- If a NULL job code was provided, then it is possible to make it this far
                 if nvl(c1rec.event_logon_uses_code,'F') = 'F' then sts := LNG.GLB_TXT_003; note_invalid_access(upper(trim(un)),pw,upper(job)); return; end if;
	       end if;
	      else
	       close c2;
	       is_customer := 'PHOTOGRAPHER';
	       owner_id := c2rec.pid;
	       check_pw := c2rec.password;
	       if c2rec.redirect_site_id is not null
	        then
	         sts := 'REDIRECT';
	         redirect_to(c2rec.redirect_site_id,un,pw,em);
	         return;
	       end if;
	     end if;
	  else
	     close c1p;
	     open c1(c1prec.aid);
	     fetch c1 into c1rec;
	     close c1;
	     c1rec := conv_account(c1prec,c1rec);
	     if c1rec.redirect_site_id is not null
	      then
	       sts := 'REDIRECT';
	       redirect_to(c1rec.redirect_site_id,un,pw,em);
	       return;
	     end if;
	     owner_id := c1prec.profile_id;
	     check_pw := c1prec.password;
             bypass_pw := c1rec.public_account;
             if encrypt( upper( nvl(pw,'|') )) <> nvl(c1prec.password,'!') -- Is guest?
	      then
               check_pw := c1prec.password_owner;
	       if c1rec.public_account = 'T'
	        then
	         is_customer := 'PROFILEG';
	        else
                 is_customer := 'PROFILE';
               end if;
	      else
               check_pw := c1prec.password;
	       is_customer := 'PROFILEG';
	     end if;
          end if;
         else
	  close c1;
	  if c1rec.redirect_site_id is not null
	   then
	    sts := 'REDIRECT';
	    redirect_to(c1rec.redirect_site_id,un,pw,em);
	    return;
	  end if;
	  owner_id := c1rec.aid;
	  check_pw := c1rec.password;
          bypass_pw := c1rec.public_account;
          if encrypt( upper( nvl(pw,'|') )) <> nvl(c1rec.password,'!') -- Is guest?
	   then
             check_pw := c1rec.password_owner;
             if c1rec.public_account = 'T'
	      then
	        if encrypt( upper( nvl(pw,'|') )) = nvl(check_pw,'!')
	         then
	          is_customer := 'OWNER';
	         else
	          is_customer := 'CUSTOMER';
	        end if;
	      else
	        is_customer := 'OWNER';
	      end if;
	   else
	      check_pw := c1rec.password;
              is_customer := 'CUSTOMER';
	   end if;
        end if;
      else
        owner_id := c5rec.manufacturer_id;
        check_pw := c5rec.password;
        is_customer := 'MANUFACTURER';
     end if;
   end if;

   -- Check Password
   if is_customer = 'VIRTUAL'
    then
     if upper(nvl(pw,'|')) <> nvl(check_pw,'!')
      then
       sts := LNG.GLB_TXT_004;
       note_invalid_access(upper(trim(un)),pw,upper(job));
       return;
     end if;
    else
     if (encrypt(upper( nvl(pw,'|') )) <> nvl(check_pw,'!')) and (bypass_pw = 'F')
      then
       sts := LNG.GLB_TXT_004;
       if is_customer = 'PHOTOGRAPHER'
        then
         update photographer set failed_logins = nvl(failed_logins,0) + 1 where pid = c2rec.pid;
        elsif is_customer = 'MANUFACTURER'
         then
          update manufacturer set failed_logins = nvl(failed_logins,0) + 1 where manufacturer_id = c5rec.manufacturer_id;
        elsif is_customer in ('PROFILE','PROFILEG')
         then
          update customer_profile set failed_logins = nvl(failed_logins,0) + 1 where profile_id = c1prec.profile_id;
        else
          update customer_account set failed_logins = nvl(failed_logins,0) + 1 where aid = c1rec.aid;
       end if;
       note_invalid_access(upper(trim(un)),pw,upper(job));
       return;
     end if;
   end if;

   if is_customer in ('OWNER','CUSTOMER','PROFILE','PROFILEG','VIRTUAL')
    then
      if (c1rec.date_expires < sysdate) and (c1rec.date_expires is not null)
       then
	 account_expired( c1rec, is_customer );
	 sts := LNG.GLB_TXT_035;
         --is_customer := 'BAD';
	 return;
      end if;
   end if;

   -- Has the account been disabled by the Couple or the Photographer?
   if is_customer in ('CUSTOMER','PROFILEG')
    then
      if c1rec.customer_disabled = 'T'
       then
	account_temp_disabled( c1rec );
	sts := LNG.GLB_TXT_035;
        --is_customer := 'BAD';
	return;
       end if;
   end if;

   -- Has the Photographer Account been disabled?
   if is_customer = 'PHOTOGRAPHER'
    then
     if nvl(c2rec.account_enabled,'T') = 'F'
      then
       phg_account_disabled;
       return;
     end if;
   end if;

   -- Has the Photographer Account password expired?
   if is_customer = 'PHOTOGRAPHER'
    then
     if (c2rec.password_expires is not null) and (c2rec.password_expires < sysdate)
      then
       phg_new_password(c2rec);
       return;
     end if;
   end if;

   -- Check IP Address is Restricted
   begin hostip := owa_util.get_cgi_env( 'REMOTE_ADDR' ); exception when others then hostip := 'UNKNOWN'; end;
   --open c7;
   --fetch c7 into c7rec;
   --close c7;
   if glbx.extract_master_parameter('IP_ADDRESS_NORESTRICT') = 'TRUE'
    then
     open c8( hostip );
     fetch c8 into c8rec;
     if c8%FOUND
      then
       close c8;
       sts := LNG3.ADM_TXT_701;
       return;
     end if;
     close c8;
    else
     open c8( hostip );
     fetch c8 into c8rec;
     if c8%NOTFOUND
      then
       close c8;
       sts := LNG3.ADM_TXT_701;
       return;
     end if;
     close c8;
   end if;

   -- Check if the Photographer(client) account has been restricted to certain IP address only
   if is_customer in ('OWNER','PROFILE','CUSTOMER','PROFILEG','VIRTUAL')
    then
     open c4( c1rec.pid );
     fetch c4 into c4rec;
     close c4;
     if c4rec.restrict_to_ip_address is not null
      then
       if hostip not like replace(c4rec.restrict_to_ip_address,'*','%')
        then
         sts := LNG3.ADM_TXT_701;
         return;
       end if;
     end if;
   end if;

   --voidrec := glbx.get_order_style( glbx.get_order_style( c1rec.aid, c1prec.profile_id, is_customer, b2c_value ));
   --def_cntry := voidrec.residing_country;
   if is_customer in ('OWNER','PROFILE','CUSTOMER','PROFILEG','VIRTUAL')
    then

     -- Check if Guest Feature Enabled
     open c6(c1rec.theme_type);
     fetch c6 into c6rec;
     close c6;
     if (substr(c6rec.theme_data,190,1) = 'F') and (is_customer in ('CUSTOMER','PROFILEG','VIRTUAL'))
      then
       sts := LNG.GLB_TXT_005;
       note_invalid_access(upper(trim(un)),pw,upper(job));
       return;
     end if;

     -- Check if Customer Feature Enabled
     if (substr(c6rec.theme_data,193,1) = 'F') and (is_customer in ('OWNER','PROFILE'))
      then
       sts := LNG.GLB_TXT_005;
       note_invalid_access(upper(trim(un)),pw,upper(job));
       return;
     end if;

     /*
     -- Check Email Address
     if (is_customer in ('CUSTOMER','PROFILEG','VIRTUAL') and substr(c1rec.on_login,5,1) = 'T') and (em is null)
      then
       -- Check if prompt for country also
       if substr(c1rec.on_login,1,1) = 'T'
        then
         sts := 'B' || '[' || def_cntry || ']' || LNG.GLB_TXT_133;
         return;
        else
         sts := 'E' || '[' || def_cntry || ']' || LNG.GLB_TXT_133;
         return;
       end if;
     end if;

     -- Check Prompt for Country
     if (is_customer in ('CUSTOMER','PROFILEG','VIRTUAL') and substr(c1rec.on_login,1,1) = 'T') and (country is null)
      then
       sts := 'C' || '[' || def_cntry || ']' || LNG.GLB_TXT_133;
       return;
     end if;

     if (is_customer in ('OWNER') and substr(c1rec.on_login,6,1) = 'T')
      then
       open c11(is_customer,c1rec.aid);
       fetch c11 into c11rec;
       close c11;
       if em is null and c11rec.contact_email is null
        then
         if substr(c1rec.on_login,2,1) = 'T' and c11rec.sendto_country is null
          then
           sts := 'B' || '[' || def_cntry || ']' || LNG.GLB_TXT_133;
           return;
          else
           sts := 'E' || '[' || def_cntry || ']' || LNG.GLB_TXT_133;
           return;
         end if;
       end if;
     end if;

     if (is_customer in ('OWNER') and substr(c1rec.on_login,2,1) = 'T')
      then
       open c11(is_customer,c1rec.aid);
       fetch c11 into c11rec;
       close c11;
       if country is null and c11rec.sendto_country is null
        then
           sts := 'C' || '[' || def_cntry || ']' || LNG.GLB_TXT_133;
           return;
       end if;
     end if;

     if (is_customer in ('PROFILE') and substr(c1rec.on_login,6,1) = 'T') and (em is null)
      then
       open c11(is_customer,c1prec.profile_id);
       fetch c11 into c11rec;
       close c11;
       if em is null and c11rec.contact_email is null
        then
         if substr(c1rec.on_login,2,1) = 'T' and c11rec.sendto_country is null
          then
           sts := 'B' || '[' || def_cntry || ']' || LNG.GLB_TXT_133;
           return;
          else
           sts := 'E' || '[' || def_cntry || ']' || LNG.GLB_TXT_133;
           return;
         end if;
       end if;
     end if;

     if (is_customer in ('PROFILE') and substr(c1rec.on_login,2,1) = 'T')
      then
       open c11(is_customer,c1prec.profile_id);
       fetch c11 into c11rec;
       close c11;
       if country is null and c11rec.sendto_country is null
        then
           sts := 'C' || '[' || def_cntry || ']' || LNG.GLB_TXT_133;
           return;
       end if;
     end if;
    */
   end if;

   -- Create Session Record
   -- select s_login_session.nextval into id from dual;

   if is_customer = 'PHOTOGRAPHER'
    then
      update photographer set failed_logins = 0 where pid = c2rec.pid;
    elsif is_customer = 'MANUFACTURER'
    then
     update manufacturer set failed_logins = 0 where manufacturer_id = c5rec.manufacturer_id;
    elsif is_customer in ('PROFILE','PROFILEG')
    then
     update customer_profile set failed_logins = 0 where profile_id = c1prec.profile_id;
    elsif is_customer = 'VIRTUAL'
     then
      null;
    else
     update customer_account set failed_logins = 0 where aid = c1rec.aid;
   end if;

   -- Fixed for AWM issue (Aug 2003)
   id := nvl( existing_sessid_is, glbx.get_random_sessionid );

   -- Check Business Feature and see if lightbox contents are to be transferred
   if is_customer in ('OWNER','PROFILE')
    then
     open c6(c1rec.theme_type);
     fetch c6 into c6rec;
     close c6;
     if substr(c6rec.theme_data,299,1) = 'T'
      then
       transfer_acct_details(is_customer,c1rec.aid,c1prec.profile_id,id);
     end if;
     if substr(c6rec.theme_data,364,1) = 'T'
      then
       transfer_session_Images(is_customer,c1rec.aid,c1prec.profile_id,id);
     end if;
   end if;

   if em is null
    then
     if is_customer = 'OWNER'
      then
       open c9(is_customer,c1rec.aid);
       fetch c9 into cust_em,cntry;
       close c9;
     elsif is_customer = 'PROFILE'
      then
       open c9(is_customer,c1prec.aid);
       fetch c9 into cust_em,cntry;
       close c9;
     end if;
    else
     cust_em := em;
   end if;

   if country is null
    then
     if is_customer = 'OWNER'
      then
       open c9(is_customer,c1rec.aid);
       fetch c9 into cust_em,cntry;
       close c9;
     elsif is_customer = 'PROFILE'
      then
       open c9(is_customer,c1prec.aid);
       fetch c9 into cust_em,cntry;
       close c9;
     end if;
    else
     cust_em := em;
     cntry := country;
   end if;

   if is_customer = 'OWNER'
    then
     open c10( 'OWNER', owner_id );
     fetch c10 into prev_sess;
     close c10;
   elsif is_customer = 'PROFILE'
    then
     open c10( 'PROFILE', c1prec.profile_id ); -- V470a Change
     fetch c10 into prev_sess;
     close c10;
   elsif is_customer = 'PHOTOGRAPHER'
    then
     open c10( 'PHOTOGRAPHER', owner_id );
     fetch c10 into prev_sess;
     close c10;
   elsif is_customer = 'VIRTUAL'
    then
     open c10a( 'VIRTUAL', owner_id, c3rec.client_id );
     fetch c10a into prev_sess;
     close c10a;
   else
    prev_sess := NULL;
   end if;

   if existing_sessid_is is null
    then
     surl := rpad(to_char(id),12,'Z') || glbx.randstring;
     -- Commented out by David Banjo on 17/9/23
     -- xxval := substr(owa_util.get_cgi_env( 'HTTP_USER_AGENT'),1,100);
     begin
       xxval := substr(owa_util.get_cgi_env( 'HTTP_USER_AGENT'),1,100);
     exception
       when others then
        xxval := null;
     end;
      
     insert into login_session(screen_type,login_type,sessid,aid,date_created,date_updated,call_ctr,guest_email, browser, ip_address, securl,unsolicited_email,previous_sessid,country)
        values (1,is_customer, id, owner_id, sysdate, sysdate, 1, cust_em, xxval, hostip, surl, un_email, prev_sess, cntry );
     session_id := id;
    else
     update login_session
      set
       aid = owner_id,
       login_type = is_customer,
       date_updated = sysdate,
       call_ctr = call_ctr + 1
     where
      sessid = existing_sessid_is;
   end if;
   commit;
   sts := is_customer;

   if is_customer = 'VIRTUAL'
    then
     update login_session
      set
       event_id = c3rec.client_id
     where
      sessid = id;
     commit;
   end if;

 exception
  when others
   then
    sts := LNG.GLB_TXT_005;
    note_invalid_access(upper(trim(un)),pw,upper(job));
    return;
 end logon_user;

 procedure redirect_to(rsite_id in integer, un in varchar2, pw in varchar2, em in varchar2)
 as
  cursor c1(rsite_id integer) is select site_dns from redirect_sites where site_id = rsite_id;
  c1rec	c1%ROWTYPE;
 begin
  open c1(rsite_id);
  fetch c1 into c1rec;
  close c1;
  owa_util.redirect_url( glbx.adjust_for_http(c1rec.site_dns) || '/pls/piction/glbx.accept_login?un=' || translate(un,' ','+') || '&pw=' || translate(pw,' ','+') || '&em=' || translate(em,' ','+'));
 end redirect_to;

 function randstring
  return varchar2
 is
  retstr	varchar2(10);
 begin

 retstr := NULL;
 dbms_random.Initialize(to_number(TO_CHAR(SYSDATE,'SSSSS')));
 for j in 1..10 loop
  retstr := retstr || chr(mod(abs(dbms_random.Random),26) + 65);
 end loop;

 dbms_random.terminate;
 return( retstr );

 end randstring;

 function randword
  return varchar2
 is

  cursor c1 is select count('x') tot from dictionary where length(term) > 5;
  cursor c2 is select term from dictionary where length(term) > 5;

  retstr	varchar2(1000);
  tot		integer;
  ctr		integer;

 begin
 -- Not an efficient procedure, but only planned to be run adhoc.
 open c1;
 fetch c1 into tot;
 close c1;
 retstr := NULL;
 dbms_random.Initialize(to_number(TO_CHAR(SYSDATE,'SSSSS')));
 ctr := mod(abs(dbms_random.Random),tot);
 for c2rec in c2 loop
  retstr := c2rec.term;
  if c2%ROWCOUNT = ctr then exit; end if;
 end loop;
 dbms_random.terminate;
 return( replace(replace(retstr,'''',''),'"','') );

 end randword;

 function conv_account( profile_rec in CUSTOMER_PROFILE%ROWTYPE, customer_rec in CUSTOMER_ACCOUNT%ROWTYPE ) return CUSTOMER_ACCOUNT%ROWTYPE
 as
  retrec 	CUSTOMER_ACCOUNT%ROWTYPE;
 begin
        retrec := customer_rec;
        retrec.theme_name := profile_rec.theme_name;
        retrec.username := profile_rec.username;
        retrec.account_name := profile_rec.account_name;
        retrec.theme_type := profile_rec.theme_type;
        retrec.public_account := profile_rec.public_account;
        retrec.customer_disabled := profile_rec.customer_disabled;
	retrec.is_beta_tester := profile_rec.is_beta_tester;
	retrec.date_held := profile_rec.date_held;
	retrec.password := profile_rec.password;
	retrec.password_owner := profile_rec.password_owner;
	retrec.failed_logins := profile_rec.failed_logins;
	retrec.date_created := profile_rec.date_created;
	retrec.date_expires := profile_rec.date_expires;
	retrec.enable_novelties := profile_rec.enable_novelties;
	retrec.enable_greetingcards := profile_rec.enable_greetingcards;
	retrec.can_edit_meta_data_values := profile_rec.can_edit_meta_data_values;
	retrec.reporting_category := profile_rec.reporting_category;
	retrec.receive_images_via_email := profile_rec.receive_images_via_email;
	retrec.receive_image_account := profile_rec.receive_image_account;
	retrec.receive_image_umo_scene := profile_rec.receive_image_umo_scene;
	retrec.receive_image_options := profile_rec.receive_image_options;
  return(retrec);
 end conv_account;

 procedure account_expired( c1rec CUSTOMER_ACCOUNT%ROWTYPE, customer_type in varchar2 )
 as
  cursor c2(phgid integer) is select work_phone,mobile_phone,contact_email,contact_fax,business_name,photographer_title, home_site from photographer where pid = phgid;
  c2rec	c2%ROWTYPE;
 begin
   open c2(c1rec.pid);
   fetch c2 into c2rec;
   close c2;
  htp.htmlopen;
   htp.header( 2, nvl(glbx.userpref(c1rec.pid,c1rec.aid,'ACCT_EXP'),LNG.GLB_TXT_006), 'CENTER' );
   htp.nl;
   htp.header( 3, LNG.GLB_TXT_007 || ': ' || to_char( c1rec.date_expires, LNG.MASK ), 'CENTER' );
   htp.nl;
   htp.nl;
   htp.p( '<CENTER>' );
   if c2rec.home_site is null
    then
     htp.anchor( 'http://' || owa_util.get_cgi_env( 'SERVER_NAME' ) || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || GLBX.PICTION_LOGIN_PAGE,LNG.GLB_TXT_008 );
    else
     if upper(substr(c2rec.home_site,1,7)) = 'HTTP://'
      then
       htp.anchor( c2rec.home_site, LNG.GLB_TXT_008 );
      else
       htp.anchor( 'http://' || c2rec.home_site, LNG.GLB_TXT_008 );
     end if;
   end if;
   htp.nl;
   htp.nl;
   if customer_type = 'OWNER'
    then
      htp.anchor( 'glbx.request_extension?acid=' || c1rec.aid, LNG.GLB_TXT_009 );
   end if;
   htp.nl;
   htp.nl;
   htp.bold( replace(LNG.GLB_TXT_108,'<PHOTOGRAPHER>',c2rec.photographer_title ));
   htp.nl;
   htp.bold( LNG.CST_TXT_005 ); htp.nl;
   htp.nl;
   htp.tableopen(cattributes=>'cellspacing=2 cellpadding=2 border=1');
    htp.tablerowopen;
     htp.tabledata( LNG.CST_TXT_004,cattributes=>glbx.QUERY_BACKGROUND );
     htp.tabledata( c2rec.business_name,cattributes=>glbx.QUERY_CELL_BACKGROUND );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( LNG.PHG_TXT_301,cattributes=>glbx.QUERY_BACKGROUND );
     htp.tabledata( nvl(c2rec.contact_email,'&nbsp;'),cattributes=>glbx.QUERY_CELL_BACKGROUND );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( LNG.PHG_TXT_237,cattributes=>glbx.QUERY_BACKGROUND );
     htp.tabledata( nvl(c2rec.work_phone,'&nbsp;'),cattributes=>glbx.QUERY_CELL_BACKGROUND );
    htp.tablerowclose;
    if c2rec.mobile_phone is not null
     then
      htp.tablerowopen;
       htp.tabledata( LNG.PHG_TXT_238,cattributes=>glbx.QUERY_BACKGROUND );
       htp.tabledata( c2rec.mobile_phone,cattributes=>glbx.QUERY_CELL_BACKGROUND );
      htp.tablerowclose;
    end if;
    if c2rec.contact_fax is not null
     then
      htp.tablerowopen;
       htp.tabledata( LNG.PHG_TXT_336,cattributes=>glbx.QUERY_BACKGROUND );
       htp.tabledata( c2rec.contact_fax,cattributes=>glbx.QUERY_CELL_BACKGROUND );
      htp.tablerowclose;
    end if;
   htp.tableclose;
   htp.p( '</CENTER>' );
  htp.htmlclose;

 end account_expired;

 procedure phg_account_disabled
 as

 begin
  htp.htmlopen;
   htp.header( 2, LNG.PHG_TXT_271, 'CENTER' );
   htp.nl;
   htp.nl;
   htp.header( 3, LNG.PHG_TXT_272 || '-' || glbx.extract_master_parameter('PICTION_EMAIL_ACCT'), 'CENTER' );
   htp.nl;
   htp.nl;
   htp.header( 3, LNG.PHG_TXT_273 || '-' || glbx.extract_master_parameter('CONTACT_NUMBER'), 'CENTER' );
   htp.nl;
   htp.nl;
   htp.p( '<CENTER>' );
   htp.anchor( 'http://' || owa_util.get_cgi_env( 'SERVER_NAME' ) || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || GLBX.PICTION_LOGIN_PAGE,LNG.GLB_TXT_008 );
   htp.nl;
   htp.nl;
   htp.p( '</CENTER>' );
  htp.htmlclose;
 end phg_account_disabled;

procedure phg_new_password( phgrec in PHOTOGRAPHER%ROWTYPE, msg in varchar2 default null )
 as
begin
  htp.htmlopen;
   htp.header( 2, nvl(msg,LNG2.PBK_TXT_126), 'CENTER' );
   htp.nl;
   htp.p( '<CENTER>' );
   htp.formopen( 'glbx.phg_expired_pwd' );
   htp.formhidden( 'P1', phgrec.pid );
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
    htp.tablerowopen;
     htp.tabledata( LNG.GLB_TXT_117 );
     htp.tabledata( htf.formpassword( 'P2', 30, 100 ));
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( LNG.GLB_TXT_116 );
     htp.tabledata( htf.formpassword( 'P3', 30, 100 ));
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( LNG.GLB_TXT_105 );
     htp.tabledata( htf.formpassword( 'P4', 30, 100 ));
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( null, LNG.PHG_ALT_431 );
   htp.nl;
   htp.formclose;
   htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'GLBX', 'PHG_NEW_PASSWORD',errmsg=>sqlerrm);
end phg_new_password;

procedure phg_expired_pwd(p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2)
as

  cursor c1(owner_id integer) is select * from photographer where pid = owner_id;
  --cursor c2 is select password_expiry_days from master_piction;

  c1rec		c1%ROWTYPE;
  --c2rec		c2%ROWTYPE;
  testpw	varchar2(100);
  pw_expiry	number;

begin
 open c1(p1);
 fetch c1 into c1rec;
 close c1;
 if nvl(c1rec.password,'!') <> nvl(encrypt(upper(p2)),'|')
  then
   update photographer
    set
     failed_logins = nvl(failed_logins,0) + 1
    where pid = to_number(p1);
   commit;
   glbx.phg_new_password(c1rec, LNG.GLB_TXT_118 );
   return;
 end if;
 if p2 is null or p3 is null or p4 is null
  then
   glbx.phg_new_password(c1rec,LNG.GLB_TXT_119 );
   return;
 end if;
 if upper(p3) <> upper(p4)
  then
   glbx.phg_new_password(c1rec,LNG.GLB_TXT_120 );
   return;
 end if;
 testpw := encrypt(upper(p3));
 --open c2;
 --fetch c2 into c2rec;
 --close c2;
 pw_expiry := nvl(to_number(glbx.extract_master_parameter('PASSWORD_EXPIRY_DAYS')),90);
 update photographer
  set
   password = testpw,
   password_expires = (sysdate + pw_expiry),
   failed_logins = 0
 where pid = to_number(p1);
 insert into audit_photographer_password(pid,date_changed,pw) values (to_number(p1),sysdate,upper(p3));
 commit;
 accept_login(c1rec.username,upper(p3),null,null);
exception when others then
 glbx.error_details( 'GLBX', 'PHG_EXPIRED_PWD',errmsg=>sqlerrm,extdet=>' P1:' || p1);
end phg_expired_pwd;

procedure account_temp_disabled( c1rec CUSTOMER_ACCOUNT%ROWTYPE )
 as
  cursor c2(phgid integer) is select home_site from photographer ph where ph.pid = phgid;
  cursor c3(acid integer) is
   select text_unsolicited_email,columns_on_login
   from order_style os, customer_price_book cpb
   where cpb.oid = os.oid and
         cpb.aid = acid and
         ltype = 'OWNER';

 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 pfx		THEME%ROWTYPE;
 dsp		varchar2(32767);
 tag_name 	GLBX.MYARRAY;
 tag_title 	GLBX.MYARRAY;

 begin
  open c2(c1rec.pid);
  fetch c2 into c2rec;
  close c2;
  open c3(c1rec.aid);
  fetch c3 into c3rec;
  close c3;
  pfx := glbx.get_thm( c1rec.aid );
  if c2rec.home_site is null
   then
    c2rec.home_site := glbx.extract_master_parameter('PICTION_HOME_PAGE');
  end if;
  c2rec.home_site := glbx.adjust_for_http( c2rec.home_site );

  dsp := NULL;
  dsp := dsp || htf.formopen( 'glbx.grab_email_address' );
  dsp := dsp || htf.formhidden( 'ACID', c1rec.aid );
  dsp := dsp || htf.bold( LNG.GLB_TXT_081 );
  dsp := dsp || htf.nl;
  dsp := dsp || htf.nl;
  dsp := dsp || htf.formtext( 'P1', 30, 100 );
  dsp := dsp || htf.nl;
  dsp := dsp || htf.nl;
  if substr(c3rec.columns_on_login,12,1) = 'T'
   then
    dsp := dsp || htf.formcheckbox( 'P2', 'T', 'CHECKED' );
   else
    dsp := dsp || htf.formcheckbox( 'P2', 'T' );
  end if;
  dsp := dsp || ' ' || c3rec.text_unsolicited_email;
  dsp := dsp || htf.nl;
  dsp := dsp || htf.nl;
  dsp := dsp || htf.formsubmit( null, LNG.GLB_TXT_082 );
  dsp := dsp || htf.formclose;

  if pfx.expire_template is null
   then
    htp.htmlopen;
     htp.header( 2, LNG.GLB_TXT_053, 'CENTER' );
     htp.nl;
     htp.header( 3, LNG.GLB_TXT_054 || c1rec.customer_message, 'CENTER' );
     htp.nl;
     htp.p( '<CENTER>' );
     htp.nl;
     htp.p( dsp );
     htp.nl;
     htp.nl;
     htp.anchor( c2rec.home_site,LNG.GLB_TXT_008 );
     htp.nl;
     htp.nl;
     htp.p( '</CENTER>' );
    htp.htmlclose;
    return;
  end if;

  tag_name(1) := 'EMAIL_ADDRESS_DETAILS';
  tag_title(1) := dsp;
  tag_name(2) := 'HOME_SITE';
  tag_title(2) := c2rec.home_site;
  tag_name(3) := 'CUSTOMER_MESSAGE';
  tag_title(3) := c1rec.customer_message;
  tag_name(4) := 'UNSOLICITED_EMAIL';
  tag_title(4) := c3rec.text_unsolicited_email;
  tag_name(5) := 'AID';
  tag_title(5) := c1rec.aid;
  tag_name(6) := 'FORM_HIDDEN_AID';
  tag_title(6) := htf.formhidden( 'ACID', c1rec.aid );

  external_html_file(surl=>NULL, cusrec=>c1rec, display_type=>'EXPIRED', tag_name=>tag_name, tag_title=>tag_title, fname=>pfx.expire_template );

 end account_temp_disabled;

 procedure grab_email_address( acid in integer, p1 in varchar2, p2 in varchar2 default 'F' )
 as
 begin
  insert into grab_email(aid,email_address,date_created,unsolicited_email)
   select acid, p1, sysdate, p2
   from dual
   where not exists
   (select 'x'
    from grab_email
    where aid=acid and email_address=p1);
  commit;
  htp.htmlopen;
   htp.header( 2, LNG.GLB_TXT_083, 'CENTER' );
   htp.nl;
   htp.header( 3, LNG.GLB_TXT_084, 'CENTER' );
   htp.nl;
   htp.nl;
   htp.nl;
   htp.p( '</CENTER>' );
  htp.htmlclose;
 end grab_email_address;

 procedure help_cookie
 as
 begin
  htp.htmlopen;
   htp.header( 3, 'How to Setup Cookies on your Browser','CENTER');
   htp.nl;
   htp.bold( 'To run Piction your browser needs to have Cookies running. These cookies are only stored in your browser and not in any files.');
   htp.nl;
   htp.bold( 'Piction will not read any non Piction Cookies. Piction will only store a session number in the cookie and will not store any other data of any sorts with the cookie.');
   htp.nl;
   htp.nl;
   htp.line;
   htp.nl;
   htp.nl;
   htp.bold( 'To Enable Cookies under Microsoft Internet Explorer (IE):' );
   htp.nl;
   htp.italic( 'From the Menu Choose: Tools-Internet Options... On the tabs on the top of the Window click on the one called Security.');
   htp.nl;
   htp.italic( 'On the bottom half of the Window is a section called Security Level for this Zone. Change the level to Medium or Lower.');
   htp.nl;
   htp.italic( 'If this does not fix the problem. Click on the Custom Option. Find the option called Allow per-session cookies(not stored), and click on enable.');
   htp.nl;
   htp.bold( 'Important Note: If the error still appears click on Refresh (Icon at the top of the screen). IE might have cached this page and not the correct login page.');
   htp.nl;
   htp.nl;
   htp.italic( 'Now go back to the previous screen and re-enter in your Username and Password.' );
   htp.nl;
   htp.nl;
   htp.line;
   htp.nl;
   htp.nl;
   htp.bold( 'To Enable Cookies under Netscape:' );
   htp.nl;
   htp.nl;
   htp.italic( 'From the Menu Choose: Edit->Preferences. On the left hand side of the pop-up window is an Option titled Advanced. Click on the Word Advanced.');
   htp.nl;
   htp.italic( 'On the Right Hand Side there is a section title Cookies. Click on the Option that says: Accept All Cookies. Click on OK to save the settings.');
   htp.line;
   htp.italic( 'Now go back to the previous screen and re-enter in your Username and Password.' );
   htp.line;
   htp.nl;
  htp.htmlclose;
 end help_cookie;

 procedure cookie_id( surl in varchar2, stype out varchar2, ltype out varchar2, owner_id out integer, sts out varchar2, call_type in varchar2 default 'O', progcalled in varchar2 default null, retrieved_id in integer default null, dispwhat in varchar2 default null, iscust in boolean default TRUE, reset in boolean default TRUE, ignore_cookie_check in boolean default FALSE )
 is
  cursor c1( id integer ) is select rowid, login_type, screen_type, aid, date_created, date_updated, is_connected  from login_session where sessid = id;
  --cursor c2 is select disconnect_after from master_piction;
  cursor c3( id integer, surl varchar2 ) is select rowid, login_type, screen_type, aid, date_created, date_updated, is_connected  from login_session where securl = surl and sessid = id;

  c1rec		c1%ROWTYPE;
  id		varchar2(100);
  seccomp	varchar2(20);
  x		integer;
  ck		owa_cookie.cookie;
  timeout	integer;
  vsurl         varchar2(100);

 -- Add parameter to hold procedure called
 -- Add boolean call to enable full auditing and track procedure, date, sessid

 begin
  -- Is there a Master Parameter Cookie set?
  -- insert into temp values ('F1:' || vsurl || '-' || surl ); commit;
  vsurl := surl;

  -- Check if Cookie Enabled and not a customer
  if not ignore_cookie_check and iscust
   then
    if glbx.extract_master_parameter('COOKIE_ENABLED') = 'TRUE'
     then
       ck := owa_cookie.get(nvl(glbx.extract_master_parameter('COOKIE_NAME'),'PICTION_COOKIE'));
       if ck.num_vals > 0
        then
         id := ck.vals(1);
         if id is not null and surl is not null and glbx.truncsurl(id) <> glbx.truncsurl(surl)
          then
            -- The Stored Cookie Value is greater than the one passed down. We should use the stored cookie value
            -- insert into temp values ('F2:' || vsurl || '-' || surl || '-' || id ); commit;
            vsurl := id;
         end if;
       end if;
    end if;
  end if;

  -- Put in so that external APIs can get access to the SURL.
  DAPI.GLOBAL_SURL := vsurl;

  id := NULL;
  -- insert into temp values ('F3:' || vsurl ); commit;
  if reset then htp.init; end if;
  --if glbx.stress_test then stype := 1; ltype := 'CUSTOMER'; owner_id := 2369; sts := NULL; return; end if;
    id := substr(vsurl,1,12);
    x := instr(id,'Z');
    if x > 0
     then
      id := substr(id,1,x-1);
    end if;
    begin
     x := to_number(id);
    exception
     when others then
     sts := 'Invalid ID:' || id;
     return;
    end;
    seccomp := substr(vsurl,13,10);
    open c3(x,substr(vsurl,1,22));
    fetch c3 into c1rec;
    if c3%NOTFOUND
     then
      close c3;
      sts := 'Invalid ID:' || id;
      return;
    end if;
    close c3;

    begin
     open c1( to_number(id) );
    exception
     when others then
      sts := 'Invalid ID:' || id;
      return;
    end;

    fetch c1 into c1rec;
    if c1%NOTFOUND
     then
      close c1;
      sts := LNG.GLB_TXT_010;
      return;
    end if;
    close c1;

    if c1rec.is_connected = 'F'
     then
      sts := LNG.GLB_TXT_011;
      return;
    end if;

    ltype := c1rec.login_type;
    stype := c1rec.screen_type;
    if call_type = 'O'
     then
      owner_id := c1rec.aid;
    elsif call_type = 'S'
     then
     owner_id := to_number(id);
    end if;

    update login_session
     set
	 date_updated = sysdate,
	 call_ctr = call_ctr + 1
    where rowid = c1rec.rowid;

   begin timeout := to_number(glbx.extract_master_parameter('DISCONNECT_AFTER')); exception when others then timeout := 180; end;

   if (sysdate - nvl(c1rec.date_updated,c1rec.date_created))*1440 > timeout
    then
     update login_session
	set is_connected = 'F'
	where rowid = c1rec.rowid;
	commit;
	sts := LNG.GLB_TXT_012 || timeout || LNG.GLB_TXT_013;
	htp.nl;
	htp.nl;
	login_page( LNG.GLB_TXT_014 );
	return;
   end if;

   --if decs.audit_all_activity
   -- then
     insert into audit_all_activity(sessid,date_updated,program_called,umo_id,display_what,login_type) values
     ( to_number(id), sysdate, progcalled, retrieved_id, dispwhat,ltype );
   --end if;

  commit;

exception when others then
 glbx.error_details( 'GLBX', 'COOKIE_ID',errmsg=>sqlerrm,extdet=>'STYPE:' || stype || ' LTYPE:' || ltype || ' OWNER_ID:' || owner_id || ' CALL_TYPE:' || call_type || ' STS:' || sts);
end cookie_id;

function encrypt( password IN Varchar2, use_gcard in boolean default FALSE, special_key in varchar2 default null) return varchar2
  as
	--Key must be at leat three characters long, or there's no point (and maybe an errror)
	key varchar2(30);
	newp varchar2(30);
	final varchar2(30);
	klen number;
	kpos number:=1;
	temp_pass char;
	temp_key char;
	startp number;
	a number;
	y number;
  begin
    if password is null then return( '*' ); end if;
    if use_gcard
     then
      key := DECS.GREETING_CARD_ENCRYPT_KEY || DECS.RANDOM_NUMBER;
     else
      if special_key is null
       then
        key := DECS.GENERAL_ENCRYPT_KEY || DECS.RANDOM_NUMBER;
       else
        key := special_key || DECS.RANDOM_NUMBER;
      end if;
    end if;
	--Grab first 30 chars of password.
	newp:=substr(password,1,30);

	--Pad with spaces
	newp:=rpad(newp,30);

	klen:=length(key);
	startp:=ascii('A');
	y:=30-length(password);

	--Encrypt, 8 passes.
	for pass in 1..8 loop
	final:='';
	for letter in 1..30 loop
		--Get next letter
		temp_pass:=substr(newp,letter,1);

		--Get next letter in key.
		kpos:=kpos+1;
		temp_key:=substr(key,kpos,1);
		kpos:=mod(kpos,klen);

		--Number juggle. Also converts intire string to uppercase A-Z
		if mod(ascii(temp_pass),2) = 0 then
			temp_key:=chr(mod(ascii(temp_pass)+3,26)+startp);
		else
			temp_key:=chr(mod(ascii(temp_pass)+8,26)+startp);
		end if;

		--More bits of juggling that use the other parts of the word, makes it quite
		--good after 8 passes.
		a:=13;
		if letter < 30 then
			a:=a+ascii(substr(newp,letter+1,1));
		end if;
		if letter < 29 then
			a:=a+ascii(substr(newp,letter+2,1));
		end if;
		if letter < 28 then
			a:=a+ascii(substr(newp,letter+3,1));
		end if;
		if letter < 27 then
			a:=a+ascii(substr(newp,letter+4,1));
		end if;
		if letter > 1 then
			a:=a+ascii(substr(newp,letter-1,1));
		end if;
		if letter > 2 then
			a:=a+ascii(substr(newp,letter-2,1));
		end if;
		if letter > 3 then
			a:=a+ascii(substr(newp,letter-3,1));
		end if;
		a:=a+letter;
		a:=a+y;
		a:=a+ascii(temp_key);
		a:=mod(a,50);
		if a=0 then
			a:=1;
		end if;
		temp_pass:=chr(mod(ascii(temp_pass)+a+mod(letter,10),26)+startp);
		final:=final||temp_pass;
	end loop;
	newp:=final;
	end loop;
	return newp;
exception when others then
 glbx.error_details( 'GLBX', 'ENCRYPT',errmsg=>sqlerrm,extdet=>'Password:' || password);
end encrypt;

procedure accept_login( un in varchar2 default null, pw in varchar2 default null, Click_To_Login in varchar2 default null, em in varchar2 default null, unsolicited_email in varchar2 default 'F', job in varchar2 default null, country in varchar2 default null, simplesearch in varchar2 default NULL, v_umo in varchar2 default NULL, v_product_id in varchar2 default null, screen_name in varchar2 default null, screen_parms in varchar2 default null, screen_type in varchar2 default 'RIGHT', rnd in varchar2 default null )
as

 cursor c1a( sess_id integer ) is select on_login from customer_account where aid = (select aid from login_session where sessid = sess_id);
 cursor c1b( sess_id integer ) is select on_login from customer_account where aid = (select aid from customer_profile where profile_id = (select aid from login_session where sessid = sess_id));

 sts		varchar2(1000);
 surl		varchar2(100);
 vsurl		varchar2(100);
 v_user		varchar2(100);
 session_id	integer;
 stype		integer;
 pfx		THEME%ROWTYPE;
 un_email	char(1);
 on_login	CUSTOMER_ACCOUNT.ON_LOGIN%TYPE;
 lrec		login_session%ROWTYPE;

begin

 -- Check for reconnection. Only applies if no username and password is entered.
 -- insert into temp values ('A1:' ); commit;
 if (un is null and pw is null) or
--    (simplesearch is not null or v_umo is not null or v_product_id is not null or screen_name is not null)
-- this change required for INTORD
    (v_umo is not null or v_product_id is not null )
  then
   vsurl := piction_cookie( lrec );
   -- insert into temp values ('A2:' || vsurl ); commit;
   if vsurl is null
    then
     -- Cookie does not exist, see if a default username exists
     -- insert into temp values ('A3:' || vsurl ); commit;
     v_user := upper( glbx.extract_master_parameter('DEFAULT_LOGIN') );

    else
     -- Cookie Exists, extract the SURL and use that for connection
     -- insert into temp values ('4:' || vsurl ); commit;
     reconnect(simplesearch=>simplesearch,v_umo=>v_umo,v_product_id=>v_product_id,screen_name=>screen_name,screen_parms=>screen_parms,screen_type=>screen_type);
     return;
   end if;
 else
  v_user := upper(un);
 end if;

 htp.init;
 if upper(unsolicited_email) not in ('T','F')
  then
   un_email := 'F';
  else
   un_email := upper(unsolicited_email);
 end if;

 if v_user is null
  then
   sts := 'No Username Provided';
  else
   logon_user( v_user, upper(pw), sts, session_id, stype, Click_To_Login, em, un_email, job, surl, country );
 end if;

 if sts = 'REDIRECT'
  then
   return;

 elsif sts in ('CUSTOMER','OWNER','PROFILE','PROFILEG','VIRTUAL','PHOTOGRAPHER','MANUFACTURER')
  then
   fname.login_account_first_stage( surl, simplesearch, v_umo, v_product_id, screen_name, screen_parms, screen_type );
   return;

 elsif sts = LNG.GLB_TXT_035 -- Error has Occured
  then
   return;

 else -- Display Login Page
  pfx := glbx.get_thm( DECS.DEFAULT_PHG_THEME );
  glbx.main_title( surl, sts,'<BODY BGCOLOR="#' || pfx.text_back || '">',stype=>1,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.title( LNG.GLB_TXT_015 );
  htp.nl;
  htp.nl;
  htp.p( '<CENTER>' );
  htp.nl;
  htp.header( 3, LNG.GLB_TXT_016, 'CENTER' );
  htp.nl;
  login_page(un=>v_user,job=>job,pfx=>glbx.get_thm( DECS.DEFAULT_PHG_THEME ), simplesearch=>simplesearch, v_umo=>v_umo, v_product_id=>v_product_id,screen_name=>screen_name,screen_parms=>screen_parms,screen_type=>screen_type);
  return;
 end if;

exception when others then
 glbx.error_details( 'GLBX', 'ACCEPT_LOGIN',errmsg=>sqlerrm);
end accept_login;

procedure forgotten_password( un in varchar2 )
is

 cursor c1( acid integer ) is select date_created from login_session where login_type = 'FORGOTTEN_PASSWORD' and aid = acid and sessid = 0;
 cursor c2( un varchar2 ) is select * from customer_account where username = un;
 cursor c2c( acid integer ) is select contact_email from customer_contact where login_type = 'OWNER' and aid = acid;
 cursor c2d(acid integer) is select pw from audit_customer_password where aid = acid and date_changed = (select max(date_changed) from audit_customer_password where aid=acid and pw is not null);
 cursor c3( un varchar2 ) is select * from customer_profile where username = un;
 cursor c3c( acid integer ) is select contact_email from customer_contact where login_type = 'PROFILE' and aid = acid;
 cursor c3d(acid integer) is select pw from audit_profile_password where profile_id = acid and date_changed = (select max(date_changed) from audit_profile_password where profile_id=acid and pw is not null);
 cursor c4( un varchar2 ) is select * from photographer where username = un;
 cursor c4d(phgid integer) is select pw from audit_photographer_password where pid = phgid and date_changed = (select max(date_changed) from audit_photographer_password where pid=phgid and pw is not null);
 cursor c5( un varchar2 ) is select * from manufacturer where username = un;
 cursor c5d(manid integer) is select pw from audit_manufacturer_password where manufacturer_id = manid and date_changed = (select max(date_changed) from audit_manufacturer_password where manufacturer_id = manid and pw is not null);

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c2crec		c2c%ROWTYPE;
 c2drec		c2d%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c3crec		c3c%ROWTYPE;
 c3drec		c3d%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c4drec		c4d%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c5drec		c5d%ROWTYPE;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;

begin

 -- Customer Account
 open c2(upper(un));
 fetch c2 into c2rec;
 if c2%FOUND
  then
   close c2;
   open c1(c2rec.aid);
   fetch c1 into c1rec;
   close c1;
   if c1rec.date_created is not null and sysdate > c1rec.date_created - 1 then htp.bold( LNG4.AHC_TXT_447 ); return; end if;
   open c2c(c2rec.aid);
   fetch c2c into c2crec;
   close c2c;
   open c2d(c2rec.aid);
   fetch c2d into c2drec;
   close c2d;
   if c2crec.contact_email is not null
    then
     if c2drec.pw is not null
      then
       gcode(1) := 'USERNAME';
       gparam(1) := c2rec.username;
       gcode(2) := 'ACCOUNT_NAME';
       gparam(2) := c2rec.account_name;
       gcode(3) := 'PASSWORD';
       gparam(3) := c2drec.pw;
       gcode(4) := 'BAR_TITLE';
       gparam(4) := glbx.extract_master_parameter('BAR_TITLE');
       glbx.send( gcode, gparam, 'forgotten_password.tmp', p_to=>c2crec.contact_email,p_subj=>LNG4.AHC_TXT_448 || glbx.extract_master_parameter('BAR_TITLE'),p_from=>glbx.extract_master_parameter('MAIL_FROM'), scode=>'FP1');
       insert into login_session(login_type,aid,date_created,sessid) values ('FORGOTTEN_PASSWORD',c2rec.aid,sysdate,0);
       commit;
       htp.htmlopen;
       glbx.header_msg( LNG4.AHC_TXT_451 );
       htp.htmlclose;
      else
       htp.bold( LNG4.AHC_TXT_450 );
     end if;
   else
     htp.bold( LNG4.AHC_TXT_449 );
   end if;
   return;
 end if;
 close c2;

 -- Customer Profile
 open c3(upper(un));
 fetch c3 into c3rec;
 if c3%FOUND
  then
   close c3;
   open c1(c3rec.profile_id);
   fetch c1 into c1rec;
   close c1;
   if c1rec.date_created is not null and sysdate > c1rec.date_created - 1 then htp.bold( LNG4.AHC_TXT_447 ); return; end if;
   open c3c(c3rec.profile_id);
   fetch c3c into c3crec;
   close c3c;
   open c3d(c3rec.profile_id);
   fetch c3d into c3drec;
   close c3d;
   if c3crec.contact_email is not null
    then
     if c3drec.pw is not null
      then
       gcode(1) := 'USERNAME';
       gparam(1) := c3rec.username;
       gcode(2) := 'ACCOUNT_NAME';
       gparam(2) := c3rec.account_name;
       gcode(3) := 'PASSWORD';
       gparam(3) := c3drec.pw;
       gcode(4) := 'BAR_TITLE';
       gparam(4) := glbx.extract_master_parameter('BAR_TITLE');
       glbx.send( gcode, gparam, 'forgotten_password.tmp', p_to=>c3crec.contact_email,p_subj=>LNG4.AHC_TXT_448 || glbx.extract_master_parameter('BAR_TITLE'),p_from=>glbx.extract_master_parameter('MAIL_FROM'), scode=>'FP1');
       insert into login_session(login_type,aid,date_created,sessid) values ('FORGOTTEN_PASSWORD',c3rec.profile_id,sysdate,0);
       commit;
       htp.htmlopen;
       glbx.header_msg( LNG4.AHC_TXT_451 );
       htp.htmlclose;
      else
       htp.bold( LNG4.AHC_TXT_450 );
     end if;
   else
     htp.bold( LNG4.AHC_TXT_449 );
   end if;
   return;
 end if;
 close c3;

 -- Photographer
 open c4(upper(un));
 fetch c4 into c4rec;
 if c4%FOUND
  then
   close c4;
   open c1(c4rec.pid);
   fetch c1 into c1rec;
   close c1;
   if c1rec.date_created is not null and sysdate > c1rec.date_created - 1 then htp.bold( LNG4.AHC_TXT_447 ); return; end if;
   open c4d(c4rec.pid);
   fetch c4d into c4drec;
   close c4d;
   if c4rec.contact_email is not null
    then
     if c4drec.pw is not null
      then
       gcode(1) := 'USERNAME';
       gparam(1) := c4rec.username;
       gcode(2) := 'ACCOUNT_NAME';
       gparam(2) := c4rec.business_name;
       gcode(3) := 'PASSWORD';
       gparam(3) := c4drec.pw;
       gcode(4) := 'SIGNATURE';
       gparam(4) := glbx.extract_master_parameter('MAIL SIGNATURE');
       gcode(5) := 'BAR_TITLE';
       gparam(5) := glbx.extract_master_parameter('BAR_TITLE');
       glbx.send( gcode, gparam, 'forgotten_password.tmp', p_to=>c4rec.contact_email,p_subj=>LNG4.AHC_TXT_448 || glbx.extract_master_parameter('BAR_TITLE'),p_from=>glbx.extract_master_parameter('MAIL_FROM'), scode=>'FP1');
       insert into login_session(login_type,aid,date_created,sessid) values ('FORGOTTEN_PASSWORD',c4rec.pid,sysdate,0);
       commit;
       htp.htmlopen;
       glbx.header_msg( LNG4.AHC_TXT_451 );
       htp.htmlclose;
      else
       htp.bold( LNG4.AHC_TXT_450 );
     end if;
   else
     htp.bold( LNG4.AHC_TXT_449 );
   end if;
   return;
 end if;
 close c4;

 -- Manufacturer
 open c5(upper(un));
 fetch c5 into c5rec;
 if c5%FOUND
  then
   close c5;
   open c1(c5rec.manufacturer_id);
   fetch c1 into c1rec;
   close c1;
   if c1rec.date_created is not null and sysdate > c1rec.date_created - 1 then htp.bold( LNG4.AHC_TXT_447 ); return; end if;
   open c5d(c5rec.manufacturer_id);
   fetch c5d into c5drec;
   close c5d;
   if c5rec.contact_email is not null
    then
     if c5drec.pw is not null
      then
       gcode(1) := 'USERNAME';
       gparam(1) := c5rec.username;
       gcode(2) := 'ACCOUNT_NAME';
       gparam(2) := c5rec.name;
       gcode(3) := 'PASSWORD';
       gparam(3) := c5drec.pw;
       gcode(4) := 'BAR_TITLE';
       gparam(4) := glbx.extract_master_parameter('BAR_TITLE');
       glbx.send( gcode, gparam, 'forgotten_password.tmp', p_to=>c5rec.contact_email,p_subj=>LNG4.AHC_TXT_448 || glbx.extract_master_parameter('BAR_TITLE'),p_from=>glbx.extract_master_parameter('MAIL_FROM'), scode=>'FP1');
       insert into login_session(login_type,aid,date_created,sessid) values ('FORGOTTEN_PASSWORD',c5rec.manufacturer_id,sysdate,0);
       commit;
       htp.htmlopen;
       glbx.header_msg( LNG4.AHC_TXT_451 );
       htp.htmlclose;
      else
       htp.bold( LNG4.AHC_TXT_450 );
     end if;
   else
     htp.bold( LNG4.AHC_TXT_449 );
   end if;
   return;
 end if;
 close c5;

 htp.bold( LNG4.AHC_TXT_452 );

end forgotten_password;

procedure login_page( msg in varchar2 default null, un in varchar2 default null, em in varchar2 default null, job in varchar2 default null, style in varchar2 default 'INITIAL', pfx in THEME%ROWTYPE default null, on_form in char DEFAULT 'TTTTTT', unsolicited_email in varchar2 default 'F', country in varchar2 default null, pw in varchar2 default null, promptoption in varchar2 default 'E', simplesearch in varchar2 default NULL, v_umo in varchar2 default NULL, v_product_id in varchar2 default null, screen_name in varchar2 default null, screen_parms in varchar2 default null, screen_type in varchar2 default 'RIGHT' )
as

 cursor c3 is select distinct region from postal_charge order by region;

 bckh 	varchar2(100);
 bckb 	varchar2(100);
 align	varchar2(100);
 tbl	varchar2(100);

begin
 if style in ('INITIAL','PROMPT') then htp.htmlopen; htp.p( '<CENTER>' ); end if;
 if style in ('EMBEDDED','PROMPT')
  then
   if substr(on_form,5,1) = 'T'
    then
     bckh := pfx.qbground;
     bckb := pfx.qcbground;
    else
     bckh := NULL;
     bckb := NULL;
   end if;
   if substr(on_form,3,1) = 'T'
    then
     tbl := 'cellpadding=3 cellspacing=3 border=1';
    else
     tbl := 'cellpadding=3 cellspacing=3 border=0';
   end if;
   if substr(on_form,2,1) = 'T'
    then
     align := ' ALIGN="RIGHT"';
    else
     align := ' ALIGN="LEFT"';
   end if;
  else
   bckh := glbx.QUERY_BACKGROUND;
   bckb := glbx.QUERY_CELL_BACKGROUND;
   align := ' ALIGN="RIGHT"';
   tbl := 'cellpadding=3 cellspacing=3 border=1';
 end if;

 if msg is not null
  then
   htp.header( 3, msg, 'CENTER' );
   htp.nl;
 end if;

 htp.tableopen(cattributes=>'cellpadding=3 cellspacing=3 border=0' );
 htp.tablerowopen;
 htp.p( '<TD ALIGN="LEFT" VALIGN="TOP">' );

 htp.formopen( 'glbx.accept_login', ctarget=>'_top' );
 htp.formhidden( 'SIMPLESEARCH', simplesearch );
 htp.formhidden( 'V_UMO', v_umo );
 htp.formhidden( 'V_PRODUCT_ID', v_product_id );
 htp.formhidden( 'SCREEN_NAME', screen_name );
 htp.formhidden( 'SCREEN_PARMS', screen_parms );
 htp.formhidden( 'SCREEN_TYPE', screen_type );

 htp.tableopen(cattributes=>tbl );
  if style = 'PROMPT'
   then
    htp.formhidden( 'UN', un );
    htp.formhidden( 'PW', pw );
   else
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.GLB_TXT_017),cattributes=>bckh || align );
     htp.tabledata( htf.formtext( 'UN', 20, 100, un ),cattributes=>bckb );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.GLB_TXT_018),cattributes=>bckh || align );
     htp.tabledata( htf.formpassword( 'PW', 20, 100 ),cattributes=>bckb );
    htp.tablerowclose;
  end if;

 htp.tableclose;
 htp.nl;
 htp.formsubmit(null, LNG.GLB_TXT_019 );
 htp.formclose;
 if glbx.extract_master_parameter('FORGOTTEN_PASSWORD') = 'TRUE' and style not in ('SIMPLE','EMBEDDED')
   then
    htp.nl;
     htp.p('<FONT SIZE=-2>');
     htp.formopen( 'glbx.forgotten_password', ctarget=>'_top' );
     htp.tableopen(cattributes=>tbl );
     htp.tablerowopen;
      htp.tabledata( '<FONT SIZE=-2>' || htf.bold(LNG4.AHC_TXT_441) || '</FONT>',cattributes=>bckh || align );
      htp.tabledata( '<FONT SIZE=-2>' || htf.bold(LNG4.AHC_TXT_442) || '</FONT>',cattributes=>bckb );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( '<FONT SIZE=-2>' || htf.bold(LNG.GLB_TXT_076) || '</FONT>',cattributes=>bckh || align );
      htp.tabledata( htf.formtext( 'UN', 30, 100 ),cattributes=>bckb );
     htp.tablerowclose;
     htp.tableclose;
    htp.nl;
    htp.formsubmit(null, LNG4.AHC_TXT_446 );
    htp.formclose;
    htp.p('</FONT>');
 end if;

 htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tableclose;

 if style in ('INITIAL','PROMPT') then htp.p( '</CENTER>' ); htp.htmlclose; end if;
exception when others then
 glbx.error_details( 'GLBX', 'LOGIN_PAGE',errmsg=>sqlerrm,extdet=>'MSG:' || msg);
end login_page;

procedure acct_logoff(surl in varchar2, iscust in varchar2 default 'T', force_logoff in varchar2 default 'F', other_logoff in varchar2 default null)
as

 cursor c1(sess integer) is select ca.theme_type,ph.home_site from login_session ls,photographer ph,customer_account ca where ca.pid=ph.pid and ca.aid = ls.aid and ls.sessid = sess;
 cursor c2(sess integer) is select ph.theme_type,ph.home_site from login_session ls,photographer ph where ph.pid = ls.aid and ls.sessid = sess;
 cursor c3(sess integer) is
  select count('x') tot
  from shopping_basket sb, purchase_order po
  where sb.poid = po.poid and
        po.sessid = sess and
        po.status in (LNG.ORD_TXT_120,LNG4.AHC_TXT_672,'PreOrder - Confirmed without Payment');

 c1rec		c1%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sess_id	integer;
 sts		varchar2(100);

begin

 if iscust = 'T'
  then
   glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'GLBX.ACCT_LOGOFF', iscust=>TRUE );
  else
   glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'GLBX.ACCT_LOGOFF', iscust=>FALSE );
 end if;

 if sts is not null and sts <> LNG.GLB_TXT_011
  then
   htp.bold( LNG.GLB_TXT_020 || ':' || sts );
   return;
 end if;

 if ltype = 'PHOTOGRAPHER'
  then
   open c2(sess_id);
   fetch c2 into c1rec;
   close c2;
  elsif ltype = 'MANUFACTURER'
   then
    c1rec.theme_type := NULL;
    c1rec.home_site := NULL;
  else
   open c1(sess_id);
   fetch c1 into c1rec;
   close c1;
 end if;

 -- Check Shopping Basket and see if anything is left in it
 if force_logoff = 'F' and ltype in ('PHOTOGRAPHER','OWNER','CUSTOMER','PROFILE','PROFILEG','VIRTUAL')
  then
   open c3(sess_id);
   fetch c3 into c3rec;
   close c3;
   if c3rec.tot > 0
    then
     -- Ask if they want to buy or leave
     fname.acct_orders(surl,acid=>NULL,force_logoff=>'T',other_logoff=>other_logoff);
     return;
   end if;
 end if;

 -- If they have specified a site then do not log them off
 if other_logoff is null
  then
   update login_session
    set
     is_connected = 'F',
     date_updated = sysdate,
     call_ctr = nvl(call_ctr,1) + 1
   where sessid = sess_id;
   commit;
 end if;
 --login_page;

 if other_logoff is not null then c1rec.home_site := other_logoff; end if;

 if c1rec.home_site is null
  then
    if glbx.extract_master_parameter('OVERRIDE_HOME_PAGE') is null
     then
      owa_util.redirect_url( 'http://' || owa_util.get_cgi_env( 'SERVER_NAME' ) || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || GLBX.PICTION_LOGIN_PAGE);
     else
      owa_util.redirect_url( glbx.extract_master_parameter('OVERRIDE_HOME_PAGE') );
    end if;
  else
    owa_util.redirect_url( glbx.adjust_for_http(c1rec.home_site));
 end if;

 --owa_util.print_cgi_env;
exception when others then
 glbx.error_details( 'GLBX', 'ACCT_LOGOFF',errmsg=>sqlerrm);
end acct_logoff;

function photo_pref( pid integer, acid integer, prefname varchar2 )
 return varchar2
as
 cursor c1 is
  select value
   from photographer_preference pp, all_preferences ap
   where pp.pid = pid and
         pp.aid = acid and
         ap.preference_name = prefname and
		 ap.prefid = pp.prefid;
 c1rec	c1%ROWTYPE;
begin
 open c1;
 fetch c1 into c1rec;
 close c1;
 return( c1rec.value );
exception when others then
 glbx.error_details( 'GLBX', 'PHOTO_PREF',pid,errmsg=>sqlerrm);
end photo_pref;

function userpref(phgid in integer, acid in integer, txt in varchar2)
 return varchar2
is
 cursor c1(phgid integer, acid integer, txt varchar2) is
  select pp.value
  from all_preferences ap, photographer_preference pp
  where pp.pid = phgid and
        pp.aid = acid and
		pp.prefid = ap.prefid and
		ap.preference_name = txt;
 c1rec	c1%ROWTYPE;
begin
 open c1( phgid, acid, txt );
 fetch c1 into c1rec;
 close c1;
 return( c1rec.value );
exception when others then
 glbx.error_details( 'GLBX', 'USERPREF',phgid,acid,errmsg=>sqlerrm,extdet=>'TXT:' || txt);
end userpref;

function userpref_sess(sess_id in integer, txt in varchar2)
 return varchar2
is
 cursor c1(sess_id integer, txt varchar2) is
  select pp.value
  from all_preferences ap, login_session ls, customer_account ca, photographer_preference pp
  where ls.aid = pp.aid and
        ls.sessid = sess_id and
		pp.prefid = ap.prefid and
		pp.pid = ca.pid and
		pp.aid = ca.aid and
		ap.preference_name = txt;
 c1rec	c1%ROWTYPE;
begin
 open c1( sess_id, txt );
 fetch c1 into c1rec;
 close c1;
 return( c1rec.value );
exception when others then
 glbx.error_details( 'GLBX', 'USERPREF_SESS',errmsg=>sqlerrm,extdet=>'Sess_Id:' || sess_id || ' TXT:' || txt);
end userpref_sess;

procedure process_acct_details( surl in varchar2, acid in integer, p1 in varchar2, p1b in varchar2 default null, p2 in varchar2, p2a in varchar2, p2b in varchar2, p3 in varchar2, p4 in varchar2, p4a in varchar2, p5 in varchar2, p6 in varchar2, p6f in varchar2, p7 in varchar2, p8 in varchar2,
                                action in varchar2 default null, profid in integer default null, ppub in varchar2 default 'F', pmet in varchar2 default 'F', event_to_use in varchar2 default null)
as

 cursor c1( uname varchar2, acid integer ) is select 'x' from customer_account where username = uname and aid <> acid;
 cursor c1p( uname varchar2, profid integer ) is select 'x' from customer_profile where username = uname and profile_id <> profid;
 cursor c2( uname varchar2 ) is select 'x' from photographer where username = uname;
 cursor c3( uname varchar2 ) is select 'x' from manufacturer where username = uname;
 cursor c4( thm varchar2 ) is select theme_data from theme_types where theme_type = thm;
 cursor c5(cname varchar2) is select clr_hex from colours where clr_name = cname;
 cursor c6(acid integer, phgid integer) is select 'x' from customer_account where aid = acid and pid = phgid and password = password_owner;
 cursor c8(phid integer) is select days_to_expire, payment_style, ph.plan_id from photographer ph,charge_plan cp where cp.id = ph.plan_id and ph.pid = phid;
 cursor c9(phid integer, plid integer, pname varchar2) is select qty from charge_plan_event_phg where plan_id = plid and plan_event = pname and pid = phid;
 cursor c10(acid integer) is select theme_type from customer_account where aid = acid;
 cursor c11(acid varchar2, bf varchar2) is
  select um.umo_id, ua.attribute_id
  from umo um, customer_account ca, umo_attributes ua
  where ca.aid = um.aid and
        ca.theme_type = bf and
        um.umo_type = ua.umo_type and
        ca.aid = acid and
        ua.business_feature = ca.theme_type;
 cursor c12(bf varchar2) is
  select attribute_id from umo_attributes where business_feature = bf;
 cursor c13(acid integer, atid integer) is
   select ua.umo_id,ua.attribute_id,ua.value,ua.position_id,um.umo_type
   from umo_attribute ua, umo um
   where ua.attribute_id = atid and
         ua.umo_id = um.umo_id and
         um.aid = acid;
cursor c14(phgid integer, uname varchar2) is
 select upper(reserve_username_prefix) pfx
 from photographer
 where pid <> phgid and
       reserve_username_prefix is not null and
       uname like upper(reserve_username_prefix) || '%';
cursor c15(phgid integer, isdef varchar2) is select oid from order_style where is_default = isdef and pid = phgid;
cursor c16 (plid integer, pev varchar2) is select * from charge_plan_event where plan_id = plid and plan_event = pev;

 c4rec		c4%ROWTYPE;
 c8rec		c8%ROWTYPE;
 c9rec		c9%ROWTYPE;
 c10rec		c10%ROWTYPE;
 c14rec		c14%ROWTYPE;
 c15rec		c15%ROWTYPE;
 c16rec		c16%ROWTYPE;
 new_password	varchar2(100);
 new_passwordb	varchar2(100);
 phid		integer;
 tmp		char(1);
 msg		varchar2(100);
 newaid		integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
 chexa		varchar2(20);
 chexb		varchar2(20);
 dispvert	char(1);
 retprof	varchar2(100);
 newexp		date;
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, phid, sts, progcalled=>'GLBX.PROCESS_ACCT_DETAILS', iscust=>FALSE );
 if sts is not null
  then
   htp.bold( LNG.GLB_TXT_020 || ':' || sts );
   return;
 end if;

 if action = LNG4.AHC_TXT_641
  then
   pbk.mng_profiles(surl,acid);
   return;
 end if;

 if action = LNG.GLB_BUT_042
  then
   htp.htmlopen;
    htp.header( 2, LNG.GLB_TXT_022, 'CENTER' );
    htp.nl;
    htp.header( 3, LNG.GLB_TXT_023, 'CENTER' );
    htp.nl;
    htp.nl;
    htp.p( '<CENTER>' );
    htp.formopen( 'phg.delete_account' );
    htp.formhidden( 'SURL', glbx.rndsurl(surl));
    htp.formhidden( 'ACID', acid );
    htp.formsubmit( 'ACTION', LNG.GLB_BUT_042 );
    htp.formsubmit( 'ACTION', LNG.GLB_BUT_041 );
    htp.formclose;
    htp.p( '</CENTER>' );
   htp.htmlclose;
   return;
 end if;
 new_password := NULL;
 tmp := NULL;
 if p3 is null
  then
   msg := LNG.GLB_TXT_024;
   phg.disp_err( surl,'PHGUPD', acid, msg, profid );
   return;
 end if;

 if p1 is null
  then
   msg := LNG.GLB_TXT_025;
   phg.disp_err( surl,'PHGUPD', acid, msg, profid );
   return;
 end if;

 if (acid = 0) and (p4 is null) and (ppub = 'F')
  then
   -- Check if BF 190 is enabled. If it disabled continue and ignore error message
   open c4(p6);
   fetch c4 into c4rec;
   close c4;
   if substr(c4rec.theme_data,190,1) = 'T'
    then
     msg := LNG.GLB_TXT_026;
     phg.disp_err( surl,'PHGUPD', acid, msg, profid );
     return;
   end if;
 end if;

 open c1( upper(p3), acid );
 fetch c1 into tmp;
 if c1%FOUND
  then
   close c1;
   msg := LNG.GLB_TXT_027 || p3;
   phg.disp_err( surl,'PHGUPD', acid, msg, profid );
   return;
 end if;
 close c1;

 open c1p( upper(p3), nvl(profid,0) );
 fetch c1p into tmp;
 if c1p%FOUND
  then
   close c1p;
   msg := LNG.GLB_TXT_027 || p3;
   phg.disp_err( surl,'PHGUPD', acid, msg, profid );
   return;
 end if;
 close c1p;

 open c2( upper(p3) );
 fetch c2 into tmp;
 if c2%FOUND
  then
   close c2;
   msg := LNG.GLB_TXT_027 || p3;
   phg.disp_err( surl,'PHGUPD', acid, msg, profid );
   return;
 end if;
 close c2;
 open c3( upper(p3) );
 fetch c3 into tmp;
 if c3%FOUND
  then
   close c3;
   msg := LNG.GLB_TXT_027 || p3;
   phg.disp_err( surl,'PHGUPD', acid, msg, profid );
   return;
 end if;
 close c3;

 if p4 is not null
  then
   new_password := encrypt( upper( p4 ));
 end if;

 if p4a is not null
  then
   new_passwordb := encrypt( upper( p4a ));
 end if;

 -- If a Customer Profile is modified
 if profid = 0
  then
   select s_customer_profile.nextval into newaid from dual;
   open c8(phid);
   fetch c8 into c8rec;
   close c8;
   newexp := NULL;
   if c8rec.payment_style in ('YEARLY')
    then
     newexp := to_date(p2b,LNG.MASK);
    else
     newexp := sysdate+c8rec.days_to_expire;
   end if;

   insert into customer_profile(profile_id,pid,aid,account_name,date_held,username,password,password_owner,scene_name,theme_name,theme_type,date_created,date_expires,public_account,can_edit_meta_data_values) values
    (newaid,phid,acid,p1,p2,upper(rtrim(p3)),new_password,new_passwordb,p5,p6,p6f,sysdate,newexp,ppub,pmet);
   insert into audit_profile_password(profile_id,date_changed,pw,pwg) values (newaid,sysdate,upper( p4a ),upper( p4 ));
   commit;

   phg.phg_acct_master(surl,acid,profid=>newaid);
   return;

 elsif nvl(profid,0) > 0
  then
     open c8(phid);
     fetch c8 into c8rec;
     close c8;
     newexp := NULL;
     if c8rec.payment_style in ('YEARLY','EVENT')
      then
       newexp := to_date(p2b,LNG.MASK);
     end if;
     update customer_profile
	  set
	   account_name = p1,
	   date_held = p2,
	   username = upper(p3),
	   password = nvl(new_password,password),
	   password_owner = nvl(new_passwordb,password_owner),
	   scene_name = p5,
	   theme_name = p6,
	   theme_type = p6f,
	   public_account = ppub,
	   can_edit_meta_data_values = pmet,
	   date_expires = nvl(newexp,date_expires)
	 where aid = acid and
	       pid = phid and
	       profile_id = profid;

      if (p4a is not null) or (p4 is not null)
       then
        insert into audit_profile_password(profile_id,date_changed,pw,pwg) values (profid,sysdate,upper(p4a),upper(p4));
      end if;
     commit;
     phg.phg_acct_master(surl,acid,profid=>profid);
     return;
 end if;

 -- If a Customer Account is modified
 if acid <> 0
  then
     open c10(acid);
     fetch c10 into c10rec;
     close c10;
     open c8(phid);
     fetch c8 into c8rec;
     close c8;
     newexp := NULL;
     if c8rec.payment_style in ('YEARLY')
      then
       newexp := to_date(p2b,LNG.MASK);
     end if;

     update customer_account
	  set
	   account_name = p1,
	   date_held = p2,
	   photographer_account_id = p2a,
	   username = upper(p3),
	   password = nvl(new_password,password),
	   password_owner = nvl(new_passwordb,password_owner),
	   scene_name = p5,
	   theme_name = p6,
	   theme_type = p6f,
	   public_account = ppub,
	   can_edit_meta_data_values = pmet,
	   date_expires = nvl(newexp,date_expires)
	 where aid = acid and
	       pid = phid;


      if c10rec.theme_type <> p6f
       then
        -- Business Feature Changed. Update all the Meta Tags.
        for c12rec in c12(c10rec.theme_type) loop
          delete from umo_index where umo_id in
           (select umo_id from umo where aid = acid) and aid = acid and attribute_id = c12rec.attribute_id;
          for c13rec in c13(acid,c12rec.attribute_id) loop
            if c13rec.umo_type = 'AUDIO'
             then
                myaudio.audio_api(v_umo=>c13rec.umo_id,attrib_id=>c13rec.attribute_id,data_value=>c13rec.value,acid=>acid,posid=>nvl(c13rec.position_id,1),action=>'DELETE');
             elsif c13rec.umo_type = 'VIDEO'
               then
                myvideo.video_api(v_umo=>c13rec.umo_id,attrib_id=>c13rec.attribute_id,data_value=>c13rec.value,acid=>acid,posid=>nvl(c13rec.position_id,1),action=>'DELETE');
              elsif c13rec.umo_type = 'RELATIONAL'
               then
                myrelational.relational_api(v_umo=>c13rec.umo_id,attrib_id=>c13rec.attribute_id,data_value=>c13rec.value,acid=>acid,posid=>nvl(c13rec.position_id,1),action=>'DELETE');
              elsif c13rec.umo_type = 'BLUEPRINT'
               then
                myblueprint.blueprint_api(v_umo=>c13rec.umo_id,attrib_id=>c13rec.attribute_id,data_value=>c13rec.value,acid=>acid,posid=>nvl(c13rec.position_id,1),action=>'DELETE');
              elsif c13rec.umo_type = 'DOCUMENT'
               then
                mydocument.document_api(v_umo=>c13rec.umo_id,attrib_id=>c13rec.attribute_id,data_value=>c13rec.value,acid=>acid,posid=>nvl(c13rec.position_id,1),action=>'DELETE');
              end if;
          end loop;

          delete from umo_attribute where umo_id in
           (select umo_id from umo where aid = acid) and attribute_id = c12rec.attribute_id;
        end loop;
        for c11rec in c11(acid,p6f) loop
           insert into umo_attribute(umo_id,attribute_id,date_made,position_id,value) values
               (c11rec.umo_id,c11rec.attribute_id,sysdate,1,null);
        end loop;
      end if;

      open c6(acid,phid);
      fetch c6 into tmp;
      if c6%FOUND
       then
	   close c6;
           msg := LNG.GLB_TXT_028;
           phg.disp_err( surl,'PHGUPD', acid, msg, profid );
	   rollback;
           return;
      end if;
      if (p4a is not null) or (p4 is not null)
       then
        insert into audit_customer_password(aid,date_changed,pw,pwg) values (acid,sysdate,upper(p4a),upper(p4));
      end if;
      close c6;

  else

   -- Create new customer
   -- Check if the username has already been reserved by someone else
   open c14(phid,upper(rtrim(p3)));
   fetch c14 into c14rec;
   close c14;
   if c14rec.pfx is not null
    then
     msg := LNG4.AHC_TXT_975 || ':' || c14rec.pfx;
     phg.disp_err( surl,'PHGUPD', acid, msg, profid );
     return;
   end if;

   select s_customer_profile.nextval into newaid from dual;
   open c8(phid);
   fetch c8 into c8rec;
   close c8;
   if new_password = new_passwordb
    then
     msg := LNG.GLB_TXT_028;
     phg.disp_err( surl,'PHGUPD', acid, msg, profid );
     return;
   end if;
   if c8rec.payment_style in ('YEARLY')
    then
     newexp := to_date(p2b,LNG.MASK);
    else
     newexp := sysdate+c8rec.days_to_expire;
   end if;

   if p1b is null
    then
     insert into customer_account(pid,aid,account_name,date_held,username,password,password_owner,scene_name,theme_name,theme_type,date_created,date_expires,public_account,home_page_options,site_type,photographer_account_id,on_login,zoom_factor,can_edit_meta_data_values,enable_novelties,novelty_features,enable_greetingcards) values
      (phid,newaid,p1,p2,upper(rtrim(p3)),new_password,new_passwordb,p5,p6,p6f,sysdate,newexp,ppub,rpad('T',30,'T'),'S',p2a,'FFFFTFTTFFTFFFFFFFFF',rpad('T',10,'T'),pmet,'T',lpad('F',40,'F'),'T');
    else
     insert into customer_account(pid,aid,account_name,date_held,username,password,password_owner,scene_name,theme_name,theme_type,date_created,date_expires,public_account,home_page_options,site_type,photographer_account_id,zoom_factor,home_page_style,
                                  home_page_link,link_name,home_page_override,event_logon_uses_code,event_logon_password_style,customer_message,background_img,on_login,can_edit_meta_data_values,enable_novelties,cusobj,novelty_features,enable_greetingcards,reporting_category)
      select pid,newaid,p1,p2,upper(rtrim(p3)),new_password,new_passwordb,scene_name,theme_name,theme_type,sysdate,newexp,public_account,home_page_options,site_type,photographer_account_id,zoom_factor,home_page_style,
                                  home_page_link,link_name,home_page_override,event_logon_uses_code,event_logon_password_style,customer_message,null,on_login,pmet,enable_novelties,cusobj,novelty_features,enable_greetingcards,reporting_category
      from customer_account where aid = p1b and pid = phid;
      
     insert into customer_roles (aid,role_id)
     select newaid,role_id
       from  customer_roles 
      where aid = p1b;

   end if;

   /*
    1  Main Title
    2  Instructions
    3  Categories and # Images
    4  Central Image
    18 Random Image on Home Page
    19 Background Image is used on Home Page  - 20 Category Total
    16 Central Image can be Clicked On
    17 Use Photographer Logo as Central Image
    12 Display Mfctr Clearance Details instead of Image
    11 Display Column Listing of Categories
    5  Customer Account Listed
    6  Date of Event Listed
    7  Date Account Expires Listed
    8  Price Book Expires Listed
    9  List Audio
    13 Display Username
    10 Display Novelties
    (not used, 14,15,20)
   */
   if p1b is null -- If not null, then already set, see above insert statement
    then
     update customer_account
      set
        home_page_options = substr(home_page_options,1,8) || 'F' || substr(home_page_options,10)
     where aid = newaid;
     update customer_account
      set
        home_page_options = substr(home_page_options,1,10) || 'F' || substr(home_page_options,12)
     where aid = newaid;
       update customer_account
      set
        home_page_options = substr(home_page_options,1,11) || 'F' || substr(home_page_options,13)
     where aid = newaid;
       update customer_account
      set
        home_page_options = substr(home_page_options,1,20) || 'F' || substr(home_page_options,22)
     where aid = newaid;
     update customer_account
      set
        home_page_options = substr(home_page_options,1,12) || 'F' || substr(home_page_options,14)
     where aid = newaid;
     update customer_account
      set
        home_page_options = substr(home_page_options,1,16) || 'F' || substr(home_page_options,18)
     where aid = newaid;
     update customer_account
      set
        home_page_options = substr(home_page_options,1,18) || 'F' || substr(home_page_options,20)
     where aid = newaid;
   end if;

   if p1b is null
    then
     insert into photographer_preference(pid,aid,prefid,value)
      select phid,newaid,ph.prefid,ph.value
	from photographer_preference ph
	 where ph.pid = phid and aid = 0;
    else
     insert into photographer_preference(pid,aid,prefid,value)
      select phid,newaid,c.prefid,c.value
      from photographer_preference c
      where c.pid = phid and aid = p1b;
     insert into home_news
       (hnews,aid,title,title_highlight,title_font_colour,title_inc_font,order_by,display_column,font,font_colour,
        font_inc_font,reference_link_type,reference_link,reference_search_cat,reference_search_age,tnail_or_text,matte_image,
        tnail_id,text_display,line_between_news,display_to,news,frame_news,news_object,image_loc)
      select
        s_home_news.nextval,newaid,title,title_highlight,title_font_colour,title_inc_font,order_by,display_column,font,font_colour,
        font_inc_font,reference_link_type,reference_link,reference_search_cat,reference_search_age,tnail_or_text,matte_image,
        tnail_id,text_display,line_between_news,display_to,news,frame_news,news_object,image_loc
      from home_news
      where aid = p1b;

   end if;

   -- Plan Style is EVENT then check Quota and decrement
   -- If Invalid (ie they have hacked in somehow) then delete the account
   if c8rec.payment_style = 'EVENT'
    then
     open c9(phid,c8rec.plan_id,event_to_use);
     fetch c9 into c9rec;
     if c9%NOTFOUND or (c9rec.qty <= 0)
      then
       close c9;
       delete from customer_account where aid = newaid;
       delete from photographer_preference where aid= newaid and pid = phid;
       htp.htmlopen;
        htp.bold( LNG2.PFM_TXT_081 || ': ' || event_to_use);
        htp.nl;
        htp.bold('. ' ||  LNG2.PFM_TXT_082 );
        -- htp.p( 'PH:' || phid || '-' || c8rec.plan_id || '-' || c9rec.qty );
        htp.nl;
       htp.htmlclose;
       return;
     end if;
     close c9;
     update charge_plan_event_phg
      set
       qty = qty - 1
       where pid = phid and
             plan_id = c8rec.plan_id and
             plan_event = event_to_use;
     open c16(c8rec.plan_id, event_to_use );
     fetch c16 into c16rec;
     close c16;
     if c16rec.days_expires is null
      then
       newexp := NULL;
      else
       newexp := sysdate+c16rec.days_expires;
     end if;
     update customer_account
      set
       date_expires = newexp,
       plan_event = event_to_use,
       plan_id = c8rec.plan_id
     where
      aid = newaid;

   end if;
   insert into audit_customer_password(aid,date_changed,pw,pwg) values (newaid,sysdate,upper( p4a ),upper( p4 ));
   theme_rec := get_theme_types( phid );

     -- Map the first price book of the photographer to the customer
   /*
   insert into customer_price_book(pid,aid,spb,valid_until,pb_when_invalid)
     select phid,newaid, spb, null, null
       from phg_price_book
       where pid = phid and
        rownum < 2;
   */

   -- Attach the Default Order Style
   if p1b is null
    then
     -- Get the Default Order Style. If none specified get the anyone out.
     open c15(phid,'T');
     fetch c15 into c15rec;
     if c15%NOTFOUND
      then
       close c15;
       open c15(phid,'F');
       fetch c15 into c15rec;
     end if;
     close c15;
     insert into customer_price_book(pid,aid,oid,valid_until,oid_when_invalid,ltype)
      values(phid,newaid,c15rec.oid,null,null,'OWNER');
    else
     insert into customer_price_book(pid,aid,oid,valid_until,oid_when_invalid,ltype)
       select phid,newaid,oid,valid_until,oid_when_invalid,ltype
       from customer_price_book
       where pid = phid and aid = p1b and ltype = 'OWNER' and rownum < 2;
   end if;

 end if;
 commit;

 if acid = 0
  then
   phg.phg_acct_master(surl,newaid);
  else
   phg.phg_acct_master(surl,acid);
 end if;

exception when others then
 glbx.error_details( 'GLBX', 'PROCESS_ACCT_DETAILS',vaid=>acid,errmsg=>sqlerrm,extdet=>'P1:' || p1);
end process_acct_details;

function scrollbar( msg in varchar2, bar_type in varchar2 default 'SCROLLBAR' )
 return varchar2
is
 fv_hdr	varchar2(4000);
begin
 if msg is null then return( null ); end if;
 if bar_type = 'SCROLLBAR'
  then
fv_hdr := htf.htmlopen || ' <SCRIPT LANGUAGE="JavaScript">
function game_scroll(seed)
{
        var msg  = "' || msg || '";
        var out = " ";
        var c   = 1;
        if (seed > 100) {
                seed--;         var cmd="game_scroll(" + seed + ")";
                timerTwo=window.setTimeout(cmd,100);
        }
        else if (seed <= 100 && seed > 0) {
                for (c=0 ; c < seed ; c++) {
                        out+=" ";
                }
                out+=msg;
                seed--;
                var cmd="game_scroll(" + seed + ")";
                    window.status=out;
                timerTwo=window.setTimeout(cmd,100);
        }
        else if (seed <= 0) {
                if (-seed < msg.length) {
                        out+=msg.substring(-seed,msg.length);
                        seed--;
                        var cmd="game_scroll(" + seed + ")";
                        window.status=out;
                        timerTwo=window.setTimeout(cmd,100);
                }
                else {
                        window.status=" ";
                timerTwo=window.setTimeout("game_scroll(100)",75);
                }
        }
}
</SCRIPT>
</HEAD>
<BODY onLoad="timerONE=window.setTimeout(''game_scroll(100)'',500);" ' || 'BGCOLOR="#FFFFFF"' || '> ';
elsif bar_type = 'MENUBAR'
  then
fv_hdr := '<HEAD>' || ' <SCRIPT LANGUAGE="JavaScript">
var space = "                                                                           "
var scr = space + "' || translate(msg,'"<>','   ') || '"
function ScrollAlong()
{
 temp = scr.substring(0,1);
 scr += temp
 scr = scr.substring(1,scr.length);
 document.Scroll.ScrollBox.value = scr.substring(0,80);
 var counts = setTimeout("ScrollAlong()",100);
}
</SCRIPT>
</HEAD>';
end if;
return( fv_hdr );
exception when others then
 glbx.error_details( 'GLBX', 'SCROLLBAR',errmsg=>sqlerrm,extdet=>'MSG:' || msg);
end scrollbar;

procedure error_details(pkn in varchar2 default null, prc in varchar2 default null, vpid in integer default null, vaid in integer default null, vphid in integer default null, vpoid in integer default null, errmsg in varchar2 default null, extdet in varchar2 default null, display_error_page in boolean default TRUE)
as
begin
 begin
  insert into error_trap(date_created,package_name,procedure_name,pid,aid,phid,poid,error_message,extra_details) values
   (sysdate,pkn,prc,vpid,vaid,vphid,vpoid,errmsg,extdet);
  commit;
 exception
  when others then  htp.htmlopen; htp.p( sqlerrm );
 end;
 if not display_error_page then return; end if;
 htp.htmlopen;
 htp.header(2, LNG.GLB_TXT_035, 'CENTER' );
 htp.bold( LNG.GLB_TXT_036 );
 htp.nl;
 htp.nl;
 htp.italic( LNG.GLB_TXT_037 );
 htp.nl;
 htp.nl;
 htp.bold( LNG.GLB_TXT_038 );
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( 'Package' );
   htp.tabledata( pkn );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Procedure/Function' );
   htp.tabledata( prc );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'PID' );
   htp.tabledata( vpid );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'AID' );
   htp.tabledata( vaid );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'PHID' );
   htp.tabledata( vphid );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'POID' );
   htp.tabledata( vpoid );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Error Message' );
   htp.tabledata( errmsg );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Extra Details' );
   htp.tabledata( extdet );
  htp.tablerowclose;
 htp.tableclose;
 htp.htmlclose;
exception
 when others then
  htp.p( LNG.GLB_TXT_039 || sqlerrm );
  htp.p( LNG.GLB_TXT_040 );
end error_details;

function total_payment( poid integer )
 return number
is

 parm1 		GLBX.MYARRAY;
 parm2 		GLBX.MYARRAY_NMB;

begin
 calculate_pricing( poid, parm1, parm2 );
 return( retrieve_pricing_value( 'SUB_TOTAL', parm1, parm2 ));

exception when others then
 glbx.error_details( 'GLBX', 'TOTAL_PAYMENT',vpoid=>poid,errmsg=>sqlerrm);
end total_payment;

function  individual_payment( vsbid integer )
 return number
is

 cursor c1(vsbid in integer) is
  select *
  from purchase_order
  where poid in (select poid from shopping_basket where shopping_id = vsbid);

 cursor c5(vsbid integer) is select * from shopping_basket where shopping_id = vsbid;

tot	number;
crt	number;
surch	number;
c1rec	c1%ROWTYPE;
c5rec	c5%ROWTYPE;

begin

 tot := 0;

 /*
 open c1( vsbid );
 fetch c1 into c1rec;
 close c1;
 */
 open c5( vsbid );
 fetch c5 into c5rec;
 close c5;
 -- Ignore Delivery Cost
 -- tot := tot + nvl(c1rec.delivery_cost,0);
 tot := (c5rec.photo_cost * c5rec.qty);

 /*
 This code has been commented out at the request of AWM (2nd Aug 2002). GST, Surcharge and Discount are now calculated separately.
 if nvl(c1rec.photographer_discount,1) <> 0
  then
   tot := tot * nvl(c1rec.photographer_discount,1);
 end if;
 tot := tot * (1 - (nvl(c1rec.special_discount,0)/100));

 -- Add Surcharge
 surch := 0;
 if ( c1rec.home_country = c1rec.sendto_country ) and (c5rec.surcharge_local is not null)
  then
   surch := (c5rec.surcharge_local/100) * tot;
 elsif ( c1rec.home_country <> c1rec.sendto_country ) and (c5rec.surcharge_int is not null)
  then
   surch := (c5rec.surcharge_int/100) * tot;
 end if;
 tot := tot + surch;

 -- Add GST if not included
 if nvl(c1rec.other_cost,0) <> 0 and c1rec.gst_incl = 'F'
  then
   tot := tot * (1 + (c1rec.other_cost/100));
 end if;
 */

 return( round(tot,2) );

exception when others then
 glbx.error_details( 'GLBX', 'INDIVIDUAL_PAYMENT',extdet=>'VSBID:' || vsbid,errmsg=>sqlerrm);
end individual_payment;

procedure purchase_each_cost( purchrec in purchase_order%ROWTYPE, additional_options out number, surcharge out number, gst out number, postage out number, discount out number )
as

 parm1 		GLBX.MYARRAY;
 parm2 		GLBX.MYARRAY_NMB;

begin

 calculate_pricing( purchrec.poid, parm1, parm2 );
 additional_options := retrieve_pricing_value( 'ADDITIONAL_OPTIONS', parm1, parm2 );
 surcharge := retrieve_pricing_value( 'TOTAL_SURCHARGE', parm1, parm2 );
 gst := retrieve_pricing_value( 'GST', parm1, parm2 );
 postage := retrieve_pricing_value( 'POSTAGE', parm1, parm2 );
 discount := retrieve_pricing_value( 'PHG_DISCOUNT', parm1, parm2 );

end purchase_each_cost;

procedure extract_grand_total_payment( poid in integer, gst_value out number, discounts out number, cert_total out number, gtotal out number, include_gift_certificate in boolean default TRUE )
as

 parm1 		GLBX.MYARRAY;
 parm2 		GLBX.MYARRAY_NMB;
 nmb		number;

begin
 calculate_pricing( poid, parm1, parm2 );

 gst_value := retrieve_pricing_value( 'GST_VALUE', parm1, parm2 );
 nmb := retrieve_pricing_value( 'GST_INCLUSIVE', parm1, parm2 );
 if nmb > 0 then gst_value := nmb; end if;

 discounts := retrieve_pricing_value( 'DISCOUNT', parm1, parm2 );
 cert_total := retrieve_pricing_value( 'CERTIFICATE_TOTAL', parm1, parm2 );
 if include_gift_certificate
  then
   gtotal := retrieve_pricing_value( 'GRAND_TOTAL_NOCERT', parm1, parm2 );
  else
   gtotal := retrieve_pricing_value( 'GRAND_TOTAL_WITHCERT', parm1, parm2 );
 end if;

end extract_grand_total_payment;

procedure extract_photographer_order( poid in integer, gst in number, subtotal out number, gtotal out number, handling out number, commission out number, phg_receives out number, tax out number, postage out number, include_gift_certificate in boolean default TRUE )
as

 parm1 		GLBX.MYARRAY;
 parm2 		GLBX.MYARRAY_NMB;

begin
 calculate_pricing( poid, parm1, parm2 );
 subtotal := retrieve_pricing_value( 'SUB_TOTAL', parm1, parm2 );
 handling := retrieve_pricing_value( 'HANDLING', parm1, parm2 );
 commission := retrieve_pricing_value( 'COMMISSION', parm1, parm2 );
 phg_receives := retrieve_pricing_value( 'PHOTOGRAPHER_GETS', parm1, parm2 );
 postage := retrieve_pricing_value( 'POSTAGE', parm1, parm2 );
 if include_gift_certificate
  then
   gtotal := retrieve_pricing_value( 'GRAND_TOTAL_NOCERT', parm1, parm2 );
  else
   gtotal := retrieve_pricing_value( 'GRAND_TOTAL_WITHCERT', parm1, parm2 );
 end if;

end extract_photographer_order;

function grand_total_payment( poid in integer, include_gift_certificate in boolean default TRUE )
 return number
is

 parm1 		GLBX.MYARRAY;
 parm2 		GLBX.MYARRAY_NMB;

begin
 calculate_pricing( poid, parm1, parm2 );
 if include_gift_certificate
  then
   return( retrieve_pricing_value( 'GRAND_TOTAL_NOCERT', parm1, parm2 ));
  else
   return( retrieve_pricing_value( 'GRAND_TOTAL_WITHCERT', parm1, parm2 ));
 end if;

exception when others then
 glbx.error_details( 'GLBX', 'GRAND_TOTAL_PAYMENT',vpoid=>poid, errmsg=>sqlerrm);
end grand_total_payment;

function quick_grand_total_payment( poid in integer, item in varchar2 default null )
 return number
is

 parm1 		GLBX.MYARRAY;
 parm2 		GLBX.MYARRAY_NMB;

begin
 calculate_pricing( poid, parm1, parm2 );
 return( retrieve_pricing_value( nvl(item,'GRAND_TOTAL_WITHCERT'), parm1, parm2 ));

exception when others then
 glbx.error_details( 'GLBX', 'GRAND_TOTAL_PAYMENT',vpoid=>poid, errmsg=>sqlerrm);
end quick_grand_total_payment;

function backimg( surl in varchar2, acid in integer default null, backcol in varchar2, bckimg in integer default null, ownr in varchar2 default 'OWNER', extra_js in varchar2 default null)
 return varchar2
as
 cursor c1(acid integer) is select background_img from customer_account where aid = acid;
 retvar	integer;
begin
 if bckimg is null
  then
   open c1(acid);
   fetch c1 into retvar;
   close c1;
   if retvar is null then return( '<BODY ' || extra_js || 'BGCOLOR="#' || backcol || '">' ); end if;
  else
   retvar := bckimg;
 end if;
 return( '<BODY ' || extra_js || 'BACKGROUND="ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || retvar || '&parm1=DISPLAY_TYPE&parm2=RAW' ||
         '&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || ownr || '">');
exception when others then
 glbx.error_details( 'GLBX', 'BACKIMG',vaid=>acid,errmsg=>sqlerrm,extdet=>'BCKIMG:' || bckimg);
end backimg;

function urlencode( p_str in varchar2 ) return varchar2
as
    l_tmp   varchar2(6000);
    l_len   number default length(p_str);
    l_hex   varchar2(16) default '0123456789ABCDEF';
    l_num   number;
begin
    if ( p_str is NULL ) then
        return NULL;
    end if;

    if ( l_len*3 > 6000 ) then
        raise PROGRAM_ERROR;
    end if;

    for i in 1 .. length(p_str) loop
        l_num := ascii( substr(p_str,i,1) );
        l_tmp := l_tmp || '%' ||
                 substr(l_hex, mod(trunc(l_num/16),16)+1, 1 ) ||
                 substr(l_hex, mod(l_num,   16)+1, 1 );
    end loop;

    return l_tmp;
end urlencode;

function add_opt( p_switch in varchar2, p_value in varchar2 ) return varchar2
is
begin
    if ( p_value is null ) then
        return NULL;
    end if;
    return ' ' || p_switch || ' "' || p_value || '"';
end add_opt;


function dquote( p_str in varchar2 ) return varchar2
is
begin
	return '''' || replace( p_str, '''', '''''' ) || '''';
end dquote;

function censor (txt in varchar2, maxlength in integer default null, ignore_lf in boolean default FALSE, ignore_html in boolean default FALSE)
 return varchar2
 as
  ret_txt 	varchar2(32767);
  ctr		integer;
  ctr1		integer;
begin
if txt is null then return( null ); end if;
 -- || is Concat
 -- Translate to upper case
 ret_txt := txt;
 -- Loop through checking text for all combinations
 for crec in (select censored_word,replacement_word from data_censor) loop
  ctr := 1;
  loop
   ctr := instr( upper(ret_txt), crec.censored_word, ctr );
   exit when ctr = 0;
   ret_txt := substr(ret_txt,1,ctr-1) || crec.replacement_word ||
               substr(ret_txt,ctr+length(crec.censored_word));
  end loop;
 end loop;
 if not ignore_html
 then
 ctr := 1;
 loop
  ctr := instr( ret_txt, '<', ctr );
  exit when ctr = 0;
  ctr1 := instr( ret_txt, '>', ctr );
  exit when ctr1 = 0;
  ret_txt := substr( ret_txt, 1, ctr-1) || substr( ret_txt, ctr1+1);
 end loop;
 end if;
 loop
  ctr := instr( ret_txt, '`', ctr );
  exit when ctr = 0;
  ret_txt := substr( ret_txt, 1, ctr-1) || substr( ret_txt, ctr+1);
 end loop;
-- ret_txt := replace(ret_txt,'''','''''');   -- Replace single quotes by two single quotes
-- ret_txt := replace(ret_txt,'"','&quote;');   -- Replace single quotes by two single quotes
 if not ignore_lf
  then
   ret_txt := replace(ret_txt,chr(10),'<BR>');   -- Replace line feeds Unix
   ret_txt := replace(ret_txt,chr(13),'<BR>');   -- Replace line feeds NT
   ret_txt := replace(ret_txt,'<BR><BR>','<BR>'); -- Replace duplicate line feeds
 end if;
 if maxlength is not null then ret_txt := substr(ret_txt,1,maxlength); end if;
 return( ret_txt );
exception when others then
 glbx.error_details( 'GLBX', 'CENSOR',errmsg=>sqlerrm,extdet=>'TXT:' || txt);
 return( txt );
end censor;

-- Though this procedure is now redundant, it is left here in case it is required again in a future version
/*
function display_screen_size( pfx in varchar2 default 'w_d_', stype in integer, backcol in varchar2 default glbx.TITLE_BACKGROUND )
return varchar2
as
 tmp	varchar2(1000);
begin
 -- htp.p( '<TD WIDTH="30" valign="MIDDLE" ALIGN="RIGHT" ' || backcol || ' >' );
 tmp := htf.tableopen( cattributes=> 'cellpadding=0 cellspacing=0 border=0' );
 tmp := tmp || htf.tablerowopen;
 if stype = 1
  then
   tmp := tmp || htf.tabledata(htf.img( DECS.IMAGE_LOCATION || pfx || 'scr_1x.gif',cattributes=>'border=0',calt=>LNG.GLB_TXT_047 ));
   --tmp := tmp || htf.nl;
  else
   tmp := tmp || htf.tabledata(htf.anchor2( 'glbx.adjust_screen_size?stype=1', htf.img( DECS.IMAGE_LOCATION || pfx || 'scr_1.gif',cattributes=>'border=0',calt=>LNG.GLB_TXT_048 ),ctarget=>'_top'));
   --htp.nl;
 end if;
 tmp := tmp || htf.tablerowclose;
 tmp := tmp || htf.tablerowopen;

 if stype = 2
  then
   tmp := tmp || htf.tabledata(htf.img( DECS.IMAGE_LOCATION || pfx || 'scr_2x.gif',cattributes=>'border=0',calt=>LNG.GLB_TXT_049 ));
   --tmp := tmp || htf.nl;
  else
   tmp := tmp || htf.tabledata(htf.anchor2( 'glbx.adjust_screen_size?stype=2', htf.img( DECS.IMAGE_LOCATION || pfx || 'scr_2.gif',cattributes=>'border=0',calt=>LNG.GLB_TXT_050 ),ctarget=>'_top'));
   --tmp := tmp || htf.nl;
 end if;
 tmp := tmp || htf.tablerowclose;
 tmp := tmp || htf.tablerowopen;

 if stype = 3
  then
   tmp := tmp || htf.tabledata(htf.img( DECS.IMAGE_LOCATION || pfx || 'scr_3x.gif',cattributes=>'border=0',calt=>LNG.GLB_TXT_051 ));
  else
   tmp := tmp || htf.tabledata(htf.anchor2( 'glbx.adjust_screen_size?stype=3', htf.img( DECS.IMAGE_LOCATION || pfx || 'scr_3.gif',cattributes=>'border=0',calt=>LNG.GLB_TXT_052 ),ctarget=>'_top'));
 end if;
 tmp := tmp || htf.tablerowclose;
 tmp := tmp || htf.tableclose;

 return( tmp );
 -- htp.p( '</TD>' );
exception when others then
 glbx.error_details( 'GLBX', 'DISPLAY_SCREEN_SIZE',errmsg=>sqlerrm,extdet=>'STYPE:' || stype);
 return( NULL );
end display_screen_size;

procedure adjust_screen_size( stype in integer default 1 )
as
 ltype		varchar2(100);
 oldstype	integer;
 owner_id	integer;
 sts		varchar2(100);
begin
 glbx.cookie_id( oldstype, ltype, owner_id, sts, 'S', progcalled=>'GLBX.ADJUST_SCREEN_SIZE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 if stype not in (1,2,3,4,5) then htp.htmlopen; htp.bold( 'Invalid Type. Must be either 1, 2, 3' ); htp.htmlclose; return; end if;

 update login_session set screen_type = stype where sessid = owner_id;
 commit;

 if ltype = 'PHOTOGRAPHER'
  then
   phg.phg_master(stype);
  else
   cst.acct_master(owner_id,stype);
 end if;

exception when others then
 glbx.error_details( 'GLBX', 'ADJUST_SCREEN_SIZE',errmsg=>sqlerrm,extdet=>'STYPE:' || stype);
end adjust_screen_size;
*/

function get_image_style( lsessid in integer )
 return varchar2
as
 cursor c1(lsessid integer) is select browser_type, os from login_session where sessid = lsessid;
 c1rec  c1%ROWTYPE;
begin
 open c1( lsessid );
 fetch c1 into c1rec;
 close c1;
 if upper(c1rec.browser_type) = 'NETSCAPE' or upper(c1rec.os) in ('MACPPC') then return( NULL ); else return( 'STYLE="display:block;"' ); end if;
end get_image_style;

procedure acct_home( surl in varchar2, acid in integer default null, rnd in integer default 1234)
as

 cursor c3a(acid integer,utype varchar2,phgid integer) is
  select um.extras.orderby_scene,um.extras.title title,um.umo_scene_id,count('x') tot
  from umo um, customer_account ca
  where um.aid = acid and
        um.aid = ca.aid and
        ca.pid = phgid and
        um.umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT') and
        ((utype = 'PHOTOGRAPHER') or
         (utype in ('OWNER','PROFILE') and um.extras.enabled_phg='TRUE') or
         (utype in ('CUSTOMER','PROFILEG') and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE'))
  group by um.extras.orderby_scene,um.extras.title,um.umo_scene_id
  order by um.extras.orderby_scene;

 cursor c3(profid integer) is select count('x') from profile_scenes where profile_id = profid;

 cursor c4(acid integer) is
  select um.umo_id,um.photo_master,um.extras.title title ,um.umo_scene_id
  from umo um, umo_attribute ut, umo_attributes uts
  where um.aid=acid and
        um.umo_id = ut.umo_id and
        ut.attribute_id = uts.attribute_id and
        ut.value = 'DETAIL PHOTO' and
        sub_category='QUALITY';

 cursor c5(acid integer) is select * from customer_price_book where aid = acid;

 cursor c6(acid integer, ltype varchar2) is
  select distinct mc.display_description,mc.expiry_date,mc.warranty_id,mc.detailed_description,mc.mfc_clr_id
  from customer_contact cc, customer_interest ci, mfctr_interest_group mig, mfctr_clearance mc
       where cc.contact_id = ci.contact_id and
             ci.interest_id = mig.interest_id and
             mc.mfc_clr_id  = mig.mfc_clr_id and
             mc.expiry_date is not null and
             mc.expiry_date >= sysdate and
             mc.contact_home_page = 'T' and
             cc.aid = acid and
             cc.login_type = ltype
  order by mc.expiry_date desc;

 cursor c7(acid integer) is select * from customer_account where aid = acid;
 cursor c7p(profid integer) is select * from customer_profile where profile_id = profid;

 cursor c8(acid integer) is select count('x') from umo um where um.aid = acid and um.umo_type <> 'AUDIO' and um.audio_original.description is not null;

 cursor c9(acid integer, utype varchar2) is
   select count('x')
   from umo um
   where um.aid = acid and
         um.umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT') and
        ((utype = 'PHOTOGRAPHER') or
         (utype in ('OWNER','PROFILE') and um.extras.enabled_phg='TRUE') or
         (utype in ('CUSTOMER','PROFILEG','VIRTUAL') and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE'));

 cursor c10(acid integer, utype varchar2) is
  select um.umo_id,um.photo_master,um.extras.title ,um.umo_scene_id
  from umo um
  where um.aid = acid and
        um.umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT') and
        ((utype = 'PHOTOGRAPHER') or
         (utype in ('OWNER','PROFILE') and um.extras.enabled_phg='TRUE') or
         (utype in ('CUSTOMER','PROFILEG','VIRTUAL') and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE'));

 cursor c11(profid integer) is select count('x') from profile_scenes where profile_id = profid;

 cursor c12(acid integer, utype varchar2, phgid integer, profid integer) is
  select um.extras.orderby_scene,um.extras.title title,um.umo_scene_id,count('x') tot
  from umo um, customer_account ca, profile_scenes ps
  where um.aid = acid and
        um.aid = ca.aid and
        ca.pid = phgid and
        um.extras.title is not null and
        um.umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT') and
        ((utype = 'PHOTOGRAPHER') or
         (utype in ('OWNER','PROFILE') and um.extras.enabled_phg='TRUE') or
         (utype in ('CUSTOMER','PROFILEG') and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE')) and
        ps.umo_scene_id = um.umo_scene_id and
        ps.profile_id = profid
  group by um.extras.orderby_scene,um.extras.title,um.umo_scene_id
  order by um.extras.orderby_scene;

 cursor c13(acid integer, phgr integer, imgtype varchar2) is
  select um.photo_master, um.umo_id, um.version, 'K' typ, um.extras.orderby_nmb
     from umo um, customer_account ca
     where um.aid = ca.aid and
           ca.pid = phgr and
           um.is_global = 'T' and
           umo_type = imgtype;

 cursor c14(acid integer) is
  select pid,advert,business_name,username,home_site,logo_phid,abn_number,private_gallery
  from photographer where pid in (select pid from customer_account where aid=acid);


 c1rec		customer_account%ROWTYPE;
 c1prec		customer_profile%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c13rec		c13%ROWTYPE;
 c14rec		c14%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec 	theme_types%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 fl 		UTL_FILE.FILE_TYPE;
 showtotal	boolean;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 photo_name	varchar2(100);
 hght		integer;
 ctr		integer;
 totaudio	integer;
 totprof	integer;
 width		integer;
 height		integer;
 cc_id		integer;
 nmb		integer;
 nmb_tot	integer;
 foundrec 	boolean;
 orig_width	integer;
 proftot	integer;
 b2c_value	char(1);
 orig_height	integer;
 ownid		integer;
 backimg	varchar2(1000);
 xltype		varchar2(100);
 frm_goto	varchar2(100);
 tmpstr		varchar2(100);
 bfr		varchar2(25000);
 tmp		varchar2(32767);
 empty_array	GLBX.MYARRAY;
 imgdisp	varchar2(100);

begin

 if acid is null
  then
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GLBX.ACCT_HOME', iscust=>TRUE );
  else
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GLBX.ACCT_HOME', iscust=>FALSE );
 end if;

 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 theme_rec := cust_get_theme_types( c1rec.aid );

 -- If API Call it
 if c1rec.home_page_style = 'A'
  then
     pfx := glbx.get_thm( c1rec.theme_name );
     if nvl(c1rec.home_page_override,pfx.home_page_external_call) is not null
      then
       execute immediate
       'begin ' || nvl(c1rec.home_page_override,pfx.home_page_external_call) ||
       '(surl=>:surl,ltype=>:ltype,acid=>:acid);' ||
       'end;'
       using glbx.rndsurl(surl),ltype,acid;
       return;
     end if;
 end if;

 -- If Search Page call it
 if c1rec.home_page_style = 'S'
  then
   cst.acct_search(surl=>glbx.rndsurl(surl),acid=>acid);
   return;
 end if;

 -- If Order Page call it
 if c1rec.home_page_style = 'O'
  then
   fname.acct_orders(surl=>glbx.rndsurl(surl),acid=>acid);
   return;
 end if;

 -- If Photographer Detail Page call it
 if c1rec.home_page_style = 'P'
  then
   cst.acct_phg(surl=>glbx.rndsurl(surl),acid=>acid);
   return;
 end if;

 -- If External Page call it
 if c1rec.home_page_style = 'X'
  then
   owa_util.redirect_url( glbx.adjust_for_http(c1rec.home_page_link ));
   return;
 end if;

 -- Look for Home Page Dedicated Display of Category of User Event
 if ltype = 'PHOTOGRAPHER'
  then
   totprof := 0;
   xltype := 'OWNER';
   if c1rec.home_page_style in ('V','N')
    then
     if (nvl(c1rec.site_type,'S') = 'S')
      then
       phg.phg_disp_by_scene_fm(surl,acid,scnm=>c1rec.home_page_category);
      else
       cst.disp_event(surl=>glbx.rndsurl(surl),left_api_parm=>null,start_from=>1, acid=>acid );
     end if;
     return;
   end if;

  elsif ltype in ('PROFILE','PROFILEG')
   then
    open c11(profid);
    fetch c11 into totprof;
    close c11;
    xltype := ltype;
    if c1rec.home_page_style in ('V','N')
     then
      if (nvl(c1rec.site_type,'S') = 'S')
       then
        cst.disp_category(surl=>glbx.rndsurl(surl),left_api_parm=>c1rec.home_page_category,start_from=>1 );
       else
        cst.disp_event(surl=>glbx.rndsurl(surl),left_api_parm=>null,start_from=>1 );
      end if;
      return;
    end if;

   else
    totprof := 0;
    xltype := ltype;
    if c1rec.home_page_style in ('V','N')
     then
      if (nvl(c1rec.site_type,'S') = 'S')
       then
        cst.disp_category(surl=>glbx.rndsurl(surl),left_api_parm=>c1rec.home_page_category,start_from=>1 );
       else
        cst.disp_event(surl=>glbx.rndsurl(surl),left_api_parm=>null,start_from=>1 );
      end if;
      return;
    end if;
 end if;

 -- Template
 if c1rec.home_page_style = 'T'
  then
    begin
     if c1rec.link_name is null
      then
       fl := utl_file.fopen( glbx.extract_master_parameter('IMAGE_DIR') || DECS.UNIX_OR_NT || 'order_style', c1rec.home_page_link, 'r', 25000 );
      else
       fl := utl_file.fopen( glbx.extract_master_parameter('IMAGE_DIR') || DECS.UNIX_OR_NT || 'order_style' || DECS.UNIX_OR_NT || c1rec.link_name, c1rec.home_page_link, 'r', 25000 );
     end if;
    exception
     when others then
      --htp.p( glbx.extract_master_parameter('IMAGE_DIR') || DECS.UNIX_OR_NT || 'order_style' || DECS.UNIX_OR_NT || subdir ); htp.nl;
      htp.p( 'Error: Cannot find HTML Page:' || voidrec.login_html_subdir );
      return;
    end;

    loop
     begin
      utl_file.get_line( fl, bfr );
      htp.p( replace(replace(bfr,'<PICTION_ACCOUNT_NAME>',c1rec.account_name),'<PICTION_SURL>', surl ) );
     exception
      when others
       then
        utl_file.fclose( fl );
        return;
      end;
    end loop;

   return;

 end if;

 open c4( c1rec.aid );
 fetch c4 into c4rec;
 close c4;

 if substr( c1rec.home_page_options,18,1) = 'T'
  then
   dbms_random.Initialize(to_number(TO_CHAR(SYSDATE,'SSSSS')));
   nmb := abs(dbms_random.Random);
   dbms_random.terminate;
   open c9(c1rec.aid,ltype);
   fetch c9 into nmb_tot;
   close c9;
   nmb := mod(nmb,nmb_tot) + 1;
   open c10(c1rec.aid,ltype);
   for j in 1..nmb loop
    fetch c10 into c4rec;
    if c10%NOTFOUND then exit; end if;
   end loop;
   close c10;
 end if;

 pfx := glbx.get_thm( c1rec.theme_name );
 if substr( c1rec.home_page_options,19,1) = 'T'
  then
   if c1rec.background_img is not null
    then
     backimg := glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype);
    else
     backimg := '<BODY BGCOLOR="#' || pfx.det_back || '" >';
   end if;
  else
   backimg := '<BODY BGCOLOR="#' || pfx.det_back || '" >';
 end if;

 if ltype = 'PHOTOGRAPHER'
  then
   glbx.main_title( surl, null,backimg,helpid=>'G01',stype=>stype+1,sstyle=>pfx.det_text_font,sclr=>pfx.det_text_colour,
                  det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font, h2_sstyle=>pfx.det_title_font,
                  h2_sclr=>pfx.det_title_colour,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour,
                  errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  else
   glbx.main_title( surl, null,backimg,helpid=>'G01',stype=>stype+1,sstyle=>pfx.det_text_font,sclr=>pfx.det_text_colour,
                  det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font, h2_sstyle=>pfx.det_title_font,
                  h2_sclr=>pfx.det_title_colour,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour,
                  errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,sim_three_frame=>pfx.sim_three_frame,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 end if;

 htp.p('<CENTER>');
 if c1rec.home_page_style = 'W'
  then
   disp_news(surl, c1rec.aid, stype, ltype, pfx, c1rec, theme_rec, profid);
   return;
 end if;

 if ltype = 'PHOTOGRAPHER'
  then
   if substr( c1rec.home_page_options,1,1) = 'T' then htp.header( 2, glbx.userpref( c1rec.pid, acid, 'TITLE_DETAILS' ), 'CENTER'); end if;
   if substr( c1rec.home_page_options,2,1) = 'T' then glbx.instruction( glbx.userpref( c1rec.pid, acid, 'HELP_DETAILS'), pfx ); end if;
  else
   if substr( c1rec.home_page_options,1,1) = 'T' then htp.header( 2, glbx.userpref( c1rec.pid, c1rec.aid, 'TITLE_DETAILS' ), 'CENTER'); end if;
   if substr( c1rec.home_page_options,2,1) = 'T' then glbx.instruction( glbx.userpref( c1rec.pid, c1rec.aid, 'HELP_DETAILS'), pfx ); end if;
 end if;

 if substr( c1rec.home_page_options,3,1)  = 'T' or
    substr( c1rec.home_page_options,4,1)  = 'T' or
    substr( c1rec.home_page_options,5,1)  = 'T' or
    substr( c1rec.home_page_options,6,1)  = 'T' or
    substr( c1rec.home_page_options,7,1)  = 'T' or
    substr( c1rec.home_page_options,9,1)  = 'T' or
    substr( c1rec.home_page_options,12,1) = 'T' or
    substr( c1rec.home_page_options,16,1) = 'T' or
    substr( c1rec.home_page_options,17,1) = 'T' or
    substr( c1rec.home_page_options,20,1) = 'T'
  then
    htp.tableopen( cattributes=>' cellpadding=0 cellspacing=2 border=0' );
    htp.tablerowopen;

    htp.p( '<TD>' );
    htp.tableopen( cattributes=>' cellpadding=2 cellspacing=0 border=0' );
    htp.tablerowopen;
 end if;

 if pfx.det_cell_back is null
  then
   htp.p( '<TD valign="TOP" ALIGN="CENTER" style="text-align: center;">' );
  else
   htp.p( '<TD valign="TOP" ALIGN="CENTER" bgcolor="#' || pfx.det_cell_back || '" style="text-align: center;">' );
 end if;

 if substr( c1rec.home_page_options,5,1) = 'T'
  then
   htp.p( '<FONT SIZE=1>' || htf.bold( lng.CST_TXT_031 ) || '</FONT>');
   htp.nl;
   htp.p( '<FONT SIZE=+2>' || htf.bold( htf.italic(c1rec.account_name) ) || '</FONT>');
 end if;
 if c1rec.date_held is not null and substr( c1rec.home_page_options,6,1) = 'T'
  then
   htp.nl;
   htp.nl;
   htp.p( '<FONT SIZE=1>' || htf.bold( lng.CST_TXT_032 ) || '</FONT>');
   htp.nl;
   htp.p(htf.bold( c1rec.date_held));
 end if;
 htp.nl;
 htp.nl;
 if substr( c1rec.home_page_options,7,1) = 'T'
  then
   htp.p('<FONT SIZE=1>' || htf.bold( lng.CST_TXT_033 ) || '</FONT>');
   htp.nl;
   htp.p(htf.bold( to_char(c1rec.date_expires,LNG.MASK) ));
 end if;
 if substr( c1rec.home_page_options,9,1) = 'T'
  then
   open c8(nvl(acid,c1rec.aid));
   fetch c8 into totaudio;
   close c8;
   if totaudio > 0
    then
      htp.nl;
      htp.nl;
      htp.p(htf.bold( LNG.GLB_TXT_080));
      htp.nl;
      htp.anchor( 'glbx.list_all_audio?surl=' || surl || '&acid=' || acid, htf.img( DECS.IMAGE_LOCATION || 'adminc/audio.gif',cattributes=>'border=1',calt=>lng.GLB_ALT_061 ));
   end if;
 end if;
 htp.p( '</TD>' );

 --- Display Manufacturer Clearance Sales
 foundrec := FALSE;
 if substr( c1rec.home_page_options,12,1) = 'T'
  then
   tmp := htf.bold( LNG2.FNM_TXT_081 ) || htf.nl || htf.nl || htf.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=2' );
   tmp := tmp || htf.tablerowopen || htf.tabledata( htf.bold(LNG3.ADM_TXT_105 ),cattributes=>pfx.qbground);
   tmp := tmp || htf.tabledata( htf.bold(LNG2.FNM_TXT_053 ),cattributes=>pfx.qbground) || htf.tablerowclose;
   cc_id := c1rec.aid;
   if ltype = 'PROFILE' then cc_id := profid; end if;
   for c6rec in c6(cc_id,xltype) loop
    foundrec := TRUE;
    if ltype = 'PHOTOGRAPHER'
     then
      tmp := tmp || htf.tablerowopen || htf.tabledata( c6rec.display_description,cattributes=>pfx.qcbground );
     else
      tmp := tmp || htf.tablerowopen || htf.tabledata( htf.anchor( 'cst.mfc_clearance?surl=' || glbx.rndsurl(surl) || '&mcid=' || c6rec.mfc_clr_id, c6rec.display_description ),cattributes=>pfx.qcbground);
    end if;
    tmp := tmp || htf.tabledata( to_char(c6rec.expiry_date,LNG.MASK),cattributes=>pfx.qcbground) || htf.tablerowclose;
   end loop;
   tmp := tmp || htf.tableclose;
 end if;

 -- Display Image
 if (c4rec.umo_id is not null and not foundrec and substr( c1rec.home_page_options,4,1) = 'T') or (nvl(substr( c1rec.home_page_options,17,1),'F') = 'T')
  then
    imgdisp := get_image_style( owner_id );
      if glbx.userpref(c1rec.pid,c1rec.aid,'DISPLAY_ORIGINAL') = LNG.PHG_TXT_045
       then
        orig_width := c4rec.photo_master.width;
        orig_height := c4rec.photo_master.height;
       else
        orig_width := trunc(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH_ACTUAL',stype)/4);
        orig_height := (trunc(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH_ACTUAL',stype)/4) / c4rec.photo_master.width) * c4rec.photo_master.height;
      end if;
      if pfx.det_cell_back is null
       then
        htp.p( '<TD valign="TOP" ALIGN="CENTER" style="text-align: center;">' );
       else
        htp.p( '<TD valign="TOP" ALIGN="CENTER" bgcolor="#' || pfx.det_cell_back || '" style="text-align: center;">' );
      end if;
      htp.tableopen( cattributes=>'style="text-align: center;"  cellpadding=0 cellspacing=0 bordercolordark="#' || pfx.tnail_border_colour || '" bordercolorlight="#' || pfx.tnail_border_colour_l || '" border=' || to_char(nvl(pfx.tnail_border,0)) );
        htp.tablerowopen;
	photo_name :=  ump.uma_attribute( surl,c4rec.umo_id, 'PHOTO', 'NAME' );
	if nvl(substr( c1rec.home_page_options,17,1),'F') = 'F'
	 then

	  if nvl(substr( c1rec.home_page_options,16,1),'F') = 'F'
	   then
             htp.tabledata('<IMG BORDER=0 WIDTH=' || orig_width || ' HEIGHT=' || orig_height || ' SRC="' ||
                           'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c4rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=AID&parm2=' || to_char(acid) ||
                           '&parm1=LOGIN_TYPE&parm2=' || ltype ||
                           '" ALT="' || photo_name || '" ' || imgdisp || '>', cattributes=>'style="text-align: center;"  align="CENTER" valign="MIDDLE" bgcolor="#' || pfx.tnail_matte_colour || '" width="' || to_char(orig_width + nvl(pfx.tnail_width,0)) || '" height="' || to_char(orig_height + nvl(pfx.tnail_width,0)) || '"' );
	   else
	    if pfx.fullimg_jscript_popup = 'F'
	     then
               htp.tabledata(
	  	   htf.anchor(
	             'cst.disp_acct_photo?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid || '&photo_id=' || c4rec.umo_id || '&footer_api=cst.disp_category&left_api_parm=' || c4rec.umo_scene_id  || '&current_page_number=1&display_detail=' || pfx.display_style || '&how_display=' || pfx.fullimg_display_type,
	             '<IMG BORDER=0 WIDTH=' || orig_width || ' HEIGHT=' || orig_height || ' SRC="' ||
                     'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c4rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=AID&parm2=' || to_char(acid) ||
                     '&parm1=LOGIN_TYPE&parm2=' || ltype || '" ALT="' || photo_name || '" ' || imgdisp || '>' ), cattributes=>'style="text-align: center;"  align="CENTER" valign="MIDDLE" bgcolor="#' || pfx.tnail_matte_colour || '" width="' || to_char(orig_width + nvl(pfx.tnail_width,0)) || '" height="' || to_char(orig_height + nvl(pfx.tnail_width,0)) || '"' );
             else
               htp.tabledata(
	  	   htf.anchor2(
	             'cst.disp_acct_photo?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid || '&photo_id=' || c4rec.umo_id || '&footer_api=cst.disp_category&left_api_parm=' || c4rec.umo_scene_id  || '&current_page_number=1&display_detail=' || pfx.display_style || '&how_display=' || pfx.fullimg_display_type,
	             '<IMG BORDER=0 WIDTH=' || orig_width || ' HEIGHT=' || orig_height || ' SRC="' ||
                     'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c4rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=AID&parm2=' || to_char(acid) ||
                     '&parm1=LOGIN_TYPE&parm2=' || ltype || '" ALT="' || photo_name || '" ' || imgdisp || '>', ctarget=>'NEW_POPUP' ), cattributes=>'style="text-align: center;"  align="CENTER" valign="MIDDLE" bgcolor="#' || pfx.tnail_matte_colour || '" width="' || to_char(orig_width + nvl(pfx.tnail_width,0)) || '" height="' || to_char(orig_height + nvl(pfx.tnail_width,0)) || '"' );
             end if;
	  end if;

	 else
	  -- Use Photographer Logo as Central Image
	  open c13( c1rec.pid, c1rec.pid, 'ICON' );
	  fetch c13 into c13rec;
	  close c13;
	  open c14(c1rec.aid);
	  fetch c14 into c14rec;
	  close c14;
          width := to_number(ump.uma_attribute( surl,c13rec.umo_id, 'ICON', 'DISPLAY_WIDTH' ));
          height := to_number(ump.uma_attribute( surl,c13rec.umo_id, 'ICON', 'DISPLAY_HEIGHT' ));
	  if nvl(substr( c1rec.home_page_options,16,1),'F') = 'F'
	   then

            htp.tabledata('<IMG BORDER=0 WIDTH=' || width || ' HEIGHT=' || height || ' SRC="' ||
                  'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c13rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' ||
                  '&parm1=LOGIN_TYPE&parm2=' || ltype ||
                  '&parm1=OVERRIDE_DISPLAY&parm2=ICON&parm1=AID&parm2=' ||
                  '" ALT="' || glbx.adjust_for_http(c14rec.home_site) || '" ' || imgdisp || '>');

	   else
            htp.tabledata(htf.anchor2( glbx.adjust_for_http(c14rec.home_site),'<IMG BORDER=0 WIDTH=' || width || ' HEIGHT=' || height || ' SRC="' ||
                  'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c13rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' ||
                  '&parm1=LOGIN_TYPE&parm2=' || ltype ||
                  '&parm1=OVERRIDE_DISPLAY&parm2=ICON&parm1=AID&parm2=' ||
                  '" ALT="' || glbx.adjust_for_http(c14rec.home_site) || '" ' || imgdisp || '>',ctarget=>'_top' ));
          end if;
	end if;
        htp.tablerowclose;
      htp.tableclose;
      htp.p( '</TD>' );

 elsif foundrec and substr( c1rec.home_page_options,12,1) = 'T'
  then
   if pfx.det_cell_back is null
    then
      htp.p( '<TD valign="TOP" ALIGN="CENTER" style="text-align: center;">' );
    else
      htp.p( '<TD valign="TOP" ALIGN="CENTER" bgcolor="#' || pfx.det_cell_back || '" style="text-align: center;">' );
   end if;
   htp.p( tmp );
   htp.p( '</TD>' );
 end if;

 if substr( c1rec.home_page_options,3,1) = 'T'
  then
   if pfx.det_cell_back is null
    then
     htp.p( '<TD valign="TOP" ALIGN="CENTER" STYLE="font-family: ''' || pfx.instruct_text_font || '''; color: #' || pfx.instruct_text_colour || '">' );
    else
     htp.p( '<TD valign="TOP" ALIGN="CENTER" bgcolor="#' || pfx.det_cell_back || '" STYLE="background-color: #' || pfx.det_cell_back || ' font-family: ''' || pfx.instruct_text_font || '''; color: #' || pfx.instruct_text_colour || '">' );
   end if;


   if ltype in ('PROFILE','PROFILEG')
    then
     open c3(profid);
     fetch c3 into proftot;
     close c3;
     ownid := profid;
    elsif ltype = 'PHOTOGRAPHER'
     then
      proftot := 0;
      ownid := c1rec.pid;
     else
      proftot := 0;
      ownid := c1rec.aid;
   end if;

   empty_array(1) := NULL;
   if substr( c1rec.home_page_options,20,1) = 'T'
    then
     tmpstr := glbx.userpref(c1rec.pid,c1rec.aid,'HOME_TITLE');
     if tmpstr is not null then htp.bold( tmpstr ); htp.nl; end if;
     tmpstr := glbx.userpref(c1rec.pid,c1rec.aid,'HOME_HELP');
     if tmpstr is not null then htp.italic( tmpstr ); htp.nl; end if;
     showtotal := TRUE;
    else
     tmpstr := glbx.userpref(c1rec.pid,c1rec.aid,'HOME_TITLE');
     if tmpstr is not null then htp.bold( tmpstr ); htp.nl; end if;
     tmpstr := glbx.userpref(c1rec.pid,c1rec.aid,'HOME_HELP');
     if tmpstr is not null then htp.italic( tmpstr ); htp.nl; end if;
     showtotal := FALSE;
   end if;
   --if pfx.nested_scene_style in (LNG3.ADM_TXT_571,LNG3.ADM_TXT_576) then pfx.nested_scene_style := LNG3.ADM_TXT_572; end if;
   if pfx.nested_scene_style in (LNG3.ADM_TXT_571,LNG3.ADM_TXT_576) then pfx.nested_scene_style := 'HOME'; end if;
   glbx.scene_display( surl, c1rec, pfx, ltype, stype, ownid,
                        substr(theme_rec.theme_data,92,1),
                        pfx.nested_scene_style,
                        null,
                        null, proftot, empty_array, showtotal, 'ALIGN="LEFT" VALIGN="TOP"' );
   htp.p( '</TD>' );
 end if;

 if substr( c1rec.home_page_options,3,1)  = 'T' or
    substr( c1rec.home_page_options,4,1)  = 'T' or
    substr( c1rec.home_page_options,5,1)  = 'T' or
    substr( c1rec.home_page_options,6,1)  = 'T' or
    substr( c1rec.home_page_options,7,1)  = 'T' or
    substr( c1rec.home_page_options,9,1)  = 'T' or
    substr( c1rec.home_page_options,12,1) = 'T' or
    substr( c1rec.home_page_options,16,1) = 'T' or
    substr( c1rec.home_page_options,17,1) = 'T' or
    substr( c1rec.home_page_options,20,1) = 'T'
  then
   htp.tablerowclose;
   htp.tableclose;
   htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
   htp.tableclose;
end if;

 if substr( c1rec.home_page_options,8,1) = 'T'
  then
   open c5(c1rec.aid);
   fetch c5 into c5rec;
   close c5;
   purchord := glbx.get_purchase_order( owner_id );
   if purchord.oid is null
    then
     voidrec := glbx.get_order_style( glbx.get_order_style( c1rec.aid, profid, ltype, b2c_value ));
    else
     voidrec := glbx.get_order_style( purchord.oid );
   end if;
   if (c5rec.valid_until is not null)
    then
     if sysdate > c5rec.valid_until
      then
       htp.header(3,voidrec.text_delayed_pricing,'CENTER');
      else
       htp.header(3,voidrec.text_alt_price_book || ' ' || to_char(c5rec.valid_until,LNG.MASK),'CENTER');
     end if;
   end if;
 end if;

 if substr( c1rec.home_page_options,13,1) = 'T'
  then
    htp.header(3,c1rec.username,'CENTER');
 end if;

 if substr( c1rec.home_page_options,14,1) = 'T' and c1rec.home_page_link is not null
  then
   if substr( c1rec.home_page_options,15,1) = 'T'
    then
     htp.anchor2( replace(c1rec.home_page_link,'~SURL',SURL),c1rec.link_name, ctarget=>'HOME_WINDOW' );
    else
     htp.anchor(replace(c1rec.home_page_link,'~SURL',SURL), c1rec.link_name);
   end if;
 end if;

 -- Display Column Listing of Categories
 -- Display Column Listing of Categories
 if substr( c1rec.home_page_options,11,1) = 'T' or
    substr( c1rec.home_page_options,21,1) = 'T'
  then
   htp.tableopen( cattributes=>' cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
   for c3rec in c3a( c1rec.aid, ltype, c1rec.pid ) loop
    if (mod(c3a%ROWCOUNT,3) = 1 and substr( c1rec.home_page_options,11,1) = 'T') or
       (mod(c3a%ROWCOUNT,5) = 1  and substr( c1rec.home_page_options,21,1) = 'T')
     then
      htp.tablerowclose;
      htp.tablerowopen;
    end if;
    if ltype = 'PHOTOGRAPHER'
     then
      show_link(c1rec.aid,stype,pfx,c3rec.umo_scene_id,showtotal,'phg.phg_disp_by_scene_fm?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid || '&scnm=' || c3rec.umo_scene_id,c3rec.title,null, TRUE, NULL, bf131=>'HOME');
      --htp.tabledata( htf.anchor( 'phg.phg_disp_by_scene_fm?surl=' || surl || '&acid=' || c1rec.aid || '&scnm=' || c3rec.umo_scene_id, nvl(c3rec.title,'&nbsp;') || ' - #' || c3rec.tot || ')' ) );
     else
      show_link(c1rec.aid,stype,pfx,c3rec.umo_scene_id,showtotal, 'cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id  || '&start_from=1',c3rec.title, null, TRUE, NULL, bf131=>'HOME');
      -- htp.tabledata( htf.anchor( 'cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id  || '&start_from=1', nvl(c3rec.title,'&nbsp;') || '- #' || c3rec.tot || ')' ) );
    end if;
   end loop;
   htp.tablerowclose;
   htp.tableclose;
 end if;

 if substr( c1rec.home_page_options,10,1) = 'T'
  then
   htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );
    htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0' );
    htp.tablerowopen;
     htp.p(glbx.novelty_option( surl, pfx, null, null,  1, null, c1rec, ltype, 'HOME', 'HOR_TABLE', 0 ));
    htp.tablerowclose;
    htp.tableclose;
   htp.p( '</TD>' );
 end if;

 if c1rec.home_page_style = 'Z'
  then
   disp_news(surl, c1rec.aid, stype, ltype, pfx, c1rec, theme_rec, profid);
   return;
 end if;

 htp.p('</CENTER>');
 glbx.close_page( pfx );
exception when others then
 glbx.error_details( 'GLBX', 'ACCT_HOME',c1rec.pid,c1rec.aid,errmsg=>sqlerrm);
end acct_home;

procedure send_emails( surl in varchar2, p1 in varchar2, acid in integer )
as
 cursor c1(acid integer) is select * from customer_account where aid = acid;
 cursor c2(acid integer) is select email_address from grab_email where aid = acid;
 cursor c3(phgid integer) is select business_name,home_site from photographer where pid = phgid;

 c1rec		c1%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'GLBX.SEND_EMAILS', iscust=>TRUE );
 if sts is not null
  then
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'GLBX.SEND_EMAILS', iscust=>FALSE );
   if sts is not null
    then
     glbx.redisplay_login_page( sts );
     return;
   end if;
 end if;

 if ltype not in ('OWNER','PHOTOGRAPHER')
  then
   return; -- Trying to break in
 end if;

 if ltype = 'OWNER'
  then
   open c1(owner_id);
  else
   open c1(acid);
 end if;
 fetch c1 into c1rec;
 close c1;
 open c3(c1rec.pid);
 fetch c3 into c3rec;
 close c3;
 gcode(1) := 'ACCOUNT_NAME';
 gparam(1) := c1rec.account_name;
 gcode(2) := 'WEB_SITE';
 gparam(2) := nvl(c3rec.home_site,extract_master_parameter('PICTION_HOME_PAGE'));
 gcode(3) := 'MESSAGE';
 gparam(3) := censor(p1);
 gcode(4) := 'PHOTOGRAPHER';
 gparam(4) := c3rec.business_name;
 gcode(5) := 'SIGNATURE';
 gparam(5) := glbx.extract_master_parameter('MAIL SIGNATURE');
 htp.htmlopen;
  htp.header( 2,LNG.GLB_TXT_089, 'CENTER' );
  htp.nl;
  htp.ulistopen;
 for c2rec in c2(nvl(acid,owner_id)) loop
   glbx.send( gcode, gparam, 'notify_guests.tmp', c2rec.email_address, LNG.GLB_TXT_090 || initcap(c1rec.account_name), glbx.extract_master_parameter('MAIL_FROM'),ltype=>ltype,own_id=>owner_id, scode=>'NG1', v_pid=>c1rec.pid, v_aid=>c1rec.aid);
   htp.listitem( c2rec.email_address );
 end loop;
 htp.ulistclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'GLBX', 'SEND_EMAILS',c1rec.pid,owner_id,errmsg=>sqlerrm);
end send_emails;

procedure modify_cust_access( surl in varchar2, acid in integer default null, p1 in varchar2, p2 in varchar2)
as

 cursor c1(acid integer) is select pid from customer_account where aid = acid;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 act		integer;
 phg		integer;
begin
 if acid is null
  then
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'GLBX.MODIFY_CUST_ACCESS', iscust=>TRUE );
  else
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'GLBX.MODIFY_CUST_ACCESS', iscust=>FALSE );
 end if;
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 if ltype not in ('OWNER','PHOTOGRAPHER')
  then
   return; -- Trying to break in
 end if;
 if ltype = 'OWNER'
  then
   update customer_account set
      customer_disabled = decode(p1,'T','T','F'),
      customer_message = p2
    where aid = owner_id;
    act := owner_id;
    open c1(owner_id);
    fetch c1 into phg;
    close c1;
  else
   update customer_account set
      customer_disabled = decode(p1,'T','T','F'),
      customer_message = p2
    where aid = acid and pid = owner_id;
    act := acid;
    phg := owner_id;
 end if;
 cst.acct_details(surl,acid);
exception when others then
 glbx.error_details( 'GLBX', 'MODIFY_CUST_ACCESS',vaid=>acid,errmsg=>sqlerrm);
end modify_cust_access;

procedure list_all_audio( surl in varchar2, acid in integer)
as
 cursor c1a(acid integer) is select * from customer_account where aid = acid;
 cursor c1b(phgid integer,acid integer) is select * from customer_account where aid=acid and pid = phgid;
 cursor c2(acid integer) is
  select um.umo_id, um.extras.title, um.umo_scene_id, um.audio_original.description sze, um.audio_original.format fmt, um.photo_thumbnail.width wd, um.photo_thumbnail.height hg
  from umo um
  where um.aid = acid and
        um.umo_type <> 'AUDIO' and
        um.audio_original.description is not null
  order by um.extras.orderby_scene;

 crec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 backcol	varchar2(100);
 photo_name	varchar2(100);

begin

 if acid is null
  then
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'GLBX.LIST_ALL_AUDIO', iscust=>TRUE );
  else
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'GLBX.LIST_ALL_AUDIO', iscust=>FALSE );
 end if;
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 if ltype = 'PHOTOGRAPHER'
   then
   open c1b(owner_id,acid);
   fetch c1b into crec;
   close c1b;
 else
   open c1a(owner_id);
   fetch c1a into crec;
   close c1a;
 end if;
 if crec.aid is null then return; end if; -- Someone trying to break in
 pfx := glbx.get_thm( crec.theme_name );
 glbx.main_title( surl, lng.GLB_TXT_062,glbx.backimg(surl,owner_id,pfx.text_back,crec.background_img),helpid=>'G02',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 htp.formopen( 'cst.accept_display' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
   if ltype in ('OWNER','CUSTOMER')
     then
	 htp.formhidden( 'P0', '0' );
	 htp.formhidden( 'P1', '0' );
	 htp.formhidden( 'PA', '0' );
	 htp.formhidden( 'PB', '0' );
	 htp.formhidden( 'PC', '0' );
	 htp.formhidden( 'PPN', '0' );
	 htp.formhidden( 'FOOTER_API', null );
	 htp.formhidden( 'LEFT_API_PARM', null );
	 htp.formhidden( 'CURRENT_PAGE_NUMBER', null );
	 htp.formhidden( 'DISPLAY_DETAIL', null );
	 htp.tableopen;
	  htp.tablerowopen;
	   htp.tabledata(htf.formimage( 'Add_To_Trolley',DECS.IMAGE_LOCATION || 'adminc/order.gif', cattributes=>'BORDER=0' ));
	  htp.tablerowclose;
	 htp.tableclose;
   end if;

  htp.tableopen( cattributes=>'cellpadding=0 cellspacing=1 border=1 ' || glbx.TABLE_BACKGROUND );
   htp.tablerowopen;
   if ltype in ('OWNER','CUSTOMER')
     then
      htp.tabledata('<b><font size="+1">' || lng.GLB_TXT_063 || '</font></b>',cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
    end if;
    htp.tabledata('<b><font size="+1">' || lng.GLB_TXT_064 || '</font></b>',cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
    htp.tabledata('<b><font size="+1">' || lng.GLB_TXT_065 || '</font></b>',cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
    htp.tabledata('<b><font size="+1">' || lng.GLB_TXT_066 || '</font></b>',cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tablerowclose;

  for c2rec in c2(crec.aid) loop
   htp.tablerowopen;
    if mod(c2%ROWCOUNT,2) = 0
     then
      backcol := 'bgcolor="#' || nvl(pfx.vert_colour_a,glbx.QUERY_CELL_BACKGROUND1) || '"';
     else
      backcol := 'bgcolor="#' || nvl(pfx.vert_colour_b,glbx.QUERY_CELL_BACKGROUND2) || '"';
    end if;
   if ltype in ('OWNER','CUSTOMER')
     then
      htp.tabledata( htf.formcheckbox( 'P1', c2rec.umo_id ),cattributes=>backcol || 'valign="MIDDLE" align="CENTER"' );
   end if;
   photo_name := ump.uma_attribute(surl,c2rec.umo_id,'PHOTO','NAME' );
   htp.tabledata( '<IMG BORDER=0 WIDTH=' || c2rec.wd || ' HEIGHT=' || c2rec.hg || ' SRC="' ||
                  'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || ltype ||
  	          '" ALT="' || photo_name || '" STYLE="display:block;">' || htf.nl ||
		  htf.bold(photo_name),cattributes=>backcol || 'valign="MIDDLE" align="CENTER" CLASS="SMALL"' );
   htp.tabledata(htf.anchor2(
                 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=WINDOWX&parm1=DISPLAY_WHAT&parm2=ORIGINAL' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || acid || '&parm1=OVERRIDE&parm2=AUDIO',
	         htf.img( DECS.IMAGE_LOCATION || 'adminc/audio.gif',cattributes=>'border=0',calt=>lng.CST_ALT_086 ),ctarget=>'AUDIO_WINDOW'),cattributes=>backcol || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata( htf.bold(LNG.GLB_TXT_067 || c2rec.sze || htf.nl || LNG.GLB_TXT_068 || initcap(c2rec.fmt)) ,cattributes=>backcol || 'valign="MIDDLE" align="CENTER" CLASS="SMALL"');
  htp.tablerowopen;
  end loop;
  htp.tableclose;
  htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'GLBX', 'LIST_ALL_AUDIO',vaid=>acid,errmsg=>sqlerrm);
end list_all_audio;

procedure show_help( surl in varchar2 default null, helpid in varchar2 default null, typ in varchar2 default null, logtyp in varchar2 default NULL, highlightword in varchar2 default NULL)
as

 cursor c1( tpid varchar2 ) is
  select topic_title,content,content2,content3,content4,content5,content6,content7,content8
  from help_topics
  where topic_id = tpid;

 cursor c2(grp varchar2, indic integer, ltype varchar2) is
  select content_id,topic_id,content_name
  from help_contents
  where ((substr(sec_mask,indic,1) = 'T') or (ltype='ADMINISTRATOR' and sec_mask = 'FFFF')) and
        (group_name = grp)
  order by content_id;

 cursor c3(fl char, indic integer, ltype varchar2) is select topic_id,index_word from help_index where ((substr(sec_mask,indic,1) = 'T') or (ltype='ADMINISTRATOR' and sec_mask = 'FFFF')) and (first_letter = fl) order by index_word;

 cursor c3a(fl char, indic integer, ltype varchar2) is select count('x') from help_index where ((substr(sec_mask,indic,1) = 'T') or (ltype='ADMINISTRATOR' and sec_mask = 'FFFF')) and (first_letter = fl) order by index_word;

 cursor c4(indic integer, ltype varchar2) is select distinct group_name from help_contents where (substr(sec_mask,indic,1) = 'T') or (ltype='ADMINISTRATOR' and sec_mask = 'FFFF');

 cursor c5(indic integer, ltype varchar2) is select howdoi_title,content_id from help_howdoi where (substr(sec_mask,indic,1) = 'T') or (ltype='ADMINISTRATOR' and sec_mask = 'FFFF');

 cursor c5a(vindic varchar2) is select content from help_howdoi where content_id = vindic;

 cursor c5b(vindic varchar2) is select howdoi_title,content_id from help_howdoi where topic_id_xref = vindic;

 cursor c6(keyword varchar2, indic integer, ltype varchar2) is
  select ht.topic_id,ht.topic_title
  from help_topics ht,help_index hi
  where ht.topic_id = hi.topic_id and ((substr(hi.sec_mask,indic,1) = 'T') or (ltype='ADMINISTRATOR' and sec_mask = 'FFFF')) and (hi.index_word = upper(keyword))
  order by ht.topic_id;

 cursor c7(phgid integer) is select * from theme_types tt where theme_type = (select theme_type from photographer where pid=phgid);

 cursor c8(acid integer) is select * from theme_types tt where theme_type = (select theme_type from customer_account where aid=acid);
 cursor c9(acid integer) is select * from theme_types tt where theme_type = (select theme_type from customer_profile where profile_id=acid);

 c1rec		c1%ROWTYPE;
 c5arec		c5a%ROWTYPE;
 c5brec		c5b%ROWTYPE;
 indic		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 dummy		integer;
 isfound	boolean;
 lastval	varchar2(100);
 hlp		varchar2(32767);
 tmp		varchar2(20000);
 ctr		integer;
 loc		integer;
 lastloc	integer;
 x		integer;
 y		integer;
 z		integer;
 ig_ctr		integer;
 com_ctr	integer;
 inf_loop	integer;
 ignore		boolean;
 nmb		integer;
 theme_rec 	theme_types%ROWTYPE;
 tag		varchar2(100);

begin
 if surl is null
  then
   stype := 1;
   ltype := 'CUSTOMER';
 elsif logtyp is null -- First try as photographer
  then
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'GLBX.SHOW_HELP', iscust=>FALSE );
   if sts is not null  -- Now try as customer
    then
      glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'GLBX.SHOW_HELP', iscust=>TRUE );
      if sts is not null
       then
        glbx.redisplay_login_page( sts );
        return;
      end if;
   end if;
 else
  glbx.adm_cookie_id(surl,owner_id,sts);
  if sts is not null
   then
    htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
  end if;
  stype := 1;
  ltype := 'ADMINISTRATOR';
 end if;

 -- Extract Business Features for Embedded Help Restriction Tag
 if ltype = 'ADMINISTRATOR'
  then
   theme_rec.theme_data := rpad('T',500,'T');
 elsif ltype = 'PHOTOGRAPHER'
  then
   open c7(owner_id);
   fetch c7 into theme_rec;
   close c7;
 elsif ltype in ('OWNER','CUSTOMER')
  then
   open c8(owner_id);
   fetch c8 into theme_rec;
   close c8;
 else
   open c9(owner_id);
   fetch c9 into theme_rec;
   close c9;
 end if;

 htp.htmlopen;
 htp.title( extract_master_parameter('BAR_TITLE') || ' ' || LNG.GLB_TXT_115 );
 htp.tableopen( cattributes=>'width="100%" cellpadding=0 cellspacing=0 border=0 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;

   if typ = 'INDEX'
    then
     htp.tabledata('<b><font size="+1" color="#ffffff">&nbsp;' || LNG.GLB_TXT_091 || '</font></b>',cattributes=>glbx.TITLE_BACKGROUND || 'valign="MIDDLE" align="CENTER"');

   elsif typ = 'FIND'
    then
     htp.tabledata('<b><font size="+1" color="#ffffff">&nbsp;' || LNG.GLB_TXT_092 || '</font></b>',cattributes=>glbx.TITLE_BACKGROUND || 'valign="MIDDLE" align="CENTER"');

   elsif typ = 'FORMX'
    then
     htp.tabledata('<b><font size="+1" color="#ffffff">&nbsp;' || LNG.GLB_TXT_100 || '</font></b>',cattributes=>glbx.TITLE_BACKGROUND || 'valign="MIDDLE" align="CENTER"');

   elsif typ = 'CONTENTS'
    then
     htp.tabledata('<b><font size="+1" color="#ffffff">&nbsp;' || LNG.GLB_TXT_093 || '</font></b>',cattributes=>glbx.TITLE_BACKGROUND || 'valign="MIDDLE" align="CENTER"');

   else
    open c1(helpid);
    fetch c1 into c1rec;
    hlp := replace(c1rec.content || c1rec.content2 || c1rec.content3 || c1rec.content4 || c1rec.content5 || c1rec.content6 || c1rec.content7 || c1rec.content8,'~SURL',surl);
    close c1;

    if instr(hlp,'<IGNORE') > 0
     then
      ig_ctr := 1;
      inf_loop :=  1;
      loop
       inf_loop := inf_loop + 1;
       if inf_loop = 100 then exit; end if;
       x := instr(hlp,'<IGNORE',1,ig_ctr);
       exit when x = 0;
       z := instr(hlp,'>',x);
       tag := replace(substr(hlp,x,z-x),' ','');
       y := x;
       x := instr(tag,'BF=');
       tag := replace(substr(tag,x+3),'"','');
       -- should be a set of numbers
       com_ctr := 1;
       ignore := FALSE;
       loop
        x:= instr(tag,',');
        if x = 0
         then
          begin nmb := to_number(tag); exception when others then nmb := null; exit; end;
          if substr(theme_rec.theme_data,nmb,1) = 'F' then ignore := TRUE; end if;
          exit;
        end if;
        begin nmb := to_number(substr(tag,1,x-1)); exception when others then nmb := null; exit; end;
        tag := substr(tag,x+1);
        if substr(theme_rec.theme_data,nmb,1) = 'F' then ignore := TRUE; exit; end if;
       end loop;
       -- Either way, remove ignore tags.
       if ignore
        then
         x := instr(hlp,'</IGNORE>',y);
         hlp := substr(hlp,1,y-1) || substr(hlp,x+length('</IGNORE>')+1);
        else
         x := instr(hlp,'</IGNORE>',y);
         hlp := substr(hlp,1,y-1) || substr(hlp,z+1,(x-z)-1) || substr(hlp,x+length('</IGNORE>'));
       end if;
      end loop;
    end if;

    htp.tabledata('<b><font size="-1" color="#ffffff" width="5%">[' || helpid || '] ' || '</font></b>',cattributes=>glbx.TITLE_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
    htp.tabledata('<b><font size="+1" color="#ffffff" width="80%">' || nvl(c1rec.topic_title,LNG.GLB_TXT_094) || '</font></b>',cattributes=>glbx.TITLE_BACKGROUND || 'valign="MIDDLE" align="CENTER"');
   end if;

   if helpid is not null
    then
     htp.p( '<TD ' || glbx.TITLE_BACKGROUND || 'valign="MIDDLE" align="CENTER" width="15%">' );
     if extract_master_parameter('ENABLE_CONTENTS') = 'TRUE'
      then
       htp.anchor( 'glbx.show_help?surl=' || glbx.rndsurl(surl) || '&helpid=' || helpid || '&typ=CONTENTS&logtyp=' || logtyp,htf.img( DECS.IMAGE_LOCATION || 'adminc/help_contents.gif',cattributes=>' border=0',calt=>LNG.GLB_ALT_071) );
     end if;
     if extract_master_parameter('ENABLE_INDEX') = 'TRUE'
      then
       htp.anchor( 'glbx.show_help?surl=' || glbx.rndsurl(surl) || '&helpid=' || helpid || '&typ=INDEX&logtyp=' || logtyp,htf.img( DECS.IMAGE_LOCATION || 'adminc/help_index.gif',cattributes=>' border=0',calt=>LNG.GLB_ALT_071) );
     end if;
     if extract_master_parameter('ENABLE_HOWDOI') = 'TRUE'
      then
       htp.anchor( 'glbx.show_help?surl=' || glbx.rndsurl(surl) || '&helpid=' || helpid || '&typ=HOW&logtyp=' || logtyp,htf.img( DECS.IMAGE_LOCATION || 'adminc/help_how.gif',cattributes=>' border=0',calt=>LNG.GLB_ALT_071) );
     end if;
     if extract_master_parameter('ENABLE_FIND') = 'TRUE'
      then
       htp.anchor( 'glbx.show_help?surl=' || glbx.rndsurl(surl) || '&helpid=' || helpid || '&typ=FIND&logtyp=' || logtyp,htf.img( DECS.IMAGE_LOCATION || 'adminc/help_find.gif',cattributes=>' border=0',calt=>LNG.GLB_ALT_071) );
     end if;
     htp.p( '</TD>' );
   end if;

  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.nl;
 if ltype = 'PHOTOGRAPHER' then indic := 1;
  elsif ltype in ('OWNER','PROFILE') then indic := 2;
  elsif ltype in ('CUSTOMER','PROFILEG','VIRTUAL') then indic := 3;
  elsif ltype = 'MANUFACTURER' then indic := 4;
  elsif ltype = 'ADMINISTRATOR' then indic := 0;
  else indic := 3;
 end if;

 if typ = 'INDEX'
  then
   for j in 65..90 loop
    dummy := 0;
    open c3a(chr(j), indic,ltype);
    fetch c3a into dummy;
    if dummy > 0
     then
      htp.bold( chr(j) );
      htp.ulistopen;
      tmp := NULL;
      lastval := NULL;
      for c3rec in c3( chr(j), indic, ltype ) loop
       if c3rec.index_word = lastval
        then
         tmp := tmp || ',' || htf.anchor( 'glbx.show_help?surl=' || glbx.rndsurl(surl) || '&helpid=' || c3rec.topic_id || '&logtyp=' || logtyp || '&highlightword=' || replace(initcap(c3rec.index_word),' ',''),c3rec.topic_id );
        else
         if tmp is not null then htp.listitem( initcap(lastval) || ': ' ||substr(tmp,2) ); end if;
         tmp := ',' || htf.anchor( 'glbx.show_help?surl=' || glbx.rndsurl(surl) || '&helpid=' || c3rec.topic_id || '&logtyp=' || logtyp || '&highlightword=' || replace(initcap(c3rec.index_word),' ',''),c3rec.topic_id );
       end if;
       lastval := c3rec.index_word;
      end loop;
      if tmp is not null then htp.listitem( initcap(lastval) || ': ' ||substr(tmp,2) ); end if;
      htp.ulistclose;
    end if;
    close c3a;
   end loop;

 elsif typ = 'FIND'
  then
   htp.formopen( 'glbx.show_help' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formhidden( 'TYP','FORMX' );
   htp.formhidden( 'LOGTYP',logtyp );
   htp.tableopen(cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.GLB_TXT_101),cattributes=>glbx.QUERY_BACKGROUND );
     htp.tabledata( htf.formtext('HELPID',10,30),cattributes=>glbx.QUERY_CELL_BACKGROUND );
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( null,LNG.GLB_TXT_092);
   htp.formclose;
 elsif typ = 'FORMX'
  then
    isfound := FALSE;
    htp.bold( LNG.GLB_TXT_102 || replace(helpid,' ','') ); htp.nl;
    htp.ulistopen;
    for c6rec in c6( replace(helpid,' ',''), indic, ltype ) loop
     isfound := TRUE;
     htp.listitem( htf.anchor( 'glbx.show_help?surl=' || glbx.rndsurl(surl) || '&helpid=' || c6rec.topic_id || '&logtyp=' || logtyp || '&highlightword=' || replace(helpid,' ',''),c6rec.topic_title ));
    end loop;
    htp.ulistclose;
    if not isfound
     then
      htp.bold( LNG.GLB_TXT_103 ); htp.nl; htp.nl;
      htp.formopen( 'glbx.show_help' );
      htp.formhidden( 'SURL', glbx.rndsurl(surl));
      htp.formhidden( 'TYP','FORMX' );
      htp.formhidden( 'LOGTYP',logtyp );
      htp.tableopen(cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );
      htp.tablerowopen;
        htp.tabledata( htf.bold(LNG.GLB_TXT_101),cattributes=>glbx.QUERY_BACKGROUND );
        htp.tabledata( htf.formtext('HELPID',10,30),cattributes=>glbx.QUERY_CELL_BACKGROUND );
       htp.tablerowclose;
      htp.tableclose;
      htp.nl;
      htp.formsubmit( null,LNG.GLB_TXT_092);
      htp.formclose;
    end if;
    htp.nl;
 elsif typ = 'CONTENTS'
  then
   for c4rec in c4(indic,ltype) loop
    htp.bold( c4rec.group_name ); htp.nl;
    htp.ulistopen;
    for c2rec in c2( c4rec.group_name, indic, ltype ) loop
     htp.listitem( htf.anchor( 'glbx.show_help?surl=' || glbx.rndsurl(surl) || '&helpid=' || c2rec.topic_id || '&logtyp=' || logtyp,c2rec.content_name ));
    end loop;
    htp.ulistclose;
    htp.nl;
   end loop;
 elsif typ = 'HOW'
  then
   htp.ulistopen;
   for c5rec in c5(indic,ltype) loop
     htp.listitem( htf.anchor( 'glbx.show_help?surl=' || glbx.rndsurl(surl) || '&helpid=' || c5rec.content_id || '&typ=SHOWHOW' || '&logtyp=' || logtyp,c5rec.howdoi_title ));
   end loop;
   htp.ulistclose;
 elsif typ = 'SHOWHOW'
  then
   open c5a(helpid);
   fetch c5a into c5arec;
   close c5a;
  htp.p( nvl(c5arec.content,LNG.GLB_TXT_094) );
 else
  if highlightword is null
   then
    htp.p( nvl(hlp,LNG.GLB_TXT_094) );
   else
    ctr := 1;
    lastloc := 1;
    loop
     loc := instr(upper(hlp),upper(highlightword),1,ctr);
     if (loc = 0) or (ctr > 1000) then exit; end if;
     htp.p( substr(hlp,lastloc - 1,(loc-lastloc )));
     htp.p( '<EM><BLINK>' || highlightword || '</BLINK></EM>');
     lastloc := loc + length(highlightword) + 1;
     ctr := ctr + 1;
    end loop;
    htp.p( substr(hlp,lastloc - 1 ));
  end if;
  open c5b(helpid);
  fetch c5b into c5brec;
  close c5b;
  if c5brec.content_id is not null
   then
    htp.nl;
    htp.anchor( 'glbx.show_help?surl=' || glbx.rndsurl(surl) || '&helpid=' || c5brec.content_id || '&typ=SHOWHOW' || '&logtyp=' || logtyp,c5brec.howdoi_title );
    htp.nl;
    htp.nl;
  end if;
 end if;
 htp.nl;
 htp.nl;
 htp.p( '<CENTER>' );
 htp.bold( '<a href="javascript:history.go(-1)" onMouseOver="self.status=document.referrer;return true">' || '[' || LNG.CST_TXT_058 || ']' || '</a>' || ' ');
 htp.bold( '<a href="javascript:self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'GLBX', 'SHOW_HELP',errmsg=>sqlerrm, extdet=>'HELPID:' || helpid);
end show_help;

procedure beta_bug( surl in varchar2, acid in integer default null)
as
 tmp		varchar2(4000);
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
begin
 if acid is null
  then
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'GLBX.BETA_BUG', iscust=>TRUE );
  else
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'GLBX.BETA_BUG', iscust=>FALSE );
 end if;
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 htp.htmlopen;
  htp.header(2,LNG4.AHC_TXT_119, 'CENTER' );
  htp.nl;
  htp.formopen( 'glbx.accept_beta_bug' );
  htp.tableopen( cattributes=>'BORDER=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG2.FRM_TXT_015 ) );
    htp.tabledata( htf.formtext( 'P1', 40, 100 ) );
   htp.tablerowclose;
   tmp := htf.formselectopen( 'P2' );
   tmp := tmp || htf.formselectoption( LNG4.AHC_TXT_121 );
   tmp := tmp || htf.formselectoption( LNG4.AHC_TXT_122,'SELECTED' );
   tmp := tmp || htf.formselectoption( LNG4.AHC_TXT_123 );
   tmp := tmp || htf.formselectoption( LNG4.AHC_TXT_124 );
   tmp := tmp || htf.formselectclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_125 ) );
    htp.tabledata( tmp );
   htp.tablerowclose;
   tmp := htf.formselectopen( 'P3' );
   tmp := tmp || htf.formselectoption( LNG4.AHC_TXT_126,'SELECTED' );
   tmp := tmp || htf.formselectoption( LNG4.AHC_TXT_127 );
   tmp := tmp || htf.formselectoption( LNG4.AHC_TXT_128 );
   tmp := tmp || htf.formselectoption( LNG4.AHC_TXT_129 );
   tmp := tmp || htf.formselectoption( LNG4.AHC_TXT_130 );
   tmp := tmp || htf.formselectoption( LNG4.AHC_TXT_131 );
   tmp := tmp || htf.formselectoption( LNG4.AHC_TXT_132 );
   tmp := tmp || htf.formselectclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_133 ) );
    htp.tabledata( tmp );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_134 ) );
    htp.tabledata( htf.formtext( 'P4', 40, 100 ) );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_135 ) );
    htp.tabledata( htf.formtextarea( 'P5', 5, 40 ) );
   htp.tablerowclose;
  htp.tableclose;
  htp.formhidden( 'P6', null );
  htp.formhidden( 'P7', null );
  htp.formhidden( 'ACID', acid );
  htp.nl;
  htp.formsubmit(null,LNG4.AHC_TXT_136);
  htp.formclose;
 htp.htmlclose;

exception when others then
 glbx.error_details( 'GLBX', 'BETA_BUG',errmsg=>sqlerrm,extdet=>'ACID: ' || acid);
end beta_bug;

procedure accept_beta_bug(acid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2 )
as
 gcode			GLBX.MYARRAY;
 gparam			GLBX.MYARRAY;
begin
    gcode(1) := 'P1';
    gparam(1) := p1;
    gcode(2) := 'P12';
    gparam(2) := p2;
    gcode(3) := 'P3';
    gparam(3) := p3;
    gcode(4) := 'P4';
    gparam(4) := p4;
    gcode(5) := 'P5';
    gparam(5) := p5;
    gcode(6) := 'P6';
    gparam(6) := p6;
    gcode(7) := 'P7';
    gparam(7) := p7;
    gcode(8) := 'SIGNATURE';
    gparam(8) := glbx.extract_master_parameter('MAIL SIGNATURE');
    glbx.send( gcode, gparam, 'bug.tmp', 'info@piction.com', LNG4.AHC_TXT_137, glbx.extract_master_parameter('MAIL_FROM'));
    commit;
    htp.htmlopen;
     htp.header(2,LNG4.AHC_TXT_138, 'CENTER' );
     htp.nl;
     htp.nl;
     htp.bold( LNG4.AHC_TXT_139 );
     htp.nl;
     htp.nl;
    htp.htmlclose;

exception when others then
 glbx.error_details( 'GLBX', 'ACCEPT_BETA_BUG',errmsg=>sqlerrm,extdet=>'ACID: ' || acid);
end accept_beta_bug;

procedure process_mfc_details( surl in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2, p8 in varchar2, p9 in varchar2 default 'F', p10 in varchar2, p11 in varchar2, p12 in varchar2, p13 in varchar2, p14 in varchar2, p15 in varchar2, action in varchar2 )
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 tmp		varchar2(2000);
 new_password	varchar2(100);
 nmb		integer;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'GLBX.PROCESS_MFC_DETAILS', iscust=>TRUE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 -- LNG.LAB_BUT_011 (What the only current action is)
 begin nmb := to_number(p8); exception when others then nmb := 30; end;

 if (p3 is not null or p4 is not null)
  then
   if nvl(p3,'#') <> nvl(p4,'&')
    then
     lab.home(surl,LNG.GLB_TXT_106);
     return;
   end if;
 end if;

 if p3 is null
  then
   new_password := NULL;
  else
   new_password := encrypt( upper( p3 ));
 end if;

 update manufacturer
  set
   name = nvl(p1,name),
   contact_email = p6,
   contact = p2,
   password = nvl(new_password,password),
   theme_name = p5,
   abn_number = p7,
   invoice_days = p8,
   price_book_public = p9,
   public_book = p10,
   home_page = p11,
   workflow_display = p12,
   sort_on_attribute_id = p13,
   receptionist_aid = p14,
   barcode_function = p15
 where manufacturer_id = owner_id;
 insert into audit_manufacturer_password(manufacturer_id,date_changed,pw) values (owner_id,sysdate,upper(p3));
 commit;
 lab.home(surl,LNG.GLB_TXT_030);

exception when others then
 glbx.error_details( 'GLBX', 'PROCESS_MFC_DETAILS',errmsg=>sqlerrm,extdet=>'OWNER_ID: ' || owner_id);
end process_mfc_details;

procedure request_extension( acid in integer )
as
 cursor c1(acid integer) is select photographer_title from photographer where pid in (select pid from customer_account where aid = acid);
 c1rec	c1%ROWTYPE;
begin
 htp.htmlopen;
  htp.header( 2, LNG.GLB_TXT_109, 'CENTER' );
  htp.nl;
  htp.formopen( 'GLBX.ACCEPT_EXTENSION' );
  htp.formhidden( 'ACID', acid );
  open c1(acid);
  fetch c1 into c1rec;
  close c1;
  htp.italic( replace(LNG.GLB_TXT_110,'<PHOTOGRAPHER>',c1rec.photographer_title) );
  htp.nl;
  htp.nl;
  htp.tableopen;
   htp.tablerowopen;
    htp.tabledata( LNG.PHG_TXT_301 );
    htp.tabledata( htf.formtext( 'P1', 30, 100 ) );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( LNG.CST_TXT_108 );
    htp.tabledata( htf.formtext( 'P2', 30, 100 ) );
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( null, LNG.GLB_TXT_111 );
  htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'GLBX', 'REQUEST_EXTENSION',errmsg=>sqlerrm,extdet=>'ACID: ' || acid);
end request_extension;

procedure accept_extension( acid in integer, p1 in varchar2, p2 in varchar2 )
as
 cursor c1(acid integer) is select ph.pid,ca.account_name,ph.business_name,ph.contact_email from photographer ph,customer_account ca where ca.pid=ph.pid and ca.aid = acid;
 --cursor c2 is select piction_email_acct from master_piction;
 c1rec		c1%ROWTYPE;
 --c2rec		c2%ROWTYPE;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;
begin
 open c1(acid);
 fetch c1 into c1rec;
 close c1;
 --open c2;
 --fetch c2 into c2rec;
 --close c2;
 gcode(1) := 'CUSTOMER_ACCOUNT_NAME';
 gparam(1) := c1rec.account_name;
 gcode(2) := 'PHOTOGRAPHER_NAME';
 gparam(2) := c1rec.business_name;
 gcode(3) := 'PID';
 gparam(3) := to_char(c1rec.pid);
 gcode(4) := 'AID';
 gparam(4) := to_char(acid);
 gcode(5) := 'EMAIL';
 gparam(5) := p1;
 gcode(6) := 'PHONE';
 gparam(6) := p2;
 gcode(7) := 'SIGNATURE';
 gparam(7) := glbx.extract_master_parameter('MAIL SIGNATURE');
 glbx.send( gcode, gparam, 'request_extension.tmp', nvl(c1rec.contact_email ,glbx.extract_master_parameter('PICTION_EMAIL_ACCT')), LNG.GLB_TXT_114, glbx.extract_master_parameter('MAIL_FROM'), scode=>'RE1');
 commit;
 htp.htmlopen;
  htp.header( 2,LNG.GLB_TXT_112 || ' ' || glbx.extract_master_parameter('PAGE_TITLE'), 'CENTER' );
  htp.nl;
  htp.header( 3,LNG.GLB_TXT_113, 'CENTER' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'GLBX', 'ACCEPT_REQUEST_EXTENSION',errmsg=>sqlerrm,extdet=>'ACID: ' || acid || ' P1:' || p1 || ' P2:' || p2);
end accept_extension;

procedure change_password( surl in varchar2, acid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, action in varchar2 )
as

 cursor c2a(phgid integer) is select password from photographer where pid = phgid;
 cursor c2b(acid integer) is select password_owner from customer_account where aid = acid;
 cursor c2c(profid integer) is select password_owner from customer_profile where profile_id = profid;

 c1rec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 profid		integer;
 owner_id	integer;
 pw		varchar2(100);
 sts		varchar2(100);
 testpw		varchar2(100);
 pw_expiry	number;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GLBX.CHANGE_PASSWORD' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );

 if action = LNG.PHG_TXT_052
  then
   phg.phg_utlts_prefs(surl,acid);
   return;
 end if;

 if ltype = 'PHOTOGRAPHER'
  then
   open c2a(c1rec.pid);
   fetch c2a into pw;
   close c2a;
 elsif ltype = 'OWNER'
  then
   open c2b(c1rec.aid);
   fetch c2b into pw;
   close c2b;
 elsif ltype = 'PROFILE'
  then
   open c2b(profid);
   fetch c2b into pw;
   close c2b;
 end if;

 -- Check if Password is the same as the one passed down
 if pw <> encrypt(upper(p1)) or p1 is null or pw is null
  then
   if ltype = 'PHOTOGRAPHER'
    then
     update photographer
      set
       failed_logins = nvl(failed_logins,0) + 1
      where pid = c1rec.pid;
     commit;
     phg.phg_password(surl, acid, LNG.GLB_TXT_118 );
     return;
   elsif ltype = 'OWNER'
    then
     update customer_account
      set
       failed_logins = nvl(failed_logins,0) + 1
      where aid = c1rec.aid;
     commit;
     cst.acct_details(surl, null, LNG.GLB_TXT_118);
     return;
   elsif ltype = 'PROFILE'
    then
     update customer_profile
      set
       failed_logins = nvl(failed_logins,0) + 1
      where profile_id = profid;
     commit;
     cst.acct_details(surl, null, LNG.GLB_TXT_118);
     return;
   end if;
 end if;

 -- None of the values can be null
 if p1 is null or p2 is null or p3 is null
  then
   if ltype = 'PHOTOGRAPHER'
    then
     phg.phg_password(surl,acid,LNG.GLB_TXT_119 );
     return;
    else
     cst.acct_details(surl, null, LNG.GLB_TXT_119);
     return;
   end if;
 end if;

 -- New password must match the new confirmed one
 if upper(p2) <> upper(p3)
  then
   if ltype = 'PHOTOGRAPHER'
    then
     phg.phg_password(surl,acid,LNG.GLB_TXT_120 );
     return;
    else
     cst.acct_details(surl, null, LNG.GLB_TXT_120);
     return;
   end if;
 end if;

 testpw := encrypt(upper(p2));
 --open c2;
 --fetch c2 into c2rec;
 --close c2;
 pw_expiry := nvl(to_number(glbx.extract_master_parameter('PASSWORD_EXPIRY_DAYS')),90);

 if ltype = 'PHOTOGRAPHER'
  then
   update photographer
    set
     password = testpw,
     password_expires = (sysdate + pw_expiry),
     failed_logins = 0
   where pid = c1rec.pid;
   insert into audit_photographer_password(pid,date_changed,pw) values (c1rec.pid,sysdate,upper(p2));
   commit;
   phg.phg_password(surl,acid,LNG.GLB_TXT_121);
   return;
 elsif ltype = 'OWNER'
  then
    update customer_account
     set
      password_owner = testpw,
      failed_logins = 0
    where aid = c1rec.aid;
    insert into audit_customer_password(aid,date_changed,pw) values (c1rec.aid,sysdate,upper(p2));
    cst.acct_details(surl, null, LNG.GLB_TXT_121);
    return;
 elsif ltype = 'PROFILE'
  then
    update customer_profile
     set
      password_owner = testpw,
      failed_logins = 0
    where profile_id = profid;
    insert into audit_profile_password(profile_id,date_changed,pw) values (profid,sysdate,upper(p2));
    cst.acct_details(surl, null, LNG.GLB_TXT_121);
    return;
 end if;
exception when others then
 glbx.error_details( 'GLBX', 'CHANGE_PASSWORD',errmsg=>sqlerrm,extdet=>'ACID: ' || acid || ' P1:' || p1 || ' P2:' || p2 || ' P3:' || p3);
end change_password;

function  get_theme_types(phgid in integer)
 return theme_types%ROWTYPE
as
 cursor c1(phgid integer) is select * from theme_types tt where theme_type in (select theme_type from photographer where pid=phgid);
 c1rec  c1%ROWTYPE;
begin
 open c1(phgid);
 fetch c1 into c1rec;
 close c1;
 return( c1rec );
exception when others then
 glbx.error_details( 'GLBX', 'GET_THEME_TYPES',errmsg=>sqlerrm,extdet=>'PHGID:' || phgid);
end get_theme_types;

function  cust_get_theme_types(acid in integer)
 return theme_types%ROWTYPE
as
 cursor c1(acid integer) is select * from theme_types tt where theme_type in (select theme_type from customer_account where aid=acid);
 c1rec  c1%ROWTYPE;
begin
 open c1(acid);
 fetch c1 into c1rec;
 close c1;
 return( c1rec );
exception when others then
 glbx.error_details( 'GLBX', 'CUST_GET_THEME_TYPES',errmsg=>sqlerrm,extdet=>'ACID:' || acid);
end cust_get_theme_types;

function  get_email(surl in varchar2)
 return varchar2
as
 cursor c1(sess_id integer) is select guest_email from login_session where sessid = sess_id;
 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GLBX.GET_EMAIL', iscust=>TRUE, reset=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return( NULL );
 end if;
 open c1(owner_id);
 fetch c1 into c1rec;
 close c1;
 return( c1rec.guest_email );
exception when others then
 glbx.error_details( 'GLBX', 'GET_EMAIL',errmsg=>sqlerrm); return( NULL );
end get_email;

function  get_country(surl in varchar2)
 return varchar2
as
 cursor c1(sess_id integer) is select country from login_session where sessid = sess_id;
 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GLBX.GET_COUNTRY', iscust=>TRUE, reset=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return( NULL );
 end if;
 open c1(owner_id);
 fetch c1 into c1rec;
 close c1;
 return( c1rec.country );
exception when others then
 glbx.error_details( 'GLBX', 'GET_COUNTRY',errmsg=>sqlerrm); return( NULL );
end get_country;

procedure adm_cookie_id( surl in varchar2, owner_id out integer, sts out varchar2, progcalled in varchar2 default null )
 is
  cursor c1( id integer ) is select rowid, login_type, aid, date_updated, date_created, is_connected from login_session where sessid = id;
  cursor c3( id integer, surl varchar2 ) is select rowid, login_type, aid, date_updated, date_created, is_connected from login_session where securl = surl and sessid = id;

  c1rec		c1%ROWTYPE;
  id		varchar2(20);
  timeout	integer;
  seccomp	varchar2(20);
  x		integer;

 begin

    id := substr(surl,1,12);
    x := instr(id,'Z');
    if x > 0
     then
      id := substr(id,1,x-1);
    end if;
    begin
     x := to_number(id);
    exception
     when others then
     sts := 'Invalid ID:' || id;
     return;
    end;
    seccomp := substr(surl,13,10);
    open c3(x,substr(surl,1,22));
    fetch c3 into c1rec;
    if c3%NOTFOUND
     then
      close c3;
      sts := 'Invalid ID:' || id;
      return;
    end if;
    close c3;

   open c1( to_number(id) );
   fetch c1 into c1rec;
   if c1%NOTFOUND
    then
     close c1;
     sts := 'SESSION NOT FOUND';
     return;
   end if;
   close c1;

  if c1rec.login_type <> 'ADMIN'
   then
    sts := 'INVALID LOGIN TYPE';
    return;
  end if;

 -- open c2;
 -- fetch c2 into timeout;
 -- close c2;
   begin timeout := to_number(glbx.extract_master_parameter('DISCONNECT_AFTER')); exception when others then timeout := 180; end;

  if (sysdate - nvl(c1rec.date_updated,c1rec.date_created))*1440 > timeout
   then
    update login_session
	set is_connected = 'F'
	where rowid = c1rec.rowid;
	commit;
	sts := LNG.GLB_TXT_012 || timeout || LNG.GLB_TXT_013;
        htp.htmlopen;
        -- htp.bold('ID:' || id );htp.nl;
        htp.print('<BODY BGCOLOR="#' || GLBX.QUERY_CELL_BACKGROUND1 || '">');
        htp.p( '<CENTER>' );
        glbx.header_msg(LNG.GLB_TXT_012 || timeout || LNG.GLB_TXT_013);
        htp.nl;
        htp.bold( LNG3.ADM_TXT_157 );
        htp.nl;
        htp.nl;
        htp.anchor( 'adm.test_page?id=' || DECS.PW_RESET, LNG3.ADM_TXT_158 );
        htp.nl;
        htp.nl;
        htp.anchor( 'glbx.login_page', LNG3.ADM_TXT_159 );
        htp.nl;
        htp.nl;
        htp.italic( LNG3.ADM_TXT_160 );
        htp.nl;
        htp.nl;
        htp.nl;
        htp.p( '</CENTER>' );
        htp.htmlclose;
	return;
  end if;

 --if decs.audit_all_activity
 -- then
   insert into audit_all_activity(sessid,date_updated,program_called,umo_id,display_what) values
   ( to_number(id), sysdate, progcalled, null, null );
 --end if;

 update login_session set date_updated = sysdate, call_ctr = call_ctr + 1
  where rowid = c1rec.rowid;
 commit;
 owner_id := c1rec.aid;

 exception
  when others then sts := sqlerrm; htp.p( sqlerrm ); return;
 end adm_cookie_id;

function conv_nmb( val in varchar2, typ in varchar2 default 'MONEY'  )
 return number
as
 nmb	number;
begin
 if typ = 'MONEY'
  then
   begin
    nmb := to_number(val);
    nmb := to_number(to_char(nmb,LNG.MONEY_FORMAT),LNG.MONEY_FORMAT);
   exception when others then
    begin
     nmb := to_number(val,LNG.MONEY_FORMAT);
    exception when others then nmb := 0;
    end;
   end;
   return( nmb );

 elsif typ = 'PERCENTAGE'
  then
   begin
    nmb := to_number(val);
    if nmb < 0 then nmb := 0;
    elsif nmb > 100 then nmb := 100;
    end if;
    return( nmb );
   exception
    when others then return( NULL );
   end;

 elsif typ = 'NUMBER'
  then
   begin
    nmb := to_number(val);
    return( nmb );
   exception
    when others then return( NULL );
   end;
 end if;

exception when others then
 glbx.error_details( 'GLBX', 'CONV_NMB',errmsg=>sqlerrm,extdet=>'VAL:' || val);
end conv_nmb;

procedure determine_wm( ph1 in ORDSYS.ORDIMAGE, ph2 in ORDSYS.ORDIMAGE, wm in varchar2, xcoord out integer, ycoord out integer, sts out integer)
as

begin
 sts := 0;
 if ph2.width > ph1.width
  then
   xcoord := 0;
   ycoord := 0;
   sts := 1;
   return;
 end if;
 if ph2.height > ph1.height
  then
   xcoord := 0;
   ycoord := 0;
   sts := 2;
   return;
 end if;

 if wm = LNG.PHG_TXT_379 -- Top Left
  then
   xcoord := 1;
   ycoord := 1;
 elsif wm = LNG.PHG_TXT_381 -- Top Center
  then
   xcoord := round( (ph1.width-ph2.width)/2);
   if xcoord < 1 then xcoord:= 1; end if;
   ycoord := 1;
 elsif wm = LNG.PHG_TXT_383 -- Top Right
  then
   xcoord := ph1.width - (ph2.width+1);
   if xcoord < 1 then xcoord := 1; end if;
   ycoord := 1;
 elsif wm = LNG.PHG_TXT_384 -- Middle Left
  then
   xcoord := 1;
   ycoord := round( (ph1.height-ph2.height)/2);
   if ycoord < 1 then ycoord := 1; end if;
 elsif wm = LNG.PHG_TXT_385 -- Middle Center
  then
   xcoord := round( (ph1.width-ph2.width)/2);
   if xcoord < 1 then xcoord:= 1; end if;
   ycoord := round( (ph1.height-ph2.height)/2);
   if ycoord < 1 then ycoord := 1; end if;
 elsif wm = LNG.PHG_TXT_401 -- Middle Right
  then
   xcoord := ph1.width - (ph2.width+1);
   if xcoord < 1 then xcoord := 1; end if;
   ycoord := round( (ph1.height-ph2.height)/2);
   if ycoord < 1 then ycoord := 1; end if;
 elsif wm = LNG.PHG_TXT_402 -- Bottom Left
  then
   xcoord := 1;
   ycoord := ph1.height - (ph2.height+1);
   if ycoord < 1 then ycoord := 1; end if;
 elsif wm = LNG.PHG_TXT_403 -- Bottom Center
  then
   xcoord := round( (ph1.width-ph2.width)/2);
   if xcoord < 1 then xcoord:= 1; end if;
   ycoord := ph1.height - (ph2.height+1);
   if ycoord < 1 then ycoord := 1; end if;
 elsif wm = LNG.PHG_TXT_415 -- Bottom Right
  then
   xcoord := ph1.width - (ph2.width+1);
   if xcoord < 1 then xcoord := 1; end if;
   ycoord := ph1.height - (ph2.height+1);
   if ycoord < 1 then ycoord := 1; end if;
 end if;

exception when others then
 glbx.error_details( 'GLBX', 'DETERMINE_WM',errmsg=>sqlerrm,extdet=>'WM:' || wm);
 sts := 3;
end determine_wm;

function extract_fname( fname in varchar2, ftype in varchar2 DEFAULT 'NO_EXTENSION', maxlength in integer DEFAULT 100)
 return varchar2
as

 jctr	integer;
 vname	varchar2(1000);

begin
 jctr := NULL;
 if fname is null then return( null ); end if;
 for j in REVERSE 1..length(fname) loop
  if substr(fname,j,1) in ('/','\')
   then
    jctr := j+1;
    exit;
  end if;
 end loop;

 if jctr is null
  then
   vname := fname;
  else
   vname := substr(fname,jctr);
 end if;

 if ftype in ('SUFFIX','NO_EXTENSION')
  then
   jctr := NULL;
   for j in REVERSE 1..length(vname) loop
    if substr(vname,j,1) = '.'
     then
      jctr := j;
      exit;
    end if;
   end loop;
   if ftype = 'SUFFIX'
    then
     return( substr(vname,jctr+1) );
   end if;
   if jctr is not null
    then
     vname := substr(vname,1,jctr-1);
   end if;
 end if;

 if ftype = 'PWD'
  then
   return( substr(fname,1,jctr-1) );
  elsif ftype = 'FILE'
   then
   return( substr(fname,jctr) );
   else
   return( substr(vname,1,maxlength) );
 end if;

exception when others then
 glbx.error_details( 'GLBX', 'EXTRACT_FNAME',errmsg=>sqlerrm,extdet=>'FNAME:[' || fname || ']');
 return(fname);
end extract_fname;

function get_aidx( sesid in integer, gtype in varchar2, ltype in varchar2 )
 return customer_account%ROWTYPE
as
 vltype varchar2(100);
begin
 vltype := ltype;
 return( get_aid( sesid, gtype, vltype ) );
end get_aidx;

function get_aid( sesid in integer, gtype in varchar2, ltype in out varchar2 )
 return customer_account%ROWTYPE
as

 cursor c1(sesid integer) is
  select *
  from customer_account ca
  where ca.aid =
  (select ls.aid
   from login_session ls
   where ls.sessid = sesid and ls.aid = ca.aid);

 cursor c1p(sesid integer) is
  select *
  from customer_profile cp
  where cp.profile_id =
  (select ls.aid
   from login_session ls
   where ls.sessid = sesid and ls.aid = cp.profile_id);

 cursor c2(acid integer) is select * from customer_account where aid = acid;
 cursor c2p(pfid integer) is select * from customer_profile where profile_id = pfid;
 cursor c3(sess_id integer) is select event_id,aid from login_session where sessid = sess_id;
 cursor c4( mfid integer) is select * from manufacturer where manufacturer_id = mfid;
 cursor c4a( sesid integer) is select * from manufacturer where manufacturer_id = (select ls.aid from login_session ls where ls.sessid = sesid);
 cursor c4b( sesid integer) is select * from photographer where pid = (select ls.aid from login_session ls where ls.sessid = sesid);
 cursor c4c( phgid integer) is select * from photographer where pid = phgid;

 c1rec	c1%ROWTYPE;
 c1prec	c1p%ROWTYPE;
 c4rec	c4%ROWTYPE;
 c4brec	c4b%ROWTYPE;
 accid	integer;
 profid	integer;

begin
 if gtype = 'S'
  then
   if ltype in ('PROFILE','PROFILEG')
    then
     open c1p(sesid);
     fetch c1p into c1prec;
     close c1p;
     open c2(c1prec.aid);
     fetch c2 into c1rec;
     close c2;
     c1rec.scene_name := c1prec.scene_name;
     c1rec.theme_name := c1prec.theme_name;
     c1rec.username := c1prec.username;
     c1rec.account_name := c1prec.account_name;
     c1rec.theme_type := c1prec.theme_type;
     c1rec.public_account := c1prec.public_account;
     c1rec.reporting_category := c1prec.reporting_category;
    elsif ltype = 'MANUFACTURER'
     then
      open c4a( sesid );
      fetch c4a into c4rec;
      close c4a;
      c1rec.theme_name := c4rec.theme_name;
      c1rec.account_name := c4rec.name;
      c1rec.scene_name := c4rec.reporting_category;
      c1rec.reporting_category := c4rec.reporting_category;
      c1rec.username := c4rec.username;
      c1rec.aid := c4rec.manufacturer_id;
    elsif ltype = 'PHOTOGRAPHER'
     then
      open c4b( sesid );
      fetch c4b into c4brec;
      close c4b;
      c1rec.theme_name := c4brec.top_frame_lf;
      c1rec.account_name := c4brec.business_name;
      c1rec.scene_name := c4brec.reporting_category;
      c1rec.reporting_category := c4rec.reporting_category;
      c1rec.username := c4brec.username;
      c1rec.aid := c4brec.pid;
    elsif ltype = 'VIRTUAL'
     then
     open c3(sesid);
     fetch c3 into profid,accid;
     close c3;
     open c2(accid);
     fetch c2 into c1rec;
     close c2;
     ltype := 'CUSTOMER';
    else
     open c1(sesid);
     fetch c1 into c1rec;
     close c1;
   end if;
 elsif gtype = 'C'
  then
   if ltype in ('PROFILE','PROFILEG')
    then
     open c2p(sesid);
     fetch c2p into c1prec;
     close c2p;
     open c2(c1prec.aid);
     fetch c2 into c1rec;
     close c2;
     c1rec.scene_name := c1prec.scene_name;
     c1rec.theme_name := c1prec.theme_name;
     c1rec.username := c1prec.username;
     c1rec.account_name := c1prec.account_name;
     c1rec.theme_type := c1prec.theme_type;
     c1rec.public_account := c1prec.public_account;
    elsif ltype = 'MANUFACTURER'
     then
      open c4( sesid );
      fetch c4 into c4rec;
      close c4;
      c1rec.theme_name := c4rec.theme_name;
      c1rec.account_name := c4rec.name;
      c1rec.scene_name := c4rec.reporting_category;
      c1rec.username := c4rec.username;
    elsif ltype = 'PHOTOGRAPHER'
     then
      open c4c( sesid );
      fetch c4c into c4brec;
      close c4c;
      c1rec.theme_name := c4brec.top_frame_lf;
      c1rec.account_name := c4brec.business_name;
      c1rec.scene_name := c4brec.reporting_category;
      c1rec.username := c4brec.username;
    else
     open c2(sesid);
     fetch c2 into c1rec;
     close c2;
     if ltype = 'VIRTUAL' then ltype := 'CUSTOMER'; end if;
   end if;
 end if;
 return( c1rec );
exception when others then
 glbx.error_details( 'GLB', 'GET_AID',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || sesid || ' Gtype is:' || gtype);
end get_aid;

function get_cusrec( sess_id in integer, ltype in out varchar2, acid in integer, profid out integer )
 return customer_account%ROWTYPE
as

 cursor c1_cust(sess_id integer) is
  select *
  from customer_account ca
  where ca.aid in
  (select ls.aid
   from login_session ls
   where ls.sessid = sess_id);

 cursor c1_prof(sess_id integer) is
  select *
  from customer_profile cp
  where cp.profile_id in
  (select ls.aid
   from login_session ls
   where ls.sessid = sess_id);

 cursor c1_phg(sess_id integer, acid integer) is
  select *
  from customer_account ca
  where ca.aid = acid and
        ca.pid in
  (select ls.aid
   from login_session ls
   where ls.sessid = sess_id);

 cursor c2(acid integer) is select * from customer_account where aid = acid;

 cursor c3(sess_id integer) is select event_id,aid from login_session where sessid = sess_id;

 c1rec	c1_cust%ROWTYPE;
 c1prec	c1_prof%ROWTYPE;
 accid	integer;

begin
 if ltype in ('PROFILE','PROFILEG')
  then
   open c1_prof(sess_id);
   fetch c1_prof into c1prec;
   close c1_prof;
   profid := c1prec.profile_id;
   open c2(c1prec.aid);
   fetch c2 into c1rec;
   close c2;
   return( conv_account(c1prec,c1rec) );
 elsif ltype = 'PHOTOGRAPHER'
  then
   open c1_phg(sess_id,acid);
   fetch c1_phg into c1rec;
   close c1_phg;
   return( c1rec );
 elsif ltype in ('OWNER','CUSTOMER')
  then
   open c1_cust(sess_id);
   fetch c1_cust into c1rec;
   close c1_cust;
   return( c1rec );
 elsif ltype = 'VIRTUAL'
  then
   open c3(sess_id);
   fetch c3 into profid,accid;
   close c3;
   open c2(accid);
   fetch c2 into c1rec;
   close c2;
   ltype := 'CUSTOMER';
 end if;

 return( c1rec );

exception when others then
 glbx.error_details( 'GLB', 'GET_CUSREC',errmsg=>sqlerrm,extdet=>'LTYPE:' || ltype || ' SESSID:' || sess_id );
end get_cusrec;


procedure header_msg( txt in varchar2, newline in boolean default TRUE )
as
begin
 htp.header( 2, txt, 'CENTER', cattributes=>'CLASS="ERROR"' );
 if newline then htp.nl; end if;
exception when others then
 glbx.error_details( 'GLB', 'HEADER_MSG',errmsg=>sqlerrm,extdet=>'TXT: ' || txt);
end header_msg;

procedure instruction( txt in varchar2, pfx in theme%ROWTYPE )
as
begin
 -- , pfx.instruct_align, pfx.instruct_cell_border, pfx.instruct_cell_colour
 -- If no cell border then do not display a table. Allow the background image to shine through
 if pfx.instruct_cell_border = 0
  then
    htp.header( 5 + nvl(pfx.instruct_font_inc,0), txt, pfx.instruct_align, cattributes=>'STYLE="font-family: ' || pfx.instruct_text_font || '; color: #' || pfx.instruct_text_colour || '"' );
  else
   htp.tableopen( cattributes=>'cellspacing=0 cellpadding=0 border=' || pfx.instruct_cell_border || 'STYLE="border-color: #' || pfx.instruct_cell_brd_clr || '"' );
   htp.tablerowopen;
    htp.p( '<TD ALIGN="' || pfx.instruct_align || '" valign="MIDDLE" bgcolor="#' || pfx.instruct_cell_colour || '" STYLE="background-color: #' || pfx.instruct_cell_colour || '; color: #' || pfx.instruct_text_colour || '">' );
    htp.header( 5 + nvl(pfx.instruct_font_inc,0), txt, pfx.instruct_align, cattributes=>'STYLE="font-family: ' || pfx.instruct_text_font || '; color: #' || pfx.instruct_text_colour || '" STYLE="background-color: #' || pfx.instruct_cell_colour || '; color: #' || pfx.instruct_text_colour || '" ' );
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tableclose;
 end if;
exception when others then
 glbx.error_details( 'GLB', 'INSTRUCTION',errmsg=>sqlerrm, extdet=>'TXT: ' || txt);
end instruction;

function trg( keep_lhf in char, target in varchar2 )
 return varchar2
as
begin
 if keep_lhf = 'N'
  then
   return( '_top' );
  else
   return( target );
 end if;
end trg;

procedure scene_display( surl in varchar2, custrec in CUSTOMER_ACCOUNT%ROWTYPE, pfx in THEME%ROWTYPE, ltype in varchar2, stype in integer, owner_id in integer, bf92 in char, bf131 in char, imghdr in varchar2, titlegif in varchar2, proftot in integer default 0, expanded_scenes in GLBX.MYARRAY, showtotal in boolean default FALSE, align in varchar2 default 'ALIGN="LEFT"', new_nested in varchar2 default null )
as

 cursor c3_phg( phgid integer, acid integer, utype varchar2, void integer ) is
  select /*+ ALL_ROWS */ um.extras.title title,um.umo_scene_id, um.extras.orderby_scene
  from umo um, customer_account ca
  where um.aid = acid and
        um.extras.title is not null and
        um.umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT') and
        ca.aid = acid and
        ca.pid = phgid
  union
  select usc.title ,usc.umo_scene_id, usc.order_by
  from phg_price_item ppit, phg_price_book ppb, price_book_category pbc, umo_scene usc, order_style os
  where ppit.spb = os.spb and
        os.oid = void and
        shop_item = 'T' and
        pbc.aid = acid and
        usc.umo_scene_id = pbc.umo_scene_id and
        ppb.spb = ppit.spb and
        pbc.ppi = ppit.ppi and
        shop_style = LNG4.AHC_TXT_077
  order by 3;

 cursor c3_own( acid integer, utype varchar2, void integer ) is
  select /*+ ALL_ROWS */ um.extras.title title,um.umo_scene_id, um.extras.orderby_scene
  from umo um
  where um.aid = acid and
        um.extras.title is not null and
        um.umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT') and
        um.extras.enabled_phg='TRUE'
  union
  select usc.title ,usc.umo_scene_id, usc.order_by
  from phg_price_item ppit, phg_price_book ppb, price_book_category pbc, umo_scene usc, order_style os
  where ppit.spb = os.spb and
        os.oid = void and
        shop_item = 'T' and
        pbc.aid = acid and
        usc.umo_scene_id = pbc.umo_scene_id and
        ppb.spb = ppit.spb and
        pbc.ppi = ppit.ppi and
        shop_style = LNG4.AHC_TXT_077
  order by 3;

 cursor c3_gus( acid integer, utype varchar2, void integer ) is
  select /*+ ALL_ROWS */ um.extras.title title,um.umo_scene_id, um.extras.orderby_scene
  from umo um, customer_account ca
  where um.aid = acid and
        um.umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT') and
        um.extras.title is not null and
        um.extras.enabled_phg='TRUE' and
        um.extras.enabled_cus='TRUE'
  union
  select usc.title ,usc.umo_scene_id, usc.order_by
  from phg_price_item ppit, phg_price_book ppb, price_book_category pbc, umo_scene usc, order_style os
  where ppit.spb = os.spb and
        os.oid = void and
        shop_item = 'T' and
        pbc.aid = acid and
        usc.umo_scene_id = pbc.umo_scene_id and
        ppb.spb = ppit.spb and
        pbc.ppi = ppit.ppi and
        shop_style = LNG4.AHC_TXT_077
  order by 3;

 cursor c12(profid integer) is select * from profile_scenes where profile_id = profid order by order_by;

 c3rec		c3_phg%ROWTYPE;
 void		integer;
 b2c_value	char(1);

begin

 -- Display the image header
 if pfx.disploc = 'S'
  then
   htp.nl;
   htp.p( imghdr );
 end if;
 -- If Nested Scenes not supported, then the traditional simple display is used, which runs faster
 if (bf92 = 'F' and pfx.nested_scene_style <> LNG3.ADM_TXT_576)
  then
     htp.tableopen( cattributes=>'cellpadding=1 cellspacing=0 border=' || nvl(pfx.border_around_scene,'0') );
     if proftot = 0
      then
       void := glbx.get_order_style(custrec.aid,owner_id,ltype,b2c_value);
       if ltype = 'PHOTOGRAPHER'
        then
         open c3_phg( owner_id, custrec.aid, ltype, void );
       elsif ltype in ('OWNER','PROFILE')
        then
         open c3_own( custrec.aid, ltype, void );
       elsif ltype in ('CUSTOMER','PROFILEG')
        then
         open c3_gus( custrec.aid, ltype, void );
       end if;
       loop
        if ltype = 'PHOTOGRAPHER'
         then
          fetch c3_phg into c3rec;
          exit when c3_phg%NOTFOUND;
        elsif ltype in ('OWNER','PROFILE')
         then
          fetch c3_own into c3rec;
          exit when c3_own%NOTFOUND;
        elsif ltype in ('CUSTOMER','PROFILEG')
         then
          fetch c3_gus into c3rec;
          exit when c3_gus%NOTFOUND;
        end if;
        htp.tablerowopen;
         if pfx.display_bullet = 'T' and titlegif is not null
         then
          if ltype = 'PHOTOGRAPHER'
           then
            htp.tabledata(htf.anchor2('phg.phg_disp_by_scene_fm?surl=' || glbx.rndsurl(surl) || '&acid=' || custrec.aid || '&scnm=' || c3rec.umo_scene_id,
               htf.img( DECS.IMAGE_LOCATION || 'category/' || titlegif,cattributes=>'border=0 width=12 height=12',calt=>LNG.CST_TXT_019),ctarget=>'PHG_RIGHT'),cattributes=>'VALIGN="TOP"');
           else
             htp.tabledata(htf.anchor2('cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id || '&start_from=1',
               htf.img( DECS.IMAGE_LOCATION || 'category/' || titlegif,cattributes=>'border=0 width=12 height=12',calt=>LNG.CST_TXT_019),ctarget=>trg( pfx.keep_lhf, 'CUS_RIGHT' )),cattributes=>'VALIGN="TOP"');
          end if;
         end if;
         if ltype = 'PHOTOGRAPHER'
          then
           -- htp.tabledata(htf.anchor2('phg.phg_disp_by_scene_fm?surl=' || glbx.rndsurl(surl) || '&acid=' || custrec.aid || '&scnm=' || c3rec.umo_scene_id,'<FONT SIZE="-1">' || htf.italic( nvl(trim(c3rec.title),'&nbsp;') ) || cat_ttl(custrec.aid,c3rec.umo_scene_id,showtotal) || '</FONT>',ctarget=>'PHG_RIGHT'),cattributes=>align);
           show_link(custrec.aid,stype,pfx,c3rec.umo_scene_id,showtotal,'phg.phg_disp_by_scene_fm?surl=' || glbx.rndsurl(surl) || '&acid=' || custrec.aid || '&scnm=' || c3rec.umo_scene_id,c3rec.title,'PHG_RIGHT', TRUE, align, new_nested, bf131);
          else
           -- htp.tabledata(htf.anchor2('cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id || '&start_from=1','<FONT SIZE="-1">' || htf.italic( nvl(trim(c3rec.title),'&nbsp;')) || cat_ttl(custrec.aid,c3rec.umo_scene_id,showtotal) || '</FONT>',ctarget=>trg( pfx.keep_lhf, 'CUS_RIGHT' )),cattributes=>align);
           show_link(custrec.aid,stype,pfx,c3rec.umo_scene_id,showtotal,'cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id || '&start_from=1',c3rec.title,trg( pfx.keep_lhf, 'CUS_RIGHT' ), TRUE, align, new_nested, bf131);
         end if;
        htp.tablerowclose;
       end loop;

     else

       -- If proftot <> 0 (ie. there are categories that should not be displayed for a profile. Only display the following)
       for c12rec in c12( owner_id ) loop
        htp.tablerowopen;
         if pfx.display_bullet = 'T' and titlegif is not null
         then
           htp.tabledata(htf.anchor2('cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id || '&start_from=1',
            htf.img( DECS.IMAGE_LOCATION || 'category/' || titlegif,cattributes=>'border=0 width=12 height=12',calt=>LNG.CST_TXT_019),ctarget=>trg( pfx.keep_lhf, 'CUS_RIGHT' )),cattributes=>'VALIGN="TOP"');
         end if;
         show_link(custrec.aid,stype,pfx,c3rec.umo_scene_id,showtotal,'cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id || '&start_from=1',c12rec.title,trg( pfx.keep_lhf, 'CUS_RIGHT' ), TRUE, align, new_nested, bf131);
         --htp.tabledata(htf.anchor2('cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id || '&start_from=1','<FONT SIZE="-1">' || htf.italic( nvl(trim(c12rec.title),'&nbsp;') ) || cat_ttl(custrec.aid,c3rec.umo_scene_id,showtotal) || '</FONT>',ctarget=>trg( pfx.keep_lhf, 'CUS_RIGHT' )),cattributes=>align);
        htp.tablerowclose;
       end loop;
     end if;
     htp.tableclose;
     htp.nl;
     return;
 end if;

 -- Bf92 = T (Nested Scenes Allowed)
 if pfx.nested_scene_style in (LNG3.ADM_TXT_572,'HOME') -- Expand All
  then
    htp.tableopen( cattributes=>'cellpadding=1 cellspacing=0 border=' || nvl(pfx.border_around_scene,'0') );
     glbx.rec_scene_display( surl, null, 0, custrec, pfx, ltype, stype, owner_id, bf92, bf131, titlegif, proftot, expanded_scenes, showtotal, align, new_nested );
    htp.tableclose;
    htp.nl;

 elsif pfx.nested_scene_style = LNG3.ADM_TXT_571 -- Drill Down
  then
    htp.tableopen( cattributes=>'cellpadding=1 cellspacing=0 border=' || nvl(pfx.border_around_scene,'0') );
     glbx.rec_scene_display( surl, null, 0, custrec, pfx, ltype, stype, owner_id, bf92, bf131, titlegif, proftot, expanded_scenes, showtotal, align, new_nested );
    htp.tableclose;
    htp.nl;

 elsif (pfx.nested_scene_style = LNG3.ADM_TXT_576) -- Lov
  then
   if ltype = 'PHOTOGRAPHER'
    then
     htp.formopen( 'phg.phg_disp_by_scene_fm',ctarget=>'PHG_RIGHT');
     htp.formhidden( 'SURL', glbx.rndsurl(surl));
     htp.formhidden( 'ACID', custrec.aid );
   else
     if pfx.keep_lhf = 'N'
      then
       htp.formopen( 'cst.disp_category',ctarget=>'_top');
      elsif pfx.keep_lhf = '2'
       then
        htp.formopen( 'cst.disp_category',ctarget=>'CUS_BOTTOM');
      else
        htp.formopen( 'cst.disp_category',ctarget=>'CUS_RIGHT');
     end if;
     htp.formhidden( 'SURL', glbx.rndsurl(surl));
   end if;

   if pfx.scene_position = 'L' and pfx.keep_lhf in ('L','R')
    then
     htp.formselectopen( 'LEFT_API_PARM', cattributes=>'onChange="parent.frames[1].location.href = this.options[this.selectedIndex].value;"' );
   elsif pfx.scene_position = 'T' and pfx.keep_lhf in ('L','R') and ltype <> 'PHOTOGRAPHER'
    then
     htp.formselectopen( 'LEFT_API_PARM', cattributes=>'onChange="parent.frames[1].frames[1].location.href = this.options[this.selectedIndex].value;"' );
    elsif pfx.scene_position = 'T' and pfx.keep_lhf = '2'
     then
      htp.formselectopen( 'LEFT_API_PARM', cattributes=>'onChange="parent.frames[1].location.href = this.options[this.selectedIndex].value;"' );
    elsif pfx.scene_position = 'T' and pfx.keep_lhf = 'N' and ltype = 'PHOTOGRAPHER'
     then
      htp.formselectopen( 'LEFT_API_PARM', cattributes=>'onChange="parent.frames[1].location.href = this.options[this.selectedIndex].value;"' );
    elsif pfx.scene_position = 'T' and pfx.keep_lhf = 'N'
     then
      htp.formselectopen( 'LEFT_API_PARM', cattributes=>'onChange="parent.window.location.href = this.options[this.selectedIndex].value;"' );
    else
     htp.formselectopen( 'LEFT_API_PARM', cattributes=>'onChange="parent.frames[1].location.href = this.options[this.selectedIndex].value;"' );
   end if;

   -- language file was : LNG.GLB_TXT_135
   if ltype = 'PHOTOGRAPHER'
     then
      htp.formselectoption( 'Choose Category', cattributes=>'VALUE="glbx.acct_home?surl=' || glbx.rndsurl(surl) || '&acid=' || custrec.aid || '"' );
     else
      htp.formselectoption( 'Choose Category', cattributes=>'VALUE="glbx.acct_home?surl=' || glbx.rndsurl(surl) || '"' );
    end if;
    glbx.rec_scene_display( surl, null, 0, custrec, pfx, ltype, stype, owner_id, bf92, LNG3.ADM_TXT_576, titlegif, proftot, expanded_scenes, showtotal, align, new_nested );
   htp.formselectclose;
   htp.formclose;
 end if;
exception when others then
 glbx.error_details( 'GLB', 'SCENE_DISPLAY',errmsg=>sqlerrm,extdet=>'LTYPE: ' || ltype);
end scene_display;

procedure rec_scene_display( surl in varchar2, lvl in integer, spc in integer, custrec in CUSTOMER_ACCOUNT%ROWTYPE, pfx in THEME%ROWTYPE, ltype in varchar2, stype in integer, owner_id in integer, bf92 in char, bf131 in varchar2, titlegif in varchar2, proftot in integer default 0, expanded_scenes in GLBX.MYARRAY, showtotal in boolean, align in varchar2, new_nested in varchar2 default null )
as

 cursor c3_phg( phgid integer, acid integer, utype varchar2, lvl integer, void integer, ctg varchar2 ) is
  select /*+ ALL_ROWS */ um.extras.title title,um.umo_scene_id, um.extras.orderby_scene, usc.parent_scene
  from umo um, customer_account ca, umo_scene usc
  where um.aid = ca.aid and
        um.extras.title is not null and
        um.umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT') and
        ca.aid = acid and
        nvl(parent_scene,0) = nvl(lvl,0) and
        usc.umo_scene_id = um.umo_scene_id and
        ca.pid = phgid
  union
  select usc.title ,usc.umo_scene_id, usc.order_by, usc.parent_scene
  from phg_price_item ppit, phg_price_book ppb, price_book_category pbc, umo_scene usc, order_style os
  where ppit.spb = os.spb and
        os.oid = void and
        shop_item = 'T' and
        pbc.aid = acid and
        nvl(parent_scene,0) = nvl(lvl,0) and
        usc.umo_scene_id = pbc.umo_scene_id and
        ppb.spb = ppit.spb and
        pbc.ppi = ppit.ppi and
        shop_style = LNG4.AHC_TXT_077
  union
  select usc.title ,usc.umo_scene_id, usc.order_by, usc.parent_scene
  from umo_scene usc
  where exists (select 'x' from umo_scene usc2 where usc2.parent_scene = usc.umo_scene_id) and
        nvl(usc.parent_scene,0) = nvl(lvl,0) and
        ((owned_by = 'PUBLIC') or (owned_by = 'PHOTOGRAPHER' and owner_id = phgid)) and
        usc.category = ctg
  order by 3;

-- Note: Don't need to union as BF 131 says display all categories even if nothing is attached to it.
cursor c3_phg_bf131( phgid integer, acid integer, utype varchar2, lvl integer, ctg varchar2 ) is
  select /*+ ALL_ROWS */ distinct usc.title, usc.umo_scene_id, usc.order_by, usc.parent_scene
  from umo_scene usc, customer_account ca
  where nvl(parent_scene,0) = nvl(lvl,0) and
        ca.aid = acid and
        ca.pid = phgid and
        ca.scene_name = usc.category and
        ((owned_by = 'PUBLIC') or ((owned_by = 'PHOTOGRAPHER') and (owner_id = phgid)))
  order by usc.order_by;

 cursor c3_own( phgid integer, acid integer, utype varchar2, lvl integer, void integer, ctg varchar2 ) is
  select /*+ ALL_ROWS */ um.extras.title title,um.umo_scene_id, um.extras.orderby_scene, usc.parent_scene
  from umo um, umo_scene usc
  where um.aid = acid and
        um.extras.title is not null and
        um.umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT') and
        nvl(parent_scene,0) = nvl(lvl,0) and
        usc.umo_scene_id = um.umo_scene_id and
        um.extras.enabled_phg='TRUE'
  union
  select usc.title ,usc.umo_scene_id, usc.order_by, usc.parent_scene
  from phg_price_item ppit, phg_price_book ppb, price_book_category pbc, umo_scene usc, order_style os
  where ppit.spb = os.spb and
        os.oid = void and
        shop_item = 'T' and
        pbc.aid = acid and
        nvl(parent_scene,0) = nvl(lvl,0) and
        usc.umo_scene_id = pbc.umo_scene_id and
        ppb.spb = ppit.spb and
        pbc.ppi = ppit.ppi and
        shop_style = LNG4.AHC_TXT_077
  union
  select usc.title ,usc.umo_scene_id, usc.order_by, usc.parent_scene
  from umo_scene usc
  where exists (select 'x' from umo_scene usc2 where usc2.parent_scene = usc.umo_scene_id) and
        nvl(usc.parent_scene,0) = nvl(lvl,0) and
        ((owned_by = 'PUBLIC') or (owned_by = 'PHOTOGRAPHER' and owner_id = phgid)) and
        usc.category = ctg
  order by 3;

 cursor c3_gus( phgid integer, acid integer, utype varchar2, lvl integer, void integer, ctg varchar2 ) is
  select /*+ ALL_ROWS */ distinct um.extras.title title,um.umo_scene_id, um.extras.orderby_scene, usc.parent_scene
  from umo um, umo_scene usc
  where um.aid = acid and
        um.extras.title is not null and
        um.umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT') and
        um.extras.enabled_phg='TRUE' and
        nvl(parent_scene,0) = nvl(lvl,0) and
        usc.umo_scene_id = um.umo_scene_id and
        um.extras.enabled_cus='TRUE'
  union
  select usc.title ,usc.umo_scene_id, usc.order_by, usc.parent_scene
  from phg_price_item ppit, phg_price_book ppb, price_book_category pbc, umo_scene usc, order_style os
  where ppit.spb = os.spb and
        os.oid = void and
        shop_item = 'T' and
        pbc.aid = acid and
        nvl(parent_scene,0) = nvl(lvl,0) and
        usc.umo_scene_id = pbc.umo_scene_id and
        ppb.spb = ppit.spb and
        pbc.ppi = ppit.ppi and
        shop_style = LNG4.AHC_TXT_077
  union
  select usc.title ,usc.umo_scene_id, usc.order_by, usc.parent_scene
  from umo_scene usc
  where exists (select 'x' from umo_scene usc2 where usc2.parent_scene = usc.umo_scene_id) and
        nvl(usc.parent_scene,0) = nvl(lvl,0) and
        ((owned_by = 'PUBLIC') or (owned_by = 'PHOTOGRAPHER' and owner_id = phgid)) and
        usc.category = ctg
  order by 3;

-- Cursor Repeated because they are opened twice
cursor c3_phgx( phgid integer, acid integer, utype varchar2, lvl integer, void integer, ctg varchar2 ) is
  select /*+ ALL_ROWS */ um.extras.title title,um.umo_scene_id, um.extras.orderby_scene, usc.parent_scene
  from umo um, customer_account ca, umo_scene usc
  where um.aid = ca.aid and
        um.umo_type in ('PHOTO','AUDIO','VIDEO','DOCUMENT','RELATIONAL','BLUEPRINT') and
        um.extras.title is not null and
        ca.aid = acid and
        nvl(parent_scene,0) = nvl(lvl,0) and
        usc.umo_scene_id = um.umo_scene_id and
        ca.pid = phgid
  union
  select usc.title ,usc.umo_scene_id, usc.order_by, usc.parent_scene
  from phg_price_item ppit, phg_price_book ppb, price_book_category pbc, umo_scene usc, order_style os
  where ppit.spb = os.spb and
        os.oid = void and
        shop_item = 'T' and
        pbc.aid = acid and
        nvl(parent_scene,0) = nvl(lvl,0) and
        usc.umo_scene_id = pbc.umo_scene_id and
        ppb.spb = ppit.spb and
        pbc.ppi = ppit.ppi and
        shop_style = LNG4.AHC_TXT_077
  union
  select usc.title ,usc.umo_scene_id, usc.order_by, usc.parent_scene
  from umo_scene usc
  where exists (select 'x' from umo_scene usc2 where usc2.parent_scene = usc.umo_scene_id) and
        nvl(usc.parent_scene,0) = nvl(lvl,0) and
        usc.category = ctg and
        ((owned_by = 'PUBLIC') or (owned_by = 'PHOTOGRAPHER' and owner_id = phgid))
  order by 3;

cursor c3_phg_bf131x( phgid integer, acid integer, utype varchar2, lvl integer ) is
  select /*+ ALL_ROWS */ distinct usc.title, usc.umo_scene_id, usc.order_by, usc.parent_scene
  from umo_scene usc, customer_account ca
  where nvl(parent_scene,0) = nvl(lvl,0) and
        ca.aid = acid and
        ca.pid = phgid and
        ca.scene_name = usc.category and
        ((owned_by = 'PUBLIC') or ((owned_by = 'PHOTOGRAPHER') and (owner_id = phgid)))
  order by usc.order_by;

 cursor c3_ownx( phgid integer, acid integer, utype varchar2, lvl integer, void integer, ctg varchar2 ) is
  select /*+ ALL_ROWS */ um.extras.title title,um.umo_scene_id, um.extras.orderby_scene, usc.parent_scene
  from umo um, umo_scene usc
  where um.aid = acid and
        um.extras.title is not null and
        um.umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT') and
        nvl(parent_scene,0) = nvl(lvl,0) and
        usc.umo_scene_id = um.umo_scene_id and
        um.extras.enabled_phg='TRUE'
  union
  select usc.title ,usc.umo_scene_id, usc.order_by, usc.parent_scene
  from phg_price_item ppit, phg_price_book ppb, price_book_category pbc, umo_scene usc, order_style os
  where ppit.spb = os.spb and
        os.oid = void and
        shop_item = 'T' and
        pbc.aid = acid and
        nvl(parent_scene,0) = nvl(lvl,0) and
        usc.umo_scene_id = pbc.umo_scene_id and
        ppb.spb = ppit.spb and
        pbc.ppi = ppit.ppi and
        shop_style = LNG4.AHC_TXT_077
  union
  select usc.title ,usc.umo_scene_id, usc.order_by, usc.parent_scene
  from umo_scene usc
  where exists (select 'x' from umo_scene usc2 where usc2.parent_scene = usc.umo_scene_id) and
        nvl(usc.parent_scene,0) = nvl(lvl,0) and
        ((owned_by = 'PUBLIC') or (owned_by = 'PHOTOGRAPHER' and owner_id = phgid)) and
        usc.category = ctg
  order by 3;

 cursor c3_gusx( phgid integer, acid integer, utype varchar2, lvl integer, void integer, ctg varchar2 ) is
  select /*+ ALL_ROWS */ um.extras.title title,um.umo_scene_id, um.extras.orderby_scene, usc.parent_scene
  from umo um, umo_scene usc
  where um.aid = acid and
        um.extras.title is not null and
        um.umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT') and
        um.extras.enabled_phg='TRUE' and
        nvl(parent_scene,0) = nvl(lvl,0) and
        usc.umo_scene_id = um.umo_scene_id and
        um.extras.enabled_cus='TRUE'
  union
  select usc.title ,usc.umo_scene_id, usc.order_by, usc.parent_scene
  from phg_price_item ppit, phg_price_book ppb, price_book_category pbc, umo_scene usc, order_style os
  where ppit.spb = os.spb and
        os.oid = void and
        shop_item = 'T' and
        pbc.aid = acid and
        nvl(parent_scene,0) = nvl(lvl,0) and
        usc.umo_scene_id = pbc.umo_scene_id and
        ppb.spb = ppit.spb and
        pbc.ppi = ppit.ppi and
        shop_style = LNG4.AHC_TXT_077
  union
  select usc.title ,usc.umo_scene_id, usc.order_by, usc.parent_scene
  from umo_scene usc
  where exists (select 'x' from umo_scene usc2 where usc2.parent_scene = usc.umo_scene_id) and
        nvl(usc.parent_scene,0) = nvl(lvl,0) and
        ((owned_by = 'PUBLIC') or (owned_by = 'PHOTOGRAPHER' and owner_id = phgid)) and
        usc.category = ctg
  order by 3;

cursor c3_phgz( phgid integer, acid integer, uscid integer, void integer, ctg varchar2 ) is
  select /*+ ALL_ROWS */ 'x'
  from umo um
  where um.aid = acid and
        um.extras.title is not null and
        um.umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT') and
        um.umo_scene_id = uscid
  union
  select 'x'
  from phg_price_item ppit, phg_price_book ppb, price_book_category pbc, order_style os
  where ppit.spb = os.spb and
        shop_item = 'T' and
        os.oid = void and
        pbc.aid = acid and
        pbc.umo_scene_id = uscid and
        ppb.spb = ppit.spb and
        pbc.ppi = ppit.ppi and
        shop_style = LNG4.AHC_TXT_077
  union
  select 'x'
  from umo_scene usc
  where exists (select 'x' from umo_scene usc2 where usc2.parent_scene = usc.umo_scene_id) and
        nvl(usc.parent_scene,0) = nvl(lvl,0) and
        ((owned_by = 'PUBLIC') or (owned_by = 'PHOTOGRAPHER' and owner_id = phgid)) and
        usc.category = ctg;

 cursor c3_ownz( phgid integer, acid integer, uscid integer, void integer, ctg varchar2 ) is
  select /*+ ALL_ROWS */ 'x'
  from umo um
  where um.aid = acid and
        um.extras.title is not null and
        um.umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT') and
        um.umo_scene_id = uscid and
        um.extras.enabled_phg='TRUE'
  union
  select 'x'
  from phg_price_item ppit, phg_price_book ppb, price_book_category pbc, order_style os
  where ppit.spb = os.spb and
        os.oid = void and
        shop_item = 'T' and
        pbc.aid = acid and
        pbc.umo_scene_id = uscid and
        ppb.spb = ppit.spb and
        pbc.ppi = ppit.ppi and
        shop_style = LNG4.AHC_TXT_077
  union
  select 'x'
  from umo_scene usc
  where exists (select 'x' from umo_scene usc2 where usc2.parent_scene = usc.umo_scene_id) and
        nvl(usc.parent_scene,0) = nvl(lvl,0) and
        ((owned_by = 'PUBLIC') or (owned_by = 'PHOTOGRAPHER' and owner_id = phgid)) and
        usc.category = ctg;

 cursor c3_gusz( phgid integer, acid integer, uscid integer, void integer, ctg varchar2 ) is
  select /*+ ALL_ROWS */ 'x'
  from umo um
  where um.aid = acid and
        um.extras.title is not null and
        um.umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT') and
        um.extras.enabled_phg='TRUE' and
        um.umo_scene_id = uscid and
        um.extras.enabled_cus='TRUE'
  union
  select 'x'
  from phg_price_item ppit, phg_price_book ppb, price_book_category pbc, order_style os
  where ppit.spb = os.spb and
        shop_item = 'T' and
        os.oid = void and
        pbc.aid = acid and
        pbc.umo_scene_id = uscid and
        ppb.spb = ppit.spb and
        pbc.ppi = ppit.ppi and
        shop_style = LNG4.AHC_TXT_077
  union
  select 'x'
  from umo_scene usc
  where exists (select 'x' from umo_scene usc2 where usc2.parent_scene = usc.umo_scene_id) and
        nvl(usc.parent_scene,0) = nvl(lvl,0) and
        ((owned_by = 'PUBLIC') or (owned_by = 'PHOTOGRAPHER' and owner_id = phgid)) and
        usc.category = ctg;

 cursor c4(acid integer, void integer) is
 select /*+ ALL_ROWS */ 'x'
 from phg_price_item ppi, order_style os
 where ppi.spb = os.spb and
       os.oid = void and
       shop_item = 'T' and
       shop_style = LNG2.FNM_TXT_108;

 cursor c12(profid integer) is select * from profile_scenes where profile_id = profid order by order_by;
 cursor c12a(profid integer, uscid integer) is select count('x') tot from profile_scenes where profile_id = profid and umo_scene_id = uscid;

 -- c1rec	c1%ROWTYPE;
 c3rec		c3_phg%ROWTYPE;
 c3recx		c3_phgx%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ctr		integer;
 expfnd		boolean;
 plusex 	boolean;
 tot		char(1);
 ntot		integer;
 void		integer;
 nmb		integer;
 b2c_value	char(1);
 apnd		varchar2(32767);
 tmp		varchar2(32767);

begin

 ctr := 0;
 void := glbx.get_order_style(custrec.aid,owner_id,ltype,b2c_value);

 if ltype = 'PHOTOGRAPHER'
  then
   if bf131 in ('EXPAND ALL','HOME') -- Was T
    then
     open c3_phg_bf131( owner_id, custrec.aid, ltype, lvl, custrec.scene_name );
    else
     open c3_phg( owner_id, custrec.aid, ltype, lvl, void, custrec.scene_name );
   end if;
 elsif ltype in ('OWNER','PROFILE')
  then
   if bf131 in ('EXPAND ALL','HOME') -- was T
    then
     open c3_phg_bf131( custrec.pid, custrec.aid, ltype, lvl, custrec.scene_name );
    else
     open c3_own( custrec.pid, custrec.aid, ltype, lvl, void, custrec.scene_name );
   end if;
 elsif ltype in ('CUSTOMER','PROFILEG')
  then
   if bf131 in ('EXPAND ALL','HOME') -- was T
    then
     open c3_phg_bf131( custrec.pid, custrec.aid, ltype, lvl, custrec.scene_name );
    else
     open c3_gus( custrec.pid, custrec.aid, ltype, lvl, void, custrec.scene_name );
   end if;
 end if;

 loop

      ctr := ctr + 1;
      if ltype = 'PHOTOGRAPHER'
         then
          if bf131 in ('EXPAND ALL','HOME') -- was T
           then
            fetch c3_phg_bf131 into c3rec;
            if c3_phg_bf131%NOTFOUND then close c3_phg_bf131; exit; end if;
           else
            fetch c3_phg into c3rec;
            if c3_phg%NOTFOUND then close c3_phg; exit; end if;
           end if;
       elsif ltype in ('OWNER','PROFILE')
         then
          if bf131 in ('EXPAND ALL','HOME') -- was T
           then
            fetch c3_phg_bf131 into c3rec;
            if c3_phg_bf131%NOTFOUND then close c3_phg_bf131; exit; end if;
           else
            fetch c3_own into c3rec;
            if c3_own%NOTFOUND then close c3_own; exit; end if;
           end if;
        elsif ltype in ('CUSTOMER','PROFILEG')
         then
          if bf131 in ('EXPAND ALL','HOME') -- was T
           then
            fetch c3_phg_bf131 into c3rec;
            if c3_phg_bf131%NOTFOUND then close c3_phg_bf131; exit; end if;
           else
            fetch c3_gus into c3rec;
            if c3_gus%NOTFOUND then close c3_gus; exit; end if;
           end if;
       end if;

       -- Note: BF131 is display all scenes even if no images in theme
       if pfx.nested_scene_style in (LNG3.ADM_TXT_571)  -- Drill Down
        then
         expfnd := FALSE;
         apnd := htf.tablerowopen;
         -- Test - if in expanded list then expand below else either put up plus or not
         for k in expanded_scenes.first..expanded_scenes.last loop
          if to_char(c3rec.umo_scene_id) = expanded_scenes(k)
           then
            expfnd := TRUE;
            exit;
          end if;
         end loop;
         if expfnd
          then
           tmp := NULL;
           for k in expanded_scenes.first..expanded_scenes.last loop
            if to_char(c3rec.umo_scene_id) <> expanded_scenes(k)
             then
              tmp := tmp || '&expanded_scenes=' || expanded_scenes(k);
            end if;
           end loop;
           tmp := substr(tmp,2);
           if tmp is NULL then tmp := 'expanded_scenes='; end if;
           if ltype = 'PHOTOGRAPHER'
             then
              apnd := apnd || htf.tabledata(htf.anchor('phg.phg_acct_left?surl=' || glbx.rndsurl(surl) || '&acid=' || custrec.aid || '&' || tmp || '&new_nested=' || c3rec.umo_scene_id || '#nested',htf.img( DECS.IMAGE_LOCATION || 'adminc/minus.gif', cattributes=>'border=0 VALIGN="TOP"', calt=>LNG.GLB_TXT_079 )),cattributes=>align);
             else
              apnd := apnd || htf.tabledata(htf.anchor('cst.acct_leftx?surl=' || glbx.rndsurl(surl) || '&' || tmp || '&new_nested=' || c3rec.umo_scene_id || '#nested', htf.img( DECS.IMAGE_LOCATION || 'adminc/minus.gif', cattributes=>'border=0 VALIGN="TOP"', calt=>LNG.GLB_TXT_079 )),cattributes=>align);
           end if;
          else
           -- Does Plus sign need to be displayed?
           plusex := FALSE;
           if ltype = 'PHOTOGRAPHER'
            then
             if bf131 in ('EXPAND ALL','HOME') -- was T
              then
               open c3_phg_bf131x( owner_id, custrec.aid, ltype, c3rec.umo_scene_id );
               fetch c3_phg_bf131x into c3recx;
               if c3_phg_bf131x%FOUND then plusex := TRUE; end if;
               close c3_phg_bf131x;
              else
               open c3_phgx( owner_id, custrec.aid, ltype, c3rec.umo_scene_id, void, custrec.scene_name );
               fetch c3_phgx into c3recx;
               if c3_phgx%FOUND then plusex := TRUE; end if;
               close c3_phgx;
              end if;
            elsif ltype in ('OWNER','PROFILE')
             then
             if bf131 in ('EXPAND ALL','HOME') -- was T
              then
               open c3_phg_bf131x( custrec.pid, custrec.aid, ltype, c3rec.umo_scene_id );
               fetch c3_phg_bf131x into c3recx;
               if c3_phg_bf131x%FOUND then plusex := TRUE; end if;
               close c3_phg_bf131x;
              else
               open c3_ownx( custrec.pid, custrec.aid, ltype, c3rec.umo_scene_id, void, custrec.scene_name );
               fetch c3_ownx into c3recx;
               if c3_ownx%FOUND then plusex := TRUE; end if;
               close c3_ownx;
              end if;
            else
             if bf131 in ('EXPAND ALL','HOME') -- was T
              then
               open c3_phg_bf131x( custrec.pid, custrec.aid, ltype, c3rec.umo_scene_id );
               fetch c3_phg_bf131x into c3recx;
               if c3_phg_bf131x%FOUND then plusex := TRUE; end if;
               close c3_phg_bf131x;
              else
               open c3_gusx( custrec.pid, custrec.aid, ltype, c3rec.umo_scene_id, void, custrec.scene_name );
               fetch c3_gusx into c3recx;
               if c3_gusx%FOUND then plusex := TRUE; end if;
               close c3_gusx;
              end if;
           end if;

           if plusex
            then
             tmp := NULL;
             for k in expanded_scenes.first..expanded_scenes.last loop
               tmp := tmp || '&expanded_scenes=' || expanded_scenes(k);
             end loop;
             tmp := 'expanded_scenes=' || c3rec.umo_scene_id || tmp;
             if ltype = 'PHOTOGRAPHER'
              then
               apnd := apnd || htf.tabledata(htf.anchor('phg.phg_acct_left?surl=' || glbx.rndsurl(surl) || '&acid=' || custrec.aid || '&' || tmp || '&new_nested=' || c3rec.umo_scene_id || '#nested',htf.img( DECS.IMAGE_LOCATION || 'adminc/plus.gif', cattributes=>'border=0', calt=>LNG.GLB_TXT_072 )),cattributes=>align);
              else
               apnd := apnd || htf.tabledata(htf.anchor('cst.acct_leftx?surl=' || glbx.rndsurl(surl) || '&' || tmp || '&new_nested=' || c3rec.umo_scene_id || '#nested', htf.img( DECS.IMAGE_LOCATION || 'adminc/plus.gif', cattributes=>'border=0', calt=>LNG.GLB_TXT_072 )),cattributes=>align);
             end if;
            else
             apnd := apnd || htf.tabledata( '&nbsp;' );
           end if;
         end if;

         apnd := apnd || '<TD STYLE="font-size: ' || to_char(6 + nvl(pfx.anchor_font_adj,0) + trunc(stype/1.5)) || 'pt">';
         for j in 1..spc loop
           apnd := apnd || pfx.nested_scene_delim;
         end loop;

         if bf131 in ('EXPAND ALL','HOME') -- was T
          then
            if ltype = 'PHOTOGRAPHER'
             then
              open c3_phgz(custrec.pid, custrec.aid,c3rec.umo_scene_id, void, custrec.scene_name);
              fetch c3_phgz into tmp;
              if c3_phgz%FOUND
               then
                show_link(custrec.aid,stype,pfx,c3rec.umo_scene_id,showtotal,'phg.phg_disp_by_scene_fm?surl=' || glbx.rndsurl(surl) || '&acid=' || custrec.aid || '&scnm=' || c3rec.umo_scene_id,c3rec.title,'PHG_RIGHT', FALSE, NULL, new_nested, bf131, apnd);
                htp.p( '</TD>' );
                htp.tablerowclose;
               else
                htp.p( apnd );
                htp.p(htf.italic( nvl(trim(c3rec.title),'&nbsp;') ));
                htp.p( '</TD>' );
                htp.tablerowclose;
              end if;
              close c3_phgz;

             elsif ltype in ('OWNER','PROFILE')
              then
              open c3_ownz(custrec.pid, custrec.aid,c3rec.umo_scene_id, void, custrec.scene_name);
              fetch c3_ownz into tmp;
              ntot := 1;
              if ltype = 'PROFILE' and proftot > 0 -- Check to see if allowed to be displayed
               then
                ntot := 0;
                open c12a(owner_id,c3rec.umo_scene_id);
                fetch c12a into ntot;
                close c12a;
              end if;
              if c3_ownz%FOUND and ntot > 0
               then
                show_link(custrec.aid,stype,pfx,c3rec.umo_scene_id,showtotal,'cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id  || '&start_from=1',c3rec.title,trg( pfx.keep_lhf, 'CUS_RIGHT' ), FALSE, NULL, new_nested, bf131, apnd);
                htp.p( '</TD>' );
                htp.tablerowclose;
               else
                htp.p( apnd );
                htp.p(htf.italic( nvl(trim(c3rec.title),'&nbsp;') ));
                htp.p( '</TD>' );
                htp.tablerowclose;
              end if;
              close c3_ownz;

             elsif ltype in ('CUSTOMER','PROFILEG')
              then
              open c3_gusz(custrec.pid, custrec.aid,c3rec.umo_scene_id, void, custrec.scene_name);
              fetch c3_gusz into tmp;
              ntot := 1;
              if ltype = 'PROFILEG' and proftot > 0 -- Check to see if allowed to be displayed
               then
                ntot := 0;
                open c12a(owner_id,c3rec.umo_scene_id);
                fetch c12a into ntot;
                close c12a;
              end if;
              if c3_gusz%FOUND and ntot > 0
               then
                show_link(custrec.aid,stype,pfx,c3rec.umo_scene_id,showtotal,'cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id  || '&start_from=1',c3rec.title,trg( pfx.keep_lhf, 'CUS_RIGHT' ), FALSE, NULL, new_nested, bf131, apnd);
                --htp.anchor2('cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id  || '&start_from=','<FONT SIZE="-1">' || htf.italic( nvl(trim(c3rec.title),'&nbsp;') ) || cat_ttl(custrec.aid,c3rec.umo_scene_id,showtotal) || '</FONT>',ctarget=>trg( pfx.keep_lhf, 'CUS_RIGHT' ));
                htp.p( '</TD>' );
                htp.tablerowclose;
               else
                htp.p( apnd );
                htp.p(htf.italic( nvl(trim(c3rec.title),'&nbsp;') ));
                htp.p( '</TD>' );
                htp.tablerowclose;
              end if;
              close c3_gusz;
            end if;

         else
          -- Only displayed scenes allowed and images exist
          if ltype = 'PHOTOGRAPHER'
           then
            show_link(custrec.aid,stype,pfx,c3rec.umo_scene_id,showtotal,'phg.phg_disp_by_scene_fm?surl=' || glbx.rndsurl(surl) || '&acid=' || custrec.aid || '&scnm=' || c3rec.umo_scene_id,c3rec.title,'PHG_RIGHT', FALSE, NULL, new_nested, bf131, apnd);
            --htp.anchor2('phg.phg_disp_by_scene_fm?surl=' || glbx.rndsurl(surl) || '&acid=' || custrec.aid || '&scnm=' || c3rec.umo_scene_id,'<FONT SIZE="-1">' || htf.italic( nvl(trim(c3rec.title),'&nbsp;') ) || cat_ttl(custrec.aid,c3rec.umo_scene_id,showtotal) || '</FONT>',ctarget=>'PHG_RIGHT');
            htp.p( '</TD>' );
            htp.tablerowclose;
           else
            if ltype in ('PROFILE','PROFILEG') and proftot > 0 -- Check to see if allowed to be displayed
             then
              open c12a(owner_id,c3rec.umo_scene_id);
              ntot := 0;
              fetch c12a into ntot;
              if ntot > 0
               then
                show_link(custrec.aid,stype,pfx,c3rec.umo_scene_id,showtotal, 'cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id  || '&start_from=1',c3rec.title,trg( pfx.keep_lhf, 'CUS_RIGHT' ), FALSE, NULL, new_nested, bf131, apnd);
                --htp.anchor2('cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id  || '&start_from=1','<FONT SIZE="-1">' || htf.italic( nvl(trim(c3rec.title),'&nbsp;') ) || cat_ttl(custrec.aid,c3rec.umo_scene_id,showtotal) || '</FONT>',ctarget=>trg( pfx.keep_lhf, 'CUS_RIGHT' ));
                htp.p( '</TD>' );
                htp.tablerowclose;
              end if;
              close c12a;
             else
              show_link(custrec.aid,stype,pfx,c3rec.umo_scene_id,showtotal,'cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id  || '&start_from=1',c3rec.title,trg( pfx.keep_lhf, 'CUS_RIGHT' ), FALSE, NULL, new_nested, bf131, apnd);
              -- htp.anchor2('cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id  || '&start_from=1','<FONT SIZE="-1">' || htf.italic( nvl(trim(c3rec.title),'&nbsp;') ) || cat_ttl(custrec.aid,c3rec.umo_scene_id,showtotal) || '</FONT>',ctarget=>trg( pfx.keep_lhf, 'CUS_RIGHT' ));
              htp.p( '</TD>' );
              htp.tablerowclose;
            end if;
          end if;
         end if;
        if expfnd then glbx.rec_scene_display( surl, c3rec.umo_scene_id, spc + 1, custrec, pfx, ltype, stype, owner_id, bf92, bf131, titlegif, proftot, expanded_scenes, showtotal, align, new_nested ); end if;

       elsif pfx.nested_scene_style in (LNG3.ADM_TXT_572,'HOME') -- Expand All
        then
         apnd := htf.tablerowopen;
         if pfx.display_bullet = 'T' and titlegif is not null
          then
           if ltype = 'PHOTOGRAPHER'
            then
             apnd := apnd || htf.tabledata(htf.anchor2('phg.phg_disp_by_scene_fm?surl=' || glbx.rndsurl(surl) || '&acid=' || custrec.aid || '&scnm=' || c3rec.umo_scene_id,
                htf.img( DECS.IMAGE_LOCATION || 'category/' || titlegif,cattributes=>'border=0 width=12 height=12',calt=>LNG.CST_TXT_019),ctarget=>'PHG_RIGHT'),cattributes=>align);
            else
              apnd := apnd || htf.tabledata(htf.anchor2('cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id || '&start_from=',
                htf.img( DECS.IMAGE_LOCATION || 'category/' || titlegif,cattributes=>'border=0 width=12 height=12',calt=>LNG.CST_TXT_019),ctarget=>trg( pfx.keep_lhf, 'CUS_RIGHT' )),cattributes=>align);
           end if;
         end if;
         apnd := apnd || '<TD STYLE="font-size: ' || to_char(6 + nvl(pfx.anchor_font_adj,0) + trunc(stype/1.5)) || 'pt">';
         for j in 1..spc loop
           apnd := apnd || pfx.nested_scene_delim;
         end loop;
         if bf131 in ('EXPAND ALL','HOME') -- was T
          then
            if ltype = 'PHOTOGRAPHER'
             then
              open c3_phgz(custrec.pid, custrec.aid,c3rec.umo_scene_id, void, custrec.scene_name);
              fetch c3_phgz into tmp;
              if c3_phgz%FOUND
               then
                show_link(custrec.aid,stype,pfx,c3rec.umo_scene_id,showtotal,'phg.phg_disp_by_scene_fm?surl=' || glbx.rndsurl(surl) || '&acid=' || custrec.aid || '&scnm=' || c3rec.umo_scene_id,c3rec.title,'PHG_RIGHT', FALSE, NULL, new_nested, bf131, apnd);
                -- htp.anchor2('phg.phg_disp_by_scene_fm?surl=' || glbx.rndsurl(surl) || '&acid=' || custrec.aid || '&scnm=' || c3rec.umo_scene_id,'<FONT SIZE="-1">' || htf.italic( nvl(trim(c3rec.title),'&nbsp;') ) || cat_ttl(custrec.aid,c3rec.umo_scene_id,showtotal) || '</FONT>',ctarget=>'PHG_RIGHT');
                htp.p( '</TD>' );
                htp.tablerowclose;
               else
                htp.p( apnd );
                htp.p(htf.italic( nvl(trim(c3rec.title),'&nbsp;') ));
                htp.p( '</TD>' );
                htp.tablerowclose;
              end if;
              close c3_phgz;
             elsif ltype in ('OWNER','PROFILE')
              then
              open c3_ownz(custrec.pid, custrec.aid,c3rec.umo_scene_id, void, custrec.scene_name);
              fetch c3_ownz into tmp;
              ntot := 1;
              if ltype = 'PROFILE' and proftot > 0 -- Check to see if allowed to be displayed
               then
                ntot := 0;
                open c12a(owner_id,c3rec.umo_scene_id);
                fetch c12a into ntot;
                close c12a;
              end if;
              if c3_ownz%FOUND and ntot > 0
               then
                show_link(custrec.aid,stype,pfx,c3rec.umo_scene_id,showtotal,'cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id  || '&start_from=1',c3rec.title,trg( pfx.keep_lhf, 'CUS_RIGHT' ), FALSE, NULL, new_nested, bf131, apnd);
                --htp.anchor2(,'<FONT SIZE="-1">' || htf.italic( nvl(trim(c3rec.title),'&nbsp;') ) || cat_ttl(custrec.aid,c3rec.umo_scene_id,showtotal) || '</FONT>',ctarget=>trg( pfx.keep_lhf, 'CUS_RIGHT' ));
                htp.p( '</TD>' );
                htp.tablerowclose;
               else
                htp.p( apnd );
                htp.p(htf.italic( nvl(trim(c3rec.title),'&nbsp;') ));
                htp.p( '</TD>' );
                htp.tablerowclose;
              end if;
              close c3_ownz;
             elsif ltype in ('CUSTOMER','PROFILEG')
              then
              open c3_gusz(custrec.pid, custrec.aid,c3rec.umo_scene_id, void, custrec.scene_name);
              fetch c3_gusz into tmp;
              ntot := 1;
              if ltype = 'PROFILEG' and proftot > 0 -- Check to see if allowed to be displayed
               then
                ntot := 0;
                open c12a(owner_id,c3rec.umo_scene_id);
                fetch c12a into ntot;
                close c12a;
              end if;
              if c3_gusz%FOUND and ntot > 0
               then
                show_link(custrec.aid,stype,pfx,c3rec.umo_scene_id,showtotal,'cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id  || '&start_from=1',c3rec.title,trg( pfx.keep_lhf, 'CUS_RIGHT' ), FALSE, NULL, new_nested, bf131, apnd);
                --htp.anchor2('cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id  || '&start_from=1','<FONT SIZE="-1">' || htf.italic( nvl(trim(c3rec.title),'&nbsp;') ) || cat_ttl(custrec.aid,c3rec.umo_scene_id,showtotal) || '</FONT>',ctarget=>trg( pfx.keep_lhf, 'CUS_RIGHT' ));
                htp.p( '</TD>' );
                htp.tablerowclose;
               else
                htp.p( apnd );
                htp.p(htf.italic( nvl(trim(c3rec.title),'&nbsp;') ));
                htp.p( '</TD>' );
                htp.tablerowclose;
              end if;
              close c3_gusz;
            end if;
          else
           if ltype = 'PHOTOGRAPHER'
            then
             show_link(custrec.aid,stype,pfx,c3rec.umo_scene_id,showtotal,'phg.phg_disp_by_scene_fm?surl=' || glbx.rndsurl(surl) || '&acid=' || custrec.aid || '&scnm=' || c3rec.umo_scene_id,c3rec.title,'PHG_RIGHT', FALSE, NULL, new_nested, bf131, apnd);
             --htp.anchor2('phg.phg_disp_by_scene_fm?surl=' || glbx.rndsurl(surl) || '&acid=' || custrec.aid || '&scnm=' || c3rec.umo_scene_id,'<FONT SIZE="-1">' || htf.italic( nvl(trim(c3rec.title),'&nbsp;') ) || cat_ttl(custrec.aid,c3rec.umo_scene_id,showtotal) || '</FONT>',ctarget=>'PHG_RIGHT');
             htp.p( '</TD>' );
             htp.tablerowclose;
            else
             if ltype in ('PROFILE','PROFILEG') and proftot > 0 -- Check to see if allowed to be displayed
              then
               open c12a(owner_id,c3rec.umo_scene_id);
               ntot := 0;
               fetch c12a into ntot;
               --htp.bold( ntot || '-' || c3rec.umo_scene_id || '-' || owner_id || '-' || nvl(trim(c3rec.title),'&nbsp;') ); htp.nl;
               if ntot > 0
                then
                 show_link(custrec.aid,stype,pfx,c3rec.umo_scene_id,showtotal,'cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id  || '&start_from=1',c3rec.title,trg( pfx.keep_lhf, 'CUS_RIGHT' ), FALSE, NULL, new_nested, bf131, apnd);
                 -- htp.anchor2('cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id  || '&start_from=1','<FONT SIZE="-1">' || htf.italic( nvl(trim(c3rec.title),'&nbsp;') ) || cat_ttl(custrec.aid,c3rec.umo_scene_id,showtotal) || '</FONT>',ctarget=>trg( pfx.keep_lhf, 'CUS_RIGHT' ));
                 htp.p( '</TD>' );
                 htp.tablerowclose;
               end if;
               close c12a;
              else
               show_link(custrec.aid,stype,pfx,c3rec.umo_scene_id,showtotal,'cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id  || '&start_from=1',c3rec.title,trg( pfx.keep_lhf, 'CUS_RIGHT' ), FALSE, NULL, new_nested, bf131, apnd);
               --htp.anchor2('cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id  || '&start_from=1','<FONT SIZE="-1">' || htf.italic( nvl(trim(c3rec.title),'&nbsp;') ) || cat_ttl(custrec.aid,c3rec.umo_scene_id,showtotal) || '</FONT>',ctarget=>trg( pfx.keep_lhf, 'CUS_RIGHT' ));
               htp.p( '</TD>' );
               htp.tablerowclose;
             end if;
           end if;
         end if;
        glbx.rec_scene_display( surl, c3rec.umo_scene_id, spc + 1, custrec, pfx, ltype, stype, owner_id, bf92, bf131, titlegif, proftot, expanded_scenes, showtotal, align, new_nested );

       elsif (pfx.nested_scene_style = LNG3.ADM_TXT_576) -- LOV
        then
         tmp := NULL;
         for j in 1..spc loop
           tmp := tmp || pfx.nested_scene_delim;
         end loop;
         tmp := tmp || c3rec.title;
         nmb := 0;
         if c3rec.parent_scene is null then nmb := category_total(custrec.aid,c3rec.umo_scene_id); else nmb := 1; end if;
         if ltype = 'PHOTOGRAPHER'
          then
           if nmb > 0 then htp.formselectoption( tmp, cattributes=>'VALUE="' || 'phg.phg_disp_by_scene_fm?surl=' || glbx.rndsurl(surl) || '&acid=' || custrec.aid || '&scnm=' || c3rec.umo_scene_id || '"' ); end if;
          else
           if ltype in ('PROFILE','PROFILEG') and proftot > 0 -- Check to see if allowed to be displayed
            then
              open c12a(owner_id,c3rec.umo_scene_id);
              ntot := 0;
              fetch c12a into ntot;
              if ntot > 0
               then
                if nmb > 0 then htp.formselectoption( tmp, cattributes=>'VALUE="' || 'cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id  || '&start_from=1"' ); end if;
              end if;
              close c12a;
            else
             if nmb > 0 then htp.formselectoption( tmp, cattributes=>'VALUE="' || 'cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id  || '&start_from=1"' ); end if;
           end if;
         end if;
        glbx.rec_scene_display( surl, c3rec.umo_scene_id, spc + 1, custrec, pfx, ltype, stype, owner_id, bf92, bf131, titlegif, proftot, expanded_scenes, showtotal, align, new_nested );

       end if;
     end loop;

   -- Look for General Shop Item
   if spc = 0
    then
     open c4(custrec.aid, void);
     fetch c4 into c4rec;
     if c4%FOUND
      then
       close c4;
       if (pfx.nested_scene_style = LNG3.ADM_TXT_576) or (pfx.nested_scene_style = LNG3.ADM_TXT_575 and ltype = 'PHOTOGRAPHER')
        then
         if ltype = 'PHOTOGRAPHER'
          then
            htp.formselectoption( glbx.userpref(custrec.pid,custrec.aid,'STORE'), cattributes=>'VALUE="' || 'phg.phg_disp_by_scene_fm?surl=' || glbx.rndsurl(surl) || '&acid=' || custrec.aid || '&scnm=STORE"' );
           else
            htp.formselectoption( glbx.userpref(custrec.pid,custrec.aid,'STORE'), cattributes=>'VALUE="' || 'cst.disp_store?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id  || '&start_from=1"' );
         end if;
        elsif pfx.nested_scene_style in (LNG3.ADM_TXT_572 ,LNG3.ADM_TXT_571, 'HOME')
         then
          apnd := htf.tablerowopen;
           if pfx.display_bullet = 'T' and pfx.nested_scene_style in (LNG3.ADM_TXT_572,'HOME') and titlegif is not null
            then
            if ltype = 'PHOTOGRAPHER'
             then
              apnd := apnd || htf.tabledata(htf.anchor2('phg.phg_disp_by_scene_fm?surl=' || glbx.rndsurl(surl) || '&acid=' || custrec.aid || '&scnm=STORE',
                      htf.img( DECS.IMAGE_LOCATION || 'category/' || titlegif,cattributes=>'border=0 width=12 height=12',calt=>LNG.CST_TXT_019),ctarget=>'PHG_RIGHT'),cattributes=>'VALIGN="TOP"');
             else
              apnd := apnd || htf.tabledata(htf.anchor2('cst.disp_store?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id  || '&start_from=1',
                      htf.img( DECS.IMAGE_LOCATION || 'category/' || titlegif,cattributes=>'border=0 width=12 height=12',calt=>LNG.CST_TXT_019),ctarget=>trg( pfx.keep_lhf, 'CUS_RIGHT' )),cattributes=>'VALIGN="TOP"');
            end if;
           else
            apnd := apnd || htf.tabledata( '&nbsp;' );
           end if;
           if ltype = 'PHOTOGRAPHER'
            then
             apnd := apnd || htf.tabledata(htf.anchor2('phg.phg_disp_by_scene_fm?surl=' || glbx.rndsurl(surl) || '&acid=' || custrec.aid || '&scnm=STORE', htf.italic( glbx.userpref(custrec.pid,custrec.aid,'STORE') ),ctarget=>'PHG_RIGHT'),cattributes=>align);
            else
             apnd := apnd || htf.tabledata(htf.anchor2('cst.disp_store?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c3rec.umo_scene_id  || '&start_from=1',htf.italic( glbx.userpref(custrec.pid,custrec.aid,'STORE') ),ctarget=>trg( pfx.keep_lhf, 'CUS_RIGHT' )),cattributes=>align);
           end if;
           htp.p( apnd );
           htp.p( '</TD>' );
           htp.tablerowclose;
       end if;
      else
       close c4;
     end if;
   end if;

exception when others then
 glbx.error_details( 'GLB', 'REC_SCENE_DISPLAY',errmsg=>sqlerrm,extdet=>'LTYPE: ' || ltype);
end rec_scene_display;

function get_random_sessionid
 return integer
as

 cursor c1(sess_id integer) is select count('x') tot from login_session where sessid = sess_id;

 c1rec	c1%ROWTYPE;
 nmb	integer;
 infctr	integer;

begin

 dbms_random.Initialize(to_number(TO_CHAR(SYSDATE,'SSSSS')));
 infctr := 0;
 nmb := abs(dbms_random.Random);

 loop
  open c1(nmb);
  fetch c1 into c1rec;
  close c1;
  if c1rec.tot = 0
   then
    exit;
  end if;

  infctr := infctr + 1;
  if infctr between 1000 and 10000
   then
    select s_login_session.nextval into nmb from dual;

  elsif infctr > 10000
   then
    glbx.error_details( 'GLB', 'GET_RANDOM_SESSIONID',errmsg=>sqlerrm, extdet=> 'Unable to extract random number' );
    nmb := 1;
    exit;

  else
    nmb := abs(dbms_random.Random);

  end if;

 end loop;

 dbms_random.terminate;
 return( nmb );

exception when others then
 glbx.error_details( 'GLB', 'GET_RANDOM_SESSIONID',errmsg=>sqlerrm);
end get_random_sessionid;

function linkdisp( surl in varchar2, v_umo integer, to_umo in integer, linkstrength in number, linktype in varchar2, filmname in varchar2, photoname in varchar2, stype in integer, acid in integer )
 return varchar2
as
 clr	varchar2(4000);
begin
 if linktype = LNG2.PBK_TXT_064 -- Colour High
  then
   if     linkstrength between 0 and 4 then clr :=   'FFFFF0';
    elsif linkstrength between 5 and 10 then clr :=  'FFFFFC';
    elsif linkstrength between 11 and 15 then clr := 'FFFF00';
    elsif linkstrength between 16 and 20 then clr := 'FFFFCC';
    elsif linkstrength between 21 and 25 then clr := 'FFF000';
    elsif linkstrength between 26 and 30 then clr := 'FFFC0C';
    elsif linkstrength between 31 and 35 then clr := 'FF0000';
    elsif linkstrength between 36 and 40 then clr := 'FFC00C';
    elsif linkstrength between 41 and 45 then clr := 'F00000';
    elsif linkstrength between 46 and 50 then clr := 'FC000C';
    elsif linkstrength between 51 and 55 then clr := '00000C';
    elsif linkstrength > 56 then clr := '000000';
   end if;
   clr := '<FONT COLOUR=#' || clr || '>' || nvl(photoname,filmname) || '</FONT>';
 elsif linktype = LNG2.PBK_TXT_065   -- Colour Low
  then
   if     linkstrength between 0 and 4 then clr :=   '000000';
    elsif linkstrength between 5 and 10 then clr :=  '00000C';
    elsif linkstrength between 11 and 15 then clr := 'F00000';
    elsif linkstrength between 16 and 20 then clr := 'FC000C';
    elsif linkstrength between 21 and 25 then clr := 'FFC00C';
    elsif linkstrength between 26 and 30 then clr := 'FF0000';
    elsif linkstrength between 31 and 35 then clr := 'FFF000';
    elsif linkstrength between 36 and 40 then clr := 'FFFC0C';
    elsif linkstrength between 41 and 45 then clr := 'FFFFCC';
    elsif linkstrength between 46 and 50 then clr := 'FFFF00';
    elsif linkstrength between 51 and 55 then clr := 'FFFFFC';
    elsif linkstrength > 56 then clr := 'FFFFF0';
   end if;
   clr := '<FONT COLOUR=#' || clr || '>' || nvl(photoname,filmname) || '</FONT>';
 elsif linktype = LNG2.PBK_TXT_066 -- Number
  then
   clr := nvl(photoname,filmname) || '(' || htf.italic(to_char(trunc(linkstrength))) || ')';
 elsif linktype = LNG2.PBK_TXT_067 -- Bar
  then
   clr := nvl(photoname,filmname) || ' <HR ALIGN="LEFT" COLOR="#09334C" SIZE="5" WIDTH="' || round(linkstrength/10) || '">';
 end if;

 return( htf.anchor2( 'glbx.transfer_link?surl=' || surl || '&v_umo=' || to_char(v_umo) || '&to_umo=' || to_umo || '&src=LINK&acid=' || acid, clr, ctarget=>'CUS_RIGHT' ) );

exception when others then
 glbx.error_details( 'GLB', 'LINKDISP',errmsg=>sqlerrm, extdet=>'LINKSTRENGTH:' || to_char(linkstrength) || ' LINKTTYPE:' || linktype || ' FILMNAME:' || filmname || ' PHOTONAME:' || photoname );
 return( NULL );
end linkdisp;

procedure transfer_link( surl in varchar2, v_umo in integer, to_umo in integer, src in varchar2, acid in integer )
as

 cursor c2(v_umo integer, acid integer) is select * from umo where umo_id = v_umo and aid = acid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 result_list	UMP.SEARCH_RESULT_PHG;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GLBX.TRANSFER_LINK');
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );

 update umo_link
  set
   connections = nvl(connections,0) + 1,
   weighting = nvl(weighting,0) + 1
 where umo_id = v_umo and
       to_umo_id = to_umo and
       link_type = 'T';

 commit;

 open c2(to_umo,c1rec.aid);
 fetch c2 into c2rec;
 close c2;
 result_list(1) := c2rec;

 if src = 'LINK'
  then
   extended_search_api( surl=>surl, ltype=>ltype, result_list=>result_list, search_total=>1, title=>'Linked Record', acid=>acid, current_page_number=>'1');
   return;
 end if;

exception when others then
 glbx.error_details( 'GLB', 'TRANSFER_LINK',errmsg=>sqlerrm, extdet=>'V_UMO:' || to_char(v_umo) || ' TO_UMO:' || to_umo || ' SRC:' || src );
end transfer_link;

procedure validate_meta_tag( tag_value in varchar2, tag_record in UMO_ATTRIBUTES%ROWTYPE, result out varchar2 )
as
 nmb	number;
 int	integer;
 dt	date;
begin
 result := NULL;
 -- Check mandatory
 if tag_record.mandatory = 'T' and tag_value is null
  then
   result := LNG2.PBK_TXT_101;
   return;
 end if;

 -- Return if null
 if trim(tag_value)is null or
    ascii(tag_value) = 49824 then return; end if; -- UTF8 Space

 if tag_record.edit_type  = 'VARCHAR'
  then
   if length(tag_value) > tag_record.maxlength
    then
     result := LNG2.PBK_TXT_102 || tag_record.maxlength;
     return;
   end if;
 elsif tag_record.edit_type = 'SQL'
  then
   null;
 elsif tag_record.edit_type = 'SQL QUERY'
  then
   null;
 elsif tag_record.edit_type in ('LOV','Boolean')
  then
   if tag_record.edit_type = 'Boolean' then
    if instr(',' || upper(tag_record.lov_list) || ',' , ',' || upper(substr(tag_value, -1, 1)) || ',') = 0
     then
      result := LNG2.PBK_TXT_103 || ':' || tag_value || '-' || tag_record.attribute_id || '-' || tag_record.lov_list || '[' || length(tag_value) || ':' || ascii(tag_value);
      return;
    end if;
   else
    if instr(',' || upper(tag_record.lov_list) || ',' , ',' || upper(tag_value) || ',') = 0
     then
      result := LNG2.PBK_TXT_103 || ':' || tag_value || '-' || tag_record.attribute_id || '-' || tag_record.lov_list || '[' || length(tag_value) || ':' || ascii(tag_value);
      return;
    end if;
   end if;
 elsif tag_record.edit_type = 'NUMBER'
  then
   begin
    nmb := to_number(tag_value);
   exception
    when others then
     result := LNG2.PBK_TXT_104;
     return;
   end;
 elsif tag_record.edit_type = 'INTEGER'
  then
   begin
    int := to_number(tag_value);
    if to_char(int) <> tag_value
     then
      result := LNG2.PBK_TXT_105;
      return;
   end if;
   exception
    when others then
     result := LNG2.PBK_TXT_105;
     return;
   end;
 elsif tag_record.edit_type = 'DATE'
  then
   begin
    dt := to_date(tag_value,LNG.MASK);
   exception
    when others then
     result := LNG2.PBK_TXT_106 || ':' || LNG.MASK;
     return;
   end;
 elsif tag_record.edit_type = 'TIME'
  then
   begin
    dt := to_date(tag_value,LNG.TSMASK_ONLY);
   exception
    when others then
     result := LNG2.PBK_TXT_107 || ':' || LNG.TSMASK_ONLY;
     return;
   end;
 end if;

exception when others then
 glbx.error_details( 'GLB', 'VALIDATE_META_TAG',errmsg=>sqlerrm, extdet=>'TAG_VALUE:' || tag_value );
end validate_meta_tag;

procedure displog( surl in varchar2, acid integer, action in varchar2 default 'VIEW', acc in varchar2 default 'ADMIN', new_window in varchar2 default 'T' )
is

 cursor c1(acid integer) is select username from customer_account where aid = acid;
 cursor c2(acid integer) is select * from load_log where aid= acid order by time_start;
 cursor c3(manid integer) is select username from manufacturer where manufacturer_id = manid;

 c1rec		c1%ROWTYPE;
 sessid		integer;
 sts		varchar2(200);
 stype		integer;
 ltype		varchar2(100);
 owner_id	integer;
 pfx		THEME%ROWTYPE;
 foundrec	boolean;
 imgld		integer;
 imgfl		integer;
 ftime		date;
 ltime		date;

begin
 if acc = 'ADMIN'
  then
   glbx.adm_cookie_id(surl,sessid,sts,'ADM.DISPLOG');
   if sts is not null
    then
     htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
   end if;
  else
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'GLBX.DISPLOG', iscust=>FALSE );
   if sts is not null
    then
     glbx.redisplay_login_page( sts );
   return;
   end if;
 end if;

 pfx := glbx.get_thm( acid );

 if action = 'DELETE'
  then
   delete from load_log where aid = acid;
   commit;
   htp.htmlopen;
   glbx.header_msg(LNG3.ADM_TXT_755);
   if new_window = 'T'
    then
     htp.nl;
     htp.p( '<CENTER>' );
     htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
     htp.p( '</CENTER>' );
   end if;
   htp.htmlclose;
   return;
 end if;

 glbx.main_title( surl, LNG2.PFM_TXT_053,glbx.backimg(surl,null,pfx.text_back),helpid=>'G05',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 foundrec := FALSE;
 imgld := 0;
 imgfl := 0;
 htp.p( '<CENTER>' );
 for c2rec in c2(acid) loop
   foundrec := TRUE;
   if (c2%ROWCOUNT = 1) or (ftime is null) then ftime := c2rec.time_start; end if;
   ltime := nvl(c2rec.time_start,ltime);
   htp.tablerowopen;
   if c2rec.succeeded = 'T' and c2rec.umo_id is not null then imgld := imgld + 1; end if;
   if c2rec.succeeded = 'F' then imgfl := imgfl + 1; end if;
 end loop;

 if foundrec
   then
    htp.nl;
    htp.p( LNG3.ADM_TXT_356 || ': ' || htf.bold(to_char(ltime, LNG.TSMASK )) );
    htp.nl;
    htp.p( LNG3.ADM_TXT_357 || ': ' || htf.bold(to_char(round((ltime - ftime)*86400,2))) );
    htp.nl;
    if imgld >= 1
     then
      htp.p( LNG3.ADM_TXT_358 || ': ' || htf.bold(to_char( round(((ltime - ftime)*86400)/imgld,2) )) );
      htp.nl;
    end if;
    htp.p( LNG3.ADM_TXT_359 || ': ' || htf.bold(imgld) );
    htp.nl;
    htp.p( LNG3.ADM_TXT_759 || ': ' || htf.bold(imgfl) );
    htp.nl;
 end if;

 open c1(acid);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   pfx := glbx.get_thm( DECS.DEFAULT_PHG_THEME );
   open c3(acid);
   fetch c3 into c1rec;
   close c3;
 end if;
 close c1;
 glbx.header_msg( LNG.GLB_TXT_017 || ':' || c1rec.username );
  htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || GLBX.TABLE_BACKGROUND );
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.PHG_TXT_048 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_750 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_751 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_752 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( LNG3.ADM_TXT_753 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    foundrec := FALSE;
    imgld := 0;
    imgfl := 0;
    for c2rec in c2(acid) loop
     foundrec := TRUE;
     if (c2%ROWCOUNT = 1) or (ftime is null) then ftime := c2rec.time_start; end if;
     ltime := nvl(c2rec.time_start,ltime);
     htp.tablerowopen;
      if c2rec.succeeded = 'T' and c2rec.umo_id is not null then imgld := imgld + 1; end if;
      if c2rec.succeeded = 'F' then imgfl := imgfl + 1; end if;
      htp.tabledata(nvl(to_char(c2rec.umo_id),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(nvl(to_char(c2rec.time_start,LNG.TSMASK),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(nvl(c2rec.filename,'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(c2rec.succeeded,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"');
      htp.tabledata(htf.bold(nvl(c2rec.result,'&nbsp;')),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
    end loop;
  htp.tableclose;

  htp.nl;
  if foundrec
   then
    htp.nl;
    htp.p( LNG3.ADM_TXT_356 || ': ' || htf.bold(to_char(ltime, LNG.TSMASK )) );
    htp.nl;
    htp.p( LNG3.ADM_TXT_357 || ': ' || htf.bold(to_char(round((ltime - ftime)*86400,2))) );
    htp.nl;
    if imgld >= 1
     then
      htp.p( LNG3.ADM_TXT_358 || ': ' || htf.bold(to_char( round(((ltime - ftime)*86400)/imgld,2) )) );
      htp.nl;
    end if;
    htp.p( LNG3.ADM_TXT_359 || ': ' || htf.bold(imgld) );
    htp.nl;
    htp.p( LNG3.ADM_TXT_759 || ': ' || htf.bold(imgfl) );
    htp.nl;
    htp.formopen( 'glbx.displog' );
     htp.formhidden( 'SURL', glbx.rndsurl(surl));
     htp.formhidden( 'ACID', acid );
     htp.formhidden( 'ACC', acc );
     htp.formhidden( 'ACTION', 'DELETE' );
     htp.formsubmit( null, LNG3.ADM_TXT_754 );
    htp.formclose;
   else
    glbx.header_msg( LNG3.ADM_TXT_757 );
  end if;
  htp.nl;
  htp.nl;
  if new_window = 'T'
   then
    htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
  end if;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'GLBX', 'DISPLOG', errmsg=>sqlerrm, extdet=>'ACID:' || acid);
end displog;

function get_dir( val in varchar2, lvl in varchar2 )
 return varchar2
as
 ctr1	integer;
 ctr2	integer;
begin
 ctr1 := 0;
 ctr2 := 0;
 for j in 1..length(val) loop
    if substr(val,(length(val)+1)-j,1) = DECS.UNIX_OR_NT
     then
      if ctr1 = 0
       then
        ctr1 := (length(val)+1)-j;
       else
        ctr2 := (length(val)+1)-j;
        exit;
      end if;
    end if;
  end loop;
  --htp.p( '1:' || ctr1 || ' 2:' || ctr2 || '-' || val ); htp.nl;
  if lvl = 'DIRECTORY' -- Extract the last directory name
  then
   return(substr(val,ctr2+1,(ctr1-ctr2)-1));
 elsif lvl = 'SUBDIRECTORY' -- Extract all the directory until the last name
  then
   return(substr(val,1,ctr2));
 end if;

exception when others then
 glbx.error_details( 'GLBX', 'GET_DIR', errmsg=>sqlerrm, extdet=>'VAL:' || val || ' LVL:' || lvl);
end get_dir;

function indnt( pscene integer )
  return integer
 is
  cursor cparent( pscene integer ) is select parent_scene from umo_scene where umo_scene_id = pscene;
  crec   cparent%ROWTYPE;
 begin
  if pscene is null then return( null ); end if;
  open cparent(pscene);
  fetch cparent into crec;
  close cparent;
  return( nvl(indnt( crec.parent_scene ),0) + 1 );
end indnt;

function extract_master_parameter( pname in varchar2 )
 return varchar2
as

 cursor c1(pname varchar2) is select parm_value from master_parameters where parm_name = pname;

 c1rec	c1%ROWTYPE;

begin
 if pname in ('ENABLE_IMAGE_PROG' ) then return( 'TRUE' ); end if;
 if pname in ('REPORTS_DIRECTORY','MAIL_OUTPUT_DIR','MAIL_TEMPLATE_DIR','IMAGE_DIR','HELP_DIR','BIN_DIR','ADVERTS_DIR','SOURCE_DIR','REPORTING_DIR')
  then
   open c1('PICTION_DIRECTORY');
   fetch c1 into c1rec;
   close c1;
   if pname = 'REPORTS_DIRECTORY' then return( c1rec.parm_value || DECS.UNIX_OR_NT || 'report_load' );
   elsif pname = 'MAIL_OUTPUT_DIR' then return( c1rec.parm_value || DECS.UNIX_OR_NT || 'mail_output' );
   elsif pname = 'MAIL_TEMPLATE_DIR' then return( c1rec.parm_value || DECS.UNIX_OR_NT || 'mail_template' );
   elsif pname = 'IMAGE_DIR' then return( c1rec.parm_value || DECS.UNIX_OR_NT || 'images' );
   elsif pname = 'HELP_DIR' then return( c1rec.parm_value || DECS.UNIX_OR_NT || 'help' );
   elsif pname = 'SOURCE_DIR' then return( c1rec.parm_value || DECS.UNIX_OR_NT || 'source' );
   elsif pname = 'ADVERTS_DIR' then return( c1rec.parm_value || DECS.UNIX_OR_NT || 'adverts' );
   elsif pname = 'BIN_DIR' then return( c1rec.parm_value || DECS.UNIX_OR_NT || 'bin' );
   elsif pname = 'REPORTING_DIR' then return( c1rec.parm_value || DECS.UNIX_OR_NT || 'reports' );
   end if;
 else
  open c1(pname);
  fetch c1 into c1rec;
  close c1;
  return( c1rec.parm_value );
 end if;

exception when others then
 glbx.error_details( 'GLBX', 'EXTRACT_MASTER_PARAMETER', errmsg=>sqlerrm, extdet=>'PNAME:' || pname);
end extract_master_parameter;

procedure display_warranty( surl in varchar2, wid in integer, phgid in integer )
as

 cursor c1(wid integer, phgid integer) is select warranty_html_page from warranty where warranty_id = wid and pid = phgid;

 c1rec		c1%ROWTYPE;
 l_terms        utl_file.file_type;
 p_body		varchar2(32767);

begin

   open c1(wid,phgid);
   fetch c1 into c1rec;
   if c1%NOTFOUND
    then
     close c1;
     htp.bold( LNG2.FNM_TXT_086 );
     return;
   end if;
   close c1;

   begin
    l_terms := utl_file.fopen( glbx.extract_master_parameter('MAIL_TEMPLATE_DIR'), c1rec.warranty_html_page, 'r' );
   exception
    when others
     then
      htp.bold( LNG2.FNM_TXT_086 );
      return;
   end;

   htp.bold( LNG2.FNM_TXT_087 );
   htp.nl;
   htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=1' );
   htp.tablerowopen;
   htp.p( '<TD>' );
   loop
     begin
      utl_file.get_line(l_terms,p_body);
      htp.p(p_body);
     exception
      when others
       then exit;
     end;
   end loop;
   utl_file.fclose( l_terms );

  htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tableclose;

exception
 when others then htp.p( LNG2.FNM_TXT_087 ); return;
end display_warranty;

function rndsurl( surl in varchar2 )
 return varchar2
as
begin
 return( substr(surl,1,22) || to_char(sysdate,'SSSSS') );
exception
 when others then
  glbx.error_details( 'GLBX', 'RNDSURL', errmsg=>sqlerrm, extdet=>'SURL:' || surl);
  return( SURL );
end rndsurl;

function truncsurl( surl in varchar2 )
 return varchar2
as
begin
 return( substr(surl,1,22) );
exception
 when others then
  glbx.error_details( 'GLBX', 'TRUNCSURL', errmsg=>sqlerrm, extdet=>'SURL:' || surl);
  return( SURL );
end truncsurl;

function man_discount( manid integer, phgid integer )
 return number
as

 cursor c1( manid integer, phgid integer ) is select discount from manufacturer_photographer_disc where manufacturer_id = manid and pid = phgid;

 c1rec	c1%ROWTYPE;
begin

 if manid is null or phgid is null
  then
   return( 0 );
 end if;
 open c1(manid,phgid);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   return( 0 );
 end if;
 close c1;
 return( nvl(c1rec.discount,0) );
exception
 when others then begin close c1; exception when others then null; end; return( 0 );
end man_discount;

function strip_special_characters( str in varchar2 )
 return varchar2
as
begin
 return( translate( str, '"&%+?','.....' ) );
exception
 when others then return( str );
end strip_special_characters;

procedure meta_lov( parm in varchar2, mandatory in varchar2, lov_list in varchar2, value in varchar2, multilist in varchar2 default null )
as

 ctr		integer;
 ctr_loc	integer;
 lastloc	integer;
 lov_value	varchar2(1000);

begin
  if multilist is null
   then
    htp.formselectopen( parm );
   else
    htp.formselectopen( 'P1', null, multilist, cattributes=>'MULTIPLE' );
  end if;
  if mandatory = 'F'
   then
    htp.formselectoption( NULL );
  end if;
  ctr := 0;
  lastloc := 0;
  loop
   ctr := ctr + 1;
   if ctr > 1000 then exit; end if; -- Inf Loop Protection
   ctr_loc := instr(lov_list,',',1,ctr);
   if ctr_loc = 0
    then
     lov_value := substr(lov_list,lastloc+1);
     if lov_value is not null
      then
       if lov_value = value
        then
         htp.formselectoption( lov_value, 'SELECTED' );
        else
         htp.formselectoption( lov_value );
       end if;
     end if;
     exit;
   end if;
   lov_value := substr(lov_list,lastloc+1,(ctr_loc-lastloc)-1);
   if lov_value is not null
    then
       if lov_value = value
        then
         htp.formselectoption( lov_value, 'SELECTED' );
        else
         htp.formselectoption( lov_value );
       end if;
   end if;
   lastloc := ctr_loc;
  end loop;
  htp.formselectclose;
exception
 when others then null;
end meta_lov;

procedure meta_sql( v_umo in integer, utype in varchar2, parm in varchar2, mandatory in varchar2, lov_list in varchar2, value in varchar2 )
as

   cursor c1(v_umo integer, scat varchar2, utype varchar2 ) is
    select value
    from umo_attribute ua, umo_attributes u
    where ua.umo_id = v_umo and
          (u.umo_type = utype or u.umo_type = 'ALL' ) and
          u.attribute_id = ua.attribute_id and
          u.sub_category = scat
    order by position_id;

   c1rec		c1%ROWTYPE;
   ctr			integer;
   loc			integer;
   cursor_name		integer;
   dummy 		integer;
   col_count		integer;
   desc_t		dbms_sql.desc_tab;
   common_nmb		number;
   common_vc2		varchar2(4000);
   common_dte		date;
   str			varchar2(4000);
   tmpval		varchar2(4000);
   tmpval2		varchar2(4000);
   sqlstmt		varchar2(32767);

begin
   htp.formselectopen( parm );
   if mandatory = 'F'
    then
     htp.formselectoption( NULL );
   end if;

   if lov_list is null
    then
     htp.formselectclose;
     return;
   end if;

   sqlstmt := lov_list;
   ctr := 1;
   loop
    loc := instr( sqlstmt,'<PICTION_PARAMETER=' );
    if nvl(loc,0) = 0 then exit; end if;
    str := substr(sqlstmt,loc+19,(instr(sqlstmt, '>', loc+19)-(loc+19)));
    open c1( v_umo,upper(str),utype);
    fetch c1 into c1rec;
    if c1%NOTFOUND
     then
      c1rec.value := NULL;
    end if;
    close c1;
    sqlstmt := replace(sqlstmt,'<PICTION_PARAMETER=' || str || '>',c1rec.value);
    ctr := ctr + 1;
    if ctr > 1000 then exit; end if; -- Inf Loop Protection
   end loop;

   cursor_name := dbms_sql.open_cursor;
   dbms_sql.parse( cursor_name, sqlstmt, dbms_sql.native );
   dbms_sql.describe_columns(cursor_name,col_count,desc_t);

   for j in 1..least(2,col_count) loop
    if desc_t(j).col_type in (1,96)
     then
      dbms_sql.define_column_char(cursor_name,j,common_vc2,desc_t(j).col_max_len);
    elsif desc_t(j).col_type = 2
     then
      dbms_sql.define_column(cursor_name,j,common_nmb);
    elsif desc_t(j).col_type = 12
     then
      dbms_sql.define_column(cursor_name,j,common_dte);
    end if;
   end loop;
   dummy := dbms_sql.execute( cursor_name );

   loop
     dummy := dbms_sql.fetch_rows(cursor_name);
     if dummy = 0 then exit; end if;
     tmpval := NULL;
     tmpval2 := NULL;
     for j in 1..least(2,col_count) loop
      common_vc2 := NULL;
      common_nmb := NULL;
      common_dte := NULL;
      if desc_t(j).col_type in (1,96)
       then
        dbms_sql.column_value_char(cursor_name,j,common_vc2);
        if j = 1 then tmpval := rtrim( common_vc2 ); else tmpval2 := rtrim( common_vc2 ); end if;
       elsif desc_t(j).col_type = 2
        then
         dbms_sql.column_value(cursor_name,j,common_nmb);
         if j = 1 then tmpval := to_char( common_nmb ); else tmpval2 := to_char( common_nmb ); end if;
       elsif desc_t(j).col_type = 12
        then
         dbms_sql.column_value(cursor_name,j,common_dte);
         if j = 1 then tmpval := to_char( common_dte, LNG.TSMASK ); else tmpval2 := to_char( common_dte, LNG.TSMASK ); end if;
      end if;
     end loop;
     if col_count = 1 then tmpval2 := tmpval; end if;
     if tmpval = value
      then
       htp.formselectoption( tmpval2, 'SELECTED', cattributes=>'VALUE="' || tmpval || '"' );
      else
       htp.formselectoption( tmpval2, cattributes=>'VALUE="' || tmpval || '"' );
     end if;
   end loop;

   dbms_sql.close_cursor( cursor_name );

   htp.formselectclose;
exception
 when others then return;
end meta_sql;

function meta_sql_query( v_umo in integer, utype in varchar2, lov_list in varchar2 )
 return varchar2
as

   cursor c1(v_umo integer, scat varchar2, utype varchar2 ) is
    select value
    from umo_attribute ua, umo_attributes u
    where ua.umo_id = v_umo and
          (u.umo_type = utype or u.umo_type = 'ALL' ) and
          u.attribute_id = ua.attribute_id and
          u.sub_category = scat
    order by position_id;

   c1rec		c1%ROWTYPE;
   cursor_name		integer;
   dummy 		integer;
   col_count		integer;
   ctr			integer;
   loc			integer;
   desc_t		dbms_sql.desc_tab;
   common_nmb		number;
   common_vc2		varchar2(4000);
   common_dte		date;
   tmpval		varchar2(4000);
   str			varchar2(4000);
   sqlstmt		varchar2(32767);

begin
   if lov_list is null then return( NULL ); end if;
   sqlstmt := lov_list;
   ctr := 1;
   loop
    loc := instr( sqlstmt,'<PICTION_PARAMETER=' );
    if nvl(loc,0) = 0 then exit; end if;
    str := substr(sqlstmt,loc+19,(instr(sqlstmt, '>', loc+19)-(loc+19)));
    open c1( v_umo,upper(str),utype);
    fetch c1 into c1rec;
    if c1%NOTFOUND
     then
      c1rec.value := NULL;
    end if;
    close c1;
    sqlstmt := replace(sqlstmt,'<PICTION_PARAMETER=' || str || '>',c1rec.value);
    ctr := ctr + 1;
    if ctr > 1000 then exit; end if; -- Inf Loop Protection
   end loop;

   tmpval := NULL;
   cursor_name := dbms_sql.open_cursor;
   dbms_sql.parse( cursor_name, sqlstmt, dbms_sql.native );
   dbms_sql.describe_columns(cursor_name,col_count,desc_t);

   for j in 1..least(1,col_count) loop
    if desc_t(j).col_type in (1,96)
     then
      dbms_sql.define_column_char(cursor_name,j,common_vc2,desc_t(j).col_max_len);
    elsif desc_t(j).col_type = 2
     then
      dbms_sql.define_column(cursor_name,j,common_nmb);
    elsif desc_t(j).col_type = 12
     then
      dbms_sql.define_column(cursor_name,j,common_dte);
    end if;
   end loop;
   dummy := dbms_sql.execute( cursor_name );

   dummy := dbms_sql.fetch_rows(cursor_name);
   tmpval := NULL;
   for j in 1..least(1,col_count) loop
      common_vc2 := NULL;
      common_nmb := NULL;
      common_dte := NULL;
      if desc_t(j).col_type in (1,96)
       then
        dbms_sql.column_value_char(cursor_name,j,common_vc2);
        tmpval := rtrim( common_vc2 );
       elsif desc_t(j).col_type = 2
        then
         dbms_sql.column_value(cursor_name,j,common_nmb);
         tmpval := to_char( common_nmb );
       elsif desc_t(j).col_type = 12
        then
         dbms_sql.column_value(cursor_name,j,common_dte);
         tmpval := to_char( common_dte, LNG.TSMASK );
      end if;
   end loop;

   dbms_sql.close_cursor( cursor_name );

   return( tmpval );

exception
 when others then return(null);
end meta_sql_query;

procedure meta_sql_query_update( v_umo in integer, urec in umo_attributes%ROWTYPE, utype in varchar2, upd_val in varchar2 )
as

   cursor c1(v_umo integer, scat varchar2, utype varchar2 ) is
    select value
    from umo_attribute ua, umo_attributes u
    where ua.umo_id = v_umo and
          u.umo_type = utype and
          u.attribute_id = ua.attribute_id and
          u.sub_category = scat
    order by position_id;

   c1rec		c1%ROWTYPE;
   cursor_name		integer;
   dummy 		integer;
   col_count		integer;
   ctr			integer;
   loc			integer;
   desc_t		dbms_sql.desc_tab;
   common_nmb		number;
   common_vc2		varchar2(4000);
   common_dte		date;
   errmsg		varchar2(1000);
   tmpval		varchar2(4000);
   str			varchar2(4000);
   sqlstmt		varchar2(32767);
   sqlstmt_ins		varchar2(32767);

begin

   sqlstmt := urec.sql_update_mask;
   ctr := 1;
   loop
    loc := instr( sqlstmt,'<PICTION_PARAMETER=', 1, 1 );
    if loc = 0 then exit; end if;
    str := substr(sqlstmt,loc+19,(instr(sqlstmt, '>', loc+19)-(loc+19)));
    open c1( v_umo,upper(str),utype);
    fetch c1 into c1rec;
    if c1%NOTFOUND
     then
      c1rec.value := NULL;
    end if;
    close c1;
    sqlstmt := replace(sqlstmt,'<PICTION_PARAMETER=' || str || '>',c1rec.value);
    ctr := ctr + 1;
    if ctr > 1000 then exit; end if; -- Inf Loop Protection
   end loop;
   execute immediate sqlstmt using upd_val;

   if SQL%ROWCOUNT = 0
    then
     -- Perform an Insert then update
     sqlstmt_ins := urec.sql_insert_mask;
     ctr := 1;
     loop
      loc := instr( sqlstmt_ins,'<PICTION_PARAMETER=', 1, ctr );
      if loc = 0 then exit; end if;
      str := substr(sqlstmt_ins,loc+19,(instr(sqlstmt_ins, '>', loc+19)-(loc+19)));
      open c1( v_umo,upper(str),utype);
      fetch c1 into c1rec;
      if c1%NOTFOUND
       then
        c1rec.value := NULL;
      end if;
      close c1;
      sqlstmt_ins := replace(sqlstmt_ins,'<PICTION_PARAMETER=' || str || '>',c1rec.value);
      ctr := ctr + 1;
      if ctr > 1000 then exit; end if; -- Inf Loop Protection
     end loop;
     execute immediate sqlstmt_ins;
     execute immediate sqlstmt using upd_val;
   end if;

exception
 when others
  then
   errmsg := sqlerrm;
   insert into audit_meta_remote_update ( umo_id, date_created, attribute_id, value, sql_error )
    values ( v_umo, sysdate, urec.attribute_id, upd_val, errmsg );
   commit;
   return;
end meta_sql_query_update;

function page_break(  val in varchar2 default null ) return varchar2
as
begin
 return( '<p STYLE="page-break-after: auto">' || val || '</p>' );
end page_break;

procedure relogin( surl in varchar2, acid in integer )
as

 cursor c1(sess_id integer) is select * from login_session where sessid = sess_id;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 id		integer;
 new_surl	varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GLBX.RELOGIN' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c1(owner_id);
 fetch c1 into c1rec;
 close c1;

 -- Disconnect Old Session
 update login_session
  set
   is_connected = 'F',
   date_updated = sysdate,
   call_ctr = nvl(call_ctr,1) + 1
 where sessid = owner_id;

 id := glbx.get_random_sessionid;
 new_surl := rpad(to_char(id),12,'Z') || glbx.randstring;
 insert into login_session(screen_type, login_type, sessid, aid, date_created, date_updated,call_ctr, guest_email, browser, ip_address, securl, unsolicited_email, country, previous_sessid, calling_sessid)
        values (c1rec.screen_type,c1rec.login_type, id, c1rec.aid, sysdate, sysdate, 1, c1rec.guest_email, substr(owa_util.get_cgi_env( 'HTTP_USER_AGENT'),1,100), c1rec.ip_address, new_surl, c1rec.unsolicited_email, c1rec.country, owner_id, to_number(replace(substr(surl,1,12),'Z','')) );

 -- Merge the Lightbox from the Old Session
 -- Remember if they are logging in, then old session lightbox results might be merged in from the login routine

 if c1rec.login_type in ('PHOTOGRAPHER','OWNER','PROFILE')
  then
   update lightbox
    set    sessid = id
    where  sessid = owner_id;

   -- Change the Shopping Basket (commented out until one cna think of a better solution
   --update purchase_order
   -- set   sessid = id
   -- where sessid = owner_id;

   -- Remove duplicate entries
   delete from lightbox lb
   where lb.rowid > (select min(lbx.rowid)
                     from lightbox lbx
                     where lbx.umo_id = lb.umo_id
                      and  lbx.sessid = lb.sessid ) and
          sessid = id;
 end if;

 commit;

 if ltype = 'PHOTOGRAPHER'
  then
   phg.screen_sze(new_surl);
  else
   cst.screen_sze(new_surl);
 end if;

exception when others then
 glbx.error_details( 'GLBX', 'RELOGIN', errmsg=>sqlerrm);
end relogin;

procedure relogin( surl in varchar2, un in varchar2, pw in varchar2, sts out varchar2, nsurl out varchar2, use_existing_surl in boolean default TRUE )
as

 cursor c1(sess_id integer) is select * from login_session where sessid = sess_id;
 c1rec		c1%ROWTYPE;
 session_id	integer;
 xstype		integer;
 ltype		varchar2(100);
 xltype		varchar2(100);
 stype		integer;
 owner_id	integer;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GLBX.RELOGIN' );
 if sts is not null
  then
   return;
 end if;

 open c1(owner_id);
 fetch c1 into c1rec;
 close c1;

 -- Validate the new connection
 if use_existing_surl
  then
   logon_user( upper(un), upper(pw), sts, session_id, xstype, c1rec.guest_email, 'x', 'F', null, nsurl, c1rec.country, existing_sessid_is=>owner_id );
   session_id := owner_id;
   nsurl := surl;
  else
   logon_user( upper(un), upper(pw), sts, session_id, xstype, c1rec.guest_email, 'x', 'F', null, nsurl, c1rec.country );
 end if;
 if sts not in ('PHOTOGRAPHER','OWNER','CUSTOMER','PROFILE','PROFILEG') then return; end if;
 xltype := sts;
 sts := NULL;

 transfer_details( owner_id, session_id, nsurl, xltype, TRUE, use_existing_surl );

exception when others then
 sts := sqlerrm;
 glbx.error_details( 'GLBX', 'RELOGIN', errmsg=>sqlerrm, extdet=>'UN:' || un || ' PW:' || pw);
end relogin;

procedure reset_cookie( new_surl in varchar2, use_javascript in boolean default TRUE )
as
begin
 if glbx.extract_master_parameter('COOKIE_ENABLED') = 'TRUE'
   then
    if use_javascript
     then
      htp.p('<SCRIPT LANGUAGE="JavaScript"><!-- document.cookie = "PICTION_COOKIE=' || glbx.truncsurl(new_surl) || ';"; // --> </SCRIPT>');
     else
      owa_util.mime_header('text/html', FALSE);
      owa_cookie.send(nvl(glbx.extract_master_parameter('COOKIE_NAME'),'PICTION_COOKIE'), glbx.truncsurl(new_surl));
      owa_util.http_header_close;
    end if;
 end if;
end reset_cookie;

procedure transfer_details( old_sessid in integer, new_sessid in integer, new_surl in varchar2, ltype in varchar2, disconnect_session in boolean default TRUE, use_existing_surl in boolean )
as

 cursor c1(sess_id integer) is select * from login_session where sessid = sess_id;
 cursor c3(vprofid integer) is select aid from customer_profile where profile_id = vprofid;
 cursor c4(ltype varchar2, acid integer) is select * from customer_contact where login_type = ltype and aid = acid;

 c1rec		c1%ROWTYPE;
 c1nrec		c1%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 profid		integer;
 void		integer;
 b2c_value	char(1);
 tp		integer;

begin

 open c1(new_sessid);
 fetch c1 into c1nrec;
 close c1;

 -- Pull in old details
 if not use_existing_surl
  then
   open c1(old_sessid);
   fetch c1 into c1rec;
   close c1;

   -- Disconnect Old Session
   if disconnect_session
    then
     update login_session
      set
       is_connected = 'F',
       date_updated = sysdate,
       call_ctr = nvl(call_ctr,1) + 1
     where sessid = old_sessid;
   end if;

   -- Set the New Screen Type to be the old one as it cannot be recalculated
   update login_session
    set
     screen_type = c1rec.screen_type
   where
     sessid = new_sessid;

   -- Merge the Lightbox from the Old Session
   -- Remember if they are logging in, then old session lightbox results might be merged in from the login routine
   update lightbox
    set    sessid = new_sessid
    where  sessid = old_sessid;
 end if;

 -- Change the Shopping Basket
 -- This step is fine, as the customer is already logged in, and we are just moving everything over
 if ltype in ('OWNER','PROFILE')
  then
   open c4(ltype, c1nrec.aid);
   fetch c4 into c4rec;
   close c4;
   if not use_existing_surl
    then
     update purchase_order
      set   sessid = new_sessid
     where sessid = old_sessid;
   end if;
   update purchase_order
    set   sendto_name = c4rec.sendto_name,
  	  sendto_firstname = c4rec.sendto_firstname,
  	  sendto_lastname = c4rec.sendto_lastname,
  	  sendto_street = c4rec.sendto_street,
	  sendto_suburb = c4rec.sendto_suburb,
	  sendto_city = c4rec.sendto_city,
	  sendto_state = c4rec.sendto_state,
	  sendto_branch = c4rec.sendto_branch,
	  sendto_department = c4rec.sendto_department,
	  sendto_postcode = c4rec.sendto_postcode,
	  sendto_country = c4rec.sendto_country,
          contact_phone = c4rec.contact_phone,
	  contact_email = c4rec.contact_email,
	  billing_name = c4rec.billing_name,
	  billing_firstname = c4rec.billing_firstname,
	  billing_lastname = c4rec.billing_lastname,
	  billing_gpo_box = c4rec.billing_gpo_box,
	  billing_street = c4rec.billing_street,
	  billing_suburb = c4rec.billing_suburb,
	  billing_city = c4rec.billing_city,
	  billing_postcode = c4rec.billing_postcode,
	  billing_country = c4rec.billing_country,
	  billing_email = c4rec.billing_email,
	  billing_fax = c4rec.billing_fax,
	  billing_phone = c4rec.billing_phone,
	  billing_branch = c4rec.billing_branch,
	  billing_department = c4rec.billing_department,
	  billing_state = c4rec.billing_state
  where sessid = new_sessid;
  tp := sql%rowcount;

 else

  update purchase_order
   set   sessid = new_sessid
   where sessid = old_sessid;

 end if;

 -- Update Order Style in Purchase Order Table to reflect a possible new Order Style
 if ltype in ('PROFILE','PROFILEG')
  then
   open c3(c1nrec.aid);
   fetch c3 into c3rec;
   close c3;
   profid := c1nrec.aid;
  else
   c3rec.aid := c1nrec.aid;
   profid := NULL;
 end if;

 void := get_order_style( c3rec.aid, profid, ltype, b2c_value );
 update purchase_order
  set
   oid = nvl(void,oid)
 where
  sessid = new_sessid;

 -- Remove duplicate entries
 delete from lightbox lb
 where lb.rowid > (select min(lbx.rowid)
                   from lightbox lbx
                   where lbx.umo_id = lb.umo_id
                    and  lbx.sessid = lb.sessid ) and
        sessid = new_sessid;

 commit;

exception when others then
 glbx.error_details( 'GLBX', 'TRANSFER_DETAILS', errmsg=>sqlerrm);
end transfer_details;

procedure image_matte( pfx in THEME%ROWTYPE, wd in integer, hg in integer, trg in varchar2, trgdisp in varchar2, ctarget in varchar2 )
as

begin

  htp.tableopen( cattributes=>'style="text-align: center; padding=0; ' ||
                 'border-top: ' || to_char(nvl(pfx.tnail_border,0)) || ' #' || pfx.tnail_border_colour || ' '|| pfx.matte_border_style || ';' ||
                 'border-left: ' || to_char(nvl(pfx.tnail_border,0)) || ' #' || pfx.tnail_border_colour || ' '|| pfx.matte_border_style || ';' ||
                 'border-right: ' || to_char(nvl(pfx.tnail_border,0)) || ' #' || pfx.tnail_border_colour_l || ' '|| pfx.matte_border_style || ';' ||
                 'border-bottom: ' || to_char(nvl(pfx.tnail_border,0)) || ' #' || pfx.tnail_border_colour_l || ' '|| pfx.matte_border_style || ';' ||
                 '" ' ||
                 'align="CENTER" cellpadding=0 cellspacing=0 bordercolordark="#' || pfx.tnail_border_colour || '"  bordercolorlight="#' || pfx.tnail_border_colour_l || '" border=' ||
                 to_char(nvl(pfx.tnail_border,0)) );
   htp.tablerowopen;
    htp.p('<TD style="background-position: center; background-color: #' || pfx.tnail_matte_colour || '; text-align: center; width:' || to_char(wd + nvl(pfx.tnail_width,0)) || 'px; height:' || to_char(hg + nvl(pfx.tnail_width,0))  || 'px;" bgcolor="#' || pfx.tnail_matte_colour || '" align="CENTER" valign="MIDDLE" width=' ||
          to_char(wd + nvl(pfx.tnail_width,0)) || ' height=' || to_char(hg + nvl(pfx.tnail_width,0)) || '>');
    if trg is null
     then
      htp.p( trgdisp );
     else
      if ctarget is null
       then
        htp.anchor( trg, trgdisp );
       else
        htp.anchor2( trg, trgdisp, ctarget=>ctarget);
      end if;
    end if;
    htp.p('</TD>');
   htp.tablerowclose;
  htp.tableclose;

exception when others then
 glbx.error_details( 'GLBX', 'IMAGE_MATTE', errmsg=>sqlerrm);
end image_matte;

procedure image_nmb_index( surl in varchar2, cusrec in customer_account%ROWTYPE, pfx in THEME%ROWTYPE, ltype in varchar2, acid in integer, gap in integer default 10 )
as

 cursor c1(acid integer) is select min(um.extras.orderby_nmb) min_nmb, max(um.extras.orderby_nmb) max_nmb from umo um where aid = acid;

 c1rec	c1%ROWTYPE;
 lrange	varchar2(100);
 drange	varchar2(100);
 ctarg	varchar2(100);
 j	integer;

begin

open c1( cusrec.aid );
fetch c1 into c1rec;
close c1;

if (pfx.nested_scene_style = LNG3.ADM_TXT_576) or (pfx.nested_scene_style = LNG3.ADM_TXT_575 and ltype = 'PHOTOGRAPHER') -- Lov
 then
   if ltype = 'PHOTOGRAPHER'
    then
     htp.formopen( 'cst.disp_event',ctarget=>'PHG_RIGHT');
     htp.formhidden( 'SURL', glbx.rndsurl(surl));
     htp.formhidden( 'ACID', acid );
   else
     if pfx.keep_lhf = 'N'
      then
       htp.formopen( 'cst.disp_event',ctarget=>'_top');
      elsif pfx.keep_lhf = '2'
       then
        htp.formopen( 'cst.disp_event',ctarget=>'CUS_BOTTOM');
      else
        htp.formopen( 'cst.disp_event',ctarget=>'CUS_RIGHT');
     end if;
     htp.formhidden( 'SURL', glbx.rndsurl(surl));
   end if;
   if pfx.scene_position = 'L' and pfx.keep_lhf in ('L','R')
    then
     htp.formselectopen( 'LEFT_API_PARM', cattributes=>'onChange="parent.frames[1].location.href = this.options[this.selectedIndex].value;"' );
   elsif pfx.scene_position = 'T' and pfx.keep_lhf in ('L','R') and ltype <> 'PHOTOGRAPHER'
    then
     htp.formselectopen( 'LEFT_API_PARM', cattributes=>'onChange="parent.frames[1].frames[1].location.href = this.options[this.selectedIndex].value;"' );
    elsif pfx.scene_position = 'T' and pfx.keep_lhf = '2'
     then
      htp.formselectopen( 'LEFT_API_PARM', cattributes=>'onChange="parent.frames[1].location.href = this.options[this.selectedIndex].value;"' );
    elsif pfx.scene_position = 'T' and pfx.keep_lhf = 'N' and ltype = 'PHOTOGRAPHER'
     then
      htp.formselectopen( 'LEFT_API_PARM', cattributes=>'onChange="parent.frames[1].location.href = this.options[this.selectedIndex].value;"' );
    elsif pfx.scene_position = 'T' and pfx.keep_lhf = 'N'
     then
      htp.formselectopen( 'LEFT_API_PARM', cattributes=>'onChange="parent.window.location.href = this.options[this.selectedIndex].value;"' );
    else
     htp.formselectopen( 'LEFT_API_PARM', cattributes=>'onChange="parent.frames[1].location.href = this.options[this.selectedIndex].value;"' );
   end if;
   htp.formselectoption( LNG4.AHC_TXT_593, cattributes=>'VALUE="glbx.acct_home?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '"' );

   for k in 1..trunc(c1rec.max_nmb / gap) loop
    if j+gap < c1rec.max_nmb
     then
      lrange := '[' || j || '-' || to_char(j+gap) || ']';
      drange := to_char(j) || ' - ' || to_char(j+gap);
     else
      lrange := '[' || j || '-' || c1rec.max_nmb || ']';
      drange := to_char(j) || ' - ' || to_char(c1rec.max_nmb);
    end if;
    htp.formselectoption( drange, cattributes=>'VALUE="' || 'cst.disp_event?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || lrange  || '&start_from=1"' || '&acid=' || acid );
    j := j + gap + 1;
   end loop;
   lrange := '[' || j || '-' || to_char(j+gap) || ']';
   drange := to_char(j) || ' - ' || to_char(j+gap);
   htp.formselectoption( drange, cattributes=>'VALUE="' || 'cst.disp_event?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || lrange  || '&start_from=1"' || '&acid=' || acid );
   htp.formselectclose;
   htp.formclose;

 else

   if ltype = 'PHOTOGRAPHER'
    then
      ctarg := 'PHG_RIGHT';
   elsif pfx.keep_lhf = 'N'
    then
      ctarg := '_top';
   elsif pfx.keep_lhf = '2'
      then
       ctarg := 'CUS_BOTTOM';
   else
       ctarg := 'CUS_RIGHT';
   end if;

   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=0 border=' || nvl(pfx.border_around_scene,'0') );
    j := c1rec.min_nmb;
    for k in 1..trunc(c1rec.max_nmb / gap) loop
    if j+gap < c1rec.max_nmb
     then
      lrange := '[' || j || '-' || to_char(j+gap) || ']';
      drange := to_char(j) || ' - ' || to_char(j+gap);
     else
      lrange := '[' || j || '-' || c1rec.max_nmb || ']';
      drange := to_char(j) || ' - ' || to_char(c1rec.max_nmb);
    end if;
    htp.tablerowopen;
     htp.tabledata( htf.anchor2( 'cst.disp_event?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || lrange  || '&start_from=1' || '&acid=' || acid,drange,ctarget=>ctarg) );
    htp.tablerowclose;
    j := j + gap + 1;
    end loop;
    lrange := '[' || j || '-' || c1rec.max_nmb || ']';
    drange := to_char(j) || ' - ' || to_char(c1rec.max_nmb);
    htp.tablerowopen;
     htp.tabledata( htf.anchor2( 'cst.disp_event?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || lrange  || '&start_from=1' || '&acid=' || acid,drange,ctarget=>ctarg) );
    htp.tablerowclose;
   htp.tableclose;

 end if;

 htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0' );
 htp.tablerowopen;
 htp.p( '<TD>' );
 htp.formopen( 'cst.disp_event', ctarget=>ctarg );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'START_FROM', '1' );
  htp.formhidden( 'ACID', acid );
  htp.formsubmit( null, LNG3.ADM_TXT_883 || ' #' );
 htp.p( '</TD>' );
 htp.p( '<TD>' );
  htp.formtext( 'LEFT_API_PARM', 3, 10 );
 htp.p( '</TD>' );
 htp.formclose;
 htp.tableclose;

exception when others then
 glbx.error_details( 'GLBX', 'IMAGE_NMB_INDEX', errmsg=>sqlerrm, extdet=>'ACID:' || acid || ' GAP:' || gap );
end image_nmb_index;

procedure transfer_acct_details( ltype in varchar2, acid in integer, profid in integer, sess_id in integer )
as

 cursor c1(ltype varchar2, acid integer) is
  select sessid
  from login_session
  where login_type = ltype and
        aid = acid
  order by date_created desc;

 c1rec	c1%ROWTYPE;

begin

 if ltype = 'OWNER'
  then
   open c1(ltype,acid);
   fetch c1 into c1rec;
   close c1;

 elsif ltype = 'PROFILE'
  then
   open c1(ltype,profid);
   fetch c1 into c1rec;
   close c1;

 else
  return;
 end if;

 if c1rec.sessid is null then return; end if;
 commit;

 -- Rename the Lightbox
 update lightbox
  set    sessid = sess_id
  where  sessid = c1rec.sessid;

 -- Remove duplicate entries
 delete from lightbox lb
 where lb.rowid > (select min(lbx.rowid)
                   from lightbox lbx
                   where lbx.umo_id = lb.umo_id
                    and  lbx.sessid = lb.sessid ) and
        sessid = sess_id;

exception when others then
 glbx.error_details( 'GLBX', 'TRANSFER_ACCT_DETAILS', errmsg=>sqlerrm, extdet=>'LTYPE:' || ltype || ' ACID:' || acid || ' PROFID:' || profid);
end transfer_acct_details;

procedure transfer_session_Images( ltype in varchar2, acid in integer, profid in integer, sess_id in integer )
as

 cursor c1(ltype varchar2, acid integer) is
  select sessid
  from login_session
  where login_type = ltype and
        aid = acid
  order by date_created desc;

 c1rec	c1%ROWTYPE;

begin

 if ltype = 'OWNER'
  then
   open c1(ltype,acid);
 elsif ltype = 'PROFILE'
  then
   open c1(ltype,profid);
 else
  return;
 end if;
 fetch c1 into c1rec;
 close c1;

 if c1rec.sessid is null then return; end if;
 update umo
  set
   sessid = sess_id
  where
   sessid = c1rec.sessid;

exception when others then
 glbx.error_details( 'GLBX', 'TRANSFER_SESSION_IMAGES', errmsg=>sqlerrm, extdet=>'LTYPE:' || ltype || ' ACID:' || acid || ' PROFID:' || profid);
end transfer_session_images;

procedure extended_search_api( surl in varchar2, ltype in varchar2, result_list in UMP.SEARCH_RESULT_PHG, search_total in integer,
                               display_detail in char default NULL, title in varchar2 default null, help_file_code in varchar2 default null,
                               left_api in varchar2 default null, left_api_parm in varchar2 default null, footer_api in varchar2 default null,
                               current_page_number in varchar2, no_results_message in varchar2 default null, acid in integer default null,
                               msg in varchar2 default null, extra_term in varchar2 default null)
as
begin

 if ltype in ('CUSTOMER','OWNER','PROFILE','PROFILEG','VIRTUAL')
  then
      cst.disp_by_scene( surl=>surl, result_list=>result_list, search_total=>search_total,
                         left_api=>left_api, left_api_parm=>left_api_parm,
                         display_detail=>display_detail, title=>title, help_file_code=>help_file_code, footer_api=>footer_api,
                         current_page_number=>current_page_number,no_results_message=>no_results_message,msg=>msg,extra_term=>extra_term);

  elsif ltype = 'PHOTOGRAPHER'
   then
      cst.disp_by_scene( surl=>surl, result_list=>result_list, search_total=>search_total,
                         left_api=>left_api, left_api_parm=>left_api_parm,
                         display_detail=>display_detail, title=>title, help_file_code=>help_file_code, footer_api=>footer_api,
                         current_page_number=>current_page_number,no_results_message=>no_results_message,acid=>acid,msg=>msg,extra_term=>extra_term);
 end if;

exception when others then
 glbx.error_details( 'GLBX', 'EXTENDED_SEARCH_API', errmsg=>sqlerrm);
end extended_search_api;

procedure create_profile( surl in varchar2, profile_name in varchar2, profile_un in varchar2, profile_pw in varchar2, profile_pwg in varchar2 default null,
                          bftr in varchar2, laf in varchar2, transfer_lbox in boolean default FALSE, acid in integer default null, disconnect_session in boolean default TRUE, return_surl out varchar2, result out varchar2, use_existing_surl in boolean default TRUE )
as

 cursor c3( bftr varchar2 ) is select count('x') tot from theme_types where theme_type = bftr;

 cursor c4( thm varchar2 ) is select count('x') tot from theme where theme_name = thm;

 cursor c5( sess_id integer) is select * from login_session where sessid = sess_id;

 cursor c6(ttype varchar2) is select * from theme_types tt where theme_type = ttype;

 cursor c7(acid integer) is select * from customer_account where aid = acid;

 c1rec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 newaid		integer;
 id		integer;
 newexp		date;
 newsurl	varchar2(100);
 sts		varchar2(100);
 new_password	varchar2(100);
 new_passwordg	varchar2(100);
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GLBX.CREATE_PROFILE', reset=>FALSE );
 if sts is not null
  then
   result := sts;
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 if c1rec.pid is null and acid is not null
  then
   open c7(acid);
   fetch c7 into c1rec;
   close c7;
 end if;
 open c6(c1rec.theme_type);
 fetch c6 into theme_rec;
 close c6;

 -- To Create a profile Business Feature #80 must be enabled
 if substr(theme_rec.theme_data,80,1) = 'F'
  then
   result := LNG4.AHC_TXT_488;
   return;
 end if;

 -- Check to make sure the the username is unique
 if userexists(profile_un)
  then
   result := LNG4.AHC_TXT_487 || ':' || upper(trim(profile_un));
   return;
 end if;

 -- Check to make sure the Business Feature and Look and Feel Exist
 open c3(bftr);
 fetch c3 into c3rec;
 close c3;
 if c3rec.tot = 0
  then
   result := LNG4.AHC_TXT_486 || ':' || bftr;
   return;
 end if;

 open c4(laf);
 fetch c4 into c4rec;
 close c4;
 if c4rec.tot = 0
  then
   result := LNG4.AHC_TXT_485  || ':' || laf;
   return;
 end if;

 -- Password cannot be NULL
 if profile_pw is null
  then
   result := LNG4.AHC_TXT_484;
   return;
 end if;

 -- Create the profile
 select s_customer_profile.nextval into newaid from dual;

 new_password := encrypt( upper( profile_pw ));
 new_passwordg := encrypt( upper( profile_pwg ));

 insert into customer_profile(
   profile_id,pid,aid,account_name,date_held,username,password,password_owner,
   scene_name,theme_name,theme_type,date_created,date_expires,public_account) values
  (newaid,c1rec.pid,c1rec.aid,c1rec.account_name,c1rec.date_held,upper(trim(profile_un)),new_password,new_passwordg,
   c1rec.scene_name,laf,bftr,sysdate,c1rec.date_expires,c1rec.public_account);
 insert into audit_profile_password(profile_id,date_changed,pw,pwg) values
                                   (newaid,sysdate,upper( profile_pwg ),upper( profile_pw ));

 -- Create a login session for the account
 -- It is up to the calling session whether they reconnect in as this profile account
 if use_existing_surl
  then
   id := owner_id;
   newsurl := surl;
   update login_session
    set
     aid = newaid,
     login_type = 'PROFILE',
     date_updated = sysdate,
     call_ctr = call_ctr + 1
   where
    sessid = owner_id;
  else
   id := glbx.get_random_sessionid;
   newsurl := rpad(to_char(id),12,'Z') || glbx.randstring;
   open c5( owner_id );
   fetch c5 into c5rec;
   close c5;
   insert into login_session(screen_type,login_type,sessid,aid,date_created,date_updated,call_ctr,guest_email, browser, ip_address, securl, unsolicited_email, country)
    values (stype, 'PROFILE', id, newaid, sysdate, sysdate, 1, c5rec.guest_email, c5rec.browser, c5rec.ip_address, newsurl, c5rec.unsolicited_email, c5rec.country );
 end if;

 transfer_details( owner_id, id, newsurl, 'PROFILE', disconnect_session, use_existing_surl );

 return_surl := newsurl;
 result := NULL;

exception
 when others then
  result := sqlerrm;
end create_profile;

procedure modify_profile( surl in varchar2, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY, result out varchar2, update_purchase_order_surl in varchar2 default null )
as

 cursor c2(profid integer) is select * from customer_contact where aid = profid and login_type = 'PROFILE';
 cursor c3(vsurl varchar2) is select poid from purchase_order where sessid in (select sessid from login_session where securl = vsurl);
 cursor c4(vsurl varchar2) is select * from login_session where securl = vsurl;
 cursor c6(ttype varchar2) is select * from theme_types tt where theme_type = ttype;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c6rec		c6%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 nmb		integer;
 vpoid		integer;
 void		integer;
 sts		varchar2(100);
 theme_rec	theme_types%ROWTYPE;

 function find_parm( defval in varchar2, fnd in varchar2, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY )
  return varchar2
 is
 begin
  for j in parm1.first..parm1.last loop
   if parm2(j) = fnd then return( parm1(j) ); end if;
  end loop;
  return( defval );
 end find_parm;

begin
 -- Assumes you are logged on as the Profile and are modifying it.
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GLBX.MODIFY_PROFILE', reset=>FALSE );
 if sts is not null
  then
   -- Added to get around a cookie problem at AWM
   open c4(glbx.truncsurl(surl));
   fetch c4 into c4rec;
   if c4%NOTFOUND
    then
     close c4;
     result := sts;
     return;
   end if;
   close c4;
   stype := c4rec.screen_type;
   ltype := c4rec.login_type;
   owner_id := c4rec.sessid;
   sts := NULL;
 end if;

 if ltype <> 'PROFILE'
  then
   result := 'Only a Profile can modify its details';
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, null, profid );
 open c6(c1rec.theme_type);
 fetch c6 into theme_rec;
 close c6;

 -- To Modify a profile Business Feature #80 must be enabled
 if substr(theme_rec.theme_data,80,1) = 'F'
  then
   result := 'Modification of Profiles is not allowed';
   return;
 end if;

 open c2(profid);
 fetch c2 into c2rec;
 if c2%NOTFOUND
  then
   close c2;
   -- Profile Account does not exist. Create it.
   select s_customer_contact.nextval into c2rec.contact_id from dual;
   insert into customer_contact(contact_id,aid,login_type) values (c2rec.contact_id,profid,ltype);
  else
   close c2;
 end if;

 c1rec.public_account := find_parm(c1rec.public_account,'PUBLIC_ACCOUNT',parm1,parm2);
 c1rec.account_name := find_parm(c1rec.account_name,'ACCOUNT_NAME',parm1,parm2);
 c2rec.user_type := find_parm(c2rec.user_type,'USER_TYPE',parm1,parm2);
 c2rec.receive_emails := find_parm(c2rec.receive_emails,'RECEIVE_EMAILS',parm1,parm2);
 c2rec.sendto_name := find_parm(c2rec.sendto_name,'SENDTO_NAME',parm1,parm2);
 c2rec.sendto_firstname := find_parm(c2rec.sendto_firstname,'SENDTO_FIRSTNAME',parm1,parm2);
 c2rec.sendto_lastname := find_parm(c2rec.sendto_lastname,'SENDTO_LASTNAME',parm1,parm2);
 c2rec.sendto_street := find_parm(c2rec.sendto_street,'SENDTO_STREET',parm1,parm2);
 c2rec.sendto_suburb := find_parm(c2rec.sendto_suburb,'SENDTO_SUBURB',parm1,parm2);
 c2rec.sendto_state := find_parm(c2rec.sendto_state,'SENDTO_STATE',parm1,parm2);
 c2rec.sendto_branch := find_parm(c2rec.sendto_branch,'SENDTO_BRANCH',parm1,parm2);
 c2rec.sendto_department := find_parm(c2rec.sendto_department,'SENDTO_DEPARTMENT',parm1,parm2);
 c2rec.sendto_city := find_parm(c2rec.sendto_city,'SENDTO_CITY',parm1,parm2);
 c2rec.sendto_country := find_parm(c2rec.sendto_country,'SENDTO_COUNTRY',parm1,parm2);
 c2rec.sendto_postcode := find_parm(c2rec.sendto_postcode,'SENDTO_POSTCODE',parm1,parm2);
 c2rec.contact_phone := find_parm(c2rec.contact_phone,'CONTACT_PHONE',parm1,parm2);
 c2rec.contact_mobile := find_parm(c2rec.contact_mobile,'CONTACT_MOBILE',parm1,parm2);
 c2rec.contact_email := find_parm(c2rec.contact_email,'CONTACT_EMAIL',parm1,parm2);

 c2rec.account_billing_id := find_parm(c2rec.account_billing_id,'ACCOUNT_BILLING_ID',parm1,parm2);
 c2rec.account_password := find_parm(c2rec.account_password,'ACCOUNT_PASSWORD',parm1,parm2);
 begin nmb := to_number(find_parm(c2rec.account_limit,'ACCOUNT_LIMIT',parm1,parm2)); exception when others then nmb := NULL; end;
 c2rec.account_limit := nmb;

 c2rec.billing_name := find_parm(c2rec.billing_name,'BILLING_NAME',parm1,parm2);
 c2rec.billing_firstname := find_parm(c2rec.billing_firstname,'BILLING_FIRSTNAME',parm1,parm2);
 c2rec.billing_lastname := find_parm(c2rec.billing_lastname,'BILLING_LASTNAME',parm1,parm2);
 c2rec.billing_street := find_parm(c2rec.billing_street,'BILLING_STREET',parm1,parm2);
 c2rec.billing_suburb := find_parm(c2rec.billing_suburb,'BILLING_SUBURB',parm1,parm2);
 c2rec.billing_state := find_parm(c2rec.billing_state,'BILLING_STATE',parm1,parm2);
 c2rec.billing_branch := find_parm(c2rec.billing_branch,'BILLING_BRANCH',parm1,parm2);
 c2rec.billing_department := find_parm(c2rec.billing_department,'BILLING_DEPARTMENT',parm1,parm2);
 c2rec.billing_city := find_parm(c2rec.billing_city,'BILLING_CITY',parm1,parm2);
 c2rec.billing_country := find_parm(c2rec.billing_country,'BILLING_COUNTRY',parm1,parm2);
 c2rec.billing_postcode := find_parm(c2rec.billing_postcode,'BILLING_POSTCODE',parm1,parm2);
 c2rec.billing_phone := find_parm(c2rec.billing_phone,'BILLING_PHONE',parm1,parm2);
 c2rec.billing_email := find_parm(c2rec.billing_email,'BILLING_EMAIL',parm1,parm2);
 c2rec.billing_fax := find_parm(c2rec.billing_fax,'BILLING_FAX',parm1,parm2);
 c2rec.tax_code := find_parm(c2rec.tax_code,'TAX_CODE',parm1,parm2);
 c2rec.tax_group := find_parm(c2rec.tax_group,'TAX_GROUP',parm1,parm2);
 c2rec.accept_pay_by_acct := find_parm(c2rec.accept_pay_by_acct,'ACCEPT_PAY_BY_ACCT',parm1,parm2);

 c2rec.booking_defined_1 := find_parm(c2rec.booking_defined_1,'BOOKING_DEFINED_1',parm1,parm2);
 c2rec.booking_defined_2 := find_parm(c2rec.booking_defined_2,'BOOKING_DEFINED_2',parm1,parm2);
 c2rec.booking_defined_3 := find_parm(c2rec.booking_defined_3,'BOOKING_DEFINED_3',parm1,parm2);
 c2rec.booking_defined_4 := find_parm(c2rec.booking_defined_4,'BOOKING_DEFINED_4',parm1,parm2);
 c2rec.booking_defined_5 := find_parm(c2rec.booking_defined_5,'BOOKING_DEFINED_5',parm1,parm2);
 c2rec.booking_defined_6 := find_parm(c2rec.booking_defined_6,'BOOKING_DEFINED_6',parm1,parm2);
 c2rec.user_defined_1 := find_parm(c2rec.user_defined_1,'USER_DEFINED_1',parm1,parm2);
 c2rec.user_defined_2 := find_parm(c2rec.user_defined_2,'USER_DEFINED_2',parm1,parm2);
 c2rec.user_defined_3 := find_parm(c2rec.user_defined_3,'USER_DEFINED_3',parm1,parm2);
 c2rec.user_defined_4 := find_parm(c2rec.user_defined_4,'USER_DEFINED_4',parm1,parm2);
 c2rec.user_defined_5 := find_parm(c2rec.user_defined_5,'USER_DEFINED_5',parm1,parm2);
 c2rec.user_defined_6 := find_parm(c2rec.user_defined_6,'USER_DEFINED_6',parm1,parm2);
 c2rec.user_fee_code := find_parm(c2rec.user_fee_code,'USER_FEE_CODE',parm1,parm2);
 c2rec.billing_gpo_box := find_parm(c2rec.billing_gpo_box,'BILLING_GPO_BOX',parm1,parm2);
 c2rec.extra := find_parm(c2rec.extra,'EXTRA',parm1,parm2);

 update customer_profile
  set
   public_account = c1rec.public_account,
   account_name = c1rec.account_name
 where
  profile_id = profid;

 update customer_contact
  set
   user_type = c2rec.user_type,
   receive_emails = c2rec.receive_emails,
   sendto_name = c2rec.sendto_name,
   sendto_firstname = c2rec.sendto_firstname,
   sendto_lastname = c2rec.sendto_lastname,
   sendto_street = c2rec.sendto_street,
   sendto_suburb = c2rec.sendto_suburb,
   sendto_state = c2rec.sendto_state,
   sendto_branch = c2rec.sendto_branch,
   sendto_department = c2rec.sendto_department,
   sendto_city = c2rec.sendto_city,
   sendto_country = c2rec.sendto_country,
   sendto_postcode = c2rec.sendto_postcode,
   contact_phone = c2rec.contact_phone,
   contact_mobile = c2rec.contact_mobile,
   contact_email = c2rec.contact_email,
   account_billing_id = c2rec.account_billing_id,
   account_password = c2rec.account_password,
   account_limit = c2rec.account_limit,
   billing_name = c2rec.billing_name,
   billing_firstname = c2rec.billing_firstname,
   billing_lastname = c2rec.billing_lastname,
   billing_street = c2rec.billing_street,
   billing_branch = c2rec.billing_branch,
   billing_department = c2rec.billing_department,
   billing_state = c2rec.billing_state,
   billing_suburb = c2rec.billing_suburb,
   billing_city = c2rec.billing_city,
   billing_country = c2rec.billing_country,
   billing_postcode = c2rec.billing_postcode,
   billing_phone = c2rec.billing_phone,
   billing_email = c2rec.billing_email,
   billing_fax = c2rec.billing_fax,
   billing_gpo_box = c2rec.billing_gpo_box,
   accept_pay_by_acct = c2rec.accept_pay_by_acct,
   tax_code = c2rec.tax_code,
   tax_group = c2rec.tax_group,
   booking_defined_1 = c2rec.booking_defined_1,
   booking_defined_2 = c2rec.booking_defined_2,
   booking_defined_3 = c2rec.booking_defined_3,
   booking_defined_4 = c2rec.booking_defined_4,
   booking_defined_5 = c2rec.booking_defined_5,
   booking_defined_6 = c2rec.booking_defined_6,
   user_defined_1 = c2rec.user_defined_1,
   user_defined_2 = c2rec.user_defined_2,
   user_defined_3 = c2rec.user_defined_3,
   user_defined_4 = c2rec.user_defined_4,
   user_defined_5 = c2rec.user_defined_5,
   user_defined_6 = c2rec.user_defined_6,
   user_fee_code = c2rec.user_fee_code,
   extra = c2rec.extra
   where contact_id = c2rec.contact_id;

 commit;
 result := NULL;

 if update_purchase_order_surl is not null
  then
   open c3(glbx.truncsurl(update_purchase_order_surl));
   fetch c3 into vpoid;
   close c3;
   update purchase_order
    set   sendto_name = c2rec.sendto_name,
  	  sendto_firstname = c2rec.sendto_firstname,
  	  sendto_lastname = c2rec.sendto_lastname,
  	  sendto_street = c2rec.sendto_street,
	  sendto_suburb = c2rec.sendto_suburb,
	  sendto_city = c2rec.sendto_city,
	  sendto_state = c2rec.sendto_state,
	  sendto_branch = c2rec.sendto_branch,
	  sendto_department = c2rec.sendto_department,
	  sendto_postcode = c2rec.sendto_postcode,
	  sendto_country = c2rec.sendto_country,
          contact_phone = c2rec.contact_phone,
	  contact_email = c2rec.contact_email,
	  billing_name = c2rec.billing_name,
	  billing_firstname = c2rec.billing_firstname,
	  billing_lastname = c2rec.billing_lastname,
	  billing_gpo_box = c2rec.billing_gpo_box,
	  billing_branch = c2rec.billing_branch,
	  billing_department = c2rec.billing_department,
	  billing_street = c2rec.billing_street,
	  billing_suburb = c2rec.billing_suburb,
	  billing_city = c2rec.billing_city,
	  billing_postcode = c2rec.billing_postcode,
	  billing_country = c2rec.billing_country,
	  billing_email = c2rec.billing_email,
	  billing_fax = c2rec.billing_fax,
	  billing_phone = c2rec.billing_phone,
	  billing_state = c2rec.billing_state
  where poid = vpoid;
 end if;

 void := find_parm(NULL,'ORDER_STYLE',parm1,parm2);
 if void is not null
  then
    update customer_price_book
     set
      oid = void
     where
      pid = c1rec.pid and
      aid = profid and
      ltype = 'PROFILE';
     if SQL%NOTFOUND
      then
       insert into customer_price_book(pid,aid,oid,valid_until,oid_when_invalid,ltype) values (c1rec.pid,profid,void,null,null,'PROFILE');
     end if;
  end if;

exception
 when others then
  result := sqlerrm;
end modify_profile;

procedure delete_profile( surl in varchar2, profile_un in varchar2, acid in integer default null, result out varchar2 )
as

 cursor c2(uname varchar2, acid integer) is select * from customer_profile where username = uname and aid = acid;
 cursor c6(ttype varchar2) is select * from theme_types tt where theme_type = ttype;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c6rec		c6%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 nmb		integer;
 sts		varchar2(100);
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GLBX.DELETE_PROFILE' );
 if sts is not null
  then
   result := sts;
   return;
 end if;

 if ltype = 'PROFILEG'
  then
   result := 'Guest Logins cannot delete their own Profile';
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 open c6(c1rec.theme_type);
 fetch c6 into theme_rec;
 close c6;

 -- To Delete a profile Business Feature #80 must be enabled
 if substr(theme_rec.theme_data,80,1) = 'F'
  then
   result := 'Modification of Profiles is not allowed';
   return;
 end if;

 -- It is possible for a Profile to Delete itself.
 open c2(upper(profile_un),c1rec.aid);
 fetch c2 into c2rec;
 if c2%NOTFOUND
  then
   close c2;
   result := upper(profile_un) || ' Profile Not Found';
   return;
 end if;
 close c2;
 delete from customer_contact where login_type = 'PROFILE' and aid = c2rec.profile_id;
 delete from audit_profile_password where profile_id = c2rec.profile_id;
 delete from customer_profile where profile_id = c2rec.profile_id;
 commit;

 result := NULL;

exception
 when others then
  result := sqlerrm;
end delete_profile;

procedure external_html_file(surl in varchar2, cusrec in customer_account%ROWTYPE, display_type in varchar2, tag_name in GLBX.MYARRAY, tag_title in GLBX.MYARRAY, fname in varchar2 default null )
as

 cursor c1(phgid integer) is select * from photographer where pid = phgid;

 c1rec		c1%ROWTYPE;
 l_terms        utl_file.file_type;
 template_dir	varchar2(100);
 fname_gen	varchar2(100);
 fname_phg	varchar2(100);
 fname_cus	varchar2(100);
 p_body		varchar2(32767);

begin

 open c1(cusrec.pid);
 fetch c1 into c1rec;
 close c1;

 template_dir := glbx.extract_master_parameter('MAIL_TEMPLATE_DIR');
 if display_type = 'CONTACTUS'
  then
    fname_gen := GLBX.EXT_CONTACTUS;
    fname_phg := 'contactus_' || c1rec.username || '.html';
    fname_cus := 'contactus_' || cusrec.username || '.html';
 elsif display_type = 'FEEDBACK'
  then
    fname_gen := GLBX.EXT_FEEDBACK;
    fname_phg := 'feedback_' || c1rec.username || '.html';
    fname_cus := 'feedback_' || cusrec.username || '.html';
 elsif display_type = 'HELP'
  then
    fname_gen := GLBX.EXT_HELP;
    fname_phg := 'help_' || c1rec.username || '.html';
    fname_cus := 'help_' || cusrec.username || '.html';
 elsif display_type = 'LEGAL'
  then
    fname_gen := GLBX.EXT_LEGAL;
    fname_phg := 'legal_' || c1rec.username || '.html';
    fname_cus := 'legal_' || cusrec.username || '.html';
 elsif display_type = 'PRIVACY'
  then
    fname_gen := GLBX.EXT_PRIVACY;
    fname_phg := 'privacy_' || c1rec.username || '.html';
    fname_cus := 'privacy_' || cusrec.username || '.html';
 elsif display_type = 'README'
  then
    fname_gen := GLBX.EXT_README_NOTES;
    fname_phg := 'readme_' || c1rec.username || '.html';
    fname_cus := 'readme_' || cusrec.username || '.html';
 elsif display_type = 'TERMS'
  then
    fname_gen := GLBX.EXT_TERMS_AND_CONDITIONS;
    fname_phg := 'terms_' || c1rec.username || '.html';
    fname_cus := 'terms_' || cusrec.username || '.html';
 /*
 elsif display_type = 'REGISTRATION'
  then
    fname_gen := GLBX.EXT_REGISTRATION;
    fname_phg := 'privacy_' || c1rec.username || '.html';
    fname_cus := 'privacy_' || cusrec.username || '.html';
 */
 elsif display_type = 'MAIN_IMAGE'
  then
    fname_gen := GLBX.EXT_MAIN_IMAGE;
    fname_phg := 'main_image_' || c1rec.username || '.html';
    fname_cus := 'main_image_' || cusrec.username || '.html';

 elsif display_type = 'EXPIRED'
  then
    -- Account Expired
    template_dir := glbx.extract_fname( fname, 'PWD' );
    template_dir := substr(template_dir,1,length(template_dir)-1);
    fname_gen := glbx.extract_fname( fname, 'FILE' );
    fname_phg := fname_gen;
    fname_cus := fname_gen;
 end if;

 -- First look for one based on the customer username
 -- Then look for one based on the photographer username
 -- Then look for the general one
 begin
   l_terms := utl_file.fopen( template_dir, fname_cus, 'r', max_linesize=>32767 );
  exception
   when others then
    begin
     l_terms := utl_file.fopen( template_dir, fname_phg, 'r', max_linesize=>32767 );
    exception
     when others then
      begin
        l_terms := utl_file.fopen( template_dir, fname_gen, 'r', max_linesize=>32767 );
      exception
       when others then
        htp.p( LNG.ORD_TXT_162 );
        return;
      end;
    end;
 end;

 loop
    begin
      utl_file.get_line(l_terms,p_body);
      p_body := replace(p_body,'<PHOTOGRAPHER>',c1rec.business_name);
      p_body := replace(p_body,'<ACCOUNT_NAME>',cusrec.account_name);
      if tag_name.count > 0
       then
        for j in tag_name.first..tag_name.last loop
         p_body := replace(p_body,tag_name(j),tag_title(j) );
        end loop;
      end if;
      htp.p( p_body );
     exception
      when others
       then exit;
    end;
 end loop;

 utl_file.fclose( l_terms );

exception when others then
 glbx.error_details( 'GLBX', 'EXTERNAL_HTML_FILE', errmsg=>sqlerrm);
 begin utl_file.fclose( l_terms ); exception when others then null; end;
end external_html_file;

function userlist
 return glbx.myarray
as

  cursor c1 is
   select username from customer_account
   union all
   select username from customer_profile
   union all
   select username from photographer
   union all
   select username from manufacturer
   order by 1;

 retlist	glbx.myarray;

begin

 open c1;
 fetch c1 bulk collect into retlist;
 close c1;
 return( retlist );

exception when others then
 glbx.error_details( 'GLBX', 'USERLIST', errmsg=>sqlerrm );
end userlist;

function userexists( un in varchar2 )
 return boolean
as

 cursor c1(un varchar2) is
  select count('x') tot
  from
  (
   select username from customer_account where username = un
   union all
   select username from customer_profile where username = un
   union all
   select username from photographer where username = un
   union all
   select username from manufacturer where username = un
  );

 c1rec	c1%ROWTYPE;

begin
 -- NULL users are not allowed so return it exists
 if trim(un) is null then return( TRUE ); end if;

 open c1(upper(trim(un)));
 fetch c1 into c1rec;
 close c1;
 if c1rec.tot = 0
  then
   return( FALSE );
  else
   return( TRUE );
 end if;
exception when others then
 glbx.error_details( 'GLBX', 'USEREXISTS', errmsg=>sqlerrm, extdet=>'UN:' || un );
end userexists;

function proposed_users( un in varchar2, limit in integer default 5 )
 return glbx.myarray
as

 retlist	glbx.myarray;
 j		integer;
 infctr		integer;
 try_username	varchar2(100);
 try_a		boolean := FALSE;
 try_b		boolean := FALSE;
 try_c		boolean := FALSE;
 try_d		boolean := FALSE;
 try_e		boolean := FALSE;
 try_f		boolean := FALSE;
 try_g		boolean := FALSE;
 try_h		boolean := FALSE;
 try_i		boolean := FALSE;
 try_ctr	integer;

begin
 -- Failsafe protection
 if limit < 1 or limit > 1000 then return( retlist ); end if;
 if trim(un) is null then return( retlist ); end if;

 j := 1;
 infctr := 1;
 try_ctr := 1;

 loop
  -- Work out a user combination based on current name
  if not try_a
   then
    -- Try plural
    try_username := upper(trim(un)) || 'S';
    try_a := TRUE;
  elsif not try_b
   then
    -- Try ing
    try_username := upper(trim(un)) || 'ING';
    try_b := TRUE;
  elsif not try_c
   then
    -- Try starting with X
    try_username := 'X' || upper(trim(un));
    try_c := TRUE;
  elsif not try_d
   then
    -- Try ending with X
    try_username := upper(trim(un)) || 'X';
    try_d := TRUE;
  elsif not try_e
   then
    -- Try ending with _Z
    try_username := upper(trim(un)) || '_Z';
    try_e := TRUE;
  elsif not try_f
   then
    -- Try doubling it
    try_username := upper(trim(un)) || upper(trim(un));
    try_f := TRUE;
  elsif not try_g
   then
    -- Try a shorthand version
    try_username := substr(upper(trim(un)),1,trim(length(upper(trim(un)))/2));
    try_g := TRUE;
  elsif not try_h
   then
    -- Try halving and doubling it
    try_username := substr(upper(trim(un)),1,trim(length(upper(trim(un)))/2)) || substr(upper(trim(un)),1,trim(length(upper(trim(un)))/2));
    try_h := TRUE;
  elsif not try_i
   then
    -- Try interposing it
    try_username := substr(upper(trim(un)),length(upper(trim(un)))/2) || substr(upper(trim(un)),1,trim(length(upper(trim(un)))/2));
    try_i := TRUE;
  else
   -- Try Numbers at the end combinations
    try_username := upper(trim(un)) || to_char(try_ctr);
    try_ctr := try_ctr + 1;
  end if;
  if not userexists( try_username )
   then
    retlist(j) := try_username;
    j := j + 1;
  end if;
  infctr := infctr + 1;
  exit when j > limit or infctr > 10000;
 end loop;

 return(retlist);

end proposed_users;

function encrypt_data( input_string in integer )
 return varchar2
as
   raw_input           	raw(128);
   raw_key             	raw(128) := utl_raw.cast_to_raw(substr(DECS.GREETING_CARD_ENCRYPT_KEY,1,8));
   encrypted_raw        raw(2048);

 begin

   raw_input := utl_raw.cast_to_raw(substr(rpad(to_char(input_string),16,' '),1,16));
   dbms_obfuscation_toolkit.desencrypt(input => raw_input, key => raw_key, encrypted_data => encrypted_raw );
   return( rawtohex(encrypted_raw) );

exception
 when others
  then
   return( NULL );
end encrypt_data;

function validate_encrypted_data( keyval in varchar2, output_nmb out integer )
 return boolean
as

   raw_key             	raw(128) := utl_raw.cast_to_raw(substr(DECS.GREETING_CARD_ENCRYPT_KEY,1,8));
   encrypted_raw        raw(2048);
   decrypted_raw        raw(2048);

 begin

   encrypted_raw := hextoraw( keyval );
   dbms_obfuscation_toolkit.desdecrypt(input => encrypted_raw, key => raw_key, decrypted_data => decrypted_raw);

   begin output_nmb := to_number( utl_raw.cast_to_varchar2(decrypted_raw) ); exception when others then return( FALSE ); end;
   return( TRUE );

exception
 when others
  then
   output_nmb := null;
   return( FALSE );
end validate_encrypted_data;

function encrypt_password( input_string in varchar2, maxlength in integer default 128 )
 return varchar2
as
   raw_input           	raw(128);
   raw_key             	raw(128) := utl_raw.cast_to_raw(substr(DECS.GENERAL_ENCRYPT_KEY || 'AABBCCDD',1,8));
   encrypted_raw        raw(2048);

 begin

   raw_input := utl_raw.cast_to_raw(substr(rpad(nvl(upper(input_string),'|'),maxlength,' '),1,maxlength));
   dbms_obfuscation_toolkit.desencrypt(input => raw_input, key => raw_key, encrypted_data => encrypted_raw );
   return( rawtohex(encrypted_raw) );

exception
 when others
  then
   return( NULL );
end encrypt_password;

function decrypt_password( input_string_hex in varchar2, maxlength in integer default 128 )
 return varchar2
as

   raw_key             	raw(128) := utl_raw.cast_to_raw(substr(DECS.GENERAL_ENCRYPT_KEY || 'AABBCCDD',1,8));
   encrypted_raw        raw(2048);
   decrypted_raw        raw(2048);

 begin

   encrypted_raw := hextoraw( substr(input_string_hex,1,maxlength) );
   dbms_obfuscation_toolkit.desdecrypt(input => encrypted_raw, key => raw_key, decrypted_data => decrypted_raw);

   return( utl_raw.cast_to_varchar2(decrypted_raw) );

exception
 when others
  then
   return( NULL );
end decrypt_password;

function certificate_remaining( certid in integer )
 return number
is
 cursor c1( certid integer ) is select sum(amount_used) su from gift_certificate_usage where certificate_id = certid;
 cursor c2( certif integer ) is select value from gift_certificate where certificate_id = certid;

 c1rec	c1%ROWTYPE;
 c2rec	c2%ROWTYPE;

begin

 open c2( certid );
 fetch c2 into c2rec;
 close c2;
 open c1( certid );
 fetch c1 into c1rec;
 close c1;
 return( nvl(c2rec.value,0) - nvl(c1rec.su,0) );
exception
 when others then return( NULL );
end certificate_remaining;

function historic_purchase_orders( sess_id in integer )
 return glbx.myarray
as

 cursor c1( sess_id integer ) is select previous_sessid from login_session where sessid = sess_id;
 cursor c2( sess_id integer ) is select poid,status,oid,date_created,date_purchased from purchase_order where sessid = sess_id;
 cursor c3( sess_id integer ) is select srfq_id from simple_rfq where sessid = sess_id;
 cursor c4( void integer ) is select * from order_style where oid = void;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ret_arr	glbx.myarray;
 ret_po		glbx.myarray;
 inf_ctr	integer;
 vsess		integer;
 vnmb		integer;
 ctr		integer;

begin
 inf_ctr := 1;
 vsess := sess_id;

 loop
  if inf_ctr <> 1 then ret_arr( inf_ctr ) := vsess; end if;
  open c1( vsess );
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
    close c1;
    exit;
  end if;
  close c1;
  if c1rec.previous_sessid is null then exit; end if;
  exit when inf_ctr > 10000;
  inf_ctr := inf_ctr + 1;
  vsess := c1rec.previous_sessid;
 end loop;
 if ret_arr.count = 0 then ret_arr(1) := NULL; return( ret_arr ); end if;

 -- Extract the Purchase Order Id, or the Simple RFQ Id
 inf_ctr := 0;
 ctr := 0;
 for j in ret_arr.first..ret_arr.last loop
  c2rec.poid := NULL;
  open c2(ret_arr(j));
  fetch c2 into c2rec;
  vnmb := c2rec.poid;
  close c2;
  open c4(c2rec.oid);
  fetch c4 into c4rec;
  close c4;
 --glbx.dbg( 'A:' || c2rec.poid || '-' || c2rec.oid );
 --glbx.dbg( 'B:' || c4rec.disp_ord_trk_expire_at );
 --glbx.dbg( 'C:' || c4rec.disp_ord_trk_expire_date );
  if ( (c4rec.disp_ord_trk_expire_at = 'D') and (nvl(c2rec.date_purchased,c2rec.date_created) + nvl(c4rec.disp_ord_trk_expire_date,30) >= sysdate) ) or
       (nvl(c4rec.disp_ord_trk_expire_at,'N') <> 'D' )
   then
    ctr := ctr + 1;
    if vnmb is not null
     then
      inf_ctr := inf_ctr + 1;
      if c2rec.status in ('PreOrder - No Order Made','PreOrder','PreOrder - Sent to Bank','PreOrder - Confirmed without Payment')
       then
        ret_po(ctr) := 'A' || to_char(vnmb);
      elsif c2rec.status in ('Customer Cancelled','Photographer Cancelled')
       then
        ret_po(ctr) := 'C' || to_char(vnmb);
      elsif c2rec.status = 'Awaiting Authorisation'
       then
        ret_po(ctr) := 'W' || to_char(vnmb);
       else
        ret_po(ctr) := 'P' || to_char(vnmb);
      end if;
      vnmb := NULL;
    end if;
    open c3(ret_arr(j));
    fetch c3 into vnmb;
    close c3;
    if vnmb is not null
     then
      inf_ctr := inf_ctr + 1;
      ret_po(ctr) := 'R' || to_char(vnmb);
      vnmb := NULL;
    end if;
  end if;
 end loop;
 return( ret_po );
exception
 when others then
   return( ret_po );
end historic_purchase_orders;

function certificate_validate( certid in varchar2, acid in integer, cert_rec out GIFT_CERTIFICATE%ROWTYPE, err out varchar2 )
 return boolean
as

   cursor c1( nmb integer) is select * from gift_certificate where certificate_id = nmb;
   cursor c2( nmb integer) is select sum(amount_used) tot from gift_certificate_usage where certificate_id = nmb;

   c2rec	c2%ROWTYPE;

   output_nmb	integer;

begin

   -- Check if Valid Id
   if not validate_encrypted_data(certid,output_nmb)
    then
     err := LNG4.AHC_TXT_715;
     return( FALSE );
   end if;

   open c1(output_nmb);
   fetch c1 into cert_rec;
   if c1%NOTFOUND
    then
     err := LNG4.AHC_TXT_716;
     return( FALSE );
   end if;

   -- Check if Valid for this account
   if cert_rec.valid_only_customer = 'T' and cert_rec.aid <> acid
    then
     err := LNG4.AHC_TXT_714;
     return( FALSE );
   end if;

   -- Check if it has not expired
   if cert_rec.expiry_date < sysdate
    then
     err := LNG4.AHC_TXT_532;
     return( FALSE );
   end if;

   -- Check there is money left on it.
   open c2( output_nmb );
   fetch c2 into c2rec;
   close c2;

   if nvl(c2rec.tot,0) >= cert_rec.value
    then
     err := LNG4.AHC_TXT_717;
     return( FALSE );
   end if;

   return( TRUE );

exception
 when others then return( FALSE );
end certificate_validate;

procedure certificate_history( cert_rec in GIFT_CERTIFICATE%ROWTYPE, pfx in THEME%ROWTYPE )
as

   cursor c1( nmb integer) is select count('x') tot,sum(amount_used) sm from gift_certificate_usage where certificate_id = nmb;
   cursor c2( nmb integer) is select * from gift_certificate_usage where certificate_id = nmb order by date_used desc;
   cursor c3( acid integer) is select account_name,username from customer_account where aid = acid;

   c1rec	c1%ROWTYPE;
   c3rec	c3%ROWTYPE;

begin

 open c1( cert_rec.certificate_id );
 fetch c1 into c1rec;
 close c1;

 if c1rec.tot = 0
  then
   glbx.header_msg( LNG4.AHC_TXT_536 );
   return;
 end if;

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG.CST_TXT_099), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
   htp.tabledata( htf.bold( LNG3.ADM_TXT_463), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
   htp.tabledata( htf.bold( LNG3.ADM_TXT_464), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
   htp.tabledata( htf.bold( LNG.CST_TXT_031), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tablerowclose;
 for c2rec in c2( cert_rec.certificate_id ) loop
  htp.tablerowopen;
   htp.tabledata( c2rec.poid, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( to_char(c2rec.date_used,LNG.MASK), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( to_char(c2rec.amount_used,LNG.MONEY_FORMAT), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
   open c3(c2rec.aid);
   fetch c3 into c3rec;
   close c3;
   htp.tabledata( nvl(c3rec.account_name,c3rec.username), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
 end loop;
 htp.tablerowopen;
  htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tabledata( htf.bold( LNG.CST_TXT_138 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tabledata( htf.bold(to_char(c1rec.sm,LNG.MONEY_FORMAT)), cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"' );
  htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tabledata( htf.bold( LNG4.AHC_TXT_530 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tabledata( htf.bold(to_char(cert_rec.value - c1rec.sm,LNG.MONEY_FORMAT)), cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"' );
  htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
 htp.tablerowclose;
 htp.tableclose;

exception when others then
 glbx.error_details( 'GLB', 'CERTIFICATE_HISTORY',null,null,errmsg=>sqlerrm,extdet=>'CERTID:' || cert_rec.certificate_id);
end certificate_history;

procedure public_registration( acid in integer )
as

 cursor c1(acid integer) is select * from generic_registration where aid = acid;
 c1rec	c1%ROWTYPE;

begin

 open c1(acid);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   return; -- Trying to break in
 end if;
 close c1;

 if substr(c1rec.on_presubmit,1,1) = 'T' and
    substr(c1rec.on_presubmit,3,1) = 'T'
  then
   cst.cust_contact( surl=>null, acid=>acid, profid=>NULL, action=>'NEW' );
  else
   return; -- Registration Form Disabled
 end if;

exception when others then
 glbx.error_details( 'GLB', 'PUBLIC_REGISTRATION',null,null,errmsg=>sqlerrm,extdet=>'ACID:' || acid);
end public_registration;

function gif_exists( url in varchar2 )
 return boolean
as
 retval	varchar2(32767);
begin
 retval := utl_http.request( url );
 if retval is null or length(retval) = 0 or substr(retval,1,21) = '<!DOCTYPE HTML PUBLIC'
  then
   return( FALSE );
  else
   return( TRUE );
 end if;
exception
 when others then return( FALSE );
end gif_exists;

function embed_image_map( surl in varchar2, v_umo in integer, adj in number, acid in integer )
 return varchar2
as

 cursor c1( v_umo integer ) is select * from image_map where umo_id = v_umo;
 cursor c2( v_umo integer ) is select umo_scene_id from umo where umo_id = v_umo;

 c2rec		c2%ROWTYPE;
 foundrec	boolean;
 newcoords	varchar2(100);
 href		varchar2(1000);
 tmp		varchar2(32767);

 function adj_coords(coords in varchar2, adj in number )
  return varchar2
 as

  retval	varchar2(100);
  ctr		integer;
  x		integer;
  lastx		integer;

 begin
  if adj = 0 then return( coords ); end if;
  ctr := 1;
  lastx := 0;
  retval := NULL;
  loop
   x := instr( coords, ',', 1, ctr );
   if x = 0
    then
     retval := retval || ',' || to_char(nvl(round(to_number(substr(coords, lastx + 1 )) / adj),0) );
     exit;
   end if;
   retval := retval || ',' || to_char(round(nvl(to_number(substr( coords, lastx + 1, (x - lastx) - 1 )),0) / adj) );
   lastx := x;
   ctr := ctr + 1;
   exit when ctr = 100;
  end loop;
  return( substr(retval,2) );
 exception
  when others then return( coords );
 end adj_coords;

begin
 foundrec := FALSE;
 open c2(v_umo);
 fetch c2 into c2rec;
 close c2;
 for c1rec in c1(v_umo) loop
  foundrec := TRUE;
  if c1rec.search_type = 'N' then href := 'NOHREF';
  elsif c1rec.search_type = 'S' then href := '"' || 'cst.simple_search?surl=' || surl || '&acid=' || acid || '&p1=' || replace(c1rec.search_terms,' ','+') || '&p3=' || replace(LNG.PHG_ALT_390,' ','+') || '"';
  elsif c1rec.search_type = 'A' then href := '"' || c1rec.search_api_call || '?surl=' || surl || '&acid=' || acid || '&v_umo=' || v_umo || '&search_terms=' || replace(c1rec.search_terms,' ','+') || '"';
  elsif c1rec.search_type = 'C' then href := '"' || 'cst.disp_category?surl=' || surl || '&acid=' || acid || '&left_api_parm=' || c2rec.umo_scene_id || '&start_from=1' || '"';
  elsif c1rec.search_type = 'H' then href := '"' || c1rec.search_api_call || '"';
  elsif c1rec.search_type = 'M' then href := '"' || 'mailto:' || c1rec.search_api_call || '"';
  end if;

  if adj = 1
   then
    tmp := tmp || '<AREA SHAPE=' || c1rec.shape || ' COORDS="' || c1rec.coords || '" HREF=' || href || ' ALT="' || c1rec.alt_tag || '">';
   else
    newcoords := adj_coords(replace(c1rec.coords,' ',''),adj);
    tmp := tmp || '<AREA SHAPE=' || c1rec.shape || ' COORDS="' || newcoords || '" HREF=' || href || ' ALT="' || c1rec.alt_tag || '">';
  end if;
 end loop;
 if foundrec
  then
   htp.p( '<MAP NAME="UMO_MAP' || v_umo || '">' || tmp || '</MAP>' );
   return( ' USEMAP=#UMO_MAP' || v_umo || ' ' );
 end if;
 return( NULL );

exception
 when others then return( NULL );
end embed_image_map;

procedure display_query(acid in integer, srcnme in varchar2, ltype in varchar2, sess_id in integer, vpid in integer, lbox in varchar2, rowsret out integer)
as

 cursor c5(acid integer, srcnme varchar2, ltype varchar2, sess_id integer, vpid integer) is
   select *
   from advanced_search
   where pid = vpid and
         nvl(aid,0) = nvl(acid,0) and
         src_name = srcnme and
         login_type = ltype and
        ((ltype = 'PHOTOGRAPHER') or
         (ltype in ('OWNER','PROFILE')) or
         (ltype in ('CUSTOMER','PROFILEG') and (src_name = LNG.PHG_TXT_055) and (sessid = sess_id)) )
   order by order_by;

 cursor c6( uscid integer ) is select title from umo_scene where umo_scene_id = uscid;

 last_umo	integer;
 last_age	varchar2(100);
 last_agev	varchar2(100);
 age_typ	varchar2(20);
 isnew		char(1);
 tmp		varchar2(1000);
 umos		varchar2(1000);
 umolist	GLBX.MYARRAY;

begin
   last_umo := NULL;
   tmp := NULL;
   last_age := NULL;
   umos := NULL;
   for c5rec in c5(acid,srcnme,ltype,sess_id,vpid) loop
    if c5%ROWCOUNT = 1 and c5rec.is_global = 'T'
     then
      htp.p( LNG2.PFM_TXT_168 || ' ' );
    end if;
    htp.p(c5rec.clause );
    htp.p( ' ' );
    htp.bold(c5rec.keyword);
    htp.p( ' ' );
    htp.p(c5rec.join_clause);
    if c5rec.stem = 'T'
     then
      htp.p( '(' || LNG2.PFM_TXT_169 || ')' );
    end if;
    htp.p( ' ' );
    last_umo := c5rec.umo_scene_id;
    tmp := c5rec.ignore_lightbox;
    isnew := c5rec.notify_on_new;
    rowsret := c5rec.rows_returned;
    last_age := c5rec.age;
    umos := c5rec.umo_scene_ids;
   end loop;
   if tmp = 'T' then htp.p( ' and ' || LNG4.AHC_TXT_431 || ' ' || lbox ); end if;
   tmp := NULL;
   if last_umo is not null
    then
     htp.p( 'in' || ' ' );
     open c6(last_umo);
     fetch c6 into tmp;
     close c6;
     htp.bold( tmp );
   end if;
   if umos is not null
    then
     umolist := extract_umos( umos );
     htp.p( 'in' );
     for j in umolist.first..umolist.last loop
      if umolist(j) is not null
       then
        open c6(umolist(j));
        fetch c6 into tmp;
        close c6;
        htp.bold(  ' ' || tmp );
      end if;
     end loop;
   end if;
   if last_age is not null
    then
     last_agev := substr(last_age,1,length(last_agev)-1);
     if substr(last_age,length(last_age),1) = 'D' then age_typ := LNG3.ADM_TXT_668;
     elsif substr(last_age,length(last_age),1) = 'W' then age_typ := LNG5.EXT_TXT_046;
     elsif substr(last_age,length(last_age),1) = 'M' then age_typ := LNG3.ADM_TXT_667;
     elsif substr(last_age,length(last_age),1) = 'Y' then age_typ := LNG2.PBK_TXT_034;
     elsif substr(last_age,length(last_age),1) = 'X' then age_typ := LNG5.EXT_TXT_047;
     end if;
     htp.p( ' ' || LNG5.EXT_TXT_045 || '-' || last_agev || ' ' || age_typ );
   end if;
   if isnew = 'T' then htp.italic( '-' || LNG4.AHC_TXT_997 ); end if;
exception
 when others then return;
end display_query;

function  extract_umos( umos in varchar2 )
 return GLBX.MYARRAY
as

 retarray	GLBX.MYARRAY;
 ctr		integer;
 x		integer;
 lastx		integer;

begin

 retarray(1) := NULL;
 ctr := 1;
 lastx := 0;
 if umos is null then return( retarray ); end if;
 loop
  x := nvl(instr(umos,',',1,ctr),0);
  if x = 0
   then
    retarray(ctr+1) := substr(umos,lastx+1);
    exit;
  end if;
  retarray(ctr+1) := substr(umos,lastx+1,(x-lastx)-1);
  lastx := x;
  ctr := ctr + 1;
 end loop;
 return( retarray );
end extract_umos;

procedure prompt_em_country(surl in varchar2, sts in varchar2, un in varchar2, pw in varchar2, job in varchar2, em in varchar2, unsolicited_email in varchar2 default 'F', country in varchar2)
as

 pfx		THEME%ROWTYPE;

begin
  pfx := glbx.get_thm( DECS.DEFAULT_PHG_THEME );
  glbx.main_title( surl, LNG.CST_TXT_163,'<BODY BGCOLOR="#' || pfx.text_back || '">',stype=>1,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.title( LNG.GLB_TXT_015 );
  htp.nl;
  htp.nl;
  login_page( msg=>LNG.CST_TXT_163, style=>'PROMPT', un=>un, pw=>pw, em=>em, job=>job, unsolicited_email=>unsolicited_email, country=>country, pfx=>pfx, promptoption=>substr(sts,1,1) );
exception when others then
 glbx.error_details( 'GLBX', 'PROMPT_EM_COUNTRY',errmsg=>sqlerrm, extdet=>'MSG:' || sts);
end prompt_em_country;

function keyword_anchor( surl in varchar2, txt in varchar2, acid in integer default null, js in boolean default FALSE, parent in boolean default FALSE )
 return varchar2
as

 retxt		varchar2(32767);
 ctr		integer;
 x		integer;
 z		integer;
 lastx		integer;
 jscript	varchar2(1000);
 jscript_close	varchar2(1000);
 delim		char(1);

begin

 if js
  then
   if parent
    then
     jscript := 'javascript: parent.opener.location = ''';
     jscript_close := '''; parent.close();';
    else
     jscript := 'javascript: window.opener.location = ''';
     jscript_close := '''; window.close();';
   end if;
 end if;

 retxt := NULL;
 ctr := 1;
 lastx := 0;
 if txt is null then return( null ); end if;
 -- Modify to either delimit by commas (with spaces) or just spaces (if no commas)
 if instr(txt,',') > 0 then delim := ','; else delim := ' '; end if;

 loop
  -- Comma or Space Delimited Keyword Support
  x := nvl(instr(txt,delim,1,ctr),0);

  if x = 0
   then
    if trim(substr(txt,lastx+1)) is not null
     then
      retxt := retxt || htf.anchor( jscript || 'cst.simple_search?surl=' || surl || '&acid=' || acid || '&p1=' || replace(trim(substr(txt,lastx+1)),' ','+') || '&p3=' || replace(LNG.PHG_ALT_390,' ','+') || jscript_close, trim(substr(txt,lastx+1)) );
    end if;
    exit;
  end if;
  if trim(substr(txt,lastx+1,(x-lastx)-1)) is not null
   then
    retxt := retxt || htf.anchor( jscript || 'cst.simple_search?surl=' || surl || '&acid=' || acid || '&p1=' || replace(trim(substr(txt,lastx+1,(x-lastx)-1)),' ','+') || '&p3=' || replace(LNG.PHG_ALT_390,' ','+') || jscript_close, trim(substr(txt,lastx+1,(x-lastx)-1)) ) || ' ';
  end if;
  lastx := x;
  ctr := ctr + 1;
  if ctr > 4000 then exit; end if;
 end loop;

 return( retxt );
exception
 when others then return( txt || '-' || sqlerrm );
end keyword_anchor;

function since_last_session( surl in varchar2 )
 return number
as

 cursor c1( surl varchar2 ) is
  select trunc(sysdate - nvl(date_updated,date_created)) + 1 dys
  from login_session where sessid in
  (select previous_sessid from login_session where securl = surl);

 retval	number;

begin
    open c1(glbx.truncsurl(surl));
    fetch c1 into retval;
    close c1;
    retval := nvl(retval,0); -- If not found then nothing should be returned (Note: This query will not work in batch mode)
    return( retval );
exception
 when others then return( 0 );
end since_last_session;

procedure home_disptable( home_rec in home_news%ROWTYPE, surl in varchar2, acid in varchar2, stype in integer, ltype in varchar2, pfx in THEME%ROWTYPE, cusrec in customer_account%ROWTYPE, theme_rec in THEME_TYPES%ROWTYPE, profid in integer )
as

 cursor c1( v_umo integer ) is select * from umo where umo_id = v_umo;
 c1rec	c1%ROWTYPE;

 dsp	varchar2(4000);
 aln	varchar2(100);

procedure disp_link(dsp in varchar2, uscid in integer default null )
as
 lnk	varchar2(1000);
begin
   if home_rec.reference_link_type = 'N'
    then
     htp.p( dsp );
     return;
    elsif home_rec.reference_link_type = 'S'
     then
      if home_rec.reference_search_cat is null
       then
        lnk := 'cst.simple_search?surl=' || surl || '&acid=' || acid || '&p3=0&p1=' || replace(home_rec.reference_link,' ','+') || '&age=' || home_rec.reference_search_age;
       else
        lnk := 'cst.simple_search?surl=' || surl || '&acid=' || acid || '&p3=&p1=' || replace(home_rec.reference_link,' ','+') || '&age=' || home_rec.reference_search_age || '&umoids=' || home_rec.reference_search_cat;
      end if;
    elsif home_rec.reference_link_type = 'H'
     then
      lnk :=  glbx.adjust_for_http(home_rec.reference_link);
    elsif home_rec.reference_link_type = 'M'
     then
      htp.mailto( home_rec.reference_link, dsp );
      return;
    elsif home_rec.reference_link_type = 'C'
     then
      if ltype = 'PHOTOGRAPHER'
       then
        lnk := 'phg.phg_disp_by_scene_fm?surl=' || surl || '&acid=' || acid || '&scnm=' || uscid;
       else
        lnk := 'cst.disp_category?surl=' || surl || '&left_api_parm=' || uscid || '&start_from=1';
      end if;
    elsif home_rec.reference_link_type = 'A'
     then
      lnk := home_rec.reference_link || '?surl=' || SURL || '&ACID=' || acid;
   end if;
   if home_rec.matte_image = 'T' and c1rec.umo_id is not null
    then
     glbx.image_matte(pfx,c1rec.photo_thumbnail.width,c1rec.photo_thumbnail.height,lnk,dsp,null );
    else
     htp.anchor(lnk, dsp );
   end if;
end disp_link;

begin
 if ltype = 'PHOTOGRAPHER'
  then
   null;
 elsif home_rec.display_to = 'B'
  then
   null;
 elsif home_rec.display_to = 'C' and ltype in ('CUSTOMER','PROFILEG','VIRTUAL')
  then
   return;
 elsif home_rec.display_to = 'G' and ltype in ('OWNER','PROFILE')
  then
   return;
 end if;

 htp.tableopen( cattributes=>'width="100%" cellpadding=2 cellspacing=0 rules="NONE" frame="HSIDES,VSIDES" border=' || to_char(nvl(home_rec.frame_news,0)) ); --frame="VOID" border=' || to_char(nvl(home_rec.frame_news,0))
 if home_rec.title is not null and nvl(home_rec.news_object,'N') <> 'A'
  then
   htp.tablerowopen;
     htp.p( '<TD bgcolor=#' || home_rec.title_highlight || ' STYLE="background-color: #' || home_rec.title_highlight || '; font-family: ''' || home_rec.font || '''; font-size: ' || to_char( 8 + home_rec.title_inc_font) || 'pt; color: #' || home_rec.title_font_colour || '" ALIGN="LEFT" valign="MIDDLE">');
     htp.p( home_rec.title );
     htp.p( '</TD>' );
   htp.tablerowclose;
 end if;

 if home_rec.news_object <> 'N'
  then
   htp.tablerowopen;
     htp.p( '<TD STYLE="font-family: ''' || home_rec.font || '''; font-size: ' || to_char( 8 + home_rec.font_inc_font) || 'pt; color: #' || home_rec.font_colour || '" ALIGN="LEFT" VALIGN="TOP">');
     if home_rec.news_object = 'S' -- Search
      then
       htp.tableopen( cattributes=>'width="100%" cellpadding=4 cellspacing=0 border=0' );
        htp.tablerowopen;
         htp.tabledata( htf.bold(LNG.GLB_TXT_092), cattributes=>'bgcolor=#' || home_rec.title_highlight || ' valign="MIDDLE" align="LEFT" STYLE="background-color: #' || home_rec.title_highlight || '; font-size: ' || to_char(4+stype) || 'pt"' );
         htp.formopen( 'cst.simple_search' );
         htp.formhidden( 'SURL', glbx.rndsurl(surl));
         htp.formhidden( 'ACID', acid );
         htp.formhidden( 'P3', '0' );
         if substr(pfx.search_choices,2,1) = 'T'
          then
            htp.tabledata(htf.anchor( 'cst.acct_search?surl=' || surl || '&acid=' || acid || '&search_call=ADVANCED',LNG2.FNM_TXT_139,cattributes=>'STYLE="font-size: ' || to_char(2+stype) || 'pt"'),cattributes=>pfx.qcbground || ' valign="MIDDLE" align="CENTER"');
          else
           htp.tabledata('&nbsp;',cattributes=>pfx.qbground );
         end if;
        htp.tablerowclose;
        htp.tablerowopen;
         htp.tabledata(htf.formtext( 'P1', round(glbx.sctrl(pfx.theme_name,'SCROLLBAR_WIDTH',stype)/2), 100, null),cattributes=>' valign="MIDDLE" align="LEFT" STYLE="font-size: ' || to_char(2+stype) || 'pt"');
         htp.tabledata(htf.formimage( 'Find', DECS.IMAGE_LOCATION || 'adminc/find.gif',cattributes=>'BORDER="0"'),cattributes=>' valign="MIDDLE" align="CENTER"');
        htp.tablerowclose;
      htp.tableclose;
      htp.formclose;
       -- cst.disp_standard_search(surl, stype, ltype, profid, acid, cusrec, pfx, theme_rec, 'VERY SIMPLE' );

     elsif home_rec.news_object = 'C' -- Chat Forum
      then
       null;

     elsif home_rec.news_object = 'P' -- Poll
      then
       online_poll(surl, stype, ltype, profid, acid, cusrec, pfx, theme_rec);

     elsif home_rec.news_object = 'A' -- Advert (title is the name of the advert)
      then
       htp.img( DECS.ADVERT_LOCATION || home_rec.title, cattributes=>'border=1', calt=>home_rec.text_display );

     elsif home_rec.news_object = 'T' -- Categories
      then
       list_categories( surl, stype, ltype, profid, acid, cusrec, pfx, theme_rec, home_rec );

     end if;
     htp.p( '</TD>' );
   htp.tablerowclose;
 end if;

 if home_rec.tnail_or_text = 'T'
  then
   htp.tablerowopen;
     htp.p( '<TD STYLE="font-family: ''' || home_rec.font || '''; font-size: ' || to_char( 6 + nvl(home_rec.font_inc_font,0) + trunc(stype/1.5)) || 'pt; color: #' || home_rec.font_colour || '" ALIGN="LEFT" VALIGN="TOP">');
     htp.p( home_rec.news );
     htp.p( '</TD>' );
   htp.tablerowclose;
 end if;

 htp.tablerowopen;
   htp.p( '<TD STYLE="font-family: ''' || home_rec.font || '''; font-size: ' || to_char( 6 + nvl(home_rec.font_inc_font,0) + trunc(stype/1.5)) || 'pt; color: #' || home_rec.font_colour || '" ALIGN="CENTER" valign="MIDDLE">');

   if home_rec.tnail_or_text = 'T'
    then
     dsp := nvl(home_rec.text_display,'&nbsp;');
    else
     open c1(home_rec.tnail_id);
     fetch c1 into c1rec;
     close c1;
     htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0' );
     htp.tablerowopen;
     htp.p( '<TD STYLE="font-family: ''' || home_rec.font || '''; font-size: ' || to_char( 6 + nvl(home_rec.font_inc_font,0) + trunc(stype/1.5)) || 'pt; color: #' || home_rec.font_colour || '" ALIGN="LEFT" VALIGN="TOP">');
     --htp.p( '</TD>' );
     --htp.p( '<TD align="CENTER" valign="MIDDLE" bgcolor="#' || pfx.tnail_matte_colour || '" width="' || to_char(c1rec.photo_thumbnail.width + nvl(pfx.tnail_width,0)) || '" height="' || to_char(c1rec.photo_thumbnail.height + nvl(pfx.tnail_width,0)) || '">' );
     if home_rec.image_loc = 'T' then aln := 'ALIGN="TOP"';
     elsif home_rec.image_loc = 'L' then aln := 'ALIGN="LEFT"';
     elsif home_rec.image_loc = 'R' then aln := 'ALIGN="RIGHT"';
     elsif home_rec.image_loc = 'C' then aln := 'ALIGN="MIDDLE"';
     elsif home_rec.image_loc = 'B' then aln := 'ALIGN="BOTTOM"';
     end if;
     dsp := '<IMG BORDER=0 WIDTH=' || c1rec.photo_thumbnail.width || ' HEIGHT=' || c1rec.photo_thumbnail.height || ' SRC="' ||
            'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL&parm1=AID&parm2=' || acid ||
            '&parm1=LOGIN_TYPE&parm2=' || ltype ||
            '" ALT="' || c1rec.extras.film_name || '" STYLE="display:block;" hspace="3" vspace="3" ' || aln || '>';
   end if;

   disp_link(dsp, c1rec.umo_scene_id);

   if home_rec.tnail_or_text = 'B'
    then
     disp_link(nvl(home_rec.text_display,'&nbsp;'), c1rec.umo_scene_id);
     htp.p( home_rec.news );
     htp.p( '</TD>' );
     htp.tablerowclose;
     htp.tableclose;
   end if;

   if home_rec.tnail_or_text = 'N'
    then
     htp.p( home_rec.news );
     htp.p( '</TD>' );
     htp.tablerowclose;
     htp.tableclose;
   end if;

   htp.p( '</TD>' );
 htp.tablerowclose;

 htp.tableclose;

 if home_rec.line_between_news = 'T' then htp.line; end if;
 htp.nl;

exception when others then
 glbx.error_details( 'GLBX', 'HOME_DISPTABLE',errmsg=>sqlerrm, extdet=>'HOME_REC.HNEWS' || home_rec.hnews);
end home_disptable;

procedure disp_news(surl in varchar2, acid in varchar2, stype in integer, ltype in varchar2, pfx in THEME%ROWTYPE, cusrec in customer_account%ROWTYPE, theme_rec in THEME_TYPES%ROWTYPE, profid in integer)
as

 cursor c1(acid integer, col integer) is select * from home_news where display_column = col and aid = acid order by order_by;
 cursor c2(acid integer) is select count(distinct display_column) tot from home_news where aid=acid;

 c2rec  c2%ROWTYPE;
 wd	varchar2(100);

begin
 open c2(acid);
 fetch c2 into c2rec;
 close c2;
 if c2rec.tot = 1 then wd := 'WIDTH="90%"';
 elsif c2rec.tot = 2 then wd := 'WIDTH="45%"';
 elsif c2rec.tot = 3 then wd := 'WIDTH="30%"';
 else wd := 'WIDTH="100%"';
 end if;
 htp.tableopen( cattributes=>'cellspacing=0 cellpadding=10 border=1 frame="VOID" rules="COLS"' );
 htp.tablerowopen;
 htp.p( '<TD VALIGN="TOP" ALIGN="CENTER" ' || wd || '>' );
 for c1rec in c1(acid,1) loop
  home_disptable(c1rec,surl,acid,stype,ltype,pfx,cusrec,theme_rec,profid);
 end loop;
 htp.p( '</TD>' );
 if c2rec.tot > 1
  then
   htp.p( '<TD VALIGN="TOP" ALIGN="CENTER" ' || wd || '>' );
   for c1rec in c1(acid,2) loop
    home_disptable(c1rec,surl,acid,stype,ltype,pfx,cusrec,theme_rec,profid);
   end loop;
   htp.p( '</TD>' );
 end if;
 if c2rec.tot > 2
  then
   htp.p( '<TD VALIGN="TOP" ALIGN="CENTER" ' || wd || '>' );
   for c1rec in c1(acid,3) loop
    home_disptable(c1rec,surl,acid,stype,ltype,pfx,cusrec,theme_rec,profid);
   end loop;
   htp.p( '</TD>' );
 end if;
 htp.tablerowclose;
 htp.tableclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'GLBX', 'DISP_NEWS',errmsg=>sqlerrm);
end disp_news;

procedure note_invalid_access(un in varchar2, pw in varchar2, jb in varchar2 default null )
as
 hostip varchar2(100);
begin
 begin hostip := owa_util.get_cgi_env( 'REMOTE_ADDR' ); exception when others then hostip := 'UNKNOWN'; end;
 insert into invalid_access_attempt(username,password,ip_address,job,date_access) values (un,pw,hostip,jb,sysdate);
 commit;
exception when others then
 glbx.error_details( 'GLBX', 'NOTE_INVALID_ACCESS',errmsg=>sqlerrm);
end note_invalid_access;

function disp_mt( surl in varchar2, ltype in varchar2, v_umo in integer, utype in varchar2, bf_167 in char, pfx in THEME%ROWTYPE, acid in integer, show_cols in GLBX.MYARRAY, noscreen in boolean default FALSE, parent in boolean default FALSE )
 return boolean
as
 cursor c1(v_umo integer, utype varchar2) is
   select category, sub_category, value, edit_type, lov_list, umo_type, external_query, sql_select_mask
   from umo_attribute uta, umo_attributes ut
   where ut.attribute_id = uta.attribute_id and
         ((ut.umo_type = utype) or (ut.umo_type = 'ALL')) and
         uta.umo_id = v_umo and
         ut.displayed = 'T'
   order by ut.order_by,sub_category;

 cursor c2(v_umo integer, utype varchar2) is
   select category, sub_category, value, edit_type, lov_list, umo_type, external_query, sql_select_mask
   from umo_attribute uta, umo_attributes ut
   where ut.attribute_id = uta.attribute_id and
         ((ut.umo_type = utype) or (ut.umo_type = 'ALL')) and
         uta.umo_id = v_umo and
         ((value is not null) or (external_query = 'T')) and
         ut.displayed = 'T'
   order by ut.order_by,sub_category;

 value		varchar2(32767);
 lastrec	varchar2(100);
 js		boolean;

 function is_in_array( val in varchar2, show_cols in GLBX.MYARRAY )
  return boolean
 as
 begin
  if show_cols.count = 0 then return( TRUE ); end if;
  for j in show_cols.first..show_cols.last loop
   if val = show_cols(j) then return( TRUE ); end if;
  end loop;
  return( FALSE );
 end is_in_array;

begin
  js := FALSE;
  if (pfx.fullimg_jscript_popup = 'T' and ltype <> 'PHOTOGRAPHER')
   then
    if not noscreen then js :=  TRUE; end if;
  end if;

  htp.tableopen( cattributes=>pfx.meta_table );
   /* Removed because it does not look nice
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.CST_TXT_042 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_554 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
    htp.tabledata( htf.bold( LNG.CST_TXT_013 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   */
  lastrec := NULL;
  if bf_167 = 'T' -- Display all meta tags even if NULL
   then

    for c1rec in c1( v_umo, utype ) loop
     if is_in_array(c1rec.sub_category,show_cols)
      then
       htp.tablerowopen;
        if pfx.meta_header = 'T'
         then
          if (lastrec is null) or (lastrec <> c1rec.category)
	      then
	       htp.tabledata( htf.bold( initcap(c1rec.category) ), cattributes=>pfx.meta_bground || 'valign="MIDDLE" ALIGN="LEFT"' );
	     else
	       htp.tabledata( '&nbsp;', cattributes=>pfx.meta_bground || 'valign="MIDDLE" ALIGN="LEFT"' );
          end if;
        end if;
        lastrec := c1rec.category;

        if pfx.meta_category = 'T'
         then
          htp.tabledata( htf.bold( initcap(c1rec.sub_category) ), cattributes=>pfx.meta_bground || 'valign="MIDDLE" ALIGN="LEFT"' );
        end if;
        value := nvl(external_query_show( v_umo, utype, c1rec.value, c1rec.edit_type, c1rec.lov_list, c1rec.sql_select_mask, c1rec.external_query ),'&nbsp;');
        if c1rec.edit_type = LNG3.ADM_TXT_583
         then
          htp.tabledata( htf.anchor( replace(substr(value,instr(value,',')+1),' ','%20'), nvl(substr(value,1,instr(value,',')-1),LNG.SLD_TXT_021) ), cattributes=>pfx.meta_bground || 'valign="MIDDLE" ALIGN="LEFT"' );
        elsif c1rec.edit_type = LNG.CST_TXT_038
         then
          htp.tabledata( glbx.keyword_anchor(surl,value,acid,js,parent), cattributes=>pfx.meta_bground || 'valign="MIDDLE" ALIGN="LEFT"' );
        elsif c1rec.edit_type = LNG3.ADM_TXT_612
         then
          htp.tabledata( nvl(htf.mailto( substr(value,instr(value,',')+1),substr(value,1,instr(value,',')-1) ),'&nbsp;'), cattributes=>pfx.meta_bground || 'valign="MIDDLE" ALIGN="LEFT"' );
        else
         htp.tabledata( nvl(value,'&nbsp;'), cattributes=>pfx.meta_bground || 'valign="MIDDLE" ALIGN="LEFT"' );
        end if;

       htp.tablerowclose;
     end if;
    end loop;

  else

    for c2rec in c2( v_umo, utype ) loop
     if is_in_array(c2rec.sub_category,show_cols)
      then
       htp.tablerowopen;
        if pfx.meta_header = 'T'
         then
          if (lastrec is null) or (lastrec <> c2rec.category)
 	    then
	     htp.tabledata( htf.bold( initcap(c2rec.category) ), cattributes=>pfx.meta_bground || 'valign="MIDDLE" ALIGN="LEFT"' );
	    else
	     htp.tabledata( '&nbsp;', cattributes=>pfx.meta_bground || 'valign="MIDDLE" ALIGN="LEFT"' );
          end if;
        end if;
        lastrec := c2rec.category;
        if pfx.meta_category = 'T'
         then
          htp.tabledata( htf.bold( initcap(c2rec.sub_category) ), cattributes=>pfx.meta_bground || 'valign="MIDDLE" ALIGN="LEFT"' );
        end if;
        value := nvl(external_query_show( v_umo, utype, c2rec.value, c2rec.edit_type, c2rec.lov_list, c2rec.sql_select_mask, c2rec.external_query ),'&nbsp;');
        if c2rec.edit_type = LNG3.ADM_TXT_583
         then
          htp.tabledata( htf.anchor( replace(substr(value,instr(value,',')+1),' ','%20'),nvl(substr(value,1,instr(value,',')-1),LNG.SLD_TXT_021) ), cattributes=>pfx.meta_bground || 'valign="MIDDLE" ALIGN="LEFT"' );
        elsif c2rec.edit_type = LNG.CST_TXT_038 -- Keyword
         then
          htp.tabledata( glbx.keyword_anchor(surl,value,acid,js,parent), cattributes=>pfx.meta_bground || 'valign="MIDDLE" ALIGN="LEFT"' );
        elsif c2rec.edit_type = LNG3.ADM_TXT_612
         then
          htp.tabledata( nvl(htf.mailto( substr(value,instr(value,',')+1),substr(value,1,instr(value,',')-1) ),'&nbsp;'), cattributes=>pfx.meta_bground || 'valign="MIDDLE" ALIGN="LEFT"' );
        else
         htp.tabledata( nvl(value,'&nbsp;'), cattributes=>pfx.meta_bground || 'valign="MIDDLE" ALIGN="LEFT"' );
        end if;
       htp.tablerowclose;
      end if;
    end loop;

  end if;
  htp.tableclose;
  return(TRUE);
 exception when others then
 glbx.error_details( 'GLBX', 'DISP_MT',errmsg=>sqlerrm, extdet=>'V_UMO:' || v_umo);
 return( FALSE );
end disp_mt;

function authority_outstanding( profid integer )
 return number
as

 cursor c4( profid integer ) is
  select poid
  from purchase_order
  where paid_method = 'AUTHORISATION' and
        authorised_by = profid and
        payment_received = 'F' and
        status not in ('Customer Cancelled','Photographer Cancelled','PreOrder - No Order Made','PreOrder','PreOrder - Sent to Bank','Awaiting Authorisation','PreOrder - Confirmed without Payment');
 c4rec	c4%ROWTYPE;
 tot	number;

begin
 tot := 0;
 for c4rec in c4(profid) loop
  tot := tot + nvl(glbx.grand_total_payment( c4rec.poid, include_gift_certificate=> TRUE ),0);
 end loop;
 return( tot );
exception
 when others then return( tot );
end authority_outstanding;

function piction_cookie( lrec out login_session%ROWTYPE )
 return varchar2
as
  cursor c1(surl varchar2) is select * from login_session where securl = surl;

  c1rec	c1%ROWTYPE;
  ck	owa_cookie.cookie;
  id	varchar2(100);

begin
  -- Piction Cookie Feature has been disabled.
  if glbx.extract_master_parameter('COOKIE_ENABLED') = 'FALSE'
   then
    return( NULL );
  end if;

  ck := owa_cookie.get(nvl(glbx.extract_master_parameter('COOKIE_NAME'),'PICTION_COOKIE'));
  if ck.num_vals = 0
   then
    return( NULL );
  end if;
  -- insert into temp values ('Z:' || ck.vals(1) ); commit;
  -- insert into temp values ('Z:' || glbx.truncsurl(ck.vals(1)) ); commit;
  id := glbx.truncsurl(ck.vals(1));
  open c1(id);
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
    close c1;
    return( NULL );
  end if;
  close c1;
  lrec := c1rec;
  return( id );
exception
 when others
  then
  htp.bold(sqlerrm);
   return( NULL );
end piction_cookie;

procedure reconnect( failurl in varchar2 default null, simplesearch in varchar2 default null, v_umo in varchar2 default NULL, v_product_id in varchar2 default null, screen_name in varchar2 default null, screen_parms in varchar2 default null, screen_type in varchar2 default 'RIGHT' )
as

-- cursor c1(surl varchar2) is select securl from login_session where previous_sessid = sess_id;
-- c1rec	c1%ROWTYPE;
 surl	varchar2(100);
 lrec	login_session%ROWTYPE;

begin
 surl := piction_cookie( lrec );
 if surl is null
  then
   if failurl is null
    then
     htp.htmlopen;
      htp.header(2,LNG3.ADM_TXT_701,'CENTER');
     htp.htmlclose;
     return;
    else
     owa_util.redirect_url( failurl );
     return;
   end if;
 end if;

 -- If the cookie reset doesn't work, check if there is a future securl
-- open c1(lrec.sessid);
-- fetch c1 into c1rec;
-- close c1;
-- if c1rec.securl is not null then surl := c1rec.securl; end if;

 if lrec.login_type = 'PHOTOGRAPHER'
  then
   phg.phg_master(surl, lrec.screen_type, lrec.browser_type, lrec.browser_version, lrec.os, simplesearch=>simplesearch,v_umo=>v_umo,v_product_id=>v_product_id);

 elsif lrec.login_type = 'MANUFACTURER'
  then
    lab.lab_master(surl, lrec.screen_type );

 elsif lrec.login_type = 'ADMINISTRATOR'
  then
   htp.htmlopen;
   htp.p( '<HEAD>' );
   htp.title( glbx.extract_master_parameter('MENU_TITLE') );
   htp.p( '</HEAD>' );
   htp.framesetopen('99%,1%','100%',cattributes=>'frameborder="0" framespacing="0" border="0"');
    htp.frame( 'adm.acct_bottom?surl=' || glbx.rndsurl(surl) || '&msg=','ADM_MASTER');
   htp.framesetclose;
  htp.p( '<BODY>' );
   htp.noframesopen;
    glbx.noframe(surl,'GLBX.RECONNECT');
   htp.noframesclose;
  htp.p( '</BODY>' );
   htp.htmlclose;

 else
   cst.acct_master(surl, lrec.screen_type, lrec.browser_type, lrec.browser_version, lrec.os, simplesearch=>simplesearch,v_umo=>v_umo,v_product_id=>v_product_id,screen_name=>screen_name,screen_parms=>screen_parms,screen_type=>screen_type);

 end if;

exception when others then
 glbx.error_details( 'GLBX', 'RECONNECT',errmsg=>sqlerrm, extdet=>'SURL:' || surl);
end reconnect;

function get_theme_types(ttype in varchar2)
 return theme_types%ROWTYPE
as
 cursor c1(ttype varchar2) is select * from theme_types tt where theme_type = ttype;
 c1rec  c1%ROWTYPE;
begin
 open c1(ttype);
 fetch c1 into c1rec;
 close c1;
 return( c1rec );
exception when others then
 glbx.error_details( 'GLB', 'GET_THEME_TYPES',errmsg=>sqlerrm,extdet=>'TTYPE:' || ttype);
end get_theme_types;

function get_order_style(void in integer)
 return order_style%ROWTYPE
as
 cursor c1(ttype varchar2) is select * from order_style where oid = void;
 c1rec  c1%ROWTYPE;
begin
 open c1(void);
 fetch c1 into c1rec;
 close c1;
 return( c1rec );
exception when others then
 glbx.error_details( 'GLB', 'GET_ORDER_STYLE',errmsg=>sqlerrm,extdet=>'VOID:' || void);
end get_order_style;

function get_order_style( acid in integer, profid in integer, logintype in varchar2, b2c_value out varchar2 )
 return integer
as

 cursor c1(id integer, logintype varchar2) is select * from customer_price_book where aid = id and ltype = logintype and oid is not null;

 c1rec		c1%ROWTYPE;
 foundrec	boolean;

begin

 -- Display Styles go in a hierarchical order.

 b2c_value := 'F';
 foundrec := FALSE;
 if logintype in ('PROFILE','PROFILEG')
  then
   if logintype = 'PROFILEG'
    then
     open c1(profid,'PROFILEG');
     fetch c1 into c1rec;
     if c1%FOUND then foundrec := TRUE; else foundrec := FALSE; end if;
     close c1;
   end if;
   if logintype = 'PROFILE' or not foundrec
    then
     open c1(profid,'PROFILE');
     fetch c1 into c1rec;
     if c1%FOUND then foundrec := TRUE; else foundrec := FALSE; end if;
     close c1;
   end if;
 end if;

 if (logintype in ('PHOTOGRAPHER','OWNER','CUSTOMER','VIRTUAL')) or not foundrec
  then
   if logintype in ('CUSTOMER','VIRTUAL') or not foundrec
    then
     open c1(acid,'CUSTOMER');
     fetch c1 into c1rec;
     if c1%FOUND then foundrec := TRUE; else foundrec := FALSE; end if;
     close c1;
   end if;
   if (logintype in ('PHOTOGRAPHER','OWNER')) or not foundrec
    then
     open c1(acid,'OWNER');
     fetch c1 into c1rec;
     if c1%FOUND then foundrec := TRUE; else foundrec := FALSE; end if;
     close c1;
   end if;
 end if;

 if not foundrec
  then
   return( NULL );
 end if;

 if c1rec.valid_until is not null
  then
   if sysdate > c1rec.valid_until
    then
     b2c_value := c1rec.b2c_enabled;
     return( nvl(c1rec.oid_when_invalid,c1rec.oid) );
    else
     b2c_value := c1rec.b2c_enabled;
     return( c1rec.oid );
   end if;
 else
  b2c_value := c1rec.b2c_enabled;
  return( c1rec.oid );
 end if;

exception
 when others
  then return( c1rec.oid );
end get_order_style;

function get_purchase_order(sess_id in integer)
 return purchase_order%ROWTYPE
as
 cursor c1(sess_id integer) is select * from purchase_order where sessid = sess_id;
 c1rec  c1%ROWTYPE;
begin
 open c1(sess_id);
 fetch c1 into c1rec;
 close c1;
 return( c1rec );
exception when others then
 glbx.error_details( 'GLB', 'GET_PURCHASE_ORDER',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end get_purchase_order;

procedure get_all_order_details(sess_id in integer, ltype in out varchar2, acid in integer, profid out integer, cusrec out customer_account%rowtype, pfx out theme%rowtype, theme_rec out theme_types%rowtype, purchord out purchase_order%rowtype, voidrec out order_style%rowtype )
as
 cursor c1(sess_id integer) is select * from login_session where sessid=sess_id;
 c1rec	c1%ROWTYPE;
 b2c_value	char(1);
begin
 cusrec := glbx.get_cusrec( sess_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types( cusrec.theme_type );
 purchord := glbx.get_purchase_order( sess_id );
 if purchord.oid is null
  then
   voidrec := glbx.get_order_style( glbx.get_order_style( cusrec.aid, profid, ltype, b2c_value ));
  else
   voidrec := glbx.get_order_style( purchord.oid );
 end if;
 if purchord.poid is null
  then
    open c1(sess_id);
    fetch c1 into c1rec;
    close c1;
    fname.create_purchase_order(c1rec.securl, sess_id, 'PreOrder - No Order Made', profid, ltype, cusrec, voidrec, purchord);
 end if;
exception when others then
 glbx.error_details( 'GLB', 'GET_ALL_ORDER_DETAILS',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end get_all_order_details;

function img_meta_edit( v_umo in integer, utype in varchar2, pfx in THEME%ROWTYPE, single_edit in boolean, stype in integer, acid in integer, format_type in varchar2 default 'PHOTOGRAPHER', bftr in varchar2 default null )
 return boolean
as

 cursor c2(v_umo integer, utype varchar2, ftype varchar2, bftr varchar2) is
  select ut.attribute_id, category, sub_category, value, mandatory, maxlength, edit_type, lov_list, help_on, sql_select_mask, external_query
  from umo_attribute uta, umo_attributes ut
  where ut.attribute_id = uta.attribute_id and
        ((ut.umo_type = utype and ut.editeable = 'T') or (ut.umo_type = 'ALL')) and
        uta.umo_id = v_umo and
        ((ut.business_feature is null) or (ut.business_feature is not null and ut.business_feature = bftr ) ) and
        ((ftype = 'PHOTOGRAPHER') or (ftype <> 'PHOTOGRAPHER' and prof_editeable = 'T'))
 union all
  select ut.attribute_id, category, sub_category, null value, mandatory, maxlength, edit_type, lov_list, help_on, sql_select_mask, external_query
  from umo_attributes ut
  where v_umo is null and
        0 = (select count('x') from exception_report) and
        ((ut.umo_type = utype and ut.editeable = 'T') or (ut.umo_type = 'ALL')) and
        ((ut.business_feature is null) or (ut.business_feature is not null and ut.business_feature = bftr ) ) and
        ((ftype = 'PHOTOGRAPHER') or (ftype <> 'PHOTOGRAPHER' and prof_editeable = 'T'))
 union all
  select ut.attribute_id, category, sub_category, er.txt value, mandatory, maxlength, edit_type, lov_list, help_on, sql_select_mask, external_query
  from umo_attributes ut, exception_report er
  where v_umo is null and
        er.id = ut.attribute_id and
        ((ut.umo_type = utype and ut.editeable = 'T') or (ut.umo_type = 'ALL')) and
        ((ut.business_feature is null) or (ut.business_feature is not null and ut.business_feature = bftr ) ) and
        ((ftype = 'PHOTOGRAPHER') or (ftype <> 'PHOTOGRAPHER' and prof_editeable = 'T'))
  order by 2,3;

  foundrec	boolean;
  value		varchar2(32767);

begin
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || pfx.qcbground );
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold(LNG.PHG_TXT_022), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tabledata( htf.bold(LNG.CST_TXT_013), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"' );
  htp.tablerowclose;
  foundrec := FALSE;
  for c2rec in c2( v_umo, utype, format_type, bftr ) loop
   foundrec := TRUE;
   htp.tablerowopen;
    if c2rec.edit_type = 'VARCHAR'
     then
      htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/varchar.gif',cattributes=>'border=0',calt=>c2rec.help_on || chr(10) || LNG2.PBK_TXT_108  ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
    elsif c2rec.edit_type = 'Keyword'
     then
      htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/varchar.gif',cattributes=>'border=0',calt=>c2rec.help_on || chr(10) || LNG.CST_TXT_038 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
    elsif c2rec.edit_type = 'NUMBER'
     then
      htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/number.gif',cattributes=>'border=0',calt=>c2rec.help_on || chr(10) || LNG2.PBK_TXT_109 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
    elsif c2rec.edit_type = 'DATE'
     then
      htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/date.gif',cattributes=>'border=0',calt=>c2rec.help_on || chr(10) || LNG2.PBK_TXT_110 || ':' || LNG.MASK ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
    elsif c2rec.edit_type = 'TIME'
     then
      htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/time.gif',cattributes=>'border=0',calt=>c2rec.help_on || chr(10) || LNG2.PBK_TXT_111 || ':' || LNG.TSMASK_ONLY ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
    elsif c2rec.edit_type = 'LOV'
     then
      htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/list.gif',cattributes=>'border=0',calt=>c2rec.help_on || chr(10) || LNG2.PBK_TXT_112 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
    elsif c2rec.edit_type = 'Boolean'
     then
      htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/boolean.gif',cattributes=>'border=0',calt=>c2rec.help_on || chr(10) || LNG3.ADM_TXT_611 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
    elsif c2rec.edit_type = 'INTEGER'
     then
      htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/number.gif',cattributes=>'border=0',calt=>c2rec.help_on || chr(10) || LNG2.PBK_TXT_113 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
    elsif c2rec.edit_type = 'EMAIL'
     then
      htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/list.gif',cattributes=>'border=0',calt=>c2rec.help_on || chr(10) || LNG3.ADM_TXT_643), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
    elsif c2rec.edit_type = 'LINK'
     then
      htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/list.gif',cattributes=>'border=0',calt=>c2rec.help_on || chr(10) || LNG3.ADM_TXT_594), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
    elsif c2rec.edit_type = 'SQL'
     then
      htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'adminc/query.gif',cattributes=>'border=0',calt=>c2rec.help_on || chr(10) || LNG3.ADM_TXT_832), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
    else
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
    end if;

    if c2rec.mandatory = 'T'
     then
      htp.tabledata( htf.bold( initcap(c2rec.category || '-' || c2rec.sub_category) ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     else
      htp.tabledata( htf.italic( initcap(c2rec.category || '-' || c2rec.sub_category) ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    end if;
    if not single_edit then htp.formhidden( 'TAG_UMO', v_umo ); end if;
    htp.formhidden( 'TAG_ID', to_char(c2rec.attribute_id) );
    htp.formhidden( 'TAG_NAME', NULL );

    value := external_query_show( v_umo, utype, c2rec.value, c2rec.edit_type, c2rec.lov_list, c2rec.sql_select_mask, c2rec.external_query );
    if c2rec.edit_type in ('LOV','Boolean')
     then
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
      glbx.meta_lov( 'TAG_VALUE', c2rec.mandatory, c2rec.lov_list, value );
      htp.p( '</TD>' );
    elsif c2rec.edit_type = 'SQL' and c2rec.lov_list is not null -- SQL
     then
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
      glbx.meta_sql( v_umo, utype, 'TAG_VALUE', c2rec.mandatory, c2rec.lov_list, value );
      htp.p( '</TD>' );
     else
      htp.tabledata( htf.formtext( 'TAG_VALUE', (glbx.sctrl(pfx.theme_name,'DISPLAY_HORIZONTAL',stype) * 4) + 5, c2rec.maxlength, value ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    end if;
   htp.tablerowclose;
  end loop;
  if not foundrec
   then
    if not single_edit then htp.formhidden( 'TAG_UMO', null ); end if;
    htp.formhidden( 'TAG_ID', '0' );
    htp.formhidden( 'TAG_VALUE', null );
    htp.formhidden( 'TAG_NAME', null );
    htp.bold( LNG.PHG_TXT_123 ); htp.nl;
  end if;
 htp.tableclose;
  return( TRUE );
exception when others then
 glbx.error_details( 'GLBX', 'IMG_META_EDIT', vaid=>acid, errmsg=>sqlerrm, extdet=>'V_UMO:' || v_umo || ' UTYPE:' || utype);
 return( FALSE );
end img_meta_edit;

function update_meta_data( surl in varchar2, v_umo in integer, acid in integer, utype in varchar2, ltype in varchar2, tag_id in GLBX.MYARRAY, tag_name in GLBX.MYARRAY, tag_value in GLBX.MYARRAY, reterrors in out GLBX.MYARRAY, reterrors_ctr in out integer )
 return boolean
as

  cursor c1( v_umo integer) is select aid from umo where umo_id = v_umo;
  cursor c3( attrid integer, ftype varchar2) is
   select *
   from umo_attributes
   where attribute_id = attrid and
        ((ftype = 'PHOTOGRAPHER') or (ftype <> 'PHOTOGRAPHER' and prof_editeable = 'T'));

 c3rec		c3%ROWTYPE;
 parm1		ump.parameters;
 parm2		ump.parameters;
 retval		varchar2(4000);

begin
  parm1(1) := 'UMO_ID';
  parm2(1) := to_char(v_umo);
  parm1(2) := 'AID';
  parm2(2) := to_char(acid);
  if acid is null
   then
    open c1(v_umo);
    fetch c1 into parm2(2);
    close c1;
  end if;
  parm1(3) := 'OBJECT_TYPE';
  parm2(3) := utype;
  parm1(4) := 'KEEP_STATUS';
  parm2(4) := 'KEEP';
  reterrors_ctr := 0;

  for j in tag_id.first..tag_id.last loop
   if to_number(nvl(tag_id(j),'0')) > 0
    then
     retval := NULL;
     open c3(tag_id(j),ltype);
     fetch c3 into c3rec;
     if c3%NOTFOUND then c3rec.attribute_id := NULL; end if;
     close c3;
     -- Ensure can only modify valid attributes
     if c3rec.attribute_id is not null
      then
       glbx.validate_meta_tag( tag_value(j), c3rec, retval );

       if retval is not null
        then
         reterrors_ctr := reterrors_ctr + 1;
         reterrors(reterrors_ctr) := '[' || tag_id(j) || ']' || retval;
        else

         if v_umo is not null -- start A
         then

         if c3rec.external_query = 'T'
          then
           if c3rec.sql_update_mask is not null then
            if upper(c3rec.edit_type) = 'BOOLEAN' then
               glbx.meta_sql_query_update( v_umo, c3rec, utype, substr(tag_value(j), -1, 1) );
            else
               glbx.meta_sql_query_update( v_umo, c3rec, utype, tag_value(j) );
            end if;
           end if;
          else
           parm1(5) := 'ATTRIBUTE_ID';
           parm2(5) := '[' || tag_id(j) || ']' || tag_value(j);
           ump.modify_uma(surl,parm1,parm2,retval);
           if retval is not null
            then
             reterrors_ctr := reterrors_ctr + 1;
             reterrors(reterrors_ctr) := LNG4.AHC_TXT_391 || ':' || retval;
           end if;
         end if;
         end if; -- End A

       end if;
     end if;

   elsif to_number(nvl(tag_id(j),'0')) < 0
    then
      parm1(5) := tag_name(j);
      parm2(5) := tag_value(j);
      if retval is not null
       then
       reterrors_ctr := reterrors_ctr + 1;
       reterrors(reterrors_ctr) := LNG4.AHC_TXT_391 || ':' || retval;
      end if;
   end if;

  end loop;

  return( TRUE );
exception when others then
 glbx.error_details( 'GLBX', 'UPDATE_META_DATA', vaid=>acid, errmsg=>sqlerrm, extdet=>'V_UMO:' || v_umo || ' UTYPE:' || utype);
 return( FALSE );
end update_meta_data;

function saved_preference_value( acid in integer, profid in integer, ltype in varchar2, preference_name in varchar2 )
 return varchar2
as

 cursor c1(acid integer, ltype varchar2, preference_name varchar2) is
  select pref_value
  from customer_saved_preference
  where aid = acid and
        login_type = ltype and
        pref_name = preference_name;

 c1rec	c1%ROWTYPE;

begin
 if ltype in ('PROFILE','PROFILEG')
  then
   open c1(profid,ltype,upper(preference_name));
   fetch c1 into c1rec;
   close c1;
  else
   open c1(acid,ltype,upper(preference_name));
   fetch c1 into c1rec;
   close c1;
 end if;
 return( c1rec.pref_value );
exception
 when others then return( NULL );
end saved_preference_value;

function saved_preference_update( acid in integer, profid in integer, ltype in varchar2, preference_name in varchar2, preference_value in varchar2 )
 return boolean
as
begin

 if ltype in ('PROFILE','PROFILEG')
  then
   update customer_saved_preference
    set
     pref_value = preference_value,
     date_updated = sysdate
   where
    aid = profid and
    login_type = ltype and
    pref_name = upper(preference_name);
  if sql%ROWCOUNT = 0
   then
    insert into customer_saved_preference (aid, login_type, date_updated, pref_name, pref_value ) values
     (profid, ltype, sysdate, upper(preference_name), preference_value );
  end if;
  else
   update customer_saved_preference
    set
     pref_value = preference_value,
     date_updated = sysdate
   where
    aid = acid and
    login_type = ltype and
    pref_name = upper(preference_name);
  if sql%ROWCOUNT = 0
   then
    insert into customer_saved_preference (aid, login_type, date_updated, pref_name, pref_value ) values
     (acid, ltype, sysdate, upper(preference_name), preference_value );
  end if;
 end if;
 commit;
 return( TRUE );
exception
 when others then
 glbx.error_details( 'GLBX', 'SAVED_PREFERENCE_UPDATE', vaid=>acid, errmsg=>sqlerrm, extdet=>'ACID:' || acid || ' PROFID:' || profid);
 return( FALSE );
end saved_preference_update;

function saved_preference_delete( acid in integer, profid in integer, ltype in varchar2, preference_name in varchar2 )
 return boolean
as
begin

 if ltype in ('PROFILE','PROFILEG')
  then
   delete from customer_saved_preference
   where
    aid = profid and
    login_type = ltype and
    pref_name = upper(preference_name);
  else
   delete from customer_saved_preference
   where
    aid = acid and
    login_type = ltype and
    pref_name = upper(preference_name);
 end if;
 commit;
 return( TRUE );
exception
 when others then
 glbx.error_details( 'GLBX', 'SAVED_PREFERENCE_DELETE', vaid=>acid, errmsg=>sqlerrm, extdet=>'ACID:' || acid || ' PROFID:' || profid);
 return( FALSE );
end saved_preference_delete;

procedure online_poll(surl in varchar2, stype in integer, ltype in varchar2, profid in integer, acid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, over_width in varchar2 default null )
as

 cursor c1(acid integer) is select * from online_poll_question where aid = acid;
 c1rec	c1%ROWTYPE;

begin
 open c1(cusrec.aid);
 fetch c1 into c1rec;
 close c1;
 if c1rec.poll_id is null then return; end if;
  htp.formopen( 'glbx.accept_online_poll', cattributes=>'onsubmit="javascript: window.open('''',''POLL_WINDOW'',''top=100,left=100,height=300,width=300,location=no,resizable=yes,scrollbars=yes,status=no''); this.target=''POLL_WINDOW'';"' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'ACID', acid );
  htp.tableopen( cattributes=>'width="' || nvl(over_width,'80%') || '" cellpadding=3 cellspacing=0 border=1 rules="NONE" frame="HSIDES,VSIDES"' );
   htp.tablerowopen;
    htp.tabledata( htf.bold(c1rec.poll_question), cattributes=>pfx.qbground || ' valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   if c1rec.is_question = 'T'
    then
     htp.tablerowopen;
      htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" align="LEFT">' );
       htp.formradio( 'P1', 'T', 'CHECKED' );
       htp.bold( ' ' || LNG.PHG_TXT_045 );
       htp.nl;
       htp.formradio( 'P1', 'T' );
       htp.bold( ' ' || LNG.PHG_TXT_046 );
      htp.p( '</TD>' );
     htp.tablerowclose;
    else
     htp.tablerowopen;
      htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" align="LEFT">' );
      if c1rec.text_1 is not null then htp.formradio( 'P1', '1', 'CHECKED' ); htp.p( ' ' || c1rec.text_1 ); htp.nl; end if;
      if c1rec.text_2 is not null then htp.formradio( 'P1', '2' ); htp.p( ' ' || c1rec.text_2 ); htp.nl; end if;
      if c1rec.text_3 is not null then htp.formradio( 'P1', '3' ); htp.p( ' ' || c1rec.text_3 ); htp.nl; end if;
      if c1rec.text_4 is not null then htp.formradio( 'P1', '4' ); htp.p( ' ' || c1rec.text_4 ); htp.nl; end if;
      if c1rec.text_5 is not null then htp.formradio( 'P1', '5' ); htp.p( ' ' || c1rec.text_5 ); htp.nl; end if;
      if c1rec.text_6 is not null then htp.formradio( 'P1', '6' ); htp.p( ' ' || c1rec.text_6 ); htp.nl; end if;
      if c1rec.text_7 is not null then htp.formradio( 'P1', '7' ); htp.p( ' ' || c1rec.text_7 ); htp.nl; end if;
      if c1rec.text_8 is not null then htp.formradio( 'P1', '8' ); htp.p( ' ' || c1rec.text_8 ); htp.nl; end if;
      if c1rec.text_9 is not null then htp.formradio( 'P1', '9' ); htp.p( ' ' || c1rec.text_9 ); htp.nl; end if;
      if c1rec.text_10 is not null then htp.formradio( 'P1', '10' ); htp.p( ' ' || c1rec.text_10 ); htp.nl; end if;
      htp.p( '</TD>' );
     htp.tablerowclose;
   end if;
   htp.tablerowopen;
      htp.tabledata(htf.formimage( 'Find', DECS.IMAGE_LOCATION || 'adminc/find.gif',cattributes=>'BORDER="0"'),cattributes=>pfx.qcbground || ' valign="MIDDLE" align="CENTER"');
   htp.tablerowclose;
   if c1rec.disclaimer is not null
    then
     htp.tablerowopen;
       htp.tabledata( htf.italic(c1rec.disclaimer), cattributes=>pfx.qbground || ' valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
   end if;
  htp.tableclose;
  htp.formclose;

end online_poll;

procedure accept_online_poll( surl in varchar2, acid in integer, p1 in varchar2 default null, find in varchar2 default null )
as

 cursor c1(acid integer) is select * from online_poll_question where aid = acid;

 c1rec		c1%ROWTYPE;
 cusrec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 ttl		integer;
 sts		varchar2(100);

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'GLBX.ACCEPT_ONLINE_POLL' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );

 open c1(cusrec.aid);
 fetch c1 into c1rec;
 close c1;
 if c1rec.poll_id is null then return; end if;

 if c1rec.is_question = 'T'
  then
   if p1 = 'T'
    then
     update online_poll_question set answer_yes = nvl(answer_yes,0) + 1 where aid = cusrec.aid;
    else
     update online_poll_question set answer_no = nvl(answer_no,0) + 1 where aid = cusrec.aid;
   end if;
  else
   if p1 = '1' then update online_poll_question set answer_1 = nvl(answer_1,0) + 1 where aid = cusrec.aid;
   elsif p1 = '2' then update online_poll_question set answer_2 = nvl(answer_2,0) + 1 where aid = cusrec.aid;
   elsif p1 = '3' then update online_poll_question set answer_3 = nvl(answer_3,0) + 1 where aid = cusrec.aid;
   elsif p1 = '4' then update online_poll_question set answer_4 = nvl(answer_4,0) + 1 where aid = cusrec.aid;
   elsif p1 = '5' then update online_poll_question set answer_5 = nvl(answer_5,0) + 1 where aid = cusrec.aid;
   elsif p1 = '6' then update online_poll_question set answer_6 = nvl(answer_6,0) + 1 where aid = cusrec.aid;
   elsif p1 = '7' then update online_poll_question set answer_7 = nvl(answer_7,0) + 1 where aid = cusrec.aid;
   elsif p1 = '8' then update online_poll_question set answer_8 = nvl(answer_8,0) + 1 where aid = cusrec.aid;
   elsif p1 = '9' then update online_poll_question set answer_9 = nvl(answer_9,0) + 1 where aid = cusrec.aid;
   elsif p1 = '10' then update online_poll_question set answer_10 = nvl(answer_10,0) + 1 where aid = cusrec.aid;
   end if;
 end if;
 commit;

 open c1(cusrec.aid);
 fetch c1 into c1rec;
 close c1;
 -- Draw Graph of Results
 glbx.main_title( surl, NULL, glbx.backimg(surl,owner_id,pfx.text_back,cusrec.background_img,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.title( c1rec.poll_question );
 htp.p( '<CENTER>' );
 if c1rec.is_question = 'T' and (nvl(c1rec.answer_yes,0) + nvl(c1rec.answer_no,0)) = 0
  then
   htp.bold( 'No Respones in Yet' );
   return;
 elsif c1rec.is_question = 'F'
  then
   ttl := nvl(c1rec.answer_1,0) + nvl(c1rec.answer_2,0) + nvl(c1rec.answer_3,0) + nvl(c1rec.answer_4,0) + nvl(c1rec.answer_5,0) + nvl(c1rec.answer_6,0) + nvl(c1rec.answer_7,0) + nvl(c1rec.answer_8,0) + nvl(c1rec.answer_9,0) + nvl(c1rec.answer_10,0);
   if ttl = 0
    then
     htp.bold( 'No Respones in Yet' );
     return;
   end if;
 end if;

 htp.nl;
 htp.bold( c1rec.poll_question );
 htp.nl;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=3 cellspacing=0 border=1 rules="NONE" frame="HSIDES,VSIDES"' );
  if c1rec.is_question = 'T'
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNG.PHG_TXT_045 ) );
     htp.tabledata( to_char( round((nvl(c1rec.answer_yes,0) / (nvl(c1rec.answer_yes,0) + nvl(c1rec.answer_no,0))*100)) ) || '%' );
      htp.tabledata( '<IMG SRC="' || DECS.IMAGE_LOCATION || 'adminc/bar.gif" ALIGN=left WIDTH="' || to_char( round((nvl(c1rec.answer_yes,0) / (nvl(c1rec.answer_yes,0) + nvl(c1rec.answer_no,0))*100)) ) || '" HEIGHT="20" BORDER="0" HSPACE="5" VSPACE="0">' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNG.PHG_TXT_046 ) );
     htp.tabledata( to_char( round((nvl(c1rec.answer_no,0) / (nvl(c1rec.answer_yes,0) + nvl(c1rec.answer_no,0))*100)) ) || '%' );
      htp.tabledata( '<IMG SRC="' || DECS.IMAGE_LOCATION || 'adminc/bar.gif" ALIGN=left WIDTH="' || to_char( round((nvl(c1rec.answer_no,0) / (nvl(c1rec.answer_yes,0) + nvl(c1rec.answer_no,0))*100)) ) || '" HEIGHT="20" BORDER="0" HSPACE="5" VSPACE="0">' );
    htp.tablerowclose;
   else
    if c1rec.text_1 is not null then
     htp.tablerowopen;
      htp.tabledata( htf.bold( c1rec.text_1 ) );
      htp.tabledata( to_char( round((nvl(c1rec.answer_1,0) / ttl )*100)) || '%' );
      htp.tabledata( '<IMG SRC="' || DECS.IMAGE_LOCATION || 'adminc/bar.gif" ALIGN=left WIDTH="' || round((nvl(c1rec.answer_1,0) / ttl )*100) || '" HEIGHT="20" BORDER="0" HSPACE="5" VSPACE="0">' );
     htp.tablerowclose;
    end if;
    if c1rec.text_2 is not null then
     htp.tablerowopen;
      htp.tabledata( htf.bold( c1rec.text_2 ) );
      htp.tabledata( to_char( round((nvl(c1rec.answer_2,0) / ttl )*100)) || '%' );
      htp.tabledata( '<IMG SRC="' || DECS.IMAGE_LOCATION || 'adminc/bar.gif" ALIGN=left WIDTH="' || round((nvl(c1rec.answer_2,0) / ttl )*100) || '" HEIGHT="20" BORDER="0" HSPACE="5" VSPACE="0">' );
     htp.tablerowclose;
    end if;
    if c1rec.text_3 is not null then
     htp.tablerowopen;
      htp.tabledata( htf.bold( c1rec.text_3 ) );
      htp.tabledata( to_char( round((nvl(c1rec.answer_3,0) / ttl )*100)) || '%' );
      htp.tabledata( '<IMG SRC="' || DECS.IMAGE_LOCATION || 'adminc/bar.gif" ALIGN=left WIDTH="' || round((nvl(c1rec.answer_3,0) / ttl )*100) || '" HEIGHT="20" BORDER="0" HSPACE="5" VSPACE="0">' );
     htp.tablerowclose;
    end if;
    if c1rec.text_4 is not null then
     htp.tablerowopen;
      htp.tabledata( htf.bold( c1rec.text_4 ) );
      htp.tabledata( to_char( round((nvl(c1rec.answer_4,0) / ttl )*100)) || '%' );
      htp.tabledata( '<IMG SRC="' || DECS.IMAGE_LOCATION || 'adminc/bar.gif" ALIGN=left WIDTH="' || round((nvl(c1rec.answer_4,0) / ttl )*100) || '" HEIGHT="20" BORDER="0" HSPACE="5" VSPACE="0">' );
     htp.tablerowclose;
    end if;
    if c1rec.text_5 is not null then
     htp.tablerowopen;
      htp.tabledata( htf.bold( c1rec.text_5 ) );
      htp.tabledata( to_char( round((nvl(c1rec.answer_5,0) / ttl )*100)) || '%' );
      htp.tabledata( '<IMG SRC="' || DECS.IMAGE_LOCATION || 'adminc/bar.gif" ALIGN=left WIDTH="' || round((nvl(c1rec.answer_5,0) / ttl )*100) || '" HEIGHT="20" BORDER="0" HSPACE="5" VSPACE="0">' );
     htp.tablerowclose;
    end if;
    if c1rec.text_6 is not null then
     htp.tablerowopen;
      htp.tabledata( htf.bold( c1rec.text_6 ) );
      htp.tabledata( to_char( round((nvl(c1rec.answer_6,0) / ttl )*100)) || '%' );
      htp.tabledata( '<IMG SRC="' || DECS.IMAGE_LOCATION || 'adminc/bar.gif" ALIGN=left WIDTH="' || round((nvl(c1rec.answer_6,0) / ttl )*100) || '" HEIGHT="20" BORDER="0" HSPACE="5" VSPACE="0">' );
     htp.tablerowclose;
    end if;
    if c1rec.text_7 is not null then
     htp.tablerowopen;
      htp.tabledata( htf.bold( c1rec.text_7 ) );
      htp.tabledata( to_char( round((nvl(c1rec.answer_7,0) / ttl )*100)) || '%' );
      htp.tabledata( '<IMG SRC="' || DECS.IMAGE_LOCATION || 'adminc/bar.gif" ALIGN=left WIDTH="' || round((nvl(c1rec.answer_7,0) / ttl )*100) || '" HEIGHT="20" BORDER="0" HSPACE="5" VSPACE="0">' );
     htp.tablerowclose;
    end if;
    if c1rec.text_8 is not null then
     htp.tablerowopen;
      htp.tabledata( htf.bold( c1rec.text_8 ) );
      htp.tabledata( to_char( round((nvl(c1rec.answer_8,0) / ttl )*100)) || '%' );
      htp.tabledata( '<IMG SRC="' || DECS.IMAGE_LOCATION || 'adminc/bar.gif" ALIGN=left WIDTH="' || round((nvl(c1rec.answer_8,0) / ttl )*100) || '" HEIGHT="20" BORDER="0" HSPACE="5" VSPACE="0">' );
     htp.tablerowclose;
    end if;
    if c1rec.text_9 is not null then
     htp.tablerowopen;
      htp.tabledata( htf.bold( c1rec.text_9 ) );
      htp.tabledata( to_char( round((nvl(c1rec.answer_9,0) / ttl )*100)) || '%' );
      htp.tabledata( '<IMG SRC="' || DECS.IMAGE_LOCATION || 'adminc/bar.gif" ALIGN=left WIDTH="' || round((nvl(c1rec.answer_9,0) / ttl )*100) || '" HEIGHT="20" BORDER="0" HSPACE="5" VSPACE="0">' );
     htp.tablerowclose;
    end if;
    if c1rec.text_10 is not null then
     htp.tablerowopen;
      htp.tabledata( htf.bold( c1rec.text_10 ) );
      htp.tabledata( to_char( round((nvl(c1rec.answer_10,0) / ttl )*100)) || '%' );
      htp.tabledata( '<IMG SRC="' || DECS.IMAGE_LOCATION || 'adminc/bar.gif" ALIGN=left WIDTH="' || round((nvl(c1rec.answer_10,0) / ttl )*100) || '" HEIGHT="20" BORDER="0" HSPACE="5" VSPACE="0">' );
     htp.tablerowclose;
    end if;
  end if;
 htp.tableclose;
 htp.nl;
 if c1rec.disclaimer is not null
  then
   htp.italic( c1rec.disclaimer );
 end if;
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'GLBX', 'ACCEPT_ONLINE_POLL',errmsg=>sqlerrm,extdet=>'P1:' || p1);
end accept_online_poll;

procedure list_categories(surl in varchar2, stype in integer, ltype in varchar2, profid in integer, acid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, home_rec in home_news%ROWTYPE )
as

 cursor c1(acid integer,utype varchar2,phgid integer) is
  select /*+ ALL_ROWS */ um.extras.orderby_scene,um.extras.title title,um.umo_scene_id,usc.parent_scene, count('x') tot
  from umo um, customer_account ca, umo_scene usc
  where um.aid = acid and
        um.aid = ca.aid and
        usc.umo_scene_id = um.umo_scene_id and
        ca.pid = phgid and
        um.umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT') and
        ((utype = 'PHOTOGRAPHER') or
         (utype in ('OWNER','PROFILE') and um.extras.enabled_phg='TRUE') or
         (utype in ('CUSTOMER','PROFILEG') and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE'))
  group by um.extras.orderby_scene,um.extras.title,um.umo_scene_id,usc.parent_scene
  order by um.extras.orderby_scene;

begin

  htp.tableopen( cattributes=>'width="100%" cellpadding=2 cellspacing=0 border=1 rules="NONE" frame="HSIDES,VSIDES"' );
   htp.tablerowopen; -- bgcolor=#' || home_rec.title_highlight || background-color: #' || home_rec.title_highlight || ';
    htp.p( '<TD valign="MIDDLE" align="LEFT" STYLE="font-family: ''' || home_rec.font || '''; font-size: ' || to_char(6 + home_rec.title_inc_font + trunc(stype/1.5)) || 'pt; color: #' || home_rec.title_font_colour || '">' );

    if ltype = 'PHOTOGRAPHER'
     then

      for c1rec in c1( acid, ltype, cusrec.pid ) loop
       htp.anchor('phg.phg_disp_by_scene_fm?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&scnm=' || c1rec.umo_scene_id, lpad(pfx.nested_scene_delim, indnt(c1rec.parent_scene),pfx.nested_scene_delim) || c1rec.title, cattributes=>'STYLE="font-size: ' || to_char(6 + home_rec.font_inc_font + trunc(stype/1.5)) || 'pt"');
       htp.nl;
      end loop;

     else

      for c1rec in c1( cusrec.aid, ltype, cusrec.pid ) loop
       htp.anchor('cst.disp_category?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || c1rec.umo_scene_id  || '&start_from=1', lpad(pfx.nested_scene_delim, indnt(c1rec.parent_scene),pfx.nested_scene_delim) || c1rec.title, cattributes=>'STYLE="font-size: ' || to_char(6 + home_rec.font_inc_font + trunc(stype/1.5)) || 'pt"');
       htp.nl;
      end loop;

    end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
  htp.tableclose;

end list_categories;

procedure meta_prompt( surl in varchar2, acid in integer, ltype in varchar2, tgroup in varchar2, v_umo in integer default null, button_found in out boolean, onegrouponly in integer default null, can_edit in char default 'T', query_mode in boolean default FALSE, default_names in glbx.myarray, default_values in glbx.myarray, recno in integer default null, rectotal in integer default null )
as

 cursor c1(acid integer, tgroup varchar2, onegrouponly integer) is
  select *
  from customer_meta_data_group
  where aid = acid and
        target_area = tgroup and
        ((onegrouponly is null) or (onegrouponly is not null and group_id = onegrouponly))
  order by display_order;
 cursor c2(acid integer, gip integer) is
  select *
  from customer_meta_data
  where aid = acid and
        group_id = gip
  order by display_order;
 cursor c3(attribid integer) is select * from umo_attributes where attribute_id = attribid;
 cursor c4(v_umo integer, attribid integer) is select value from umo_attribute where umo_id = v_umo and attribute_id = attribid;
 cursor c5(acid integer) is select p.pid,scene_name,object_access,ca.theme_name from photographer p,customer_account ca where p.pid = ca.pid and ca.aid = acid;
 cursor c6(v_category varchar2, v_owner_id integer) is
 select umo_scene_id,owned_by,order_by,title,parent_scene
   from umo_scene
   where category = v_category and
   owned_by = 'PUBLIC'
  union all
  select usc.umo_scene_id, usc.owned_by, usc.order_by, usc.title, usc.parent_scene
  from umo_scene usc, photographer ph
  where category = v_category and
        usc.owner_id = ph.pid and
        ph.pid = v_owner_id and
        owned_by = 'PHOTOGRAPHER'
  order by 3;
 cursor c7(v_umo integer) is select * from umo where umo_id = v_umo;
 cursor c8(vsurl varchar2) is select poid from purchase_order po, login_session ls where ls.securl = vsurl and ls.sessid = po.sessid;

 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 umrec		c7%ROWTYPE;
 foundrec	boolean;
 vpoid		integer;
 x		integer;
 lastg		varchar2(4000);
 vttl		varchar2(4000);
 pfx		THEME%ROWTYPE;
 vl		varchar2(32767);
 value		varchar2(32767);

begin
 -- Note: Do not embed FORMOPEN tags here, this is up to the calling module to do this
 open c8(surl);
 fetch c8 into vpoid;
 close c8;
 htp.tableopen(cattributes=>'cellspacing=2 cellpadding=2 border=0');
 open c5(acid);
 fetch c5 into c5rec;
 close c5;
 pfx := glbx.get_thm( c5rec.theme_name );
 for c1rec in c1(acid, tgroup, onegrouponly) loop
  --if c1rec.title is not null then htp.bold( c1rec.title ); end if;
  if ((lastg is null) or (c1rec.title is null) or (lastg is not null and c1rec.title is not null and lastg <> c1rec.title))
   then
    if lastg is not null then htp.tablerowclose; end if;
    htp.tablerowopen;
  end if;
  htp.p( '<TD ALIGN="CENTER" VALIGN="TOP">' );

  htp.tableopen( cattributes=>c1rec.html_table );
  htp.tablerowopen;

   htp.p( '<TD ' || c1rec.html_tabledata || '>' );
   htp.tableopen;
   htp.tablerowopen;

   for c2rec in c2(acid, c1rec.group_id) loop
    open c3(c2rec.attribute_id);
    fetch c3 into c3rec;
    close c3;
    if c2rec.title is not null and c3rec.mandatory = 'T'
     then
      vttl := htf.bold( c2rec.title );
     else
      vttl := c2rec.title;
    end if;
    c4rec.value := NULL;
    if v_umo is null
     then
      c4rec.value := c3rec.lov_list;
     else
      open c4(v_umo, c2rec.attribute_id);
      fetch c4 into c4rec;
      close c4;
    end if;
    if query_mode
     then
      value := NULL;
     else
      value := external_query_show( v_umo, c3rec.umo_type, c4rec.value, c3rec.edit_type, c3rec.lov_list, c3rec.sql_select_mask, c3rec.external_query );
    end if;

    if c2rec.attribute_id = -1
     then
      htp.tablerowclose;
      htp.tablerowopen;

    elsif c2rec.attribute_id = -2
     then
      htp.tabledata(htf.bold( vttl ), cattributes=>'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell);

    elsif c2rec.attribute_id = -3
     then
      if can_edit = 'T' or query_mode
       then
        htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'site_specific/' || vttl, cattributes=>'border=0'), cattributes=>'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell);
       else
        htp.tabledata( '&nbsp;', cattributes=>'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell);
      end if;

    elsif c2rec.attribute_id = -4
     then
      if can_edit = 'T'
       then
        htp.tabledata( GLBX.UPLOAD_NAME, cattributes=>'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell );
       else
        htp.tabledata( '&nbsp;', cattributes=>'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell);
      end if;

    elsif c2rec.attribute_id = -5
     then
      if vttl is not null then htp.tabledata( vttl, cattributes=> c2rec.tablecell ); end if;
       x := nvl(instr(c2rec.lov_checkbox_width,','),0);
       if x = 0
        then
         htp.p( '<TD COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell || '>' );
        else
         htp.p( '<TD COLSPAN=' || substr(c2rec.lov_checkbox_width,1,x-1) || '  ROWSPAN=' || substr(c2rec.lov_checkbox_width,x+1) || c2rec.tablecell || '>' );
       end if;
       if can_edit = 'T' or query_mode
        then
         htp.formhidden( 'P1', c2rec.attribute_id );
         htp.formselectopen( 'P2' );
         for c6rec in c6(c5rec.scene_name,c5rec.pid) loop
          htp.formselectoption( lpad(pfx.nested_scene_delim, indnt(c6rec.parent_scene),pfx.nested_scene_delim) || c6rec.title, cattributes=>'VALUE="' || c6rec.umo_scene_id || '"' );
         end loop;
         htp.formselectclose;
       else
        htp.p( '&nbsp;' );
       end if;
       htp.p( '</TD>' );

    elsif c2rec.attribute_id = -6
     then
       if vttl is not null then htp.tabledata( vttl, cattributes=> c2rec.tablecell ); end if;
       x := nvl(instr(c2rec.lov_checkbox_width,','),0);
       if x = 0
        then
         htp.p( '<TD COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell || '>' );
        else
         htp.p( '<TD COLSPAN=' || substr(c2rec.lov_checkbox_width,1,x-1) || '  ROWSPAN=' || substr(c2rec.lov_checkbox_width,x+1) || c2rec.tablecell || '>' );
       end if;
       if can_edit = 'T'
        then
         htp.formhidden( 'P1', c2rec.attribute_id );
         htp.formselectopen( 'P2' );
          htp.formselectoption( LNG.PHG_ALT_427 );
          htp.formselectoption( LNG.PHG_TXT_308,'SELECTED' );
          htp.formselectoption( LNG.PHG_TXT_309 );
          htp.formselectoption( LNG.PHG_TXT_310 );
         htp.formselectclose;
       else
        htp.p( '&nbsp;' );
       end if;
       htp.p( '</TD>' );

    elsif c2rec.attribute_id = -7
     then
       if vttl is not null then htp.tabledata( vttl, cattributes=> c2rec.tablecell ); end if;
       x := nvl(instr(c2rec.lov_checkbox_width,','),0);
       if x = 0
        then
         htp.p( '<TD COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell || '>' );
        else
         htp.p( '<TD COLSPAN=' || substr(c2rec.lov_checkbox_width,1,x-1) || '  ROWSPAN=' || substr(c2rec.lov_checkbox_width,x+1) || c2rec.tablecell || '>' );
       end if;
       if can_edit = 'T' or query_mode
        then
         htp.formhidden( 'P1', c2rec.attribute_id );
         htp.p( htf.formselectopen( 'P2' ));
         if substr(c5rec.object_access,1,1) = 'T' or substr(c5rec.object_access,1,5) = 'FFFFF'
          then
           htp.formselectoption( 'PHOTO','SELECTED' );
         end if;
         if substr(c5rec.object_access,2,1) = 'T'
          then
           htp.formselectoption( 'DOCUMENT' );
         end if;
         if substr(c5rec.object_access,3,1) = 'T'
          then
           htp.formselectoption( 'AUDIO' );
         end if;
         if substr(c5rec.object_access,4,1) = 'T'
            then
           htp.formselectoption( 'VIDEO' );
         end if;
         if substr(c5rec.object_access,5,1) = 'T'
          then
           htp.formselectoption( 'RELATIONAL' );
         end if;
         if substr(c5rec.object_access,6,1) = 'T'
          then
           htp.formselectoption( 'BLUEPRINT' );
         end if;
       else
        htp.p( '&nbsp;' );
       end if;
         htp.formselectclose;
       htp.p( '</TD>' );

    elsif c2rec.attribute_id = -8
     then
        htp.tabledata( '&nbsp;',cattributes=>'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell);

    elsif c2rec.attribute_id = -9 and v_umo is not null
     then
       open c7(v_umo);
       fetch c7 into umrec;
       close c7;
       x := nvl(instr(c2rec.lov_checkbox_width,','),0);
       if x = 0
        then
         htp.p( '<TD COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell || '>' );
        else
         htp.p( '<TD COLSPAN=' || substr(c2rec.lov_checkbox_width,1,x-1) || '  ROWSPAN=' || substr(c2rec.lov_checkbox_width,x+1) || c2rec.tablecell || '>' );
       end if;
       glbx.image_matte(pfx,umrec.photo_thumbnail.width,umrec.photo_thumbnail.height,
                        null,
                        '<IMG BORDER=0 WIDTH=' || umrec.photo_thumbnail.width || ' HEIGHT=' || umrec.photo_thumbnail.height || ' SRC="' ||
                        'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || acid || '&parm1=VERSION&parm2=' || umrec.version ||
                        '" ALT="' || umrec.extras.film_name || '" STYLE="display:block;">',null );
       htp.p( '</TD>' );

    elsif c2rec.attribute_id = -13 and v_umo is not null
     then
       open c7(v_umo);
       fetch c7 into umrec;
       close c7;
       x := nvl(instr(c2rec.lov_checkbox_width,','),0);
       if x = 0
        then
         htp.p( '<TD COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell || '>' );
        else
         htp.p( '<TD COLSPAN=' || substr(c2rec.lov_checkbox_width,1,x-1) || '  ROWSPAN=' || substr(c2rec.lov_checkbox_width,x+1) || c2rec.tablecell || '>' );
       end if;
       glbx.image_matte(pfx,umrec.photo_master.width,umrec.photo_master.height,
                        null,
                        '<IMG BORDER=0 WIDTH=' || umrec.photo_master.width || ' HEIGHT=' || umrec.photo_master.height || ' SRC="' ||
                        'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || acid || '&parm1=VERSION&parm2=' || umrec.version ||
                        '" ALT="' || umrec.extras.film_name || '" STYLE="display:block;">',null );
       htp.p( '</TD>' );

    elsif c2rec.attribute_id = -10 and v_umo is null
     then
      if vttl is not null then htp.tabledata( vttl, cattributes=> c2rec.tablecell ); end if;
      if c2rec.purchase_column is not null then htp.tabledata( c2rec.purchase_column, cattributes=> c2rec.tablecell );
      elsif c2rec.shopping_column is not null then htp.tabledata( c2rec.shopping_column, cattributes=> c2rec.tablecell );
      elsif c2rec.umo_column is not null then htp.tabledata( c2rec.umo_column, cattributes=> c2rec.tablecell );
      end if;

    elsif c2rec.attribute_id = -10 and v_umo is not null
     then
      if vttl is not null then htp.tabledata( vttl, cattributes=> c2rec.tablecell ); end if;
      vl := NULL;
      if c2rec.umo_column is not null
       then
        execute immediate 'select ' || substr(c2rec.umo_column,instr(c2rec.umo_column,']')+1) || ' from umo where umo_id = :1'
         into vl
          using v_umo;
      elsif c2rec.purchase_column is not null
       then
        execute immediate 'select ' || substr(c2rec.purchase_column,instr(c2rec.purchase_column,']')+1) || ' from purchase_order where poid = :1'
         into vl
          using vpoid;
      end if;
      htp.tabledata( nvl(vl,'&nbsp;'), cattributes=> c2rec.tablecell );

    elsif c2rec.attribute_id = -11
     then
       button_found := TRUE;
       if can_edit = 'T'
        then
         htp.tabledata( htf.formsubmit( 'ACTION', nvl(c2rec.title,'Next')),cattributes=>'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell);
        else
         htp.tabledata( '&nbsp;',cattributes=>'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell);
       end if;

    elsif c2rec.attribute_id = -12
     then
       button_found := TRUE;
       if can_edit = 'T'
        then
         htp.tabledata( htf.formsubmit( 'ACTION', nvl(c2rec.title,'Previous')),cattributes=>'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell);
        else
         htp.tabledata( '&nbsp',cattributes=>'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell);
       end if;

    elsif c2rec.attribute_id = -14 and not query_mode and v_umo is not null and not(nvl(recno,1) = nvl(rectotal,1) and nvl(recno,1) = 1) -- Query Toolbox with Save
     then
       --button_found := TRUE;
       htp.p( '<TD ' || 'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell || '>' );
        htp.formsubmit( 'ACTION', '|-*');
        htp.formsubmit( 'ACTION', '&lt;&lt;<*');
        htp.formsubmit( 'ACTION', '&lt;*');
        htp.formsubmit( 'ACTION', '*-*');
        htp.formsubmit( 'ACTION', '?');
        htp.formsubmit( 'ACTION', '*&gt;');
        htp.formsubmit( 'ACTION', '*&gt;&gt;');
        htp.formsubmit( 'ACTION', '*-|');
       htp.p( '</TD>' );

    elsif c2rec.attribute_id = -14 and not query_mode and v_umo is not null and nvl(recno,1) = nvl(rectotal,1) and nvl(recno,1) = 1 -- Query Toolbox with Save
     then
       --button_found := TRUE;
       htp.p( '<TD ' || 'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell || '>' );
        htp.formsubmit( 'ACTION', '*-*');
        htp.formsubmit( 'ACTION', '?');
       htp.p( '</TD>' );

    elsif c2rec.attribute_id = -14 and not query_mode and v_umo is null -- Query Toolbox with Save
     then
       --button_found := TRUE;
       htp.p( '<TD ' || 'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell || '>' );
        htp.formsubmit( 'ACTION', '?');
       htp.p( '</TD>' );

    elsif c2rec.attribute_id = -15 and query_mode -- Query Toolbox
     then
         htp.tabledata( htf.formsubmit( 'ACTION', nvl(c2rec.title,'Execute Query')),cattributes=>'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell);

    elsif c2rec.attribute_id = -16 and not query_mode and v_umo is not null and not(nvl(recno,1) = nvl(rectotal,1) and nvl(recno,1) = 1) -- Query Toolbox
     then
       --button_found := TRUE;
       htp.p( '<TD ' || 'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell || '>' );
        htp.formsubmit( 'ACTION', '|-');
        htp.formsubmit( 'ACTION', '&lt;&lt;');
        htp.formsubmit( 'ACTION', '&lt;');
        htp.formsubmit( 'ACTION', '-');
        htp.formsubmit( 'ACTION', '?');
        htp.formsubmit( 'ACTION', '&gt;');
        htp.formsubmit( 'ACTION', '&gt;&gt;');
        htp.formsubmit( 'ACTION', '-|');
       htp.p( '</TD>' );

    elsif c2rec.attribute_id = -16 and not query_mode and v_umo is not null and nvl(recno,1) = nvl(rectotal,1) and nvl(recno,1) = 1 -- Query Toolbox
     then
       --button_found := TRUE;
       htp.p( '<TD ' || 'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell || '>' );
        htp.formsubmit( 'ACTION', '-');
        htp.formsubmit( 'ACTION', '?');
       htp.p( '</TD>' );

    elsif c2rec.attribute_id = -16 and not query_mode and v_umo is null -- Query Toolbox with Save
     then
       --button_found := TRUE;
       htp.p( '<TD ' || 'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell || '>' );
        htp.formsubmit( 'ACTION', '?');
       htp.p( '</TD>' );

    elsif c2rec.attribute_id = -17 and query_mode -- Query Mode Instructions
     then
      htp.p( '<TD ' || 'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell || '>' );
       if c2rec.title is null
        then
         htp.italic( 'Use as first position:' );
         htp.p( htf.bold( '&' ) || '- and. ' );
         htp.p( htf.bold( '|' ) || '- or. ' );
         htp.p( htf.bold( '!' ) || '- sounds like. ' );
         htp.p( htf.bold( '$' ) || '- stem. ' );
         htp.p( htf.bold( '%' ) || '- starts with. ' );
         htp.p( htf.bold( '@' ) || '- ignore lightbox.' );
         htp.p( htf.bold( '=' ) || '- exactly matches (Case Sensitive).' );
        else
         htp.p( c2rec.title );
        end if;
      htp.p( '</TD>' );

    elsif c2rec.attribute_id = -18 -- Display Mode
     then
       if query_mode
        then
          htp.tabledata( htf.bold(htf.italic('Query Mode')),cattributes=>'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell);
        elsif can_edit = 'T' and v_umo is null
         then
          htp.tabledata( htf.bold(htf.italic('Insert Mode')),cattributes=>'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell);
        elsif can_edit = 'T' and v_umo is not null
         then
          if rectotal is null and recno = 1
           then
            htp.tabledata( htf.bold(htf.italic('Update Mode')), cattributes=>'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell);
           else
            htp.tabledata( htf.bold(htf.italic('Update Mode ' || recno || '/' || rectotal)), cattributes=>'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell);
          end if;
        else
          htp.tabledata( htf.bold(htf.italic('Read Only')),cattributes=>'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell);
       end if;


    elsif c2rec.attribute_id = -19 and not query_mode -- User Defined Fields
     then
      if default_names.count = 0
       then
          htp.tabledata( '&nbsp;',cattributes=>'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell);
       else
        foundrec := FALSE;
        for z in default_names.first..default_names.last loop
         if default_names(z) = c2rec.title
          then
           htp.tabledata( nvl(default_values(z),'&nbsp;'),cattributes=>'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell);
           foundrec := TRUE;
         end if;
        end loop;
        if not foundrec
         then
          htp.tabledata( '&nbsp;',cattributes=>'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell);
        end if;
      end if;

    elsif (c2rec.attribute_id in (-14, -16, -18, -19) and query_mode) or (c2rec.attribute_id in (-15, -17) and not query_mode) -- Query Toolbox
     then
      null;

    elsif (c2rec.edit_display = 'T' and can_edit = 'T') or (query_mode and c3rec.queryable = 'T')
     then
      if c2rec.display_type = 'C' -- Checkbox
       then
        if vttl is not null then htp.tabledata( vttl, cattributes=> c2rec.tablecell ); end if;
        if c3rec.edit_type = 'Boolean'
         then
          if value = substr(c3rec.lov_list,1,instr(c3rec.lov_list,',')-1)
           then
             htp.tabledata(htf.formhidden( 'P3', '{' || c3rec.attribute_id || '}' || substr(c3rec.lov_list,instr(c3rec.lov_list,',')+1) ) || htf.formcheckbox( 'P3', '[' || c3rec.attribute_id || ']' || substr(c3rec.lov_list,1,instr(c3rec.lov_list,',')-1), 'CHECKED' ), cattributes=> c2rec.tablecell);
           else
             htp.tabledata(htf.formhidden( 'P3', '{' || c3rec.attribute_id || '}' || substr(c3rec.lov_list,instr(c3rec.lov_list,',')+1) ) || htf.formcheckbox( 'P3', '[' || c3rec.attribute_id || ']' || substr(c3rec.lov_list,1,instr(c3rec.lov_list,',')-1) ), cattributes=> c2rec.tablecell);
          end if;
         else
          show_checkbox( c2rec, c3rec, value, c2rec.tablecell );
        end if;

      elsif c2rec.display_type = 'L'
       then
        if vttl is not null then htp.tabledata( vttl, cattributes=> c2rec.tablecell ); end if;
        htp.p( '<TD COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell || '>' );
        htp.formhidden( 'P1', c2rec.attribute_id );
         if c3rec.edit_type in ('LOV','Boolean')
          then
           meta_lov( 'P2', c3rec.mandatory, c3rec.lov_list, value );
         elsif c3rec.edit_type = 'SQL'
          then
           meta_sql( v_umo, c3rec.umo_type, 'P2', c3rec.mandatory, c3rec.lov_list, value );
         end if;
        htp.p( '</TD>' );

      elsif c2rec.display_type = 'S'
       then
        if vttl is not null then htp.tabledata( vttl, cattributes=> c2rec.tablecell ); end if;
        htp.p( '<body onload="fillSections();">');
        htp.p( '<script type="text/javascript" language="JavaScript">' );
        htp.p( '<!--' );
        htp.p( 'var sectionNames=new Array(' || meta_distinct_lov( c3rec.lov_list, value, TRUE ) || ');' );
        htp.p( 'var numSections=sectionNames.length;' );
        htp.p( 'var pages=new Array(numSections);' );
        htp.p( 'pages[0]="";' );
        htp.p( meta_distinct_lov( c3rec.lov_list, value, FALSE,'pages' ) );
        htp.p( 'var idx=new Array(numSections);' );
        htp.p( 'idx[0]="";' );
        htp.p( meta_distinct_lov( c3rec.lov_list, value, FALSE,'idx' ) );
        htp.p( 'var URLbits=self.location.href.split("/");' );
        htp.p( 'var currPage=URLbits[URLbits.length-1];' );
        htp.p( 'var currPageName=currPage.split(".")[0];' );
        htp.p( 'var flag=false;' );
        htp.p( 'function fillSections()' );
        htp.p( '{' );
        htp.p( 'var j=1;' );
        htp.p( 'for(var i=0;i<numSections;i++)' );
        htp.p( '{' );
        htp.p( 'if(i!=0||currPageName!="index")');
        htp.p( '{' );
        htp.p( ' document.navForm.sectionMenu.options[j]=new Option' );
        htp.p( ' (sectionNames[i],i);' );
        htp.p( ' j++;' );
        htp.p( ' } } } ' );
        htp.p( 'function fillPages(form)
                {
                var mySelectedIndex=form.sectionMenu.selectedIndex;
                var m=1;
                selectedSection=mySelectedIndex;
                for(var k=0;k<pages[selectedSection].length;k++)
                   {
                    var selectedPageName=pages[selectedSection][k];
                    var selectedFile=selectedPageName;
                    var vidx=idx[selectedSection][k];
                    var pidx=vidx;
                    if(selectedPageName.indexOf(" ")!=-1)
                       selectedPageName=selectedPageName.split(" ")[1];
                       form.pageMenu.options[m]=new Option(selectedFile,vidx);
                       m++;
                   }
                for(n=pages[selectedSection].length+1;n<30;n++)
                 form.pageMenu.options[n]=new Option("","");
                flag=true;
                }' );

        htp.p( '//-->' );
        htp.p( '</script>' );
        htp.p( '<TD COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell || '>' );
        htp.formhidden( 'P1', 'S' || c2rec.attribute_id );
        htp.p( '<select name="sectionMenu" size="1" onchange="fillPages(this.form);">');
        htp.p( '<option value="" selected>-- Please Select --</option>');
        htp.p( '</select>' );
        htp.p( '<BR>' );
        htp.p( '<BR>' );
        htp.p( '<select name="pageMenu" size=' || c2rec.display_width || ' style="width:280px">');
        htp.p( '</select>' );
        htp.p( '</TD>' );
        htp.p( '</body>' );

      elsif c2rec.display_type = 'V' -- Varchar Field
       then
        if vttl is not null then htp.tabledata( vttl, cattributes=> c2rec.tablecell ); end if;
        htp.tabledata( htf.formhidden( 'P1', c2rec.attribute_id ) || htf.formtext( 'P2', nvl(c2rec.display_width,10), c3rec.maxlength, value ),cattributes=>'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell );

      elsif c2rec.display_type = 'T' -- Text Box
       then
        if vttl is not null then htp.tabledata( vttl, cattributes=> c2rec.tablecell ); end if;
        htp.tabledata( htf.formhidden( 'P1', c2rec.attribute_id ) || htf.formtextareaopen( 'P2', 3, nvl(c2rec.display_width,10)) || value || htf.formtextareaclose,cattributes=>'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell );
      end if;

    else

     if vttl is not null then htp.tabledata( vttl, cattributes=> c2rec.tablecell ); end if;
     if can_edit = 'T' or query_mode
      then
       htp.tabledata( nvl(value,'&nbsp;'), cattributes=>'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell  );
      else
       htp.tabledata( htf.bold(nvl(value,'&nbsp;')), cattributes=>'COLSPAN=' || nvl(c2rec.lov_checkbox_width,'1') || ' ' || c2rec.tablecell  );
     end if;
    end if;

   end loop;

   htp.tablerowclose;
   htp.tableclose;
   htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tableclose;

   htp.p( '</TD>' );
   lastg := c1rec.title;

 end loop;

 htp.tablerowclose;
 htp.tableclose;

exception
 when others then
 glbx.error_details( 'GLBX', 'META_PROMPT', vaid=>acid, errmsg=>sqlerrm, extdet=>'ACID:' || acid || ' TGROUP:' || tgroup);
end meta_prompt;

procedure meta_query_perform( surl in varchar2, acid in integer, sess_id in integer, ltype in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY )
as

 c1rec		customer_account%ROWTYPE;
 stype		integer;
 owner_id	integer;
 profid		integer;
 secdet		ump.security_details;
 qid		varchar2(100);
 and_or		varchar2(20);
 opt		varchar2(20);
 lbox		varchar2(20);
 cstem		varchar2(20);
 edit_type	varchar2(20);
 vltype		varchar2(20);
 tempstr	varchar2(1000);

begin

 qid := 'Screen_Query';

 vltype := ltype;
 c1rec := glbx.get_cusrec( sess_id, vltype, acid, profid );
 secdet.ltype	 := vltype;
 if vltype = 'PHOTOGRAPHER'
  then
   secdet.pid	 := c1rec.pid;
  else
   secdet.pid	 := 0;
 end if;
 secdet.aid	 := c1rec.aid;
 secdet.profid	 := profid;
 secdet.returnto := 'GLB_META';
 secdet.sessid	 := sess_id;
 secdet.em       := null;
 secdet.query    := qid;

 delete from meta_tag_query where sessid = sess_id;
 lbox := 'F';
 for j in p1.first..p1.last loop

  if (p1(j) is not null) and p1(j) <> '0' and
     (not (trim(p2(j)) is null or (length(p2(j)) = 1 and ascii(p2(j)) = 49824)))
   then
    opt := 'Matches';
    and_or := 'And';
    cstem := 'F';
    edit_type := 'VARCHAR';
    tempstr := trim(p2(j));
    -- Check first position
    if substr(p2(j),1,1) = '&'
     then
      and_or := 'And';
      tempstr := substr(p2(j),2);
    elsif substr(p2(j),1,1) = '='
     then
      opt := 'Exactly Matches';
      tempstr := substr(p2(j),2);
    elsif substr(p2(j),1,1) = '|'
     then
      and_or := 'Or';
      tempstr := substr(p2(j),2);
    elsif substr(p2(j),1,1) = '$'
     then
      cstem := 'T';
      tempstr := substr(p2(j),2);
    elsif substr(p2(j),1,1) = '@'
     then
      lbox := 'T';
      tempstr := substr(p2(j),2);
    elsif substr(p2(j),1,1) = '!'
     then
      opt := 'Sounds Like';
      tempstr := substr(p2(j),2);
    elsif substr(p2(j),1,1) = '%'
     then
      opt := 'Starts With';
      tempstr := substr(p2(j),2);
    end if;
    -- Check second position
    if substr(p2(j),2,1) = '&'
     then
      and_or := 'And';
      tempstr := substr(p2(j),3);
    elsif substr(p2(j),2,1) = '='
     then
      opt := 'Exactly Matches';
      tempstr := substr(p2(j),3);
    elsif substr(p2(j),2,1) = '|'
     then
      and_or := 'Or';
      tempstr := substr(p2(j),3);
    elsif substr(p2(j),2,1) = '$'
     then
      cstem := 'T';
      tempstr := substr(p2(j),3);
    elsif substr(p2(j),2,1) = '@'
     then
      lbox := 'T';
      tempstr := substr(p2(j),3);
    elsif substr(p2(j),2,1) = '!'
     then
      opt := 'Sounds Like';
      tempstr := substr(p2(j),3);
    elsif substr(p2(j),2,1) = '%'
     then
      opt := 'Starts With';
      tempstr := substr(p2(j),3);
    end if;
    if instr(tempstr,'%') > 0 then opt := 'Starts With'; end if;

    insert into meta_tag_query(pid,aid,order_by,login_type,cust_id,sessid,attribute_id,value_a,value_b,search_type,search_item,src_name,ignore_lightbox,stem,andor,notify_on_new,show_column) values
     (secdet.pid,c1rec.aid,j,ltype,profid,sess_id,p1(j),tempstr,null,edit_type,opt,qid,lbox,cstem,and_or,'F','T');
  end if;
 end loop;
 -- Create Complex Meta Tag Query from Parameters
 ump.meta_tag_search( surl=>surl, left_api_parm=>qid, start_from =>1, display_detail=>NULL,acid=>profid, sec_details=>secdet );

 -- xxx need to adjust for equivalent for V5

end meta_query_perform;

procedure meta_query_navigate( surl in varchar2, acid in integer, curr_umo in integer, navigate_option in varchar2, next_umo out integer, currno in integer, recno out integer )
as
 cursor c1(sess_id integer) is select umo_id, order_by from customer_meta_data_query where sessid = sess_id order by order_by;
 cursor c2(surl varchar2 ) is select sessid from login_session where securl = surl;
 cursor c3(sess_id integer, lstnmb integer) is
  select a2.umo_id, a2.order_by
  from (select order_by from customer_meta_data_query where umo_id = lstnmb and sessid = sess_id) a1,
       customer_meta_data_query a2
  where a2.sessid = sess_id and a2.order_by > a1.order_by
  order by a2.order_by;
 cursor c3n(sess_id integer, lstnmb integer, inc integer) is
  select a2.umo_id, a2.order_by
  from (select (order_by + inc) order_by from customer_meta_data_query where umo_id = lstnmb and sessid = sess_id) a1,
       customer_meta_data_query a2
  where a2.sessid = sess_id and a2.order_by > a1.order_by
  order by a2.order_by;
 cursor c4(sess_id integer) is select umo_id, order_by from customer_meta_data_query where sessid = sess_id order by order_by desc;
 cursor c5(sess_id integer, lstnmb integer) is
  select a2.umo_id, a2.order_by
  from (select order_by from customer_meta_data_query where umo_id = lstnmb and sessid = sess_id) a1,
       customer_meta_data_query a2
  where a2.sessid = sess_id and a2.order_by < a1.order_by
  order by a2.order_by desc;
 cursor c5p(sess_id integer, lstnmb integer, inc integer) is
  select a2.umo_id, a2.order_by
  from (select (order_by - inc) order_by from customer_meta_data_query where umo_id = lstnmb and sessid = sess_id) a1,
       customer_meta_data_query a2
  where a2.sessid = sess_id and a2.order_by < a1.order_by
  order by a2.order_by desc;
 sess_id	integer;
begin

 open c2( glbx.truncsurl(surl) );
 fetch c2 into sess_id;
 close c2;
 --  based on navigate_option (START, PREVIOUS, NEXT, LAST) pull out ID.
 -- If nothing there, return next_umo is null
 next_umo := NULL;
 if navigate_option = 'START'
  then
   open c1( sess_id );
   fetch c1 into next_umo, recno;
   close c1;

 elsif navigate_option = 'LAST'
  then
   open c4( sess_id );
   fetch c4 into next_umo, recno;
   close c4;

 elsif navigate_option = 'NEXT'
  then
   open c3( sess_id, curr_umo );
   fetch c3 into next_umo, recno;
   close c3;
   next_umo := nvl(next_umo, curr_umo);
   recno := nvl(recno, currno);

 elsif navigate_option = 'NEXTSET'
  then
   open c3n( sess_id, curr_umo, 10 );
   fetch c3n into next_umo, recno;
   close c3n;
   next_umo := nvl(next_umo, curr_umo);
   recno := nvl(recno, currno);

 elsif navigate_option = 'PREVIOUS'
  then
   open c5( sess_id, curr_umo );
   fetch c5 into next_umo, recno;
   close c5;
   next_umo := nvl(next_umo, curr_umo);
   recno := nvl(recno, currno);

 elsif navigate_option = 'PREVIOUSSET'
  then
   open c5p( sess_id, curr_umo, 10 );
   fetch c5p into next_umo, recno;
   close c5p;
   next_umo := nvl(next_umo, curr_umo);
   recno := nvl(recno, currno);

 end if;

end meta_query_navigate;

procedure show_checkbox( c2rec in customer_meta_data%ROWTYPE, c3rec in umo_attributes%ROWTYPE, value in varchar2, cell in varchar2 default null )
as

 ctr		integer;
 ctr_loc	integer;
 lastloc	integer;
 ext_value	varchar2(1000);

begin
  ctr := 0;
  lastloc := 0;
  if value is null then return; end if;
  loop
   ctr := ctr + 1;
   if ctr > 1000 then exit; end if; -- Inf Loop Protection
   ctr_loc := instr(c3rec.lov_list,',',1,ctr);

   if mod(ctr,nvl(c2rec.lov_checkbox_width,5)) = 1
    then
     if ctr > 1
      then
       htp.tablerowclose;
       htp.tablerowopen;
     end if;
   end if;

   if ctr_loc = 0
    then
     ext_value := substr(c3rec.lov_list,lastloc+1);
     if value is not null
      then
       htp.formhidden( 'P3', '{' || c3rec.attribute_id || '}' || ext_value );
       if ext_value = value
        then
         htp.tabledata(htf.formcheckbox( 'P3', '[' || c3rec.attribute_id || ']' || ext_value, 'CHECKED' ));
        else
         htp.tabledata(htf.formcheckbox( 'P3', '[' || c3rec.attribute_id || ']' || ext_value ));
       end if;
      else
       htp.formhidden( 'P3', '{' || c3rec.attribute_id || '}' || ext_value );
       if c2rec.checkbox_enabled = 'T'
        then
         htp.tabledata(htf.formcheckbox( 'P3', '[' || c3rec.attribute_id || ']' || ext_value, 'CHECKED' ));
        else
         htp.tabledata(htf.formcheckbox( 'P3', '[' || c3rec.attribute_id || ']' || ext_value ));
       end if;
     end if;
     htp.tabledata( ext_value, cattributes=>nvl(cell,'ALIGN="LEFT"') );
     exit;
   end if;

   ext_value := substr(c3rec.lov_list,lastloc+1,(ctr_loc-lastloc)-1);
   if value is not null
    then
       htp.formhidden( 'P3', '{' || c3rec.attribute_id || '}' || ext_value );
       if ext_value = value
        then
         htp.tabledata(htf.formcheckbox( 'P3', '[' || c3rec.attribute_id || ']' || ext_value, 'CHECKED' ));
        else
         htp.tabledata(htf.formcheckbox( 'P3', '[' || c3rec.attribute_id || ']' || ext_value ));
       end if;
    else
       htp.formhidden( 'P3', '{' || c3rec.attribute_id || '}' || ext_value );
       if c2rec.checkbox_enabled = 'T'
        then
         htp.tabledata(htf.formcheckbox( 'P3', '[' || c3rec.attribute_id || ']' || ext_value, 'CHECKED' ));
        else
         htp.tabledata(htf.formcheckbox( 'P3', '[' || c3rec.attribute_id || ']' || ext_value ));
       end if;
   end if;
   htp.tabledata( ext_value, cattributes=>nvl(cell,'ALIGN="LEFT"') );
   lastloc := ctr_loc;
  end loop;

end show_checkbox;

procedure show_checkbox( c2rec in customer_meta_data%ROWTYPE, c3rec in umo_attributes%ROWTYPE, value in varchar2 )
as

 ctr		integer;
 ctr_loc	integer;
 lastloc	integer;
 ext_value	varchar2(1000);

begin
  ctr := 0;
  lastloc := 0;
  if value is null then return; end if;
  loop
   ctr := ctr + 1;
   if ctr > 1000 then exit; end if; -- Inf Loop Protection
   ctr_loc := instr(c3rec.lov_list,',',1,ctr);

   if mod(ctr,nvl(c2rec.lov_checkbox_width,5)) = 1
    then
     if ctr > 1
      then
       htp.tablerowclose;
       htp.tablerowopen;
     end if;
   end if;

   if ctr_loc = 0
    then
     ext_value := substr(c3rec.lov_list,lastloc+1);
     if value is not null
      then
       htp.formhidden( 'P3', '{' || c3rec.attribute_id || '}' || ext_value );
       if ext_value = value
        then
         htp.tabledata(htf.formcheckbox( 'P3', '[' || c3rec.attribute_id || ']' || ext_value, 'CHECKED' ));
        else
         htp.tabledata(htf.formcheckbox( 'P3', '[' || c3rec.attribute_id || ']' || ext_value ));
       end if;
      else
       htp.formhidden( 'P3', '{' || c3rec.attribute_id || '}' || ext_value );
       if c2rec.checkbox_enabled = 'T'
        then
         htp.tabledata(htf.formcheckbox( 'P3', '[' || c3rec.attribute_id || ']' || ext_value, 'CHECKED' ));
        else
         htp.tabledata(htf.formcheckbox( 'P3', '[' || c3rec.attribute_id || ']' || ext_value ));
       end if;
     end if;
     htp.tabledata( ext_value, cattributes=>'ALIGN="LEFT"' );
     exit;
   end if;

   ext_value := substr(c3rec.lov_list,lastloc+1,(ctr_loc-lastloc)-1);
   if value is not null
    then
       htp.formhidden( 'P3', '{' || c3rec.attribute_id || '}' || ext_value );
       if ext_value = value
        then
         htp.tabledata(htf.formcheckbox( 'P3', '[' || c3rec.attribute_id || ']' || ext_value, 'CHECKED' ));
        else
         htp.tabledata(htf.formcheckbox( 'P3', '[' || c3rec.attribute_id || ']' || ext_value ));
       end if;
    else
       htp.formhidden( 'P3', '{' || c3rec.attribute_id || '}' || ext_value );
       if c2rec.checkbox_enabled = 'T'
        then
         htp.tabledata(htf.formcheckbox( 'P3', '[' || c3rec.attribute_id || ']' || ext_value, 'CHECKED' ));
        else
         htp.tabledata(htf.formcheckbox( 'P3', '[' || c3rec.attribute_id || ']' || ext_value ));
       end if;
   end if;
   htp.tabledata( ext_value, cattributes=>'ALIGN="LEFT"' );
   lastloc := ctr_loc;
  end loop;

end show_checkbox;

function cust_button( pfx in THEME%ROWTYPE, gif in varchar2, element in integer default 1 )
 return varchar2
as
begin
 if nvl(substr(pfx.separate_customer_bt,1,1),'F') = 'F'
  then
   return( DECS.IMAGE_LOCATION || 'adminc/' || gif );
 end if;

 if nvl(substr(pfx.separate_customer_bt,element,1),'F') = 'F'
  then
   return( DECS.IMAGE_LOCATION || 'adminc/' || gif );
  else
   return( DECS.IMAGE_LOCATION || pfx.disp_prefix || '/' || gif );
 end if;
end cust_button;

function where_called( called_from in varchar2 )
  return integer
 as
 begin
  if called_from = 'MAIN'
   then
    return( 1 );
  elsif called_from = 'LIGHTBOX'
   then
    return( 2 );
  elsif called_from = 'PREFERENCES'
   then
    return( 3 );
  elsif called_from = 'HOME'
   then
    return( 4 );
  end if;
  return( 5 );
end where_called;

function available_to( ltype in varchar2 )
  return integer
 as
 begin
  if ltype = 'PHOTOGRAPHER'
   then
    return( 1 );
  elsif ltype = 'OWNER'
   then
    return( 2 );
  elsif ltype = 'CUSTOMER'
   then
    return( 3 );
  elsif ltype = 'PROFILE'
   then
    return( 4 );
  elsif ltype = 'PROFILEG'
   then
    return( 5 );
  elsif ltype = 'VIRTUAL'
   then
    return( 6 );
  end if;
  return( 7 );
end available_to;

function novelty_option( surl in varchar2, pfx in theme%ROWTYPE, footer_api in varchar2, left_api_parm in varchar2,  current_page_number in integer, display_detail in char, cusrec in customer_account%ROWTYPE, ltype in varchar2, called_from in varchar2, display in varchar2, loc_id in integer )
 return varchar2
as

 cursor c1(acid integer) is select count('x') tot from novelty_customer where aid = acid;
 cursor c2(acid integer, nmb in integer, nmb2 in integer) is
  select display_name, call_type, display_suffix, where_called, program_name, first_parameter, nd.novelty_id, nd.always_main_screen
  from novelty_definition nd, novelty_customer nc
  where nc.novelty_id = nd.novelty_id and
        nc.aid = acid and
        substr(nd.available_to,nmb,1) = 'T' and
        substr(nd.where_called,nmb2,1) = 'T'
  order by nd.order_by,nc.novelty_id;
 cursor c3(phgid integer, nmb in integer, nmb2 in integer) is
  select display_name, call_type, display_suffix, where_called, program_name, first_parameter, nd.novelty_id, nd.always_main_screen
  from novelty_definition nd, novelty_set ns, charge_plan cp, photographer p
  where p.pid = phgid and
        cp.id = p.plan_id and
        cp.novelty_set_id = ns.novelty_set_id and
        nd.novelty_id = ns.novelty_id and
        substr(nd.available_to,nmb,1) = 'T' and
        substr(nd.where_called,nmb2,1) = 'T'
  order by nd.order_by,ns.novelty_id;
 cursor c4(phgid integer, nmb in integer, nmb2 in integer) is
  select count('x') tot
  from novelty_definition nd, novelty_set ns, charge_plan cp, photographer p
  where p.pid = phgid and
        cp.id = p.plan_id and
        cp.novelty_set_id = ns.novelty_set_id and
        nd.novelty_id = ns.novelty_id and
        substr(nd.available_to,nmb,1) = 'T' and
        substr(nd.where_called,nmb2,1) = 'T'
  order by nd.order_by,ns.novelty_id;

 c1rec		c1%ROWTYPE;
 c3rec		c3%ROWTYPE;
 nmb		integer;
 nmb2		integer;
 cusloc		varchar2(100);
 jscript	varchar2(1000);
 jscript_close	varchar2(1000);
 retxt		varchar2(32767);

 function disp_anchor(c3rec in c3%ROWTYPE, typ in varchar2 default 'ANCHOR')
  return varchar2
 as
 begin
  if typ = 'ANCHOR'
   then
    return(
          htf.anchor2(  jscript || c3rec.program_name ||'?surl=' || glbx.rndsurl(surl) || '&loc_id=' || loc_id || '&footer_api=' || replace(footer_api,' ','+') ||
                        '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number ||
                        '&display_detail=' || display_detail || '&acid=' || cusrec.aid || '&first_parameter=' || c3rec.first_parameter ||
                        '&called_from=' || called_from || '&nvid=' || c3rec.novelty_id || jscript_close,
                        htf.img( cust_button(pfx,c3rec.display_suffix,10),cattributes=>'border=0',calt=>c3rec.display_name ),ctarget=>cusloc ));
   elsif typ = 'LOV'
    then
     return(
          htf.formselectoption( c3rec.display_name,
           cattributes=>'VALUE="' || c3rec.program_name ||'?surl=' || glbx.rndsurl(surl) || '&loc_id=' || loc_id || '&footer_api=' || replace(footer_api,' ','+') ||
                        '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number ||
                        '&display_detail=' || display_detail || '&acid=' || cusrec.aid || '&first_parameter=' || c3rec.first_parameter ||
                        '&called_from=' || called_from || '&nvid=' || c3rec.novelty_id || '"' ));
  end if;
 end disp_anchor;

begin
 retxt := NULL;
 if nvl(cusrec.enable_novelties,'F') = 'F'
  then
   -- Nothing to display, novelties are disabled
   return( retxt );
 end if;

 if ltype = 'PHOTOGRAPHER' then cusloc := 'PHG_RIGHT';
 elsif pfx.keep_lhf in ('L','R') then cusloc := 'CUS_RIGHT';
 elsif pfx.keep_lhf = 'N' then cusloc := '_top';
 else cusloc := 'CUS_BOTTOM';
 end if;

 if ltype = 'PHOTOGRAPHER'
  then
   nmb := 1;
 elsif ltype = 'OWNER'
  then
   nmb := 2;
 elsif ltype = 'PROFILE'
  then
   nmb := 3;
 elsif ltype = 'CUSTOMER'
  then
   nmb := 4;
 elsif ltype = 'PROFILEG'
  then
   nmb := 5;
 elsif ltype = 'VIRTUAL'
  then
   nmb := 6;
 end if;

 nmb2 := where_called( called_from );

 open c1(cusrec.aid);
 fetch c1 into c1rec;
 close c1;

 if c1rec.tot = 0
  then
   --open c4(phgid,nmb,nmb2);
   --fetch c4 into c1rec.tot;
   --close c4;
   --if c1rec.tot > 4
   -- then
   --end if;
   for c3rec in c3(cusrec.pid,nmb,nmb2) loop

    if pfx.fullimg_jscript_popup = 'T' and display_detail <> 'S' and c3rec.always_main_screen = 'T' -- Slider does not have pop up image
     then
      jscript := 'javascript: parent.opener.location = ''';
      jscript_close := '''; parent.close();';
      cusloc := NULL;
    else
      jscript := NULL;
      jscript_close := NULL;
    end if;

    if display = 'VERT_TABLE'
     then
      retxt := retxt || htf.tabledata( disp_anchor(c3rec) );
      retxt := retxt || htf.tablerowclose;
      retxt := retxt || htf.tablerowopen;
    elsif display = 'HOR_TABLE'
     then
      retxt := retxt || htf.tabledata( disp_anchor(c3rec) );
    elsif display = 'LOV'
     then
      retxt := retxt || disp_anchor(c3rec,'LOV');
    elsif display = 'ANCHOR'
     then
      retxt := retxt || disp_anchor(c3rec);
      retxt := retxt || htf.nl;
    end if;
   end loop;

  else

   for c3rec in c2(cusrec.aid,nmb,nmb2) loop

    if pfx.fullimg_jscript_popup = 'T' and display_detail <> 'S' and c3rec.always_main_screen = 'T' -- Slider does not have pop up image
     then
      jscript := 'javascript: parent.opener.location = ''';
      jscript_close := '''; parent.close();';
      cusloc := NULL;
    else
      jscript := NULL;
      jscript_close := NULL;
    end if;

    if display = 'VERT_TABLE'
     then
      retxt := retxt || htf.tabledata( disp_anchor(c3rec) );
      retxt := retxt || htf.tablerowclose;
      retxt := retxt || htf.tablerowopen;
    elsif display = 'HOR_TABLE'
     then
      retxt := retxt || htf.tabledata( disp_anchor(c3rec) );
    elsif display = 'LOV'
     then
      retxt := retxt || disp_anchor(c3rec,'LOV');
    elsif display = 'ANCHOR'
     then
      retxt := retxt || disp_anchor(c3rec);
      retxt := retxt || htf.nl;
    end if;
  end loop;

 end if;
 return( retxt );
exception
 when others then
 glbx.error_details( 'GLBX', 'NOVELTY_OPTION', vaid=>cusrec.aid, errmsg=>sqlerrm, extdet=>'PID:' || cusrec.pid );
end novelty_option;

function external_query_show( v_umo in integer, utype in varchar2, value in varchar2, edit_type in varchar2, lov_list in varchar2, sql_select_mask in varchar2, external_query in char )
 return varchar2
as
begin
 if external_query = 'F'
  then
    return( value );
 end if;
 return( glbx.meta_sql_query( v_umo, utype, sql_select_mask ) );
end external_query_show;

function retrieve_pricing_value( parm_key in varchar2, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY_NMB )
 return number
as
begin
 for j in parm1.first..parm1.last loop
  if parm1(j) = parm_key then return( parm2(j) ); end if;
 end loop;
 return( NULL );
exception when others then return( NULL );
end retrieve_pricing_value;

function extract_purchase_value( vpoid in integer, parm_key in varchar2 )
 return number
as

 parm1	GLBX.MYARRAY;
 parm2	GLBX.MYARRAY_NMB;
 retval	number;

begin
 calculate_pricing( vpoid, parm1, parm2 );
 retval := retrieve_pricing_value( parm_key, parm1, parm2 );
 return( retval );
exception when others then return( NULL );
end extract_purchase_value;

procedure calculate_pricing( vpoid in integer, parm1 in out NOCOPY GLBX.MYARRAY, parm2 in out NOCOPY GLBX.MYARRAY_NMB )
as

 cursor c1(purchase_id integer, li varchar2) is
  select sum((nvl(photo_cost,0) + nvl(frame_cost,0) + nvl(alteration_cost,0)) * qty ) p1,
         sum(nvl(special_shipping,0)) p2,
         sum((nvl(photo_cost,0) * qty) * (nvl(decode( li, 'LOCAL', surcharge_local, surcharge_int ),0) / 100)) p3,
         sum(nvl(royalty_api,0)) p4,
         sum(nvl(price * (1 - (nvl(b2c_lab_discount,0)/100)),0) * qty) p5,
         sum((nvl(photo_cost,0) + nvl(frame_cost,0) + nvl(alteration_cost,0)) * qty * decode(upper(nvl(item_dispatched,'!')),'T',1,'Y',1,0)) item_disp_t,
         sum((nvl(photo_cost,0) + nvl(frame_cost,0) + nvl(alteration_cost,0)) * qty * decode(upper(nvl(item_dispatched,'!')),'F',1,'N',1,0)) item_disp_f,
         sum((nvl(photo_cost,0) + nvl(frame_cost,0) + nvl(alteration_cost,0)) * qty * decode(upper(nvl(item_dispatched,'!')),'!',1,0)) item_disp_n
  from shopping_basket
  where poid = purchase_id;

 cursor c2(vpoid integer) is select * from purchase_order where poid = vpoid;

 cursor c3(phgid integer) is
  select payment_style,charge_option1_royalty,charge_option1_discount,charge_option2_discount,lab_charge_perc
  from photographer ph,charge_plan cp
  where ph.plan_id = cp.id and
        ph.pid = phgid;

cursor c4(vpoid integer) is select sum(amount_used) sm from gift_certificate_usage where poid = vpoid;

cursor c5(vpoid integer) is select sum(nvl(chosen_price,0)) from purchase_additional_options where poid = vpoid;

 purchrec		c2%ROWTYPE;
 c3rec			c3%ROWTYPE;

 nmb1			number;
 nmb2			number;
 sub_total		number;
 sub_total1		number;
 total_special		number;
 total_surcharge	number;
 total_royalty_api	number;
 total_product_price    number;
 total_addopt		number;

 commission		number;
 postage		number;
 lab_postage		number;
 lab_extra_cost		number;
 gift_wrap		number;
 surcharge		number;
 gst			number;
 gst_value		number;
 gst_inclusive		number;
 item_dispatched_t	number;
 item_dispatched_f	number;
 item_dispatched_n	number;
 gst_item_dispatched_t	number;
 gst_item_dispatched_f	number;
 gst_item_dispatched_n	number;
 discount		number;
 special_discount	number;
 phg_discount		number;
 handling		number;
 certificate_total	number;
 grand_total_nocert	number;
 grand_total_withcert	number;
 admin_tax		number;
 lab_gets		number;
 photographer_gets	number;
 admin_gets		number;
 admin_gst		number;
 refund			number;

begin

 -- Extract Purchase Order Details
 open c2(vpoid);
 fetch c2 into purchrec;
 close c2;

 -- Extract Sub Total Details from Shopping Basket
 open c1(vpoid, purchrec.local_internation);
 fetch c1 into sub_total, total_special, total_surcharge, total_royalty_api, total_product_price, item_dispatched_t, item_dispatched_f, item_dispatched_n;
 close c1;

 open c3(purchrec.pid);
 fetch c3 into c3rec;
 close c3;

 sub_total1 := sub_total;
 phg_discount := nvl(purchrec.photographer_discount,0);
 special_discount := nvl(purchrec.special_discount,0);

 -- Apply Discount at Sub Total Stage
 if purchrec.apply_discount_at = 'S'
  then
   -- Discount (if price greater than value)
   nmb1 := sub_total1 * (phg_discount/100);
   discount := nmb1;
   sub_total1 := sub_total1 - nmb1;
   -- Special Discount as Identified by the Photographer in their order page
   nmb2 := sub_total1 * (special_discount/100);
   discount := discount + nmb2;
   sub_total1 := sub_total1 - nmb2;

   -- Extract Royalty Commission (after discount)
   commission := nvl(sub_total1 * nvl(c3rec.charge_option1_royalty / 100,0),0) + total_royalty_api;

 end if;

 -- Postage
 postage := nvl(purchrec.delivery_cost,0) + total_special;

 -- If manual shipping then there is no postage.
 if purchrec.manual_ship = 'T'
  then
   postage := 0;
   total_special := 0;
 end if;

 -- Lab Postage
 lab_postage := nvl(purchrec.mfctr_stnd_shipping,0);

 -- Gift Wrap xxx
 /*
 if (purchrec.is_gift = 'T') and (purchrec.wrap_gift = 'T')
  then
   gift_wrap := nvl(purchrec.wrap_cost,0);
  else
   gift_wrap := 0;
 end if;
 */
 -- Additional Options
 open c5(vpoid);
 fetch c5 into total_addopt;
 close c5;
 total_addopt := nvl(total_addopt,0);

 sub_total1 := sub_total1 + postage + total_addopt + total_surcharge;

 -- Apply Discount at Sub Total Stage
 if purchrec.apply_discount_at = 'P'
  then
   -- Discount (if price greater than value)
   nmb1 := sub_total1 * (phg_discount/100);
   discount := nmb1;
   sub_total1 := sub_total1 - nmb1;
   -- Special Discount as Identified by the Photographer in their order page
   nmb2 := sub_total1 * (special_discount/100);
   discount := discount + nmb2;
   sub_total1 := sub_total1 - nmb2;

   -- Extract Royalty Commission (after discount)
   commission := nvl(sub_total1 * nvl(c3rec.charge_option1_royalty / 100,0),0) + total_royalty_api;

 end if;

 -- Add GST
 if nvl( purchrec.gst_incl, 'F' ) = 'F'
  then
   -- GST to be added
   gst := nvl(purchrec.other_cost,0);
   if gst <> 0
    then
     gst_value := sub_total1 * (gst/100);
     gst_inclusive := 0;
     sub_total1 := sub_total1 + gst_value;
     gst_item_dispatched_t := item_dispatched_t * (gst/100);
     gst_item_dispatched_f := item_dispatched_f * (gst/100);
     gst_item_dispatched_n := item_dispatched_n * (gst/100);
   end if;

  else

   -- GST Inclusive
   gst := nvl(purchrec.other_cost,0);
   if gst <> 0
    then
     gst_value := 0;
     gst_inclusive := sub_total1 - ((sub_total1 * 100) / (100 + gst));
     gst_item_dispatched_t := gst_item_dispatched_t - ((gst_item_dispatched_t * 100) / (100 + gst));
     gst_item_dispatched_f := gst_item_dispatched_f - ((gst_item_dispatched_f * 100) / (100 + gst));
     gst_item_dispatched_n := gst_item_dispatched_n - ((gst_item_dispatched_n * 100) / (100 + gst));
   end if;
 end if;

 -- Apply Discount at Sub Total Stage
 if purchrec.apply_discount_at = 'F'
  then
   -- Discount (if price greater than value)
   nmb1 := sub_total1 * (phg_discount/100);
   discount := nmb1;
   sub_total1 := sub_total1 - nmb1;
   -- Special Discount as Identified by the Photographer in their order page
   nmb2 := sub_total1 * (special_discount/100);
   discount := discount + nmb2;
   sub_total1 := sub_total1 - nmb2;

   -- Extract Royalty Commission (after discount)
   commission := nvl(sub_total1 * nvl(c3rec.charge_option1_royalty / 100,0),0) + total_royalty_api;
 end if;

 commission := nvl(commission,0);

 grand_total_nocert := sub_total1;

 open c4(vpoid);
 fetch c4 into certificate_total;
 close c4;
 certificate_total := nvl(certificate_total,0);
 grand_total_withcert := grand_total_nocert - certificate_total;

 if purchrec.paid_method in ('MERCHANT','GIFT')
  then
   handling := grand_total_withcert * nvl(c3rec.lab_charge_perc / 100,0);
  else
   handling := 0;
 end if;

 lab_extra_cost := nvl(purchrec.mfctr_other_cost,0);
 lab_gets := lab_postage + lab_extra_cost + total_product_price;

 begin admin_gst := nvl( to_number(glbx.extract_master_parameter('COMMISSION_TAX')), 0); exception when others then admin_gst := 0; end;

 if commission > 0
  then
   -- GST Inclusive
   --admin_tax := commission - ((commission * 100) / (100 + admin_gst));
   if nvl( purchrec.gst_incl, 'F' ) = 'F'
    then
     admin_tax := commission * (admin_gst/100);
    else
     admin_tax := commission - ((commission * 100) / (100 + admin_gst));
   end if;
  else
   admin_tax := 0;
 end if;

 if nvl( purchrec.gst_incl, 'F' ) = 'F'
  then
   photographer_gets := grand_total_withcert - (handling + commission + lab_gets + admin_tax );
  else
   -- GST Inclusive
   photographer_gets := grand_total_withcert - (handling + commission + lab_gets );
 end if;

 admin_gets := grand_total_withcert - (photographer_gets + lab_gets );

 refund := nvl(purchrec.refund_total,0);

 -- Populate Return Array
 -- Add new entries to the end as programs might refer directly to the Array Entry Index number
 --
 parm1(1)  := 'SUB_TOTAL';             parm2(1) := sub_total;
 parm1(2)  := 'SUB_TOTAL1';            parm2(2) := sub_total1;
 parm1(3)  := 'TOTAL_SPECIAL';         parm2(3) := total_special;
 parm1(4)  := 'TOTAL_SURCHARGE';       parm2(4) := total_surcharge;
 parm1(5)  := 'TOTAL_ROYALTY_API';     parm2(5) := total_royalty_api;
 parm1(6)  := 'TOTAL_PRODUCT_PRICE';   parm2(6) := total_product_price;
 parm1(7)  := 'COMMISSION';            parm2(7) := commission;
 parm1(8)  := 'POSTAGE';               parm2(8) := postage;
 parm1(9)  := 'LAB_POSTAGE';           parm2(9) := lab_postage;
 parm1(10) := 'LAB_EXTRA_COST';        parm2(10) := lab_extra_cost;
 parm1(11) := 'GIFT_WRAP';             parm2(11) := gift_wrap;
 parm1(12) := 'SURCHARGE';             parm2(12) := surcharge;
 parm1(13) := 'GST';                   parm2(13) := gst;
 parm1(14) := 'GST_VALUE';             parm2(14) := gst_value;
 parm1(15) := 'DISCOUNT';              parm2(15) := discount; --$
 parm1(16) := 'PHG_DISCOUNT';          parm2(16) := phg_discount;  --%
 parm1(17) := 'HANDLING';              parm2(17) := handling;
 parm1(18) := 'CERTIFICATE_TOTAL';     parm2(18) := certificate_total;
 parm1(19) := 'GRAND_TOTAL_NOCERT';    parm2(19) := grand_total_nocert;
 parm1(20) := 'GRAND_TOTAL_WITHCERT';  parm2(20) := grand_total_withcert;
 parm1(21) := 'TAX'; 		       parm2(21) := admin_tax;
 parm1(22) := 'LAB_GETS';              parm2(22) := lab_gets;
 parm1(23) := 'PHOTOGRAPHER_GETS';     parm2(23) := photographer_gets;
 parm1(24) := 'GETS';    	       parm2(24) := admin_gets;
 parm1(25) := 'SPECIAL_DISCOUNT';      parm2(25) := special_discount;
 parm1(26) := 'REFUND'; 	       parm2(26) := refund;
 parm1(27) := 'GST_INCLUSIVE'; 	       parm2(27) := gst_inclusive;
 parm1(28) := 'ADMIN_ROYALTY'; 	       parm2(28) := nvl(c3rec.charge_option1_royalty,0);
 parm1(29) := 'ADMIN_GST';    	       parm2(29) := admin_gst;
 parm1(30) := 'HANDLING_PERC';         parm2(30) := nvl(c3rec.lab_charge_perc,0);
 parm1(31) := 'ADDITIONAL_OPTIONS';    parm2(31) := total_addopt;
 parm1(32) := 'ITEM_DISPATCHED_T';     parm2(32) := nvl(item_dispatched_t,0);
 parm1(33) := 'GST_ITEM_DISPATCHED_T'; parm2(33) := nvl(gst_item_dispatched_t,0);
 parm1(34) := 'ITEM_DISPATCHED_F';     parm2(34) := nvl(item_dispatched_f,0);
 parm1(35) := 'GST_ITEM_DISPATCHED_F'; parm2(35) := nvl(gst_item_dispatched_f,0);
 parm1(36) := 'ITEM_DISPATCHED_N';     parm2(36) := nvl(item_dispatched_n,0);
 parm1(37) := 'GST_ITEM_DISPATCHED_N'; parm2(37) := nvl(gst_item_dispatched_n,0);

exception
 when others then
 glbx.error_details( 'GLBX', 'CALCULATE_PRICING', errmsg=>sqlerrm, extdet=>'VPOID:' || vpoid );
end calculate_pricing;

function category_total( acid in integer, uscid in integer)
 return integer
as

 cursor c1(acid integer, uscid integer) is select count('x') tot from umo where aid = acid and umo_scene_id = uscid;
 c1rec	c1%ROWTYPE;

 begin
  open c1(acid,uscid);
  fetch c1 into c1rec;
  close c1;
  return( c1rec.tot );
 exception
  when others then return( c1rec.tot );
 end category_total;

procedure show_link( acid in integer, stype in integer, pfx in THEME%ROWTYPE, uscid in integer, showtotal in boolean, lnk in varchar2, txt in varchar2, cusloc in varchar2, istb in boolean default TRUE, aln in varchar2 default null, new_nested in varchar2 default null, bf131 in varchar2, apnd in varchar2 default null )
as

 nmb	integer;
 fnt	integer;
 vtxt	varchar2(1000);
 vstyl	varchar2(1000);

begin

 nmb := category_total(acid,uscid);
 fnt := 6 + nvl(pfx.anchor_font_adj,0) + trunc(stype/1.5);
 if to_char(uscid) = new_nested then htp.p( '<a href="#nested"></a>' ); end if;
 htp.p( apnd );

 vtxt := nvl(trim(txt),'&nbsp;');
 vstyl := 'STYLE="font-size: ' || fnt || 'pt; font-family: ' || pfx.anchor_text_font || '; font-style: ' || pfx.anchor_type || ';"';

 if nmb = 0
  then

   if (instr(apnd,'>',1,2) = length(apnd))
    then
     null;
    else
     htp.p(txt);
   end if;

  else

   if showtotal
    then
     if cusloc is null
      then
       if istb
        then
         htp.tabledata(htf.anchor(lnk, txt || ' - #' || to_char(nmb), cattributes=>vstyl), cattributes=>aln );
        else
         htp.anchor(lnk, txt || ' - #' || to_char(nmb), cattributes=>vstyl);
       end if;
      else
       if istb
        then
         htp.tabledata(htf.anchor2(lnk, txt || ' - #' || to_char(nmb), ctarget=>cusloc, cattributes=>vstyl), cattributes=>aln );
        else
         htp.anchor2(lnk, txt || ' - #' || to_char(nmb), ctarget=>cusloc, cattributes=>vstyl);
       end if;
     end if;
    else
     if cusloc is null
      then
       if istb
        then
         htp.tabledata(htf.anchor2(lnk, txt, cattributes=>vstyl), cattributes=>aln );
        else
         htp.anchor2(lnk, txt, cattributes=>vstyl);
       end if;
      else
       if istb
        then
         htp.tabledata(htf.anchor2(lnk, txt, ctarget=>cusloc, cattributes=>vstyl), cattributes=>aln );
        else
         htp.anchor2(lnk, txt, ctarget=>cusloc, cattributes=>vstyl);
       end if;
     end if;
   end if;
 end if;

end show_link;

/*
function cat_ttl(acid in integer, uscid in integer, showtotal in boolean )
 return varchar2
as
begin
 if not showtotal then return( NULL ); end if;
 return( ' - #' || to_char(category_total(acid,uscid)));
end cat_ttl;
*/

procedure show_public_accounts( photographer_id in integer, bgcolor in varchar2 default 'FFFFFF', style in varchar2 default 'URL',
                                title in varchar2 default null, justify in varchar2 default 'CENTER',
                                table_parm in varchar2 default NULL, table_data in varchar2 default NULL,
                                jobref in varchar2 default '%', disp_no_img in varchar2 default 'F', business_feature in varchar2 default '%',
                                instruction_text in varchar2 default null, bar_title in varchar2 default null, anchor in varchar2 default null,
                                returl in varchar2 default null, returl_display in varchar2 default null, number_links in varchar2 default null, rnd in varchar2 default null,
                                ctarget in varchar2 default '_top', html_page in varchar2 default null, subdir in varchar2 default null)
as

 cursor c1(photographer_id integer, jobref varchar2, bf varchar2) is
  select aid,username,account_name,photographer_account_id,event_logon_uses_code,site_type
  from customer_account
  where pid = photographer_id and
        (date_expires > sysdate or date_expires is null) and
        (public_account = 'T' or nvl(site_type,'S') <> 'S') and
        upper(theme_type) like bf and
        (upper(photographer_account_id) like jobref or photographer_account_id is null)
 union all
  select cp.aid,cp.username,cp.account_name,ca.photographer_account_id, ca.event_logon_uses_code, ca.site_type
  from customer_profile cp, customer_account ca
  where cp.pid = photographer_id and
        ca.aid = cp.aid and
        (cp.date_expires > sysdate or cp.date_expires is null) and
        (cp.public_account = 'T' or nvl(ca.site_type,'S') <> 'S') and
        upper(cp.theme_type) like bf and
        (upper(ca.photographer_account_id) like jobref or ca.photographer_account_id is null)
  order by 3;

 cursor c2(acid integer) is select umo_id from umo where aid = acid;

 c2rec		c2%ROWTYPE;
 foundrec	boolean;
 txt		varchar2(1000);
 fl 		UTL_FILE.FILE_TYPE;
 bfr		varchar2(25000);

begin
 if html_page is null
  then
   htp.htmlopen;
   if bar_title is not null then htp.title( bar_title ); end if;

   htp.p( '<BODY BGCOLOR="#' || bgcolor || '">' );
   if justify = 'CENTER'
    then
     htp.p( '<CENTER>' );
   end if;

   if title is not null
     then
      glbx.header_msg( title );
    end if;

   if instruction_text is not null
    then
     htp.p( instruction_text );
     htp.nl;
   end if;

  else
   begin
    if subdir is null
     then
      fl := utl_file.fopen( glbx.extract_master_parameter('IMAGE_DIR') || DECS.UNIX_OR_NT || 'order_style', html_page, 'r', 25000 );
     else
      fl := utl_file.fopen( glbx.extract_master_parameter('IMAGE_DIR') || DECS.UNIX_OR_NT || 'order_style' || DECS.UNIX_OR_NT || subdir, html_page, 'r', 25000 );
    end if;
   exception
    when others then
     --htp.p( glbx.extract_master_parameter('IMAGE_DIR') || DECS.UNIX_OR_NT || 'order_style' || DECS.UNIX_OR_NT || subdir ); htp.nl;
     htp.p( 'Error: Cannot find HTML Page:' || subdir || DECS.UNIX_OR_NT || html_page );
     return;
   end;
   loop
    begin
     utl_file.get_line( fl, bfr);
     if trim(upper(bfr)) = '<PICTION_PUBLIC_LOGIN>'
      then
       exit;
      else
       htp.p( bfr );
     end if;
    exception
     when others
      then
       utl_file.fclose( fl );
       return;
     end;
   end loop;

 end if;
 htp.tableopen( cattributes=>table_parm );
 for c1rec in c1( photographer_id, upper(jobref) || '%', upper(business_feature) || '%' ) loop
  foundrec := TRUE;
  if disp_no_img = 'F'
   then
    open c2(c1rec.aid);
    fetch c2 into c2rec;
    if c2%NOTFOUND then foundrec := FALSE; end if;
    close c2;
  end if;
  if upper(number_links) in ('T','TRUE')
   then
    txt := c2%ROWCOUNT || ': ' || c1rec.account_name;
   else
    txt := c1rec.account_name;
  end if;
  if foundrec
   then
    htp.tablerowopen;
    if style = 'URL' and nvl(c1rec.site_type,'S') = 'S'
     then
      htp.tabledata( htf.anchor2( 'glbx.accept_login?un=' || replace( c1rec.username,' ','+') || '&pw=' || '&rnd=' || to_char(sysdate,'SSSSS'), txt, ctarget=>ctarget, cattributes=>anchor),cattributes=>table_data);

    elsif nvl(c1rec.site_type,'S') <> 'S'
     then
      htp.p( '<TD ' || table_data || '>' );
      htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=0' );
      htp.formopen( 'glbx.accept_login', ctarget=>ctarget);
      htp.formhidden( 'RND', to_char(sysdate, 'SSSSS' ));
      if c1rec.event_logon_uses_code = 'F'
       then
        htp.formhidden( 'JOB', c1rec.photographer_account_id );
      end if;
      htp.tablerowopen;
       htp.tabledata( LNG.GLB_TXT_076 || ' ' || htf.formtext( 'UN', 5, 10 ) );
       htp.tabledata( LNG.GLB_TXT_018 || ' ' || htf.formpassword( 'PW', 5, 10 ) );
       htp.tabledata( htf.formsubmit( null, txt ));
      htp.tablerowclose;
      htp.formclose;
      htp.tableclose;
     htp.p( '</TD>' );

    elsif style = 'BUTTON' or nvl(c1rec.site_type,'S') <> 'S'
     then
      htp.p( '<TD ' || table_data || '>' );
      htp.formopen( 'glbx.accept_login', ctarget=>ctarget);
      htp.formhidden( 'RND', to_char(sysdate, 'SSSSS' ));
      htp.formhidden( 'UN', c1rec.username );
      htp.formhidden( 'PW', NULL );
      if c1rec.event_logon_uses_code = 'F'
       then
        htp.formhidden( 'JOB', c1rec.photographer_account_id );
      end if;
      htp.formsubmit( null, txt );
      htp.formclose;
     htp.p( '</TD>' );
    end if;
    htp.tablerowclose;
  end if;
 end loop;
 htp.tableclose;

 if returl is not null and returl_display is not null
  then
   htp.nl;
   htp.nl;
   htp.anchor( returl, returl_display, cattributes=>anchor );
 end if;

 if html_page is null
  then
   if justify = 'CENTER'
    then
     htp.p( '</CENTER>' );
   end if;
   htp.htmlclose;

  else
   loop
    begin
     utl_file.get_line( fl, bfr );
     htp.p( bfr );
    exception
     when others
      then
       utl_file.fclose( fl );
       return;
     end;
   end loop;

 end if;

exception
 when others then
  glbx.error_details( 'GLBX', 'SHOW_PUBLIC_ACCOUNTS', errmsg=>sqlerrm, extdet=>'PHOTOGRAPHER_ID:' || photographer_id);
end show_public_accounts;

procedure show_all_accounts( photographer_id in integer, bgcolor in varchar2 default 'FFFFFF', style in varchar2 default 'URL',
                             title in varchar2 default null, justify in varchar2 default 'CENTER',
                             table_parm in varchar2 default NULL, table_data in varchar2 default NULL,
                             jobref in varchar2 default '%', disp_no_img in varchar2 default 'F', business_feature in varchar2 default '%',
                             instruction_text in varchar2 default null, bar_title in varchar2 default null, anchor in varchar2 default null,
                             returl in varchar2 default null, returl_display in varchar2 default null, number_links in varchar2 default null, rnd in varchar2 default null,
                             ctarget in varchar2 default '_top', html_page in varchar2 default null, subdir in varchar2 default null)
as

 cursor c1(photographer_id integer, jobref varchar2, bf varchar2) is
  select aid,username,account_name,photographer_account_id,event_logon_uses_code,site_type,date_expires,public_account
  from customer_account
  where pid = photographer_id and
        (date_expires > sysdate or date_expires is null) and
        upper(theme_type) like bf and
        (upper(photographer_account_id) like jobref or photographer_account_id is null)
 union all
  select cp.aid,cp.username,cp.account_name,ca.photographer_account_id, ca.event_logon_uses_code, ca.site_type,cp.date_expires,cp.public_account
  from customer_profile cp, customer_account ca
  where cp.pid = photographer_id and
        ca.aid = cp.aid and
        (cp.date_expires > sysdate or cp.date_expires is null) and
        upper(cp.theme_type) like bf and
        (upper(ca.photographer_account_id) like jobref or ca.photographer_account_id is null)
  order by 3;

 cursor c2(acid integer) is select umo_id from umo where aid = acid;

 c2rec		c2%ROWTYPE;
 foundrec	boolean;
 txt		varchar2(1000);
 fl 		UTL_FILE.FILE_TYPE;
 bfr		varchar2(25000);

begin
 if html_page is null
  then
   htp.htmlopen;
   if bar_title is not null then htp.title( bar_title ); end if;

   htp.p( '<BODY BGCOLOR="#' || bgcolor || '">' );
   if justify = 'CENTER'
    then
     htp.p( '<CENTER>' );
   end if;

   if title is not null
     then
      glbx.header_msg( title );
    end if;

   if instruction_text is not null
    then
     htp.p( instruction_text );
     htp.nl;
   end if;

  else
   begin
    if subdir is null
     then
      fl := utl_file.fopen( glbx.extract_master_parameter('IMAGE_DIR') || DECS.UNIX_OR_NT || 'order_style', html_page, 'r', 25000 );
     else
      fl := utl_file.fopen( glbx.extract_master_parameter('IMAGE_DIR') || DECS.UNIX_OR_NT || 'order_style' || DECS.UNIX_OR_NT || subdir, html_page, 'r', 25000 );
    end if;
   exception
    when others then
     --htp.p( glbx.extract_master_parameter('IMAGE_DIR') || DECS.UNIX_OR_NT || 'order_style' || DECS.UNIX_OR_NT || subdir ); htp.nl;
     htp.p( 'Error: Cannot find HTML Page:' || subdir || DECS.UNIX_OR_NT || html_page );
     return;
   end;
   loop
    begin
     utl_file.get_line( fl, bfr);
     if trim(upper(bfr)) = '<PICTION_PUBLIC_LOGIN>'
      then
       exit;
      else
       htp.p( bfr );
     end if;
    exception
     when others
      then
       utl_file.fclose( fl );
       return;
     end;
   end loop;

 end if;

 htp.tableopen( cattributes=>table_parm );
 for c1rec in c1( photographer_id, upper(jobref) || '%', upper(business_feature) || '%' ) loop

  foundrec := TRUE;
  if disp_no_img = 'F'
   then
    open c2(c1rec.aid);
    fetch c2 into c2rec;
    if c2%NOTFOUND then foundrec := FALSE; end if;
    close c2;
  end if;

  if upper(number_links) in ('T','TRUE')
   then
    txt := c2%ROWCOUNT || ': ' || c1rec.account_name;
   else
    txt := c1rec.account_name;
  end if;
  if foundrec
   then
    htp.tablerowopen;
    if style = 'URL' and nvl(c1rec.site_type,'S') = 'S'
     then
      htp.tabledata( htf.anchor2( 'glbx.accept_login?un=' || replace( c1rec.username,' ','+') || '&pw=' || '&rnd=' || to_char(sysdate,'SSSSS'), txt, ctarget=>ctarget, cattributes=>anchor),cattributes=>table_data);

    elsif nvl(c1rec.site_type,'S') <> 'S'
     then
      if style <> 'URL' then htp.tabledata( initcap( nvl(txt, c1rec.username) ), cattributes=>table_data ); end if;
      htp.p( '<TD ' || table_data || '>' );
      htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=0' );
      htp.formopen( 'glbx.accept_login', ctarget=>ctarget);
      htp.formhidden( 'RND', to_char(sysdate, 'SSSSS' ));
      if c1rec.event_logon_uses_code = 'F'
       then
        htp.formhidden( 'JOB', c1rec.photographer_account_id );
      end if;
      htp.tablerowopen;
       htp.formhidden( 'UN', c1rec.username );
       htp.tabledata( LNG.GLB_TXT_018 || ' ' || htf.formpassword( 'PW', 5, 10 ) );
       htp.tabledata( htf.formsubmit( null, txt ));
      htp.tablerowclose;
      htp.formclose;
      htp.tableclose;
     htp.p( '</TD>' );

    elsif style in ('BUTTON','IMAGE') or nvl(c1rec.site_type,'S') <> 'S'
     then
      htp.tabledata( initcap( nvl(txt, c1rec.username) ), cattributes=>table_data );
      htp.p( '<TD ALIGN="CENTER" ' || table_data || ' >' );
      htp.formopen( 'glbx.accept_login', ctarget=>ctarget);
      htp.formhidden( 'RND', to_char(sysdate, 'SSSSS' ));
      htp.formhidden( 'UN', c1rec.username );
      htp.formhidden( 'PW', NULL );
      if c1rec.event_logon_uses_code = 'F'
       then
        htp.formhidden( 'JOB', c1rec.photographer_account_id );
      end if;
      if style = 'BUTTON'
       then
        htp.formsubmit( null, LNG.GLB_TXT_019 );
       else
        htp.formimage( 'Click_To_Login', DECS.IMAGE_LOCATION || 'admin/login.jpg',cattributes=>'BORDER="0"'  );
      end if;
      htp.formclose;
     htp.p( '</TD>' );
    end if;
    if c1rec.date_expires is null
     then
      htp.tabledata( '&nbsp;', cattributes=>table_data );
     else
      htp.tabledata( LNG.PHG_TXT_174 || ':' || to_char(c1rec.date_expires,LNG.MASK), cattributes=>table_data );
    end if;
    htp.tablerowclose;
  end if;
 end loop;
 htp.tableclose;
 if returl is not null and returl_display is not null
  then
   htp.nl;
   htp.nl;
   htp.anchor( returl, returl_display, cattributes=>anchor );
 end if;

 if html_page is null
  then
   if justify = 'CENTER'
    then
     htp.p( '</CENTER>' );
   end if;
   htp.htmlclose;

  else
   loop
    begin
     utl_file.get_line( fl, bfr );
     htp.p( bfr );
    exception
     when others
      then
       utl_file.fclose( fl );
       return;
     end;
   end loop;

 end if;

 htp.htmlclose;
exception
 when others then
  glbx.error_details( 'GLBX', 'SHOW_ALL_ACCOUNTS', errmsg=>sqlerrm, extdet=>'PHOTOGRAPHER_ID:' || photographer_id);
end show_all_accounts;

procedure noframe( surl in varchar2, called_from in varchar2 default null )
as
begin
 htp.anchor( replace(glbx.extract_master_parameter('FRAMES_NOT_SUPPORTED'),'~SURL',surl), LNG.GLB_TXT_029);
end noframe;

function meta_distinct_lov( lov_list in varchar2, value in varchar2, choose_distinct in boolean, indx in varchar2 default null )
 return varchar2
as

   cursor c1(v_umo integer, scat varchar2, utype varchar2 ) is
    select value
    from umo_attribute ua, umo_attributes u
    where ua.umo_id = v_umo and
          (u.umo_type = utype or u.umo_type = 'ALL' ) and
          u.attribute_id = ua.attribute_id and
          u.sub_category = scat
    order by position_id;

   c1rec		c1%ROWTYPE;
   ctr			integer;
   loc			integer;
   cursor_name		integer;
   dummy 		integer;
   col_count		integer;
   desc_t		dbms_sql.desc_tab;
   common_nmb		number;
   common_vc2		varchar2(4000);
   common_dte		date;
   str			varchar2(4000);
   tmpval		varchar2(4000);
   ltmpval		varchar2(4000);
   vtmpval		varchar2(4000);
   idxval		varchar2(4000);
   tmpval2		varchar2(32767);
   sqlstmt		varchar2(32767);

begin

   sqlstmt := lov_list;
   ctr := 1;
   /*
   loop
    loc := instr( sqlstmt,'<PICTION_PARAMETER=' );
    if nvl(loc,0) = 0 then exit; end if;
    str := substr(sqlstmt,loc+19,(instr(sqlstmt, '>', loc+19)-(loc+19)));
    open c1( v_umo,upper(str),utype);
    fetch c1 into c1rec;
    if c1%NOTFOUND
     then
      c1rec.value := NULL;
    end if;
    close c1;
    sqlstmt := replace(sqlstmt,'<PICTION_PARAMETER=' || str || '>',c1rec.value);
    ctr := ctr + 1;
    if ctr > 1000 then exit; end if; -- Inf Loop Protection
   end loop;
   */

   if choose_distinct
    then
     sqlstmt := 'select distinct ' || substr(sqlstmt,instr(sqlstmt,',')+1);
     sqlstmt := substr(sqlstmt,1,instr(sqlstmt,',')-1) ||
                substr(sqlstmt,instr(sqlstmt,' ',instr(sqlstmt,',')+1));
     cursor_name := dbms_sql.open_cursor;
     dbms_sql.parse( cursor_name, sqlstmt, dbms_sql.native );
     dbms_sql.describe_columns(cursor_name,col_count,desc_t);

     for j in 1..least(3,col_count) loop
      if desc_t(j).col_type in (1,96)
       then
        dbms_sql.define_column_char(cursor_name,j,common_vc2,desc_t(j).col_max_len);
      elsif desc_t(j).col_type = 2
       then
        dbms_sql.define_column(cursor_name,j,common_nmb);
      elsif desc_t(j).col_type = 12
       then
        dbms_sql.define_column(cursor_name,j,common_dte);
      end if;
     end loop;
     dummy := dbms_sql.execute( cursor_name );

     tmpval2 := NULL;
     ctr := 0;

     loop

       dummy := dbms_sql.fetch_rows(cursor_name);
       if dummy = 0 then exit; end if;
       ctr := ctr + 1;
       tmpval := NULL;
       for j in 1..least(3,col_count) loop
        common_vc2 := NULL;
        common_nmb := NULL;
        common_dte := NULL;
        if desc_t(j).col_type in (1,96)
         then
          dbms_sql.column_value_char(cursor_name,j,common_vc2);
          if j = 1 then tmpval := rtrim( common_vc2 ); end if;
         elsif desc_t(j).col_type = 2
          then
           dbms_sql.column_value(cursor_name,j,common_nmb);
           if j = 1 then tmpval := to_char( common_nmb ); end if;
         elsif desc_t(j).col_type = 12
          then
           dbms_sql.column_value(cursor_name,j,common_dte);
           if j = 1 then tmpval := to_char( common_dte, LNG.TSMASK ); end if;
        end if;
       end loop;
       if ctr > 1
        then
         tmpval2 := tmpval2 || ',';
       end if;
       tmpval2 := tmpval2 || '"' || tmpval || '"';
     end loop;

     dbms_sql.close_cursor( cursor_name );

    else

     cursor_name := dbms_sql.open_cursor;
     dbms_sql.parse( cursor_name, sqlstmt, dbms_sql.native );
     dbms_sql.describe_columns(cursor_name,col_count,desc_t);

     for j in 1..least(3,col_count) loop
      if desc_t(j).col_type in (1,96)
       then
        dbms_sql.define_column_char(cursor_name,j,common_vc2,desc_t(j).col_max_len);
      elsif desc_t(j).col_type = 2
       then
        dbms_sql.define_column(cursor_name,j,common_nmb);
      elsif desc_t(j).col_type = 12
       then
        dbms_sql.define_column(cursor_name,j,common_dte);
      end if;
     end loop;
     dummy := dbms_sql.execute( cursor_name );

     tmpval2 := NULL;
     ltmpval := NULL;
     tmpval := NULL;
     ctr := 0;
     loop
       dummy := dbms_sql.fetch_rows(cursor_name);
       if dummy = 0 then exit; end if;
       for j in 1..least(3,col_count) loop
        common_vc2 := NULL;
        common_nmb := NULL;
        common_dte := NULL;
        if desc_t(j).col_type in (1,96)
         then
          dbms_sql.column_value_char(cursor_name,j,common_vc2);
          if j = 1 then idxval := rtrim( common_vc2 ); end if;
          if j = 2 then tmpval := rtrim( common_vc2 ); end if;
          if j = 3 then vtmpval := rtrim( common_vc2 ); end if;
         elsif desc_t(j).col_type = 2
          then
           dbms_sql.column_value(cursor_name,j,common_nmb);
           if j = 1 then idxval := to_char( common_nmb ); end if;
           if j = 2 then tmpval := to_char( common_nmb ); end if;
           if j = 3 then vtmpval := to_char( common_nmb ); end if;
         elsif desc_t(j).col_type = 12
          then
           dbms_sql.column_value(cursor_name,j,common_dte);
           if j = 1 then idxval := to_char( common_dte, LNG.TSMASK ); end if;
           if j = 2 then tmpval := to_char( common_dte, LNG.TSMASK ); end if;
           if j = 3 then vtmpval := to_char( common_dte, LNG.TSMASK ); end if;
        end if;
       end loop;
       if ltmpval is null or (ltmpval is not null and ltmpval <> tmpval)
        then
         ctr := ctr + 1;
         if (ltmpval is not null and ltmpval <> tmpval)
          then
          tmpval2 := substr(tmpval2,1,length(tmpval2)-1) || ');';
         end if;
         tmpval2 := tmpval2 || indx || '[' || ctr || ']=new Array(';
       end if;
       ltmpval := tmpval;
       if indx = 'pages'
        then
         tmpval2 := tmpval2 || '"' || vtmpval || '",';
        else
         tmpval2 := tmpval2 || '"' || idxval || '",';
       end if;
     end loop;
     tmpval2 := substr(tmpval2,1,length(tmpval2)-1) || ');';
     dbms_sql.close_cursor( cursor_name );
 end if;

 return( tmpval2 );

exception
 when others then htp.p( sqlerrm ); return(null);
end meta_distinct_lov;

procedure external_file_load( surl in varchar2, file in varchar2, fdir in out varchar2, fname in out varchar2 )
as

  cursor c2(uname varchar2) is select blob_content from apache_ows_content where name = uname;

  v_umo 	integer;
  blb		blob;
  dm		integer;
  dump_dir	varchar2(1000);
  wait_seconds 	integer := 30;
  status 	integer;
  result 	integer;
  retsess	integer;
  sessid	integer;
  sts		varchar2(200);
  fl 		UTL_FILE.FILE_TYPE;
  bfr		varchar2( 32767 );

begin
   -- Retrieve the image from the Browser. First transfer it to the UMO table then call the C Program to download it. This means copying it from apache_ows_content to UMO and then deleting the whole thing. This generates a bit of Redo (if the file is big).
   -- It would be far better for large files to be transferred to the server via ftp.
   --ump.init(0,'TEMPORARY',v_umo);
   open c2(file);
   fetch c2 into blb;
   close c2;
   --update umo um set um.photo_master.source.localdata = blb where umo_id = v_umo;
   --commit;
   fdir := nvl(fdir,glbx.extract_master_parameter('REPORTS_DIRECTORY'));
   if substr( fdir, length(fdir),1) not in ('/','\') then fdir := fdir || DECS.UNIX_OR_NT; end if;
   fname := nvl(fname, 'external_file.txt');
   --select s_umo_sess.nextval into retsess from dual;
   /*
   dm := dbms_pipe.create_pipe('CPROG',8192,FALSE);
   dbms_output.put_line(dm);
   dbms_pipe.pack_message('DLOAD' || retsess);
   dbms_pipe.pack_message(v_umo);
   dbms_pipe.pack_message(0);
   dbms_pipe.pack_message(user); -- Schema Name
   dbms_pipe.pack_message(100);
   dbms_pipe.pack_message('WRITE');
   dbms_pipe.pack_message( fdir || fname );
   dbms_pipe.pack_message('MASTER');
   sts := dbms_pipe.send_message('CPROG',maxpipesize=>32767);
   commit;

   sts := dbms_pipe.receive_message('DLOAD' || retsess,wait_seconds);
   dbms_pipe.unpack_message(result);
   */

   utl_lob.unloadtofile(blb, fdir || fname, status);

   /*
   if result > 0
    then
     htp.bold( 'Error Extracting File to Directory: ' || result );
     delete from umo where umo_id = v_umo;
     delete from file_upload_metadata where filename = file;
     delete from apache_ows_content where name = file;
     commit;
     return;
   end if;
   */

   --delete from umo where umo_id = v_umo;
   delete from file_upload_metadata where filename = file;
   delete from apache_ows_content where name = file;
   commit;

exception
 when others then
  glbx.error_details( 'GLBX', 'EXTERNAL_FILE_LOAD', errmsg=>sqlerrm, extdet=>'FILE:' || file || ' FDIR:' || fdir || ' FNAME:' || fname );
end external_file_load;

procedure comma_delimited(bfr in varchar2, comma_delim out GLBX.MYARRAY, delimchar in char default ',')
as

 ctr	integer;
 pos	integer;
 lctr	integer;
 xctr	integer;
 delim	char(1);

begin
 if bfr is null then return; end if;

 ctr := 1;
 lctr := 0;
 xctr := 1;
 delim := delimchar;
 if substr(bfr,1,1) = '"'
   then
    delim := '"';
    lctr := 1;
 end if;

 loop
  pos := instr( bfr, delim, lctr+1, 1 );
  if pos = 0
   then
    if delim = '"'
     then
      comma_delim( xctr ) := substr(bfr,lctr+1);
      comma_delim( xctr ) := substr(comma_delim( xctr ),1,length(comma_delim( xctr ))-1);
     else
      comma_delim( xctr ) := substr(bfr,lctr+1);
    end if;
    exit;
  end if;

  comma_delim( xctr ) := substr(bfr, lctr+1, (pos - (lctr + 1)));

  if delim = '"'
   then
    delim := delimchar;
    pos := pos + 1;
    lctr := pos;
  end if;

  if delim = delimchar and substr(bfr,pos+1,1) = '"'
   then
    delim := '"';
    lctr := pos + 1;
  else
    lctr := pos;
  end if;

  ctr := ctr + 1;
  xctr := xctr + 1;
  if ctr > 1000 then exit; end if;
 end loop;

exception
 when others then
  glbx.error_details( 'GLBX', 'COMMA_DELIMITED', errmsg=>sqlerrm, extdet=>'BFR:' || bfr );
end comma_delimited;

procedure external_email( phgid in integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, option1 in GLBX.MYARRAY, option2 in GLBX.MYARRAY, submit in varchar2 default null )
as

 cursor c1(phgid integer) is select * from photographer where pid = phgid;
 c1rec	c1%ROWTYPE;

 gcode			GLBX.MYARRAY;
 gparam			GLBX.MYARRAY;

 sendto_email		varchar2(1000);
 from_email		varchar2(1000);
 subject_line		varchar2(1000);
 testsendto_email	varchar2(1000);
 template		varchar2(1000);
 returnto_url		varchar2(1000);
 return_title		varchar2(4000);
 return_body		varchar2(4000);
 sms_mobile		varchar2(1000);

begin
 -- Validate phgid integer
 open c1(phgid);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   htp.p( 'Invalid Access' );
   return;
 end if;
 close c1;

 -- Valid Options Include
 -- SENDTO_EMAIL
 -- FROM_EMAIL
 -- SUBJECT_LINE
 -- TESTSENDTO_EMAIL
 -- TEMPLATE
 sendto_email := c1rec.contact_email;
 template := lower(c1rec.username) || '.tmp';
 from_email := sendto_email;
 subject_line := 'Enquiry';

 for j in option1.first..option1.last loop
  if upper(option1(j)) = 'SENDTO_EMAIL' then sendto_email := option2(j);
  elsif upper(option1(j)) = 'FROM_EMAIL' then from_email := option2(j);
  elsif upper(option1(j)) = 'SUBJECT_LINE' then subject_line := option2(j);
  elsif upper(option1(j)) = 'TESTSENDTO_EMAIL' then testsendto_email := option2(j);
  elsif upper(option1(j)) = 'TEMPLATE' then template := option2(j);
  elsif upper(option1(j)) = 'RETURNTO_URL' then returnto_url := option2(j);
  elsif upper(option1(j)) = 'RETURN_TITLE' then return_title := option2(j);
  elsif upper(option1(j)) = 'RETURN_BODY' then return_body := option2(j);
  elsif upper(option1(j)) = 'SMS_MOBILE' then sms_mobile := option2(j);
  end if;
 end loop;
 testsendto_email := nvl(testsendto_email,sendto_email);
 from_email := nvl(from_email,sendto_email);

 -- Prefil in subject line template
 for j in p1.first..p1.last loop
  subject_line := replace(subject_line, '<' || upper(p1(j)) || '>', p2(j) );
  gcode(j) := upper(p1(j));
  gparam(j) := p2(j);
 end loop;

 if upper(p2(1)) = 'TEST'
  then
   sendto_email := testsendto_email;
 end if;

 glbx.send( gcode, gparam, template, p_to=>sendto_email, p_subj=>subject_line, p_from=>from_email );

 if sms_mobile is not null
  then
   glbx.send( gcode, gparam, null, p_to=>sms_mobile || '@' || glbx.extract_master_parameter('SMS_SITE'),p_subj=>subject_line,p_from=>from_email,  is_sms=>TRUE);
 end if;

 if returnto_url is null
  then
   htp.htmlopen;
   htp.header(2, nvl(return_title,'Thank You For Your Booking Enquiry'), 'CENTER' );
   htp.header(3, nvl(return_body,'Our friendly staff will contact you regarding your Arrangements shortly.'), 'CENTER' );
   htp.htmlclose;
  else
   owa_util.redirect_url( returnto_url );
 end if;

exception
 when others then
  glbx.error_details( 'GLBX', 'EXTERNAL_EMAIL', errmsg=>sqlerrm );
end external_email;

procedure dbg( vinf in varchar2, vsurl in varchar2 default null, vproc in varchar2 default null )
as
begin
 if DBG_CTR is null then delete from debug; commit;DBG_CTR := 0; end if;
 DBG_CTR := DBG_CTR + 1;
 insert into debug(surl, tm, proc, inf, ctr ) values (vsurl, sysdate, vproc, vinf, DBG_CTR );
 commit;
 htp.p( DBG_CTR || ':' || vinf || '-' || vproc ); htp.nl;
exception
 when others then null;
end dbg;

function quality_loop( p1 in varchar2, existing_value in varchar2 default null, show_hdr_ftr in boolean default TRUE)
 return varchar2
as
 tmp	varchar2(32767);
begin
    if show_hdr_ftr then tmp := htf.formselectopen( p1 ); else tmp := NULL; end if;
    if '1' = existing_value then tmp := tmp || htf.formselectoption( '1', 'SELECTED' ); else tmp := tmp || htf.formselectoption( '1' ); end if;
    if '1.2' = existing_value then tmp := tmp || htf.formselectoption( '1.2', 'SELECTED' ); else tmp := tmp || htf.formselectoption( '1.2' ); end if;
    if '1.4' = existing_value then tmp := tmp || htf.formselectoption( '1.4', 'SELECTED' ); else tmp := tmp || htf.formselectoption( '1.4' ); end if;
    if '1.6' = existing_value then tmp := tmp || htf.formselectoption( '1.6', 'SELECTED' ); else tmp := tmp || htf.formselectoption( '1.6' ); end if;
    if '1.8' = existing_value then tmp := tmp || htf.formselectoption( '1.8', 'SELECTED' ); else tmp := tmp || htf.formselectoption( '1.8' ); end if;
    if '2' = existing_value then tmp := tmp || htf.formselectoption( '2', 'SELECTED' ); else tmp := tmp || htf.formselectoption( '2' ); end if;
    if '2.5' = existing_value then tmp := tmp || htf.formselectoption( '2.5', 'SELECTED' ); else tmp := tmp || htf.formselectoption( '2.5' ); end if;
    if '3' = existing_value then tmp := tmp || htf.formselectoption( '3', 'SELECTED' ); else tmp := tmp || htf.formselectoption( '3' ); end if;
    if '4' = existing_value then tmp := tmp || htf.formselectoption( '4', 'SELECTED' ); else tmp := tmp || htf.formselectoption( '4' ); end if;
    if '5' = existing_value then tmp := tmp || htf.formselectoption( '5', 'SELECTED' ); else tmp := tmp || htf.formselectoption( '5' ); end if;
    if '6' = existing_value then tmp := tmp || htf.formselectoption( '6', 'SELECTED' ); else tmp := tmp || htf.formselectoption( '6' ); end if;
    if '7' = existing_value then tmp := tmp || htf.formselectoption( '7', 'SELECTED' ); else tmp := tmp || htf.formselectoption( '7' ); end if;
    if '8' = existing_value then tmp := tmp || htf.formselectoption( '8', 'SELECTED' ); else tmp := tmp || htf.formselectoption( '8' ); end if;
   if show_hdr_ftr then tmp := tmp || htf.formselectclose; end if;
   return( tmp );
end quality_loop;

function get_login_application( sess_id in integer, keyval in varchar2 )
 return varchar2
as
 cursor c1(sess_id integer) is select application_parameters from login_session where sessid = sess_id;
 c1rec  c1%ROWTYPE;
 x	integer;
 y	integer;
begin
 open c1(sess_id);
 fetch c1 into c1rec;
 close c1;
 x := instr( c1rec.application_parameters, '[' || keyval );
 if x = 0 then return( NULL ); end if;
 x := x + length('[' || keyval || ':' );
 y := instr( c1rec.application_parameters, ']', x );
 return( substr( c1rec.application_parameters, x, (y-x) ) );
end get_login_application;

function update_login_application( sess_id in integer, keyval in varchar2, newval in varchar2 )
 return boolean
as
 cursor c1(sess_id integer) is select application_parameters from login_session where sessid = sess_id;
 c1rec  c1%ROWTYPE;
 x	integer;
 y	integer;
 z	integer;
begin
 open c1(sess_id);
 fetch c1 into c1rec;
 close c1;
 x := instr( c1rec.application_parameters, '[' || keyval );
 if x = 0
  then
   update login_session
    set
     application_parameters = application_parameters || '[' || keyval || ':' || newval || ']'
   where
    sessid = sess_id;
   commit;
   return( TRUE );
 end if;

 z := x + length('[' || keyval || ':' ) + 1;
 y := instr( c1rec.application_parameters, ']', z );

 update login_session
  set
   application_parameters = substr(application_parameters,1,x-1) || '[' || keyval || ':' || newval || ']' || substr(application_parameters,y+1)
 where
  sessid = sess_id;
 commit;

 return( TRUE );
end update_login_application;

procedure meta_handle_query_action(surl in varchar2, acid in integer, sess_id in integer, ltype in varchar2, action in varchar2, qmode in char, file in varchar2, pUmoId in integer, lUmoId in out integer, currno in integer, recno out integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY )
as

   cursor c2(cUmoId integer) is select umo_type,umo_scene_id from umo where umo_id = cUmoId;

   c2rec 		c2%ROWTYPE;
   cusrec		customer_account%ROWTYPE;
   parm1	      	ump.parameters;
   parm2		ump.parameters;
   profid		integer;
   vltype		varchar2(100);
   retval		varchar2(1000);
   newid_arr		ump.myarray_int;

begin

   if qmode = 'T'
    then
      glbx.meta_query_perform( surl, acid, sess_id, ltype, p1, p2, p3 );
      glbx.meta_query_navigate( surl, acid, curr_umo=>NULL, navigate_option=>'START', next_umo=>lUmoId, currno=>currno, recno=>recno );

   elsif Action = '>' -- Move to Next Record
    then
      lUmoId := pUmoId;
      glbx.meta_query_navigate( surl, acid, curr_umo=>lUmoId, navigate_option=>'NEXT', next_umo=>lUmoId, currno=>currno, recno=>recno );

   elsif Action = '*>' -- Move to Next Record
    then
      lUmoId := pUmoId;
      phg.meta_tload(surl, acid, file, p1, p2, p3, lUmoId, null);
      glbx.meta_query_navigate( surl, acid, curr_umo=>lUmoId, navigate_option=>'NEXT', next_umo=>lUmoId, currno=>currno, recno=>recno );

   elsif Action = '<' -- Move to Next Record
    then
      lUmoId := pUmoId;
      glbx.meta_query_navigate( surl, acid, curr_umo=>lUmoId, navigate_option=>'PREVIOUS', next_umo=>lUmoId, currno=>currno, recno=>recno );

   elsif Action = '<*' -- Move to Next Record
    then
      lUmoId := pUmoId;
      phg.meta_tload(surl, acid, file, p1, p2, p3, lUmoId, null);
      glbx.meta_query_navigate( surl, acid, curr_umo=>lUmoId, navigate_option=>'PREVIOUS', next_umo=>lUmoId, currno=>currno, recno=>recno );

   elsif Action = '|-' -- Move to First Record
    then
      lUmoId := pUmoId;
      glbx.meta_query_navigate( surl, acid, curr_umo=>lUmoId, navigate_option=>'START', next_umo=>lUmoId, currno=>currno, recno=>recno );

   elsif Action = '|-*' -- Move to First Record
    then
      lUmoId := pUmoId;
      phg.meta_tload(surl, acid, file, p1, p2, p3, lUmoId, null);
      glbx.meta_query_navigate( surl, acid, curr_umo=>lUmoId, navigate_option=>'PREVIOUSSET', next_umo=>lUmoId, currno=>currno, recno=>recno );

   elsif Action = '<<' -- Move to Next Record
    then
      lUmoId := pUmoId;
      glbx.meta_query_navigate( surl, acid, curr_umo=>lUmoId, navigate_option=>'PREVIOUSSET', next_umo=>lUmoId, currno=>currno, recno=>recno );

   elsif Action = '<<*' -- Move to Next Record
    then
      lUmoId := pUmoId;
      phg.meta_tload(surl, acid, file, p1, p2, p3, lUmoId, null);
      glbx.meta_query_navigate( surl, acid, curr_umo=>lUmoId, navigate_option=>'START', next_umo=>lUmoId, currno=>currno, recno=>recno );

   elsif Action = '>>' -- Move to Next Set Record
    then
      lUmoId := pUmoId;
      glbx.meta_query_navigate( surl, acid, curr_umo=>lUmoId, navigate_option=>'NEXTSET', next_umo=>lUmoId, currno=>currno, recno=>recno );

   elsif Action = '*>>' -- Move to Next Set Record
    then
      lUmoId := pUmoId;
      phg.meta_tload(surl, acid, file, p1, p2, p3, lUmoId, null);
      glbx.meta_query_navigate( surl, acid, curr_umo=>lUmoId, navigate_option=>'NEXTSET', next_umo=>lUmoId, currno=>currno, recno=>recno );

   elsif Action = '-|' -- Move to Last Record
    then
      lUmoId := pUmoId;
      glbx.meta_query_navigate( surl, acid, curr_umo=>lUmoId, navigate_option=>'LAST', next_umo=>lUmoId, currno=>currno, recno=>recno );

   elsif Action = '*-|' -- Move to Last Record
    then
      lUmoId := pUmoId;
      phg.meta_tload(surl, acid, file, p1, p2, p3, lUmoId, null);
      glbx.meta_query_navigate( surl, acid, curr_umo=>lUmoId, navigate_option=>'LAST', next_umo=>lUmoId, currno=>currno, recno=>recno );

   elsif Action = '-' -- Insert Mode
    then
      lUmoId := null;

   elsif Action = '*-*' -- Insert Mode
    then
      lUmoId := pUmoId;
      phg.meta_tload(surl, acid, file, p1, p2, p3, lUmoId, null);
      lUmoId := null;

   elsif Action = LNG.PHG_BUT_116 -- Modify Image Details
     then
      if file is not null
       then
        --
        -- Upload file
        --
        --lUmoId := reloadImage(surl, acid, file, pUmoId);
        vltype := ltype;
        cusrec := glbx.get_cusrec(sess_id, vltype, null, profid);
        open c2(pUmoId);
        fetch c2 into c2rec;
        close c2;

        parm1.delete;
        parm2.delete;
        parm1(1) := 'UMO_ID';
        parm2(1) := to_char(pUmoId);
        parm1(2) := 'AID';
        parm2(2) := to_char(cusrec.aid);
        parm1(3) := 'OBJECT_TYPE';
        parm2(3) := c2rec.umo_type;
        parm1(4) := 'KEEP_STATUS';
        if pUmoId is null
         then
          parm2(4) := 'KEEP';
         else
          parm2(4) := 'LOAD AGAIN';
        end if;
        parm1(5) := 'OWS_NAME';
        parm2(5) := file;
        parm1(6) := 'LOAD_FROM_FILE_OR_UPLOAD';
        parm2(6) := 'UPLOAD';
        parm1(7) := 'ORIGINAL_LOCATION';
        parm2(7) := 'REPLACE';
        parm1(8) := 'BYPASS_QUOTA_CHECK';
        parm2(8) := 'FALSE';
        parm1(9) := 'CREATE_THUMBNAIL';
        parm2(9) := 'TRUE';
        parm1(10) := 'THUMBNAIL_WIDTH';
        parm2(10) := nvl(glbx.photo_pref(cusrec.pid, cusrec.aid, 'THUMBNAIL_WIDTH'), '100');
        parm1(11) := 'THUMBNAIL_QUALITY';
        parm2(11) := nvl(glbx.photo_pref(cusrec.pid, cusrec.aid, 'SUPER_THB'), '1');
        parm1(12) := 'PHGR_ID';
        parm2(12) := to_char(cusrec.pid);
        parm1(13) := 'STORE_ORIGINAL';
        parm2(13) := 'FALSE';
        parm1(14) := 'RELOAD_PHOTO';
        parm2(14) := 'T';

        --ump.load_uma(pSURL, parm1, parm2, retval, new_umo_id);
        ump.load_uma(surl, parm1, parm2, retval, newid_arr);
        if pUmoId is null then lUmoId := newid_arr(1); else lUmoId := pUmoId; end if;

      else
         lUmoId := null;

      end if;
      lUmoId := nvl(lUmoId, pUmoId);
      phg.meta_tload(surl, acid, file, p1, p2, p3, lUmoId, null);

   end if;

end meta_handle_query_action;

function auto_file_type( v_filename in varchar2 )
 return varchar2
as

 cursor c1( ext varchar2 ) is select count('x') cnt from extensible_formats where upper(file_extension) = upper( ext );

 c1rec		c1%ROWTYPE;
 ext		varchar2(100);
 api		varchar2(1000);
 retbool	char(1);
 tchar		char(1);
begin

 -- First Test if a Photo (hardcoded in)
  ext := upper(glbx.extract_fname( v_filename, 'SUFFIX' ));
  if ext in ('JPG','TIFF','TIF','BMP','GIF','ZIP') then return( 'PHOTO' );  end if;

 if mydocument.document_api ( v_filename ) = 'T' then return( 'DOCUMENT' ); end if;
 if myvideo.video_api ( v_filename ) = 'T' then return( 'VIDEO' ); end if;
 if myaudio.audio_api ( v_filename ) = 'T' then return( 'AUDIO' ); end if;
 if myblueprint.blueprint_api ( v_filename ) = 'T' then return( 'BLUEPRINT' ); end if;

 -- Test if Image Magick or NConvert File Type
 open c1( ext );
 fetch c1 into c1rec;
 close c1;
 if c1rec.cnt > 0 then return( 'PHOTO' );  end if;

 -- No Relational Test
 return( 'PHOTO' );

exception
 when others then
  glbx.error_details( 'GLBX', 'AUTO_FILE_TYPE', errmsg=>sqlerrm, extdet=>'V_FILENAME:' || v_filename );
  return( 'PHOTO' );
end auto_file_type;

function find_nmb( val in varchar2 )
  return integer
 is

  x	integer;
  y	integer;
  tmp	varchar2(1000);

 begin

  x := instr(val,'1');
  y := instr(val,'2');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(val,'3');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(val,'4');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(val,'5');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(val,'6');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(val,'7');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(val,'8');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(val,'9');
  if not((y = 0) or (y > x)) then x := y; end if;
  if x = 0 then return( NULL ); end if;
  tmp := substr(val,x);

  x := instr(tmp,'.');
  y := instr(tmp,';');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(tmp,'-');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(tmp,',');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(tmp,'[');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(tmp,'{');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(tmp,'<');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(tmp,'(');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(tmp,'*');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(tmp,'+');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(tmp,'@');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(tmp,'$');
  if not((y = 0) or (y > x)) then x := y; end if;
  for j in 65..90 loop
   y := instr(tmp,chr(j));
   if not((y = 0) or (y > x)) then x := y; end if;
  end loop;
  for j in 97..122 loop
   y := instr(tmp,chr(j));
   if not((y = 0) or (y > x)) then x := y; end if;
  end loop;
  tmp := substr(tmp,1,x-1);

  begin
   y := to_number(tmp);
   return( y );
  exception
   when others then return( NULL );
  end;

exception
 when others then return( NULL );
end find_nmb;

function match_password( value1 in varchar2, value2 in varchar2 )
 return boolean
as
begin
 if value1 is null and value2 is null then return( TRUE );
 elsif value1 is null and value2 is not null then return( FALSE );
 elsif value1 is not null and value2 is null then return( FALSE );
 else return( value1 = value2 );
 end if;
exception
 when others then
  glbx.error_details( 'GLBX', 'MATCH_PASSWORD', errmsg=>sqlerrm );
end match_password;

procedure file_listing( start_directory in varchar2, include_subdirs in boolean, load_using_file boolean default FALSE, fname in varchar2 default null, fdir in varchar2 default null, rsess in out varchar2, error_message out varchar2 )
as

 cursor c1( rsess varchar2, ftype char ) is
  select rowid,id,fname,fsize,file_type,directory_name,full_path
  from dir_results
  where id = rsess and
        full_path is null and
        file_type = ftype
  order by decode(file_type,'F',1,'D',2), fname;

 fl		UTL_FILE.FILE_TYPE;
 fl2		UTL_FILE.FILE_TYPE;
 result 	integer;
 wait_seconds	integer := 10;
 tot		integer;
 dm		integer;
 fsz		integer;
 bfr		varchar2(1000);
 rsess2		varchar2(100);
 sts		varchar2(200);
 bsts		boolean;

begin

 -- This routine will extract file names from a directory, including directories and load them into the DIR_RESULTS table
 -- It will also load file names extracted from a file

 -- Initialise Key to the Table
 if rsess is null
  then
   select s_umo_sess.nextval into rsess from dual;
 end if;

 if load_using_file
  then
   begin
    fl := utl_file.fopen( fdir, fname, 'r' );
   exception
    when others then
     error_message := 'Unable to Find File' || ':' || fdir || DECS.UNIX_OR_NT || fname;
   end;
   loop
    begin
     utl_file.get_line(fl,bfr);
     begin
       fl2 := utl_file.fopen( fdir, trim(bfr), 'r' );
       utl_file.fclose( fl2 );
       fsz := 1; -- set to 1 so that it will trigger a load
     exception when others then fsz := null;
     end;
     insert into dir_results(uniqueid,id,fname,fsize,file_type,directory_name,full_path) values
      (s_dir_results.nextval,rsess,trim(bfr),fsz,'F',glbx.extract_fname(start_directory,'PWD'),glbx.extract_fname(start_directory,'PWD') || trim(bfr));
     exception when others then exit;
    end;
   end loop;
   commit;
   utl_file.fclose( fl );
   return;
 end if;

 bsts := ump.directory_listing(start_directory, rsess );

 for c1rec in c1(rsess,'F') loop
  update dir_results
    set
     full_path = glbx.extract_fname(start_directory,'PWD') || c1rec.fname
   where
    rowid = c1rec.rowid;
 end loop;
 delete from dir_results where (fname in ('.','..') or fname is null) and id = rsess;
 if include_subdirs
  then
   select s_umo_sess.nextval into rsess2 from dual;

   bsts := ump.directory_listing(glbx.extract_fname(start_directory,'PWD') || '*', rsess2 );
   -- Recursive Loop
   delete from dir_results where (fname in ('.','..') or fname is null) and id = rsess2;
   for c1rec in c1(rsess2, 'D') loop
     file_listing(glbx.extract_fname(start_directory,'PWD') ||
                  c1rec.fname ||
                  DECS.UNIX_OR_NT ||
                  glbx.extract_fname(start_directory,'NO_EXTENSION') || '.' ||
                  glbx.extract_fname(start_directory,'SUFFIX'),
                  include_subdirs,
                  load_using_file,
                  fname,
                  fdir,
                  rsess,
                  error_message);

     insert into dir_results(uniqueid,id,fname,fsize,file_type,directory_name,full_path) values
      (s_dir_results.nextval,rsess,c1rec.fname,c1rec.fsize,'D',c1rec.directory_name,glbx.extract_fname(start_directory,'PWD') || c1rec.fname);

   end loop;
   delete from dir_results where id = rsess2;

 end if;

 commit;

exception
 when others then
  error_message := sqlerrm;
  glbx.error_details( 'GLBX', 'FILE_LISTING', errmsg=>sqlerrm );
end file_listing;

-- A variety of overloaded procedures to make it flexible to call
procedure portlet( pid in varchar2, name in varchar2 )
as
 phgid 	integer;
 p1	GLBX.MYARRAY;
 p2	GLBX.MYARRAY;
begin
 begin phgid := pid; exception when others then phgid := NULL; end;
 p1(1) := NULL;
 p2(1) := NULL;
 core_portlet( phgid, name, p1, p2 );
end portlet;

procedure portlet( pid in varchar2, name in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
as
 phgid 	integer;
begin
 begin phgid := pid; exception when others then phgid := NULL; end;
 core_portlet( phgid, name, p1, p2 );
end portlet;

procedure portlet( photographer_id in varchar2, portlet_name in varchar2 )
as
 phgid 	integer;
 p1	GLBX.MYARRAY;
 p2	GLBX.MYARRAY;
begin
 begin phgid := photographer_id; exception when others then phgid := NULL; end;
 p1(1) := NULL;
 p2(1) := NULL;
 core_portlet( phgid, portlet_name, p1, p2 );
end portlet;

procedure portlet( photographer_id in varchar2, portlet_name in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
as
 phgid 	integer;
begin
 begin phgid := photographer_id; exception when others then phgid := NULL; end;
 core_portlet( phgid, portlet_name, p1, p2 );
end portlet;

procedure portlet( username in varchar2, name in varchar2 )
as
 cursor c1(uname varchar2) is select pid from photographer where upper(username) = upper(uname);
 c1rec	c1%ROWTYPE;
 phgid 	integer;
 p1	GLBX.MYARRAY;
 p2	GLBX.MYARRAY;
begin
 open c1(username);
 fetch c1 into phgid;
 close c1;
 p1(1) := NULL;
 p2(1) := NULL;
 core_portlet( phgid, name, p1, p2 );
end portlet;

procedure portlet( username in varchar2, name in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
as
 cursor c1(uname varchar2) is select pid from photographer where upper(username) = upper(uname);
 c1rec	c1%ROWTYPE;
 phgid 	integer;
begin
 open c1(username);
 fetch c1 into phgid;
 close c1;
 core_portlet( phgid, name, p1, p2 );
end portlet;

procedure core_portlet( phgid in integer, pname in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
as

 cursor c1(phgid integer, pname varchar2) is select * from portlet_definition where pid = phgid and upper(name) = pname;
 cursor c2(portid integer) is select * from portlet_login where portlet_id = portid;
 cursor c3(phgid integer, acctname varchar2, uname varchar2, jobref varchar2, bftr varchar2, expired char, disabled char, ispublic char ) is
  select *
  from customer_account
  where pid = phgid and
        ( (acctname is null) or ((acctname is not null) and (upper(account_name) like acctname))) and
        ( (uname is null) or ((uname is not null) and (upper(username) like uname))) and
        ( (jobref is null) or ((jobref is not null) and (upper(photographer_account_id) like jobref)) or ((jobref is not null) and (photographer_account_id is null)) ) and
        ( (bftr is null) or ((bftr is not null) and (upper(theme_type) like bftr))) and
        ( (expired = 'T') or ((expired='F') and (nvl(date_expires,sysdate+1) > sysdate))) and
        ( (disabled = 'T') or ((disabled='F') and (customer_disabled = 'T'))) and
        ( (ispublic = 'T') or ((ispublic='F') and (public_account = 'T')))
  order by acctname;
 cursor c4(acid integer) is select count('x') tot from umo um where aid= acid and umo_type in ('PHOTO','DOCUMENT','AUDIO','VIDEO','RELATIONAL','BLUEPRINT');
 cursor c5(acid integer) is select * from customer_account where aid = acid;
 cursor c6(portid integer) is select * from portlet_send_query where portlet_id = portid;
 cursor c7(portid integer) is select * from portlet_news where portlet_id = portid;

 c1rec	c1%ROWTYPE;
 c2rec	c2%ROWTYPE;
 c4rec	c4%ROWTYPE;
 c6rec	c6%ROWTYPE;
 c7rec	c7%ROWTYPE;
 cusrec c5%ROWTYPE;
 ctr	integer;
 cell	varchar2(1000);

begin
 open c1(phgid, trim(upper(pname)));
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   htp.bold( LNG5.EXT_TXT_718 || ':' || phgid || '-' || pname );
   return;
 end if;
 close c1;
 if nvl(c1rec.is_enabled,'F') = 'F' then htp.bold( 'Portlet is Disabled' ); return; end if;

 if c1rec.portlet_type = 'LOGIN'
  then
   open c2(c1rec.portlet_id);
   fetch c2 into c2rec;
   if c2%NOTFOUND
    then
     close c2;
     htp.bold( LNG5.EXT_TXT_718 || ':' || phgid || '-' || pname || '-' || c1rec.portlet_id );
    return;
   end if;
   close c2;
 elsif c1rec.portlet_type = 'SEND QUERY'
  then
   open c6(c1rec.portlet_id);
   fetch c6 into c6rec;
   if c6%NOTFOUND
    then
     close c6;
     htp.bold( LNG5.EXT_TXT_718 || ':' || phgid || '-' || pname || '-' || c1rec.portlet_id );
    return;
   end if;
   close c6;
   core_send_query( phgid, pname, p1, p2, c1rec, c6rec );
 elsif c1rec.portlet_type in ('NEWS','CUSTOMERS','QUICKNEWS')
  then
   open c7(c1rec.portlet_id);
   fetch c7 into c7rec;
   if c7%NOTFOUND
    then
     close c7;
     htp.bold( LNG5.EXT_TXT_718 || ':' || phgid || '-' || pname || '-' || c1rec.portlet_id );
    return;
   end if;
   close c7;
   core_news( phgid, pname, p1, p2, c1rec, c7rec );
 end if;

 -- Replace Overwritten Parameters
 for j in p1.first..p1.last loop
  if upper(p1(j)) = 'STYLE' then c2rec.style := upper(p2(j)); end if;
  if upper(p1(j)) = 'BACKGROUND_COLOUR' then c2rec.BACKGROUND_COLOUR := upper(p2(j)); end if;
  if upper(p1(j)) = 'BACKGROUND_IMAGE' then c2rec. BACKGROUND_IMAGE := upper(p2(j)); end if;
  if upper(p1(j)) = 'BACKGROUND_EXT' then c2rec.BACKGROUND_EXT := upper(p2(j)); end if;
  if upper(p1(j)) = 'BAR_TITLE' then c2rec.BAR_TITLE := upper(p2(j)); end if;
  if upper(p1(j)) = 'HEADER_TITLE' then c2rec.HEADER_TITLE := upper(p2(j)); end if;
  if upper(p1(j)) = 'JUSTIFY' then c2rec.JUSTIFY := upper(p2(j)); end if;
  if upper(p1(j)) = 'DISPLAY_COLUMNHEADER' then c2rec.DISPLAY_COLUMNHEADER := upper(p2(j)); end if;
  if upper(p1(j)) = 'DISPLAY_CTR' then c2rec.DISPLAY_CTR := upper(p2(j)); end if;
  if upper(p1(j)) = 'DISPLAY_ACCTNAME' then c2rec.DISPLAY_ACCTNAME := upper(p2(j)); end if;
  if upper(p1(j)) = 'DISPLAY_USERNAME' then c2rec.DISPLAY_USERNAME := upper(p2(j)); end if;
  if upper(p1(j)) = 'DISPLAY_DATEHELD' then c2rec.DISPLAY_DATEHELD := upper(p2(j)); end if;
  if upper(p1(j)) = 'DISPLAY_NUMBIMAGES' then c2rec.DISPLAY_NUMBIMAGES := upper(p2(j)); end if;
  if upper(p1(j)) = 'DISPLAY_ENABLED' then c2rec.DISPLAY_ENABLED := upper(p2(j)); end if;
  if upper(p1(j)) = 'DISPLAY_SEARCH' then c2rec. DISPLAY_SEARCH := upper(p2(j)); end if;
  if upper(p1(j)) = 'TABLE_PARM' then c2rec.TABLE_PARM := upper(p2(j)); end if;
  if upper(p1(j)) = 'TABLE_DATA' then c2rec.TABLE_DATA := upper(p2(j)); end if;
  if upper(p1(j)) = 'TABLE_DATA_ALT' then c2rec.TABLE_DATA_ALT := upper(p2(j)); end if;
  if upper(p1(j)) = 'SEARCH_USERNAME' then c2rec.SEARCH_USERNAME := upper(p2(j)); end if;
  if upper(p1(j)) = 'SEARCH_ACCTNAME' then c2rec.SEARCH_ACCTNAME := upper(p2(j)); end if;
  if upper(p1(j)) = 'SEARCH_JOBREF' then c2rec.SEARCH_JOBREF := upper(p2(j)); end if;
  if upper(p1(j)) = 'SEARCH_BUS_FTR' then c2rec.SEARCH_BUS_FTR := upper(p2(j)); end if;
  if upper(p1(j)) = 'SEARCH_DISP_NO_IMG' then c2rec.SEARCH_DISP_NO_IMG := upper(p2(j)); end if;
  if upper(p1(j)) = 'SEARCH_INCL_EXPIRED' then c2rec.SEARCH_INCL_EXPIRED := upper(p2(j)); end if;
  if upper(p1(j)) = 'SEARCH_INCL_DISABLED' then c2rec.SEARCH_INCL_DISABLED := upper(p2(j)); end if;
  if upper(p1(j)) = 'SEARCH_ISPUBLIC' then c2rec.SEARCH_ISPUBLIC := upper(p2(j)); end if;
  if upper(p1(j)) = 'ANCHOR_FONT' then c2rec.ANCHOR_FONT := upper(p2(j)); end if;
  if upper(p1(j)) = 'ANCHOR_COLOUR' then c2rec.ANCHOR_COLOUR := upper(p2(j)); end if;
  if upper(p1(j)) = 'ANCHOR_PITCH' then c2rec.ANCHOR_PITCH := upper(p2(j)); end if;
  if upper(p1(j)) = 'TEXT_FONT' then c2rec.TEXT_FONT := upper(p2(j)); end if;
  if upper(p1(j)) = 'TEXT_COLOUR' then c2rec.TEXT_COLOUR := upper(p2(j)); end if;
  if upper(p1(j)) = 'TEXT_PITCH' then c2rec.TEXT_PITCH := upper(p2(j)); end if;
  if upper(p1(j)) = 'RETURL' then c2rec.RETURL := upper(p2(j)); end if;
  if upper(p1(j)) = 'RETURL_DISPLAY' then c2rec.RETURL_DISPLAY := upper(p2(j)); end if;
  if upper(p1(j)) = 'RETURL_IS_GIF' then c2rec.RETURL_IS_GIF := upper(p2(j)); end if;
  if upper(p1(j)) = 'INSTRUCTION_TEXT_HDR' then c2rec.INSTRUCTION_TEXT_HDR := upper(p2(j)); end if;
  if upper(p1(j)) = 'INSTRUCTION_TEXT_FTR' then c2rec.INSTRUCTION_TEXT_FTR := upper(p2(j)); end if;
  if upper(p1(j)) = 'TITLE_CTR' then c2rec.TITLE_CTR := upper(p2(j)); end if;
  if upper(p1(j)) = 'TITLE_ACCTNAME' then c2rec.TITLE_ACCTNAME := upper(p2(j)); end if;
  if upper(p1(j)) = 'TITLE_USERNAME' then c2rec.TITLE_USERNAME := upper(p2(j)); end if;
  if upper(p1(j)) = 'TITLE_DATEHELD' then c2rec.TITLE_DATEHELD := upper(p2(j)); end if;
  if upper(p1(j)) = 'TITLE_NUMBIMAGES' then c2rec.TITLE_NUMBIMAGES := upper(p2(j)); end if;
  if upper(p1(j)) = 'TITLE_SEARCH' then c2rec.TITLE_SEARCH := upper(p2(j)); end if;
  if upper(p1(j)) = 'TITLE_ENABLED' then c2rec.TITLE_ENABLED := upper(p2(j)); end if;
  if upper(p1(j)) = 'JAVASCRIPT_CODE' then c2rec.JAVASCRIPT_CODE  := upper(p2(j)); end if;
  if upper(p1(j)) = 'HEADER_COLOUR' then c2rec.header_colour  := upper(p2(j)); end if;
  if upper(p1(j)) = 'HEADER_FONT_COLOUR' then c2rec.header_font_colour  := upper(p2(j)); end if;
  if upper(p1(j)) = 'CELL_COLOUR' then c2rec.cell_colour  := upper(p2(j)); end if;
  if upper(p1(j)) = 'CELL_COLOUR_ALT' then c2rec.cell_colour_alt  := upper(p2(j)); end if;
  if upper(p1(j)) = 'POS_CTR' then c2rec.pos_ctr  := upper(p2(j)); end if;
  if upper(p1(j)) = 'POS_ACCTNAME' then c2rec.pos_acctname  := upper(p2(j)); end if;
  if upper(p1(j)) = 'POS_USERNAME' then c2rec.pos_username  := upper(p2(j)); end if;
  if upper(p1(j)) = 'POS_DATEHELD' then c2rec.pos_dateheld  := upper(p2(j)); end if;
  if upper(p1(j)) = 'POS_NUMBIMAGES' then c2rec.pos_numbimages  := upper(p2(j)); end if;
  if upper(p1(j)) = 'POS_SEARCH' then c2rec.pos_search  := upper(p2(j)); end if;
  if upper(p1(j)) = 'POS_ENABLED' then c2rec.pos_enabled  := upper(p2(j)); end if;
  if upper(p1(j)) = 'TARGET' then c2rec.target  := upper(p2(j)); end if;
  if upper(p1(j)) = 'RETURL_TARGET' then c2rec.returl_target  := upper(p2(j)); end if;
  if upper(p1(j)) = 'SUBMIT_TEXT' then c2rec.submit_text  := upper(p2(j)); end if;
 end loop;

 htp.htmlopen;
 htp.p( '<HEAD>' );
 htp.title( c2rec.bar_title );
 if c2rec.javascript_code is not null then htp.p( c2rec.javascript_code ); end if;
 htp.p( '</HEAD>' );
 if c2rec.background_image is null
  then
   htp.p( '<BODY BGCOLOR=#' || c2rec.background_colour || ' ' || c2rec.background_ext || '>' );
  else
   htp.p( '<BODY BACKGROUND="/site_specific/' || c2rec.background_image || '" ' || c2rec.background_ext || '>' );
 end if;
 htp.p( '<' || nvl(c2rec.justify,'CENTER') || '>' );
 if c2rec.header_title is not null
  then
   htp.header(2, c2rec.header_title, 'CENTER' );
 end if;

 if c2rec.instruction_text_hdr is not null
  then
   htp.p( c2rec.instruction_text_hdr );
   htp.nl;
 end if;

 ctr := 0;
 htp.tableopen( cattributes=>c2rec.table_parm );
 if c2rec.display_columnheader = 'T'
  then
   cell := 'style="text-align: center; ' || 'background-color: #' || c2rec.header_colour || '; font-size: ' || c2rec.text_pitch || '; font-family: ''' || c2rec.text_font || '''; color: #' || c2rec.header_font_colour  || '"' || c2rec.table_data;
   htp.tablerowopen;
    for j in 1..7 loop
     if c2rec.display_ctr = 'T' and nvl(c2rec.pos_ctr,1) = j then htp.tabledata( c2rec.title_ctr, cattributes=>cell ); end if;
     if c2rec.display_acctname = 'T' and nvl(c2rec.pos_acctname,1) = j then htp.tabledata( c2rec.title_acctname, cattributes=>cell ); end if;
     if c2rec.display_username = 'T' and nvl(c2rec.pos_username,1) = j then htp.tabledata( c2rec.title_username, cattributes=>cell ); end if;
     if c2rec.display_dateheld = 'T' and nvl(c2rec.pos_dateheld,1) = j then htp.tabledata( c2rec.title_dateheld, cattributes=>cell ); end if;
     if c2rec.display_numbimages = 'T' and nvl(c2rec.pos_numbimages,1) = j then htp.tabledata( c2rec.title_numbimages, cattributes=>cell ); end if;
     if c2rec.display_enabled = 'T' and nvl(c2rec.pos_enabled,1) = j then htp.tabledata( c2rec.title_enabled, cattributes=>cell ); end if;
     if c2rec.display_search = 'T' and nvl(c2rec.pos_search,1) = j and c2rec.style = 'BUTTON' then htp.tabledata( c2rec.title_search, cattributes=>cell ); end if;
    end loop;
    if c2rec.style = 'BUTTON' then htp.tabledata( '&nbsp;', cattributes=>cell ); end if; -- Submit Button
   htp.tablerowclose;
 end if;

 for c3rec in c3(phgid, upper(c2rec.search_acctname) || '%', upper(c2rec.search_username) || '%', upper(c2rec.search_jobref) || '%', upper(c2rec.search_bus_ftr) || '%', nvl(upper(c2rec.search_incl_expired),'F'), nvl(upper(c2rec.search_incl_disabled),'F'), nvl(upper(c2rec.search_ispublic),'F')) loop

  open c5(c3rec.aid);
  fetch c5 into cusrec;
  close c5;

  c4rec.tot := 0;
  open c4(c3rec.aid);
  fetch c4 into c4rec;
  close c4;
  if (c2rec.search_disp_no_img = 'F') or ( (c2rec.search_disp_no_img = 'T') and (c4rec.tot > 0) )
   then
    ctr := ctr + 1;
    -- Display Row
    if mod(ctr,2) = 1
     then
      cell := 'style="text-align: left; ' || 'background-color: #' || c2rec.cell_colour || '; font-size: ' || c2rec.text_pitch || '; font-family: ''' || c2rec.text_font || '''; color: #' || c2rec.text_colour  || '"' || c2rec.table_data;
     else
      cell := 'style="text-align: left; ' || 'background-color: #' || c2rec.cell_colour_alt || '; font-size: ' || c2rec.text_pitch || '; font-family: ''' || c2rec.text_font || '''; color: #' || c2rec.text_colour  || '"' || c2rec.table_data_alt;
    end if;

   htp.tablerowopen;
    for j in 1..7 loop
     if c2rec.display_ctr = 'T' and nvl(c2rec.pos_ctr,1) = j then htp.tabledata( to_char(ctr), cattributes=>cell ); end if;

     if c2rec.display_acctname = 'T' and nvl(c2rec.pos_acctname,1) = j
      then

       if c2rec.style = 'URL'
        then
         if nvl(cusrec.site_type,'S') = 'S'
          then
           htp.tabledata( htf.anchor2( 'glbx.accept_login?un=' || replace( c3rec.username,' ','+') || '&pw=' || '&rnd=' || to_char(sysdate,'SSSSS'),c3rec.account_name, ctarget=>c2rec.target, cattributes=>'style="font-size: ' || c2rec.anchor_pitch || '; font-family: ''' || c2rec.anchor_font || '''; color: #' || c2rec.anchor_colour  || '"'), cattributes=>cell );
          elsif cusrec.event_logon_uses_code = 'F'
           then
            htp.tabledata( htf.anchor2( 'glbx.accept_login?un=' || replace( c3rec.username,' ','+') || '&pw=' || '&job=' || replace(cusrec.photographer_account_id,' ','+') || '&rnd=' || to_char(sysdate,'SSSSS'),c3rec.account_name, ctarget=>c2rec.target, cattributes=>'style="font-size: ' || c2rec.anchor_pitch || '; font-family: ''' || c2rec.anchor_font || '''; color: #' || c2rec.anchor_colour  || '"'), cattributes=>cell );
          else
           htp.tabledata( htf.anchor2( 'glbx.accept_login?un=' || replace( c3rec.username,' ','+') || '&pw=' || '&rnd=' || to_char(sysdate,'SSSSS'),c3rec.account_name, ctarget=>c2rec.target, cattributes=>'style="font-size: ' || c2rec.anchor_pitch || '; font-family: ''' || c2rec.anchor_font || '''; color: #' || c2rec.anchor_colour  || '"'), cattributes=>cell );
         end if;

        else -- Button

         if nvl(cusrec.site_type,'S') = 'S'
          then
           htp.tabledata( htf.formopen( 'glbx.accept_login', ctarget=>c2rec.target ) || htf.formhidden( 'UN', c3rec.username ) || htf.formhidden( 'RND', to_char(sysdate,'SSSSS')) || htf.formhidden( 'PW', NULL ) || c3rec.account_name, cattributes=>cell );
          elsif cusrec.event_logon_uses_code = 'F'
           then
            htp.tabledata( htf.formopen( 'glbx.accept_login', ctarget=>c2rec.target ) || htf.formhidden( 'JOB', cusrec.photographer_account_id ) || htf.formhidden( 'UN', c3rec.username ) || htf.formhidden( 'RND', to_char(sysdate,'SSSSS')) || c3rec.account_name|| ' ' || htf.formpassword( 'PW', 5, 10 ), cattributes=>cell );
          else
           htp.tabledata( htf.formopen( 'glbx.accept_login', ctarget=>c2rec.target ) || htf.formhidden( 'UN', c3rec.username ) || htf.formhidden( 'RND', to_char(sysdate,'SSSSS')) || c3rec.account_name|| ' ' || htf.formpassword( 'PW', 5, 10 ), cattributes=>cell );
         end if;
       end if;

     end if;

     if c2rec.display_username = 'T' and nvl(c2rec.pos_username,1) = j then htp.tabledata( c3rec.username, cattributes=>cell ); end if;
     if c2rec.display_dateheld = 'T' and nvl(c2rec.pos_dateheld,1) = j then htp.tabledata( nvl(c3rec.date_held,'&nbsp;'), cattributes=>cell ); end if;
     if c2rec.display_numbimages = 'T' and nvl(c2rec.pos_numbimages,1) = j then htp.tabledata( c4rec.tot, cattributes=>cell ); end if;
     if c2rec.display_enabled = 'T' and nvl(c2rec.pos_enabled,1) = j
      then
       if (c3rec.customer_disabled = 'T')
        then
          htp.tabledata( LNG5.EXT_TXT_719, cattributes=>cell );
       elsif (c3rec.date_expires is not null) and (c3rec.date_expires < sysdate )
        then
          htp.tabledata( LNG5.EXT_TXT_720 || ' ' || to_char(c3rec.date_expires,LNG.MASK), cattributes=>cell );
       elsif (c3rec.date_expires is not null)
        then
          htp.tabledata( LNG5.EXT_TXT_721 || ' ' || to_char(c3rec.date_expires,LNG.MASK), cattributes=>cell );
       else
        htp.tabledata( '&nbsp;', cattributes=>cell );
       end if;
     end if;
     if c2rec.display_search = 'T' and nvl(c2rec.pos_search,1) = j
      then
       if c2rec.style = 'BUTTON'
        then
         htp.tabledata( htf.formtext( 'SIMPLESEARCH', 20, 100 ), cattributes=>cell );
       end if;
     end if;
    end loop;
    if c2rec.style = 'BUTTON'
     then
      htp.tabledata( htf.formsubmit( null, c2rec.submit_text ) || htf.formclose, cattributes=>cell );
    end if;
   htp.tablerowclose;

  end if;
 end loop;
 htp.tableclose;

 if c2rec.returl is not null
  then
   htp.nl;
   if c2rec.returl_is_gif is null
    then
     htp.anchor2( c2rec.returl, c2rec.returl_display, ctarget=>c2rec.returl_target );
    else
     htp.anchor2( c2rec.returl, htf.img( '/site_specific/' || c2rec.returl_display, cattributes=>'BORDER=0 '), ctarget=>c2rec.returl_target );
   end if;
 end if;

 if c2rec.instruction_text_ftr is not null
  then
   htp.nl;
   htp.p( c2rec.instruction_text_ftr );
 end if;

 htp.p( '</' || nvl(c2rec.justify,'CENTER') || '>' );
 htp.p( '</BODY>' );
 htp.htmlclose;
exception
 when others then htp.p( 'Error in Portlet:' || sqlerrm );
end core_portlet;

procedure core_send_query( phgid in integer, pname in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, c1rec in portlet_definition%ROWTYPE, c6rec in out portlet_send_query%ROWTYPE )
as

 cursor c3(portid integer) is select * from portlet_send_query_cols where portlet_id = portid order by order_by;
 cursor c4(portid integer) is select template_name from portlet_send_query_cols where portlet_id = portid and data_type = 'Char (Mandatory)';

 comma_delim 	GLBX.MYARRAY;
 ctr		integer;
 cell		varchar2(1000);
 tmp		varchar2(32767);

function mandatory_exists(portid integer)
 return boolean
as
 cursor c1(portid integer) is select 'x' tot from portlet_send_query_cols where portlet_id = portid and data_type = 'Char (Mandatory)';
 c1rec c1%ROWTYPE;
begin
 open c1(portid);
 fetch c1 into c1rec;
 if c1%NOTFOUND then close c1; return( FALSE ); end if;
 close c1;
 return( TRUE );
end mandatory_exists;

begin

 -- Replace Overwritten Parameters
 for j in p1.first..p1.last loop
  if upper(p1(j)) = 'STYLE' 		   then c6rec.style := upper(p2(j)); end if;
  if upper(p1(j)) = 'BACKGROUND_COLOUR'    then c6rec.BACKGROUND_COLOUR := upper(p2(j)); end if;
  if upper(p1(j)) = 'BACKGROUND_IMAGE'     then c6rec.BACKGROUND_IMAGE := upper(p2(j)); end if;
  if upper(p1(j)) = 'BACKGROUND_EXT'       then c6rec.BACKGROUND_EXT := upper(p2(j)); end if;
  if upper(p1(j)) = 'BAR_TITLE'            then c6rec.BAR_TITLE := upper(p2(j)); end if;
  if upper(p1(j)) = 'HEADER_TITLE'         then c6rec.HEADER_TITLE := upper(p2(j)); end if;
  if upper(p1(j)) = 'JUSTIFY'              then c6rec.JUSTIFY := upper(p2(j)); end if;
  if upper(p1(j)) = 'TABLE_PARM'           then c6rec.TABLE_PARM := upper(p2(j)); end if;
  if upper(p1(j)) = 'TABLE_DATA'           then c6rec.TABLE_DATA := upper(p2(j)); end if;
  if upper(p1(j)) = 'TABLE_DATA_ALT'       then c6rec.TABLE_DATA_ALT := upper(p2(j)); end if;
  if upper(p1(j)) = 'TEXT_FONT'            then c6rec.TEXT_FONT := upper(p2(j)); end if;
  if upper(p1(j)) = 'TEXT_COLOUR'          then c6rec.TEXT_COLOUR := upper(p2(j)); end if;
  if upper(p1(j)) = 'TEXT_PITCH'           then c6rec.TEXT_PITCH := upper(p2(j)); end if;
  if upper(p1(j)) = 'HEADER_COLOUR'        then c6rec.HEADER_COLOUR := upper(p2(j)); end if;
  if upper(p1(j)) = 'HEADER_FONT_COLOUR'   then c6rec.HEADER_FONT_COLOUR := upper(p2(j)); end if;
  if upper(p1(j)) = 'CELL_COLOUR'          then c6rec.CELL_COLOUR := upper(p2(j)); end if;
  if upper(p1(j)) = 'CELL_COLOUR_ALT'      then c6rec.CELL_COLOUR_ALT := upper(p2(j)); end if;
  if upper(p1(j)) = 'RETURL'               then c6rec.RETURL := upper(p2(j)); end if;
  if upper(p1(j)) = 'RETURL_DISPLAY'       then c6rec.RETURL_DISPLAY := upper(p2(j)); end if;
  if upper(p1(j)) = 'RETURL_IS_GIF'        then c6rec.RETURL_IS_GIF := upper(p2(j)); end if;
  if upper(p1(j)) = 'INSTRUCTION_TEXT_HDR' then c6rec.INSTRUCTION_TEXT_HDR := upper(p2(j)); end if;
  if upper(p1(j)) = 'INSTRUCTION_TEXT_FTR' then c6rec.INSTRUCTION_TEXT_FTR := upper(p2(j)); end if;
  if upper(p1(j)) = 'TARGET'               then c6rec.TARGET := upper(p2(j)); end if;
  if upper(p1(j)) = 'RETURL_TARGET'        then c6rec.RETURL_TARGET := upper(p2(j)); end if;
  if upper(p1(j)) = 'SUBMIT_TEXT'          then c6rec.SUBMIT_TEXT := upper(p2(j)); end if;
  if upper(p1(j)) = 'RESET_SUBMIT_TEXT'    then c6rec.RESET_SUBMIT_TEXT := upper(p2(j)); end if;
  if upper(p1(j)) = 'EMAIL_FIELD_IS'       then c6rec.EMAIL_FIELD_IS := upper(p2(j)); end if;
  if upper(p1(j)) = 'TEMPLATE'             then c6rec.TEMPLATE := upper(p2(j)); end if;
  if upper(p1(j)) = 'AUTO_CUST_TEMPLATE'   then c6rec.AUTO_CUST_TEMPLATE := upper(p2(j)); end if;
  if upper(p1(j)) = 'SENDTO'               then c6rec.SENDTO := upper(p2(j)); end if;
  if upper(p1(j)) = 'ON_SUBMIT_PAGE'       then c6rec.ON_SUBMIT_PAGE := upper(p2(j)); end if;
  if upper(p1(j)) = 'SUBMIT_PAGE_TEXT'     then c6rec.SUBMIT_PAGE_TEXT := upper(p2(j)); end if;
  if upper(p1(j)) = 'JAVASCRIPT_CODE'      then c6rec.JAVASCRIPT_CODE := upper(p2(j)); end if;
 end loop;

 htp.htmlopen;
 htp.p( '<HEAD>' );
 htp.title( c6rec.bar_title );
 if c6rec.javascript_code is not null then htp.p( c6rec.javascript_code ); end if;
 if mandatory_exists(c1rec.portlet_id)
  then
htp.p( '
 <SCRIPT LANGUAGE="JavaScript">
<!--
function valid(form)
{
  for (var j = 0; j < document.form.length; ++j)
  {
   var tempobj=form.elements[j]
   if (tempobj.name == "P1" && tempobj.value != "")
   {
    if ( ' );

for c4rec in c4(c1rec.portlet_id) loop
  tmp := tmp || '|| ' || 'tempobj.value == "' || c4rec.template_name || '" ';
end loop;
htp.p( substr(tmp,3) );

htp.p( ')
     {
      var tempobj2=form.elements[j+1]
      if (tempobj2.value == "") {alert( "' || c6rec.mandatory_text || '" + tempobj.value); return false;}
     }
   }
  }
}
// -->
</SCRIPT>
 ' );
end if;

 htp.p( '</HEAD>' );
 if c6rec.background_image is null
  then
   htp.p( '<BODY BGCOLOR=#' || c6rec.background_colour || ' ' || c6rec.background_ext || '>' );
  else
   htp.p( '<BODY BACKGROUND="/site_specific/' || c6rec.background_image || '" ' || c6rec.background_ext || '>' );
 end if;
 htp.p( '<' || nvl(c6rec.justify,'CENTER') || '>' );
 if c6rec.header_title is not null
  then
   htp.header(2, c6rec.header_title, 'CENTER' );
 end if;

 if c6rec.instruction_text_hdr is not null
  then
   htp.p( c6rec.instruction_text_hdr );
   htp.nl;
 end if;

 if c6rec.target is null
  then
   if mandatory_exists( c1rec.portlet_id )
    then
     htp.formopen( 'glbx.portlet_send', cattributes=>' name=form onSubmit="return valid(this)"' );
    else
     htp.formopen( 'glbx.portlet_send' );
   end if;
  else
   if mandatory_exists( c1rec.portlet_id )
    then
     htp.formopen( 'glbx.portlet_send', ctarget=>c6rec.target, cattributes=>' name=form onSubmit="return valid(this)"' );
    else
     htp.formopen( 'glbx.portlet_send', ctarget=>c6rec.target );
   end if;
 end if;
 htp.formhidden( 'PORTID', c1rec.portlet_id );
 htp.formhidden( 'P1', null );
 htp.formhidden( 'P2', null );
 htp.formhidden( 'P3', null );

 ctr := 0;
 htp.tableopen( cattributes=>c6rec.table_parm );
 for c3rec in c3( c1rec.portlet_id ) loop
   ctr := ctr + 1;
   -- Display Row
   if mod(ctr,2) = 1
   then
     cell := 'style="text-align: left; ' || 'background-color: #' || nvl(c3rec.cell_colour,c6rec.cell_colour) || '; font-size: ' || nvl(c3rec.text_pitch,c6rec.text_pitch) || '; font-family: ''' || nvl(c3rec.text_font,c6rec.text_font) || '''; color: #' || nvl(c3rec.text_colour,c6rec.text_colour)  || '"' || c6rec.table_data;
    else
     cell := 'style="text-align: left; ' || 'background-color: #' || nvl(c3rec.cell_colour,c6rec.cell_colour_alt) || '; font-size: ' || nvl(c3rec.text_pitch,c6rec.text_pitch) || '; font-family: ''' || nvl(c3rec.text_font,c6rec.text_font) || '''; color: #' || nvl(c3rec.text_colour,c6rec.text_colour)  || '"' || c6rec.table_data_alt;
   end if;
   htp.tablerowopen;
    htp.tabledata( c3rec.display_name, cattributes=>cell );
    htp.p( '<TD ' || cell || '>' );
    if c3rec.data_type not in ( 'Checkbox', 'Checkbox (Checked)' ) then htp.formhidden( 'P1', c3rec.template_name ); end if;
    if c3rec.data_type in ('Character','Char (Mandatory)')
     then
      htp.formtext('P2',c3rec.field_width,c3rec.field_width,c3rec.default_value);
    elsif c3rec.data_type in ('List of Values','List (Mandatory)')
     then
      comma_delimited( c3rec.lov_values, comma_delim );
      if comma_delim.count > 0
       then
        htp.formselectopen( 'P2' );
        if c3rec.data_type = 'List of Values'
         then
          htp.formselectoption( NULL );
        end if;
        for j in comma_delim.first..comma_delim.last loop
         htp.formselectoption( comma_delim(j) );
        end loop;
        htp.formselectclose;
       else
        htp.formhidden( 'P2', c3rec.default_value );
      end if;
    elsif c3rec.data_type = 'Text Box'
     then
      htp.formtextareaopen( 'P2', c3rec.field_height, c3rec.field_width, cattributes=>'WRAP="VIRTUAL"' );
      htp.p( c3rec.default_value );
      htp.formtextareaclose;
    elsif c3rec.data_type = 'Checkbox'
     then
      htp.formcheckbox( 'P3', c3rec.template_name );
    elsif c3rec.data_type = 'Checkbox (Checked)'
     then
      htp.formcheckbox( 'P3', c3rec.template_name, 'CHECKED' );
    end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
 end loop;
 htp.tableclose;

 htp.nl;
 htp.formsubmit( 'ACTION', c6rec.submit_text );
 if c6rec.reset_submit_text is not null
  then
   htp.p( '<input type="RESET" name="' || c6rec.reset_submit_text || '">' );
 end if;
 htp.formclose;
 htp.nl;
 if c6rec.returl is not null
  then
   htp.nl;
   if c6rec.returl_is_gif is null
    then
     htp.anchor2( c6rec.returl, c6rec.returl_display, ctarget=>c6rec.returl_target );
    else
     htp.anchor2( c6rec.returl, htf.img( '/site_specific/' || c6rec.returl_display, cattributes=>'BORDER=0 '), ctarget=>c6rec.returl_target );
   end if;
 end if;

 if c6rec.instruction_text_ftr is not null
  then
   htp.nl;
   htp.p( c6rec.instruction_text_ftr );
 end if;

 htp.p( '</' || nvl(c6rec.justify,'CENTER') || '>' );
 htp.p( '</BODY>' );
 htp.htmlclose;
exception
 when others then htp.p( 'Error in Portlet:' || sqlerrm );
end core_send_query;

procedure portlet_send( portid in integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, action in varchar2 )
as

 cursor c1(portid integer) is select * from portlet_definition where portlet_id = portid;
 cursor c2(portid integer) is select * from portlet_send_query where portlet_id = portid;
 cursor c3(portid integer) is select template_name,order_by from portlet_send_query_cols where portlet_id = portid and data_type in ( 'Checkbox', 'Checkbox (Checked)' );
 cursor c4(portid integer, p1 varchar2) is select order_by from portlet_send_query_cols where portlet_id = portid and template_name = p1;

 c1rec			c1%ROWTYPE;
 c2rec			c2%ROWTYPE;
 c4rec			c4%ROWTYPE;
 gcode			GLBX.MYARRAY;
 gparam			GLBX.MYARRAY;
 isfound		boolean;
 ctr			integer;
 uniqueid		integer;
 eml			varchar2(1000);

begin
 open c1(portid);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   htp.p( 'Portlet Not Found:' || portid );
   return;
 end if;
 close c1;

 open c2(portid);
 fetch c2 into c2rec;
 if c2%NOTFOUND
  then
   close c2;
   htp.p( 'Portlet Not Found:' || portid );
   return;
 end if;
 close c2;

 select s_portlet_send_results.nextval into uniqueid from dual;

 ctr := 0;
 for j in p1.first..p1.last loop
  if p1(j) is not null
   then
    ctr := ctr + 1;
    gcode(ctr) := upper(p1(j));
    gparam(ctr) := p2(j);
    open c4(c1rec.portlet_id,upper(p1(j)));
    fetch c4 into c4rec;
    close c4;
    insert into portlet_send_results(result_id,portlet_id,pid,parm1,parm2,parm3,date_created,order_by) values
     (uniqueid,c2rec.portlet_id,c1rec.pid,upper(p1(j)),p2(j),null,sysdate,c4rec.order_by);
  end if;
 end loop;

 for c3rec in c3(portid) loop
  isfound := FALSE;
  for j in p3.first..p3.last loop
   if p3(j) = c3rec.template_name
    then
     isfound := TRUE;
   end if;
  end loop;
  ctr := ctr + 1;
  if isfound
   then
    gcode(ctr) := c3rec.template_name;
    gparam(ctr) := 'T';
   else
    gcode(ctr) := c3rec.template_name;
    gparam(ctr) := 'F';
  end if;
  insert into portlet_send_results(result_id,portlet_id,pid,parm1,parm2,parm3,date_created,order_by) values
   (uniqueid,c2rec.portlet_id,c1rec.pid,c3rec.template_name,null,gparam(ctr),sysdate,c3rec.order_by);
 end loop;

 glbx.send( gcode, gparam, c2rec.template, p_to=>c2rec.sendto, p_subj=>c2rec.subject_line, p_from=>glbx.extract_master_parameter('MAIL_FROM') );
 -- send return email
 if c2rec.auto_cust_template is not null
  then
    -- Find the email field
    for j in gcode.first..gcode.last loop
     if gcode(j) = c2rec.email_field_is
      then
       eml := gparam(j);
       exit;
     end if;
    end loop;
    if eml is not null
     then
      glbx.send( gcode, gparam, c2rec.auto_cust_template, p_to=>eml, p_subj=>c2rec.subject_line, p_from=>c2rec.sendto );
    end if;
 end if;
 commit;

 if c2rec.on_submit_username is not null
  then
   -- Login to Piction
   accept_login(un=>c2rec.on_submit_username,pw=>c2rec.on_submit_password,simplesearch=>c2rec.on_submit_search);

 elsif c2rec.on_submit_page is null
  then

   htp.htmlopen;
   htp.p( c2rec.submit_page_text );
   htp.htmlclose;

  else
   owa_util.redirect_url( c2rec.on_submit_page );

 end if;

exception
 when others then htp.p( 'Error in Portlet:' || sqlerrm );
end portlet_send;

procedure core_news( phgid in integer, pname in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, c1rec in portlet_definition%ROWTYPE, c7rec in out portlet_news%ROWTYPE )
as

 cursor c3(portid integer) is select * from portlet_news_item where portlet_id = portid order by order_by;
 cursor c4a(portid integer, cl integer) is select * from portlet_news_item where portlet_id = portid and column_1_2 = cl order by order_by;
 cursor c4b(portid integer, cl integer) is select * from portlet_news_item where portlet_id = portid and column_1_2 = cl order by order_by;
 cursor c4c(portid integer, cl integer) is select * from portlet_news_item where portlet_id = portid and column_1_2 = cl order by order_by;
 cursor c5(hn integer, acid integer) is select * from home_news where hnews = hn and aid = acid;
 cursor c6(tn varchar2) is select * from theme where theme_name = tn;
 cursor c7(acid integer) is select * from customer_account where aid = acid;
 cursor c8(tt varchar2) is select * from theme_types where theme_type = tt;

 c4arec		c4a%ROWTYPE;
 c4brec		c4b%ROWTYPE;
 c4crec		c4c%ROWTYPE;
 c5rec		c5%ROWTYPE;
 cusrec		c7%ROWTYPE;
 ctr		integer;
 cell		varchar2(1000);
 cellh		varchar2(1000);
 width		integer;
 height		integer;
 http		varchar2(100);
 pfx		theme%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin

 -- Replace Overwritten Parameters
 for j in p1.first..p1.last loop
  if upper(p1(j)) = 'STYLE' 		   then c7rec.style := upper(p2(j)); end if;
  if upper(p1(j)) = 'BACKGROUND_COLOUR'    then c7rec.BACKGROUND_COLOUR := upper(p2(j)); end if;
  if upper(p1(j)) = 'BACKGROUND_IMAGE'     then c7rec.BACKGROUND_IMAGE := upper(p2(j)); end if;
  if upper(p1(j)) = 'BACKGROUND_EXT'       then c7rec.BACKGROUND_EXT := upper(p2(j)); end if;
  if upper(p1(j)) = 'BAR_TITLE'            then c7rec.BAR_TITLE := upper(p2(j)); end if;
  if upper(p1(j)) = 'HEADER_TITLE'         then c7rec.HEADER_TITLE := upper(p2(j)); end if;
  if upper(p1(j)) = 'JUSTIFY'              then c7rec.JUSTIFY := upper(p2(j)); end if;
  if upper(p1(j)) = 'TABLE_PARM'           then c7rec.TABLE_PARM := upper(p2(j)); end if;
  if upper(p1(j)) = 'TABLE_DATA'           then c7rec.TABLE_DATA := upper(p2(j)); end if;
  if upper(p1(j)) = 'TABLE_DATA_ALT'       then c7rec.TABLE_DATA_ALT := upper(p2(j)); end if;
  if upper(p1(j)) = 'TEXT_FONT'            then c7rec.TEXT_FONT := upper(p2(j)); end if;
  if upper(p1(j)) = 'TEXT_COLOUR'          then c7rec.TEXT_COLOUR := upper(p2(j)); end if;
  if upper(p1(j)) = 'TEXT_PITCH'           then c7rec.TEXT_PITCH := upper(p2(j)); end if;
  if upper(p1(j)) = 'HEADER_COLOUR'        then c7rec.HEADER_COLOUR := upper(p2(j)); end if;
  if upper(p1(j)) = 'HEADER_FONT_COLOUR'   then c7rec.HEADER_FONT_COLOUR := upper(p2(j)); end if;
  if upper(p1(j)) = 'CELL_COLOUR'          then c7rec.CELL_COLOUR := upper(p2(j)); end if;
  if upper(p1(j)) = 'CELL_COLOUR_ALT'      then c7rec.CELL_COLOUR_ALT := upper(p2(j)); end if;
  if upper(p1(j)) = 'RETURL'               then c7rec.RETURL := upper(p2(j)); end if;
  if upper(p1(j)) = 'RETURL_DISPLAY'       then c7rec.RETURL_DISPLAY := upper(p2(j)); end if;
  if upper(p1(j)) = 'RETURL_IS_GIF'        then c7rec.RETURL_IS_GIF := upper(p2(j)); end if;
  if upper(p1(j)) = 'INSTRUCTION_TEXT_HDR' then c7rec.INSTRUCTION_TEXT_HDR := upper(p2(j)); end if;
  if upper(p1(j)) = 'INSTRUCTION_TEXT_FTR' then c7rec.INSTRUCTION_TEXT_FTR := upper(p2(j)); end if;
  if upper(p1(j)) = 'TARGET'               then c7rec.TARGET := upper(p2(j)); end if;
  if upper(p1(j)) = 'RETURL_TARGET'        then c7rec.RETURL_TARGET := upper(p2(j)); end if;
  if upper(p1(j)) = 'DIVIDER_TYPE'         then c7rec.DIVIDER_TYPE := upper(p2(j)); end if;
  if upper(p1(j)) = 'DIVIDER_CODE'         then c7rec.DIVIDER_CODE := upper(p2(j)); end if;
  if upper(p1(j)) = 'JAVASCRIPT_CODE'      then c7rec.JAVASCRIPT_CODE := upper(p2(j)); end if;
 end loop;

 htp.htmlopen;
 htp.p( '<HEAD>' );
 htp.title( c7rec.bar_title );
 if c7rec.javascript_code is not null then htp.p( c7rec.javascript_code ); end if;

 htp.p( '</HEAD>' );
 if c7rec.background_image is null
  then
   htp.p( '<BODY BGCOLOR=#' || c7rec.background_colour || ' ' || c7rec.background_ext || '>' );
  else
   htp.p( '<BODY BACKGROUND="/site_specific/' || c7rec.background_image || '" ' || c7rec.background_ext || '>' );
 end if;
 htp.p( '<' || nvl(c7rec.justify,'CENTER') || '>' );
 if c7rec.header_title is not null
  then
   htp.header(2, c7rec.header_title, 'CENTER' );
 end if;

 if c7rec.instruction_text_hdr is not null
  then
   htp.p( c7rec.instruction_text_hdr );
   htp.nl;
 end if;

 ctr := 0;
 htp.tableopen( cattributes=>nvl(c7rec.table_parm, 'cellpadding=0 cellspacing=0 border=0' ));

 if c1rec.portlet_type = 'NEWS'
  then
   open c4a(c1rec.portlet_id,1);
   open c4b(c1rec.portlet_id,2);
   open c4c(c1rec.portlet_id,3);
   loop
    htp.tablerowopen;
    fetch c4a into c4arec;
    exit when c4a%NOTFOUND;
    fetch c4b into c4brec;
    if c4b%NOTFOUND then c4brec.portlet_id := NULL; end if;
    fetch c4c into c4crec;
    if c4c%NOTFOUND then c4crec.portlet_id := NULL; end if;

    cell := 'style="text-align: left; ' || 'background-color: #' || c7rec.cell_colour || '; font-size: ' || c7rec.text_pitch || '; font-family: ''' || c7rec.text_font || '''; color: #' || c7rec.text_colour  || '"' || c7rec.table_data;
      htp.p( '<TD ' || cell || '>' );
      open c5(c4arec.news_item_or_umo_id,c4arec.aid);
      fetch c5 into c5rec;
      close c5;
      open c7(c4arec.aid);
      fetch c7 into cusrec;
      close c7;
      open c6(cusrec.theme_name);
      fetch c6 into pfx;
      close c6;
      open c8(cusrec.theme_type);
      fetch c8 into theme_rec;
      close c8;
      home_disptable(c5rec,null,c4arec.aid,1,'CUSTOMER',pfx,cusrec,theme_rec,null);
      htp.p( '</TD>' );
    if c4brec.portlet_id is null
     then
      htp.tabledata( '&nbsp;', cattributes=>cell );
     else
      htp.p( '<TD ' || cell || '>' );
      open c5(c4brec.news_item_or_umo_id,c4brec.aid);
      fetch c5 into c5rec;
      close c5;
      open c7(c4brec.aid);
      fetch c7 into cusrec;
      close c7;
      open c6(cusrec.theme_name);
      fetch c6 into pfx;
      close c6;
      open c8(cusrec.theme_type);
      fetch c8 into theme_rec;
      close c8;
      home_disptable(c5rec,null,c4brec.aid,1,'CUSTOMER',pfx,cusrec,theme_rec,null);
      htp.p( '</TD>' );
    end if;
    if c4crec.portlet_id is null
     then
      htp.tabledata( '&nbsp;', cattributes=>cell );
     else
      htp.p( '<TD ' || cell || '>' );
      open c5(c4crec.news_item_or_umo_id,c4crec.aid);
      fetch c5 into c5rec;
      close c5;
      open c7(c4crec.aid);
      fetch c7 into cusrec;
      close c7;
      open c6(cusrec.theme_name);
      fetch c6 into pfx;
      close c6;
      open c8(cusrec.theme_type);
      fetch c8 into theme_rec;
      close c8;
      home_disptable(c5rec,null,c4crec.aid,1,'CUSTOMER',pfx,cusrec,theme_rec,null);
      htp.p( '</TD>' );
    end if;
    htp.tablerowclose;

   end loop;

 elsif c1rec.portlet_type = 'QUICKNEWS'
  then
   cellh := 'style="text-align: left; ' || 'background-color: #' || c7rec.header_colour || '; font-size: ' || c7rec.text_pitch || '; font-family: ''' || c7rec.text_font || '''; color: #' || c7rec.header_font_colour  || '"' || c7rec.table_data;
   cell := 'style="text-align: left; ' || 'background-color: #' || c7rec.cell_colour || '; font-size: ' || c7rec.text_pitch || '; font-family: ''' || c7rec.text_font || '''; color: #' || c7rec.text_colour  || '"' || c7rec.table_data;
   for c3rec in c3( c1rec.portlet_id ) loop
    htp.tablerowopen;
     htp.tabledata( nvl(c3rec.news_title,'&nbsp;'), cattributes=>nvl(c3rec.news_title_style,cellh) );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( nvl(c3rec.news_text,'&nbsp;'), cattributes=>nvl(c3rec.news_text_style,cell) );
    htp.tablerowclose;
    htp.tablerowopen;
     if c7rec.divider_type = 'LINE'
      then
       htp.tabledata( '<HR ' || c7rec.divider_code || '>' );
     end if;
    htp.tablerowclose;
   end loop;

 elsif c1rec.portlet_type = 'CUSTOMERS'
  then
   open c4a(c1rec.portlet_id,1);
   open c4b(c1rec.portlet_id,2);
   loop
    fetch c4a into c4arec;
    exit when c4a%NOTFOUND;
    fetch c4b into c4brec;
    if c4b%NOTFOUND then c4brec.portlet_id := NULL; end if;
    htp.tablerowopen;

    width := to_number(ump.uma_attribute( null, c4arec.news_item_or_umo_id, 'ICON', 'DISPLAY_WIDTH' ));
    height := to_number(ump.uma_attribute( null, c4arec.news_item_or_umo_id, 'ICON', 'DISPLAY_HEIGHT' ));
    http := ump.uma_attribute( null, c4arec.news_item_or_umo_id, 'ICON', 'HTTP_LINK' );
    cell := 'style="text-align: left; ' || 'background-color: #' || c7rec.cell_colour || '; font-size: ' || c7rec.text_pitch || '; font-family: ''' || c7rec.text_font || '''; color: #' || c7rec.text_colour  || '"' || c7rec.table_data;
    if http is null
     then
        htp.tabledata('<IMG BORDER=0 WIDTH=' || width || ' HEIGHT=' || height || ' ALIGN="LEFT" SRC="' ||
              'ump.retrieve_uma?surl=&parm1=UMO_ID&parm2=' || c4arec.news_item_or_umo_id ||
              '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=EXTERNAL_ICON' ||
              '&parm1=OVERRIDE_DISPLAY&parm2=ICON&parm1=AID&parm2=' || c4arec.aid ||
              '" ALT="' || http || '" STYLE="display:block;">' || c4arec.news_title, cattributes=>nvl(c4arec.news_title_style,cell) );
      else
        htp.tabledata(htf.anchor2( glbx.adjust_for_http(http),'<IMG BORDER=0 WIDTH=' || width || ' HEIGHT=' || height || ' SRC="' ||
              'ump.retrieve_uma?surl=&parm1=UMO_ID&parm2=' || c4arec.news_item_or_umo_id ||
              '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=EXTERNAL_ICON' ||
              '&parm1=OVERRIDE_DISPLAY&parm2=ICON&parm1=AID&parm2=' || c4arec.aid ||
              '" ALT="' || http || '" STYLE="display:block;">',ctarget=>'_top' ) || c4arec.news_title, cattributes=>nvl(c4arec.news_title_style,cell));
    end if;
    if c4brec.portlet_id is null
     then
      htp.tabledata( '&nbsp;', cattributes=>nvl(c4arec.news_title_style,cell) );
     else
      width := to_number(ump.uma_attribute( null, c4brec.news_item_or_umo_id, 'ICON', 'DISPLAY_WIDTH' ));
      height := to_number(ump.uma_attribute( null, c4brec.news_item_or_umo_id, 'ICON', 'DISPLAY_HEIGHT' ));
      http := ump.uma_attribute( null, c4brec.news_item_or_umo_id, 'ICON', 'HTTP_LINK' );
      cell := 'style="text-align: left; ' || 'background-color: #' || c7rec.cell_colour || '; font-size: ' || c7rec.text_pitch || '; font-family: ''' || c7rec.text_font || '''; color: #' || c7rec.text_colour  || '"' || c7rec.table_data;
      if http is null
       then
          htp.tabledata('<IMG BORDER=0 WIDTH=' || width || ' HEIGHT=' || height || ' ALIGN="LEFT" SRC="' ||
                'ump.retrieve_uma?surl=&parm1=UMO_ID&parm2=' || c4brec.news_item_or_umo_id ||
                '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=EXTERNAL_ICON' ||
                '&parm1=OVERRIDE_DISPLAY&parm2=ICON&parm1=AID&parm2=' || c4brec.aid ||
                '" ALT="' || http || '" STYLE="display:block;">' || c4brec.news_title, cattributes=>nvl(c4brec.news_title_style,cell) );
        else
          htp.tabledata(htf.anchor2( glbx.adjust_for_http(http),'<IMG BORDER=0 WIDTH=' || width || ' HEIGHT=' || height || ' SRC="' ||
                'ump.retrieve_uma?surl=&parm1=UMO_ID&parm2=' || c4brec.news_item_or_umo_id ||
                '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=EXTERNAL_ICON' ||
                '&parm1=OVERRIDE_DISPLAY&parm2=ICON&parm1=AID&parm2=' || c4brec.aid ||
                '" ALT="' || http || '" STYLE="display:block;">', ctarget=>'_top' ) || c4brec.news_title, cattributes=>nvl(c4brec.news_title_style,cell));
      end if;
    end if;
    htp.tablerowclose;
   end loop;
   close c4a;
   close c4b;

 end if;
 htp.tableclose;


 if c7rec.returl is not null
  then
   htp.nl;
   if c7rec.returl_is_gif is null
    then
     htp.anchor2( c7rec.returl, c7rec.returl_display, ctarget=>c7rec.returl_target );
    else
     htp.anchor2( c7rec.returl, htf.img( '/site_specific/' || c7rec.returl_display, cattributes=>'BORDER=0 '), ctarget=>c7rec.returl_target );
   end if;
 end if;

 if c7rec.instruction_text_ftr is not null
  then
   htp.nl;
   htp.p( c7rec.instruction_text_ftr );
 end if;

 htp.p( '</' || nvl(c7rec.justify,'CENTER') || '>' );
 htp.p( '</BODY>' );
 htp.htmlclose;
exception
 when others then htp.p( 'Error in Portlet:' || sqlerrm );
end core_news;

function guess_date( val in varchar2 )
 return varchar2
as
 dt	date;
begin
 if val is null then return( null ); end if;
 -- Try different combinations to guess the date
 begin dt := to_date( val, 'DD-Month-YY' ); return( to_char( dt, LNG.MASK ) ); exception when others then null; end;
 begin dt := to_date( val, 'DD-Month-YYYY' ); return( to_char( dt, LNG.MASK ) ); exception when others then null; end;
 begin dt := to_date( val, LNG.MASK ); return( to_char( dt, LNG.MASK ) ); exception when others then null; end;
 begin dt := to_date( val, LNG.TSMASK ); return( to_char( dt, LNG.TSMASK ) ); exception when others then null; end;
 begin dt := to_date( val, 'DD/MM/YYYY' ); return( to_char( dt, LNG.MASK ) ); exception when others then null; end;
 begin dt := to_date( val, 'MM/DD/YYYY' ); return( to_char( dt, LNG.MASK ) ); exception when others then null; end;
 begin dt := to_date( val, 'JJJ' ); return( to_char( dt, LNG.MASK ) ); exception when others then null; end;
 begin dt := to_date( val, 'YYYYMMDD' ); return( to_char( dt, LNG.MASK ) ); exception when others then null; end;
 begin dt := to_date( val, 'YYYY-MON-DD' ); return( to_char( dt, LNG.MASK ) ); exception when others then null; end;
 begin dt := to_date( val, 'DD-MM-RR' ); return( to_char( dt, LNG.MASK ) ); exception when others then null; end;
 begin dt := to_date( val, 'DD-MM-YY' ); return( to_char( dt, LNG.MASK ) ); exception when others then null; end;
 begin dt := to_date( val, 'DD/MM/YYYY HH24:MI:SS' ); return( to_char( dt, LNG.TSMASK ) ); exception when others then null; end;
 begin dt := to_date( val, 'DD/MM/YYYY HHam:MI:SS' ); return( to_char( dt, LNG.TSMASK ) ); exception when others then null; end;
 return( NULL );
exception
 when others then return( val );
end guess_date;

function guess_date_circa( val in varchar2, date_type in varchar2 )
 return varchar2
as

 dt1	date;
 dt2	date;
 tmpval	varchar2(1000);
 v1	varchar2(1000);
 x	integer;

begin
 if val is null then return( null ); end if;

 if date_type in ('C','D') -- value circa YYYY ad/bc
  then

   -- Ignore the leading value
   if date_type = 'D'
    then
     x := instr(val,' ');
     if x = 0 then return( NULL ); end if;
     x := x + 1;
     tmpval := replace(substr(val,x),'.','');
    else
     tmpval := replace(val,'.','');
   end if;
   if substr(tmpval,1,5) <> 'CIRCA' then return( NULL ); end if;

   -- Test for format YYYY
   begin
    dt1 := to_date( substr( tmpval,7),'YYYY' );
    return( val );
   exception when others then null;
   end;

   -- Test for format YYYY ad
   begin
    dt1 := to_date( substr( tmpval,7),'YYYY ad' );
    return( val );
   exception when others then null;
   end;
   return( NULL );

 elsif date_type = 'Y' -- YYYY-YYYY
  then
   tmpval := replace( val,' ','');
   v1 := substr( tmpval, 1, 4 );
   begin dt1 := to_date(v1,'YYYY'); exception when others then return( NULL ); end;
   v1 := substr( tmpval, 6, 4 );
   begin dt2 := to_date(v1,'YYYY'); exception when others then return( NULL ); end;
   if dt2 > dt1 then return( NULL ); end if;
   return( tmpval );
 end if;

exception
 when others then return( NULL );
end guess_date_circa;

function guess_number( val in varchar2 )
 return varchar2
as
 nmb	number;
begin
 if val is null then return( null ); end if;
 begin nmb := to_number( replace(val,',','') ); return( to_char( nmb ) ); exception when others then null; end;
 return( NULL );
exception
 when others then return( NULL );
end guess_number;

function guess_money( val in varchar2 )
 return varchar2
as
 nmb	number;
begin
 if val is null then return( null ); end if;
 begin nmb := to_number( val, LNG.MONEY_FORMAT ); return( to_char( nmb, LNG.MONEY_FORMAT ) ); exception when others then null; end;
 begin nmb := to_number( val ); return( to_char( nmb, LNG.MONEY_FORMAT ) ); exception when others then null; end;
 return( NULL );
exception
 when others then return( NULL );
end guess_money;

function guess_boolean( val in varchar2, ifnull in boolean default FALSE, ifunknown in boolean default TRUE )
 return boolean
as
 bl	boolean;
begin
 if val is null then return( ifnull ); end if;
 if substr(upper(trim(val)),1,1) in ('T','Y') then return( TRUE ); end if;
 if substr(upper(trim(val)),1,1) in ('F','N') then return( FALSE ); end if;
 return( ifunknown );
exception
 when others then return( ifunknown );
end guess_boolean;

function delete_link(v_umo in integer )
 return boolean
as
 cursor c1(v_umo integer) is select * from umo_link where to_umo_id = v_umo;
 cursor c2(v_umo integer, lktype varchar2) is select * from umo_link where umo_id = v_umo and link_type = lktype;
begin
 for c1rec in c1(v_umo) loop
  for c2rec in c2(v_umo, c1rec.link_type) loop
   insert into umo_link(umo_id,to_umo_id,date_last_access,weighting,connections,sum_overtime,link_type,annotation,version_type)
    values
     ( c1rec.umo_id, c2rec.to_umo_id, c1rec.date_last_access, c1rec.weighting, c1rec.connections, c1rec.sum_overtime, c1rec.link_type, c1rec.annotation, c1rec.version_type );
  end loop;
 end loop;
 delete from umo_link um where umo_id = v_umo;
 delete from umo_link um where to_umo_id = v_umo;
 return( TRUE );
end delete_link;

function add_link( from_umo in integer, to_umo in integer, annote in varchar2 default null, isfinal in char default 'T', lktype in char default 'T' )
 return boolean
as

 procedure recurse_reset( v_umo integer, vl in varchar2, infctr in integer default 50 )
 as
  cursor c1( v_umo integer, lktype char ) is select * from umo_link where to_umo_id = v_umo and link_type = lktype;
 begin
  if infctr = 0 then return; end if;
  for c1rec in c1( v_umo, lktype ) loop
   update umo_link
    set
     version_type = vl
   where
    umo_id = c1rec.umo_id and
    to_umo_id = v_umo and
    link_type = lktype;
   recurse_reset(c1rec.umo_id,infctr-1);
  end loop;
 end recurse_reset;

begin
 if isfinal = 'T'
  then
   recurse_reset( from_umo, 'F' );
 end if;

 insert into umo_link
 ( umo_id, to_umo_id, date_last_access, link_type, version_type, annotation )
 values
  ( from_umo, to_umo, sysdate, lktype, isfinal, annote );
 return( TRUE );
end add_link;

function disp_link_history( start_umo in integer, tbl in varchar2, hdr in varchar2, td1 in varchar2, td2 in varchar2, trg in varchar2, lktype in char default 'T' )
 return boolean
as

 procedure disp_row_ahead( v_umo integer, infctr in integer default 50 )
 as
  cursor c1( v_umo integer, lktype char ) is select * from umo_link where umo_id = v_umo and link_type = lktype;
 begin
  if infctr = 0 then return; end if;
  for c1rec in c1( v_umo, lktype ) loop
   htp.tablerowopen;
    htp.tabledata( htf.anchor( trg || '&v_umo=' || c1rec.to_umo_id, '&gt;' ) , cattributes=>td1 );
    htp.tabledata( to_char( c1rec.date_last_access, LNG.TSMASK ), cattributes=>td1 );
    if td2 is not null
     then
       htp.tabledata( nvl(c1rec.annotation,'&nbsp;') , cattributes=>td2 );
    end if;
   htp.tablerowclose;
   disp_row_ahead(c1rec.to_umo_id,infctr-1);
  end loop;
 end disp_row_ahead;

 procedure disp_row( v_umo integer, infctr in integer default 50 )
 as
  cursor c1( v_umo integer, lktype char ) is select * from umo_link where to_umo_id = v_umo and link_type = lktype;
 begin
  if infctr = 0 then return; end if;
  for c1rec in c1( v_umo, lktype ) loop
   htp.tablerowopen;
    htp.tabledata( htf.anchor( trg || '&v_umo=' || c1rec.umo_id, '&lt;' ) , cattributes=>td1 );
    htp.tabledata( to_char( c1rec.date_last_access, LNG.TSMASK ), cattributes=>td1 );
    if td2 is not null
     then
       htp.tabledata( nvl(c1rec.annotation,'&nbsp;') , cattributes=>td2 );
    end if;
   htp.tablerowclose;
   disp_row(c1rec.umo_id,infctr-1);
  end loop;
 end disp_row;

begin
 htp.tableopen( tbl );
 if hdr is not null
  then
   htp.tablerowopen;
   htp.p( hdr );
   htp.tablerowclose;
 end if;
 disp_row_ahead( start_umo );
 disp_row( start_umo );

 htp.tableclose;
 return( TRUE );
end disp_link_history;

procedure fixnm( nm in varchar2, fn out varchar2, lnm out varchar2 )
as
  x	integer;
begin
 -- will split a name into first name and surname
  x := instr(nm,' ',-1);
  if x = 0
   then
    fn := null;
    lnm := nm;
    return;
  end if;

  fn := trim(substr(nm,1,x-1));
  lnm := trim(substr(nm,x+1));
  if lnm is null and fn is not null
   then
    lnm := fn;
    fn := null;
    return;
  end if;

  if upper(fn) in
  (
   'DR','MR','MRS','MS','MISS','MASTER','CAPTAIN','MZ','CPT', 'REV', 'PROF', 'SIR', 'MST',
   'DR.','MR.','MRS.','MS.','MISS.','MASTER.','CAPTAIN.','MZ.','CPT.', 'REV.', 'PROF.', 'SIR.', 'MST.'
   )
   then
    x := instr(nm,' ',1,2);
    if x = 0 then return; end if; -- name is like dr smith in which case keep the firstname as the salutation
   else
    return;
   end if;

   fn := trim(substr(nm,1,x-1));
   lnm := trim(substr(nm,x+1));
   if lnm is null and fn is not null
    then
     lnm := fn;
     fn := null;
     return;
   end if;
end fixnm;

function sctrl( tname in varchar2, ctrl in varchar2, stype in integer )
 return varchar2
as
 cursor c1(tname varchar2, ctrl varchar2 ) is select * from screen_controller where theme_name = tname and controller = ctrl;
 c1rec  c1%ROWTYPE;
begin
 -- orig_width := trunc(to_number(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH_ACTUAL',stype))/4);
 open c1(tname,ctrl);
 fetch c1 into c1rec;
 close c1;
 if c1rec.ctype = 'V'
  then
   if stype = 0 then return( c1rec.v_screen_0 );
   elsif stype = 1 then return( c1rec.v_screen_1 );
   elsif stype = 2 then return( c1rec.v_screen_2 );
   elsif stype = 3 then return( c1rec.v_screen_3 );
   elsif stype = 4 then return( c1rec.v_screen_4 );
   elsif stype = 5 then return( c1rec.v_screen_5 );
   elsif stype = 6 then return( c1rec.v_screen_6 );
   elsif stype = 7 then return( c1rec.v_screen_7 );
   end if;
  else
   if stype = 0 then return( c1rec.n_screen_0 );
   elsif stype = 1 then return( c1rec.n_screen_1 );
   elsif stype = 2 then return( c1rec.n_screen_2 );
   elsif stype = 3 then return( c1rec.n_screen_3 );
   elsif stype = 4 then return( c1rec.n_screen_4);
   elsif stype = 5 then return( c1rec.n_screen_5 );
   elsif stype = 6 then return( c1rec.n_screen_6 );
   elsif stype = 7 then return( c1rec.n_screen_7 );
   end if;
 end if;
 return( NULL );
exception
 when others then return( NULL );
end sctrl;

function fndtheme( vsess in integer, acid in integer default null )
 return varchar2
as

 cursor c1( vsess integer ) is select aid, login_type from login_session where sessid = vsess;
 cursor c2( acid integer ) is select theme_name from customer_account where aid = acid;
 cursor c3( acid integer ) is select theme_name from customer_profile where profile_id = acid;
 cursor c4( acid integer ) is select top_frame_lf from photographer where pid = acid;
 cursor c5( acid integer ) is select theme_name from manufacturer where manufacturer_id = acid;

 c1rec c1%ROWTYPE;
 res	varchar2(100);

begin
 open c1( vsess );
 fetch c1 into c1rec;
 close c1;
 if c1rec.login_type = 'PHOTOGRAPHER' and acid is null
  then
   open c4(c1rec.aid);
   fetch c4 into res;
   close c4;
 elsif c1rec.login_type = 'PHOTOGRAPHER'
  then
   open c2(acid);
   fetch c2 into res;
   close c2;
 elsif c1rec.login_type in ('OWNER','CUSTOMER','VIRTUAL')
  then
   open c2(c1rec.aid);
   fetch c2 into res;
   close c2;
 elsif c1rec.login_type in ('PROFILE','PROFILEG')
  then
   open c3(c1rec.aid);
   fetch c3 into res;
   close c3;
 elsif c1rec.login_type = 'MANUFACTURER'
  then
   open c5(c1rec.aid);
   fetch c5 into res;
   close c5;
 elsif vsess is null and acid is not null
  then
   open c2(acid);
   fetch c2 into res;
   close c2;
 end if;
 return( nvl(res,'DEFAULT') );
end fndtheme;

end glbx;
/


GRANT EXECUTE ON WEBSYS.GLBX TO STRANG;

GRANT EXECUTE ON WEBSYS.GLBX TO STX1;
