CREATE OR REPLACE package WEBSYS.pfm
as

 TYPE myarray 	IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
 TYPE listint 	IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;

 procedure main( surl in varchar2, acid in integer, msg in varchar2 default null );
 procedure ftp_upload( surl in varchar2, acid in integer, msg in varchar2 default null, p1 in varchar2 default null, p2 in varchar2 default null, p3 in varchar2 default null, p4 in varchar2 default null, p5 in varchar2 default null, p6 in varchar2 default null);
 procedure accept_ftp_load( surl in varchar2, acid in integer, p1 in GLBX.MYARRAY, p2 in varchar2, p3 in varchar2, p4 in GLBX.MYARRAY, p5 in varchar2, p6 in varchar2, p7 in char default 'F', p8 in char default NULL );
 procedure purchrep( surl in varchar2, msg in varchar2 default null, template in varchar2 default null );
 procedure accept_purchrep( surl in varchar2, p1 in GLBX.MYARRAY, p1m in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, d1 in GLBX.MYARRAY, d2 in GLBX.MYARRAY, d3r in varchar2, d3s in varchar2, d3t in varchar2,
                            p2 in varchar2, p3 in varchar2, p6a in varchar2, p6b in varchar2, action in varchar2, fnt in varchar2, template in varchar2, template2 in varchar2 default null,
                            d5a in varchar2, d5g in varchar2, d5af in varchar2, d5b in varchar2, d5c in varchar2, d5d in varchar2,  d5e in varchar2,  d5f in varchar2, dspt in char default 'F',
                            p7a in varchar2, p7b in varchar2, p8a in varchar2, p8b in varchar2, p8c in varchar2, p9a in varchar2, p9b in varchar2, p9c in varchar2, p10 in varchar2,
                            p5a in char default 'F', p5b in char default null, p5c in char default 'F', r1 in char default 'F', r2 in char default 'F', d4r in varchar2 default null, r4z in varchar2 default 'F', xdt in varchar2 default 'F',
                            d4z in varchar2 default null, d4n in varchar2 default null, d4o in varchar2 default null, d4a in varchar2 default null, d4b in varchar2 default null, d4c in varchar2 default null, d4d in varchar2 default null, d4e in varchar2 default null, d4f in varchar2 default null, d4g in varchar2 default null, d4h in varchar2 default null, d4w in varchar2 default null,
                            d4i in varchar2 default null, d4j in varchar2 default null, d4k in varchar2 default null, d4l in varchar2 default null, d4m in varchar2 default null, d4img in varchar2 default null, d4t in varchar2 default null, d4u in varchar2 default null, d4v in varchar2 default null, csv in char default 'F',
                            fsize in varchar2, fullf in char default 'F', fullg in char default 'F', fullh in char default 'F', fulli in char default 'F', fullj in char default 'F', fullk in char default 'F', fullt in char default 'F', fullu in char default 'F', fullv in char default 'F', fullw in char default 'F', fullx in char default 'F',
                            d5fca in varchar2 default '000000', d5fcb in varchar2 default '000000', dump_to_csv in char default 'F');
 procedure del_purchrep( surl in varchar2, id in integer );
 procedure run_purchrep( surl in varchar2, id in integer, dump_to_csv in char default 'F'  );
 procedure imgrep( surl in varchar2, msg in varchar2 default null, template in varchar2 default null );
 procedure del_imgrep( surl in varchar2, id in integer );
 procedure run_imgrep( surl in varchar2, id in integer, dump_to_csv in char default 'F'  );
 procedure accept_imgrep( surl in varchar2, p1 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, d1 in GLBX.MYARRAY, d3r in varchar2, d3s in varchar2, d3t in varchar2,
                          p2 in varchar2, p3 in varchar2, p8a in varchar2, p8b in varchar2, p8c in varchar2, p9a in varchar2, p9b in varchar2, p9c in varchar2,
                          d5a in varchar2, d5af in varchar2, d5c in varchar2, d5d in varchar2,  d5fca in varchar2 default '000000', d5e in varchar2, d5fcb in varchar2 default '000000',
                          fnt in varchar2, fsize in varchar2, d5f in varchar2,
                          d4z in varchar2, d4n in varchar2, d4a in varchar2, d4b in varchar2, d4c in varchar2, d4d in varchar2, d4e in varchar2, d4f in varchar2, d4g in varchar2, d4h in varchar2,
                          d4i in varchar2, d4j in varchar2, d4k in varchar2, d4l in varchar2, d4m in varchar2, d4o in varchar2, d4p in varchar2, d4q in varchar2, d4r in varchar2, d4s in varchar2,
                          limito in varchar2, d4img in varchar2, r4z in varchar2 default 'F', xdt in varchar2 default 'F', csv in char default 'F',
                          template in varchar2, template2 in varchar2 default null, dspt in char default 'F', action in varchar2, dump_to_csv in char default 'F' );
 procedure manage_portlets( surl in varchar2, msg in varchar2 default null );
 procedure edit_portlet( surl in varchar2, portid in integer default null, portname in varchar2 default null, porttype in varchar2 default null, msg in varchar2 default null );
 procedure edit_portlet_query( surl in varchar2, portid in integer default null, portname in varchar2 default null, porttype in varchar2 default null, msg in varchar2 default null );
 procedure edit_portlet_news( surl in varchar2, portid in integer default null, portname in varchar2 default null, porttype in varchar2 default null, msg in varchar2 default null );
 procedure accept_edit_portlet( surl in varchar2, portid in integer default null, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, action in varchar2 );
 procedure edit_portlet_utility( surl in varchar2, portid in integer default null, portname in varchar2 default null, action in varchar2 );
 procedure test_portlet(surl in varchar2, portid in integer);
 procedure accept_edit_portlet_query( surl in varchar2, portid in integer default null, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6 in GLBX.MYARRAY, action in varchar2 );
 procedure portlet_send_stats(surl in varchar2, portid in integer);
 procedure portlet_send_search(surl in varchar2, portid in integer, p1a in varchar2, p1b in varchar2, p1c in varchar2, p2a in varchar2, p2b in varchar2, p2c in varchar2, p3a in varchar2, p3b in varchar2 );
 procedure accept_edit_portlet_news( surl in varchar2, portid in integer default null, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6 in GLBX.MYARRAY, action in varchar2 );
 procedure edit_webservice( surl in varchar2, portid in integer default null, portname in varchar2 default null, porttype in varchar2 default null, msg in varchar2 default null );

end pfm;

/
