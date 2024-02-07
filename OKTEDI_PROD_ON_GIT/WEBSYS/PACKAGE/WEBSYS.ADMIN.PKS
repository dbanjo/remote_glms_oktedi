CREATE OR REPLACE package WEBSYS.admin
as

 DEFAULT_VARIATION_COMPLEXITY	CONSTANT VARCHAR2(20) := 'DEFAULT COMPLEXITY';
 DEFAULT_GRADE_SCORE		CONSTANT VARCHAR2(40) := 'UNIVERSITY';
 VERSION			CONSTANT VARCHAR2(40) := 'V4.0';
 REPORT_WEEK_ON			CONSTANT VARCHAR2(10) := 'MON';
 BODY_BACKGROUND		CONSTANT VARCHAR2(30) := '<BODY bgcolor="#FFFFFF">';
 QUESTION_NOT_DONE		CONSTANT VARCHAR2(3) := 'o';
 QUESTION_DONE			CONSTANT VARCHAR2(3) := '*';
 INDICATE_GROUP			CONSTANT VARCHAR2(3) := '#';
 JOB_NAME			CONSTANT VARCHAR2(100) := 'admin.daily_monitor;';
 TIMEGAP			CONSTANT VARCHAR2(100) := '05'; -- Run every 5 minutes
 TIME_FREQUENCY			CONSTANT VARCHAR2(100) := '((60*' || TIMEGAP || ')/(24*60*60))';


 TYPE COLUMN_ARRAY IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;

 function anniversaries return boolean;
 procedure manage_jobs(surl varchar2);
 procedure submit_batch(surl varchar2);
 procedure stop_batch(surl varchar2);
 procedure daily_monitor;
 procedure force_opt(surl varchar2);
 procedure force_storage(surl varchar2);
 procedure start_online_backup;
 procedure stop_online_backup;

 -- Health Check:
 --
 -- HTML Procedures and Functions
 --
 procedure web_main(surl varchar2);
 function lov_html( ltype in varchar2, pname in varchar2, selected_value in varchar2 ) return varchar2;
 function lov_health( pname in varchar2, selected_value in number ) return varchar2;
 function drop_old_directories return boolean;
 procedure accept_new_check( surl in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2 );
 procedure edit_by_question( surl in varchar2, hid in integer );
 procedure edit_by_group( surl in varchar2, hid in integer );
 procedure display_questions( surl in varchar2, hid in integer, pcode in varchar2 default null, msg in varchar2 default null );
 procedure display_groups( surl in varchar2, hid in integer, msg in varchar2 default null );
 procedure instructions( surl in varchar2, typ in varchar2 );
 procedure edit_question( surl in varchar2, hid in integer, pcode in varchar2 );
 procedure accept_question( surl in varchar2, hid in integer, pcode in varchar2, p1 in varchar2, p2 in varchar2 );
 procedure edit_group( surl in varchar2, hid in integer, pcode in varchar2 );
 procedure accept_group( surl in varchar2, hid in integer, pcode in COLUMN_ARRAY, p1 in COLUMN_ARRAY, p2 in COLUMN_ARRAY );
 procedure web_report( surl in varchar2, hid in integer );
 procedure compare_two( surl in varchar2, p1 in varchar2, p2 in varchar2 );
 procedure run_report( surl in varchar2, hid in integer, q1 in varchar2 default 'F', q2 in varchar2 default 'F', q3 in varchar2 default 'F', q4 in varchar2 default 'F',
                       q5 in varchar2 default 'F', q6 in varchar2 default 'F', q7 in varchar2 default 'F' );
 procedure confirm_delete( surl in varchar2, hid in integer );
 procedure delete_health_check( surl in varchar2, hid in integer );
 procedure reset_check( surl in varchar2, hid in integer );
 procedure edit_header( surl in varchar2, hid in integer );
 procedure accept_header( surl in varchar2, hid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2, p8 in varchar2);
 procedure manage_batch_queue(surl in varchar2, msg in varchar2);
 procedure accept_manage_batch_queue(surl varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY);
 procedure add_to_shared_pool;

end;

/
