CREATE OR REPLACE package WEBSYS.strangs
as

 MAX_NON_ZIP_SAD   CONSTANT integer := 30;

 procedure edit_entry(surl in varchar2, pk in varchar2, msg in varchar2 default null, oid in integer default null );
 function sad_generate_form15( pk in varchar2 ) return varchar2;
 procedure accept_edit_entry( surl in varchar2, pk in varchar2, oid in integer, p0 in glbx.myarray, p1 in glbx.myarray, p2 in glbx.myarray, p3 in glbx.myarray, action in varchar2 );
 procedure list_entry(surl in varchar2, msg in varchar2 default null, from_range in number default null, to_range in number default null );
 procedure accept_list_entry(surl in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2 default null );
 procedure email_sad_file_multi(surl in varchar2 );
 procedure sads_by_ship(surl varchar2, shipid number);
 procedure accept_sads_by_ship(surl varchar2, shipid number, vact varchar2 default 'STATUS');

end strangs;
/


GRANT EXECUTE ON WEBSYS.STRANGS TO STRANG;
