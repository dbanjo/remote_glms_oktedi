CREATE OR REPLACE package body WEBSYS.cal as
/*
 * File name   : cal.sql xx
 * Author      : Martijn van den Boogaard
 * Date/Time   : 18 Feb 2002 09:58:13
 * Description : The calendar options
*/

PACKAGE_NAME constant varchar2(100) := 'CAL';
PAGE_TITLE varchar2(200) := '';
PROC_NAME varchar2(100) := '';
CRLF     varchar2(10)  := CHR(13) || CHR(10);
G_CALENDAR_RECORD calendar%ROWTYPE;
G_FOOTER calendar.footer%TYPE;

function getFooter(calendarID integer) return varchar2
as
   rDummy calendar%ROWTYPE;
begin
   if G_CALENDAR_RECORD.calendar_id is null then
      rDummy := getCalendarRecord(calendarID);
      G_FOOTER := rDummy.footer;
   end if;
   return G_FOOTER;
end getFooter;

function getTimeBlock(p_name varchar2, p_SelectedValue varchar2 default null, empty_rec boolean default FALSE)
return varchar2
as
   result varchar2(2000);
begin
   result := htf.formSelectOpen(cname=>p_name);
   if empty_rec then
      result := result || htf.formSelectOption(null, cattributes=>'SELECTED VALUE=""');
   end if;
   for i in 1..60 loop
      if i = TO_NUMBER(p_SelectedValue) then
         result := result || htf.formSelectOption(TO_CHAR(i, '09'), cattributes=>'SELECTED') || CRLF;
      else
         result := result || htf.formSelectOption(TO_CHAR(i, '09')) || CRLF;
      end if;
   end loop;
   result := result || htf.formSelectClose;
   return result;
end getTimeBlock;

function getCalendarRecord(calendarID integer) return calendar%ROWTYPE
as
   cursor c1 is select * from calendar where calendar_id = calendarID;
begin
   if (G_CALENDAR_RECORD.calendar_id is null) OR (G_CALENDAR_RECORD.calendar_id != calendarID) then
      open c1;
      fetch c1 into G_CALENDAR_RECORD;
      close c1;
   end if;
   return G_CALENDAR_RECORD;
end getCalendarRecord;

function get_calendar_lov(p_pid integer, p_Name varchar2, p_SelectedValue varchar2 default null, empty_rec boolean default FALSE)
return varchar2
as
   cursor c0(cpid integer) is
   select
      *
   from
      calendar
   where
      pid = cpid
   order by
      name;
   c0rec c0%ROWTYPE;

   result varchar2(2000);
begin
   result := htf.formSelectOpen(p_name) || CRLF;
   if empty_rec then
      result := result || htf.formSelectOption(null, cattributes=>'SELECTED VALUE=""') || CRLF;
   end if;
   for c0rec in c0(p_pid) loop
      if c0rec.calendar_id = p_SelectedValue then
         result := result || htf.formSelectOption(c0rec.name, cattributes=>'SELECTED VALUE="' || c0rec.calendar_id || '"') || CRLF;
      else
         result := result || htf.formSelectOption(c0rec.name, cattributes=>'VALUE="' || c0rec.calendar_id || '"') || CRLF;
      end if;
   end loop;
   result := result || htf.formSelectClose || CRLF;
   return result;
end get_calendar_lov;

procedure update_calendar(surl varchar2, acid integer default null)
as
   -- Fetch calendar attributes
   cursor c1(cpid integer) is
   select
      *
   from
      calendar
   where
      pid = cpid
   order by
      upper(name);
   c1rec c1%ROWTYPE;

   lAccountId	integer;
   pfx	THEME%ROWTYPE;
