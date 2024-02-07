CREATE OR REPLACE package body WEBSYS.rsc
as

procedure maintain_resources(surl varchar2, acid integer, rid in integer default 0)
as
   cursor c0(crid integer, cacid integer) is
   select
      *
   from
      resources
   where
      resource_id >= crid and
      aid = cacid and
      pid = (select pid from customer_account where aid = cacid);

   c1rec  	manufacturer%ROWTYPE;
   ltype		varchar2(100);
   stype		integer;
   owner_id	integer;
   sts		varchar2(100);

   pfx		THEME%ROWTYPE;
   theme_rec	theme_types%ROWTYPE;
begin
   if not dapi.init(surl, 'RSC.MAINTAIN_RESOURCES', acid, iscust=>FALSE) then
      dapi.initFailed(surl,extra_parameter=>'BOOKING');
      return;
   end if;
   pfx := dapi.getLFRecord;
   dapi.setTitle(LNG5.RSC_TXT_001);
   dapi.pageOpen;

   htp.p('<CENTER>');

   htp.formOpen('rsc.insert_resources');
   htp.formHidden('surl', surl);
   htp.formHidden('acid', acid);
   htp.formSubmit('action', 'Insert');
   htp.nl;
   -- htp.tableData(htf.anchor('rsc.insert_resources?surl=' || surl, 'Insert new resource'));
   htp.nl;
   htp.tableOpen(cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.RSC_TXT_100), cattributes=>pfx.qbground);
   htp.tableData(htf.bold(LNG5.RSC_TXT_101), cattributes=>pfx.qbground);
   htp.tableData(htf.bold(LNG5.RSC_TXT_102), cattributes=>pfx.qbground);
   htp.tableData(htf.bold(LNG5.BKN_TXT_021), cattributes=>pfx.qbground);
   htp.tableRowClose;

   for c0rec in c0(rid, acid) loop
      htp.tableRowOpen;
      htp.tableData(htf.anchor('rsc.update_resources?surl=' || surl || '&acid=' || acid || '&rid=' || c0rec.resource_id, htf.bold(c0rec.resource_id)), cattributes=>pfx.qcbground);
      htp.tableData(c0rec.description, cattributes=>pfx.qcbground);
      htp.tableData(c0rec.max_group_size, cattributes=>pfx.qcbground);
      htp.tableData(htf.anchor('rsc.delete_resources?surl=' || surl || '&acid=' || acid || '&rid=' || c0rec.resource_id, 'DEL'), cattributes=>pfx.qcbground);
      htp.tableRowClose;
   end loop;

   htp.tableClose;
   htp.nl;
   -- htp.tableData(htf.anchor('rsc.insert_resources?surl=' || surl, 'Insert new resource'));
   htp.formSubmit('action', 'Insert');

   htp.p('</CENTER>');
   dapi.pageClose;
exception when others then
   glbx.error_details( 'RSC', 'MAINTAIN_RESOURCES',errmsg=>sqlerrm);
end maintain_resources;

procedure update_resources(surl varchar2, acid integer, rid in integer)
as
   cursor c0(crid integer) is
   select
      *
   from
      resources
   where
      resource_id = crid;
   c0rec c0%ROWTYPE;

   c1rec  	manufacturer%ROWTYPE;
   ltype		varchar2(100);
   stype		integer;
   owner_id	integer;
   sts		varchar2(100);

   pfx		THEME%ROWTYPE;
   theme_rec	theme_types%ROWTYPE;
