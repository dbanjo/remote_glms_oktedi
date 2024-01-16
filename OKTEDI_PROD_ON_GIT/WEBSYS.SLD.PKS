CREATE OR REPLACE package WEBSYS.sld
as

 TYPE myarray 	IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;

 procedure phg_master(surl varchar2,acid in integer);
 procedure new_slide(surl varchar2,acid in integer, msg in varchar2 default null);
 procedure accept_new_slide( surl varchar2,acid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2, action in varchar2 default null, oth in GLBX.MYARRAY);
 procedure edit_slideshow_master(surl varchar2,acid in integer, slid in integer);
 procedure slide_main( surl varchar2,acid in integer, slid in integer, msg in varchar2 default null );
 procedure controller( surl varchar2,acid in integer, slid in integer );
 procedure edit_slideshow_details(surl varchar2,acid in integer, slid in integer, msg in varchar2 default null);
 procedure accept_edit_slide( surl varchar2,acid in integer, slid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2, action in varchar2);
 procedure insert_slide(surl varchar2,acid in integer, slid in integer, typ in integer);
 procedure accept_slide_modify(surl varchar2,acid in integer, slid in integer, typ in integer, snmbr in integer, action in varchar2, p1 in varchar2, p2 in varchar2, p3 in SLD.MYARRAY, p4 in SLD.MYARRAY );
 procedure update_slide(surl varchar2,acid in integer, slid in integer, snmbr in integer, typ in integer, msg in varchar2 default null);
 procedure insert_bslide(surl varchar2,acid in integer, slid in integer, typ in integer, snmbr in integer);
 procedure del_slide(surl varchar2,acid in integer, slid in integer, snmbr in integer);
 procedure delete_slideshow( surl varchar2,acid in integer, slid in integer );
 procedure run_slideshow( surl varchar2,acid in integer, slid in integer );
 procedure display_slide( surl varchar2,acid in integer, slid in integer, snmbr in integer, inf in integer default 0 );
 procedure cust_slideshow(surl varchar2);
 procedure process_slideshow(surl varchar2,acid in integer, slid in integer, snmbr in integer, inf in integer, action in varchar2);
 procedure sld_bac( surl varchar2,slid in integer, msg in varchar2 default null );
 procedure slideshow_category(surl in varchar2, uscid in varchar2, dispstyle in varchar2, codes in varchar2 default null, currcode in varchar2 default null, acid in integer, ttl in varchar2 default null );

end sld;

/