begin
   if not dapi.init(surl, 'CAL.UPDATE_CALENDAR', acid, iscust=>FALSE) then
      dapi.initFailed(surl,extra_parameter=>'BOOKING');
   end if;
   lAccountId := dapi.getAccountId;
   pfx := dapi.getLFRecord;
   dapi.setTitle(LNG5.BKN_TXT_109);
   dapi.pageOpen;
   htp.p('<center>');
   htp.tableOpen(cattributes=>'cellpadding="2" cellspacing="2" border="1"');
      htp.tableRowOpen;
         htp.tableData(htf.bold(LNG5.CAL_TXT_003), cattributes=>pfx.qbground);
         htp.tableData(htf.bold(LNG5.BKN_TXT_101), cattributes=>pfx.qbground);
      htp.tableRowClose;
      for c1rec in c1(NVL(acid, lAccountId)) loop
         htp.tableRowOpen;
            htp.tableData(htf.anchor('cal.update_cal_details?surl=' || surl || '&acid=' || acid || '&cid=' || c1rec.calendar_id, htf.bold(c1rec.name)),cattributes=>pfx.qcbground);
            begin
               htp.tableData(TO_CHAR(c1rec.expire_date, LNG.MASK),cattributes=>pfx.qcbground);
               exception when others then NULL;
            end;
         htp.tableRowClose;
      end loop;
   htp.tableClose;
   htp.formOpen('cal.accept_insert_calendar');
   htp.formHidden('surl', surl);
   htp.formHidden('acid', acid);
   htp.tableOpen(cattributes=>'cellpadding="2" cellspacing="2" border="1"');
      htp.tableRowOpen;
         htp.tableData(htf.bold(LNG5.CAL_TXT_006), ccolspan=>'2', cattributes=>pfx.qbground);
      htp.tableRowClose;
      htp.tableRowOpen;
         htp.tableData(htf.bold(LNG5.BKN_TXT_097), cattributes=>pfx.qcbground);
         htp.tableData(htf.formText('p_calendar_name'), cattributes=>pfx.qcbground);
      htp.tableRowClose;
   htp.tableClose;
   htp.formSubmit('action', LNG2.PBK_TXT_012);
   htp.formClose;
   dapi.pageClose;
exception when others then
   glbx.error_details('CAL', 'UPDATE_CALENDAR', errmsg=>sqlerrm);
end update_calendar;

procedure update_cal_details(surl varchar2, acid integer default null, cid varchar2, msg varchar2 default null)
as
   --
   -- Fetch calendar attributes
   --
   cursor c1(cpid integer) is select * from calendar where pid = cpid order by upper(name);
   c1rec c1%ROWTYPE;

   cursor c2(ccid integer) is select * from calendar where calendar_id = ccid;
   c2rec c2%ROWTYPE;

   cursor c3(ccid integer) is
      select * from excluded_calendar_times where calendar_id = ccid
      order by date_time_from;
   c3rec c3%ROWTYPE;

   /*
      Work variables
   */
   owner_id	integer;
   pfx		THEME%ROWTYPE;
