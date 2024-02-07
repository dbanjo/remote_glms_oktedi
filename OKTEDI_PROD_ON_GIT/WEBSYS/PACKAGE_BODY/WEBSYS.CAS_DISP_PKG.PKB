CREATE OR REPLACE package body WEBSYS.cas_disp_pkg
as

procedure pr_display( surl varchar2,
                      stype in integer,
                      ltype in varchar2,
                      umrec in UMP.SEARCH_RESULT_PHG,
                      cusrec in CUSTOMER_ACCOUNT%ROWTYPE,
                      pfx THEME%ROWTYPE,
                      theme_rec theme_types%ROWTYPE,
                      footer_api in varchar2,
                      current_page_number in integer default 1,
                      display_detail in char default null,
                      left_api in varchar2,
                      left_api_parm in varchar2,
                      cusloc in varchar2,
                      lbox in varchar2,
                      acid in integer default null)
as
begin

htp.bold( 'This Package has not been built and should not be used' );
htp.nl;

htp.bold( 'UMREC.COUNT-' || umrec.count );
htp.nl;
htp.bold( 'Customer Account:' || cusrec.account_name );
htp.nl;
htp.bold( 'Business Feature:' || theme_rec.theme_type );
htp.nl;
htp.bold( 'Look and Feel:' || pfx.theme_name );
htp.nl;
htp.bold( 'Login Type:' || ltype );
htp.nl;
htp.bold( 'Screen Type:' || stype );

end pr_display;

end cas_disp_pkg;

/
