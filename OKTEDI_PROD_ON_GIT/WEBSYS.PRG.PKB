CREATE OR REPLACE package body WEBSYS.prg
as

-- Global constants
PACKAGE_NAME constant varchar2(3)   := 'PRG';

-- Global variables
PROC_NAME    varchar2(200)           := '';
PRG_TYPE     varchar2(200)           := '';

procedure maintain_program(
  surl varchar2,
  acid integer,
  program_type varchar2,
  pid in integer default 0)
as
   cursor c0(cptype varchar2) is
   select
      *
   from
      umo um
   where
      um.umo_type = LNG5.PRG_TXT_108 and
      um.program_obj.program_type = cptype; -- Look for paid programs

   -- Look and feel variables
   rTheme   THEME%ROWTYPE;
   labelPrefix varchar2(200);
begin
   if not dapi.init(surl, 'PRG.MAINTAIN_PROGRAM', acid, iscust=>FALSE) then
      dapi.initFailed(surl);
      return;
   end if;
   rTheme := dapi.getLFRecord;
   dapi.setTitle('Manage Programs');
   dapi.pageOpen;
   PRG_TYPE   := program_type;
   htp.p('<CENTER>');
   htp.formOpen('prg.insert_program');
   htp.formHidden('surl', surl);
   htp.formHidden('acid', acid);
   htp.formHidden('ptype', program_type);
   htp.formSubmit('action', 'Insert');
   htp.nl;

   htp.nl;
   htp.tableOpen(cattributes=>'cellpadding=0 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );
      htp.tableRowOpen;
         htp.tableData(htf.bold(LNG5.BKN_TXT_024), cattributes=>rTheme.qbground);
         htp.tableData(htf.bold(LNG5.BKN_TXT_025), cattributes=>rTheme.qbground);
         -- htp.tableData(htf.bold(LNG5.BKN_TXT_026), cattributes=>rTheme.qbground);
         htp.tableData(htf.bold(LNG5.BKN_TXT_028), cattributes=>rTheme.qbground);
         htp.tableData(htf.bold(LNG5.BKN_TXT_029), cattributes=>rTheme.qbground);
         htp.tableData(htf.bold(LNG5.BKN_TXT_030), cattributes=>rTheme.qbground);
         htp.tableData(htf.bold(LNG5.BKN_TXT_165), cattributes=>rTheme.qbground);
         htp.tableData(htf.bold(LNG5.BKN_TXT_169), cattributes=>rTheme.qbground);
         htp.tableData(htf.bold(LNG5.BKN_TXT_166), cattributes=>rTheme.qbground);
         htp.tableData(htf.bold(LNG5.BKN_TXT_167), cattributes=>rTheme.qbground);
         htp.tableData(htf.bold(LNG5.BKN_TXT_168), cattributes=>rTheme.qbground);
         htp.tableData(htf.bold(LNG5.BKN_TXT_021), cattributes=>rTheme.qbground);
      htp.tableRowClose;

   for c0rec in c0(program_type) loop
      htp.tableRowOpen;
      htp.tableData(htf.anchor('prg.update_program?surl=' || surl || '&acid=' || acid || '&p_program_type=' || program_type || '&pid=' || c0rec.umo_id, htf.bold(c0rec.umo_id)), cattributes=>rTheme.qbground);
      htp.tableData(c0rec.program_obj.program_name, cattributes=>rTheme.qcbground);
      -- htp.tableData(c0rec.program_obj.program_description, cattributes=>rTheme.qcbground);
      htp.tableData(c0rec.program_obj.duration, cattributes=>rTheme.qcbground);
      htp.tableData(c0rec.program_obj.cost_per_head, cattributes=>rTheme.qcbground);
      htp.tableData(c0rec.program_obj.school_year, cattributes=>rTheme.qcbground);
      htp.tableData(c0rec.program_obj.wars_covered, cattributes=>rTheme.qcbground);
      htp.tableData(c0rec.program_obj.program_type, cattributes=>rTheme.qcbground);
      htp.tableData(c0rec.program_obj.curriculum_link, cattributes=>rTheme.qcbground);
      htp.tableData(htf.anchor(c0rec.program_obj.url, LNG5.BKN_TXT_170, cattributes=>'target="_blank"'), cattributes=>rTheme.qcbground);
      htp.tableData(TO_CHAR(c0rec.expire_date, LNG.MASK), cattributes=>rTheme.qcbground);
      htp.tableData(htf.anchor('prg.delete_program?surl=' || surl || '&acid=' || acid || '&pid=' || c0rec.umo_id, LNG5.BKN_TXT_021), cattributes=>rTheme.qcbground);
      htp.tableRowClose;
   end loop;

   htp.tableClose;
   htp.nl;

   htp.formSubmit('action', 'Insert');
   htp.formClose;

   htp.p('</CENTER>');
   dapi.pageClose;
exception when others then
   glbx.error_details( PACKAGE_NAME, PROC_NAME, errmsg=>sqlerrm);
end maintain_program;

procedure update_program(
  surl varchar2,
  acid integer,
  p_program_type varchar2,
  pid integer)
as
   cursor c0(cumo_id integer) is
   select
      um.program_obj,
      um.expire_date,
      um.extras.ORDERBY_NMB min_nmb
   from
      umo um
   where
      um.umo_id = cumo_id;
   c0rec c0%ROWTYPE;

   rTheme   THEME%ROWTYPE;
   labelPrefix varchar2(200);
begin
   if not dapi.init(surl, 'PRG.UPDATE_PROGRAM', acid, iscust=>FALSE) then
      dapi.initFailed(surl);
      return;
   end if;
   rTheme := dapi.getLFRecord;
   dapi.setTitle('Update Program');
   dapi.addStyle('input.text', '{width: 20em}');
   dapi.pageOpen;
   open c0(pid);
   fetch c0 into c0rec;
   close c0;
   htp.formOpen('prg.accept_update_program');
   htp.formHidden('surl', surl);
   htp.formHidden('pid', pid);
   htp.formHidden('acid', acid);
   htp.formHidden('p_program_type', p_program_type);
   htp.p('<CENTER>');
   htp.tableOpen(cattributes=>'cellpadding=0 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.BKN_TXT_025), cattributes=>rTheme.qbground);
   htp.tableData(htf.formText('P_program_name', '100', '100', c0rec.program_obj.program_name, cattributes=>'class="text"'), cattributes=>rTheme.qcbground);
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.BKN_TXT_026), cattributes=>rTheme.qbground);
   htp.tableData(htf.formTextareaOpen('P_program_description', '4', '32', cattributes=>'class="text"') || c0rec.program_obj.program_description || htf.formTextareaClose, cattributes=>rTheme.qcbground);
   htp.tableRowClose;
   htp.tableRowOpen;

   htp.tableData(htf.bold(LNG5.BKN_TXT_028), cattributes=>rTheme.qbground);
   htp.tableData(htf.formText('P_duration', '100', '100', c0rec.program_obj.duration, cattributes=>'class="text"'), cattributes=>rTheme.qcbground);
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.BKN_TXT_029), cattributes=>rTheme.qbground);
   htp.tableData(htf.formText('P_cost_per_head', '10', '10', c0rec.program_obj.cost_per_head, cattributes=>'class="text"'), cattributes=>rTheme.qcbground);
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData(htf.bold('Minimum Number'), cattributes=>rTheme.qbground);
   htp.tableData(htf.formText('P_min_nmb', '10', '10', c0rec.min_nmb, cattributes=>'class="text"'), cattributes=>rTheme.qcbground);
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.BKN_TXT_030), cattributes=>rTheme.qbground);
   htp.tableData(htf.formText('P_school_year', '100', '100', c0rec.program_obj.school_year, cattributes=>'class="text"'), cattributes=>rTheme.qcbground);
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.BKN_TXT_165), cattributes=>rTheme.qbground);
   htp.tableData(htf.formText('P_wars_covered', '100', '100', c0rec.program_obj.wars_covered, cattributes=>'class="text"'), cattributes=>rTheme.qcbground);
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.BKN_TXT_166), cattributes=>rTheme.qbground);
   htp.tableData(htf.formText('P_curriculum_link', '100', '100', c0rec.program_obj.curriculum_link, cattributes=>'class="text"'), cattributes=>rTheme.qcbground);
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.BKN_TXT_167), cattributes=>rTheme.qbground);
   htp.tableData(htf.formText('P_url', '100', '100', c0rec.program_obj.url, cattributes=>'class="text"'), cattributes=>rTheme.qcbground);
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.BKN_TXT_168) || ' ('|| LNG.MASK || ')', cattributes=>rTheme.qbground);
   htp.tableData(htf.formText('P_expire_date', '100', '100', TO_CHAR(c0rec.expire_date, LNG.MASK), cattributes=>'class="text"'), cattributes=>rTheme.qcbground);
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData(htf.bold(lng.CST_TXT_216) || '<BR>' || htf.bold('Reload image') || htf.formCheckbox('reload_image', 'T'), cattributes=>rTheme.qbground);
   htp.tableData(GLBX.UPLOAD_NAME , cattributes=>rTheme.qbground);
   htp.tableRowClose;

   htp.tableClose;

   htp.formSubmit('action', LNG.CST_BUT_018);
   htp.formSubmit('action', LNG.CST_BUT_017);
   htp.formSubmit('action', LNG.CST_BUT_016);

   htp.p('</CENTER>');
   htp.formClose;
   dapi.pageClose;
