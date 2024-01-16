CREATE OR REPLACE package WEBSYS.html_email
as

procedure test;
procedure test2;
procedure test_html_send;
procedure accept_test_html_send( p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2 );
procedure purchase_order_send( surl in varchar2, acid in integer );
procedure accept_email_lightbox(surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in varchar2, acid in integer default null, lbox in varchar2, lighthdr in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, action in varchar2 );

procedure zipsend( gcode	 in GLBX.MYARRAY,
  		gparam	 in GLBX.MYARRAY,
  		infile	 in varchar2,
		p_to     in varchar2,
                p_subj   in varchar2 default NULL,
                p_from   in varchar2 default NULL,
                p_cc     in varchar2 default NULL,
                p_bcc    in varchar2 default NULL,
                is_sms   in boolean default FALSE,
                is_report in boolean default FALSE,
                ltype    in varchar2 default null,
                own_id   in integer default null,
                extension in varchar2 default null,
                is_attachment in boolean default FALSE,
                scode in varchar2 default null,
                v_pid in integer default null,
                v_aid in integer default null,
                v_profile_id in integer default null);

end html_email;

/
