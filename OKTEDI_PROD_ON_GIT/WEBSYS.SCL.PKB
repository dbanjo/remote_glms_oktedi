CREATE OR REPLACE package body WEBSYS.scl as

PACKAGE_NAME      constant varchar2( 3 ) := 'SCL';
MAX_RESULTS       constant integer := 100;

PROC_NAME         varchar2( 200 )        := '';
PAGE_TITLE        varchar2( 200 )        := '';

procedure conn_as(
  surl varchar2,
  acid number,
  un1 varchar2 default null,
  pw1 varchar2 default null,
  left_api_parm	in varchar2 default null )
is
   -- standard piction variables
   owner_id            integer;                   -- session_id for the user
   stype               integer;                   -- screen resolution type
   ltype               varchar2( 100 );             -- type of user eg. profileg, profile
   profid              integer;                   -- unique id of the customer profile
   sts                 varchar2( 100 );             -- whether the connection is valid if so returns null
   dispvert            char( 1 );
   pfx                 theme%rowtype;             -- the look and feel for display
   theme_rec           theme_types%rowtype;       -- the business feature set ( ie. theme type )
   c1rec               customer_account%rowtype;  -- the customer profile / customer account details
   s_error_text         varchar2( 1000 );        -- any error text to return to the login screen
   a_contact_values_def glbx.myarray;          -- an array of default contact values must be initialised to null
   a_contact_labels_def glbx.myarray;          -- an array of default contact labels must be initialised to null
   s_status             VARCHAR2( 100 ) :='';    -- the status of the login, set to Null if successful
   s_new_surl			VARCHAR2( 100 );		-- new surl when logged in again
   old_owner_id			INTEGER;			-- session_id for the user
   s_navigate_screen		VARCHAR2( 100 );
   s_navigate_screen_parms	VARCHAR2( 300 );
   dummy_array 		glbx.myarray;
begin
   glbx.cookie_id( surl, stype, ltype, old_owner_id, sts, 'S', progcalled=>'SCL.conn_as' );

   if ( un1 is null ) or ( pw1 is null ) then
      null;
   else
      glbx.relogin( surl, un1, pw1, s_status, s_new_surl );
      if s_status is not null then
         null;
      else
         null;
      end if;  -- s_status
   end if;  -- fields not blank
exception when others then
   glbx.error_details( 'SCL', 'conn_as', errmsg=>sqlerrm, extdet=> 'error occurred whilst trying to log in as an existing user.  user session id is: ' || owner_id );
end conn_as;

procedure mng_booking_profiles(
  surl varchar2,                                 -- Secure URL
  acid integer,                                  -- Account ID when logged in as manufacturer or photographer
  user_type varchar2,                            -- User type of the profile 'E' for School or 'T' for Bus Company
  p_id varchar2 default null,                    -- Profile ID
  p_name varchar2 default null,                  -- Profile name
  p_street varchar2 default null,                -- Street name
  p_suburb varchar2 default null,                -- Suburb
  p_country varchar2 default null,                  -- Country
  p_pcode varchar2 default null,                 -- Postal Code
  p_state varchar2 default null,                 -- State
  p_email varchar2 default null,                 -- Email
  action varchar2 default null,                  -- What button is pressed?
  search_range varchar2 default '0Z',            -- Search range the user clicked on
  pFunctionality integer default MAINTENANCE,    -- What is the list called for, can be: MAINTENANCE, CONNECTAS, SELECTION, LOGIN
  bid integer default null,                      -- Booking ID if creating a booking
  rurl varchar2 default null,
  firsttime in char default 'T')                    -- Return URL
as
   cursor c0( c_aid integer, c_user_type char, c_id integer, c_name varchar2,
              c_street varchar2, c_suburb varchar2, c_country varchar2,
              c_pcode varchar2, c_state varchar2, c_email varchar2,
              c_search_range varchar2 ) is
   select cc.billing_name     billing_name,
          cp.profile_id       profile_id,
          cc.contact_id       contact_id,
          cc.billing_street   billing_street,
          cc.billing_suburb   billing_suburb,
          cc.billing_country     billing_country,
          cc.billing_postcode billing_postcode,
          cc.billing_state    billing_state,
          cc.billing_phone    billing_phone,
          cc.billing_fax      billing_fax,
          cc.billing_email    billing_email,
          cc.sendto_name      sendto_name,
          cc.contact_email    contact_email,
          cc.contact_phone    contact_phone,
          cc.contact_mobile   contact_mobile,
          cc.aid              aid,
          cc.user_type        user_type,
          cc.billing_branch   billing_branch,
          cc.booking_defined_1 bk1,
          cc.booking_defined_2 bk2,
          cc.booking_defined_3 bk3,
          cc.booking_defined_4 bk4,
          cc.booking_defined_5 bk5,
          cc.booking_defined_6 bk6
   from customer_contact cc,
        customer_profile cp
   where
   /*
      ( ( c_id is null )     or ( c_id is not null     and contact_id = c_id ) ) and
      ( ( c_name is null )   or ( c_name is not null   and upper( billing_name ) like '%' || upper( c_name ) || '%' ) ) and
      ( ( c_street is null ) or ( c_street is not null and upper( billing_street ) like '%' || upper( c_street ) || '%' ) ) and
      ( ( c_suburb is null ) or ( c_suburb is not null and upper( billing_suburb ) like '%' || upper( c_suburb ) || '%' ) ) and
      ( ( c_country is null )   or ( c_country is not null   and upper( billing_country ) like '%' || upper( c_country ) || '%' ) ) and
      ( ( c_pcode is null )  or ( c_pcode is not null  and upper( billing_postcode ) like '%' || upper( c_pcode ) || '%' ) ) and
      ( ( c_state is null )  or ( c_state is not null  and billing_state = c_state ) ) and
      ( ( c_email is null )  or ( c_email is not null  and upper( billing_email ) like '%' || upper( c_email ) || '%' ) ) and
   */
      ( c_id is null or ( profile_id = c_id ) ) and
      ( c_name is null or ( upper( billing_name ) like '%' || upper( c_name ) || '%' ) ) and
      ( c_street is null or ( c_street is not null and upper( billing_street ) like '%' || upper( c_street ) || '%' ) ) and
      ( c_suburb is null or ( c_suburb is not null and upper( billing_suburb ) like '%' || upper( c_suburb ) || '%' ) ) and
      ( c_country is null or ( c_country is not null   and upper( billing_country ) like '%' || upper( c_country ) || '%' ) ) and
      ( c_pcode is null or ( c_pcode is not null  and upper( billing_postcode ) like '%' || upper( c_pcode ) || '%' ) ) and
      ( c_state is null or ( c_state is not null  and billing_state = c_state ) ) and
      ( c_email is null or ( c_email is not null  and upper( billing_email ) like '%' || upper( c_email ) || '%' ) ) and
      ( c_search_range is null or ( upper( substr( billing_name,1,1 ) ) >= substr( c_search_range,1,1 ) and
                                    upper( substr( billing_name,1,1 ) ) <= substr( c_search_range,2,1 ) ) ) and
      cc.user_type = c_user_type and
      cc.login_type = 'PROFILE' and
      cc.aid = cp.profile_id and
      cp.aid = c_aid
   order by
      billing_name;
   c0rec c0%ROWTYPE;

   cursor c2( c_aid integer, c_user_type varchar2, c_id integer, c_name varchar2,
              c_street varchar2, c_suburb varchar2, c_country varchar2,
              c_pcode varchar2, c_state varchar2, c_email varchar2,
              c_search_range varchar2 ) is
   select count( 'x' )
   from customer_contact cc, customer_profile cp
   where ( c_id is null or ( profile_id = c_id ) ) and
         ( c_name is null or ( upper( billing_name ) like '%' || upper( c_name ) || '%' ) ) and
         ( c_street is null or ( c_street is not null and upper( billing_street ) like '%' || upper( c_street ) || '%' ) ) and
         ( c_suburb is null or ( c_suburb is not null and upper( billing_suburb ) like '%' || upper( c_suburb ) || '%' ) ) and
         ( c_country is null or ( c_country is not null   and upper( billing_country ) like '%' || upper( c_country ) || '%' ) ) and
         ( c_pcode is null or ( c_pcode is not null  and upper( billing_postcode ) like '%' || upper( c_pcode ) || '%' ) ) and
         ( c_state is null or ( c_state is not null  and billing_state = c_state ) ) and
         ( c_email is null or ( c_email is not null  and upper( billing_email ) like '%' || upper( c_email ) || '%' ) ) and
         ( c_search_range is null or ( upper( substr( billing_name,1,1 ) ) >= substr( c_search_range,1,1 ) and
                                       upper( substr( billing_name,1,1 ) ) <= substr( c_search_range,2,1 ) ) ) and
         cc.user_type = c_user_type and
         cc.login_type = 'PROFILE' and
         cc.aid = cp.profile_id and
         cp.aid = c_aid;

   cursor c2a( c_aid integer, c_user_type varchar2 ) is
      select count( 'x' )
      from customer_contact cc, customer_profile cp
      where cc.user_type = c_user_type and
            cc.login_type = 'PROFILE' and
            cc.aid = cp.profile_id and
            cp.aid = c_aid;

   cursor c6( csurl varchar2 ) is
      select login_type, aid
      from login_session
      where securl = csurl;
   c6rec c6%ROWTYPE;

   cursor c7( caid integer ) is
      select username, password, aid, pid, profile_id
      from customer_profile
      where profile_id = caid;
   c7rec c7%ROWTYPE;

   cursor c8( caid integer ) is
      select pid
      from customer_account
      where aid = caid;
   c8rec c8%ROWTYPE;

   cursor c9( cAccountId integer ) is
      select *
      from theme
      where theme_name = ( select theme_name from customer_account where aid = cAccountId );

   pfx             THEME%ROWTYPE;
   rDefaults       school_booking_prefs%ROWTYPE;
   lManufacturerId manufacturer.manufacturer_id%TYPE;
   lPhotographerId photographer.pid%TYPE;
   lAccountId      customer_account.aid%TYPE;
   lLoginType      login_session.login_type%TYPE;
   checkbox_on     varchar2( 100 ) := 'CHECKED';
   range_anchor    varchar2( 1000 );
   lSearchRange    varchar2( 10 );
   lCount          pls_integer;
   lCountAll       pls_integer;
