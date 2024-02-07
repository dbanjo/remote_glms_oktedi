CREATE OR REPLACE package WEBSYS.thes
as

 TYPE thes_terms IS RECORD
  (
    term_id 	 integer,
    term_name	 varchar2(100)
  );

 TYPE list_of_terms IS TABLE OF thes_terms INDEX BY BINARY_INTEGER;

 procedure list_available(surl in varchar2, disptype in varchar2 default 'TABLE', disp_parm in varchar2 default null, acid in integer default null );
 procedure start_thesaurus(surl in varchar2, thesid in integer, acid in integer );
 procedure goto_page( surl in varchar2, footer_api in varchar2, thesid in integer, search_total in integer, acid in integer, start_from in integer, page in varchar2 );
 procedure term_search( surl in varchar2, thesid in integer, search_term in varchar2 default null, bttermid in integer default null, acid in integer default null, start_from in integer default 1 );
 procedure term_umo( surl in varchar2, left_api in varchar2 default null, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null );
 procedure term_details( surl in varchar2, thesid in integer, termid in integer, acid in integer default null );
 procedure advanced_search( surl in varchar2, thesid in integer, acid in integer );
 procedure accept_advanced_search( surl in varchar2, thesid in integer, acid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2 );
 procedure accept_thes_pref(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in varchar2 );
 procedure accept_thes_pref_load(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in varchar2 );
 procedure accept_thes_pref_create(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in varchar2 );
 procedure accept_thes_pref_modify(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in GLBX.MYARRAY, action in varchar2 );
 procedure accept_thes_pref_unload(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in varchar2 );
 procedure accept_thes_pref_delete(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in varchar2 );
 procedure accept_thes_pref_security(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2,
                                     p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, action in varchar2 default null );

 procedure accept_thes_pref_map(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in GLBX.MYARRAY );
 procedure accept_thes_exception(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in varchar2 );
 procedure main(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api in varchar2 default null, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );

 procedure get_properties( thesid in integer );
 procedure download( thesid in integer, include_nonpreferred in varchar2 default 'FALSE', format in varchar2 default 'TERM' );
 procedure query( thesid in integer, operator in varchar2 default 'EQUALS', text in varchar2 default null, fuzzy in varchar2 default 'FALSE', format in varchar2 default 'TERM' );
 procedure get_broader( thesid in integer, starting_term in varchar2 default null, max_levels in varchar2 default null, format in varchar2 default 'TERM' );
 procedure get_narrower( thesid in integer, starting_term in varchar2 default null, max_levels in varchar2 default null, format in varchar2 default 'TERM' );

end thes;

/
