CREATE OR REPLACE package body WEBSYS.ste as

procedure maintain_state( surl in varchar2, acid integer, sid in integer default 0 )
as
   cursor c0( cacid integer ) is
   select
      *
   from
      states
   where
      aid = cacid and
      pid = ( select pid from customer_account where aid = cacid );
   c0rec c0%ROWTYPE;

   c1rec  	manufacturer%ROWTYPE;
   ltype		varchar2( 100 );
   stype		integer;
   owner_id	integer;
   sts		varchar2( 100 );
   pfx		THEME%ROWTYPE;
   theme_rec	theme_types%ROWTYPE;
   checkbox_on varchar2( 100 ) := 'CHECKED';
begin
   if not dapi.init( surl, 'STE.MAINTAIN_STATE', acid ) then
      dapi.initFailed( surl );
      return;
   end if;
   pfx := dapi.getLFRecord;
   dapi.setTitle( LNG5.STE_TXT_001 );
   dapi.pageOpen;
   htp.p( '<CENTER>' );
   htp.formOpen( 'ste.insert_state' );
   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   htp.formSubmit( 'action', 'Insert' );
   htp.nl;
   htp.nl;
   htp.tableOpen( cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );
      htp.tableRowOpen;
         htp.tableData( htf.bold(LNG5.STE_TXT_100 ), cattributes=>pfx.qbground );
         htp.tableData( htf.bold(LNG5.STE_TXT_101 ), cattributes=>pfx.qbground );
         htp.tableData( htf.bold(LNG5.STE_TXT_102 ), cattributes=>pfx.qbground );
         htp.tableData( htf.bold(LNG5.BKN_TXT_021 ), cattributes=>pfx.qbground );
      htp.tableRowClose;
      for c0rec in c0( acid ) loop
         htp.tableRowOpen;
            htp.tableData( htf.anchor('ste.update_state?surl=' || surl || '&acid=' || acid || '&sid=' || c0rec.state_id, htf.bold(c0rec.state_id ) ), cattributes=>pfx.qbground );
            htp.tableData( c0rec.state_name, cattributes=>pfx.qcbground );
            htp.tableData( c0rec.state_tlw, cattributes=>pfx.qcbground );
            htp.tableHeader( htf.anchor('ste.delete_state?surl=' || surl || '&acid=' || acid || '&sid=' || c0rec.state_id, LNG5.BKN_TXT_021 ), cattributes=>pfx.qcbground );
         htp.tableRowClose;
      end loop;
   htp.tableClose;
   htp.nl;
   htp.formSubmit( 'action', 'Insert' );
   htp.formClose;
   htp.p( '</CENTER>' );
   dapi.pageClose;
exception when others then
   glbx.error_details( 'STE', 'MAINTAIN_STATE',errmsg=>sqlerrm );
end maintain_state;

/** Procedure name: UPDATE_STATE
   Arguments   Type           Description
   sid         integer        State ID to update
*/
procedure update_state( surl in varchar2, acid integer, sid in integer )
as
   cursor c0( csid integer ) is
   select
      *
   from
      states
   where
      state_id = csid;
   c0rec c0%ROWTYPE;

   c1rec  	manufacturer%ROWTYPE;
   ltype		varchar2( 100 );
   stype		integer;
   owner_id	integer;
   sts		varchar2( 100 );

   pfx		THEME%ROWTYPE;
   theme_rec	theme_types%ROWTYPE;
begin
   if not dapi.init( surl, 'STE.UPDATE_STATE', acid ) then
      dapi.initFailed( surl );
      return;
   end if;
   pfx := dapi.getLFRecord;
   dapi.setTitle( LNG5.STE_TXT_002 );
   dapi.pageOpen;

   open c0( sid );
   fetch c0 into c0rec;
   close c0;

   htp.formOpen( 'ste.accept_update_state' );
   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   htp.formHidden( 'P_state_id', sid);

   htp.tableOpen( cattributes=>'ALIGN="CENTER"');
   htp.tableRowOpen;
   htp.p( '<TD>');

   htp.tableOpen( cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );

   htp.tableRowOpen;
   htp.tableData( htf.bold(LNG5.STE_TXT_101), cattributes=>pfx.qbground);
   htp.tableData( htf.formText('P_state_name', '100', '100', c0rec.state_name), cattributes=>pfx.qcbground);
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold(LNG5.STE_TXT_102), cattributes=>pfx.qbground);
   htp.tableData( htf.formText('P_state_tlw', '3', '3', c0rec.state_tlw), cattributes=>pfx.qcbground);
   htp.tableRowClose;

   htp.tableClose;

   htp.p( '</TD>');
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.p( '<TD>');
   htp.formSubmit( 'action', LNG.CST_BUT_018);
   htp.formSubmit( 'action', LNG.CST_BUT_017);
   htp.formSubmit( 'action', LNG.CST_BUT_016);
   htp.p( '</TD>');
   htp.tableRowClose;
   htp.tableClose;

   htp.formClose;
   dapi.pageClose;