exception when others then
   glbx.error_details( PACKAGE_NAME, PROC_NAME,errmsg=>sqlerrm);
end update_program;

procedure accept_update_program(
  surl                  varchar2,
  acid                  integer,
  pid                   integer,
  P_program_name        varchar2,
  P_program_description varchar2,
  P_duration            varchar2,
  P_cost_per_head       varchar2,
  P_min_nmb		varchar2,
  P_school_year         varchar2,
  P_wars_covered        varchar2,
  P_expire_date         varchar2,
  p_program_type        varchar2,
  p_curriculum_link     varchar2,
  p_url                 varchar2,
  file                  varchar2 default null,
  reload_image          varchar2 default 'N',
  action                varchar2 default null)
as
   cursor c1(cumoid integer) is
   	select um.extras.photo_name file_name
   	from umo um
   	where um.umo_id = cumoid;
   c1rec c1%ROWTYPE;

   --
   -- Work variables
   --
   dummy varchar2(1);
begin
   if not dapi.init(surl, 'PRG.UPDATE_PROGRAM', acid, iscust=>FALSE) then
      dapi.initFailed(surl);
      return;
   end if;

   if action in (LNG.CST_BUT_017, LNG.CST_BUT_018) then
      --
      -- Save changes
      --
      update umo um set
        um.program_obj.program_name         = P_program_name,
        um.program_obj.program_description  = P_program_description,
        um.program_obj.duration             = P_duration,
        um.program_obj.cost_per_head        = P_cost_per_head,
        um.extras.orderby_nmb               = P_min_nmb,
        um.program_obj.school_year          = P_school_year,
        um.program_obj.wars_covered         = P_wars_covered,
        um.program_obj.curriculum_link      = p_curriculum_link,
        um.program_obj.url                  = p_url,
        um.program_obj.program_type         = p_program_type,
        um.expire_date                      = TO_DATE(P_expire_date, LNG.MASK)
        where um.umo_id = pid; -- pid = program ID
      commit;
      --
      -- Upload image if changed
      --
      open c1(pid);
      fetch c1 into c1rec;
      close c1;

      if c1rec.file_name <> file or reload_image = 'Y' then
      	--
      	-- Filename has changed
      	--
      	dummy := null;
      end if;
   end if;

   if action in (LNG.CST_BUT_016, LNG.CST_BUT_018) then
      -- Save changes and/or return to maintenance screen
      maintain_program(surl, acid, P_program_type);
   else
      -- Save changes and return to update screen
      update_program(surl, acid, P_program_type, pid);
   end if;
