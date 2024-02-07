CREATE OR REPLACE package WEBSYS.ftp
as

procedure main_display(surl  varchar2, stype integer, ltype varchar2, umrec UMP.SEARCH_RESULT_PHG, cusrec CUSTOMER_ACCOUNT%ROWTYPE, pfx   THEME%ROWTYPE,
		       theme_rec  theme_types%ROWTYPE, footer_api varchar2, current_page_number  integer default 1, search_total    integer default 0,
		       display_detail  char default null, left_api   varchar2, left_api_parm   varchar2, cusloc varchar2, lbox  varchar2, acid  integer default null,
		       sessid integer, msg varchar2 );

procedure home_page( surl in varchar2, ltype in varchar2 default 'OWNER', acid in integer, msg in varchar2 default null, left_api_parm in varchar2 default null );
procedure top_frame( surl in varchar2 );
procedure accept_images(surl in varchar2, acid in integer, file in GLBX.MYARRAY, action in varchar2);
procedure listimage( surl in varchar2, acid in integer, msg in varchar2 default null );
procedure delimg( surl in varchar2, acid in integer, sess_id in integer );

end ftp;

/