begin
   if not dapi.init(surl, 'BKN.UPDATE_CAL_DETAILS', iscust=>FALSE) then
      dapi.initFailed(surl,extra_parameter=>'BOOKING');
   end if;
   pfx := dapi.getLFRecord;
   dapi.pageOpen;
   open c2(cid);
   fetch c2 into c2rec;
   close c2;
   htp.p('<CENTER>');
   if msg is not null then
      htp.p('<font size="+3" color="#' || pfx.error_text_colour || '" FACE="' || pfx.error_text_font || '">'|| msg || '</font>' );
   end if;
   htp.formOpen('cal.accept_update_calendar_details');
   htp.formHidden('surl', surl);
   htp.formHidden('p_calendar_id', cid);
   htp.tableOpen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
    htp.tableRowOpen;
     htp.tableData(htf.bold(LNG5.BKN_TXT_097), cattributes=>pfx.qbground);
     htp.tableData(htf.formText('p_name', cvalue=>c2rec.name), cattributes=>pfx.qcbground);
    htp.tableRowClose;
    htp.tableRowOpen;
     htp.tableData(htf.bold(LNG5.BKN_TXT_098 || ' (' || LNG.TSMASK_ONLY || ')'), cattributes=>pfx.qbground);
     htp.tableData(htf.formText('p_start_time', cvalue=>TO_CHAR(c2rec.start_time, 'HH24:MI')), cattributes=>pfx.qcbground);
    htp.tableRowClose;
    htp.tableRowOpen;
     htp.tableData(htf.bold(LNG5.BKN_TXT_099 || ' (' || LNG.TSMASK_ONLY || ')'), cattributes=>pfx.qbground);
     htp.tableData(htf.formText('p_end_time', cvalue=>TO_CHAR(c2rec.end_time, 'HH24:MI')), cattributes=>pfx.qcbground);
    htp.tableRowClose;
    htp.tableRowOpen;
     htp.tableData(htf.bold(LNG5.BKN_TXT_100), cattributes=>pfx.qbground);
     htp.tableData(getTimeBlock('p_time_block', c2rec.time_block), cattributes=>pfx.qcbground);
    htp.tableRowClose;
    htp.tableRowOpen;
     htp.tableData(htf.bold(LNG5.BKN_TXT_101 || ' (' || LNG.MASK || ')'), cattributes=>pfx.qbground);
     htp.tableData(htf.formText('p_expire_date', cvalue=>TO_CHAR(c2rec.expire_date, LNG.MASK)), cattributes=>pfx.qcbground);
    htp.tableRowClose;
    htp.tableRowOpen;
     htp.tableData(htf.bold(LNG5.BKN_TXT_102), cattributes=>pfx.qbground);
     htp.tableData(htf.formText('p_days_in_view', cvalue=>TO_CHAR(c2rec.days_in_view)), cattributes=>pfx.qcbground);
    htp.tableRowClose;
    htp.tableRowOpen;
     htp.tableData(htf.bold(LNG5.BKN_TXT_103), ccolspan=>'2', cattributes=>pfx.qbground);
    htp.tableRowClose;
    htp.tableRowOpen;
     htp.tableData(htf.bold(LNG5.BKN_TXT_104), cattributes=>pfx.qbground);
     htp.tableData(htf.formText('p_name_to_contact', cvalue=>c2rec.name_to_contact), cattributes=>pfx.qcbground);
    htp.tableRowClose;
    htp.tableRowOpen;
     htp.tableData(htf.bold(LNG.ORD_TXT_180), cattributes=>pfx.qbground);
     htp.tableData(htf.formText('p_phone_to_contact', cvalue=>c2rec.phone_to_contact), cattributes=>pfx.qcbground);
    htp.tableRowClose;
    htp.tableRowOpen;
     htp.tableData(htf.bold(LNG.PHG_TXT_336), cattributes=>pfx.qbground);
     htp.tableData(htf.formText('p_fax_to_contact', cvalue=>c2rec.fax_to_contact), cattributes=>pfx.qcbground);
    htp.tableRowClose;
    htp.tableRowOpen;
     htp.tableData(htf.bold(LNG.PHG_TXT_301), cattributes=>pfx.qbground);
     htp.tableData(htf.formText('p_email_to_contact', cvalue=>c2rec.email_to_contact), cattributes=>pfx.qcbground);
    htp.tableRowClose;
    htp.tableRowOpen;
     htp.tableData(htf.bold(LNG3.ADM_TXT_635), cattributes=>pfx.qbground);
     htp.tableData(htf.formText('p_addr_name', cvalue=>c2rec.addr_name), cattributes=>pfx.qcbground);
    htp.tableRowClose;
    htp.tableRowOpen;
     htp.tableData(htf.bold(LNG.PHG_TXT_084), cattributes=>pfx.qbground);
     htp.tableData(htf.formText('p_addr_name2', cvalue=>c2rec.addr_name2), cattributes=>pfx.qcbground);
    htp.tableRowClose;
    htp.tableRowOpen;
     htp.tableData(htf.bold(LNG.CST_TXT_113), cattributes=>pfx.qbground);
     htp.tableData(htf.formText('p_addr_street', cvalue=>c2rec.addr_street), cattributes=>pfx.qcbground);
    htp.tableRowClose;
    htp.tableRowOpen;
     htp.tableData(htf.bold(LNG.CST_TXT_115), cattributes=>pfx.qbground);
     htp.tableData(htf.formText('p_addr_city', cvalue=>c2rec.addr_city), cattributes=>pfx.qcbground);
    htp.tableRowClose;
    htp.tableRowOpen;
     htp.tableData(htf.bold(LNG.CST_TXT_118), cattributes=>pfx.qbground);
     htp.tableData(htf.formText('p_addr_pcode', cvalue=>c2rec.addr_pcode), cattributes=>pfx.qcbground);
    htp.tableRowClose;
    htp.tableRowOpen;
     htp.tableData(htf.bold('Extra details'), ccolspan=>'2', cattributes=>pfx.qbground);
    htp.tableRowClose;
    htp.tableRowOpen;
     htp.tableData(htf.bold('Footer'), cattributes=>pfx.qbground);
     htp.tableData(htf.formText('p_footer', cvalue=>REPLACE(REPLACE(REPLACE(c2rec.footer, '<', '&lt;'), '>', '&gt;'), '"', '&quot;')), cattributes=>pfx.qcbground);
    htp.tableRowClose;
   htp.tableClose;
   htp.formSubmit('action', LNG.GLB_TXT_060);
   htp.formSubmit('action', LNG.SLD_TXT_004);
   htp.formClose;

   htp.formOpen('cal.enter_exclude_dates');
   htp.formHidden('surl', surl);
   htp.formHidden('calid', cid);
   htp.tableOpen(cattributes=>'cellpadding=0 cellspacing=0 border=1');
      htp.tableRowOpen;
         htp.tableData(LNG5.BKN_TXT_105, ccolspan=>'6', cattributes=>pfx.qbground);
      htp.tableRowClose;
      htp.tableRowOpen;
         htp.tableData(htf.bold(LNG5.BKN_TXT_054 || '<br>(' || LNG.MASK || ')'), cattributes=>pfx.qbground);
         htp.tableData(htf.bold(LNG5.BKN_TXT_055 || '<br>(' || LNG.MASK || ')'), cattributes=>pfx.qbground);
         htp.tableData(htf.bold(LNG5.BKN_TXT_093 || '<br>(' || LNG.TSMASK_ONLY || ')'), cattributes=>pfx.qbground);
         htp.tableData(htf.bold(LNG5.BKN_TXT_094 || '<br>(' || LNG.TSMASK_ONLY || ')'), cattributes=>pfx.qbground);
         htp.tableData(htf.bold(LNG5.BKN_TXT_096), cattributes=>pfx.qbground);
         htp.tableData(htf.bold(LNG5.BKN_TXT_021), cattributes=>pfx.qbground);
      htp.tableRowClose;
         for c3rec in c3(cid) loop
            htp.tableRowOpen;
            htp.tableData(TO_CHAR(c3rec.date_time_from, LNG.MASK), cattributes=>pfx.qcbground);
            htp.tableData(TO_CHAR(c3rec.date_time_to, LNG.MASK), cattributes=>pfx.qcbground);
            htp.tableData(TO_CHAR(c3rec.date_time_from, LNG.TSMASK_ONLY), cattributes=>pfx.qcbground);
            htp.tableData(TO_CHAR(c3rec.date_time_to, LNG.TSMASK_ONLY), cattributes=>pfx.qcbground);
            htp.tableData(c3rec.reason, cattributes=>pfx.qcbground);
            htp.tableData(htf.anchor('cal.delete_exclude_dates?surl=' || surl || '&calid=' || cid || '&p_date_time_from=' || TO_CHAR(c3rec.date_time_from, LNG.TSMASK) || '&p_date_time_to=' || TO_CHAR(c3rec.date_time_to, LNG.TSMASK), LNG5.BKN_TXT_021), cattributes=>pfx.qcbground);
            htp.tableRowClose;
         end loop;
      htp.tableRowOpen;
         htp.tableData(htf.formText('p_date_from', cvalue=>''), cattributes=>pfx.qcbground);
         htp.tableData(htf.formText('p_date_to', cvalue=>''), cattributes=>pfx.qcbground);
         htp.tableData(htf.formText('p_time_from', cvalue=>''), cattributes=>pfx.qcbground);
         htp.tableData(htf.formText('p_time_to', cvalue=>''), cattributes=>pfx.qcbground);
         htp.tableData(htf.formText('p_reason', cvalue=>''), cattributes=>pfx.qcbground);
         htp.tableData('&nbsp;', cattributes=>pfx.qcbground);
      htp.tableRowClose;
   htp.tableClose;
   htp.formSubmit('action',LNG5.BKN_TXT_106);
   htp.formClose;

   htp.p('</CENTER>');
   dapi.pageClose;