exception when others then
   glbx.error_details( PACKAGE_NAME, PROC_NAME,errmsg=>sqlerrm);
end accept_update_program;

procedure insert_program(
  surl varchar2,
  acid integer,
  ptype varchar2,
  action varchar2 default null)
as
   rTheme   THEME%ROWTYPE;
   labelPrefix varchar2(200);
begin
   if not dapi.init(surl, 'PRG.INSERT_PROGRAM', acid, iscust=>FALSE) then
      dapi.initFailed(surl);
      return;
   end if;
   rTheme := dapi.getLFRecord;
   dapi.setTitle('Insert Program');
   dapi.addStyle('input.text', '{width: 20em}');
   dapi.pageOpen;
   htp.formOpen('prg.accept_insert_program', cattributes=>'enctype="multipart/form-data" accept="image/gif,image/jpeg,image/tiff"' );
   htp.formHidden('surl', surl);
   htp.formHidden('acid', acid);

   htp.p('<CENTER>');
   htp.tableOpen(cattributes=>'cellpadding=0 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.BKN_TXT_025), cattributes=>rTheme.qbground);
   htp.tableData(htf.formText('P_program_name', '100', '100', '', cattributes=>'class="text"'), cattributes=>rTheme.qcbground);
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.BKN_TXT_026), cattributes=>rTheme.qbground);
   htp.tableData(htf.formTextareaOpen('P_program_description', '4', '32', cattributes=>'class="text"') || htf.formTextareaClose, cattributes=>rTheme.qcbground);
   htp.tableRowClose;
   htp.tableRowOpen;

   htp.tableData(htf.bold(LNG5.BKN_TXT_028), cattributes=>rTheme.qbground);
   htp.tableData(htf.formText('P_duration', '100', '100', '', cattributes=>'class="text"'), cattributes=>rTheme.qcbground);
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.BKN_TXT_029), cattributes=>rTheme.qbground);
   htp.tableData(htf.formText('P_cost_per_head', '10', '10', '', cattributes=>'class="text"'), cattributes=>rTheme.qcbground);
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData(htf.bold('Minimum Number'), cattributes=>rTheme.qbground);
   htp.tableData(htf.formText('P_min_nmb', '10', '10', '10', cattributes=>'class="text"'), cattributes=>rTheme.qcbground);
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.BKN_TXT_030), cattributes=>rTheme.qbground);
   htp.tableData(htf.formText('P_school_year', '100', '100', '', cattributes=>'class="text"'), cattributes=>rTheme.qcbground);
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.BKN_TXT_165), cattributes=>rTheme.qbground);
   htp.tableData(htf.formText('P_wars_covered', '100', '100', '', cattributes=>'class="text"'), cattributes=>rTheme.qcbground);
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.BKN_TXT_166), cattributes=>rTheme.qbground);
   htp.tableData(htf.formText('P_curriculum_link', '100', '100', '', cattributes=>'class="text"'), cattributes=>rTheme.qcbground);
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.BKN_TXT_167), cattributes=>rTheme.qbground);
   htp.tableData(htf.formText('P_url', '100', '100', '', cattributes=>'class="text"'), cattributes=>rTheme.qcbground);
   htp.tableRowClose;
   htp.formHidden('P_program_type', ptype);
   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.BKN_TXT_168) || ' ('|| LNG.MASK || ')', cattributes=>rTheme.qbground);
   htp.tableData(htf.formText('P_expire_date', '100', '100', TO_CHAR(SYSDATE, LNG.MASK), cattributes=>'class="text"'), cattributes=>rTheme.qcbground);
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData(htf.bold(lng.CST_TXT_216), cattributes=>rTheme.qbground);
   htp.tableData(GLBX.UPLOAD_NAME , cattributes=>rTheme.qbground);
   htp.tableRowClose;

   htp.tableClose;

   htp.formSubmit('action', LNG5.BKN_TXT_141); -- Insert and continue
   htp.formSubmit('action', LNG3.ADM_TXT_396); -- Insert and return
   htp.formSubmit('action', LNG.CST_BUT_016);  -- Cancel

   htp.p('</CENTER>');
   htp.formClose;
   dapi.pageClose;
