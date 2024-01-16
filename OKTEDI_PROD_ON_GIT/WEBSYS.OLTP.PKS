CREATE OR REPLACE package WEBSYS.oltp
as

  USER_SITE	varchar2(100); -- Initially used by Strang, but can be used by other customers. See procedure identify_user

function aug(vname in varchar2, p1 in varchar2 default null, p2 in varchar2 default null, p3 in varchar2 default null, p4 in varchar2 default null, p5 in varchar2 default null, p6 in varchar2 default null, p7 in varchar2 default null, p8 in varchar2 default null, p9 in varchar2 default null ) return varchar2;
function security_role( acid in integer ) return varchar2;
function f_user_site return varchar2;

procedure display_screen( surl in varchar2, rnd in varchar2, sname in varchar2, access_in in varchar2, rid in varchar2 default null, acid in integer default NULL );
procedure process_query( surl in varchar2, rnd in varchar2, scid in integer, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY, parm3 in GLBX.MYARRAY, parm4 in GLBX.MYARRAY,
                         access_in in varchar2, rid in varchar2 default null, id in varchar2 default '1',
                         action1 in varchar2 default null, action2 in varchar2 default null, action3 in varchar2 default null, action4 in varchar2 default null, action5 in varchar2 default null, msg in varchar2 default null, sort in varchar2 default null, acid in integer default null );
procedure process_query_tab( surl in varchar2, rnd in varchar2, scid in integer, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY, parm3 in GLBX.MYARRAY,
                         access_in in varchar2, rid in varchar2 default null, id in varchar2 default '1',
                         action1 in varchar2 default null, action2 in varchar2 default null, action3 in varchar2 default null, action4 in varchar2 default null, action5 in varchar2 default null, msg in varchar2 default null, sort in varchar2 default null, acid in integer default null );

procedure accept_procedure( surl in varchar2, scid in integer, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY );
procedure display_reports( surl in varchar2, rnd in varchar2 default null );
procedure run_report( surl in varchar2, repid in integer, lvl in integer default 0, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, ptype in GLBX.MYARRAY );
procedure submit_report( surl in varchar2, repid in integer, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in varchar2, p3 in integer, p4 in integer, p5 in varchar2, p6 in varchar2, p7 in varchar2, p8 in varchar2 default LNG.SLD_TXT_021,
                         parm_dd in GLBX.MYARRAY, parm_mm in GLBX.MYARRAY, parm_yy in GLBX.MYARRAY, parm_hh24 in GLBX.MYARRAY, parm_mi in GLBX.MYARRAY, repalso in GLBX.MYARRAY, ptype in GLBX.MYARRAY );
procedure view_report( surl in varchar2, repid in integer default null, sort_on in integer default 1, msg in varchar2 default null, action in varchar2 default null, search_term in varchar2 default null );
procedure view_a_report( surl in varchar2, rid in integer, mass_view in char default 'F' );
procedure check_reports( timegap in integer );
procedure rep_options_but( surl in varchar2, p0 in GLBX.MYARRAY, search_term in varchar2 default null,
  run_report in varchar2 default null, purge in varchar2 default null, sort_date in varchar2 default null, sort_name in varchar2 default null, sort_category in varchar2 default null,
  display_all in varchar2 default null, archive in varchar2 default null, revert in varchar2 default null, vdelete in varchar2 default null, search in varchar2 default null);
procedure rep_options( surl in varchar2, action in varchar2, p0 in GLBX.MYARRAY, search_term in varchar2 default null );
procedure rep_utilities( surl in varchar2, typ in varchar2, rid in integer );
procedure process_reputl( surl in varchar2, rid in integer, act in integer, typ in varchar2, p1 in varchar2 default null );
procedure extra_submit_report( surl in varchar2, repid in integer, rq_id integer, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );

procedure olap( surl in varchar2, rnd in varchar2 default null );
procedure accept_form( surl in varchar2, repid in varchar2, p1 in GLBX.MYARRAY );

procedure quick_delete( scr_name in varchar2 );
procedure quick_create( ownr in varchar2, tbl_name in varchar2, scr_type in varchar2, scr_name in varchar2, grp_col in varchar2 default null, ordby in varchar2 default null, laf in varchar2 default null );
procedure quick_modify( scr_name in varchar2, action in varchar2, column_name in varchar2, action_column in varchar2, action_value in varchar2 );
procedure quick_modify_screen( scr_name in varchar2, action_column in varchar2, action_value in varchar2 );
procedure webservice_run_report( surl in varchar2, name in varchar2, p1 in glbx.myarray, p2 in glbx.myarray );

procedure identify_user( acid in integer );

end oltp;

/


GRANT EXECUTE ON WEBSYS.OLTP TO STRANG;