exception when others then
   glbx.error_details(PACKAGE_NAME, PROC_NAME, errmsg=>sqlerrm);
end update_cal_details;

procedure enter_exclude_dates(
  surl varchar2,
  acid integer default null,
  calid varchar2,
  p_date_from varchar2,
  p_date_to varchar2,
  p_time_from varchar2,
  p_time_to varchar2,
  action varchar2,
  p_reason varchar2)
as
   msg           varchar2(1000) := NULL;
   lDateTimeFrom date;
   lDateTimeTo   date;
begin
   begin
      lDateTimeFrom := TO_DATE(p_date_from || ' ' || p_time_from, LNG.MASK || ' ' || LNG.TSMASK_ONLY);
      exception
         when others then
            msg := msg || '<br>' || LNG3.ADM_TXT_633 || '''' || p_date_from || ' ' || p_time_from || '''';
            lDateTimeFrom := NULL;
   end;
   begin
      lDateTimeTo := TO_DATE(p_date_to || ' ' || p_time_to, LNG.MASK || ' ' || LNG.TSMASK_ONLY);
      exception
         when others then
            msg := msg || '<br>' || LNG3.ADM_TXT_633 || '''' || p_date_to || ' ' || p_time_to || '''';
            lDateTimeTo := NULL;
   end;
   if msg is NULL then
      insert into excluded_calendar_times
      (calendar_id,
       date_time_from,
       date_time_to,
       reason)
      values
      (calid,
       lDateTimeFrom,
       lDateTimeTo,
       p_reason
      );
      commit;
   end if;
   update_cal_details(surl, acid, calid, msg);
