CREATE OR REPLACE package WEBSYS.display_api
as

procedure main_display( surl varchar2,
                      stype in integer,
                      ltype in varchar2,
                      umrec in UMP.SEARCH_RESULT_PHG,
                      cusrec in CUSTOMER_ACCOUNT%ROWTYPE,
                      pfx THEME%ROWTYPE,
                      theme_rec theme_types%ROWTYPE,
                      voidrec in order_style%ROWTYPE,
                      footer_api in varchar2,
                      current_page_number in integer default 1,
                      search_total in integer default 0,
                      display_detail in char default null,
                      left_api in varchar2,
                      left_api_parm in varchar2,
                      cusloc in varchar2,
                      lbox in varchar2,
                      acid in integer default null,
                      sessid in integer,
                      msg in varchar2,
                      extra_term in varchar2 default null);
end display_api;

/
