CREATE OR REPLACE package WEBSYS.aru
as

procedure home_page( surl in varchar2, ltype in varchar2 default 'OWNER', acid in integer, msg in varchar2 default null, left_api_parm in varchar2 default null );
procedure accept_home_page( surl in varchar2, acid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, pcode1 in varchar2 default null, pcode2 in varchar2 default null );
procedure main_display(surl  varchar2, stype integer, ltype varchar2, umrec UMP.SEARCH_RESULT_PHG, cusrec CUSTOMER_ACCOUNT%ROWTYPE, pfx   THEME%ROWTYPE,
		       theme_rec  theme_types%ROWTYPE, footer_api varchar2, current_page_number  integer default 1, search_total    integer default 0,
		       display_detail  char default null, left_api   varchar2, left_api_parm   varchar2, cusloc varchar2, lbox  varchar2, acid  integer default null,
		       sessid integer, msg varchar2 );
procedure main_image(surl in varchar2, acid in integer, v_umo in integer default null, footer_api in varchar2 default null, left_api_parm in varchar2 default null, current_page_number in integer default 1, foundimg in char default 'F');
procedure zoom(surl in varchar2, acid in integer, v_umo in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, zoom_factor in varchar2 default 1);
procedure create_card(surl varchar2, photo_id in integer, scard in varchar2 default null, card_shape in integer default 1, msg in varchar2 default null,
                      p1 in varchar2 default null, p2 in varchar2 default null, p3 in varchar2 default null,
	              p4 in varchar2 default null, p5 in varchar2 default null, p6 in date default null, p1a in varchar2 default null, p2a in varchar2 default null,
	              footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2);
procedure accept_create( surl varchar2, photo_id in integer, scard in integer, action in varchar2, card_shape in integer default 1,
                         p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p1a in varchar2, p2a in varchar2, ext in GLBX.MYARRAY,
                         footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2);
procedure view_card( scard in varchar2, pw in varchar2, stype in integer default 1, ltype in varchar2 default 'EXTERNAL', surl varchar2 default null );

procedure gcard_menu( surl varchar2, scard in integer, msg in varchar2, owner_id in integer, c1rec in customer_account%ROWTYPE, pfx in THEME%ROWTYPE, stype in integer,
                      footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2, ltype in varchar2);
procedure accept_menu( surl varchar2, scard in integer, action_send in varchar2 default null, action_edit in varchar2 default null, action_view in varchar2 default null,
                       action_del in varchar2 default null, action_ret in varchar2 default null,
                       footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2);
end aru;

/
