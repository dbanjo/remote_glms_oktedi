CREATE OR REPLACE package WEBSYS.gcard
as

 procedure main_program(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2 );
 procedure view_card( scard in varchar2, pw in varchar2, bypass in boolean default FALSE, stype in integer default 1, ltype in varchar2 default 'EXTERNAL', surl varchar2 default null );
 procedure accept_create( surl varchar2, photo_id in integer, scard in integer, action in varchar2, card_shape in integer,
                          p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p1a in varchar2 default null, p2a in varchar2, ext in GLBX.MYARRAY,
                          footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2);
 procedure accept_menu( surl varchar2,scard in integer, action_send in varchar2 default null, action_edit in varchar2 default null, action_view in varchar2 default null,
                        action_del in varchar2 default null, action_ret in varchar2 default null, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2);
 procedure disp_menu( surl varchar2, scard in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2 );
 procedure add_audio(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
 procedure aload(surl in varchar2, file in varchar2, p1 in varchar2, action in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2 );
 procedure calendar(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
 procedure accept_calendar_pref(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6 in GLBX.MYARRAY );
 procedure pricing(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
 procedure pricing(surl in varchar2, acid in integer, called_from in varchar2, callid in integer, first_parameter in varchar2 );
 procedure pricing_confirm(surl in varchar2, acid in integer, called_from in varchar2, callid in integer, first_parameter in varchar2, p_type in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY );
 procedure poll(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
 procedure accept_poll_pref(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, action in varchar2, p1 in varchar2, p2 in varchar2, p3 in GLBX.MYARRAY );
 procedure reminder(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
 procedure accept_reminder(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, action in varchar2,
                           p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6a in GLBX.MYARRAY, p6b in GLBX.MYARRAY, p6c in GLBX.MYARRAY);

end gcard;

/