exception when others then
   glbx.error_details(PACKAGE_NAME, PROC_NAME, errmsg=>sqlerrm);
end enter_exclude_dates;

procedure delete_exclude_dates(surl varchar2, acid integer default null, calid varchar2, p_date_time_from varchar2, p_date_time_to varchar2)
as
begin
   delete from excluded_calendar_times
   where (calendar_id = calid) and
      date_time_from = TO_DATE(p_date_time_from, LNG.TSMASK) and
      date_time_to   = TO_DATE(p_date_time_to, LNG.TSMASK);
   update_cal_details(surl, acid, calid);
end delete_exclude_dates;

procedure accept_update_calendar_details(
   surl varchar2,
   acid integer default null,
   p_calendar_id varchar2 default null,
   p_name varchar2 default null,
   p_start_time varchar2 default null,
   p_end_time varchar2 default null,
   p_time_block varchar2 default null,
   p_expire_date varchar2 default null,
   p_days_in_view varchar2 default null,
   p_name_to_contact varchar2 default null,
   p_phone_to_contact varchar2 default null,
   p_email_to_contact varchar2 default null,
   p_fax_to_contact varchar2 default null,
   p_addr_name varchar2 default null,
   p_addr_name2 varchar2 default null,
   p_addr_street varchar2 default null,
   p_addr_pcode varchar2 default null,
   p_addr_city varchar2 default null,
   p_footer varchar2 default null,
   action varchar2 default null)
as
   lDate date;
   lStartTime date;
   lEndTime   date;
   lTimeBlock integer;
   lDays      integer;
begin
   if not dapi.init(surl, 'BKN.ACCEPT_UPDATE_CALENDAR_DETAILS', iscust=>FALSE) then
      dapi.initFailed(surl,extra_parameter=>'BOOKING');
   end if;
   if action = LNG.SLD_TXT_004 then
      delete from calendar where calendar_id = p_calendar_id;
      update_calendar(surl);
   elsif action = LNG.GLB_TXT_060 then
      --
      -- Trap exceptions
      --
      begin
         lDate := TO_DATE(p_expire_date, LNG.MASK);
         exception
            when others then
               lDate := NULL;
      end;
      begin
         lStartTime := TO_DATE(p_start_time, LNG.TSMASK_ONLY);
         exception
            when others then
               lStartTime := NULL;
      end;
      begin
         lEndTime := TO_DATE(p_end_time, LNG.TSMASK_ONLY);
         exception
            when others then
               lEndTime := NULL;
      end;
      begin
         lTimeBlock := TO_NUMBER(p_time_block);
         exception
            when others then
               lTimeBlock := NULL;
      end;
      begin
         lDays := TO_NUMBER(p_days_in_view);
         exception
            when others then
               lDays := NULL;
      end;
      update calendar set
         name = p_name,
         start_time = lStartTime,
         end_time = lEndTime,
         time_block = lTimeBlock,
         expire_date = lDate,
         days_in_view = lDays,
         name_to_contact = p_name_to_contact,
         phone_to_contact = p_phone_to_contact,
         email_to_contact = p_email_to_contact,
         fax_to_contact = p_fax_to_contact,
         addr_name = p_addr_name,
         addr_name2 = p_addr_name2,
         addr_street = p_addr_street,
         addr_city = p_addr_city,
         addr_pcode = p_addr_pcode,
         footer = p_footer
      where calendar_id = p_calendar_id;
      update_cal_details(surl, acid, p_calendar_id);
   end if;
   exception
      when others then
         glbx.error_details(PACKAGE_NAME, PROC_NAME, errmsg=>sqlerrm);
