CREATE OR REPLACE package WEBSYS.virage
as

procedure virage_run(surl in varchar2, nvid in integer default null, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2 default null, called_from in varchar2 default null, msg in varchar2 default null );

procedure main(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
procedure accept_virage_run(surl in varchar2, footer_api in varchar2 default null, left_api_parm in varchar2, start_from in integer, display_detail in char default null, acid in integer,
                            p1 in varchar2 default null, p2 in varchar2 default null, p3 in varchar2 default null, p4 in varchar2 default null, p5 in varchar2 default null, pstr in varchar2 default null );
procedure accept_virage_pref(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in varchar2 );

procedure accept_context_run(surl in varchar2, footer_api in varchar2 default null, left_api_parm in varchar2, start_from in integer, display_detail in char default null, acid in integer, p1 in varchar2 );
procedure accept_context_pref(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in varchar2 );

function virage_index( surl in varchar2, acid in integer ) return boolean;
function context_index(surl in varchar2, acid in integer ) return boolean;

end virage;

/
