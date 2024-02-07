CREATE OR REPLACE package WEBSYS.lc
as

procedure main_display(surl  varchar2, stype integer, ltype varchar2, umrec UMP.SEARCH_RESULT_PHG, cusrec CUSTOMER_ACCOUNT%ROWTYPE, pfx   THEME%ROWTYPE,
		       theme_rec  theme_types%ROWTYPE, footer_api varchar2, current_page_number  integer default 1, search_total    integer default 0,
		       display_detail  char default null, left_api   varchar2, left_api_parm   varchar2, cusloc varchar2, lbox  varchar2, acid  integer default null,
		       sessid integer, msg varchar2 );

procedure main_image(surl in varchar2, acid in integer, v_umo in integer default null, footer_api in varchar2 default null, left_api_parm in varchar2 default null, current_page_number in integer default 1, uscid in integer default null, foundimg in char default 'F', retval in varchar2 default null, ro in char default 'R');
procedure accept_meta_edit( surl in varchar2, v_umo in integer, acid in integer, tag_id in glbx.myarray, tag_name in glbx.myarray, tag_value in glbx.myarray, p1 in varchar2, p2 in varchar2, p3 in char default 'F', file in varchar2, uscid in integer, ro in char, action in varchar2 );
procedure metatag( surl in varchar2, acid in integer, v_umo in integer, metaload in varchar2 );
procedure linkimage(surl in varchar2, acid in integer, v_umo in integer, msg in varchar2 default null );
procedure accept_linkimage(surl in varchar2, acid in integer, v_umo in integer, p1 in varchar2 );
procedure accept_linkimage_transfer(surl in varchar2, acid in integer, v_umo in integer, p1 in glbx.myarray, p2 in glbx.myarray, p3 in glbx.myarray );

end lc;

/