exception when others then
   glbx.error_details( 'STE', 'UPDATE_STATE',errmsg=>sqlerrm);
end update_state;

procedure accept_update_state(
  surl varchar2,
  acid integer,
  P_state_id      integer,
  P_state_name    varchar2,
  P_state_tlw     varchar2,
  action           varchar2 default null)
as
begin
   if not dapi.init( surl, 'STE.ACCEPT_UPDATE_STATE', acid) then
      dapi.initFailed( surl);
      return;
   end if;
   if action in ( LNG.CST_BUT_017, LNG.CST_BUT_018) then
      -- Save changes
      update states set
         state_name     = P_state_name,
         state_tlw      = P_state_tlw
         where state_id = P_state_id;
   end if;

   if action in ( LNG.CST_BUT_016, LNG.CST_BUT_018) then
      -- Save changes and/or return to maintenance screen
      maintain_state( surl, acid);
   else
      -- Save changes and return to update screen
      update_state( surl, acid, P_state_id);
   end if;
exception when others then
   glbx.error_details( 'STE', 'ACCEPT_UPDATE_STATE',errmsg=>sqlerrm);
end accept_update_state;

procedure insert_state( surl in varchar2, acid integer, action varchar2 default null)
as
   c1rec  	manufacturer%ROWTYPE;
   ltype		varchar2( 100);
   stype		integer;
   owner_id	integer;
   sts		varchar2( 100);

   pfx		THEME%ROWTYPE;
   theme_rec	theme_types%ROWTYPE;
begin
   if not dapi.init( surl, 'STE.INSERT_STATE', acid) then
      dapi.initFailed( surl);
      return;
   end if;
   pfx := dapi.getLFRecord;
   dapi.setTitle( LNG5.STE_TXT_003);
   dapi.pageOpen;
   htp.formOpen( 'ste.accept_insert_state');
   htp.formHidden( 'surl', surl);
   htp.formHidden( 'acid', acid);
   htp.tableOpen( cattributes=>'ALIGN="CENTER"');
   htp.tableRowOpen;
   htp.p( '<TD>');
   htp.tableOpen( cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );
   htp.tableRowOpen( cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND);
   htp.tableData( htf.bold(LNG5.STE_TXT_101), cattributes=>pfx.qbground);
   htp.tableData( htf.formText('P_state_name', '100', '100'), cattributes=>pfx.qcbground);
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( htf.bold(LNG5.STE_TXT_102), cattributes=>pfx.qbground);
   htp.tableData( htf.formText('P_state_tlw', '3', '3'), cattributes=>pfx.qcbground);
   htp.tableRowClose;
   htp.tableClose;
   htp.p( '</TD>');
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.p( '<TD>');
   htp.formSubmit( 'action', LNG5.BKN_TXT_141); -- Insert and continue
   htp.formSubmit( 'action', LNG3.ADM_TXT_396); -- Insert and return
   htp.formSubmit( 'action', LNG.CST_BUT_016);  -- Cancel
   htp.p( '</TD>');
   htp.tableRowClose;
   htp.tableClose;
   htp.formClose;
   dapi.pageClose;
exception when others then
   glbx.error_details( 'STE', 'INSERT_STATE',errmsg=>sqlerrm);
end insert_state;

procedure accept_insert_state(
  surl varchar2,
  acid integer,
  P_state_name varchar2,
  P_state_tlw varchar2,
  action varchar2 default null)
as
   cursor c1( cacid integer) is
   select
      pid
   from
      customer_account
   where
      aid = cacid;
   pid integer;
   new_state_id integer;
begin
   if not dapi.init( surl, 'STE.ACCEPT_INSERT_STATE', acid) then
      dapi.initFailed( surl);
      return;
   end if;
   if action in ( LNG5.BKN_TXT_141, LNG3.ADM_TXT_396) then
      open c1( acid);
      fetch c1 into pid;
      close c1;
      select s_state.nextval into new_state_id from dual;
      insert into states (
         pid,
         aid,
         state_id,
         state_tlw,
         state_name)
      values(
         pid,
         acid,
         new_state_id,
         P_state_tlw,
         P_state_name);
   end if;

   if action in ( LNG5.BKN_TXT_141) then
      -- Go back to insert screen
      insert_state( surl, acid);
   end if;

   if action in ( LNG3.ADM_TXT_396, LNG.CST_BUT_016) then
      -- Go back to maintenance screen
      maintain_state( surl, acid);
   end if;