begin
   if not dapi.init(surl, 'RSC.UPDATE_RESOURCES', acid, iscust=>FALSE) then
      dapi.initFailed(surl,extra_parameter=>'BOOKING');
      return;
   end if;
   pfx := dapi.getLFRecord;
   dapi.setTitle(LNG5.RSC_TXT_002);
   dapi.pageOpen;
   open c0(rid);
   fetch c0 into c0rec;
   close c0;

   htp.formOpen('rsc.accept_update_resources');
   htp.formHidden('surl', surl);
   htp.formHidden('acid', acid);
   htp.formHidden('rid', rid);

   htp.tableOpen(cattributes=>'ALIGN="CENTER"');
   htp.tableRowOpen;
   htp.p('<TD>');
   htp.tableOpen(cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.RSC_TXT_101), cattributes=>pfx.qbground);
   htp.tableData(htf.formText('P_description', '100', '1000', c0rec.description), cattributes=>pfx.qcbground);
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.RSC_TXT_102), cattributes=>pfx.qbground);
   htp.tableData(htf.formText('P_max_group_size', '3', '3', c0rec.max_group_size), cattributes=>pfx.qcbground);
   htp.tableRowClose;
   htp.tableRowOpen;

   htp.tableClose;
   htp.p('</TD>');
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.p('<TD>');
   htp.formSubmit('action', LNG.CST_BUT_018);
   htp.formSubmit('action', LNG.CST_BUT_017);
   htp.formSubmit('action', LNG.CST_BUT_016);
   htp.p('</TD>');
   htp.tableRowClose;
   htp.tableClose;

   htp.formClose;
   dapi.pageClose;
exception when others then
   glbx.error_details( 'RSC', 'UPDATE_RESOURCES',errmsg=>sqlerrm);
end update_resources;

procedure accept_update_resources(
  surl varchar2,
  acid integer,
  rid integer,
  P_description varchar2,
  P_max_group_size number,
  action varchar2 default null)
as
begin
   if not dapi.init(surl, 'RSC.ACCEPT_UPDATE_RESOURCES', acid, iscust=>FALSE) then
      dapi.initFailed(surl,extra_parameter=>'BOOKING');
      return;
   end if;
   if action in (LNG.CST_BUT_017, LNG.CST_BUT_018) then
      -- Save changes
      update resources set
         resource_id           = rid,
         description           = P_description,
         max_group_size        = P_max_group_size
         where resource_id = rid;
   end if;

   if action in (LNG.CST_BUT_016, LNG.CST_BUT_018) then
      -- Save changes and/or return to maintenance screen
      maintain_resources(surl, acid);
   else
      -- Save changes and return to update screen
      update_resources(surl, acid, rid);
   end if;

end accept_update_resources;

procedure insert_resources(surl varchar2, acid integer, action varchar2 default null)
as
   c1rec  	manufacturer%ROWTYPE;
   ltype		varchar2(100);
   stype		integer;
   owner_id	integer;
   sts		varchar2(100);

   pfx		THEME%ROWTYPE;
   theme_rec	theme_types%ROWTYPE;
begin
   if not dapi.init(surl, 'RSC.INSERT_RESOURCES', acid, iscust=>FALSE) then
      dapi.initFailed(surl,extra_parameter=>'BOOKING');
      return;
   end if;
   pfx := dapi.getLFRecord;
   dapi.setTitle(LNG5.RSC_TXT_003);
   dapi.pageOpen;
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'RSC.INSERT_RESOURCES' );

   htp.formOpen('rsc.accept_insert_resources');
   htp.formHidden('surl', surl);
   htp.formHidden('acid', acid);

   htp.tableOpen(cattributes=>'ALIGN="CENTER"');
   htp.tableRowOpen;
   htp.p('<TD>');
   htp.tableOpen(cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.RSC_TXT_101), cattributes=>pfx.qbground);
   htp.tableData(htf.formText('P_description', '100', '100', ''), cattributes=>pfx.qcbground);
   htp.tableRowClose;
   htp.tableRowOpen;

   htp.tableData(htf.bold(LNG5.RSC_TXT_102), cattributes=>pfx.qbground);
   htp.tableData(htf.formText('P_max_group_size', '3', '3', ''), cattributes=>pfx.qcbground);
   htp.tableRowClose;

   htp.tableClose;

   htp.p('</TD>');
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.p('<TD>');
   htp.formSubmit('action', LNG5.BKN_TXT_141); -- Insert and continue
   htp.formSubmit('action', LNG3.ADM_TXT_396); -- Insert and return
   htp.formSubmit('action', LNG.CST_BUT_016);  -- Cancel
   htp.p('</TD>');
   htp.tableRowClose;
   htp.tableClose;

   htp.formClose;
   dapi.pageClose;
exception when others then
   glbx.error_details( 'RSC', 'INSERT_RESOURCES',errmsg=>sqlerrm);
end insert_resources;

procedure accept_insert_resources(
  surl varchar2,
  acid integer,
  P_description varchar2,
  P_max_group_size number,
  action varchar2 default null)
