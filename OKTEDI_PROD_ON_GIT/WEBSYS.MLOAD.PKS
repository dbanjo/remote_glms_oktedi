CREATE OR REPLACE package WEBSYS.mload
as

procedure main(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
procedure accept_meta_define(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY );
procedure accept_meta_load(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in varchar2 );

function load_xml_browser(surl in varchar2, acid in integer, file in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY ) return boolean;
function load_xml_server(surl in varchar2, acid in integer, file_loc in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY ) return boolean;
function generate_xml_metatags(surl in varchar2, acid integer, uscid in integer, file_loc in varchar2, to_browser in boolean default FALSE, useloc in boolean default TRUE ) return boolean;
function load_one_image( surl in varchar2, phgid integer, metatype in varchar2, acid in integer, v_umo in integer, printoutput in boolean default false ) return boolean;

end mload;

/