exception when others then
   glbx.error_details( 'STE', 'ACCEPT_INSERT_STATE',errmsg=>sqlerrm);
end accept_insert_state;

procedure delete_state( surl in varchar2, acid integer, sid in integer)
as
   cursor c0( csid integer) is
   select
      *
   from
      states
   where
      state_id = csid;
   c0rec c0%ROWTYPE;

   c1rec  	manufacturer%ROWTYPE;
   ltype		varchar2( 100);
   stype		integer;
   owner_id	integer;
   sts		varchar2( 100);

   pfx		THEME%ROWTYPE;
   theme_rec	theme_types%ROWTYPE;
begin
   if not dapi.init( surl, 'STE.DELETE_STATE', acid) then
      dapi.initFailed( surl);
      return;
   end if;
   pfx := dapi.getLFRecord;
   dapi.setTitle( LNG5.STE_TXT_004);
   dapi.pageOpen;
   open c0( sid);
   fetch c0 into c0rec;
   close c0;
   htp.formOpen( 'ste.accept_delete_state');
   htp.formHidden( 'surl', surl);
   htp.formHidden( 'acid', acid);
   htp.formHidden( 'sid', sid);
   htp.tableOpen( cattributes=>'ALIGN="CENTER"');
   htp.tableRowOpen;
   htp.p( '<TD>');
   htp.tableOpen( cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );
   htp.tableRowOpen;
   htp.tableData( htf.bold(LNG5.STE_TXT_101), cattributes=>pfx.qbground);
   htp.tableData( c0rec.state_name, cattributes=>pfx.qcbground);
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( htf.bold(LNG5.STE_TXT_102), cattributes=>pfx.qbground);
   htp.tableData( c0rec.state_tlw, cattributes=>pfx.qcbground);
   htp.tableRowClose;
   htp.tableClose;
   htp.p( '</TD>');
   htp.tableRowClose;
   htp.tableROwOpen;
   htp.p( '<TD>');
   htp.formSubmit( 'action', LNG.SLD_TXT_004); -- Delete
   htp.formSubmit( 'action', LNG.CST_BUT_016); -- Cancel
   htp.p( '</TD>');
   htp.tableRowClose;
   htp.tableClose;
   htp.formClose;
   dapi.pageClose;
exception when others then
   glbx.error_details( 'STE', 'DELETE_STATE',errmsg=>sqlerrm);
end delete_state;

procedure accept_delete_state( surl in varchar2, acid integer, sid in integer, action in varchar2 default null)
as
begin
   if not dapi.init( surl, 'STE.ACCEPT_DELETE_STATE', acid) then
      dapi.initFailed( surl);
      return;
   end if;
   if action in ( LNG.SLD_TXT_004) then
      delete from states where state_id = sid;
   end if;
   maintain_state( surl, acid);
exception when others then
   glbx.error_details( 'STE', 'ACCEPT_DELETE_STATE',errmsg=>sqlerrm);
end accept_delete_state;

procedure setup_filter( surl varchar2)
as
   sFilter varchar( 200);
begin
   sFilter := '';
end setup_filter;

function get_state_lov( p_Name varchar2, p_SelectedValue varchar2 default null, empty_rec boolean default FALSE)
return varchar2
as
   result varchar2( 2000);
begin
   result := htf.formSelectOpen( p_name);

   if empty_rec then
      result := result || htf.formSelectOption( '---- Please select a State ----', cattributes=>'SELECTED VALUE=""');
   end if;

   for c0rec in ( select * from states order by state_name) loop
      if c0rec.state_tlw = p_SelectedValue then
         result := result || htf.formSelectOption( c0rec.state_name, cattributes=>'SELECTED VALUE="' || c0rec.state_tlw || '"');
      else
         result := result || htf.formSelectOption( c0rec.state_name, cattributes=>'VALUE="' || c0rec.state_tlw || '"');
      end if;
   end loop;

   result := result || htf.formSelectClose;

   return result;
end get_state_lov;

function getStateTLW( pStateId integer) return varchar2
as
   cursor c1( csid integer) is
      select state_tlw
      from states
      where state_id = csid;
   lStateTLW states.state_tlw%TYPE;
begin
   open c1( pStateId );
   fetch c1 into lStateTLW;
   close c1;

   return lStateTLW;

   exception
      when others then
         raise; -- reraise the exception
end getStateTLW;

end ste; -- end package

/