as
   cursor c1(cacid integer) is
   select
      pid
   from
      customer_account
   where
      aid = cacid;
   new_resource_id integer := 0;
   pid integer;
begin
   if not dapi.init(surl, 'RSC.ACCEPT_INSERT_RESOURCES', acid, iscust=>FALSE) then
      dapi.initFailed(surl,extra_parameter=>'BOOKING');
      return;
   end if;
   if action in (LNG5.BKN_TXT_141, LNG3.ADM_TXT_396) then
      open c1(acid);
      fetch c1 into pid;
      close c1;
      select s_resource.nextval into new_resource_id from dual;
      insert into resources (
         pid,
         aid,
         resource_id,
         description,
         max_group_size)
      values(
         pid,
         acid,
         new_resource_id,
         P_description,
         P_max_group_size);
   end if;
   if action in (LNG5.BKN_TXT_141) then
      -- Go back to insert screen
      insert_resources(surl, acid);
   elsif action in (LNG3.ADM_TXT_396, LNG.CST_BUT_016) then
      -- Go back to maintenance screen
      maintain_resources(surl, acid);
   end if;
exception when others then
   glbx.error_details( 'RSC', 'ACCEPT_INSERT_RESOURCES',errmsg=>sqlerrm);
end accept_insert_resources;

procedure delete_resources(surl varchar2, acid integer, rid integer)
as
   cursor c0(crid integer) is
   select
      *
   from
      resources
   where
      resource_id = crid;
   c0rec c0%ROWTYPE;

   c1rec  	manufacturer%ROWTYPE;
   ltype		varchar2(100);
   stype		integer;
   owner_id	integer;
   sts		varchar2(100);

   pfx		THEME%ROWTYPE;
   theme_rec	theme_types%ROWTYPE;
begin
   if not dapi.init(surl, 'RSC.DELETE_RESOURCES', acid, iscust=>FALSE) then
      dapi.initFailed(surl,extra_parameter=>'BOOKING');
      return;
   end if;
   pfx := dapi.getLFRecord;
   dapi.setTitle(LNG5.RSC_TXT_004);
   dapi.pageOpen;

   open c0(rid);
   fetch c0 into c0rec;
   close c0;

   htp.formOpen('rsc.accept_delete_resources');
   htp.formHidden('surl', surl);
   htp.formHidden('acid', acid);
   htp.formHidden('rid', rid);
   htp.tableOpen(cattributes=>'ALIGN="CENTER"');
   htp.tableRowOpen;
   htp.p('<TD>');
   htp.tableOpen(cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );

   htp.tableRowOpen;
   htp.tableData(htf.bold(LNG5.RSC_TXT_101), cattributes=>pfx.qbground);
   htp.tableData(c0rec.description, cattributes=>pfx.qcbground);
   htp.tableRowClose;
   htp.tableRowOpen;

   htp.tableData(htf.bold(LNG5.RSC_TXT_102), cattributes=>pfx.qbground);
   htp.tableData(c0rec.max_group_size, cattributes=>pfx.qcbground);
   htp.tableRowClose;

   htp.tableClose;

   htp.p('</TD>');
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.p('<TD>');
   htp.formSubmit('action', LNG.SLD_TXT_004); -- Delete
   htp.formSubmit('action', LNG.CST_BUT_016); -- Cancel
   htp.p('</TD>');
   htp.tableRowClose;

   htp.formClose;
   dapi.pageClose;
exception when others then
   glbx.error_details( 'RSC', 'INSERT_RESOURCES',errmsg=>sqlerrm);
end delete_resources;

procedure accept_delete_resources(surl varchar2, acid integer, rid integer, action in varchar2 default null)
as
begin
   if not dapi.init(surl, 'RSC.ACCEPT_DELETE_RESOURCES', acid, iscust=>FALSE) then
      dapi.initFailed(surl,extra_parameter=>'BOOKING');
      return;
   end if;
   if action in (LNG.SLD_TXT_004) then
      delete from resources where resource_id = rid;
   end if;

   maintain_resources(surl, acid);
exception when others then
   glbx.error_details( 'RSC', 'ACCEPT_DELETE_RESOURCES',errmsg=>sqlerrm);
end accept_delete_resources;

end rsc;

/