begin
   if pFunctionality != LOGIN then
      if not dapi.init( surl, 'SCL.MNG_BOOKING_PROFILES', acid, iscust=>FALSE ) then
         dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      end if;
      pfx := dapi.getLFRecord;
      lLoginType := dapi.getLogintype;
      if pFunctionality = SELECTIONGUEST then
         dapi.setExternalStyleSheet(  BKN.BKN_STYLESHEET );
      end if;
      if user_type = 'E' and pFunctionality = MAINTENANCE then
         dapi.setTitle( 'MANAGE LIST OF SCHOOLS' );
      elsif user_type = 'T' and pFunctionality = MAINTENANCE then
         dapi.setTitle( 'MANAGE LIST OF BUS COMPANIES' );
      elsif user_type = 'E' and pFunctionality = CONNECTAS then
         dapi.setTitle( 'CONNECT AS A SCHOOL' );
      elsif user_type = 'T' and pFunctionality = CONNECTAS then
         dapi.setTitle( 'CONNECT AS A BUS COMPANIES' );
      end if;
      dapi.pageOpen;
      if pFunctionality != SELECTIONGUEST then
         htp.p( '<center>' );
      else
         htp.p( '<script type="text/javascript" src="' || BKN.BKN_TOPSCRIPT || '"></script>' );
      end if;
      if user_type = 'E' and pFunctionality = SELECTIONGUEST then
         htp.header( 1, 'Make a Booking' );
         htp.header( 2, 'Select the school that is visiting' );
      elsif user_type = 'T' and pFunctionality = SELECTIONGUEST then
         htp.header( 1, 'Make a Booking' );
         htp.header( 2, 'Select the bus company for this visit' );
      end if;
   else
      open c9( acid );
      fetch c9 into pfx;
      close c9;
   end if;
   htp.p( p_state );
   -- Do a count with the current restrictions
   lSearchRange := search_range;
   open c2( acid, user_type, TO_NUMBER( p_id ), p_name, p_street, p_suburb, p_country,
            p_pcode, p_state, p_email, lSearchRange );
   fetch c2 into lCount;
   close c2;
   -- Count all records
   open c2a( acid, user_type );
   fetch c2a into lCountAll;
   close c2a;
   -- Of more than 100 returned then show the selection fields
   if lCountAll > 100 then
      htp.formOpen( 'scl.mng_booking_profiles', cattributes=>'NAME="form2"' );
      htp.formHidden( 'surl', surl );
      htp.formHidden( 'acid', acid );
      htp.formHidden( 'bid', bid );
      htp.formHidden( 'firsttime', 'F' );
      htp.formHidden( 'user_type', user_type );
      htp.formhidden( 'pFunctionality', pFunctionality );
      if pFunctionality != SELECTIONGUEST then
         htp.tableOpen( cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );
            htp.tableRowOpen;
               if user_type = 'E' then
                  htp.tableData( htf.bold( 'Search for a school using these attributes' ), cattributes=>pfx.qbground || ' COLSPAN="4"' );
               elsif user_type = 'T' then
                  htp.tableData( htf.bold( 'Search for a bus company using these attributes' ), cattributes=>pfx.qbground || ' COLSPAN="4"' );
               end if;
            htp.tableRowClose;
               htp.tableRowOpen;
                  htp.tableData( htf.bold( LNG5.BKN_TXT_124 ), cattributes=>pfx.qbground );
                  htp.tableData( htf.formText( 'p_id', cvalue=>p_id ), cattributes=>pfx.qcbground );
                  htp.tableData( htf.bold( LNG5.BKN_TXT_128 ), cattributes=>pfx.qbground );
                  htp.tableData( htf.formText( 'p_country', cvalue=>p_country ), cattributes=>pfx.qcbground );
               htp.tableRowClose;
            htp.tableRowOpen;
               htp.tableData( htf.bold( LNG5.BKN_TXT_125 ), cattributes=>pfx.qbground );
               htp.tableData( htf.formText( 'p_name', cvalue=>p_name ), cattributes=>pfx.qcbground );
               htp.tableData( htf.bold( LNG5.BKN_TXT_129 ), cattributes=>pfx.qbground );
               htp.tableData( htf.formText( 'p_pcode', cvalue=>p_pcode ), cattributes=>pfx.qcbground );
            htp.tableRowClose;
            htp.tableRowOpen;
               htp.tableData( htf.bold( LNG5.BKN_TXT_126 ), cattributes=>pfx.qbground );
               htp.tableData( htf.formText( 'p_street', cvalue=>p_street ), cattributes=>pfx.qcbground );
               htp.tableData( htf.bold( LNG5.BKN_TXT_130 ), cattributes=>pfx.qbground );
               htp.tableData( ste.get_state_lov( 'p_state', p_state, TRUE ), cattributes=>pfx.qcbground );
            htp.tableRowClose;
            htp.tableRowOpen;
               htp.tableData( htf.bold( LNG5.BKN_TXT_127 ), cattributes=>pfx.qbground );
               htp.tableData( htf.formText( 'p_suburb', cvalue=>p_suburb ), cattributes=>pfx.qcbground );
               htp.tableData( htf.bold( LNG5.BKN_TXT_132 ), cattributes=>pfx.qbground );
               htp.tableData( htf.formText( 'p_email', cvalue=>p_email ), cattributes=>pfx.qcbground );
            htp.tableRowClose;
         htp.tableClose;
         htp.formReset( LNG5.SCL_BTN_100 );
         htp.formSubmit( 'action', LNG5.SCL_BTN_101 );
      else
         htp.tableOpen( cattributes=>'border="0" cellpadding="0" cellspacing="0"' );
         htp.tableRowOpen;
         htp.tableData( '<label for="company_school">Name of School*:</label>' );
         htp.tableData( htf.formtext( 'p_name', '46', '60', p_name, cattributes=>'id="company_school"' ) );
         htp.tableRowClose;
         htp.tableRowOpen;
         htp.tableData( 'State*:' );
         htp.tableData( ste.get_state_lov( 'p_state', p_state, TRUE ) );
         htp.tableRowClose;
         htp.tableRowOpen;
         htp.tableData( '&nbsp;' );
         htp.tableData( htf.formImage( 'action', DECS.IMAGE_LOCATION || 'booking/continue.gif',
                        cattributes=>'border="0"' ) );
         htp.tableRowClose;
         htp.tableClose;
      end if;
      htp.formClose; -- form2
   end if;
   htp.p( '<p>Not on the list? Contact our <a href="http://www.awm.gov.au/martijn/scenario2/help.htm">bookings officer</a>.</p>' );
   if lCountAll > 50 then
      --
      -- Build the link for the search range
      --
      range_anchor := owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'scl.mng_booking_profiles?surl=' || surl ||
         '&acid=' || acid ||
         '&user_type=' || user_type ||
         '&p_id=' || p_id ||
         '&p_name=' || p_name ||
         '&p_street=' || p_street ||
         '&p_suburb=' || p_suburb ||
         '&p_country=' || p_country ||
         '&p_pcode=' || p_pcode ||
         '&p_state=' || p_state ||
         '&p_email=' || p_email ||
         '&action=' || action ||
         '&pFunctionality=' || pFunctionality ||
         '&firsttime=F';
      htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=0' );
         htp.tablerowopen;
         if search_range != 'AC' then
            htp.tabledata( htf.anchor( range_anchor || '&search_range=AC','[A-C]' ), cattributes=>' valign="CENTER" align="CENTER"' );
         else
            htp.tableData( '[A-C]' );
         end if;
         if search_range != 'DF' then
            htp.tabledata( htf.anchor( range_anchor || '&search_range=DF','[D-F]' ), cattributes=>' valign="CENTER" align="CENTER"' );
         else
            htp.tableData( '[D-F]' );
         end if;
         if search_range != 'GI' then
            htp.tabledata( htf.anchor( range_anchor || '&search_range=GI','[G-I]' ), cattributes=>' valign="CENTER" align="CENTER"' );
         else
            htp.tableData( '[G-I]' );
         end if;
         if search_range != 'JL' then
            htp.tabledata( htf.anchor( range_anchor || '&search_range=JL','[J-L]' ), cattributes=>' valign="CENTER" align="CENTER"' );
         else
            htp.tableData( '[J-L]' );
         end if;
         if search_range != 'MO' then
            htp.tabledata( htf.anchor( range_anchor || '&search_range=MO','[M-O]' ), cattributes=>' valign="CENTER" align="CENTER"' );
         else
            htp.tableData( '[M-O]' );
         end if;
         if search_range != 'PS' then
            htp.tabledata( htf.anchor( range_anchor || '&search_range=PS','[P-S]' ), cattributes=>' valign="CENTER" align="CENTER"' );
         else
            htp.tableData( '[P-S]' );
         end if;
         if search_range != 'TV' then
            htp.tabledata( htf.anchor( range_anchor || '&search_range=TV','[T-V]' ), cattributes=>' valign="CENTER" align="CENTER"' );
         else
            htp.tableData( '[T-V]' );
         end if;
         if search_range != 'WZ' then
            htp.tabledata( htf.anchor( range_anchor || '&search_range=WZ','[W-Z]' ), cattributes=>' valign="CENTER" align="CENTER"' );
         else
            htp.tableData( '[W-Z]' );
         end if;
         if search_range != '09' then
            htp.tabledata( htf.anchor( range_anchor || '&search_range=09','[0-9]' ), cattributes=>' valign="CENTER" align="CENTER"' );
         else
            htp.tableData( '[0-9]' );
         end if;
         if search_range != '0Z' then
            htp.tabledata( htf.anchor( range_anchor || '&search_range=0Z','[ALL]' ), cattributes=>' valign="CENTER" align="CENTER"' );
         else
            htp.tableData( '[ALL]' );
         end if;
         htp.tablerowclose;
      htp.tableclose;
   end if;
   if pFunctionality = MAINTENANCE then
      htp.formOpen( 'scl.insert_profile', cattributes=>'name="form3"' );
      htp.formHidden( 'surl', surl );
      htp.formHidden( 'acid', acid );
      htp.formHidden( 'user_type', user_type );
      if user_type = 'E' then
         htp.formSubmit( 'action', 'Insert school' );
      elsif user_type ='T' then
         htp.formSubmit( 'action', 'Insert bus company' );
      end if;
      htp.formClose;
   end if;
   htp.nl;
   htp.nl;

   if nvl(firsttime,'T') <> 'T' or pFunctionality = MAINTENANCE
    then

   if pFunctionality != SELECTIONGUEST then
      htp.tableOpen( cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );
   else
      htp.tableOpen;
   end if;
   htp.tableRowOpen;
   if pFunctionality = MAINTENANCE then
      htp.tableHeader( htf.bold( LNG5.BKN_TXT_124 ), cattributes=>pfx.qbground );
   elsif pFunctionality = SELECTIONGUEST OR pFunctionality = SELECTION then
      htp.tableHeader( htf.bold( LNG5.BKN_TXT_063 ), cattributes=>pfx.qbground );
   elsif pFunctionality = CONNECTAS then
      htp.tableHeader( htf.bold( LNG3.ADM_TXT_040 ), cattributes=>pfx.qbground );
   end if;
   htp.tableHeader( htf.bold( LNG5.BKN_TXT_125 ), cattributes=>pfx.qbground );
   htp.tableHeader( htf.bold( LNG5.BKN_TXT_126 ), cattributes=>pfx.qbground );
   htp.tableHeader( htf.bold( LNG5.BKN_TXT_127 ), cattributes=>pfx.qbground );
   -- htp.tableData( htf.bold( LNG5.BKN_TXT_128 ), cattributes=>pfx.qbground );
   htp.tableHeader( htf.bold( LNG5.BKN_TXT_129 ), cattributes=>pfx.qbground );
   if pFunctionality != SELECTIONGUEST then
      htp.tableHeader( htf.bold( LNG5.BKN_TXT_130 ), cattributes=>pfx.qbground );
   end if;
   htp.tableHeader( htf.bold( LNG5.BKN_TXT_160 ), cattributes=>pfx.qbground );
   htp.tableHeader( htf.bold( LNG5.BKN_TXT_161 ), cattributes=>pfx.qbground );
   if pFunctionality != SELECTIONGUEST then
      htp.tableHeader( htf.bold( LNG5.BKN_TXT_162 ), cattributes=>pfx.qbground );
      if user_type = 'T' then htp.tableHeader( htf.bold( LNG5.BKN_TXT_131 ), cattributes=>pfx.qbground ); end if;
      if user_type = 'E' then htp.tableHeader( htf.bold( nvl(rDefaults.branch_title,'Campus') ), cattributes=>pfx.qbground ); end if;
      if user_type = 'T' then htp.tableHeader( htf.bold( 'Mobile Phone' ), cattributes=>pfx.qbground ); end if;
      if rDefaults.user_defined_1 is not null then htp.tableHeader( htf.bold( rDefaults.user_defined_1 ), cattributes=>pfx.qbground ); end if;
      if rDefaults.user_defined_2 is not null then htp.tableHeader( htf.bold( rDefaults.user_defined_2 ), cattributes=>pfx.qbground ); end if;
      if rDefaults.user_defined_3 is not null then htp.tableHeader( htf.bold( rDefaults.user_defined_3 ), cattributes=>pfx.qbground ); end if;
      if rDefaults.user_defined_4 is not null then htp.tableHeader( htf.bold( rDefaults.user_defined_4 ), cattributes=>pfx.qbground ); end if;
      if rDefaults.user_defined_5 is not null then htp.tableHeader( htf.bold( rDefaults.user_defined_5 ), cattributes=>pfx.qbground ); end if;
      if rDefaults.user_defined_6 is not null then htp.tableHeader( htf.bold( rDefaults.user_defined_6 ), cattributes=>pfx.qbground ); end if;
      -- htp.tableHeader( htf.bold( LNG5.SCL_TXT_112 ), cattributes=>pfx.qbground );
    else
      if user_type = 'E' then htp.tableHeader( htf.bold( nvl(rDefaults.branch_title,'Campus') ), cattributes=>pfx.qbground ); end if;
   end if;
   if pFunctionality = MAINTENANCE then
      htp.tableHeader( htf.bold( LNG5.BKN_TXT_021 ), cattributes=>pfx.qbground );
   end if;
   htp.tableRowClose;
   if lCount = 0 then
      htp.tableRowOpen;
      htp.tableData( 'Your search returned no rows', ccolspan=>'14' );
      htp.tableRowClose;
   elsif lCount > 100 then
      htp.tableRowOpen;
      htp.tableData( LNG5.BKN_TXT_113, ccolspan=>'14' );
      htp.tableRowClose;
   else
      for c0rec in c0( acid, user_type, TO_NUMBER( p_id ), p_name, p_street,
                       p_suburb, p_country, p_pcode, p_state, p_email, lSearchRange ) loop
         htp.tableRowOpen;
            if pFunctionality = MAINTENANCE then
               htp.tableData( htf.anchor( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'scl.update_profile?surl=' || surl || '&acid=' || acid || '&user_type=' || user_type || '&sid=' || c0rec.contact_id, htf.bold( c0rec.profile_id ) ), cattributes=>pfx.qbground );
            elsif pFunctionality = CONNECTAS then
               if lLoginType = 'MANUFACTURER' then
                  open c7( c0rec.aid );
                  fetch c7 into c7rec;
                  close c7;
                  htp.tableData( htf.anchor2( owa_util.get_cgi_env('SCRIPT_NAME') || '/' ||
                                 'bkn.login_connectas?surl=' || surl || '&acid=' ||
                                 acid || '&profid=' || c7rec.profile_id, 'Connect',
                                 'login_as_profile', '_blank' ), cattributes=>pfx.qbground );
               elsif lLoginType = 'PROFILE' then
                  open c7( c0rec.aid );
                  fetch c7 into c7rec;
                  close c7;
                  htp.tableData( htf.anchor2( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'phg.customer_logon?surl=' || surl || '&acid=' || acid || '&login_type=PROFILE' || '&profid=' || c7rec.profile_id, 'Connect', 'login_as_profile', '_blank' ), cattributes=>pfx.qbground );
               end if;
               -- htp.tableData( htf.anchor2( 'glbx.accept_login?UN=' || c7rec.username || '&PW=' || c7rec.password, LNG3.ADM_TXT_040, 'login_as_profile', '_blank' ), cattributes=>pfx.qbground );
            elsif pFunctionality = SELECTIONGUEST OR pFunctionality = SELECTION then
               htp.tableHeader( htf.anchor( owa_util.get_cgi_env('SCRIPT_NAME') || '/' ||
                                'bkn.accept_select_profile?surl=' ||
                                surl || '&acid=' || acid || '&sid=' ||
                                c0rec.aid || '&bid=' || bid || '&action=OK' ||
                                '&user_type=' || c0rec.user_type || '&rurl=' ||
                                rurl, htf.bold( LNG5.BKN_TXT_063 ) ),
                                cattributes=>pfx.qbground );
            elsif pFunctionality = LOGIN then
               open c7( c0rec.aid );
               fetch c7 into c7rec;
               close c7;
               htp.tableData( htf.anchor( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'bkn.login2?acid=' || acid || '&username=' || c7rec.username, htf.bold( LNG5.BKN_TXT_063 ) ), cattributes=>pfx.qbground );
            end if;
            htp.tableData( c0rec.billing_name, cattributes=>pfx.qcbground );
            htp.tableData( c0rec.billing_street, cattributes=>pfx.qcbground );
            htp.tableData( c0rec.billing_suburb, cattributes=>pfx.qcbground );
            -- htp.tableData( c0rec.billing_country, cattributes=>pfx.qcbground );
            htp.tableData( c0rec.billing_postcode, cattributes=>pfx.qcbground );
            if pFunctionality != SELECTIONGUEST then
               htp.tableData( c0rec.billing_state, cattributes=>pfx.qcbground );
            end if;
            htp.tableData( htf.mailto( c0rec.billing_email, c0rec.billing_email ), cattributes=>pfx.qcbground );
            htp.tableData( c0rec.billing_phone, cattributes=>pfx.qcbground );
            if pFunctionality != SELECTIONGUEST then
               htp.tableData( c0rec.billing_fax, cattributes=>pfx.qcbground );
               if user_type = 'T' then htp.tableData( c0rec.sendto_name, cattributes=>pfx.qcbground ); end if;
               if user_type = 'E' then htp.tableData( nvl(c0rec.billing_branch,'&nbsp;'), cattributes=>pfx.qcbground ); end if; -- Campus
               if user_type = 'T' then htp.tableData( c0rec.contact_phone, cattributes=>pfx.qcbground ); end if;
               if rDefaults.user_defined_1 is not null then htp.tableData( nvl(c0rec.bk1,'&nbsp;'), cattributes=>pfx.qcbground ); end if; -- Campus
               if rDefaults.user_defined_2 is not null then htp.tableData( nvl(c0rec.bk2,'&nbsp;'), cattributes=>pfx.qcbground ); end if; -- Campus
               if rDefaults.user_defined_3 is not null then htp.tableData( nvl(c0rec.bk3,'&nbsp;'), cattributes=>pfx.qcbground ); end if; -- Campus
               if rDefaults.user_defined_4 is not null then htp.tableData( nvl(c0rec.bk4,'&nbsp;'), cattributes=>pfx.qcbground ); end if; -- Campus
               if rDefaults.user_defined_5 is not null then htp.tableData( nvl(c0rec.bk5,'&nbsp;'), cattributes=>pfx.qcbground ); end if; -- Campus
               if rDefaults.user_defined_6 is not null then htp.tableData( nvl(c0rec.bk6,'&nbsp;'), cattributes=>pfx.qcbground ); end if; -- Campus
               -- htp.tableData( htf.mailto( c0rec.contact_email, c0rec.contact_email ), cattributes=>pfx.qcbground );
             else
               if user_type = 'E' then htp.tableData( nvl(c0rec.billing_branch,'&nbsp;'), cattributes=>pfx.qcbground ); end if; -- Campus
            end if;
            if pFunctionality = MAINTENANCE then
               htp.tableHeader( htf.anchor( 'scl.delete_profile?surl=' || surl || '&acid=' || acid || '&user_type=' || user_type || '&sid=' || c0rec.contact_id, LNG5.SCL_TXT_114 ), cattributes=>pfx.qcbground );
            end if;
         htp.tableRowClose;
      end loop;
   end if;
   htp.tableClose;
   htp.nl;
   end if;

   /*
   if pFunctionality = MAINTENANCE then
      if user_type = 'E' then
         htp.formSubmit( 'action', 'Insert school' );
      elsif user_type = 'T' then
         htp.formSubmit( 'action', 'Insert bus company' );
      end if;
   end if;
   htp.formClose;
   */

   if pFunctionality != SELECTIONGUEST then
      htp.p( '</center>' );
   else
      htp.p( '<script type="text/javascript" src="' || BKN.BKN_BOTTOMSCRIPT || '"></script>' );
   end if;
   if pFunctionality != LOGIN then
      dapi.pageClose;
   end if;
