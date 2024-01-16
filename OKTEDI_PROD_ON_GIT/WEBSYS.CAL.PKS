CREATE OR REPLACE package WEBSYS.cal as

function getFooter(calendarID integer) return varchar2;
function getCalendarRecord(calendarID integer) return calendar%ROWTYPE;
procedure update_calendar(surl varchar2, acid integer default null);
procedure update_cal_details(surl varchar2, acid integer default null, cid varchar2, msg varchar2 default null);
procedure accept_update_calendar_details(surl varchar2, acid integer default null, p_calendar_id varchar2 default null, p_name varchar2 default null, p_start_time varchar2 default null, p_end_time varchar2 default null, p_time_block varchar2 default null, p_expire_date varchar2 default null, p_days_in_view varchar2 default null, p_name_to_contact varchar2 default null, p_phone_to_contact varchar2 default null, p_email_to_contact varchar2 default null, p_fax_to_contact varchar2 default null, p_addr_name varchar2 default null, p_addr_name2 varchar2 default null, p_addr_street varchar2 default null, p_addr_pcode varchar2 default null, p_addr_city varchar2 default null, p_footer varchar2 default null, action varchar2 default null);
procedure accept_insert_calendar(surl varchar2, acid integer default null, p_calendar_name varchar2, action varchar2);
procedure mng_calendar(surl varchar2, acid integer default null, profid varchar2 default null);
procedure accept_mng_calendar(surl varchar2, acid integer default null, p_insert varchar2 default 'FALSE', p_calendar_id varchar2, action varchar2);
procedure enter_exclude_dates(surl varchar2, acid integer default null, calid varchar2, p_date_from varchar2, p_date_to varchar2, p_time_from varchar2, p_time_to varchar2, action varchar2, p_reason varchar2);
procedure delete_exclude_dates(surl varchar2, acid integer default null, calid varchar2, p_date_time_from varchar2, p_date_time_to varchar2);

end cal; -- end package

/