end accept_update_calendar_details;

procedure accept_insert_calendar(surl varchar2, acid integer default null, p_calendar_name varchar2, action varchar2)
as
   -- Fetch calendar attributes
   cursor c1(cpid integer) is select * from calendar where pid = cpid order by upper(name);
   c1rec c1%ROWTYPE;

   -- Security variables
   owner_id	integer;

   -- Work variables
   new_calendar_id integer;
begin
   if not dapi.init(surl, 'CAL.ACCEPT_INSERT_CALENDAR', iscust=>FALSE) then
      dapi.initFailed(surl,extra_parameter=>'BOOKING');
      return;
   end if;
   select s_calendar.nextval into new_calendar_id from dual;
   insert into calendar(calendar_id, pid, name) values(new_calendar_id, owner_id, p_calendar_name);
   update_cal_details(surl, acid, new_calendar_id);
end accept_insert_calendar;

procedure mng_calendar(surl varchar2, acid integer default null, profid varchar2 default null)
as
   -- Retrieve calendar details
   cursor c1(cpid integer, cacid integer) is
   select
      cm.aid mapped_aid,
      cm.calendar_id mapped_cid
   from
      calendar c,
      calendar_map cm
   where
      c.calendar_id = cm.calendar_id and
      c.pid = cpid and
      cm.aid = cacid;
   c1rec c1%ROWTYPE;

   -- Security variables
   lAccountId	integer;

   -- Look and feel variables
   pfx		THEME%ROWTYPE;

   -- Work variables
   attached_aid integer;
   show_empty    boolean;
begin
   if not dapi.init(surl, 'CAL.MNG_CALENDAR', acid, iscust=>FALSE) then
      dapi.initFailed(surl,extra_parameter=>'BOOKING');
      return;
   end if;
   pfx := dapi.getLFRecord;
   lAccountId := dapi.getAccountId;
   dapi.pageOpen;
   open c1(lAccountId, acid);
   fetch c1 into c1rec;
   if c1%NOTFOUND then
      close c1;
      attached_aid := 0;
   else
      close c1;
      attached_aid := c1rec.mapped_aid;
   end if;
   show_empty := (attached_aid = 0);

   htp.formOpen('cal.accept_mng_calendar');
   htp.formHidden('surl', surl);
   htp.formHidden('acid', acid);
   if show_empty then
      htp.formHidden('p_insert', 'TRUE');
   else
      htp.formHidden('p_insert', 'FALSE');
   end if;

   htp.tableOpen(cattributes=>'ALIGN="CENTER"');
    htp.tableRowOpen;
     htp.p('<TD>');
      htp.tableOpen(cattributes=>'cellpadding=2 cellspacing=2 border=1');
       htp.tableRowOpen;
        htp.tableData(htf.bold('Calendar'), cattributes=>pfx.qbground || 'valign="CENTER" align="LEFT"');
        htp.tableData(get_calendar_lov(lAccountId, 'p_calendar_id', c1rec.mapped_cid, show_empty), cattributes=>pfx.qcbground || 'valign="CENTER" align="LEFT"');
       htp.tableRowClose;
      htp.tableClose;
     htp.p('</TD>');
    htp.tableRowClose;
    htp.tableRowOpen;
     htp.tableData(htf.formSubmit('action', 'Modify changes'));
    htp.tableRowClose;
   htp.tableClose;

   htp.formClose;

   htp.bodyClose;
   htp.htmlClose;

   exception when others then
      glbx.error_details(PACKAGE_NAME, PROC_NAME, errmsg=>sqlerrm);
end mng_calendar;

procedure accept_mng_calendar(surl varchar2, acid integer default null, p_insert varchar2 default 'FALSE', p_calendar_id varchar2, action varchar2)
as
begin
   if action = 'Modify changes' then
      if p_insert = 'TRUE' then
         insert into calendar_map values(p_calendar_id, acid);
      else
         update calendar_map set calendar_id = p_calendar_id where aid = acid;
      end if;
   end if;
   mng_calendar(surl, acid);
end accept_mng_calendar;

end cal; -- end package

/