exception when others then
   glbx.error_details( PACKAGE_NAME, PROC_NAME,errmsg=>sqlerrm);
end insert_program;

procedure accept_insert_program(
  surl varchar2,
  acid integer,
  P_program_name        varchar2,
  P_program_description varchar2,
  P_duration            varchar2,
  P_cost_per_head       varchar2,
  P_min_nmb		varchar2,
  P_school_year         varchar2,
  P_wars_covered        varchar2,
  P_program_type        varchar2,
  p_curriculum_link     varchar2,
  p_url                 varchar2,
  P_expire_date         varchar2,
  file                  varchar2 default null,
  action                varchar2 default null)
as
   new_umo_id integer := 0;
   session_id integer;
begin
   if not dapi.init(surl, 'PRG.ACCEPT_INSERT_PROGRAM', acid, iscust=>FALSE) then
      dapi.initFailed(surl);
      return;
   end if;

   if action in (LNG5.BKN_TXT_141, LNG3.ADM_TXT_396) then
     ump.init(acid, LNG5.PRG_TXT_108, new_umo_id );
      update umo um set
        um.program_obj.program_name         = P_program_name,
        um.program_obj.program_description  = P_program_description,
        um.program_obj.duration             = P_duration,
        um.program_obj.cost_per_head        = P_cost_per_head,
        um.extras.orderby_nmb               = P_min_nmb,
        um.program_obj.school_year          = P_school_year,
        um.program_obj.wars_covered         = P_wars_covered,
        um.program_obj.curriculum_link      = p_curriculum_link,
        um.program_obj.url                  = p_url,
        um.program_obj.program_type         = p_program_type,
        um.expire_date                      = TO_DATE(P_expire_date, LNG.MASK)
        where um.umo_id = new_umo_id;

     /*
      select s_umo.nextval into new_umo_id from dual;
      insert into umo
       ( umo_id,date_created,parent_id,aid,umo_type,photo_original_loc,umo_scene_id,umo_owner,ftp_location,ftp_virtual_dir,
         photo_original,photo_master,photo_thumbnail,photo_backup,
         audio_original,audio_thumbnail,
         video_original,blueprint_obj,
         doc_body, doc_length, extras,sessid,
         program_obj,
         expire_date )
      values
       ( new_umo_id, sysdate,NULL, acid, LNG5.PRG_TXT_108, NULL, NULL, NULL, NULL, NULL,
         ORDSYS.ORDImage(ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,NULL,NULL,NULL,NULL,NULL),
         ORDSYS.ORDImage(ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,NULL,NULL,NULL,NULL,NULL),
         ORDSYS.ORDImage(ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,NULL,NULL,NULL,NULL,NULL),
         ORDSYS.ORDImage(ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,NULL,NULL,NULL,NULL,NULL),
         ORDSYS.ORDAudio(NULL,ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,empty_clob(),NULL,NULL,NULL,NULL,NULL,NULL),
         ORDSYS.ORDAudio(NULL,ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,empty_clob(),NULL,NULL,NULL,NULL,NULL,NULL),
         ORDSYS.ORDVideo(NULL,ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,empty_clob(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
         BLUEPRINT_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,empty_blob(),empty_blob()),
         empty_blob(), null, repeated_fields(null,null,null,null,null,null,null,'TRUE','TRUE'),session_id,
         program_type(P_program_name, P_program_description, P_duration, P_cost_per_head, P_school_year, P_wars_covered, P_program_type, p_url, p_curriculum_link, null, null, null),
         TO_DATE(P_expire_date, LNG.MASK)
       );
      */
   end if;

   if action in (LNG5.BKN_TXT_141) then
   -- Go back to insert screen
      insert_program(surl, acid, P_program_type);
   end if;

   if action in (LNG3.ADM_TXT_396, LNG.CST_BUT_016) then
   -- Go back to maintenance screen
      maintain_program(surl, acid, P_program_type);
   end if;
