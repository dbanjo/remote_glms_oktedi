CREATE OR REPLACE package WEBSYS.dapi
as

 GLOBAL_SURL              	varchar2(100);
 GLOBAL_LOGIN_SESSION		login_session%ROWTYPE;
 GLOBAL_CUSTOMER_ACCOUNT 	customer_account%ROWTYPE;
 GLOBAL_PHOTOGRAPHER      	photographer%ROWTYPE;
 GLOBAL_MANUFACTURER      	manufacturer%ROWTYPE;
 GLOBAL_LF                	theme%ROWTYPE;
 GLOBAL_BF                	theme_types%ROWTYPE;
 GLOBAL_PURCHASE_ORDER    	purchase_order%ROWTYPE;
 GLOBAL_ORDER_STYLE       	order_style%ROWTYPE;
 GLOBAL_CUSTOMER_CONTACT  	customer_contact%ROWTYPE;
 GLOBAL_ERROR             	varchar2(2000);
 GLOBAL_PROFILE_ID        	integer;
 GLOBAL_PROGRAM_CALLED    	varchar2(100);
 GLOBAL_TITLE             	varchar2(200);
 GLOBAL_HELP              	varchar2(200);
 GLOBAL_B2C_VALUE		char(1);
 GLOBAL_ARRAY                   owa.vc_arr;
 GLOBAL_START_NUMBER            number;
 GLOBAL_END_NUMBER              number;

 function initialise_setup( surl in varchar2, program_called in varchar2, acid in integer default null, reset boolean default TRUE, iscust boolean default TRUE ) return boolean;
 procedure failed_connection( surl in varchar2, program_called in varchar2, nodisplay in boolean default FALSE, extra_parameter in varchar2 default null );
 procedure header_open( title in varchar2 default null, help in varchar2 default null, style in varchar2 default 'STANDARD', styleparm in varchar2 default null, return_link in varchar2 default null,
                        my_class in varchar2 default null, my_font in varchar2 default null, my_size in varchar2 default null, my_colour in varchar2 default null, body_addition in varchar2 default null );
 procedure header_close( extra_code in varchar2 default null );
 procedure acct_top( ttl in varchar2 default null );
 procedure buttons_header;
 procedure buttons_footer( slides in boolean, isleft in boolean default TRUE );
 procedure formsubmit( id in varchar2, display in varchar2 );
 procedure div_center;
 procedure end_div_center;
 function cust_button( gif in varchar2, element in integer default 1 ) return varchar2;

 procedure generate_category_list( acid in integer );
 procedure display_category_list( display_style in varchar2, show_total in boolean, accid in integer, ltype in varchar2, acid in integer, expanded in GLBX.MYARRAY );

 function init(surl in varchar2, program_called in varchar2, acid in integer default null, reset boolean default TRUE, iscust boolean default TRUE) return boolean;
 procedure initFailed(surl in varchar2, nodisplay in boolean default FALSE, extra_parameter in varchar2 default null);
 procedure pageOpen(title in varchar2 default null, help in varchar2 default null, style in varchar2 default 'STANDARD', styleparm in varchar2 default null, return_link in varchar2 default null, my_class in varchar2 default null, my_font in varchar2 default null, my_size in varchar2 default null, my_colour in varchar2 default null, body_addition in varchar2 default null);
 procedure pageClose(cattributes varchar2 default null);

 function getAccountId return integer;
 function getProfileId return integer;
 function getPhotographerId return integer;
 function getUserType return char;
 function getSessionId return integer;
 function getLoginType return varchar2;
 function getScreenType return integer;

 procedure setTitle(title varchar2);
 procedure setHelp(help varchar2);
 procedure setStyle(style varchar2);
 procedure setStyleParm(styleparm varchar2);
 procedure setExternalStyleSheet(externalStypeSheet varchar2);
 procedure setReturnLink(returnLink varchar2);
 procedure setMyClass(myClass varchar2);
 procedure setMyFont(myFont varchar2);
 procedure setMySize(mySize varchar2);
 procedure setMyColour(myColour varchar2);
 procedure setBodyAddition(bodyAddition varchar2);

 function getLFRecord return theme%ROWTYPE;
 function getBFRecord return theme_types%ROWTYPE;
 function getCustomerAccountRecord return customer_account%ROWTYPE;
 procedure addStyle(selector varchar2, properties varchar2);

 function min(a integer, b integer) return integer;
 function max(a integer, b integer) return integer;

 /**
 * Login as a new user
 * @param surl Securel URL
 * @returns New Secure URL
 */
 function login(surl varchar2) return varchar2;
end dapi;
/


GRANT EXECUTE ON WEBSYS.DAPI TO STRANG;