exception
   when VALUE_ERROR then
      mng_booking_profiles( surl, acid, user_type );
   when others then
      glbx.error_details( 'SCL', 'MNG_BOOKING_PROFILES',errmsg=>sqlerrm );
end mng_booking_profiles;

procedure update_profile(
  surl    varchar2,
  acid    integer,
  user_type varchar2,
  sid     integer,
  errText varchar2 default null )
as

   cursor c0( csid integer ) is select * from customer_contact where contact_id = csid;
   cursor c2( cprofid integer ) is select * from customer_profile where profile_id = cprofid;
   cursor c3( cprofid integer ) is
    select *
    from audit_profile_password
    where profile_id = cprofid and
          date_changed in (select max(date_changed) from audit_profile_password where profile_id = cprofid);
   cursor c4(phgid integer, acid integer) is select * from school_booking_prefs where std_profile_aid = acid and std_profile_pid = phgid;

   c0rec c0%ROWTYPE;
   c2rec c2%ROWTYPE;
   c3rec c3%ROWTYPE;
   c4rec c4%ROWTYPE;

   pfx		THEME%ROWTYPE;
begin
   if not dapi.init( surl, 'SCL.UPDATE_PROFILE', iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
   end if;
   pfx := dapi.getLFRecord;
   if user_type = 'E' then
      dapi.setTitle( 'UPDATE SCHOOL DETAILS' );
   elsif user_type = 'T' then
      dapi.setTitle( 'UPDATE BUS COMPANY DETAILS' );
   end if;
   dapi.addStyle( 'INPUT.text', '{width: 20em}' );
   dapi.pageOpen;
   open c0( sid );
   fetch c0 into c0rec;
   close c0;
   open c2( c0rec.aid );
   fetch c2 into c2rec;
   close c2;
   open c4( c2rec.pid, c2rec.aid );
   fetch c4 into c4rec;
   close c4;
   htp.p( '<center>' );
   htp.p( '<font size="+3" color="#' || pfx.error_text_colour || '" FACE="' || pfx.error_text_font || '">'|| errText || '</font>' );
   htp.formOpen( 'scl.accept_update_profile' );
   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   htp.formHidden( 'user_type', user_type );
   htp.formHidden( 'P_id', sid );
   htp.tableOpen( cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_125 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'P_name', '100', '100', c0rec.billing_name, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_126 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'P_street', '100', '100', c0rec.billing_street, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_127 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'P_suburb', '100', '100', c0rec.billing_suburb, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_129 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'P_pcode', '10', '10', c0rec.billing_postcode, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_130 ), cattributes=>pfx.qbground );
   htp.tableData( ste.get_state_lov( 'P_state', c0rec.billing_state ), cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_128 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'P_country', '100', '100', c0rec.billing_country, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_160 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'P_email', '100', '100', c0rec.billing_email, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_161 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'P_phone', '30', '30', c0rec.billing_phone, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_162 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'P_fax', '100', '100', c0rec.billing_fax, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_131 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'P_teachers_name', '100', '100', c0rec.sendto_name, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_134 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'P_teachers_phone', '30', '30', c0rec.contact_phone, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;

   if c4rec.branch_title is not null
    then
     htp.tableRowOpen;
     htp.tableData( htf.bold( c4rec.branch_title ), cattributes=>pfx.qbground );
     htp.tableData( htf.formText( 'P_Branch', '100', '100', c0rec.billing_branch, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
     htp.tableRowClose;
   end if;

   if c4rec.user_defined_1 is not null
    then
     htp.tableRowOpen;
     htp.tableData( htf.bold( c4rec.user_defined_1 ), cattributes=>pfx.qbground );
     htp.tableData( htf.formText( 'P_Udf1', '100', '100', c0rec.booking_defined_1, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
     htp.tableRowClose;
   end if;

   if c4rec.user_defined_2 is not null
    then
     htp.tableRowOpen;
     htp.tableData( htf.bold( c4rec.user_defined_2 ), cattributes=>pfx.qbground );
     htp.tableData( htf.formText( 'P_Udf2', '100', '100', c0rec.booking_defined_2, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
     htp.tableRowClose;
   end if;

   if c4rec.user_defined_3 is not null
    then
     htp.tableRowOpen;
     htp.tableData( htf.bold( c4rec.user_defined_3 ), cattributes=>pfx.qbground );
     htp.tableData( htf.formText( 'P_Udf3', '100', '100', c0rec.booking_defined_3, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
     htp.tableRowClose;
   end if;

   if c4rec.user_defined_4 is not null
    then
     htp.tableRowOpen;
     htp.tableData( htf.bold( c4rec.user_defined_4 ), cattributes=>pfx.qbground );
     htp.tableData( htf.formText( 'P_Udf4', '100', '100', c0rec.booking_defined_4, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
     htp.tableRowClose;
   end if;

   if c4rec.user_defined_5 is not null
    then
     htp.tableRowOpen;
     htp.tableData( htf.bold( c4rec.user_defined_5 ), cattributes=>pfx.qbground );
     htp.tableData( htf.formText( 'P_Udf5', '100', '100', c0rec.booking_defined_5, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
     htp.tableRowClose;
   end if;

   if c4rec.user_defined_6 is not null
    then
     htp.tableRowOpen;
     htp.tableData( htf.bold( c4rec.user_defined_6 ), cattributes=>pfx.qbground );
     htp.tableData( htf.formText( 'P_Udf6', '100', '100', c0rec.booking_defined_6, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
     htp.tableRowClose;
   end if;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_132 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'P_teachers_email', '100', '100', c0rec.contact_email, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Login information' ), ccolspan=>'2', cattributes=>pfx.qbground || ' ALIGN="CENTER"' );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Profile user name' ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'p_profile_un', '100', '100', c2rec.username, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Profile password' ), cattributes=>pfx.qbground );
   open c3( c0rec.aid );
   fetch c3 into c3rec;
   close c3;
   htp.tableData( htf.formPassword( 'p_profile_pw', '100', '100', cattributes=>'class="text"' ) || htf.nl || nvl(c3rec.pw,'Password not found'), cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Confirm password' ), cattributes=>pfx.qbground );
   htp.tableData( htf.formPassword( 'p_profile_cpw', '100', '100', cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Profile expiry date ' || LNG.MASK ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'p_date_expires', cvalue=>to_char( c2rec.date_expires, LNG.MASK ), cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;
   /*Deliberately commented out MK at request by JF. Maybe to be included later.
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Profile is Disabled' ), cattributes=>pfx.qbground );
   if nvl(c2rec.customer_disabled,'F') = 'F' then
      htp.tableData( htf.formCheckbox( 'p_customer_disabled', 'T' ), cattributes=>pfx.qcbground );
   else
      htp.tableData( htf.formCheckbox( 'p_customer_disabled', 'T', 'CHECKED' ), cattributes=>pfx.qcbground );
   end if;
   htp.tableRowClose;
   */
   htp.tableClose;
   htp.formSubmit( 'action', LNG.CST_BUT_018 );
   htp.formSubmit( 'action', LNG.CST_BUT_017 );
   htp.formSubmit( 'action', LNG.CST_BUT_016 );
   htp.formClose;
   htp.p( '</center>' );
   dapi.pageClose;
exception when others then
   glbx.error_details( 'SCL', 'UPDATE_PROFILE',errmsg=>sqlerrm );
end update_profile;

procedure accept_update_profile(
  surl 			varchar2,
  acid 			integer,
  user_type 		varchar2,
  P_id      		integer,
  P_name    		varchar2,
  P_street         	varchar2,
  P_suburb         	varchar2,
  P_country           	varchar2,
  P_pcode          	varchar2,
  P_state          	varchar2,
  P_email          	varchar2,
  P_fax     		varchar2,
  P_phone   		varchar2,
  P_teachers_name  	varchar2,
  P_teachers_phone 	varchar2,
  P_teachers_email 	varchar2,
  P_Branch	 	varchar2 default null,
  P_udf1	 	varchar2 default null,
  P_udf2	 	varchar2 default null,
  P_udf3	 	varchar2 default null,
  P_udf4	 	varchar2 default null,
  P_udf5	 	varchar2 default null,
  P_udf6	 	varchar2 default null,
  p_profile_nam    	varchar2 default null,
  p_profile_un     	varchar2 default null,
  p_profile_pw     	varchar2 default null,
  p_profile_cpw    	varchar2 default null,
  p_profile_pwg    	varchar2 default null,
  p_date_expires   	varchar2 default null,
  p_customer_disabled 	varchar2 default 'F',
  action           	varchar2 default null )
as
   /*
      Cursor definitions
   */
   cursor c1( ccid integer ) is
      select
         aid
      from
         customer_contact
      where
         contact_id = ccid;
   c1rec c1%ROWTYPE;

   cursor c2( cpid integer ) is
      select
         username
      from
         customer_profile
      where
         profile_id = cpid;
   c2rec c2%ROWTYPE;
   /*
      Exceptions
   */
   INVALID_ENTRY Exception;
   /*
      Work Variables
   */
   returnMessage varchar2( 100 );
   p_firstname	 varchar2(100);
   p_lastname    varchar2(100);
   P_teachers_firstname varchar2(100);
   P_teachers_lastname varchar2(100);
begin
   if not dapi.init( surl, 'BKN.ACCEPT_UPDATE_PROFILE', iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
   end if;
   returnMessage := null;
   if action in ( LNG.CST_BUT_017, LNG.CST_BUT_018 ) then
      --
      -- Check if the confirmation of the password is equal to the password
      --
      if p_profile_pw is not null
       then
        if p_profile_pw != nvl(p_profile_cpw,'|') then
           returnMessage := returnMessage || '<BR>Your passwords do not match';
        end if;
      end if;
      --
      -- Check if username has changed
      --
      open c1( p_id );
      fetch c1 into c1rec;
      close c1;
      open c2( c1rec.aid );
      fetch c2 into c2rec;
      close c2;
      if upper( trim( c2rec.username ) ) != upper( trim( p_profile_un ) ) then
         if glbx.userexists( p_profile_un ) then
            returnMessage :=  returnMessage || '<BR>Sorry, profile user already exists';
         end if;
      end if;
      --
      -- If there has been an error then raise an exception
      --
      if returnMessage is not null then
         raise INVALID_ENTRY;
      end if;
      --
      -- Save changes in customer_contact
      --
      glbx.fixnm(p_name,p_firstname,p_lastname);
      glbx.fixnm(P_teachers_name,P_teachers_firstname,P_teachers_lastname);
      update customer_contact set
         billing_name      = P_name,
         billing_firstname      = P_firstname,
         billing_lastname      = P_lastname,
         billing_street    = P_street,
         billing_suburb    = P_suburb,
         billing_country   = P_country,
         billing_postcode  = P_pcode,
         billing_state     = P_state,
         billing_email     = P_email,
         billing_fax       = P_fax,
         billing_phone     = P_phone,
         sendto_name       = P_teachers_name,
         sendto_firstname       = P_teachers_firstname,
         sendto_lastname       = P_teachers_lastname,
         contact_phone     = P_teachers_phone,
         contact_email     = P_teachers_email,
         billing_branch    = P_branch,
         booking_defined_1 = P_udf1,
         booking_defined_2 = P_udf2,
         booking_defined_3 = P_udf3,
         booking_defined_4 = P_udf4,
         booking_defined_5 = P_udf5,
         booking_defined_6 = P_udf6
         where contact_id = P_id;
      --
      -- Save profile
      --
      if p_profile_pw is not null
       then
        insert into audit_profile_password(profile_id,date_changed,pw,pwg) values (c1rec.aid,sysdate,upper( p_profile_pw ),upper( p_profile_pw ) || 'G');
        update customer_profile set
         account_name      = p_name,
         username          = upper( p_profile_un ),
         password          = glbx.encrypt( upper( p_profile_pw ) || 'G' ),
         password_owner    = glbx.encrypt( upper( p_profile_pw ) ),
         date_expires      = to_date( p_date_expires, LNG.MASK ),
         customer_disabled = p_customer_disabled
         where profile_id  = c1rec.aid;
       else
        update customer_profile set
         account_name      = p_name,
         username          = upper( p_profile_un ),
         date_expires      = to_date( p_date_expires, LNG.MASK ),
         customer_disabled = p_customer_disabled
         where profile_id  = c1rec.aid;
      end if;
   end if;

   if action in ( LNG.CST_BUT_016, LNG.CST_BUT_018 ) then
      -- Save changes and/or return to maintenance screen
      mng_booking_profiles( surl, acid, user_type );
   else
      -- Save changes and return to update screen
      update_profile( surl, acid, user_type, P_id );
   end if;

exception
   when INVALID_ENTRY then
      update_profile( surl, acid, user_type, p_id, returnMessage );
   when others then
      glbx.error_details( 'SCL', 'ACCEPT_UPDATE_PROFILE',errmsg=>sqlerrm );
end accept_update_profile;

procedure insert_profile(
  surl varchar2,
  acid integer,
  user_type varchar2,
  errText varchar2 default null,
  P_name    varchar2 default null,
  P_street         varchar2 default null,
  P_suburb         varchar2 default null,
  P_country           varchar2 default null,
  P_pcode          varchar2 default null,
  P_state          varchar2 default null,
  P_email          varchar2 default null,
  P_fax     varchar2 default null,
  P_phone   varchar2 default null,
  P_teachers_name  varchar2 default null,
  P_teachers_phone varchar2 default null,
  P_teachers_email varchar2 default null,
  P_Branch	 	varchar2 default null,
  P_udf1	 	varchar2 default null,
  P_udf2	 	varchar2 default null,
  P_udf3	 	varchar2 default null,
  P_udf4	 	varchar2 default null,
  P_udf5	 	varchar2 default null,
  P_udf6	 	varchar2 default null,
  p_profile_name   varchar2 default null,
  p_profile_un     varchar2 default null,
  p_profile_pw     varchar2 default null,
  p_profile_cpw    varchar2 default null,
  p_profile_pwg    varchar2 default null,
  p_date_expires   varchar2 default null,
  p_customer_disabled varchar2 default 'F',
  action           varchar2 default null )
as
   /*
      Work variables
   */
   cursor c4(phgid integer, acid integer) is select * from school_booking_prefs where std_profile_aid = acid and std_profile_pid = phgid;

   pfx		     THEME%ROWTYPE;
   new_date_expires  varchar2( 50 );
   c4rec	     c4%ROWTYPE;

begin
   if not dapi.init( surl, 'SCL.INSERT_PROFILE', iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
   end if;
   pfx := dapi.getLFRecord;
   if user_type = 'E' then
      dapi.setTitle( 'INSERT A SCHOOL' );
   elsif user_type = 'T' then
      dapi.setTitle( 'INSERT A BUS COMPANY' );
   end if;
   open c4( dapi.getPhotographerId, acid );
   fetch c4 into c4rec;
   close c4;
   dapi.addStyle( 'INPUT.text', '{width: 20em}' );
   dapi.pageOpen;
   htp.p( '<CENTER>' );
   htp.p( '<font size="+3" color="#' || pfx.error_text_colour || '" FACE="' || pfx.error_text_font || '">'|| errText || '</font>' );
   htp.formOpen( 'scl.accept_insert_profile', cattributes=>'NAME="form1"' );
   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   htp.formHidden( 'p_user_type', user_type );
   htp.tableOpen( cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );
   htp.tableRowOpen( cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );
   htp.tableData( htf.bold( LNG5.BKN_TXT_125 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'P_name', '100', '100', p_name, cattributes=>'class="text"
      onChange="javascript: if( form1.p_profile_un.value == '''' ) form1.p_profile_un.value = this.value;" ' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_126 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'P_street', '100', '100', p_street, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_127 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'P_suburb', '100', '100', p_suburb, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_129 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'P_pcode', '10', '10', p_pcode, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_130 ), cattributes=>pfx.qbground );
   htp.tableData( ste.get_state_lov( 'P_state' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_128 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'P_country', '100', '100', p_country, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_160 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'P_email', '100', '100', p_email, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_161 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'P_phone', '30', '30', p_phone, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_162 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'P_fax', '100', '100', p_fax, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_131 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'P_teachers_name', '100', '100', p_teachers_name, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_134 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'P_teachers_phone', '30', '30', p_teachers_phone, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;

   if c4rec.branch_title is not null
    then
     htp.tableRowOpen;
     htp.tableData( htf.bold( c4rec.branch_title ), cattributes=>pfx.qbground );
     htp.tableData( htf.formText( 'P_Branch', '100', '100', p_branch, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
     htp.tableRowClose;
   end if;

   if c4rec.user_defined_1 is not null
    then
     htp.tableRowOpen;
     htp.tableData( htf.bold( c4rec.user_defined_1 ), cattributes=>pfx.qbground );
     htp.tableData( htf.formText( 'P_Udf1', '100', '100', p_udf1, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
     htp.tableRowClose;
   end if;

   if c4rec.user_defined_2 is not null
    then
     htp.tableRowOpen;
     htp.tableData( htf.bold( c4rec.user_defined_2 ), cattributes=>pfx.qbground );
     htp.tableData( htf.formText( 'P_Udf2', '100', '100', p_udf2, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
     htp.tableRowClose;
   end if;

   if c4rec.user_defined_3 is not null
    then
     htp.tableRowOpen;
     htp.tableData( htf.bold( c4rec.user_defined_3 ), cattributes=>pfx.qbground );
     htp.tableData( htf.formText( 'P_Udf3', '100', '100', p_udf3, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
     htp.tableRowClose;
   end if;

   if c4rec.user_defined_4 is not null
    then
     htp.tableRowOpen;
     htp.tableData( htf.bold( c4rec.user_defined_4 ), cattributes=>pfx.qbground );
     htp.tableData( htf.formText( 'P_Udf4', '100', '100', p_udf4, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
     htp.tableRowClose;
   end if;

   if c4rec.user_defined_5 is not null
    then
     htp.tableRowOpen;
     htp.tableData( htf.bold( c4rec.user_defined_5 ), cattributes=>pfx.qbground );
     htp.tableData( htf.formText( 'P_Udf5', '100', '100', p_udf5, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
     htp.tableRowClose;
   end if;

   if c4rec.user_defined_6 is not null
    then
     htp.tableRowOpen;
     htp.tableData( htf.bold( c4rec.user_defined_6 ), cattributes=>pfx.qbground );
     htp.tableData( htf.formText( 'P_Udf6', '100', '100', p_udf6, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
     htp.tableRowClose;
   end if;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_132 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'P_teachers_email', '100', '100', p_teachers_email, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Login information' ), ccolspan=>'2', cattributes=>pfx.qbground || ' ALIGN="CENTER"' );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Profile user name' ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'p_profile_un', '100', '100', p_profile_un, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Profile password' ), cattributes=>pfx.qbground );
   htp.tableData( htf.formPassword( 'p_profile_pw', '100', '100', p_profile_pw, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Confirm password' ), cattributes=>pfx.qbground );
   htp.tableData( htf.formPassword( 'p_profile_cpw', '100', '100', p_profile_cpw, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;
   new_date_expires := nvl( p_date_expires, to_char( add_months( sysdate, 24 ), LNG.MASK ) );
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Profile expiry date ' || LNG.MASK ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'p_date_expires', cvalue=>new_date_expires, cattributes=>'class="text"' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;
   htp.tableRowOpen;
   /*Deliberately commented out MK at request by JF. Maybe to be included later.
   htp.tableData( htf.bold( 'Profile is Disabled' ), cattributes=>pfx.qbground );
   if nvl(p_customer_disabled,'F') = 'F' then
      htp.tableData( htf.formCheckbox( 'p_customer_disabled', 'T' ), cattributes=>pfx.qcbground );
   else
      htp.tableData( htf.formCheckbox( 'p_customer_disabled', 'T', 'CHECKED' ), cattributes=>pfx.qcbground );
   end if;
   htp.tableRowClose;
   */
   htp.tableClose;
   htp.formSubmit( 'action', LNG5.BKN_TXT_141 ); -- Insert and continue
   htp.formSubmit( 'action', LNG3.ADM_TXT_396 ); -- Insert and return
   htp.formSubmit( 'action', LNG.CST_BUT_016 );  -- Cancel
   htp.formClose;
   htp.p( '</CENTER>' );
   dapi.pageClose;
exception when others then
   glbx.error_details( 'SCL', 'INSERT_PROFILE',errmsg=>sqlerrm );
end insert_profile;

procedure accept_insert_profile(
  surl             in varchar2,
  acid integer,
  p_user_type varchar2,
  P_name    varchar2 default null,
  P_street         varchar2 default null,
  P_suburb         varchar2 default null,
  P_country           varchar2 default null,
  P_pcode          varchar2 default null,
  P_state          varchar2 default null,
  P_email          varchar2 default null,
  P_fax     varchar2 default null,
  P_phone   varchar2 default null,
  P_teachers_name  varchar2 default null,
  P_teachers_phone varchar2 default null,
  P_teachers_email varchar2 default null,
  P_Branch	   varchar2 default null,
  P_udf1	   varchar2 default null,
  P_udf2	   varchar2 default null,
  P_udf3	   varchar2 default null,
  P_udf4	   varchar2 default null,
  P_udf5	   varchar2 default null,
  P_udf6	   varchar2 default null,
  p_profile_name   varchar2 default null,
  p_profile_un     varchar2 default null,
  p_profile_pw     varchar2 default null,
  p_profile_cpw    varchar2 default null,
  p_profile_pwg    varchar2 default null,
  p_date_expires   varchar2 default null,
  p_customer_disabled varchar2 default 'F',
  action           varchar2 default null )
as
   cursor c2( cpname varchar2 ) is
      select profile_id, pid
      from customer_profile
      where upper( username ) = upper( cpname );

   INVALID_ENTRY Exception;

   c2rec      c2%ROWTYPE;
   rDefaults  school_booking_prefs%ROWTYPE;

   new_id integer;
   returnsurl    varchar2( 200 );
   result        varchar2( 200 );
   new_contact_id integer;
   returnMessage  varchar2( 100 ) := null;
begin
   if not dapi.init( surl, 'BKN.ACCEPT_INSERT_PROFILE', iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   rDefaults := bkn.getDefaults( acid );
   if action in ( LNG5.BKN_TXT_141, LNG3.ADM_TXT_396 ) then
      -- Check if the passwords are equal
      if p_profile_pw != p_profile_cpw then
         returnMessage := returnMessage || '<BR>Your passwords do not match';
         raise INVALID_ENTRY;
      end if;
      -- Insert into profile table
      glbx.create_profile( surl=>surl, profile_name=>p_profile_un,
                           profile_un=>p_profile_un,
                           profile_pw=>upper( p_profile_pw ) || 'G',
                           profile_pwg=>upper( p_profile_pw ),
                           bftr=>rDefaults.STD_PROFILE_BF,
                           laf=>rDefaults.STD_PROFILE_LAF,
                           transfer_lbox=>FALSE, acid=>acid,
                           disconnect_session=>FALSE,
                           return_surl=>returnsurl, result=>result );

      if length( RTRIM( result ) ) > 0 then
         rollback;
         returnMessage := returnMessage || '<BR>' || result;
      end if;

      if returnMessage is not null then
         raise INVALID_ENTRY;
      else
         -- Fetch profile_id on base of the profile username
         open c2( p_profile_un );
         fetch c2 into c2rec;
         close c2;
         -- Insert into customer_contact table
         select s_customer_contact.nextval into new_contact_id from dual;
         insert into customer_contact (
            contact_id, aid, login_type, user_type, sendto_name, contact_phone,
            contact_email, billing_name, billing_street, billing_suburb, billing_country,
            billing_postcode, billing_email, billing_fax, billing_phone, billing_state,
            date_updated, tax_group, billing_branch, booking_defined_1, booking_defined_2, booking_defined_3, booking_defined_4, booking_defined_5, booking_defined_6 )
         values (
            new_contact_id, c2rec.profile_id, 'PROFILE', p_user_type, p_teachers_name,
            p_teachers_phone, p_teachers_email, p_name, p_street, p_suburb, p_country,
            p_pcode, p_email, p_fax, p_phone, p_state, sysdate, rdefaults.default_tax_group, p_branch, p_udf1, p_udf2, p_udf3, p_udf4, p_udf5, p_udf6 );
         -- Set customer profile details
         update customer_profile
            set account_name = P_name,
                date_expires = to_date( p_date_expires, LNG.MASK ),
                customer_disabled = p_customer_disabled
            where profile_id = c2rec.profile_id;

         -- Create order style
         insert into customer_price_book(
            pid, aid, valid_until, b2c_enabled, ltype, oid, oid_when_invalid )
         values(
            c2rec.pid, c2rec.profile_id, to_date( p_date_expires, LNG.MASK ), 'F',
            'PROFILE', rDefaults.STD_ORDER_STYLE, rDefaults.STD_ORDER_STYLE );
         commit;
      end if;
   end if;

   if action in ( LNG5.BKN_TXT_141 ) then
   	--
   	-- Insert and continue insert
   	--
      insert_profile( surl, acid, p_user_type );
   end if;

   if action in ( LNG3.ADM_TXT_396, LNG.CST_BUT_016 ) then
   	--
   	-- Cancel or insert
   	--
      mng_booking_profiles( surl, acid, p_user_type );
   end if;
exception
   when INVALID_ENTRY then
      insert_profile( surl, acid, p_user_type, returnMessage, p_name, p_street, p_suburb, p_country, p_pcode, p_state, p_email, p_fax, p_phone, p_teachers_name, p_teachers_phone, p_teachers_email, p_branch, p_udf1, p_udf2, p_udf3, p_udf4, p_udf5, p_udf6, p_profile_name, p_profile_un, p_profile_pw, p_profile_cpw, p_profile_pwg, p_date_expires, p_customer_disabled );
   when others then
      glbx.error_details( 'SCL', 'ACCEPT_INSERT_PROFILE', errmsg=>sqlerrm );
end accept_insert_profile;

procedure delete_profile(
  surl varchar2,
  acid integer,
  user_type varchar2,
  sid integer )
as
   cursor c0( csid integer ) is
   select
      *
   from
      customer_contact
   where
      contact_id = csid;
   c0rec c0%ROWTYPE;

   cursor c2( csid integer ) is
   select
      *
   from
      states
   where
      state_id = csid;
   c2rec c2%ROWTYPE;

   pfx		 THEME%ROWTYPE;
begin
   if not dapi.init( surl, 'SCL.DELETE_PROFILE', iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
   end if;
   pfx := dapi.getLFRecord;
   if user_type = 'E' then
      dapi.setTitle( 'DELETE SCHOOL' );
   elsif user_type = 'T' then
      dapi.setTitle( 'DELETE BUS COMPANY' );
   end if;
   dapi.pageOpen;
   open c0( sid );
   fetch c0 into c0rec;
   close c0;
   htp.p( '<CENTER>' );
   htp.formOpen( 'scl.accept_delete_profile' );
   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   htp.formHidden( 'user_type', user_type );
   htp.formHidden( 'sid', sid );

   htp.tableOpen( cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.SCL_TXT_101 ), cattributes=>pfx.qbground );
   htp.tableData( c0rec.billing_name, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.SCL_TXT_107 ), cattributes=>pfx.qbground );
   htp.tableData( c0rec.billing_street, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.SCL_TXT_104 ), cattributes=>pfx.qbground );
   htp.tableData( c0rec.billing_suburb, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.SCL_TXT_103 ), cattributes=>pfx.qbground );
   htp.tableData( c0rec.billing_postcode, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.SCL_TXT_105 ), cattributes=>pfx.qbground );
   htp.tableData( c0rec.billing_state, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.SCL_TXT_102 ), cattributes=>pfx.qbground );
   htp.tableData( c0rec.billing_country, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.SCL_TXT_106 ), cattributes=>pfx.qbground );
   htp.tableData( c0rec.billing_email, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.SCL_TXT_108 ), cattributes=>pfx.qbground );
   htp.tableData( c0rec.billing_phone, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.SCL_TXT_109 ), cattributes=>pfx.qbground );
   htp.tableData( c0rec.billing_fax, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.SCL_TXT_110 ), cattributes=>pfx.qbground );
   htp.tableData( c0rec.sendto_name, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.SCL_TXT_111 ), cattributes=>pfx.qbground );
   htp.tableData( c0rec.contact_phone, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.SCL_TXT_112 ), cattributes=>pfx.qbground );
   htp.tableData( c0rec.contact_email, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableClose;

   if user_type = 'E' then
      htp.formSubmit( 'action', 'DELETE THIS SCHOOL' ); -- Delete
   elsif user_type = 'T' then
      htp.formSubmit( 'action', 'DELETE THIS BUS COMPANY' ); -- Cancel
   end if;
   htp.formSubmit( 'action', LNG.CST_BUT_016 ); -- Cancel

   htp.formClose;

   htp.p( '</CENTER>' );

   glbx.close_page( pfx );

   exception when others then
      glbx.error_details( 'SCL', 'DELETE_PROFILE',errmsg=>sqlerrm );

end delete_profile;


procedure accept_delete_profile(
  surl varchar2,
  acid integer,
  user_type varchar2,
  sid integer,
  action varchar2 default null )
as
   cursor c1( csid integer ) is select aid from customer_contact where contact_id = csid;
   c1rec c1%ROWTYPE;
begin
   if action in ( 'DELETE THIS SCHOOL', 'DELETE THIS BUS COMPANY' ) then
      open c1( sid );
      fetch c1 into c1rec;
      close c1;
      delete from customer_profile where profile_id = c1rec.aid;
      delete from customer_contact where contact_id = sid;
   end if;
   mng_booking_profiles( surl, acid, user_type );
end accept_delete_profile;

procedure setup_filter( surl varchar2 )
as
   sFilter varchar( 200 );
begin
   sFilter := '';
end setup_filter;

procedure login_as(
  surl          varchar2,
  acid integer,
  user_type varchar2,
  sid           varchar2 default null,
  p_id   varchar2 default null,
  p_name varchar2 default null,
  p_street      varchar2 default null,
  p_suburb      varchar2 default null,
  p_country        varchar2 default null,
  p_pcode       varchar2 default null,
  p_state       varchar2 default null,
  p_email       varchar2 default null,
  action        varchar2 default null,
  search_range  varchar2 default '0Z' )
as
   --
   -- Selection of profiles using filter
   --
   cursor c0(
         c_pid         integer,
         c_aid         integer,
         c_id   integer,
         c_name varchar2,
         c_street      varchar2,
         c_suburb      varchar2,
         c_country        varchar2,
         c_pcode       varchar2,
         c_state       varchar2,
         c_email       varchar2,
         c_search_range varchar2
         ) is
      select
         cc.billing_name      billing_name,
         cc.billing_street    billing_street,
         cc.billing_suburb    billing_suburb,
         cc.billing_country      billing_country,
         cc.billing_postcode  billing_postcode,
         cc.billing_state     billing_state,
         cc.billing_email     billing_email,
         cc.billing_phone     billing_phone,
         cc.billing_fax       billing_fax,
         cc.sendto_name       sendto_name,
         cc.contact_phone     contact_phone,
         cc.contact_email     contact_email,
         cp.profile_id        profile_id,
         cp.username          username,
         cp.password          password
      from
         customer_contact cc,
         customer_profile cp
      where
         ( cc.user_type = 'E' ) and
         ( ( c_id is null ) or ( c_id is not null and cc.contact_id = c_id ) ) and
         ( ( c_name is null ) or ( c_name is not null and upper( cc.billing_name ) like '%' || upper( c_name ) || '%' ) ) and
         ( ( c_street is null ) or ( c_street is not null and upper( cc.billing_street ) like '%' || upper( c_street ) || '%' ) ) and
         ( ( c_suburb is null ) or ( c_suburb is not null and upper( cc.billing_suburb ) like '%' || upper( c_suburb ) || '%' ) ) and
         ( ( c_country is null ) or ( c_country is not null and upper( cc.billing_country ) like '%' || upper( c_country ) || '%' ) ) and
         ( ( c_pcode is null ) or ( c_pcode is not null and upper( cc.billing_postcode ) like '%' || upper( c_pcode ) || '%' ) ) and
         ( ( c_state is null ) or ( c_state is not null and cc.billing_state = c_state ) ) and
         ( ( c_email is null ) or ( c_email is not null and upper( cc.billing_email ) like '%' || upper( c_email ) || '%' ) ) and
         upper( substr( cc.billing_name,1,1 ) ) >= substr( c_search_range,1,1 ) and
         upper( substr( cc.billing_name,1,1 ) ) <= substr( c_search_range,2,1 ) and
         cc.aid in ( select cp.profile_id from customer_profile cp where cp.aid = c_aid and cp.pid = c_pid ) and
         cp.profile_id = cc.aid
      order by
         cc.billing_name;

   cursor c3 is
   	select
   	   pid,
   	   business_name
   	from
   	   photographer
   	order by
   	   business_name;

   cursor c3x( manid integer ) is
   	select
   	   p.pid,
   	   p.business_name
   	from
   	   photographer p,
   	   manufacturer_photographer mp
   	where
   	   mp.manufacturer_id = manid and mp.pid = p.pid
   	order by
   	   business_name;

   cursor c4( cpid integer ) is
   	select
   	   aid,
   	   account_name
   	from
   	   customer_account
   	where
   	   pid = cpid;
   --
   -- ROWTYPE definitions
   --
   c0rec     c0%ROWTYPE;
   c4rec     c4%ROWTYPE;
   pfx    THEME%ROWTYPE;
   rDefaults school_booking_prefs%ROWTYPE;
   --
   -- Local variables
   --
   range_anchor varchar2( 1000 );
   checkbox_on  varchar2( 100 ) := 'CHECKED';
begin
   if not dapi.init( surl, 'SCL.LOGIN_AS', iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
   end if;
   dapi.settitle( 'Select' );
   dapi.pageOpen;
   rDefaults := bkn.getDefaults( acid );
   htp.p( '<center>' );
   htp.formOpen( 'scl.login_as', cattributes=>'NAME="form2"' );
   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   htp.formHidden( 'sid', sid );

   htp.tableOpen( cattributes=>'cellpadding="1" cellspacing="0" border="1" ' || glbx.TABLE_BACKGROUND );
   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.SCL_TXT_115 ), cattributes=>pfx.qbground || ' COLSPAN="4"' );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.SCL_TXT_100 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'p_id', cvalue=>p_id ), cattributes=>pfx.qcbground );
   htp.tableData( htf.bold( LNG5.SCL_TXT_102 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'p_country', cvalue=>p_country ), cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.SCL_TXT_101 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'p_name', cvalue=>p_name ), cattributes=>pfx.qcbground );
   htp.tableData( htf.bold( LNG5.SCL_TXT_103 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'p_pcode', cvalue=>p_pcode ), cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.SCL_TXT_107 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'p_street', cvalue=>p_street ), cattributes=>pfx.qcbground );
   htp.tableData( htf.bold( LNG5.SCL_TXT_105 ), cattributes=>pfx.qbground );
   htp.tableData( ste.get_state_lov( 'p_state', p_state, TRUE ), cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.SCL_TXT_104 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'p_suburb', cvalue=>p_suburb ), cattributes=>pfx.qcbground );
   htp.tableData( htf.bold( LNG5.SCL_TXT_106 ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'p_email', cvalue=>p_email ), cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableClose;

   htp.formReset( LNG5.SCL_BTN_100 );
   htp.formSubmit( 'action', LNG5.SCL_BTN_101 );
   htp.formClose; -- form2
   --
   -- Build the link for the search range
   --
   range_anchor := 'scl.login_as?surl=' || surl ||
                   '&acid=' || acid ||
                   '&sid=' || sid ||
                   '&p_id=' || p_id ||
                   '&p_name=' || p_name ||
                   '&p_street=' || p_street ||
                   '&p_suburb=' || p_suburb ||
                   '&p_country=' || p_country ||
                   '&p_pcode=' || p_pcode ||
                   '&p_state=' || p_state ||
                   '&p_email=' || p_email ||
                   '&action=' || action;

   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=0' );

   htp.tablerowopen;
   htp.tabledata( htf.anchor( range_anchor || '&search_range=AC','[A-C]' ), cattributes=>' valign="CENTER" align="CENTER"' );
   htp.tabledata( htf.anchor( range_anchor || '&search_range=DF','[D-F]' ), cattributes=>' valign="CENTER" align="CENTER"' );
   htp.tabledata( htf.anchor( range_anchor || '&search_range=GI','[G-I]' ), cattributes=>' valign="CENTER" align="CENTER"' );
   htp.tabledata( htf.anchor( range_anchor || '&search_range=JL','[J-L]' ), cattributes=>' valign="CENTER" align="CENTER"' );
   htp.tabledata( htf.anchor( range_anchor || '&search_range=MO','[M-O]' ), cattributes=>' valign="CENTER" align="CENTER"' );
   htp.tabledata( htf.anchor( range_anchor || '&search_range=PS','[P-S]' ), cattributes=>' valign="CENTER" align="CENTER"' );
   htp.tabledata( htf.anchor( range_anchor || '&search_range=TV','[T-V]' ), cattributes=>' valign="CENTER" align="CENTER"' );
   htp.tabledata( htf.anchor( range_anchor || '&search_range=WZ','[W-Z]' ), cattributes=>' valign="CENTER" align="CENTER"' );
   htp.tabledata( htf.anchor( range_anchor || '&search_range=09','[0-9]' ), cattributes=>' valign="CENTER" align="CENTER"' );
   htp.tabledata( htf.anchor( range_anchor || '&search_range=0Z','[ALL]' ), cattributes=>' valign="CENTER" align="CENTER"' );
   htp.tablerowclose;

   htp.tableclose;

   htp.line;

   htp.nl;

   htp.tableOpen( cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );

   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Connect' ), cattributes=>pfx.qbground );
   htp.tableData( htf.bold( LNG5.SCL_TXT_101 ), cattributes=>pfx.qbground );
   htp.tableData( htf.bold( LNG5.SCL_TXT_107 ), cattributes=>pfx.qbground );
   htp.tableData( htf.bold( LNG5.SCL_TXT_104 ), cattributes=>pfx.qbground );
   htp.tableData( htf.bold( LNG5.SCL_TXT_102 ), cattributes=>pfx.qbground );
   htp.tableData( htf.bold( LNG5.SCL_TXT_103 ), cattributes=>pfx.qbground );
   htp.tableData( htf.bold( LNG5.SCL_TXT_105 ), cattributes=>pfx.qbground );
   htp.tableData( htf.bold( LNG5.SCL_TXT_106 ), cattributes=>pfx.qbground );
   htp.tableData( htf.bold( LNG5.SCL_TXT_108 ), cattributes=>pfx.qbground );
   htp.tableData( htf.bold( LNG5.SCL_TXT_109 ), cattributes=>pfx.qbground );
   htp.tableData( htf.bold( LNG5.SCL_TXT_110 ), cattributes=>pfx.qbground );
   htp.tableData( htf.bold( LNG5.SCL_TXT_111 ), cattributes=>pfx.qbground );
   htp.tableData( htf.bold( LNG5.SCL_TXT_112 ), cattributes=>pfx.qbground );
   htp.tableRowClose;

   for c0rec in c0(
         rDefaults.STD_PROFILE_PID,
         rDefaults.STD_PROFILE_AID,
         TO_NUMBER( p_id ),
         p_name,
         p_street,
         p_suburb,
         p_country,
         p_pcode,
         p_state,
         p_email,
         search_range
         ) loop
      htp.tableRowOpen;
      -- htp.tableData( htf.anchor2( 'glbx.accept_login?UN=' || c0rec.username || '&PW=' || c0rec.password, 'Connect', 'login_as_profile', '_blank' ), cattributes=>pfx.qbground );
      htp.tableData( htf.anchor2( 'phg.customer_logon?surl=' || surl || '&acid=' || acid || '&profid=' || c0rec.profile_id || '&login_type=PROFILE', 'Connect', 'login_as_profile', '_blank' ), cattributes=>pfx.qbground );
      htp.tableData( c0rec.billing_name, cattributes=>pfx.qcbground );
      htp.tableData( c0rec.billing_street, cattributes=>pfx.qcbground );
      htp.tableData( c0rec.billing_suburb, cattributes=>pfx.qcbground );
      htp.tableData( c0rec.billing_country, cattributes=>pfx.qcbground );
      htp.tableData( c0rec.billing_postcode, cattributes=>pfx.qcbground );
      htp.tableData( c0rec.billing_state, cattributes=>pfx.qcbground );
      htp.tableData( htf.mailto( c0rec.billing_email, c0rec.billing_email ), cattributes=>pfx.qcbground );
      htp.tableData( c0rec.billing_phone, cattributes=>pfx.qcbground );
      htp.tableData( c0rec.billing_fax, cattributes=>pfx.qcbground );
      htp.tableData( c0rec.sendto_name, cattributes=>pfx.qcbground );
      htp.tableData( c0rec.contact_phone, cattributes=>pfx.qcbground );
      htp.tableData( htf.mailto( c0rec.contact_email, c0rec.contact_email ), cattributes=>pfx.qcbground );
      htp.tableRowClose;
   end loop;

   htp.tableClose;

   htp.nl;

   htp.formClose;

   htp.p( '</CENTER>' );

   glbx.close_page( pfx );

exception
   when VALUE_ERROR then
    --
      -- User typed in a non numeric value in the profile_id field
      --
      mng_booking_profiles( surl, acid, user_type );
   when others then
      glbx.error_details( 'SCL', 'MNG_BOOKING_PROFILES',errmsg=>sqlerrm );
end login_as;

end scl; -- end package

/
