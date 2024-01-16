CREATE OR REPLACE package WEBSYS.lf
as

 procedure theme_left(surl in varchar2);
 procedure mnt_themes( surl varchar2, thm in varchar2 default null, msg in varchar2 default null );
 procedure theme_options( surl varchar2, thm in varchar2, msg in varchar2 default null );
 procedure accept_theme( surl varchar2, thm in varchar2, disp in varchar2, newtheme in varchar2 default 'F', action in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, row1 in GLBX.MYARRAY, row2 in GLBX.MYARRAY, row3 in GLBX.MYARRAY, row4 in GLBX.MYARRAY);
 procedure disp_c3(surl in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2 default null );
 procedure colour_palette( surl varchar2, close_window in varchar2 default 'T' );
 procedure colour_palette_edit( surl varchar2, action in varchar2, p1 in varchar2, p2 in varchar2 default null );
 procedure copy_data( surl in varchar2, p1 in varchar2, typ in varchar2, p2 in varchar2 );
 procedure theme_right( surl varchar2, thm in varchar2 default null, disp in varchar2 default 'ICONS_STND', msg in varchar2 default null );
 procedure mnt_type_list( surl in varchar2, ttype in varchar2, template in varchar2 default 'F' );
 procedure mnt_type_frame( surl in varchar2, ttype in varchar2, template in varchar2 default 'F' );
 procedure mnt_type_edit( surl in varchar2, ttype in varchar2, typ in varchar2, template in varchar2 default 'F', msg in varchar2 default null, call in char default 'N' );
 procedure accept_mnt_type_edit( surl in varchar2, ttype in varchar2, typ in varchar2, action in varchar2 default null, call in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );
 procedure mnt_type_xref( surl in varchar2, ttype in varchar2 );
 procedure mnt_type( surl in varchar2, msg in varchar2 default null );
 procedure compare_bf( surl in varchar2, p1 in varchar2, p2 in varchar2 );
 procedure del_lf( surl varchar2, p1 in varchar2 );
 procedure mnt_master( surl in varchar2, msg in varchar2 default null );
 procedure accept_mnt_master( surl varchar2, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY, parm3 in GLBX.MYARRAY );
 procedure gcard( surl varchar2 );
 procedure mng_gcard( surl varchar2, gcard in varchar2, msg in varchar2 default null);
 procedure accept_mng_gcard( surl varchar2, gcard in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, action in varchar2);
 procedure accept_scont( surl in varchar2, thm in varchar2, p0 in GLBX.MYARRAY, p0x in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY,p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6 in GLBX.MYARRAY, p7 in GLBX.MYARRAY );
 procedure bus_change( surl in varchar2, p1 in varchar2, p2 in varchar2 default 'F' );
 procedure repall(surl in varchar2, tname varchar2);
 procedure audit_parm( surl varchar2, parm varchar2 );

end lf;

/