exception when others then
   glbx.error_details( PACKAGE_NAME, PROC_NAME,errmsg=>sqlerrm);
end accept_insert_program;

procedure delete_program(surl varchar2, acid integer, pid integer)
as
   cursor c0(cumo_id integer) is select um.program_obj, um.expire_date from umo um where um.umo_id = cumo_id;
   c0rec c0%ROWTYPE;

   -- Look and feel variables
   rTheme   THEME%ROWTYPE;
   labelPrefix varchar2(200);
begin
   if not dapi.init(surl, 'PRG.DELETE_PROGRAM', acid, iscust=>FALSE) then
      dapi.initFailed(surl);
      return;
   end if;
   rTheme := dapi.getLFRecord;
   dapi.setTitle('Delete Program');
   dapi.pageOpen;
   open c0(pid);
   fetch c0 into c0rec;
   close c0;
   htp.formOpen('prg.accept_delete_program');
   htp.formHidden('surl', surl);
   htp.formHidden('acid', acid);
   htp.formHidden('pid', pid);
   htp.p('<CENTER>');
   htp.tableOpen(cattributes=>'cellpadding=0 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.BKN_TXT_025), cattributes=>rTheme.qbground);
   htp.tableData(c0rec.program_obj.program_name, cattributes=>rTheme.qcbground);
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.BKN_TXT_026), cattributes=>rTheme.qbground);
   htp.tableData(c0rec.program_obj.program_description, cattributes=>rTheme.qcbground);
   htp.tableRowClose;
   htp.tableRowOpen;

   htp.tableData(htf.bold(LNG5.BKN_TXT_028), cattributes=>rTheme.qbground);
   htp.tableData(c0rec.program_obj.duration, cattributes=>rTheme.qcbground);
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.BKN_TXT_029), cattributes=>rTheme.qbground);
   htp.tableData(c0rec.program_obj.cost_per_head, cattributes=>rTheme.qcbground);
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.BKN_TXT_030), cattributes=>rTheme.qbground);
   htp.tableData(c0rec.program_obj.school_year, cattributes=>rTheme.qcbground);
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.BKN_TXT_165), cattributes=>rTheme.qbground);
   htp.tableData(c0rec.program_obj.wars_covered, cattributes=>rTheme.qcbground);
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.BKN_TXT_168) || ' ('|| LNG.MASK || ')', cattributes=>rTheme.qbground);
   htp.tableData(TO_CHAR(c0rec.expire_date, LNG.MASK), cattributes=>rTheme.qcbground);
   htp.tableRowClose;

   htp.tableClose;

   htp.formSubmit('action', LNG.SLD_TXT_004); -- Delete
   htp.formSubmit('action', LNG.CST_BUT_016); -- Cancel

   htp.p('</CENTER>');
   htp.formClose;
   dapi.pageClose;
exception when others then
   glbx.error_details( PACKAGE_NAME, PROC_NAME,errmsg=>sqlerrm);
end delete_program;

procedure accept_delete_program(surl varchar2, acid integer, pid integer, action varchar2 default null)
as
   cursor c0(cumo_id integer) is
      select um.program_obj.program_type ptype from umo um
      where um.umo_id = cumo_id;
   c0rec c0%ROWTYPE;
begin
   if not dapi.init(surl, 'PRG.ACCEPT_DELETE_PROGRAM', acid, iscust=>FALSE) then
      dapi.initFailed(surl);
      return;
   end if;
   open c0(pid);
   fetch c0 into c0rec;
   close c0;
   PRG_TYPE := c0rec.ptype;

   if action in (LNG.SLD_TXT_004) then
      delete from umo where umo_id = pid;
   end if;

   maintain_program(surl, acid, PRG_TYPE);

   exception when others then
      glbx.error_details( PACKAGE_NAME, PROC_NAME,errmsg=>sqlerrm);
end accept_delete_program;

end prg;

/
