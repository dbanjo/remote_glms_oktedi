CREATE OR REPLACE package WEBSYS.xscore
as

 procedure score_master( vscore in varchar2 default null, action in varchar2 default null, acid in integer );
 procedure scorer( nscore in varchar2 default null, msg in varchar2 default null, action in varchar2 default null, acid in integer );

 procedure main_display(surl  varchar2, stype integer, ltype varchar2, umrec UMP.SEARCH_RESULT_PHG, cusrec CUSTOMER_ACCOUNT%ROWTYPE, pfx   THEME%ROWTYPE,
 		       theme_rec  theme_types%ROWTYPE, footer_api varchar2, current_page_number  integer default 1, search_total    integer default 0,
		       display_detail  char default null, left_api   varchar2, left_api_parm   varchar2, cusloc varchar2, lbox  varchar2, acid  integer default null,
		       sessid integer, msg   varchar2 );
procedure delayed_score(surl varchar2, v_umo integer, p1 in varchar2 );
procedure delayed_score_phg(surl varchar2, v_umo integer, acid in integer, p1 in varchar2 );
procedure calcscore(initial_scores in GLBX.MYARRAY, c75 out integer, c80 out integer, c85 out integer, c90 out integer, c95 out integer, tot out integer, hscore out integer, lscore out integer, diff out integer, avg1 out number, fscore out integer );
procedure scorer_realtime( surl in varchar2, nscore in varchar2 default null, msg in varchar2 default null, action in varchar2 default null, acid in integer );

end xscore;

/
