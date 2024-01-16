CREATE OR REPLACE package body WEBSYS.bkn
as

/******************************************************************************
* File: bkn.sql
* See also bknh.sql
* Author: Martijn van den Boogaard
* Date: December 3 2002
******************************************************************************/

/******************************************************************************
* Package constants
******************************************************************************/
PACKAGE_NAME      constant varchar2( 3 )  := 'BKN';
MINUTES_1         constant number         := 1/( 24*60 ); -- Portion of the day in days, use number for floating point
TIME_IN_ED_CENTRE constant integer        := 15; -- Minutes
TIME_IN_GALERIES  constant integer        := 120; -- Minutes
TABLE_ATTS        constant varchar2( 200 ):= 'cellpadding="2" cellspacing="2" border="1"';
CRLF              constant varchar2( 10 ) := CHR( 13 ) || CHR( 10 );
TAB               constant varchar2( 10 ) := CHR( 9 );
SCHOOL_PAYS       constant char( 1 )      := 'E';
COMPANY_PAYS      constant char( 1 )      := 'T';
OTHER_PAYS        constant char( 1 )      := 'O';
NUM_OF_STEPS      constant integer        := 6;
EMAIL_TYPE_1      constant pls_integer    := 1;
EMAIL_TYPE_2      constant pls_integer    := 2;
EMAIL_TYPE_3      constant pls_integer    := 3;
EMAIL_TYPE_4      constant pls_integer    := 4;
EMAIL_TYPE_5      constant pls_integer    := 5;
EMAIL_TYPE_6      constant pls_integer    := 6;
EMAIL_TYPE_7      constant pls_integer    := 7;
EMAIL_TYPE_8      constant pls_integer    := 8;
EMAIL_TYPE_9      constant pls_integer    := 9;
EMAIL_TYPE_10     constant pls_integer    := 10;
EMAIL_TYPE_11     constant pls_integer    := 11;
EMAIL_TYPE_12     constant pls_integer    := 12;
BOOKING_STEPS_T1  constant varchar2( 50 ) := '1,2,3,4,6';
BOOKING_STEPS_T2  constant varchar2( 50 ) := '1,2,3,6';
BOOKING_STEPS_T3  constant varchar2( 50 ) := '1,2,3,4,5,6';
BOOKING_STEPS_T4  constant varchar2( 50 ) := '1,2,3,6';
BOOKING_TYPE_1    constant pls_integer    := 1; -- Created by school, facilitated
BOOKING_TYPE_2    constant pls_integer    := 2; -- Created by school, self guided
BOOKING_TYPE_3    constant pls_integer    := 3; -- Created by buscompany, facilitated
BOOKING_TYPE_4    constant pls_integer    := 4; -- Created by buscopmany, self guided
STANDARD_HEADER   constant varchar2( 200 ) := 'You are booking a <VISIT_TYPE> tour';

/******************************************************************************
* Package-level variables
******************************************************************************/
gBooking booking%ROWTYPE;
gCurrentBookingType pls_integer := null;
gTitle varchar2( 200 ) := null;

/******************************************************************************
* Global Exceptions
******************************************************************************/
INVALID_CREDITOR            Exception;
BOOKING_NOT_FOUND_EXCEPTION Exception;

/******************************************************************************
* Specification
******************************************************************************/

/**
* Retrieve the booking record with booking_id bid.
* @param bid Booing ID
* @return The booking record identified by booking id bid.
*/
function getBookingRecord( bid integer ) return booking%ROWTYPE;
function getmanid return integer;
function piction_cookie( lrec out login_session%ROWTYPE ) return varchar2;
function check_too_large( c1rec in booking%ROWTYPE, dt in date ) return boolean;

/**
* Return the title of the screen that will be displayed on top of the screen.
* The title should show if it is a paid program or self guided tour. The booking
* record has the information of the type of booking that is being made.
* @param bid Booing ID
* @return The title
*/
function getTitle( bid integer ) return varchar2;

/**
* Get the type of booking for the current booking. There are four types possible:
* - School booking paid program
* - School booking self guided
* - Company booking paid program
* - Company booking self guided
* @param bid Booing ID
* @return The type of the booking
*/
function getBookingType( bid integer ) return pls_integer;
function getDefaults_prof( cProfileId integer ) return school_booking_prefs%ROWTYPE;

/**
* This function returns the class of visit which can either be PAID PROGRAM
* or SELF GUIDED.
* @param The ID of the visit type
* @return The class of the visit type
*/
function getVisitTypeClass( pVisitTypeId integer ) return varchar2;

/**
* Check if the booking that is currently made is still active. After the user
* has confirmed the details the booking is not longer active. If the booking
* is active then the booking record will be returned in pBookingRecord. It also
* assigns the booking record to the global variable gBooking.
* @param pSessionId Session ID of the current logged in user
* @param pBookingRecord Record of booking table
* @return TRUE if the booking is being worked with otherwise FALSE
*/
function bookingActive( pSessionId integer, pBookingRecord out booking%ROWTYPE )
   return boolean;

/**
* Check if the booking is active.
* @param pSessionId Session ID of the current logged in user
* @return TRUE if the booking is being worked with otherwise FALSE
*/
function bookingActive( pSessionId integer ) return boolean;

/**
* Specification for the createPucrchaseOrder function.
* @param surl Secure URL
* @param acid Account ID
* @param bid Booking ID
* @return 0 if not successfull otheriwse 1
*/
function createPurchaseOrder( surl varchar2, acid integer, bid integer )
   return pls_integer;

/**
* Create shopping basket records based on the programs that are being booked.
* Returns the number of items in the shopping basket. If no program has been
* chosen it returns 0
* @param surl Secure URL
* @param bid Booking ID
* @return The number of shopping basket items
*/
function createShoppingBasketItems( surl varchar, bid integer ) return integer;

/**
* Add the reservation to the tables
* @param surl Secure URL
* @param acid Account ID
* @param bid Booking ID
* @return TRUE if succesfull otherwise FALSE
*/
function create_reservation( surl varchar2, acid integer default null,
                             bid integer ) return boolean;

/**
* Calculate the total cost for the visit based on the number of students and the type
* of visit.
* @param surl Secure URL
* @param acid Account ID
* @param bid Booking ID
* @return The total cost ex GST
*/
function total_cost( surl varchar2, acid integer default null, bid integer default null )
   return number;

/**
* Display a screen with the school details
* @param c0rec Customer Contact record
* @param pfx Theme record
*/
procedure showSchoolDetails( c0rec customer_contact%ROWTYPE, pfx theme%ROWTYPE );

/**
* Display a screen with the company details
* @param c0rec Customer Contact record
* @param pfx Theme record
*/
procedure showCompanyDetails( c0rec customer_contact%ROWTYPE, pfx theme%ROWTYPE );

/**
* Returns an HTML form select with the year levels. The difficulty lies in the
* Year level K which is substituted by 0 (zero).
* @param pName Name of the select form object
* @param pSelectedValue The value that should be selected. (K, 1, 2... 12)
* @return The HTML code for the list. Use htp.p( getYearLevel() )
*/
function getYearLevel( pName varchar2, pSelectedValue varchar2 ) return varchar2;

/**
* Display the images on the top or just a header
* @param pStep The step where we currently are. This enables to display a
*        different image
* @param pBookingId Booking ID
*/
procedure showProgress( pStep integer, pBookingId integer, surl in varchar2 default null, acid in integer default null );

/**
* Specification for the emailing
* @param surl Secure URL
* @param acid Account ID
* @param pBookingId Booking ID
* @param pEmailType Type of email to send. See constants on top of this file.
* @param pIsSendto The email address of the to field.
* @return TRUE if success otherwise FALSE.
*/
function send_Email( surl varchar2, acid integer default null, pBookingid integer, new_status varchar2, pIsSendto out varchar2 ) return boolean;

/**
* Get a record with the default values of the booking system
*/
function getDefaults( pPhotographerId integer, acid integer )
   return school_booking_prefs%ROWTYPE;

function anchor_receipt( surl in varchar2, brec in booking%ROWTYPE, acid in integer )
 return varchar2
as

 cursor c1( vpoid integer ) is select * from purchase_order where poid = vpoid;
 cursor c2( void integer ) is select * from order_style where oid = void;

 c1rec	c1%ROWTYPE;
 c2rec  c2%ROWTYPE;
 anch	varchar2(4000);
 pfx	THEME%ROWTYPE;

begin

 if brec.purchase_order_id is null then return( '&nbsp;' ); end if;

 open c1(brec.purchase_order_id);
 fetch c1 into c1rec;
 close c1;
 open c2(c1rec.oid);
 fetch c2 into c2rec;
 close c2;
 pfx := dapi.getLFRecord;

 if pfx.order_show_receipt is null
  then
   anch := 'bkn.show_receipt?surl=' || surl || '&vpoid=' || brec.purchase_order_id || '&acid=' || acid;
  else
   anch := pfx.order_show_receipt || '?surl=' || surl || '&theme_data=' || null || '&ltype=' || 'MANUFACTURER' || '&acid=' || acid || '&void=' || c1rec.pid || '&purchid=' || brec.purchase_order_id;
 end if;

 return( htf.anchor2( anch, brec.purchase_order_id, ctarget=>'POID' || brec.purchase_order_id ) );
exception
 when others then return( brec.purchase_order_id || '-' || sqlerrm );
end anchor_receipt;

procedure show_receipt( surl in varchar2, vpoid integer, acid integer )
as

 cursor c1( vpoid integer ) is select * from purchase_order where poid = vpoid;
 cursor c2( void integer ) is select * from order_style where oid = void;

 c1rec		c1%ROWTYPE;
 c2rec  	c2%ROWTYPE;
 lProgramCount  integer;
 def		school_booking_prefs%ROWTYPE;

begin
  if not dapi.init( surl, 'BKN.SHOW_RECEIPT', acid, iscust=>FALSE ) then
     dapi.initFailed( surl,extra_parameter=>'BOOKING' );
     return;
  end if;
  def := getDefaults( acid );

 open c1(vpoid);
 fetch c1 into c1rec;
 close c1;
 open c2(c1rec.oid);
 fetch c2 into c2rec;
 close c2;

 fname.customer_receipt(surl, dapi.getSessionId, dapi.getScreenType, dapi.getLoginType, null, dapi.getProfileId, dapi.getCustomerAccountRecord, dapi.getLFRecord, dapi.getBFRecord, c1rec, c2rec, null );
exception when others then
         glbx.error_details( PACKAGE_NAME, 'SHOW_RECEIPT',errmsg=>sqlerrm );
end show_receipt;

/**
* Login as profile and return the new Secure URL
* @param surl Secure URL
* @param profileId Profile ID that wants to login
* @return New secure URL if successfull otherwise NULL
*/
function loginAsProfile( surl varchar2, profileId integer )
   return varchar2
as
   cursor c1( cProfileId integer ) is
      select 'x'
      from customer_profile
      where profile_id = cProfileId;
   cursor c2( cLoginType varchar2, cProfileId integer ) is
      select *
      from customer_contact
      where login_type = cLoginType and aid = cProfileId;

   c1rec		c1%ROWTYPE;
   c2rec		c2%ROWTYPE;
   c4rec		manufacturer%ROWTYPE;
   newsurl	varchar2(100) := NULL;
   ltype		varchar2(100);
   stype		integer;
   owner_id	integer;
   sts		varchar2(100);
   lSessionId	integer;
begin
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'BKN.LOGIN_CONNECTAS', iscust=>FALSE );
   if sts is not null then
      glbx.redisplay_login_page( sts, TRUE );
      return newsurl;
   end if;
   open c1( profileId );
   fetch c1 into c1rec;
   if c1%NOTFOUND then
      close c1;
      htp.bold( LNG.PHG_TXT_175 || profileId );
      return newsurl;
   end if;
   close c1;
   lSessionId := glbx.get_random_sessionid;
   newsurl := rpad( to_char( lSessionId ), 12, 'Z' ) || glbx.randstring;
   open c2( 'PROFILE', profileId );
   fetch c2 into c2rec;
   close c2;
   insert into login_session
      ( screen_type, login_type, sessid, aid, date_created, date_updated,
        call_ctr, browser, ip_address, securl, guest_email, country,
        previous_sessid, calling_sessid )
   values
      ( stype, 'PROFILE', lSessionId, profileId, sysdate, sysdate, 1,
        substr(owa_util.get_cgi_env( 'HTTP_USER_AGENT'),1,100),
        owa_util.get_cgi_env( 'REMOTE_ADDR'), newsurl, c2rec.contact_email,
        c2rec.sendto_country, null, to_number(replace(substr(surl,1,12),'Z','')) );
   commit;
   return newsurl;
end loginAsProfile;

/******************************************************************************
* Implementation
******************************************************************************/

function getBookingRecord( bid integer ) return booking%ROWTYPE
as
   cursor c1 is
      select * from booking where booking_id = bid;
begin
   if NVL( gBooking.booking_id, 0 ) != bid then
      open c1;
      fetch c1 into gBooking;
      close c1;
   end if;
   return gBooking;
end getBookingRecord;

function getTitle( bid integer ) return varchar2
as
   lBookingType pls_integer;
begin
   if gTitle is null then
      lBookingType := getBookingType( bid );
      if ( lBookingType = BOOKING_TYPE_1 ) OR ( lBookingtype = BOOKING_TYPE_3 ) then
         gTitle := 'Book a facilitated tour';
      elsif ( lBookingType = BOOKING_TYPE_2 ) OR ( lBookingType = BOOKING_TYPE_4 ) then
         gTitle := 'Book a self guided tour';
      else
         return null;
      end if;
   end if;
   return gTitle;
end getTitle;

function getBookingType( bid integer ) return pls_integer
as
   c1rec booking%ROWTYPE;
   lVisitTypeClass varchar2( 200 );
   lVisitType integer;
begin
   if gCurrentBookingType is null then
      c1rec := getBookingRecord( bid );
      lVisitType := TO_NUMBER( c1rec.visit_type );
      lVisitTypeClass := getVisitTypeClass( lVisitType );
      if c1rec.made_by = c1rec.school_id then
         if lVisitTypeClass = LNG5.BKN_TXT_002 then
            gCurrentBookingType := BOOKING_TYPE_1;
         elsif lVisitTypeClass = LNG5.BKN_TXT_003 then
            gCurrentBookingType := BOOKING_TYPE_2;
         end if;
      elsif c1rec.made_by = c1rec.bus_company_id then
         if lVisitTypeClass = LNG5.BKN_TXT_002 then
            gCurrentBookingType := BOOKING_TYPE_3;
         elsif lVisitTypeClass = LNG5.BKN_TXT_003 then
            gCurrentBookingType := BOOKING_TYPE_4;
         end if;
      end if;
   end if;
   return gCurrentBookingType;
end getBookingType;

function getVisitTypeClass( pVisitTypeId integer ) return varchar2
as
   cursor c1( cvisitTypeId integer ) is
      select class from visit_types where visit_type_id = cvisitTypeId;
   lClass visit_types.class%TYPE;
begin
   open c1( pVisitTypeId );
   fetch c1 into lClass;
   close c1;
   return lClass;
end getVisitTypeClass;

function bookingActive( pSessionId integer, pBookingRecord out booking%ROWTYPE )
   return boolean
as
   -- Fetch booking for current session with status PRE_BOOKING
   cursor c1( csessionid integer ) is
      select *
      from booking b
      where b.session_id = csessionid and
            b.status = LNG5.BKN_TXT_004;
   lResult boolean := FALSE;
begin
   open c1( pSessionId );
   fetch c1 into gBooking;
   lResult := c1%FOUND;
   close c1;
   pBookingRecord := gBooking;
   return lResult;
end bookingActive;

function bookingActive( pSessionId integer ) return boolean
as
   rBooking booking%ROWTYPE;
begin
   return bookingActive( pSessionId, rBooking );
end bookingActive;

function createShoppingBasketItems( surl varchar, bid integer ) return integer
is
   cursor c1 is
      select program_id from booked_programs where booking_id = bid;
   cursor c2 is
      select workbook_id from booked_workbooks where booking_id = bid;
   cursor c3 is
      select num_of_students, actual_num_of_students, purchase_order_id
      from booking
      where booking_id = bid;
   cursor c4( cUmoId integer ) is
      select um.program_obj.cost_per_head cost_per_head
      from umo um
      where umo_id = cUmoId;

   c3rec 		c3%ROWTYPE;
   c4rec 		c4%ROWTYPE;
   lNewShoppingId 	integer;
   ctr 			integer := 0;
   lAccountId 		integer;
   pdef			school_booking_prefs%ROWTYPE;
   manid		integer;

begin
   if not dapi.init( surl, 'BKN.CREATESHOPPINGBASKETITEMS', iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return 0;
   end if;
   open c3;
   fetch c3 into c3rec;
   close c3;
   lAccountId := dapi.getAccountId;

   -- First delete existing shopping basket items
   delete from shopping_basket where poid = c3rec.purchase_order_id;
   -- Then loop through the booked programs
   manid := getmanid;
   pdef := getDefaults_prof( dapi.GLOBAL_PROFILE_ID );
   for c1rec in c1 loop
     ctr := ctr + 1;
     -- Fetch the program details
     open c4( c1rec.program_id );
     fetch c4 into c4rec;
     close c4;
     select s_shopping_basket.nextval into lNewShoppingId from dual;
     insert into shopping_basket
        ( poid, shopping_id, qty, isgallery, photo_cost, lab_id, xref_mfctr_code )
     values
        ( c3rec.purchase_order_id, lNewShoppingId, nvl( c3rec.actual_num_of_students, c3rec.num_of_students ), 'B', c4rec.cost_per_head, manid, pdef.default_xref_mfctr_code );
   end loop;
   -- And loop through the booked workbooks
   for c2rec in c2 loop
      ctr := ctr + 1;
      -- Fetch workbook details
      open c4( c2rec.workbook_id );
      fetch c4 into c4rec;
      close c4;
      select s_shopping_basket.nextval into lNewShoppingId from dual;
      insert into shopping_basket( poid, shopping_id, qty, isgallery, photo_cost, lab_id, xref_mfctr_code )
       values
       ( c3rec.purchase_order_id, lNewShoppingId, nvl( c3rec.actual_num_of_students, c3rec.num_of_students ), 'B', c4rec.cost_per_head, manid, pdef.default_xref_mfctr_code );
   end loop;
   return ctr;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'CREATESHOPPINGBASKETITEMS', errmsg=>sqlerrm );
end createShoppingBasketItems;

function create_reservation( surl varchar2, acid integer default null,
                             bid integer ) return boolean
as
   cursor c0( cBookingId integer ) is
      select * from booking where booking_id = cBookingId;
   cursor c1( crid integer ) is
      select * from resources where resource_id = crid;
   cursor c2( cbid integer, crid integer ) is
      select * from resource_use
      where booking_id = cbid and resource_id = crid;
   cursor c3( cProfileId integer ) is
      select education_id, galleries_id
      from school_booking_prefs
      where std_profile_aid = ( select aid from customer_profile
                                where profile_id = cProfileId )
            and
            std_profile_pid = ( select pid from customer_profile
                                where profile_id = cProfileId );

   c0rec c0%ROWTYPE;                             -- Stores the result of cursor c0
   c1rec c1%ROWTYPE;                             -- Stores the result of cursor c1
   c2rec c2%ROWTYPE;                             -- Stores the result of cursor c2
   c3rec c3%ROWTYPE;                             -- Stores the result of cursor c3
   lTimeSpan integer;                            -- Number of time spans
   lNumOfVis integer;                            -- Number of Visitors
   lSpanGalleries integer;                       -- Span in galleries
   lAccountId integer;                           -- Account ID of customer account
   lSessionId integer;                           -- Session ID
   lFound boolean;                               -- Record found?
begin
   if not dapi.init( surl, 'BKN.CREATE_RESERVATION', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return FALSE;
   end if;
   lAccountId := dapi.getAccountId;
   lSessionId := dapi.getSessionId;
   -- Fetch booking record
   open c0( bid );
   fetch c0 into c0rec;
   lFound := c0%FOUND;
   close c0;
   if NOT lFound then
      -- If booking cannot be found then raise an exception
      raise BOOKING_NOT_FOUND_EXCEPTION;
   end if;
   open c3( c0rec.made_by );
   fetch c3 into c3rec;
   close c3;
   -- Get the maximum number of students allowed in the education space
   open c1( c3rec.education_id );
   fetch c1 into c1rec;
   close c1;
   -- Calculate time span
   lTimeSpan := 1; -- At least 1 group goes through the education centre
   lNumOfVis := c0rec.num_of_students;
   while lNumOfVis > c1rec.max_group_size loop
      lTimeSpan := lTimeSpan + 1;
      lNumOfVis := lNumOfVis - c1rec.max_group_size;
   end loop;
   -- Schedule the education centre
   insert into resource_use
      ( resource_id, booking_id, date_time_from, date_time_to, calendar_id )
   values
      ( c3rec.education_id, c0rec.booking_id, c0rec.date_time,
        c0rec.date_time + ( lTimeSpan * TIME_IN_ED_CENTRE * MINUTES_1 ),
        c0rec.calendar_id );
   -- If it is a facilitated tour than we also need to schedule the AWM galeries
   if getVisitTypeClass( c0rec.visit_type ) = LNG5.BKN_TXT_002 then
      -- Fetch the information of the galleries
      open c1( c3rec.galleries_id );
      fetch c1 into c1rec;
      close c1;
   	  lSpanGalleries := 1;
      lNumOfVis := c0rec.num_of_students;
      /*
   	  while nNumOfVis > c1rec.max_group_size loop
         nSpanGalleries := nSpanGalleries + 1;
         nNumOfVis := nNumOfVis - c1rec.max_group_size;
      end loop;
      */
      -- Find the time that the group will come out of the education space
      open c2( c0rec.booking_id, c3rec.education_id );
      fetch c2 into c2rec;
      close c2;
      -- Schedule the galleries
      insert into resource_use
         ( resource_id, booking_id, date_time_from, date_time_to, calendar_id )
      values
         ( c3rec.galleries_id, c0rec.booking_id, c2rec.date_time_to,
           c2rec.date_time_to + ( ( lSpanGalleries * TIME_IN_GALERIES ) * MINUTES_1 ),
           c0rec.calendar_id );
   end if;
   commit;
   return TRUE;
exception
   when BOOKING_NOT_FOUND_EXCEPTION then
      htp.init;
      htp.htmlOpen;
      htp.p( 'This booking is no longer active!' );
      htp.htmlClose;
      return FALSE;
   when others then
      glbx.error_details( PACKAGE_NAME, 'CREATE_RESERVATION', errmsg=>sqlerrm );
      return FALSE;
end create_reservation;

function total_cost( surl varchar2, acid integer default null, bid integer default null )
   return number
as

   cursor c0( cbid integer ) is
      select num_of_students from booking where booking_id = cbid;

   cursor c2( cbid integer ) is
      select um.program_obj.cost_per_head cost, greatest(nvl(bp.num_of_visitors,0),nvl(um.extras.orderby_nmb,0)) min_nmb
      from booked_programs bp, umo um
      where bp.program_id = um.umo_id and bp.booking_id = cbid;

   cursor c3( cbid integer ) is
      select um.program_obj.cost_per_head cost, nvl(um.extras.orderby_nmb,0) min_nmb
      from booked_workbooks bw, umo um
      where bw.workbook_id = um.umo_id and
            bw.booking_id = cbid;

   c0rec 		c0%ROWTYPE;
   c2rec 		c2%ROWTYPE;
   c3rec 		c3%ROWTYPE;
   lCostOfPrograms 	number;                      -- Cost of programs
   lCostOfWorkbooks 	number;                      -- Cost of workbooks
   lNumOfVisitors 	integer;                     -- Number of visitors
   lResult 		number := 0.0;               -- Temporary result number

begin
   if not dapi.init( surl, 'BKN.TOTAL_COST', acid, FALSE, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return 0.0;
   end if;
   -- Fetch number of students that are visiting for booking bid
   /*
   open c0( bid );
   fetch c0 into c0rec;
   if c0%NOTFOUND then
      raise BOOKING_NOT_FOUND_EXCEPTION;
   end if;
   close c0;
   */
   lNumOfVisitors := nvl( c0rec.num_of_students, 0 );
   lResult := 0;

   -- Fetch the maximum cost per head of a program
   for c2rec in c2( bid ) loop
    lCostOfPrograms := NVL( c2rec.cost, 0 );
    lResult := lResult + (c2rec.min_nmb * lCostOfPrograms );
   end loop;

   -- Fetch the maximum cost per head of a workbook
   for c3rec in c3( bid ) loop
    lCostOfWorkbooks := NVL( c3rec.cost, 0 );
    -- Calculate the total cost
    lResult := lResult + (c3rec.min_nmb * lCostOfWorkbooks );
   end loop;

   return( lResult );

exception when others then
   return 0;
end total_cost;

procedure showSchoolDetails( c0rec customer_contact%ROWTYPE, pfx theme%ROWTYPE )
as
   cursor c2( csid integer ) is
      select state_name from states where state_id = csid;
   c2rec c2%ROWTYPE;
begin
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
   htp.tableData( htf.bold( LNG5.SCL_TXT_102 ), cattributes=>pfx.qbground );
   htp.tableData( c0rec.billing_city, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.SCL_TXT_103 ), cattributes=>pfx.qbground );
   htp.tableData( c0rec.billing_postcode, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   open c2( c0rec.billing_state );
   fetch c2 into c2rec;
   close c2;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.SCL_TXT_105 ), cattributes=>pfx.qbground );
   htp.tableData( c2rec.state_name, cattributes=>pfx.qcbground );
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
end showSchoolDetails;

procedure showCompanyDetails( c0rec customer_contact%ROWTYPE, pfx theme%ROWTYPE )
as
   cursor c2( csid integer ) is
      select state_name from states where state_id = csid;
   c2rec c2%ROWTYPE;
begin
   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_125 ), cattributes=>pfx.qbground );
   htp.tableData( c0rec.billing_name, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_126 ), cattributes=>pfx.qbground );
   htp.tableData( c0rec.billing_street, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_127 ), cattributes=>pfx.qbground );
   htp.tableData( c0rec.billing_suburb, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_128 ), cattributes=>pfx.qbground );
   htp.tableData( c0rec.billing_city, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_129 ), cattributes=>pfx.qbground );
   htp.tableData( c0rec.billing_postcode, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   open c2( c0rec.billing_state );
   fetch c2 into c2rec;
   close c2;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_130 ), cattributes=>pfx.qbground );
   htp.tableData( c2rec.state_name, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_131 ), cattributes=>pfx.qbground );
   htp.tableData( c0rec.sendto_name, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_132 ), cattributes=>pfx.qbground );
   htp.tableData( c0rec.contact_email, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_133 ), cattributes=>pfx.qbground );
   htp.tableData( c0rec.contact_mobile, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_134 ), cattributes=>pfx.qbground );
   htp.tableData( c0rec.contact_phone, cattributes=>pfx.qcbground );
   htp.tableRowClose;
end showCompanyDetails;

function getYearLevel( pName varchar2, pSelectedValue varchar2 ) return varchar2
as
   result varchar2( 2000 );
begin
   result := htf.formSelectOpen( pName );
   result := result || htf.formSelectOption( 'Choose a year level...', cattributes=>' value="?"' );
   -- Year level K is a special case
   if 'K' = pSelectedValue then
      result := result || htf.formSelectOption( 'K', cattributes=>'selected value="' || 'K' || '"' );
   else
      result := result || htf.formSelectOption( 'K', cattributes=>'value="' || 'K' || '"' );
   end if;
   -- loop through all the year levels
   for i in 1..12 loop
      if TO_CHAR( i ) = pSelectedValue then
         result := result || htf.formSelectOption( i, cattributes=>'selected value="' || i || '"' );
      else
         result := result || htf.formSelectOption( i, cattributes=>'value="' || i || '"' );
      end if;
   end loop;
   if 'O' = pSelectedValue then
      result := result || htf.formSelectOption( 'Other', cattributes=>'selected value="' || 'O' || '"' );
   else
      result := result || htf.formSelectOption( 'Other', cattributes=>'value="' || 'O' || '"' );
   end if;
   result := result || htf.formSelectClose;
   return result;
end getYearLevel;

/**
* Draw the progress bar
*/
procedure showProgress( pStep integer, pBookingId integer, surl in varchar2 default null, acid in integer default null )
as
   lProgressSet varchar2( 50 );
   lBookingType integer;
   lTitleType varchar2( 200 );
begin
   if pBookingId is null then
      htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0 width="100%"' );
       htp.tablerowopen;
        htp.tabledata( htf.header( 1, 'Make a Booking' ), cattributes=>'align="LEFT"' );
        htp.tabledata( '<A HREF="javascript: window.open(''bkn.prebook?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || ''',''catwin'',''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=800,height=500'');void('''');">View your bookings</A>', cattributes=>'align="LEFT"' );
       htp.tablerowclose;
      htp.tableclose;
      return;
   end if;
   lBookingType := getBookingType( pBookingId );
   if lBookingType = BOOKING_TYPE_1 then
      lProgressSet := BOOKING_STEPS_T1;
      lTitleType := 'Facilitated Program';
   elsif lBookingType = BOOKING_TYPE_2 then
      lProgressSet := BOOKING_STEPS_T2;
      lTitleType := 'Self guided';
   elsif lBookingType = BOOKING_TYPE_3 then
      lProgressSet := BOOKING_STEPS_T3;
      lTitleType := 'Facilitated Program';
   elsif lBookingType = BOOKING_TYPE_4 then
      lProgressSet := BOOKING_STEPS_T4;
      lTitleType := 'Self guided';
   end if;
   if FALSE then
      -- Step table
      htp.p( '<center>' );
      htp.tableOpen( cattributes=>'cellpadding=0 cellspacing=0 border=0' );
      htp.tableRowOpen;
      for i in 1..NUM_OF_STEPS loop
         -- We have to skip steps depending on the type of visit
         -- 1. if school is making the booking and it is facilitated
         -- 2. if school is making the booking and self guided
         -- 3. if bus company is making the booking facilitated
         -- 4. if bus company is making the booking self guided
         if INSTR( lProgressSet, TO_CHAR( i ) ) > 0 then
            if i = pStep then
               htp.tableData( htf.img( decs.image_location || 'booking/step' || i ||
                              'x.gif', calt=>'*Step' || i ) );
            else
               htp.tableData( htf.img( decs.image_location || 'booking/step' || i ||
                              '.gif', calt=>'Step' || i ) );
            end if;
         end if;
      end loop;
      htp.tableRowClose;
      htp.tableClose;
      htp.p( '</center>' );
   else
      htp.header( 1, 'Make a Booking - ' || lTitleType );
   end if;
end showProgress;


/******************************************************************************
* Public functions
******************************************************************************/

/**
* Get a record with the default values of the booking system
*/
function getDefaults( acid integer ) return school_booking_prefs%ROWTYPE
as
   cursor c1( cacid integer ) is
      select * from school_booking_prefs
      where std_profile_aid = cacid and
            std_profile_pid = ( select pid
                                from customer_account
                                where aid = cacid );
   rDefaults school_booking_prefs%ROWTYPE;
begin
   open c1( acid );
   fetch c1 into rDefaults;
   close c1;
   return rDefaults;
exception
   when others then
      glbx.error_details( PACKAGE_NAME, 'GETDEFAULTS', errmsg=>sqlerrm );
end getDefaults;

function getDefaults_prof( cProfileId integer ) return school_booking_prefs%ROWTYPE
as
   cursor c1( cacid integer ) is
      select *
      from school_booking_prefs
      where std_profile_aid = ( select aid
                                from customer_profile
                                where profile_id = cProfileId )
            and
            std_profile_pid = ( select pid
                                from customer_profile
                                where profile_id = cProfileId );
   rDefaults school_booking_prefs%ROWTYPE;
begin
   open c1( cProfileId );
   fetch c1 into rDefaults;
   close c1;
   return rDefaults;
exception
   when others then
      glbx.error_details( PACKAGE_NAME, 'GETDEFAULTS_PROF', errmsg=>sqlerrm );
end getDefaults_prof;

procedure enterBookingApi( surl varchar2, acid integer default null )
as
   PARAMETER_NOT_FOUND EXCEPTION;
   lAcid integer;
   x integer;
begin
   /*
   x := INSTR( screen_parms, 'acid' );
   if x = 0 then
      raise PARAMETER_NOT_FOUND;
   end if;
   lAcid := SUBSTR( screen_parms, x + 4 );
   */
   execute immediate
      'begin bkn.enterBookingPage( :surl, :acid ); end;'
   using
      surl, acid;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'ENTERBOOKINGAPI', errmsg=>sqlerrm );
end enterBookingApi;

/**
* First procedure to call when entering the booking system
*/
procedure enterBookingPage( surl varchar2, acid integer default null,
                            left_api_parm varchar2 default null )
as
begin
   if not dapi.init( surl, 'BKN.ENTERBOOKINGPAGE', acid, iscust=>FALSE ) then
     	dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   typeOfVisit( surl, acid, left_api_parm );
exception when others then
   glbx.error_details( PACKAGE_NAME, 'ENTERBOOKINGPAGE', errmsg=>sqlerrm );
end enterBookingPage;

/**
* User has to select the type of visit
*/
procedure typeOfVisit( surl varchar2, acid integer default null,
                       left_api_parm varchar2 default null )
as
begin
   if not dapi.init( surl, 'BKN.TYPEOFVISIT', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   acceptTypeOfVisit( surl, acid, null, left_api_parm );
exception when others then
   glbx.error_details( PACKAGE_NAME, 'TYPEOFVISIT', errmsg=>sqlerrm );
end typeOfVisit;

/**
* The user has selected a type of visit
*/
procedure acceptTypeOfVisit( surl varchar2, acid integer default null,
                             p_visit_type varchar2 default null,
                             left_api_parm varchar2 default null )
as

   cursor c0( csid integer ) is
      select b.booking_id bid, b.num_of_students nos, b.date_time dat
      from booking b
      where b.session_id = csid and b.status = LNG5.BKN_TXT_004;
   cursor c1( ccid integer ) is
      select TO_CHAR( start_time, 'HH24:MI' ) start_time
      from calendar
      where calendar_id = ccid;
   cursor c2( caid integer ) is
      select cp.pid pid, cm.calendar_id calendar_id
      from customer_profile cp, calendar_map cm
      where cp.profile_id = caid and cm.aid = cp.aid;

   c0rec c0%ROWTYPE;
   c2rec c2%ROWTYPE;
   lNewBookingId integer := 0;
   lSessionId integer;
   lAccountId integer;
   lActive boolean := FALSE;
   lStartTime varchar2( 5 );
   lUserType char( 1 );

begin
   if not dapi.init( surl, 'BKN.ACCEPTTYPEOFVISIT', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   lSessionId := dapi.getSessionId;
   lAccountId := dapi.getAccountId;
   lUserType  := dapi.getUserType;
   -- Fetch a booking if found.
   open c0( lSessionId );
   fetch c0 into c0rec;
   lActive := c0%FOUND;
   close c0;
   -- Fetch information about the calendar and profile
   open c2( lAccountId );
   fetch c2 into c2rec;
   close c2;
   if lActive then
      -- The user is still working on a booking
      update booking b
         set b.date_modified = SYSDATE,
             b.visit_type = p_visit_type,
             b.last_step = '1'
         where booking_id = c0rec.bid;
      -- delete all the references to booked programs
      delete from booked_programs where booking_id = c0rec.bid;
   else
      -- There is no record found for this session with a Pre Booking status
      -- A new booking record will be made
      open c1( c2rec.calendar_id );
      fetch c1 into lStartTime;
      close c1;
      select s_booking.nextval into lNewBookingId from dual;
      /* Removed for now, just to address prebookings grabbing the calendar
      insert into booking
         ( booking_id, session_id, date_time, last_step,
           visit_type, date_created, date_modified, status,
           made_by, made_by_login_type, purchase_order_id,
           calendar_id )
      values
         ( lNewBookingId, lSessionId,
           TO_DATE( TO_CHAR( SYSDATE, lng.MASK ) || ' ' || lStartTime, LNG.TSMASK ),
           '1', p_visit_type, SYSDATE, SYSDATE, LNG5.BKN_TXT_004, lAccountId,
           dapi.getLoginType, null, c2rec.calendar_id );
      */
      insert into booking
         ( booking_id, session_id, date_time, last_step,
           visit_type, date_created, date_modified, status,
           made_by, made_by_login_type, purchase_order_id,
           calendar_id )
      values
         ( lNewBookingId, lSessionId,
           null,
           '1', p_visit_type, SYSDATE, SYSDATE, LNG5.BKN_TXT_004, lAccountId,
           dapi.getLoginType, null, c2rec.calendar_id );
   end if;
   commit;
   if lUserType = 'E' then
      -- School is making the booking
      update booking
         set school_id = lAccountId,
             school_login_type = dapi.getLoginType,
             calendar_id = c2rec.calendar_id,
             paid_by = decode(visit_type,'2',null,'E')
         where session_id = lSessionId and status = LNG5.BKN_TXT_004;
   elsif lUserType = 'T' then
      -- Tour operator is making the booking
      update booking
         set bus_company_id = lAccountId,
             bus_company_login_type = dapi.getLoginType,
             calendar_id = c2rec.calendar_id
         where session_id = lSessionid and status = LNG5.BKN_TXT_004;
   end if;
   commit;
   open c0( lSessionId );
   fetch c0 into c0rec;
   close c0;
   -- Goto the next screen
   details( sUrl, acid, TO_CHAR( c0rec.dat, 'HH24' ), TO_CHAR( c0rec.dat, 'MI' ),
            c0rec.nos, TO_CHAR( c0rec.dat, LNG.MASK ), TO_CHAR( c0rec.dat, LNG.MASK ) );
exception when others then
   glbx.error_details( PACKAGE_NAME, 'ACCEPTTYPEOFVISIT', errmsg=>sqlerrm );
end acceptTypeOfVisit;

/**
* Screen name: BKN001
*/
procedure details( surl varchar2, acid integer default null, hour varchar2 default null,
                   minutes varchar2 default null, nov varchar2 default null,
                   date_to_start varchar2 default null, chosen_date varchar2 default null,
                   org_tour varchar2 default null, err_text varchar2 default null )
as
   CALENDAR_NOT_DEFINED Exception;
   -- Fetch calendar settings
   cursor c0(lSessionId integer ) is select booking_id from booking where session_id = lSessionId and status = 'Pre Booking';
   cursor c2( caid integer ) is
      select start_time,
             end_time,
             time_block,
             date_format
      from calendar c,
           calendar_map cm
      where c.calendar_id = cm.calendar_id and
            cm.aid = ( select aid
                       from customer_profile
                       where profile_id = caid );
   cursor c3( cProfileId integer ) is
      select visit_type_id, visit_type_name, description
      from visit_types
      where pid = ( select pid
                    from customer_profile
                    where profile_id = cProfileId );
   -- The information of the logged in guest. caid holds the profile_id
   cursor c4( caid integer ) is
      select user_type from customer_contact where aid = caid;

   c0rec 	c0%ROWTYPE;
   c1rec 	booking%ROWTYPE;
   c2rec 	c2%ROWTYPE;
   c3rec 	c3%ROWTYPE;
   c4rec 	c4%ROWTYPE;
   pfx          theme%ROWTYPE;
   dDateToStart date;
   dThisMonth   date;
   lDayToStart  integer;
   lMinutes     integer;
   lSessionId   integer;
   lAccountId   integer;
   lRowStyle1   varchar2( 1000 );
   lRowStyle2   varchar2( 1000 );
   lHour        integer;
   lMonth 	varchar2( 200 );
   email_sendto varchar2( 100 );

begin
   if not dapi.init( surl, 'BKN.DETAILS', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   lSessionId := dapi.getSessionid;
   lAccountId := dapi.getAccountId; -- Profile Id
   -- Retrieve booking
   if not bookingActive( lSessionId, c1rec ) then
      bookingNotActive( surl, acid );
      return;
   end if;
   dapi.setExternalStyleSheet( BKN_STYLESHEET );
   -- dapi.setTitle( getTitle( c1rec.booking_id ) );
   dapi.pageOpen;
   htp.comment( 'Screen name: BKN001' );
   htp.p( '<script type="text/javascript" src="' || BKN_TOPSCRIPT || '"></script>' );
   htp.p( '<div class="bodytext">' );
   showProgress( 1, null, surl, acid );
   -- Check if there is a calendar attached to this account
   open c2( lAccountId );
   fetch c2 into c2rec;
   if c2%NOTFOUND then
      close c2;
      raise CALENDAR_NOT_DEFINED;
   end if;
   close c2;
   pfx := dapi.getLFRecord;
   lRowStyle1 := 'STYLE="' || 'background-color: #' || pfx.vert_colour_a || ';"';
   lRowStyle2 := 'STYLE="' || 'background-color: #' || pfx.vert_colour_b || ';"';
   dDateToStart := nvl(TO_DATE( date_to_start, LNG.MASK ),sysdate);
   dThisMonth := dDateToStart;
   if err_text is not null then
      htp.header( 2, err_text, cattributes=>'class="ERROR"' );
   end if;
   htp.formOpen( 'bkn.accept_details', cattributes=>'NAME="form1"' );
   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   htp.formHidden( 'pOrganisedTour', org_tour );
   htp.formHidden( 'pCommand', null );
   htp.formHidden( 'pHour', '9' );
   htp.formHidden( 'pMinute', '00' );
   htp.formHidden( 'pMeridian', 'AM' );
   htp.formHidden( 'pPreviousStep', null );
   htp.formHidden( 'pVisitDate', date_to_start );
   htp.formHidden( 'pCancel', null );
   htp.formHidden( 'pNextStep', null );
   -- Javascript to interact with the calendar
   htp.p( '<script type="text/javascript">
      <!-- Script in DATE_PICKER
      function setDate( dateString ) {
         document.form1.pVisitDate.value = dateString;
         document.form1.pNextStep.value = "Next";
         document.form1.submit( );
      }
      function selectMonth( ) {
         document.form1.submit( );
      }
      // End Javascript -->
      </script>' );
   -- End javascript
   htp.p( BKN_TXT_001_001 );
   htp.formText( 'pGroupSize', '3', '3', nov );
   htp.p( '</p>' );
   -- Select type of visit
   -- XXX Dummy anchor pointing to nothing. Meant to pop up window with help
   --htp.p( BKN_TXT_001_002 );
   open c3( lAccountId );
   fetch c3 into c3rec;
   close c3;
   htp.p( 'Select the ' || visithelp( surl, acid, 'type of visit', c3rec.visit_type_id ));
   --htp.p( 'Select the type of visit' );
   -- All visit types
   for c3rec in c3( lAccountId ) loop
      htp.nl;
      if c1rec.visit_type = TO_CHAR( c3rec.visit_type_id ) then
         htp.formRadio( 'pTypeOfVisit', c3rec.visit_type_id, 'CHECKED' );
      else
         htp.formRadio( 'pTypeOfVisit', c3rec.visit_type_id );
      end if;
      --htp.p( visithelp( surl, acid, c3rec.description, c3rec.visit_type_id ) );
      htp.p( c3rec.description );
   end loop;

   -- Setup calendar header
   htp.p( BKN_TXT_001_003 );
   htp.formSelectOpen( 'pSelectMonth', cattributes=>'onChange="selectMonth( );"' );
   htp.formSelectOption( 'Select a month...', cattributes=>'value=""' );
   for i in 0..19 loop
      lMonth := TO_CHAR( ADD_MONTHS( SYSDATE, i ), 'Month yyyy' );
      if lMonth = TO_CHAR( dDateToStart, 'Month yyyy' ) then
         htp.formSelectOption( lMonth, cselected=>'SELECTED', cattributes=>'value="' || TO_CHAR( ADD_MONTHS( SYSDATE, i ), LNG.MASK ) || '"' );
      else
         htp.formSelectOption( lMonth, cattributes=>'value="' || TO_CHAR( ADD_MONTHS( SYSDATE, i ), LNG.MASK ) || '"' );
      end if;
   end loop;
   htp.formSelectClose;
   htp.p( '</p>' );
   htp.tableOpen( cattributes=>'border="0" cellpadding="3" cellspacing="0"' );
   htp.tableRowOpen;
   htp.tableData( htf.formImage( 'pPreviousMonth', DECS.IMAGE_LOCATION ||
                  'booking/pmonth.gif', cattributes=>'alt="' ||
                  LNG5.BKN_TXT_052 || '" title="' || LNG5.BKN_TXT_052 || '"' ), 'RIGHT' ); -- Link to previous month
   htp.tableData( '<center>' || htf.bold( TO_CHAR( dDateToStart, 'Month YYYY' ) )
                  || '</center>', ccolspan=>'7', calign=>'CENTER' );
   htp.tableData( htf.formimage( 'pNextMonth', DECS.IMAGE_LOCATION ||
                  'booking/nmonth.gif', cattributes=>'alt="' ||LNG5.BKN_TXT_053 || '" title="' || LNG5.BKN_TXT_053 || '"' ), 'LEFT' ); -- Link to next month
   htp.tableRowClose;

   -- Go to the first day of the month
   lDayToStart := TO_NUMBER( TO_CHAR( dDateToStart, 'DD' ) );
   dDateToStart := dDateToStart - lDayToStart;
   -- Go to the first day of the week
   lDayToStart := TO_NUMBER( TO_CHAR( dDateToStart, 'D' ) ) - 1;
   if lDayToStart != 7 then
      dDateToStart := dDateToStart - lDayToStart;
   end if;
   htp.tableRowOpen( 'center' );
   htp.tableData( '&nbsp;', crowspan=>'7' );
   for i in 1..7 loop
      htp.tableHeader( '<center>' || htf.bold( INITCAP( LOWER( ( TO_CHAR( dDateToStart + i, 'DY' ) ) ) ) ) || '</center>' );
   end loop;
   htp.tableData( '&nbsp;', crowspan=>'7' );
   htp.tableRowClose;
   for i in 1..6 loop
      if MOD( i, 2 ) = 0 then
         htp.tableRowOpen;
      else
         htp.tableRowOpen;
      end if;
      for j in 1..7 loop
         dDateToStart := dDateToStart + 1;
         if ( TO_CHAR( dThisMonth, 'MM' ) != TO_CHAR( dDateToStart, 'MM' ) )
            OR ( dDateToStart <= SYSDATE -1 ) then
            htp.tableData( '&nbsp;' );
         else
            htp.tableData( '<center>' || htf.anchor( 'javascript:setDate( ''' ||
                           TO_CHAR( dDateToStart, LNG.MASK ) || ''' );' ,
                           TO_CHAR( dDateToStart, 'DD' ) ) || '</center>', 'CENTER' );
         end if;
      end loop;
      htp.tableRowClose;
   end loop;
   htp.tableClose;
   -- End setup calendar
   htp.nl;htp.nl;
   htp.formClose;
   htp.p( cal.getFooter( c1rec.calendar_id ) );
   htp.p( '</div>' );
   htp.p( '<script type="text/javascript" src="' || BKN_BOTTOMSCRIPT || '"></script>' );
   dapi.pageClose;
exception
   when BOOKING_NOT_FOUND_EXCEPTION then
      htp.init;
      htp.htmlOpen;
      htp.p( BKN_TXT_000_003);
      htp.htmlClose;
   when CALENDAR_NOT_DEFINED then
      open c0( lSessionId );
      fetch c0 into c0rec;
      close c0;
      if send_email( surl, acid, c0rec.booking_id, 'Deleted', email_sendto ) then commit; else rollback; end if;
      update booking
         set status = 'Deleted'
         where session_id = lSessionId and status = 'Pre Booking';
      glbx.error_details( PACKAGE_NAME, 'DETAILS', vaid=>acid,
                          errmsg=>BKN_TXT_000_004, extdet=>BKN_TXT_000_005 );
   when others then
      glbx.error_details( PACKAGE_NAME, 'DETAILS', errmsg=>sqlerrm );
end details;

procedure accept_details( surl varchar2, acid integer default null, pVisitDate varchar2,
                          pHour varchar2, pMinute varchar2, pMeridian varchar2,
                          pGroupSize varchar2, pOrganisedTour varchar2 default null,
                          pPreviousMonth varchar2 default null,
                          pNextMonth varchar2 default null,
                          pCancel varchar2 default null,
                          pPreviousStep varchar2 default null,
                          pNextStep varchar2 default null,
                          pSelectMonth varchar2 default null,
                          pCommand varchar2 default null,
                          pTypeOfVisit varchar2 default null )
as
   -- Fetch calendar settings
   cursor c2( cpid integer, cdate date ) is
      select count( 'x' ) total
      from calendar c,
           calendar_map cm
      where c.calendar_id = cm.calendar_id and
            cm.aid = ( select aid
                       from customer_profile
                       where profile_id = cpid ) and
            cdate <= expire_date;
   cursor c3( cdate date, cVisitTypeId integer ) is
      select MIN( TO_NUMBER( SUBSTR( opening_time, 1, 2 ) ) ) min_hour,
             MIN( TO_NUMBER( SUBSTR( opening_time, 4, 2 ) ) ) min_minute,
             MAX( TO_NUMBER( SUBSTR( closing_time, 1, 2 ) ) ) max_hour,
             MAX( TO_NUMBER( SUBSTR( closing_time, 4, 2 ) ) ) max_minute
      from school_holidays
      where ( cdate BETWEEN date_from and date_to ) and
            calendar_id = cVisitTypeId;
   cursor c4( cVisitType integer ) is
      select valid_from_date,
             valid_to_date,
             valid_to_time,
             TO_NUMBER( SUBSTR( valid_from_time, 1, 2 ) ) min_hour,
             TO_NUMBER( SUBSTR( valid_from_time, 4, 2 ) ) min_minute,
             TO_NUMBER( SUBSTR( valid_to_time, 1, 2 ) ) max_hour,
             TO_NUMBER( SUBSTR( valid_to_time, 4, 2 ) ) max_minute
      from visit_types
      where visit_type_id = cVisitType;

   EGENERAL Exception;
   c2rec c2%ROWTYPE;
   c3rec c3%ROWTYPE;
   c4rec c4%ROWTYPE;
   rBooking booking%ROWTYPE;
   lVisitDate date;
   lHour integer;
   lMinute integer;
   lMeridian varchar2( 2 );
   lGroupSize integer;
   lOrganisedTour boolean;
   dNewProposedDate       date;
   lNewOrgTour            booking.organised%TYPE;
   lSessionId             integer;
   lAccountId             integer;
   lHour24                integer;
   lCheckNumberOfVisitors integer;
   lEarliestStartHour     integer;
   lLatestEndHour         integer;
   lLatestEndMinute       integer;
   lSchoolHoliday boolean;
   msg                    varchar2( 1000 ) := NULL;
begin
   if not dapi.init( surl, 'BKN.ACCEPT_DETAILS', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   lAccountId := dapi.getAccountId;
   lSessionId := dapi.getSessionId;
   -- insert visit type
   if pTypeOfVisit is not null then
      update booking
         set visit_type = pTypeOfVisit
         where session_id = lSessionId and
               status = 'Pre Booking';
      commit;
   end if;
   if not bookingActive( lSessionId, rBooking ) then
      bookingNotActive( surl, acid );
      return;
   end if;
   if pNextStep is not NULL then
      -- Convert time to 24h
      if ( pMeridian = 'PM' ) then
         lHour24 := TO_NUMBER( pHour ) + 12;
      else
         lHour24 := TO_NUMBER( pHour );
      end if;
      -- Check if entered date is a valid date
      begin
         dNewProposedDate := TO_DATE( pVisitDate || ' ' || lHour24 || ':' || pMinute, LNG.TSMASK );
      exception when others then
         dNewProposedDate := SYSDATE;
         msg := msg || htf.nl || LNG3.ADM_TXT_453;
         raise EGENERAL;
      end;
      -- Fetch calendar settings
      open c2( lAccountId, dNewProposedDate );
      fetch c2 into c2rec;
      close c2;
      -- Check if the calendar is active for the chosen date
      if c2rec.total <= 0 then
         msg := msg || htf.nl || BKN_TXT_001_997;
         raise EGENERAL;
      end if;
      if pTypeOfVisit is null then
         msg := msg || htf.nl || 'Please select a visit type';
         raise EGENERAL;
      end if;
      -- Fetch settings for the visit type
      open c4( rBooking.visit_type );
      fetch c4 into c4rec;
      close c4;
      -- Check if the date is valid for this visit type
      if dNewProposedDate NOT BETWEEN c4rec.valid_from_date AND c4rec.valid_to_date then
         msg := msg || htf.nl || BKN_TXT_001_996;
         raise EGENERAL;
      end if;
      -- Fetch alternative opening times
      open c3( dNewProposedDate, rBooking.visit_type );
      fetch c3 into c3rec;
      lSchoolHoliday := c3%FOUND;
      close c3;
      -- Determine the earliest starting hour and the latest ending hour
      if lSchoolHoliday then
         lEarliestStartHour := TO_NUMBER( LEAST( NVL( c3rec.min_hour, 24 ), c4rec.min_hour ) );
         lLatestEndHour     := TO_NUMBER( GREATEST( NVL( c3rec.max_hour, 0 ), c4rec.max_hour ) );
         lLatestEndMinute   := TO_NUMBER( GREATEST( NVL( c3rec.max_minute, 0 ), c4rec.max_minute ) );
      else
         lEarliestStartHour := c4rec.min_hour;
         lLatestEndHour     := c4rec.max_hour;
         lLatestEndMinute   := c4rec.max_minute;
      end if;
      -- Check if the entered time is allowed
      -- The time has to be later than the valid start time. The valid
      -- start time is taken from the vsit_types and the school holidays
      if false then -- DEBUG
         if lEarliestStartHour <= lHour24 then
            /*
            if lHour24 BETWEEN lEarliestStartHour AND lLatestEndHour then
               null;
            end if;
            */
            if lHour24 <= lLatestEndHour then
               -- Hour is valid in between start time and end time
               if ( lHour24 = lLatestEndHour ) then
                  -- Hour is equal to last hour, check the minutes
                  if pMinute > lLatestEndMinute then
                     -- Invalid time given, raise exception
                     msg := msg || htf.nl || BKN_TXT_001_995;
                  end if;
               end if;
            else
               -- Invalid time given, raise exception
               msg := msg || htf.nl || BKN_TXT_001_995;
            end if;
         else
            -- Invalid time given, raise exception
            msg := msg || htf.nl || BKN_TXT_001_994;
         end if;
      end if;
      -- Check the number of visitors
      begin
         lCheckNumberOfVisitors := TO_NUMBER( pGroupSize );
      exception when others then
         msg := msg || htf.nl || BKN_TXT_001_999;
         raise EGENERAL;
      end;
      if ( pGroupSize is null ) or ( pGroupSize <= 0 ) then
         msg := msg || htf.nl || BKN_TXT_001_998;
         raise EGENERAL;
      end if;
      -- Check if date is not before today
      if dNewProposedDate <= SYSDATE - 1 then
         msg := msg || htf.nl || BKN_TXT_001_993;
         raise EGENERAL;
      end if;
      if msg is not null then
         raise EGENERAL;
      end if;
      update booking
         set last_step = '2',
             date_time = dNewProposedDate,
             num_of_students = pGroupSize,
             organised = lNewOrgTour
         where session_id = lSessionId and
               status = 'Pre Booking';
      show_calendar( surl, acid, TO_CHAR( dNewProposedDate, LNG.TSMASK ) );
   elsif pPreviousStep is not NULL then -- Back
      typeOfVisit( surl, acid );
   elsif pCancel is not NULL then -- Cancel
      cancelBooking( surl, acid, pCommand );
   elsif pPreviousMonth is not null then -- Previous month
      details( surl, acid, lHour24, pMinute, pGroupSize,
               TO_CHAR( ADD_MONTHS( TO_DATE( pVisitDate, LNG.MASK ),-1 ), LNG.MASK ),
               TO_CHAR( rBooking.date_time, LNG.MASK ), pOrganisedTour );
   elsif pNextMonth is not null then -- Next month
      details( surl, acid, lHour24, pMinute, pGroupSize,
               TO_CHAR( ADD_MONTHS( TO_DATE( pVisitDate, LNG.MASK ),1 ), LNG.MASK ),
               TO_CHAR( rBooking.date_time, LNG.MASK ), pOrganisedTour );
   elsif pSelectMonth is not null then -- Display with a new month
      details( surl, acid, lHour24, pMinute, pGroupSize, pSelectMonth,
               TO_CHAR( rBooking.date_time, LNG.MASK ), pOrganisedTour );
   end if;
exception
   when EGENERAL then
      details( surl, acid, lHour24, pMinute, pGroupSize,
               TO_CHAR( dNewProposedDate, LNG.MASK ),
               TO_CHAR( rBooking.date_time, LNG.MASK ), pOrganisedTour, msg );
   when others then
      glbx.error_details( 'BKN', 'ACCEPT_DETAILS', errmsg=>sqlerrm );
end accept_details;

/**
* Screen name: BKN002
*/
procedure show_calendar( surl varchar2, acid integer, proposed_date varchar2 default null, errmsg in varchar2 default null )
as
   -- Fetch calendar settings
   cursor c2( caid integer ) is
      select c.calendar_id calid,
             start_time,
             end_time,
             time_block,
             date_format,
             days_in_view
      from calendar c,
           calendar_map cm
      where c.calendar_id = cm.calendar_id and
            cm.aid = ( select aid
                       from customer_profile
                       where profile_id = caid );

   c2rec c2%ROWTYPE;
   c4rec booking%ROWTYPE;
   sess_id integer;
   rTheme  theme%ROWTYPE;
   daysBefore            integer;
   daysAfter             integer;
   c_DateTime1      varchar2( 100 );
   c_DateTime3      varchar2( 100 );
   lAccountId integer;
   lSessionId integer;
begin
   if not dapi.init( surl, 'BKN.SHOW_CALENDAR', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   lAccountId := dapi.getAccountId;
   lSessionId := dapi.getSessionId;
   -- Fetch booking details
   if not bookingActive( lSessionId, c4rec ) then
      bookingNotActive( surl, acid );
      return;
   end if;
   dapi.setExternalStyleSheet(  BKN_STYLESHEET );
   -- dapi.setTitle( getTitle( c4rec.booking_id ) );
   rTheme := dapi.getLFRecord;
   dapi.pageOpen;
   htp.comment( 'Screen name: BKN002' );
   htp.p( '<script type="text/javascript" src="' || BKN_TOPSCRIPT || '"></script>' );
   htp.p( '<div class="bodytext">' );
   showProgress( 2, c4rec.booking_id );
   -- Fetch calendar details
   open c2( lAccountId );
   fetch c2 into c2rec;
   close c2;
   htp.p( BKN_TXT_002_001 );
   htp.p( cal.getFooter( c4rec.calendar_id ) );
   if errmsg is not null
    then
     htp.header(2, errmsg, 'CENTER' );
   end if;
   -- Calculate the number of days to show
   daysAfter := TRUNC( c2rec.days_in_view/2 );
   daysBefore := c2rec.days_in_view - daysAfter - 1;
   htp.formOpen( 'bkn.navigate_calendar' );
   htp.formhidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   htp.formHidden( 'proposed_date', proposed_date );
   htp.p( '<p style="text-align: left;">' );
   htp.tableOpen( cattributes=>'border="0" cellpadding="0" cellspacing="0"' );
   htp.tableRowOpen;
   -- Print the link to the previous day
   htp.tableData( htf.formImage( 'pPreviousDay', DECS.IMAGE_LOCATION ||
                  'booking/pday.gif', cattributes=>'alt="' ||
                  BKN_TXT_002_005 || '" title="' || BKN_TXT_002_005 || '"' ),
                  'LEFT' ); -- Link to previous day
   -- Print the headers
   for i in -daysBefore..daysAfter loop
   begin
      htp.tableData( htf.bold( INITCAP( LOWER( TO_CHAR( TO_DATE(
                     proposed_date, LNG.TSMASK ) + i, LNG5.BKN_TXT_086 ) ) ) ),
                     cattributes=>'ALIGN="CENTER"' );
   exception when others then
      NULL;
   end;
   end loop;
   -- Print the link to the next day
   htp.tableData( htf.formImage( 'pNextDay', DECS.IMAGE_LOCATION ||
                  'booking/nday.gif', cattributes=>'alt="' ||
                  BKN_TXT_002_006 || '" title="' || BKN_TXT_002_006 || '"' ),
                  'RIGHT' ); -- Link to next day
   htp.tableRowClose;
   htp.p( '</p>' );
   -- htp.tableClose;
   htp.formClose;

   sub_show_calendar( surl, acid, proposed_date, 'FALSE' );
   htp.p( '</div>' );
   htp.p( '<script type="text/javascript" src="' || BKN_BOTTOMSCRIPT || '"></script>' );
   dapi.pageClose;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'SHOW_CALENDAR', errmsg=>sqlerrm );
end show_calendar;

procedure sub_show_calendar( surl varchar2, acid integer, proposed_date varchar2 default null, inFrame varchar2 )
as
   -- Retrieve occupied time by a resource
   cursor c1( date_to_check date, crid integer, ccid integer ) is
      select count( * ) is_positive
      from resource_use ru, booking b
      where ( date_to_check BETWEEN ru.date_time_from AND ( ru.date_time_to - ( 1/( 24*60 ) ) ) ) and
            ru.resource_id = crid and ru.calendar_id = ccid and
            ru.booking_id  = b.booking_id and
            b.status in ( LNG5.BKN_TXT_004, LNG5.BKN_TXT_005, LNG5.BKN_TXT_006, 'Reservation Accepted', 'Visit Complete', 'Problem' );
   -- Fetch calendar settings
   cursor c2( caid integer ) is
      select c.calendar_id calid, start_time, end_time, time_block, date_format,
             days_in_view, TO_NUMBER( TO_CHAR( start_time, 'HH24' ) ) start_hour,
             TO_NUMBER( TO_CHAR( start_time, 'MI' ) ) start_minute,
             TO_NUMBER( TO_CHAR( end_time, 'HH24' ) ) end_hour,
             TO_NUMBER( TO_CHAR( end_time, 'MI' ) ) end_minute
      from calendar c, calendar_map cm
      where c.calendar_id = cm.calendar_id and
            cm.aid = ( select aid from customer_profile where profile_id = caid );
   -- Retrieve resource details
   cursor c3( crid integer ) is
      select *
      from resources
      where resource_id = crid;
   -- Fetch current booking
   cursor c4( csid integer ) is
      select *
      from booking b
      where b.session_id = csid and b.status = LNG5.BKN_TXT_004;
   -- Fetch blocked times for the specified Calendar
   cursor c5( ccid integer, cdate date ) is
      select reason
      from excluded_calendar_times
      where calendar_id = ccid and
            ( cdate BETWEEN date_time_from AND date_time_to );
   -- Fetch school holidays
   cursor c6( cVisitTypeId integer, cdate date ) is
      select TO_NUMBER( SUBSTR( opening_time, 1, 2 ) ) opening_hour,
             TO_NUMBER( SUBSTR( opening_time, 4, 2 ) ) opening_minute,
             TO_NUMBER( SUBSTR( closing_time, 1, 2 ) ) closing_hour,
             TO_NUMBER( SUBSTR( closing_time, 4, 2 ) ) closing_minute
      from school_holidays
      where calendar_id = cVisitTypeId and
            ( cdate BETWEEN date_from AND date_to );
   cursor c7( cProfileId integer ) is
      select education_id, galleries_id
      from school_booking_prefs
      where std_profile_aid = ( select aid
                                from customer_profile
                                where profile_id = cProfileId )
            and
            std_profile_pid = ( select pid
                                from customer_profile
                                where profile_id = cProfileId );
   cursor c8( cVisittypeId integer, cdate date ) is
      select valid_from_time, valid_to_time
      from visit_types
      where visit_type_id = cVisitTypeId and
            cdate BETWEEN valid_from_date AND valid_to_date;

   c1rec c1%ROWTYPE;
   c2rec c2%ROWTYPE;
   c3rec c3%ROWTYPE;
   c4rec c4%ROWTYPE;
   c5rec c5%ROWTYPE;
   c6rec c6%ROWTYPE;
   c7rec c7%ROWTYPE;
   c8rec c8%ROWTYPE;
   dThisDay     date;
   cThisDay     varchar( 100 );
   dThisTime    date;
   cThisTime    varchar( 100 );
   dThisDayTime date;
   cThisDayTime varchar( 100 );
   c_DateTime1      varchar2( 100 );
   c_DateTime3      varchar2( 100 );
   bTimeAvailable   boolean;
   nRow             integer; -- even or odd row 0 = even 1 is odd
   textNotAvailable varchar2( 200 );
   daysBefore            integer;
   daysAfter             integer;
   earliest_start_hour   integer;
   latest_end_hour       integer;
   earliest_start_minute integer;
   latest_end_minute     integer;
   end_minute            integer;
   time_span      integer; -- Time span is the amount of time blocks that should be used for the Education Centre
   time_span2     integer; -- Time span for the Galleries
   nTimeLookAhead integer;
   nNumOfVis      number;
   tableAtts  varchar2( 100 );
   anchorText varchar2( 100 );
   fontSize   varchar2( 10 );
   bid        integer;
   i_hours       integer;
   i_hours_end   integer;
   i_minutes     integer;
   i_minutes_end integer;
   lSessionId integer;
   lAccountId integer;
   rTheme  theme%ROWTYPE;
   orig_stime date; -- Original starting time
   orig_etime date; -- Original ending time
   is_school_holiday boolean;
   linkTarget varchar2( 10 ) := '"_self"';
   l_scroll_to varchar2( 500 );
   lJavaScript varchar2( 1000 );
   lIsSelected boolean;
   lTimeAvailable boolean;
   lTimeNotAvailable boolean;
   lTimeNegotiable boolean;
   lTimeBooked boolean;
begin
   if not dapi.init( surl, 'BKN.SUB_SHOW_CALENDAR', acid, FALSE, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   lSessionId := dapi.getSessionid;
   lAccountId := dapi.getAccountId;
   rTheme := dapi.getLFRecord;
   l_scroll_to := '_' || REPLACE( REPLACE( REPLACE( proposed_date, ':', 'x' ), ' ', 'x' ), '-', '_' );
   -- lJavaScript := ' onLoad="if ( document.layers ) scrollTo( 0, document.anchors[' || l_scroll_to || '].y ); if ( document.all ) eval( ''document.all.' || l_scroll_to || '.click( )'' );" ';
   fontSize    := '8pt';
   if inFrame = 'TRUE' then
      -- dapi.setBodyAddition( lJavaScript );
      dapi.pageOpen;
      linkTarget := '"_parent"';
   end if;
   -- Fetch calendar details
   open c2( lAccountId );
   fetch c2 into c2rec;
   close c2;
   -- Fetch booking details
   open c4( lSessionId );
   fetch c4 into c4rec;
   close c4;
   -- Fetch default settings
   open c7( lAccountId );
   fetch c7 into c7rec;
   close c7;
   -- Calculate time span for education centre
   -- Fetch the details of the resource
   open c3( c7rec.education_id );
   fetch c3 into c3rec;
   close c3;
   time_span := 1;                              -- At least 1 group goes through the education centre
   nNumOfVis := c4rec.num_of_students;          -- Only use the number of students
   while nNumOfVis > c3rec.max_group_size loop
      time_span := time_span + 1;
      nNumOfVis := nNumOfVis - c3rec.max_group_size;
   end loop;
   -- Calculate time span for Galleries
   -- Fetch the details of the resource
   open c3( c7rec.galleries_id );
   fetch c3 into c3rec;
   close c3;
   time_span2 := 1;                             -- At least 1 group goes through the education centre
   nNumOfVis  := c4rec.num_of_students;         -- Only use the number of students
   while nNumOfVis > c3rec.max_group_size loop
      time_span2 := time_span2 + 1;
      nNumOfVis  := nNumOfVis - c3rec.max_group_size;
   end loop;
   -- Calculate the amount of days to show
   daysAfter := TRUNC( c2rec.days_in_view/2 );
   daysBefore := c2rec.days_in_view - daysAfter - 1;
   -- Calculate the amount of time to look ahead for a booking
   -- If it is a Self guided tour we only need to check in chuncks
   -- of 15 minutes.
   -- If it is a Guided tour we have to include the time occupied in the Galeries.
   if getVisitTypeClass( c4rec.visit_type ) = LNG5.BKN_TXT_002 then
      -- When it is a paid program then also check the galeries
      nTimeLookAhead := time_span * TIME_IN_ED_CENTRE + time_span2 * TIME_IN_GALERIES;
   else
      nTimeLookAhead := time_span * TIME_IN_ED_CENTRE;
   end if;
   -- Loop though the hours, the time from the calendar is taken
   nRow := 0;
   i_hours := c2rec.start_hour;
   end_minute := 59;
   while i_hours <= c2rec.end_hour loop
      -- The first time we may want to start at an alternative minute
      if nRow = 0 then
         i_minutes := c2rec.start_minute;
      else
         i_minutes := 0;
      end if;
      -- The last time we may want to end with an alternative minute
      if i_hours = c2rec.end_hour then
         end_minute := c2rec.end_minute;
      end if;
      -- loop through the minutes
      while i_minutes <= end_minute loop
         dThisTime := TO_DATE( TO_CHAR( i_hours, '09' ) || ':' || TO_CHAR( i_minutes, '09' ), lng.TSMASK_ONLY );
         cThisTime := TO_CHAR( dThisTime, LNG.TSMASK_ONLY );
         if nRow = 0 then
            htp.tableRowOpen;
         else
            htp.tableRowOpen;
         end if;
         nRow := mod( 1, nRow );
         htp.p( '<td align="right" width="60">' );
         htp.p( '<a name="' || REPLACE( REPLACE( REPLACE( cThisDayTime, ':', 'x' ), ' ', 'x' ), '-', '_' ) || '"></a><a name="_' || REPLACE( REPLACE( REPLACE( cThisDayTime, ':', 'x' ), ' ', 'x' ), '-', '_' ) || '" href="#' || REPLACE( REPLACE( REPLACE( cThisDayTime, ':', 'x' ), ' ', 'x' ), '-', '_' ) || '"></a>' );
         htp.bold( cThisTime );
         htp.p( '</td>' );

         for dayCount in -daysBefore..daysAfter loop
            dThisDay     := TO_DATE( proposed_date, LNG.TSMASK ) + dayCount;
            cThisDay     := TO_CHAR( dThisDay, LNG.MASK );
            dThisDayTime := TO_DATE( cThisDay || ' ' || cThisTime, LNG.TSMASK );
            cThisDayTime := TO_CHAR( dThisDayTime, LNG.TSMASK );

            bTimeAvailable := TRUE;
            lTimeAvailable := FALSE;
            lTimeNotAvailable := FALSE;
            lTimeNegotiable := FALSE;
            lTimeBooked := FALSE;
            textNotAvailable := '';
            if bTimeAvailable then
               -- Check if the current date and time is on a blocked day
               open c5( c2rec.calid, dThisDayTime );
               fetch c5 into c5rec;
               bTimeAvailable := c5%NOTFOUND;
               close c5;
               if not bTimeAvailable then
                  lTimeAvailable := FALSE;
                  lTimeNegotiable := FALSE;
                  lTimeBooked := TRUE;
                  textNotAvailable := c5rec.reason;
               end if;
            end if;
            if bTimeAvailable then
               -- Check if the current date and time is on a school holiday
               open c6( c4rec.visit_type, dThisDayTime );
               fetch c6 into c6rec;
               if c6%FOUND then
                  is_school_holiday := TRUE;
                  close c6;
                  -- Compare two times only
                  orig_stime := TO_DATE( cThisDay || ' ' || to_char(c6rec.opening_hour) || ':' || to_char(c6rec.opening_minute), LNG.TSMASK ); --c2rec.start_time
                  orig_etime := TO_DATE( cThisDay || ' ' || to_char(c6rec.closing_hour) || ':' || to_char(c6rec.closing_minute), LNG.TSMASK ); --c2rec.end_time
                  bTimeAvailable := dThisDayTime BETWEEN orig_stime AND orig_etime;
               else
                  close c6;
                  -- There is no alternative start time so use the time as specified in the visit_types table
                  open c8( c4rec.visit_type, dThisDayTime );
                  fetch c8 into c8rec;
                  bTimeAvailable := c8%FOUND;
                  close c8;
                  htp.comment( 'not found' );
                  if bTimeAvailable then
                     orig_stime := TO_DATE( cThisDay || ' ' || c8rec.valid_from_time, LNG.TSMASK );
                     orig_etime := TO_DATE( cThisDay || ' ' || c8rec.valid_to_time, LNG.TSMASK );
                     bTimeAvailable := dThisDayTime BETWEEN orig_stime AND orig_etime;
                  end if;
               end if;
               textNotAvailable := null;
            end if;
            if bTimeAvailable then
               -- Look ahead in time to see if there is no overlap
               for j in 0..( nTimeLookAhead/c2rec.time_block )-1 loop
                  -- Check the Education centre occupation
                  open c1( dThisDayTime + j * ( c2rec.time_block * MINUTES_1 ), c7rec.education_id, c2rec.calid );
                  fetch c1 into c1rec;
                  close c1;

                  bTimeAvailable := c1rec.is_positive = 0;
                  if not bTimeAvailable then
                     -- When we look 0 times ahead then the time is the current time that is not available
                     -- otherwise the time will be negotiable
                     if j = 0 then
                        lTimeAvailable := FALSE;
                        lTimeNegotiable := FALSE;
                        lTimeBooked := TRUE;
                     else
                        lTimeAvailable := FALSE;
                        lTimeNegotiable := TRUE;
                        lTimeBooked := FALSE;
                     end if;
                     textNotAvailable := null;
                     exit;
                  end if;
                  -- Check the Galeries if it is a paid program
                  if getVisitTypeClass( c4rec.visit_type ) = LNG5.BKN_TXT_002 then
                     open c1( dThisDayTime + j * ( c2rec.time_block * MINUTES_1 ), c7rec.galleries_id, c2rec.calid );
                     fetch c1 into c1rec;
                     close c1;

                     bTimeAvailable := c1rec.is_positive = 0;
                     if not bTimeAvailable then
                        -- When we look 0 times ahead then the time is the current time that is not available
                        -- otherwise the time will be negotiable
                        if j = 0 then
                           lTimeAvailable := FALSE;
                           lTimeNegotiable := FALSE;
                           lTimeBooked := TRUE;
                        else
                           lTimeAvailable := FALSE;
                           lTimeNegotiable := TRUE;
                           lTimeBooked := FALSE;
                        end if;
                        textNotAvailable := null;
                        exit;
                     end if;
                  end if;
                  -- Check if the visit will not exceed the closing time
                  if bTimeAvailable then
                     if is_school_holiday then
                        bTimeAvailable := ( dThisDayTime + j * ( c2rec.time_block * MINUTES_1 ) ) < to_date( cThisDay || ' ' || latest_end_hour || ':' || latest_end_minute, LNG.TSMASK );
                     else
                        bTimeAvailable := ( dThisDayTime + j * ( c2rec.time_block * MINUTES_1 ) ) < orig_etime;
                     end if;
                     if not bTimeAvailable then
                        lTimeNegotiable := TRUE;
                        lTimeAvailable := FALSE;
                        lTimeBooked := FALSE;
                     end if;
                  end if;
               end loop;
            end if;
            if bTimeAvailable then
               lTimeAvailable := TRUE;
               lTimeNegotiable := FALSE;
               lTimeBooked := FALSE;
            end if;
            if NOT lTimeAvailable AND NOT lTimeNegotiable AND NOT lTimeBooked then
               lTimeNotAvailable := TRUE;
            end if;
            lIsSelected := cThisDayTime = proposed_date;
            if lTimeAvailable then
               htp.p( '<td width="160" class="timeAvaliable" ><center>' );
               anchortext := 'time available';
               htp.anchor( 'bkn.accept_calendar?sUrl=' || sUrl || '&acid=' || acid || '&new_date_time=' || cThisDayTime || '&action=Next', anchorText, cattributes=>'target=' || linkTarget || LNG5.BKN_TXT_008 || CRLF || cThisDayTime || '"' );
            elsif lTimeNegotiable then
               htp.p( '<td width="160" class="timeNegotiable"><center>' );
               anchorText := 'time available';
               htp.anchor( 'bkn.accept_calendar?sUrl=' || sUrl || '&acid=' || acid || '&new_date_time=' || cThisDayTime || '&action=Next', anchorText, cattributes=>'target=' || linkTarget || ' TITLE="' || LNG5.BKN_TXT_008 || CRLF || cThisDayTime || '"' );
            elsif lTimeBooked then
               htp.p( '<td width="160" class="timeBooked"><center>' );
               anchorText := 'time booked';
               htp.p( '<span style="color:#' || rTheme.caption_text_colour || ';font-family:' || rTheme.caption_text_font || ';font-size:' || fontSize || '">' || anchorText || '</span>' );
            elsif lTimeNotAvailable then
               htp.p( '<td width="160" class="timeNotAvailable"><center>' );
               anchorText := 'not available';
               htp.p( anchorText );
            end if;
            htp.p( '</center></TD>' );
         end loop;
         htp.p( '<td width="60" class="CALENDAR" ALIGN="CENTER" STYLE="color:#' || rTheme.caption_text_colour || ';font-family:' || rTheme.caption_text_font || ';font-size: ' || fontSize || '">' );
         htp.p( '&nbsp;' );
         htp.p( '</TD>' );
         htp.tableRowClose;
         i_minutes := i_minutes + c2rec.time_block;
      end loop;

      i_hours := i_hours + 1;
   end loop;

   htp.tableClose;
   htp.p( '</font>' );
   if inFrame = 'TRUE' then
      dapi.pageClose;
   end if;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'SUB_SHOW_CALENDAR', errmsg=>sqlerrm );
end sub_show_calendar;

function check_too_large( c1rec in booking%ROWTYPE, dt in date )
 return boolean
as
   cursor c2( calid integer, resid integer, dt date ) is
    select 'x' exst
    from calendar cl, resource_use ru
    where cl.calendar_id = calid and
          ru.resource_id = resid and
          cl.calendar_id = ru.resource_id and
          date_time_from = dt + (cl.time_block * MINUTES_1 );

   cursor c3( crid integer ) is
      select *
      from resources
      where resource_id = crid;

   cursor c7( cProfileId integer ) is
      select education_id, galleries_id
      from school_booking_prefs
      where std_profile_aid = ( select aid
                                from customer_profile
                                where profile_id = cProfileId )
            and
            std_profile_pid = ( select pid
                                from customer_profile
                                where profile_id = cProfileId );

   c2rec c2%ROWTYPE;
   c3rec c3%ROWTYPE;
   c7rec c7%ROWTYPE;
   lAccountId integer;

begin
   lAccountId := dapi.getAccountId;
   open c7( lAccountId );
   fetch c7 into c7rec;
   close c7;
   open c3( c7rec.education_id );
   fetch c3 into c3rec;
   close c3;
   if c1rec.num_of_students < c3rec.max_group_size
    then
     glbx.dbg( 'FALSE 1' );
     return( FALSE ); -- Not a problem, group size is a good size
   end if;

   open c2( c1rec.calendar_id, c3rec.resource_id, dt );
   fetch c2 into c2rec;
   if c2%FOUND
    then
     close c2;
     glbx.dbg( 'TRUE' );
     return( TRUE );
    else
     close c2;
     glbx.dbg( 'FALSE 2' );
     return( FALSE );
   end if;
exception
 when others then return( FALSE );
end check_too_large;

procedure accept_calendar(
  surl varchar2,                                -- Secure URL
  acid integer default null,                    -- Account ID
  new_date_time varchar2,                       -- The date and time chosen by the user
  pContactEdOfficer varchar2 default null,      -- If not null then the user clicked on contact AWM button
  pCancel varchar2 default null,                -- If not null then the user clicked on cancel button
  pBack varchar2 default null,                  -- If not null then the user clicked on back button
  action varchar2 default null )                 -- command type
as
   -- Fetch current booking
   cursor c1( csid integer ) is
      select
         *
      from
         booking
      where
         session_id = csid and status = LNG5.BKN_TXT_004;
   c1rec c1%ROWTYPE;

   -- Work variables
   lSessionId integer;
   p_organised varchar2( 1 ) := null;
   lReturnURL varchar2( 1000 );
begin
   if not dapi.init( surl, 'BKN.ACCEPT_CALENDAR', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   lSessionId := dapi.getSessionid;
   if not bookingActive( lSessionId ) then
      bookingNotActive( surl, acid );
      return;
   end if;
   open c1( lSessionId );
   fetch c1 into c1rec;
   close c1;
   if pBack is not null then
      details( surl, acid, TO_CHAR( c1rec.date_time, 'HH24' ), TO_CHAR( c1rec.date_time, 'MI' ), c1rec.num_of_students, TO_CHAR( c1rec.date_time, LNG.MASK ), TO_CHAR( c1rec.date_time, LNG.MASK ), p_organised );
   end if;
   if pCancel is not null then
      cancelBooking( surl, acid, action );
   end if;
   if pContactEdOfficer is not null then
      lReturnURL := 'show_calendar( ' || surl || ', ' || acid || ', ' || TO_CHAR( c1rec.date_time, LNG.TSMASK ) || ' );';
     	contact_awm_staff( surl, acid );
   end if;

   --
   -- Do a check here to see if the time picked clashes.
   --
   if check_too_large( c1rec, TO_DATE( new_date_time, LNG.TSMASK ))
    then
     --show_calendar( surl, acid, new_date_time, 'Please Choose another Timeslot. There are too many students to fit into this timeslot' );
     show_calendar( surl, acid, new_date_time, 'Please choose another time as large groups need two timeslots.' );
     return;
   end if;

   if action is not null then
      update
         booking
      set
         date_time = TO_DATE( new_date_time, LNG.TSMASK ),
         last_step = '2'
      where
         booking_id = c1rec.booking_id;
      school_details( surl, acid );
   end if;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'ACCEPT_CALENDAR', errmsg=>sqlerrm );
end accept_calendar;

procedure navigate_calendar(
  surl varchar2,                                 -- Secure URL
  acid integer,                                  -- Account ID
  proposed_date varchar2,                        -- Proposed date fro the visit
  pPreviousDay varchar2 default null,            -- If not null then the user clicked previous day button
  pNextDay varchar2 default null )                -- If not null then the user clickec next day button
as
   lProposedDate    varchar2( 20 );
begin
   if not dapi.init( surl, 'BKN.NAVIGATE_CALENDAR', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   if pPreviousDay is not null then
      --
      -- Navigate to previous day
      --
      begin
         lProposedDate := TO_CHAR( TO_DATE( proposed_date, LNG.TSMASK )-1, LNG.TSMASK );
         exception when others then NULL;
      end;
      show_calendar( sUrl, acid, lProposedDate );
   end if;
   if pNextDay is not null then
      --
      -- Navigate to next day
      --
      begin
         lProposedDate := TO_CHAR( TO_DATE( proposed_date, LNG.TSMASK )+1, LNG.TSMASK );
         exception when others then NULL;
      end;
      show_calendar( sUrl, acid, lProposedDate );
   end if;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'NAVIGATE_CALENDAR', errmsg=>sqlerrm );
end navigate_calendar;

procedure contact_awm_staff(
  surl varchar2,                                 -- Secure URL
  acid integer default null,                     -- Account ID
  rurl varchar2 default null )                    -- Return URL
as
   -- Fetch calendar settings
   cursor c1( caid integer ) is
      select
         c.calendar_id calid,
         start_time,
         end_time,
         time_block,
         date_format,
         days_in_view,
         name_to_contact,
         phone_to_contact,
         email_to_contact,
         fax_to_contact,
         addr_name,
         addr_name2,
         addr_street,
         addr_city,
         addr_pcode
      from
         calendar c,
         calendar_map cm
      where
         c.calendar_id = cm.calendar_id and
         cm.aid = ( select aid from customer_profile where profile_id = caid );
   c1rec c1%ROWTYPE;


   cursor c3( caid integer, cltype varchar2 ) is
      select
         *
      from
         customer_contact
      where
         aid = caid and
         login_type = cltype;
   c3rec c3%ROWTYPE;

   c2rec booking%ROWTYPE;
   lSessionId integer;
   lAccountId integer;
   lLoginType varchar2( 200 );
   pfx        theme%ROWTYPE;
   i_minutes  integer;
begin
   if not dapi.init( surl, 'BKN.CONTACT_AWM_STAFF', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   lSessionId := dapi.getSessionid;
   lLoginType := dapi.getLoginType;
   lAccountId := dapi.getAccountId;
   pfx := dapi.getLFRecord;
   if not bookingActive( lSessionId, c2rec ) then
      bookingNotActive( surl, acid );
      return;
   end if;
   dapi.setExternalStyleSheet( DECS.IMAGE_LOCATION || 'booking/booking.css' );
   -- dapi.setTitle( getTitle( c2rec.booking_id ) );
   dapi.pageOpen;
   open c1( lAccountId );
   fetch c1 into c1rec;
   close c1;
   open c3( lAccountId, lLoginType );
   fetch c3 into c3rec;
   close c3;
   htp.p( '<CENTER>' );
   htp.tableOpen( cattributes=>TABLE_ATTS );
   htp.tableRowOpen;
   htp.tableData( LNG5.BKN_TXT_061, ccolspan=>'2' );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG.PHG_TXT_022 ), cattributes=>pfx.qbground );
   htp.tableData( c1rec.name_to_contact, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG.CST_TXT_108 ), cattributes=>pfx.qbground );
   htp.tableData( c1rec.phone_to_contact, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG.PHG_TXT_336 ), cattributes=>pfx.qbground );
   htp.tableData( c1rec.fax_to_contact, cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG.PHG_TXT_301 ), cattributes=>pfx.qbground );
   htp.tableData( c1rec.email_to_contact, cattributes=>pfx.qcbground );
   htp.tableRowClose;
   htp.tableClose;

   htp.nl;
   htp.line;
   htp.nl;

   htp.formOpen( 'bkn.accept_contact_awm' );
   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );

   htp.tableOpen( cattributes=>TABLE_ATTS );
   htp.tableRowOpen;
   htp.tableData( LNG5.BKN_TXT_041, ccolspan=>'2' );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_042 ), cattributes=>pfx.qbground );
   htp.p( '<TD ' || pfx.qcbground || '>' );
   htp.formText( 'p_name', cvalue=>c3rec.billing_name );
   htp.p( '</TD>' );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_038 || ' ( ' || LNG.MASK || ' ):' ), cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'p_date', '15', '10', TO_CHAR( c2rec.date_time, LNG.MASK ) ), cattributes=>pfx.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( lng5.BKN_TXT_045 ), cattributes=>pfx.qbground );
   --
   -- Display the hours
   --
   htp.p( '<TD ' || pfx.qcbground || '>' );
   htp.formSelectOpen( 'p_hour' );

    -- Loop through the hours
    for i_hours in 1..12 loop
       if i_hours = MOD( TO_NUMBER( TO_CHAR( c2rec.date_time, 'HH12' ) ), 12 ) then
          htp.formSelectOption( i_hours, 'SELECTED' );
       else
          htp.formSelectOption( i_hours );
       end if;
    end loop;
    htp.formSelectClose;
    --
    -- Display the minutes
    --
    htp.formSelectOpen( 'p_minute', htf.bold( ':&nbsp;&nbsp;' ) );
    -- Loop through the minutes
    i_minutes := 0;
    while i_minutes < 60 loop
       if i_minutes = TO_NUMBER( TO_CHAR( c2rec.date_time, 'MI' ) ) then
          htp.formSelectOption( TO_CHAR( i_minutes, '09' ), 'SELECTED' );
       else
          htp.formSelectOption( TO_CHAR( i_minutes, '09' ) );
       end if;
       i_minutes := i_minutes + c1rec.time_block;
    end loop;
    htp.formSelectClose;
    --
    -- Display the AM or PM
    --
    htp.formSelectOpen( 'p_meridian', htf.bold( ':&nbsp;&nbsp;' ) );
    if TO_NUMBER( TO_CHAR( c2rec.date_time, 'HH24' ) ) > 12 then
       htp.formSelectOption( 'AM' );
       htp.formSelectOption( 'PM', 'SELECTED' );
    else
       htp.formSelectOption( 'AM', 'SELECTED' );
       htp.formSelectOption( 'PM' );
    end if;
    htp.formSelectClose;
   htp.p( '</TD>' );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_036 ), cattributes=>pfx.qbground );
   htp.p( '<TD ' || pfx.qcbground || '>' );
   htp.formText( 'p_groupsize', '3', '3', c2rec.num_of_students );
   htp.p( '</TD>' );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( lng.CST_TXT_108 ), cattributes=>pfx.qbground );
   htp.p( '<TD ' || pfx.qcbground || '>' );
   htp.formText( 'p_phone', '25', '25', c3rec.contact_phone );
   htp.p( '</TD>' );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( lng.GLB_TXT_066 ), cattributes=>pfx.qbground );
   htp.p( '<TD ' || pfx.qcbground || '>' );
   htp.formTextArea( 'p_details', 5, 40 );
   htp.p( '</TD>' );
   htp.tableRowClose;

   htp.tableClose;

   htp.formImage( 'pCancel', DECS.IMAGE_LOCATION || 'booking/cancel.gif', cattributes=>'alt="' || LNG5.BKN_TXT_116 || '" title="' || LNG5.BKN_TXT_116 || '" border="0"' );
   htp.formImage( 'pSend', DECS.IMAGE_LOCATION || 'booking/send.gif', cattributes=>'alt="' || LNG4.AHC_TXT_342 || '" title="' || LNG4.AHC_TXT_342 || '" border="0"' );
   htp.p( '</CENTER>' );

   dapi.pageClose;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'CONTACT_AWM_STAFF', errmsg=>sqlerrm );
end contact_awm_staff;

procedure accept_contact_awm(
  surl varchar2,                                 -- Secure URL
  acid integer default null,                     -- Account ID
  p_name varchar2,                               -- Contact name
  p_date varchar2,                               -- Date of visit
  p_hour varchar2,                               -- Selected hour of visit
  p_minute varchar2,                             -- Selected minute of visit
  p_meridian varchar2,                           -- AM or PM
  p_groupsize varchar2,                          -- Number of visitors
  p_details varchar2,                            -- Any details or remarks by the visitor
  p_phone varchar2,                              -- Phone number
  pCancel varchar2 default null,                 -- If not null then the user clicked cancel button
  pSend varchar2 default null,                   -- If not null then th user clicked the send button
  rurl varchar2 default null )                    -- Return URL
as
   -- Fetch calendar settings
   cursor c0( lSessionId integer ) is select booking_id from booking where session_id = lSessionId and status = LNG5.BKN_TXT_004;
   cursor c1( caid integer ) is
      select
         c.calendar_id calid,
         start_time,
         end_time,
         time_block,
         date_format,
         days_in_view,
         name_to_contact,
         phone_to_contact,
         email_to_contact,
         fax_to_contact,
         addr_name,
         addr_name2,
         addr_street,
         addr_city,
         addr_pcode
      from
         calendar c,
         calendar_map cm
      where
         c.calendar_id = cm.calendar_id and
         cm.aid = ( select aid from customer_profile where profile_id = caid );

   cursor c2( csid integer ) is
      select
         date_time
      from
         booking
      where
         session_id = csid and status = LNG5.BKN_TXT_004;

   c0rec 		c0%ROWTYPE;
   c1rec 		c1%ROWTYPE;
   c2rec 		c2%ROWTYPE;
   gcode		GLBX.MYARRAY;
   gparam	  	GLBX.MYARRAY;
   lSessionId  		integer;
   sentOk   		boolean := FALSE;
   rTheme   		theme%ROWTYPE;
   email_sendto 	varchar2( 100 );

begin
   if not dapi.init( surl, 'BKN.ACCEPT_CONTACT_AWM', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   lSessionId := dapi.getSessionid;
   if not bookingActive( lSessionId ) then
      bookingNotActive( surl, acid );
      return;
   end if;
   if pSend is not null then
      open c0( lSessionId );
      fetch c0 into c0rec;
      close c0;
      if send_email( surl, acid, c0rec.booking_id, LNG5.BKN_TXT_060, email_sendto ) then commit; else rollback; end if;
      update booking
         set status = LNG5.BKN_TXT_060
         where session_id = lSessionId and status = LNG5.BKN_TXT_004;
      commit;
      open c1( acid );
      fetch c1 into c1rec;
      close c1;
      gcode( 1 )  := 'NAME';
      gparam( 1 ) := p_name;
      gcode( 2 )  := 'PREFERRED_DATE';
      gparam( 2 ) := p_date;
      gcode( 3 )  := 'PREFERRED_TIME';
      gparam( 3 ) := p_hour || ':' || p_minute || p_meridian;
      gcode( 4 )  := 'GROUPSIZE';
      gparam( 4 ) := p_groupsize;
      gcode( 5 )  := 'PHONENUMBER';
      gparam( 5 ) := p_phone;
      gcode( 6 )  := 'DETAILS';
      gparam( 6 ) := p_details;
      begin
         glbx.send( gcode, gparam, 'request_for_booking.tmp', c1rec.email_to_contact, 'Booking request', nvl(glbx.extract_master_parameter( 'BOOKING_MAIL_FROM' ),glbx.extract_master_parameter( 'MAIL_FROM' )), scode=>'BK1' );
         sentOk := TRUE;
      exception when others then sentOk := FALSE;
      end;
   elsif pCancel is not null then
      sentOk := FALSE;
      open c2( lSessionId );
      fetch c2 into c2rec;
      close c2;
      begin
         execute immediate rurl;
      exception when others then null;
      end;
   end if;
   if sentOk then
      dapi.pageOpen;
      htp.p( LNG5.BKN_TXT_147 || c1rec.email_to_contact );
      dapi.pageClose;
   end if;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'ACCEPT_CONTACT_AWM', errmsg=>sqlerrm );
end accept_contact_awm;

/* Screen name: BKN003 */
procedure school_details(
  surl varchar2,                                 -- Secure URl
  acid integer default null,                     -- Account ID
  errText varchar2 default null,                 -- Error Text to be displayed
  pContactName varchar2 default null,            -- initial contact name
  pContactEmail varchar2 default null,           -- inital contact email
  pYearFrom varchar2 default null,               -- initial year from
  pYearTo varchar2 default null,                 -- initial year to
  pNumberOfAdults varchar2 default null )         -- initial number of adults
as
   cursor c2( cprofile_id integer, cltype varchar2 ) is
      select cc.billing_name billing_name,
             cc.billing_street billing_street,
             cc.billing_suburb billing_suburb,
             cc.billing_postcode billing_postcode,
             cc.billing_state billing_state,
             cc.billing_email billing_email
      from customer_contact cc
      where cc.aid = cprofile_id and
            login_type = cltype;
   cursor c3( cprofile_id integer ) is
      select aid
      from customer_profile
      where profile_id = cprofile_id;
   cursor c4( cprofid integer ) is
      select adult_student_ratio asr
      from school_booking_prefs
      where std_profile_aid = ( select aid from customer_profile where profile_id = cprofid ) and
            std_profile_pid = ( select pid from customer_profile where profile_id = cprofid );

   c1rec booking%ROWTYPE;
   c2rec c2%ROWTYPE;
   c4rec c4%ROWTYPE;
   lSessionId integer;         -- Session ID
   lAccountId integer;         -- Account ID
   lOwnerId   integer;
   lUserType  varchar2( 100 );   -- Account user type
   lLoginType varchar2( 100 );   -- Account user type
   pfx        theme%ROWTYPE;   -- Theme Record
begin
   if not dapi.init( surl, 'BKN.SCHOOL_DETAILS', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   lSessionId := dapi.getSessionid;
   lAccountId := dapi.getAccountId;
   lUserType  := dapi.getUserType;
   lLoginType := dapi.getLoginType;
   pfx := dapi.getLFRecord;
   if not bookingActive( lSessionId, c1rec ) then
      bookingNotActive( surl, acid );
      return;
   end if;
   dapi.setExternalStyleSheet( BKN_STYLESHEET  );
   -- dapi.setTitle( getTitle( c1rec.booking_id ) );
   dapi.pageOpen;
   htp.comment( 'Screen name: BKN003' );
   htp.p( '<script type="text/javascript" src="' || BKN_TOPSCRIPT || '"></script>' );
   htp.p( '<div class="bodytext">' );
   htp.p( '<script type="text/javascript">
      <!--
      function submitForm(cmd)
      {
        document.details.pSelectSchool.value = cmd;
        document.details.submit();
      }
      // End Javascript -->
      </script>' );
   showProgress( 3, c1rec.booking_id );
   open c3( lAccountId );
   fetch c3 into lOwnerId;
   close c3;
   -- htp.p( '<center>' );
   --htp.bold( 'XX:' || c1rec.school_id  || ':' || c1rec.school_login_type ); htp.nl;
   if c1rec.school_id > 0 then
      open c2( c1rec.school_id, c1rec.school_login_type );
      fetch c2 into c2rec;
      close c2;
   end if;
   htp.formOpen( 'bkn.accept_school_details', cattributes=>'name="details"' );
   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   htp.formHidden( 'p_contact_phone', null );
   htp.formHidden( 'p_contact_fax', null );
   htp.formHidden( 'pSelectSchool', null );
   htp.header( 2, LNG5.BKN_TXT_174 );
   if errText is not null then
      htp.header( 2, errText, cattributes=>'class="ERROR"' );
   end if;
   htp.tableOpen( cattributes=>'border="0" cellpadding="4" cellspacing="0"' );
   -- Visiting details
   htp.tableRowOpen;
   htp.tableHeader( LNG5.BKN_TXT_010, ccolspan=>'2', cattributes=>
                    ' style="font-size: 11pt; text-align: left;"' );
   htp.tableRowClose;
   -- School details
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'School:' ), cattributes=>'align="right" ' ||
                  'valign="top" style="text-align: right"' ); -- || pfx.qbground );
   if lUserType = 'T' then
      htp.tableData( htf.anchor2( 'javascript:submitForm(''SELECT SCHOOL'')',
                                  LNG5.BKN_TXT_040 ) ||
                     htf.nl || c2rec.billing_name || htf.nl ||
                     c2rec.billing_street || htf.nl || c2rec.billing_suburb ||
                     ' ' || c2rec.billing_state || htf.nl || c2rec.billing_postcode ||
                     htf.nl || c2rec.billing_email,
                     cattributes=>pfx.qcbground );
   else
      htp.p( '<TD ' || pfx.qcbground || '>' );
      htp.p( c2rec.billing_name || htf.nl ||
            c2rec.billing_street || htf.nl ||
            c2rec.billing_suburb || ' ' || c2rec.billing_state || htf.nl ||
            c2rec.billing_postcode );
      if c2rec.billing_email is not null then htp.p( htf.nl || c2rec.billing_email ); end if;
      htp.p( '</TD>' );
   end if;
   htp.tableRowClose;
   -- Date of visit
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Date:' ), cattributes=>'style="text-align: right" ' ||
                  'valign="top"' ); --, cattributes=>pfx.qbground );
   htp.tableData( TO_CHAR( c1rec.date_time, LNG.MASK ), cattributes=>pfx.qcbground );
   htp.tableRowClose;
   -- Time of arrival
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Time:' ), cattributes=>'style="text-align: right" ' ||
                  'valign="top"' ); --, cattributes=>pfx.qbground );
   htp.tableData( TO_CHAR( c1rec.date_time, LNG.TSMASK_ONLY ), cattributes=>pfx.qcbground );
   htp.tableRowClose;
   -- Number of students
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Number of students:' ), cattributes=>'style="text-align: right" ' ||
                  'valign="top"' ); --, cattributes=>pfx.qbground );
   htp.tableData( c1rec.num_of_students, cattributes=>pfx.qcbground );
   htp.tableRowClose;
   -- Year level from to
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Year level*:' ), cattributes=>'style="text-align: right" ' ||
                  'valign="top"' ); --, cattributes=>pfx.qbground );
   htp.tableData( getYearLevel( 'p_school_year_from', SUBSTR( c1rec.school_year, 1, INSTR( c1rec.school_year, '-' )-1 ) ) || ' to '  || getYearLevel( 'p_school_year_to', SUBSTR( c1rec.school_year, INSTR( c1rec.school_year, '-' )+1, LENGTH( c1rec.school_year ) ) ) );
   htp.tableRowClose;
   -- Number of adults
   open c4( lAccountId );
   fetch c4 into c4rec;
   close c4;
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Number of adults*:' ), cattributes=>'style="text-align: right" ' ||
                  'valign="top"' ); --, cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'P_num_of_adults', cvalue=>NVL( c1rec.num_of_adults, TO_NUMBER( pNumberOfAdults ) ) ) || ' (we request 1 adult for every ' || ABS( c4rec.asr ) || ' students)', cattributes=>pfx.qcbground );
   htp.tableRowClose;
   -- Special requirements
   htp.tableRowOpen( cvalign=>'top' );
   htp.tableData( htf.bold( 'Comments or special needs?:' ), cattributes=>'style="text-align: right" ' ||
                  'valign="top"' ); --, cattributes=>pfx.qbground );
   htp.tableData( htf.formTextAreaOpen( 'P_requirements', 4, 40 ) || c1rec.requirements || htf.formTextAreaClose, cattributes=>pfx.qcbground );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableHeader( htf.bold( LNG5.BKN_TXT_013 ), ccolspan=>'2', cattributes=>
                    ' style="font-size: 11pt; text-align: left;"' );
   htp.tableRowClose;
   -- Teacher name
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Name*:' ), cattributes=>'style="text-align: right" ' ||
                  'valign="top"' ); --, cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'P_contact_person', cvalue=>NVL( c1rec.contact_person, pContactName ) ), cattributes=>pfx.qcbground );
   htp.tableRowClose;
   -- Teacher email
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Email address*:' ), cattributes=>'style="text-align: right" ' ||
                  'valign="top"' ); -- , cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'P_contact_email', cvalue=>NVL( c1rec.contact_email, pContactEmail ) ), cattributes=>pfx.qcbground );
   htp.tableRowClose;
   -- Submit button
   htp.tableRowOpen;
   htp.tableData( '&nbsp;' );
   htp.tableData( htf.formImage( 'pNextStep', DECS.IMAGE_LOCATION || 'booking/nstep.gif', cattributes=>'alt="' || LNG5.BKN_TXT_115 || '" title="' || LNG5.BKN_TXT_115 || '" border="0"' ));
   htp.tableRowClose;
   htp.tableClose;
   htp.formClose;
   htp.nl;
   htp.p( cal.getFooter( c1rec.calendar_id ) );
   htp.p( '<script type="text/javascript">
      <!--
      document.details.P_contact_person.select( );
      document.details.P_contact_person.focus( );
      // End Javascript -->
      </script> ' );
   htp.p( '</div>' );
   htp.p( '<script type="text/javascript" src="' || BKN_BOTTOMSCRIPT || '"></script>' );
   dapi.pageClose;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'SCHOOL_DETAILS', errmsg=>sqlerrm );
end school_details;

procedure accept_school_details( surl varchar2, acid integer default null,
                                 P_contact_person varchar2, P_contact_phone varchar2,
                                 P_contact_fax varchar2, P_contact_email varchar2,
                                 P_school_year_from varchar2, P_school_year_to varchar2,
                                 P_num_of_adults varchar2, P_requirements varchar2,
                                 pPreviousStep varchar2 default null,
                                 pCancel varchar2 default null,
                                 pNextStep varchar2 default null,
                                 pSelectSchool varchar2 default null )
as
   cursor c0( csid integer ) is
      select booking_id, school_id, date_time, organised, num_of_students
      from booking
      where session_id = csid and status = LNG5.BKN_TXT_004;
   cursor c1( cprofid integer ) is
      select adult_student_ratio asr
      from school_booking_prefs
      where std_profile_aid = ( select aid
                                from customer_profile
                                where profile_id = cprofid )
            and
            std_profile_pid = ( select pid
                                from customer_profile
                                where profile_id = cprofid );
   cursor c3( cprofile_id integer ) is
      select aid
      from customer_profile
      where profile_id = cprofile_id;

   -- Exceptions
   EGENERAL Exception;
   EMPTY_FIELDS Exception;
   -- Work variables
   c0rec c0%ROWTYPE;
   c1rec c1%ROWTYPE;
   lSessionId integer;                           -- Session ID
   lAccountId integer;                           -- Account ID
   lOwnerId integer;
   formattedText varchar2( 2000 );               -- Censored text
   msg varchar2( 1000 ) := null;                 -- Error message to return to calling program
   lBookingType integer;
   lNumOfAdults integer;
   lSchoolYearTo varchar2( 2 );
   lSchoolYearFrom varchar2( 2 );
begin
   if not dapi.init( surl, 'BKN.ACCEPT_SCHOOL_DETAILS', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   lSessionId := dapi.getSessionId;
   lAccountId := dapi.getAccountId;
   if not bookingActive( lSessionId ) then
      bookingNotActive( surl, acid );
      return;
   end if;
   begin
      lNumOfAdults := TO_NUMBER( P_num_of_adults );
   exception when others then
      msg := msg || LNG5.BKN_TXT_180;
      raise EGENERAL;
   end;
   open c0( lSessionId );
   fetch c0 into c0rec;
   close c0;
   open c3( lAccountId );
   fetch c3 into lOwnerId;
   close c3;
   formattedText := glbx.censor( P_requirements, 2000, TRUE );

   if ( P_school_year_from = '?' ) AND ( p_school_year_to != '?' ) then
      lSchoolYearFrom := p_school_year_to;
   else
      lSchoolYearFrom := P_school_year_from;
   end if;

   if p_school_year_to = '?' then
      lSchoolYearTo := P_school_year_from;
   else
      lSchoolYearTo := p_school_year_to;
   end if;

   if ( pNextStep is not null ) or ( pPreviousStep is not null ) OR
      ( pSelectSchool is not null ) then
      update booking set
         contact_person = P_contact_person,
         contact_phone  = P_contact_phone,
         contact_fax    = P_contact_fax,
         contact_email  = P_contact_email,
         school_year    = lSchoolYearFrom || '-' || lSchoolYearTo,
         num_of_adults  = lNumOfAdults,
         requirements   = formattedText,
         last_step = '3'
      where session_id = lSessionId and status = LNG5.BKN_TXT_004;
      commit;
   end if;
   if pNextStep is not null then
      --
      -- check if the required fields have been populated
      --
      if P_contact_person is null then
         msg := msg || '<br/>' || LNG5.BKN_TXT_181;
      end if;
      if P_contact_email is null then
         msg := msg || '<br/>' || LNG5.BKN_TXT_182;
      end if;
      if c0rec.school_id is null then
         msg := msg || '<br/>' || 'Please select visiting school. If the school is not listed, contact the Bookings Officer';
      end if;
      if lSchoolYearFrom = '?' then
         msg := msg || '<br/>' || 'Please select a year level';
      end if;
      if lNumOfAdults is null then
         msg := msg || '<br/>' || 'Please specify the number of adults';
      end if;
      open c1( lAccountId );
      fetch c1 into c1rec;
      close c1;
      if NVL( lNumOfAdults, 0 ) < ROUND( c0rec.num_of_students / c1rec.asr ) then
         msg := msg || '<br/>' ||
                REPLACE( LNG5.BKN_TXT_184, '<NUMBER_OF_ADULTS>',
                         TO_CHAR( ROUND( c0rec.num_of_students / c1rec.asr ) ) );
      end if;
      if msg is not null then
         raise EMPTY_FIELDS;
      end if;
      -- If the booking is not part of an organised tour, skip to program details
      lBookingType := getBookingType( c0rec.booking_id );
      if ( lBookingType = BOOKING_TYPE_1 ) or
         ( lBookingType = BOOKING_TYPE_3 ) then
         program_details( surl, acid );
      elsif ( lBookingType = BOOKING_TYPE_2 ) or
            ( lBookingType = BOOKING_TYPE_4 ) then
         check_details( surl, acid );
      end if;
   elsif pPreviousStep is not null then
      show_calendar( surl, acid, TO_CHAR( c0rec.date_time, LNG.TSMASK ) );
   elsif pCancel is not null then
      cancelBooking( surl, acid );
   elsif pSelectSchool is not null then
      scl.mng_booking_profiles( surl=>surl, acid=>lOwnerId, user_type=>'E',
                                pfunctionality=>SCL.SELECTIONGUEST,
                                bid=>c0rec.booking_id );
   end if;
exception
   when EMPTY_FIELDS then
      school_details( surl, acid, msg );
   when EGENERAL then
      school_details( surl, acid, msg, p_contact_person, p_contact_email, p_school_year_from, p_school_year_to, lNumOfAdults );
   when others then
      glbx.error_details( PACKAGE_NAME, 'ACCEPT_SCHOOL_DETAILS', errmsg=>sqlerrm );
end accept_school_details;

/* Screen name: BKN004 */
procedure program_details(
  surl varchar2,                                 -- Secure URL
  acid integer default null,                     -- Account ID
  pErrorText varchar2 default null )                           -- Error message
as
   cursor c1( csid integer, cpid integer ) is
      select num_of_visitors is_positive
      from booked_programs
      where booking_id = ( select booking_id
                           from booking
                           where session_id = csid and status = LNG5.BKN_TXT_004 )
            and
            program_id = cpid;
   -- Retrieve information about schools
   cursor c3( ccid integer ) is
      select *
      from customer_contact
      where aid = ccid;
   -- Retrieve information about schools
   cursor c4( csid integer ) is
      select *
      from customer_contact
      where aid = csid;
   -- Retrieve attached programs
   cursor c5( cbid integer ) is
      select p.program_obj.program_name program_name,
             b.num_of_visitors num_of_visitors
      from umo p,
           booked_programs b
      where b.booking_id = cbid and
            p.umo_id = b.program_id;
   -- Retrieve attached workbooks
   cursor c6( cbid integer ) is
      select w.program_obj.program_name workbook_name
      from umo w, booked_workbooks b
      where b.booking_id = cbid and w.umo_id = b.workbook_id;
   cursor c7( selected_date date ) is
      select um.umo_id program_id,
             um.program_obj.program_name program_name,
             um.program_obj.cost_per_head cost_per_head,
             um.program_obj.url           url,
             um.program_obj.program_description program_description,
             um.program_obj.school_year school_year
      from umo um
      where ( um.program_obj.program_type = LNG5.PRG_TXT_110 ) and
            ( selected_date <= um.expire_date );
   cursor c8( selected_date date ) is
      select um.umo_id workbook_id,
             um.program_obj.program_name workbook_name,
             um.program_obj.cost_per_head cost_per_head,
             um.program_obj.url           url
      from umo um
      where ( um.program_obj.program_type = LNG5.PRG_TXT_111 ) and
            ( selected_date <= um.expire_date );
   cursor c9( csid integer, cpid integer ) is
      select count( 'x' ) is_positive
      from booked_workbooks
      where booking_id = ( select booking_id
                           from booking
                           where session_id = csid and status = LNG5.BKN_TXT_004 )
            and
            workbook_id = cpid;

   c1rec c1%ROWTYPE;
   c2rec booking%ROWTYPE;
   c3rec c3%ROWTYPE;
   c4rec c4%ROWTYPE;
   c5rec c5%ROWTYPE;
   c6rec c6%ROWTYPE;
   c9rec c9%ROWTYPE;
   lSessionId integer;            -- Session ID
   pfx  theme%ROWTYPE;      -- Theme record
   l_zero  boolean;
   lFromYear varchar2( 2 );
   lToYear varchar2( 2 );
   lCheckFromYear varchar2( 2 );
   lCheckToYear varchar2( 2 );
   iFromYear pls_integer;
   iToYear pls_integer;
   iCheckFromYear pls_integer;
   iCheckToYear pls_integer;
   lDoShow BOOLEAN;
begin
   if not dapi.init( surl, 'BKN.PROGRAM_DETAILS', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   lSessionId := dapi.getSessionid;
   pfx := dapi.getLFRecord;
   if not bookingActive( lSessionId, c2rec ) then
      bookingNotActive( surl, acid );
      return;
   end if;
   dapi.setExternalStyleSheet( BKN_STYLESHEET  );
   -- dapi.setTitle( getTitle( c2rec.booking_id ) );
   dapi.pageOpen;
   htp.comment( 'Screen name: BKN004' );
   htp.p( '<script type="text/javascript" src="' || BKN_TOPSCRIPT || '"></script>' );
   htp.p( '<div class="bodytext">' );
   showProgress( 4, c2rec.booking_id );
   -- htp.p( '<center>' );
   htp.header( 2, LNG5.BKN_TXT_175 );
   htp.nl;
   htp.p( REPLACE( LNG5.BKN_TXT_176, '<NUMBER_OF_STUDENTS>', c2rec.num_of_students ) );
   if pErrorText is not null then
      htp.header( 2, pErrorText, cattributes=>'class="ERROR"' );
   end if;
   htp.formOpen( 'bkn.accept_program_details', cattributes=>'name="details"' );
   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   htp.formHidden( 'P1', null );
   htp.formHidden( 'P2', null );
   htp.formHidden( 'P3', null );
   htp.formHidden( 'P4', null );

   htp.tableOpen( cattributes=>'cellpadding="2" cellspacing="2" border="0"' );
      htp.tableRowOpen( cvalign=>'top' );
         htp.p( '<td align="center">' );  -- t2
            if getVisitTypeClass( c2rec.visit_type ) = LNG5.BKN_TXT_002 then
               --
               -- Paid program, list available programs
               --
               htp.tableOpen( cattributes=>'cellpadding="2" cellspacing="2" border="0"' );
                  --
                  -- Display headers
                  --
                  htp.tableRowOpen;
                     htp.tableHeader( htf.bold( LNG5.BKN_TXT_152 ), cattributes=>pfx.qbground );
                     htp.tableHeader( htf.bold( lng5.BKN_TXT_151 ), cattributes=>pfx.qbground );
                     htp.tableHeader( htf.bold( lng5.BKN_TXT_153 ), cattributes=>pfx.qbground );
                  htp.tableRowClose;
                  --
                  -- Display programs
                  --
                  lFromYear := UPPER( SUBSTR( c2rec.school_year, 1, INSTR( c2rec.school_year, '-' ) -1 ) );
                  if lFromYear = 'K' then
                     lFromYear := '0';
                  end if;
                  iFromYear := TO_NUMBER( lFromYear );
                  lToYear := SUBSTR( c2rec.school_year, INSTR( c2rec.school_year, '-' )+1 );
                  if lToYear = 'K' then
                     lToYear := '0';
                  end if;
                  iToYear := TO_NUMBER( lToYear );
                  for c7rec in c7( c2rec.date_time ) loop
                     lCheckFromYear := SUBSTR( c7rec.school_year, 1, INSTR( c7rec.school_year, '-' )-1 );
                     if lCheckFromYear = 'K' then
                        lCheckFromYear := '0';
                     end if;
                     iCheckFromYear := TO_NUMBER( lCheckFromYear );
                     lCheckToYear := SUBSTR( c7rec.school_year, INSTR( c7rec.school_year, '-' )+1 );
                     if lCheckToYear = 'K' then
                        lCheckToYear := '0';
                     end if;
                     iCheckToYear := TO_NUMBER( lCheckToYear );
                     lDoShow := TRUE;
                     -- ( 1 ) The chosen year from is lower than program year from AND chosen year to is lower than program year from
                     if ( iFromYear < iCheckFromYear ) AND ( iToYear < iCheckFromYear ) then
                        htp.comment( 'sit 1' );
                        lDoShow := FALSE;
                     -- ( 2 ) The chosen year from is higher than program year to and chosen year to is higher than program year to
                     elsif ( iFromYear > iCheckToYear ) AND ( iToYear > iCheckToYear ) then
                        htp.comment( 'sit 2' );
                        lDoShow := FALSE;
                     end if;
                     htp.comment( 'Chosen: ' || c2rec.school_year || '   actual: ' || c7rec.school_year );
                     htp.comment( 'lfrom ' || lFromYear || ' lto ' || lToYear );
                     htp.comment( 'lcheckfrom ' || lCheckFromYear || ' lcheckto ' || lCheckToYear );
                     if lDoShow then
                        htp.tableRowOpen;
                           open c1( lSessionId, c7rec.program_id );
                           fetch c1 into c1rec;
                           l_zero := c1%NOTFOUND;
                           close c1;
                           if l_zero then
                              htp.tableData( htf.formText( 'P1', 3, 3 ) || htf.formHidden( 'P2', c7rec.program_id ), cattributes=>pfx.qcbground || ' valign="top" align="center"' );
                           else
                              htp.tableData( htf.formText( 'P1', 3, 3, c1rec.is_positive ) || htf.formHidden( 'P2', c7rec.program_id ), cattributes=>pfx.qcbground || ' valign="top" align="center"' );
                           end if;
                           htp.tableData( htf.bold( c7rec.program_name ) || '&nbsp;&nbsp;&nbsp;&nbsp;' || htf.anchor( c7rec.url, 'more info', cattributes=>'target="_blank"' ) || '<br><br>' || c7rec.program_description, cattributes=>pfx.qcbground || ' valign="top"' );
                           htp.tableData( c7rec.school_year, cattributes=>'valign="top"' );
                        htp.tableRowClose;
                     end if; /* lDoShow */
                  end loop;
               htp.tableRowOpen;
               htp.tableData( '&nbsp;' );
               htp.tableData( htf.formImage( 'pNextStep', DECS.IMAGE_LOCATION || 'booking/nstep.gif',
                                             cattributes=>'alt="' || LNG5.BKN_TXT_115 || '" title="' ||
                                             LNG5.BKN_TXT_115 || '" border="0"' ) );
               htp.tableRowClose;
               htp.tableClose;
            elsif getVisitTypeClass( c2rec.visit_type ) = LNG5.BKN_TXT_003 then
               htp.tableOpen( cattributes=>TABLE_ATTS );
                  --
                  -- Display headers, list available workbooks
                  --
                  htp.tableRowOpen;
                     htp.tableData( htf.bold( LNG5.BKN_TXT_062 ), cattributes=>pfx.qbground );
                     htp.tableData( htf.bold( lng5.WRB_TXT_101 ), cattributes=>pfx.qbground );
                     htp.tableData( htf.bold( lng5.PRG_TXT_104 ), cattributes=>pfx.qbground );
                  htp.tableRowClose;

                  --
                  -- List workbooks
                  --
                  for c8rec in c8( c2rec.date_time ) loop
                     htp.tableRowOpen;
                        open c9( lSessionId, c8rec.workbook_id );
                        fetch c9 into c9rec;
                        close c9;
                        if c9rec.is_positive > 0 then
                           htp.tableData( htf.formCheckBox( 'P3', c8rec.workbook_id, 'CHECKED' ) || htf.formHidden( 'P4', c8rec.workbook_id ), cattributes=>pfx.qcbground );
                        else
                           htp.tableData( htf.formCheckBox( 'P3', c8rec.workbook_id ) || htf.formHidden( 'P4', c8rec.workbook_id ), cattributes=>pfx.qcbground );
                        end if;
                        htp.tableData( htf.anchor( c8rec.url, c8rec.workbook_name, cattributes=>'target="_blank"' ), cattributes=>pfx.qcbground );
                        htp.tableData( TO_CHAR( c8rec.cost_per_head, lng.MONEY_FORMAT ), calign=>'RIGHT', cattributes=>pfx.qcbground );
                     htp.tableRowClose;
                  end loop;
               htp.tableClose;
            end if;
         htp.p( '</td>' );
      htp.tableRowClose;
   htp.tableClose;
   -- Navigation buttons
   -- htp.formImage( 'pPreviousStep', DECS.IMAGE_LOCATION || 'booking/pstep.gif', cattributes=>'alt="' || LNG5.BKN_TXT_114 || '" title="' || LNG5.BKN_TXT_114 || '" border="0"' );
   -- htp.formImage( 'pCancel', DECS.IMAGE_LOCATION || 'booking/cancel.gif', cattributes=>'alt="' || LNG5.BKN_TXT_116 || '" title="' || LNG5.BKN_TXT_116 || '" border="0"' );
   htp.formClose;
   htp.p( cal.getFooter( c2rec.calendar_id ) );
   -- htp.p( '</center>' );
   htp.p( '</div>' );
   htp.p( '<script type="text/javascript" src="' || BKN_BOTTOMSCRIPT || '"></script>' );
   dapi.pageClose;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'PROGRAM_DETAILS', errmsg=>sqlerrm );
end program_details;

procedure accept_program_details(
  surl varchar2,                                 -- Secure URL
  acid integer default null,                     -- Account ID
  p1 glbx.myArray,                               -- List of programs
  p2 glbx.myArray,                               -- List of selected programs
  p3 glbx.myArray,                               -- List of workbooks
  p4 glbx.myArray,                               -- List of selected workbooks
  pPreviousStep varchar2 default null,           -- If not null then the user clicked previous step
  pCancel varchar2 default null,                 -- If not null then the user clicked cancel
  pNextStep varchar2 default null )               -- If not null then the user clicked next step
as
   cursor c0( csid integer ) is
   select
      booking_id,
      organised,
      visit_type,
      num_of_students
   from
      booking
   where
      session_id = csid and status = LNG5.BKN_TXT_004;
   c0rec c0%ROWTYPE;

   cursor c1( caid integer ) is
   	select
   	   user_type
   	from
   	   customer_contact
   	where
   	   aid = caid;
   c1rec c1%ROWTYPE;

   EGENERAL Exception;

   lSessionId integer;            -- Session ID
   pfx  theme%ROWTYPE;            -- Theme record
   visitors_per_program integer;
   lAskInvoice boolean := FALSE;
   lBookingType integer;
   lNumberOfPrograms integer;
   lTotalChosen integer;
   msg varchar2( 2000 );
begin
   if not dapi.init( surl, 'BKN.ACCEPT_PROGRAM_DETAILS', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   lSessionId := dapi.getSessionid;
   if not bookingActive( lSessionId ) then
      bookingNotActive( surl, acid );
      return;
   end if;
   open c0( lSessionId );
   fetch c0 into c0rec;
   close c0;

   if pNextStep is not null then
      update
         booking
      set
         last_step = '4'
      where
         booking_id = c0rec.booking_id;
      --
      -- Insert chosen programs
      --
      for i in p2.first..p2.last loop
         --
         -- First delete all the attached programs
         --
         if p2( i ) IS NOT NULL then
            delete
            from
               booked_programs
            where
               booking_id = c0rec.booking_id and
               program_id = p2( i );
         end if;
      end loop;
      lTotalChosen := 0;
      for i in p1.first..p1.last loop
         if p1( i ) IS NOT NULL then
            begin
               visitors_per_program := TO_NUMBER( P1( i ) );
            exception when others then
               msg := msg || htf.nl || LNG5.BKN_TXT_179 || ': ' || P1( i );
               visitors_per_program := 0;
            end;
            if visitors_per_program > 0 then
               lTotalChosen := lTotalChosen + visitors_per_program;
            end if;
            insert into booked_programs values( c0rec.booking_id, p2( i ), visitors_per_program );
         end if;
      end loop;
      if lTotalChosen = 0 then
         null;
         -- msg := msg || htf.nl || LNG5.BKN_TXT_185;
      end if;
      if lTotalChosen < c0rec.num_of_students then
         msg := msg || '<br/>' || 'Please allocatate ' || TO_CHAR( c0rec.num_of_students - lTotalChosen ) || ' more student(s)';
      end if;
      if lTotalChosen > c0rec.num_of_students then
         msg := msg || '<br/>' || 'Please do not allocate more than ' || c0rec.num_of_students || ' student(s).';
      end if;
      commit;
      if msg is not null then
         raise EGENERAL;
      end if;
      --
      -- Check if a payment needs to be done
      --
      lBookingType := getBookingType( c0rec.booking_id );
      if lBookingType = BOOKING_TYPE_3 then
         lAskInvoice := ( total_cost( surl, acid, c0rec.booking_id ) != 0 );
      end if;
      if lAskInvoice then
         payment_details( surl, acid );
      else
         bkn.check_details( surl, acid );
      end if;
   elsif pPreviousStep is not null then
      	school_details( surl, acid );
   elsif pCancel is not null then
      cancelBooking( surl, acid );
   end if;
exception
   when EGENERAL then
      program_details( surl, acid, msg );
   when others then
      glbx.error_details( PACKAGE_NAME, 'ACCEPT_PROGRAM_DETAILS', errmsg=>sqlerrm );
end accept_program_details;

/* Screen name: BKN005 */
procedure payment_details(
  surl varchar2,                                 -- Secure URL
  acid integer default null,                     -- Account ID
  errText varchar2 default null )                 -- Error message
as
   cursor c1( cbid integer ) is
      select
         p.program_obj.program_name program_name,
         p.program_obj.cost_per_head cost_per_head
      from
         umo p,
         booked_programs bp
      where
         bp.booking_id = cbid and
         p.umo_id = bp.program_id;

   cursor c2( cbid integer ) is
      select
         w.program_obj.program_name workbook_name,
         w.program_obj.cost_per_head cost_per_head
      from
         umo w,
         booked_workbooks bw
      where
         bw.booking_id = cbid and w.umo_id = bw.workbook_id;
   c2rec c2%ROWTYPE;

   cursor c3( caid integer ) is
      select
         pid
      from
         customer_account
      where
         aid = caid;
   c3rec c3%ROWTYPE;

   c0rec booking%ROWTYPE;
   lSessionId integer;            -- Session ID
   rTheme              theme%ROWTYPE;      -- Theme record
   totalAmount         number;             -- Total of the costs
   programCostPerHead  number;             -- Costs per program per head
   workbookCostPerHead number;             -- Costs per workbook per head
   minimumCharge       number;             -- Minimum to be charged
begin
   if not dapi.init( surl, 'BKN.PAYMENT_DETAILS', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   lSessionId := dapi.getSessionid;
   rTheme := dapi.getLFRecord;
   --
   -- Fetch booking details
   --
   if not bookingActive( lSessionId, c0rec ) then
      bookingNotActive( surl, acid );
      return;
   end if;
   dapi.setExternalStyleSheet( BKN_STYLESHEET  );
   -- dapi.setTitle( getTitle( c0rec.booking_id ) );
   dapi.pageOpen;
   htp.comment( 'Screen name: BKN005' );
   htp.p( '<script type="text/javascript" src="' || BKN_TOPSCRIPT || '"></script>' );
   htp.p( '<div class="bodytext">' );
   showProgress( 5, c0rec.booking_id );
   totalAmount := total_cost( surl, acid, c0rec.booking_id );
   --
   -- Fetch customer account details
   --
   open c3( acid );
   fetch c3 into c3rec;
   close c3;
   minimumCharge  := TO_NUMBER( glbx.photo_pref( c3rec.pid,acid,'MIN_BOOKING_AMT' ), LNG.MONEY_FORMAT );

   if totalAmount < minimumCharge then
      totalAmount := minimumCharge;
   end if;

   htp.p( '<script type="text/javascript">
      <!-- Javascript
      function submitForm( ) {
         document.form1.pNextStep.value = "Next";
         document.form1.submit( );
      }
      // End java script -->
      </script>' );
   -- htp.p( '<CENTER>' );

   if errText is not null then
      htp.p( '<font size="+3" color="#' || rTheme.error_text_colour || '" FACE="' || rTheme.error_text_font || '">'|| errText || '</font>' );
   end if;

   htp.formOpen( 'bkn.accept_payment_details', cattributes=>'NAME="form1"' );
   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   htp.formHidden( 'pPreviousStep', null );
   htp.formHidden( 'pCancel', null );
   htp.formHidden( 'pNextStep', null );

   htp.header( 3, 'Who is paying the invoice?' );
   htp.comment( 'paid by=' || c0rec.paid_by );
   htp.p( '<p>' );
   if c0rec.paid_by = COMPANY_PAYS then
      htp.formRadio( 'creditor', COMPANY_PAYS, 'CHECKED',
                     cattributes=>'name="cbbus" onClick="submitForm( ); return true;"' );
   else
      htp.formRadio( 'creditor', COMPANY_PAYS,
                     cattributes=>'name="cbbus" onClick="submitForm( ); return true;"' );
   end if;
   htp.p( 'Bus company' );
   htp.nl;
   if c0rec.paid_by = SCHOOL_PAYS then
      htp.formRadio( 'creditor', SCHOOL_PAYS, 'CHECKED',
                     cattributes=>'onClick="submitForm( ); return true;"' );
   else
      htp.formRadio( 'creditor', SCHOOL_PAYS,
                     cattributes=>'onClick="submitForm( ); return true;"' );
   end if;
   htp.p( 'School' );
   htp.p( '</p>' );
   /*
   htp.tableOpen( cattributes=>TABLE_ATTS );
   htp.tableRowOpen;
   if c0rec.bus_company_id is null then
      htp.tableData( htf.bold( LNG5.BKN_TXT_065 ), 'CENTER', cattributes=>rTheme.qbground );
      htp.formHidden( 'creditor', '1' );
   else
      htp.tableData( htf.bold( LNG5.BKN_TXT_066 ), 'CENTER', cattributes=>rTheme.qbground );
      htp.tableRowClose;
      htp.tableRowOpen;
      htp.p( '<TD ' || rTheme.qcbground || '>' );
      htp.p( '</TD>' );
   end if;
   htp.tableRowClose;
   htp.tableClose;
   */

   -- Navigation buttons
   htp.formHidden( 'totalAmount', ( ( 1+( glbx.photo_pref( c3rec.pid,acid,'GST' )/100 ) ) * totalAmount ) );
   /*
   htp.formImage( 'pPreviousStep', DECS.IMAGE_LOCATION || 'booking/pstep.gif', cattributes=>'alt="' || LNG5.BKN_TXT_114 || '" title="' || LNG5.BKN_TXT_114 || '" border="0"' );
   htp.formImage( 'pCancel', DECS.IMAGE_LOCATION || 'booking/cancel.gif', cattributes=>'alt="' || LNG5.BKN_TXT_116 || '" title="' || LNG5.BKN_TXT_116 || '" border="0"' );
   htp.formImage( 'pNextStep', DECS.IMAGE_LOCATION || 'booking/nstep.gif', cattributes=>'alt="' || LNG5.BKN_TXT_115 || '" title="' || LNG5.BKN_TXT_115 || '" border="0"' );
   */
   htp.formClose;
   htp.p( cal.getFooter( c0rec.calendar_id ) );
   -- htp.p( '</CENTER>' );
   htp.p( '</div>' );
   htp.p( '<script type="text/javascript" src="' || BKN_BOTTOMSCRIPT || '"></script>' );
   dapi.pageClose;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'PAYMENT_DETAILS', errmsg=>sqlerrm );
end payment_details;

procedure accept_payment_details(
 surl varchar2,                                  -- Secure URL
 acid integer default null,                      -- Account ID
 creditor char default null,                     -- Who is to pay. 1=School pays, 2=Bus company pays
 payment varchar2 default null,                  -- Depricated
 totalAmount varchar2 default null,              -- Total amount to pay
 pPreviousStep varchar2 default null,            -- If not null then the user clicked previous step
 pCancel varchar2 default null,                  -- If not null then the user clicked cancel
 pNextStep varchar2 default null )                -- If not null then the user clicked next step
as
   lSessionId integer;                           -- Session ID
begin
   if not dapi.init( surl, 'BKN.ACCEPT_PAYMENT_DETAILS', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   lSessionId := dapi.getSessionid;
   if not bookingActive( lSessionId ) then
      bookingNotActive( surl, acid );
      return;
   end if;
   if creditor is null then raise INVALID_CREDITOR; end if;
   if pNextStep is not null then
     	--
     	-- Update who is to pay
   	  --
      update
         booking
      set
         paid_by = decode(visit_type,'2',null,creditor),
         total_amount = TO_NUMBER( totalAmount )
      where
         session_id = lSessionId;
      commit;
      check_details( surl, acid );
   elsif pPreviousStep is not null then
      --
      -- Go back to former screen
      --
      program_details( surl, acid );
   elsif pCancel is not null then
     	--
   	  -- Cancel booking
   	  --
      cancelBooking( surl, acid );
   end if;
exception
   when INVALID_CREDITOR then
      payment_details( surl, acid, LNG5.BKN_TXT_186 );
   when others then
      glbx.error_details( PACKAGE_NAME, 'ACCEPT_PAYMENT_DETAILS', errmsg=>sqlerrm );
end accept_payment_details;

/* Screen name: BKN006 */
procedure check_details(
  surl varchar2,                                 -- Secure URL
  acid integer default null )                     -- Account ID
as
   cursor c1( cbid integer ) is
      select
         p.program_obj.program_name program_name,
         p.program_obj.cost_per_head cost_per_head,
         bp.num_of_visitors nov
      from
         umo p, booked_programs bp
      where
         bp.booking_id = cbid and
         p.umo_id = bp.program_id;
   c1rec c1%ROWTYPE;

   cursor c2( cbid integer ) is
      select
         w.program_obj.program_name workbook_name,
         w.program_obj.cost_per_head cost_per_head
      from
         umo w, booked_workbooks bw
      where
         bw.booking_id = cbid and
         w.umo_id = bw.workbook_id;
   c2rec c2%ROWTYPE;

   cursor c3( cprofile_id integer ) is
   select
      cc.billing_name billing_name,
      cc.billing_street billing_street,
      cc.billing_suburb billing_suburb,
      cc.billing_postcode billing_postcode,
      cc.billing_email billing_email,
      cc.billing_phone billing_phone,
      cc.billing_state billing_state
   from
      customer_contact cc
   where
      cc.aid = cprofile_id and
      cc.login_type = 'PROFILE';
   c3rec c3%ROWTYPE;

   cursor c5( cbid integer /*Booking id*/ ) is
   	select
   	   count( 'x' ) amount
   	from
   	   umo p, booked_programs bp
   	where
   	   bp.booking_id = cbid and
   	   p.umo_id = bp.program_id;
   c5rec c5%ROWTYPE;

   cursor c6( cbid integer /*Booking id*/ ) is
   	select
   	   count( 'x' ) amount
   	from
   	   umo p, booked_workbooks bp
   	where
   	   bp.booking_id = cbid and
   	   p.umo_id = bp.workbook_id;
   c6rec c6%ROWTYPE;

   cursor c7( cprofile_id integer ) is
      select
         pid,
         aid
      from
         customer_profile
      where
         profile_id = cprofile_id;
   c7rec c7%ROWTYPE;

   c0rec booking%ROWTYPE;
   lSessionId integer;                           -- Session ID
   lAccountId integer;                           -- Session ID
   lLoginType varchar2( 100 );                     -- Session ID
   lOrderStyleId integer;                        -- ID of the order style
   lOrderStyle order_style%ROWTYPE;              -- Name of the order style
   pfx theme%ROWTYPE;                            -- Theme Record
   lTotalIncGst number;                          -- Total cost including GST
   lTotalExGst number;                           -- Total cost without GST
   lGst number;                           -- Total cost without GST
   b2c_value varchar2( 200 );                      -- Business to Customer value
begin
   if not dapi.init( surl, 'BKN.CHECK_DETAILS', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   lSessionId := dapi.getSessionid;
   lAccountId := dapi.getAccountId;
   lLoginType := dapi.getLoginType;
   pfx := dapi.getLFRecord;
   if not bookingActive( lSessionId, c0rec ) then
      bookingNotActive( surl, acid );
      return;
   end if;
   dapi.setExternalStyleSheet(  BKN_STYLESHEET );
   -- dapi.setTitle( getTitle( c0rec.booking_id ) );
   dapi.pageOpen;
   htp.comment( 'Screen name: BKN006' );
   htp.p( '<script type="text/javascript" src="' || BKN_TOPSCRIPT || '"></script>' );
   htp.p( '<div class="bodytext">' );
   showProgress( 6, c0rec.booking_id );
   --
   -- Calculate total cost
   --
   open c7( lAccountId );
   fetch c7 into c7rec;
   close c7;
   --
   -- Fetch visitor and invoice details
   --
   lTotalExGst := total_cost( surl, acid, c0rec.booking_id );
   lOrderStyleId := glbx.get_order_style( acid, lAccountId, lLoginType, b2c_value );
   lOrderStyle := glbx.get_order_style( lOrderStyleId );
   --lTotalIncGst := lTotalExGst * ( 1 + lOrderStyle.pricing_gst/100 );
   lTotalIncGst := lTotalExGst;
   --lGst := lTotalIncGst - lTotalIncGst * ( 1 + lOrderStyle.pricing_gst/100 )*
   lGst := lTotalIncGst - ((lTotalIncGst * 100) / (100 + lOrderStyle.pricing_gst));

   -- htp.p( '<CENTER>' );
   htp.header( 2, LNG5.BKN_TXT_154 );
   htp.formOpen( 'bkn.accept_check_details', cattributes=>'NAME="details"' );
   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   htp.tableOpen( cattributes=>'border="0" cellpadding="5" cellspacing="0"' );
   --
   -- Display date visit
   --
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Date:' ), cattributes=>'VALIGN="TOP" ' ||
                  'style="text-align: right;"' ); --, cattributes=>pfx.qbground );
   htp.tableData( TO_CHAR( c0rec.date_time, 'Day, dd Month yyyy' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;
   --
   -- Display time of visit
   --
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Time:' ), cattributes=>'VALIGN="TOP" '  ||
                  'style="text-align: right;"'); --, cattributes=>pfx.qbground );
   htp.tableData( TO_CHAR( c0rec.date_time, 'HH:MI PM' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;
   --
   -- Display number of students
   --
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Number of students:' ), cattributes=>'VALIGN="TOP" '  ||
                  'style="text-align: right;"'); --, cattributes=>pfx.qbground );
   htp.tableData( c0rec.num_of_students, cattributes=>pfx.qcbground );
   htp.tableRowClose;
   --
   -- Display number of adults
   --
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Number of adults:' ), cattributes=>'VALIGN="TOP" '  ||
                  'style="text-align: right;"'); --, cattributes=>pfx.qbground );
   htp.tableData( nvl( to_char( c0rec.num_of_adults ), '&nbsp;' ), cattributes=>pfx.qcbground );
   htp.tableRowClose;
   --
   -- Display Year level
   --
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Year level:' ), cattributes=>'VALIGN="TOP" '  ||
                  'style="text-align: right;"'); --, cattributes=>pfx.qbground );
   htp.tableData( c0rec.school_year , cattributes=>pfx.qcbground );
   htp.tableRowClose;
   --
   -- Display booked programs if any
   --
   open c5( c0rec.booking_id );
   fetch c5 into c5rec;
   close c5;
   if ( getVisitTypeClass( c0rec.visit_type ) = LNG5.BKN_TXT_002 ) and ( c5rec.amount > 0 ) then -- Paid program
      htp.tableRowOpen( cvalign=>'TOP' );
      htp.tableData( htf.bold( 'Booked program(s):' ), cattributes=>'VALIGN="TOP" '  ||
                     'style="text-align: right;"'); --, cattributes=>pfx.qbground );
      htp.p( '<TD ' || pfx.qcbground || '>' );
      htp.tableOpen;
      for c1rec in c1( c0rec.booking_id ) loop
         htp.tableRowOpen;
         htp.tableData( c1rec.nov, cattributes=>'valign="top"' );
         htp.tableData( 'x', cattributes=>'valign="top"' );
         htp.tableData( c1rec.program_name, cattributes=>'valign="top"' );
         htp.tableRowClose;
      end loop;
      htp.tableClose;
      htp.p( '</TD>' );
      htp.tableRowClose;
   end if;
   --
   -- Display booked workbooks if any
   --
   open c6( c0rec.booking_id );
   fetch c6 into c6rec;
   close c6;
   if ( c6rec.amount > 0 ) then
      htp.tableRowOpen( cvalign=>'TOP' );
      htp.tableData( htf.bold( LNG5.BKN_TXT_074 ), cattributes=>'VALIGN="TOP" '  ||
                     'style="text-align: right;"'); --, cattributes=>pfx.qbground );
      htp.p( '<TD ' || pfx.qcbground || '>' );
      htp.tableOpen;
      for c2rec in c2( c0rec.booking_id ) loop
         htp.tableRowOpen;
         htp.tableData( c2rec.workbook_name );
         htp.tableRowClose;
      end loop;
      htp.tableClose;
      htp.p( '</TD>' );
      htp.tableRowClose;
   end if;
   --
   -- Display total cost if applicable
   --
   if ( lTotalExGst > 0 ) then
      --
      -- Display total amount excl. GST
      --
      htp.tableRowOpen;
      htp.tableData( htf.bold( 'Total Including GST:' ), cattributes=>'VALIGN="TOP" '  ||
                     'style="text-align: right;"'); --, cattributes=>pfx.qbground );
      htp.tableData( nvl( TO_CHAR( lTotalIncGst, lng.MONEY_FORMAT ), '&nbsp;' ), cattributes=>pfx.qcbground );
      htp.tableRowClose;
      --
      -- Display GST amount
      --
      htp.tableRowOpen;
      htp.tableData( htf.bold( 'GST:' ), cattributes=>'VALIGN="TOP" '  ||
                     'style="text-align: right;"'); --, cattributes=>pfx.qbground );
      htp.tableData( nvl( TO_CHAR( lGst, lng.MONEY_FORMAT ), '&nbsp;' ), cattributes=>pfx.qcbground );
      htp.tableRowClose;
      --
      -- Display total amount incl. GST
      --
      /*
      htp.tableRowOpen;
      htp.tableData( htf.bold( 'Total cost incl. GST:' ), cattributes=>'VALIGN="TOP" '  ||
                     'style="text-align: right;"'); --, cattributes=>pfx.qbground );
      htp.tableData( nvl( TO_CHAR( lTotalIncGst, lng.MONEY_FORMAT ), '&nbsp;' ), cattributes=>pfx.qcbground );
      htp.tableRowClose;
      */
      --
      -- Display who is visiting
      --
      htp.tableRowOpen;
      htp.tableData( htf.bold( 'Who is visiting:' ), cattributes=>'VALIGN="TOP" '  ||
                     'style="text-align: right;"'); --, cattributes=>pfx.qbground );
      open c3( c0rec.school_id );
      fetch c3 into c3rec;
      close c3;
      htp.p( '<TD ' || pfx.qcbground || '>' );
         htp.p( c3rec.billing_name ); htp.nl;
         htp.p( c3rec.billing_street ); htp.nl;
         htp.p( c3rec.billing_suburb || ' ' || c3rec.billing_state || '  ' ||
                c3rec.billing_postcode );
      htp.p( '</TD>' );
      htp.tableRowClose;

      if c0rec.bus_company_id is not null
       then
        htp.tableRowOpen;
        htp.tableData( htf.bold( 'Booked by:' ), cattributes=>'VALIGN="TOP" '  ||
                       'style="text-align: right;"'); --, cattributes=>pfx.qbground );
        open c3( c0rec.bus_company_id );
        fetch c3 into c3rec;
        close c3;
        htp.p( '<TD ' || pfx.qcbground || '>' );
           htp.p( c3rec.billing_name ); htp.nl;
           htp.p( c3rec.billing_street ); htp.nl;
           htp.p( c3rec.billing_suburb || ' ' || c3rec.billing_state || '  ' ||
                  c3rec.billing_postcode );
        htp.p( '</TD>' );
        htp.tableRowClose;
      end if;
      --
      -- Display who will pay if applicable
      --
      htp.tableRowOpen;
      htp.tableData( htf.bold( 'Invoice to:' ),
                     cattributes=>'VALIGN="TOP" '  || 'style="text-align: right;"');
      if c0rec.paid_by = 'E' then
         --
         -- Paid by school
         --
         open c3( c0rec.school_id );
         fetch c3 into c3rec;
         close c3;
         htp.p( '<TD ' || pfx.qcbground || ' nowrap>' );
         htp.p( c3rec.billing_name ); htp.nl;
         htp.p( c3rec.billing_street ); htp.nl;
         htp.p( c3rec.billing_suburb || ' ' || c3rec.billing_state || '  ' ||
                c3rec.billing_postcode );
         htp.p( '</TD>' );
      elsif c0rec.paid_by = 'T' then
       --
         -- Paid by bus company
         --
         open c3( c0rec.bus_company_id );
         fetch c3 into c3rec;
         close c3;
         htp.p( '<TD ' || pfx.qcbground || ' nowrap>' );
         htp.p( c3rec.billing_name ); htp.nl;
         htp.p( c3rec.billing_street ); htp.nl;
         htp.p( c3rec.billing_suburb || ' ' || c3rec.billing_state || '  ' ||
                c3rec.billing_postcode );
         htp.p( '</TD>' );
      end if;
      htp.tableRowClose;

   else

      --
      -- Display who is visiting
      --
      htp.tableRowOpen;
      htp.tableData( htf.bold( 'Who is visiting:' ), cattributes=>'VALIGN="TOP" '  ||
                     'style="text-align: right;"'); --, cattributes=>pfx.qbground );
      open c3( c0rec.school_id );
      fetch c3 into c3rec;
      close c3;
      htp.p( '<TD ' || pfx.qcbground || '>' );
         htp.p( c3rec.billing_name ); htp.nl;
         htp.p( c3rec.billing_street ); htp.nl;
         htp.p( c3rec.billing_suburb || ' ' || c3rec.billing_state || '  ' ||
                c3rec.billing_postcode );
      htp.p( '</TD>' );
      htp.tableRowClose;
      if c0rec.bus_company_id is not null
       then
        htp.tableRowOpen;
        htp.tableData( htf.bold( 'Booked by:' ), cattributes=>'VALIGN="TOP" '  ||
                       'style="text-align: right;"'); --, cattributes=>pfx.qbground );
        open c3( c0rec.bus_company_id );
        fetch c3 into c3rec;
        close c3;
        htp.p( '<TD ' || pfx.qcbground || '>' );
           htp.p( c3rec.billing_name ); htp.nl;
           htp.p( c3rec.billing_street ); htp.nl;
           htp.p( c3rec.billing_suburb || ' ' || c3rec.billing_state || '  ' ||
                  c3rec.billing_postcode );
        htp.p( '</TD>' );
        htp.tableRowClose;
      end if;

   end if;
   --
   -- Display extra comments
   --
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Comments:' ), cattributes=>'VALIGN="TOP" '  ||
                  'style="text-align: right;"'); -- || pfx.qbground );
   htp.tableData( htf.paragraph || nvl( glbx.censor( c0rec.requirements, 2000 ),
                                        '&nbsp;' ),
                  cattributes=>pfx.qcbground );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( '&nbsp;' );
   htp.tableData( htf.formImage( 'pConfirm', DECS.IMAGE_LOCATION ||
                                 'booking/accept.gif',
                                 cattributes=>'alt="' || LNG5.BKN_TXT_018 ||
                                 '" title="' || LNG5.BKN_TXT_018 ||
                                 '" border="0"' ) );
   htp.tableRowClose;
   htp.tableClose;
   htp.formClose;
   htp.p( cal.getFooter( c0rec.calendar_id ) );
   -- htp.p( '</CENTER>' );
   htp.p( '</div>' );
   htp.p( '<script type="text/javascript" src="' || BKN_BOTTOMSCRIPT || '"></script>' );
   dapi.pageClose;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'CHECK_DETAILS', errmsg=>sqlerrm );
end check_details;

procedure accept_check_details(
  surl varchar2,
  acid integer default null,
  pPreviousStep varchar2 default null,
  pCancel varchar2 default null,
  pConfirm varchar2 default null,
  pContactEdOfficer varchar2 default null )
as
   cursor c0( csid integer ) is
   select
      *
   from
      booking
   where
      session_id = csid and status = LNG5.BKN_TXT_004;
   c0rec c0%ROWTYPE;

   cursor c1( crid integer ) is
   select
      *
   from
      resources
   where
      resource_id = crid;
   c1rec c1%ROWTYPE;

   cursor c2( cbid integer, crid integer ) is
   select
      *
   from
      resource_use
   where
      booking_id = cbid and resource_id = crid;
   c2rec c2%ROWTYPE;

   cursor c3( caid integer ) is
   select
      c.calendar_id calid
   from
      calendar c,
      calendar_map cm
   where
      c.calendar_id = cm.calendar_id and
      cm.aid = ( select aid from customer_profile where profile_id = caid );
   c3rec c3%ROWTYPE;

   sess_id        	integer;
   nTimeSpan      	integer;
   nSpanGalleries 	integer;
   nNumOfVis      	number;
   lBookingType   	integer;
   email_sent 		boolean;
   email_sendto 	varchar2( 256 );
   pEmailType 		integer;
   lReturnURL 		varchar2( 1000 );

begin
   if not dapi.init( surl, 'BKN.ACCEPT_CHECK_DETAILS', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;

   open c0( dapi.getSessionid );
   fetch c0 into c0rec;
   close c0;

   open c3( dapi.getAccountId );
   fetch c3 into c3rec;
   close c3;

   if pConfirm is not null then
      if create_reservation( surl, acid, c0rec.booking_id ) then
        if send_email( surl, acid, c0rec.booking_id, LNG5.BKN_TXT_005, email_sendto ) then commit; else rollback; end if;
         update booking set
            status = LNG5.BKN_TXT_005,
            last_step = '6'
         where
            booking_id = c0rec.booking_id;
      end if;
      lBookingType := getBookingType( c0rec.booking_id );
      end_page( surl, acid, c0rec.booking_id, email_sendto );
   elsif pPreviousStep is not null then
      lBookingType := getBookingType( c0rec.booking_id );
      if lBookingType = BOOKING_TYPE_1 then
         bkn.program_details( surl, acid );
      elsif lBookingType = BOOKING_TYPE_2 then
         school_details( surl, acid );
      elsif lBookingType = BOOKING_TYPE_3 then
         payment_details( surl, acid );
      elsif lBookingType = BOOKING_TYPE_4 then
         school_details( surl, acid );
      end if;
   elsif pCancel is not null then
      cancelBooking( surl, acid );
   elsif pContactEdOfficer is not null then
      lReturnURL := 'check_details( ' || surl || ', ' || acid || ', ' || TO_CHAR( c0rec.date_time, LNG.TSMASK ) || ' );';
     	contact_awm_staff( surl, acid, lReturnURL );
   end if;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'ACCEPT_CHECK_DETAILS', errmsg=>sqlerrm );
end accept_check_details;

procedure end_page( surl varchar2, acid integer default null, bid varchar2, email_sendto varchar2 default null )
as
   cursor c0( cbid integer ) is
   select *
   from booking
   where booking_id = cbid;

   cursor c3( cid integer ) is select * from customer_contact where aid = cid;

   c0rec	      c0%ROWTYPE;
   c3rec	      c3%ROWTYPE;
   sess_id            integer;
   rTheme             theme%ROWTYPE;
   booking_request_nr integer;
   grand_total        number;
   lStatus            integer;
   lSurl              varchar2( 100 );
   lBookingType       integer;
   lAccountId 	      integer;
   lText 	      varchar2( 2000 );
   eml	              varchar2( 256 );
   def		      school_booking_prefs%ROWTYPE;

begin
   if not dapi.init( surl, 'BKN.END_PAGE', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   dapi.setExternalStyleSheet(  BKN_STYLESHEET );
   -- dapi.setTitle( getTitle( bid ) );
   dapi.pageOpen;
   htp.p( '<script type="text/javascript" src="' || BKN_TOPSCRIPT || '"></script>' );
   htp.p( '<div class="bodytext">' );
   showProgress( 6, bid );

   open c0( bid );
   fetch c0 into c0rec;
   close c0;

   open c3( c0rec.made_by );
   fetch c3 into c3rec;
   close c3;
   eml := nvl(c3rec.billing_email,c0rec.contact_email);
   eml := nvl(eml,'(No email address found)' );

   def := getDefaults( dapi.getPhotographerId, c0rec.made_by );
   htp.header( 2, 'Your booking request number is ' || bid, cattributes=>'class="highlight"' );
   htp.p( '<p>Thank you for your booking request. Please use this booking ' ||
          'request number if you have to <a href="' || def.help_loc || '">contact us</a>.</p>' );
   htp.p( '<p>Once your booking has been checked a message will ' ||
          'be sent to ' || htf.bold(eml) || '. You will be asked to ' ||
          'reply by email within seven days to complete the booking process.</p>' );
   htp.p( '<p>Enjoy your visit to the ' || def.home_title || '.</p>' );
   htp.ulistOpen;
   htp.listItem( '<B><A HREF="javascript: window.open(''bkn.prebook?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || ''',''catwin'',''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=800,height=500'');void('''');">View your bookings</A></B>' );
   htp.listItem( htf.anchor( 'bkn.enterBookingPage?surl=' || Surl || '&acid=' || acid,
                 htf.bold( 'Make another booking' ) ) );
   htp.listItem( htf.anchor( def.home_url,
                 htf.bold( 'Go back to the home page' ) ) );
   htp.ulistClose;
   htp.p( '</div>' );
   htp.p( '<script type="text/javascript" src="' || BKN_BOTTOMSCRIPT || '"></script>' );
   dapi.pageClose;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'END_PAGE', errmsg=>sqlerrm );
end end_page;

procedure bookingNotActive( surl varchar2, acid integer default null )
as
begin
   if not dapi.init( surl, 'BKN.BOOKINGNOTACTIVE', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   dapi.setExternalStyleSheet( BKN_STYLESHEET );
   dapi.pageOpen;
   htp.p( '<script type="text/javascript" src="' || BKN_TOPSCRIPT || '"></script>' );
   htp.p( 'The booking you were working on is no longer active. Please create a new booking by selecting school bookings in the left menu.' );
   htp.p( '<script type="text/javascript" src="' || BKN_BOTTOMSCRIPT || '"></script>' );
   dapi.pageClose;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'BOOKINGNOTACTIVE', errmsg=>sqlerrm );
end bookingNotActive;

procedure cancelBooking( surl varchar2, acid integer default null, action varchar2 default null )
as

   cursor c1( csid integer ) is
      select booking_id from booking
      where session_id = csid and status = LNG5.BKN_TXT_004;

   c1rec 	c1%ROWTYPE;
   -- Work variables
   lSessionId 	integer;
   pfx 		theme%ROWTYPE;
   bid     	integer;
   sStyle  	varchar( 1000 );
   email_sendto varchar2( 100 );

begin
   if not dapi.init( surl, 'BKN.cancelBooking', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   pfx := dapi.getLFRecord;
   lSessionId := dapi.getSessionid;
   dapi.setExternalStyleSheet( DECS.IMAGE_LOCATION || 'booking/booking.css' );
   -- dapi.setTitle( LNG5.BKN_TXT_027 );
   dapi.pageOpen;
   open c1( lSessionId );
   fetch c1 into c1rec;
   close c1;
   if send_email( surl, acid, c1rec.booking_id, LNG5.BKN_TXT_009, email_sendto ) then commit; else rollback; end if;
   update booking
   set
      status = LNG5.BKN_TXT_009
   where
      booking_id = c1rec.booking_id;
   commit;
   sStyle := ' STYLE="color:#' || pfx.error_text_colour || ';font-family:' || pfx.error_text_font || ';" ';
   htp.tableOpen( calign=>'CENTER' );
   htp.tableRowOpen;
   htp.tableData( htf.paragraph( cattributes=>sStyle )|| 'Booking cancelled for booking_id = ' || c1rec.booking_id );
   htp.tableRowClose;
   htp.tableClose;
   dapi.pageClose;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'CANCELBOOKING', errmsg=>sqlerrm );
end cancelBooking;

procedure select_programs( surl varchar2, acid integer, bid integer, rurl varchar2,
                           login_type varchar2, msg varchar2 default null )
as
   cursor c1 is
      select um.umo_id umo_id, um.program_obj.program_name program_name,
             um.program_obj.program_description description,
             um.program_obj.duration duration,
             um.program_obj.cost_per_head cost_per_head,
             um.program_obj.school_year school_year,
             um.program_obj.wars_covered wars_covered
      from umo um
      where um.program_obj.program_type = LNG5.PRG_TXT_110;

   cursor c2( cprogram_id integer, cbid integer ) is
   select num_of_visitors
   from booked_programs bp
   where bp.booking_id = cbid and
         bp.program_id = cprogram_id;

   booked integer;
   sess_id integer;
   rTheme theme%ROWTYPE;
   lFound boolean;
begin
   if not dapi.init( surl, 'BKN.SELECT_PROGRAMS', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   rTheme := dapi.getLFRecord;
   dapi.pageOpen;
   htp.p( '<center>' );
   htp.formOpen( 'bkn.accept_select_programs' );
   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   htp.formHidden( 'rurl', rurl );
   htp.formHidden( 'bid', bid );
   htp.formHidden( 'login_type', login_type );
   htp.formHidden( 'p1', null );
   htp.formHidden( 'p2', null );
   --
   -- Display a message
   --
   if msg is not null then
      htp.p( '<font size="+3" color="#' || rTheme.TEXT_COLOUR || '" FACE="' || rTheme.error_text_font || '">'|| msg || '</font>' );
   end if;
   htp.tableOpen( cattributes=>'width="100%" border="1" cellpadding="2" cellspacing="0"' );
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Select' ), cattributes=>rTheme.qbground );
   htp.tableData( htf.bold( 'Program Name' ), cattributes=>rTheme.qbground );
   htp.tableData( htf.bold( 'Duration' ), cattributes=>rTheme.qbground );
   htp.tableData( htf.bold( 'Wars Covered' ), cattributes=>rTheme.qbground );
   htp.tableRowClose;
   for c1rec in c1 loop
      htp.tableRowOpen;
      open c2( c1rec.umo_id, bid );
      fetch c2 into booked;
      lFound := c2%FOUND;
      close c2;
      if lFound then
         htp.tableData( htf.formHidden( 'p1', c1rec.umo_id ) || htf.formText( 'p2', cvalue=>booked ), cattributes=>rTheme.qcbground );
      else
         htp.tableData( htf.formHidden( 'p1', c1rec.umo_id ) || htf.formText( 'p2', cvalue=>null ), cattributes=>rTheme.qcbground );
      end if;
      htp.tableData( c1rec.program_name, cattributes=>rTheme.qcbground );
      htp.tableData( c1rec.duration, cattributes=>rTheme.qcbground );
      htp.tableData( c1rec.wars_covered, cattributes=>rTheme.qcbground );
      htp.tableRowClose;
   end loop;
   htp.tableClose;
   htp.formSubmit( 'action', 'Ok' );
   htp.formSubmit( 'action', 'Cancel' );
   htp.formClose;
   htp.p( '</center>' );
   dapi.pageClose;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'SELECT_PROGRAMS',errmsg=>sqlerrm );
end select_programs;

procedure accept_select_programs(
  surl varchar2,
  acid integer,
  rurl varchar2,
  p1 glbx.myarray,
  p2 glbx.myarray,
  bid integer,
  login_type varchar2,
  action varchar2 )
as
   cursor c1 is
   select
      purchase_order_id
   from
      booking
   where
      booking_id = bid;
   c1rec c1%ROWTYPE;
   cursor c2 is
   select
      num_of_visitors,
      program_id
   from
      booked_programs
   where
      booking_id = bid;

   dummy integer;
   msg   varchar2( 200 );
   oldList varchar2( 1000 );
   newList varchar2( 1000 );
   lSessionId integer;
begin
   if not dapi.init( surl, 'BKN.ACCEPT_SELECT_PROGRAMS', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   lSessionId := dapi.getSessionid;
   if action = 'Ok' then
      --
      -- Audit changes
      --
      oldList := null;
      for c2rec in c2 loop
         oldList := oldList || c2rec.num_of_visitors || 'x' || c2rec.program_id || ' ';
      end loop;
      --
      -- Delete mapped programs
      --
      delete from booked_programs where booking_id = bid;
      --
      -- Add the chosen programs
      --
      newList := null;
      for i in p1.first..p1.last loop
         if p2( i ) is not null then
            insert into booked_programs ( booking_id, program_id, num_of_visitors ) values( bid, p1( i ), p2( i ) );
         end if;
         newList := newLIst || p2( i ) || 'x' || p1( i ) || ' ';
      end loop;
      --
      -- After this we have to recalculate the purchase_order if a purchase order exists
      --
      open c1;
      fetch c1 into c1rec;
      close c1;
      if c1rec.purchase_order_id is not null then
         if createShoppingBasketItems( surl, bid ) = 0 then
            --
            -- Fail
            --
            msg := 'Error creating shopping basket items';
         end if;
      end if;
      --
      -- Audit changes
      --
      insert into audit_booking values( SYSDATE, bid, 'BOOKED_PROGRAMS', 'Booked Programs', oldList, newList, acid );
      commit;
      lab_booking_details( surl, acid, bid, rurl );
   end if;
end accept_select_programs;

procedure select_workbooks(
  surl varchar2,
  acid integer,
  bid  integer,
  rurl varchar2,
  login_type varchar2,
  msg varchar2 default null )
as
   cursor c1 is
      select
         um.umo_id umo_id,
         um.program_obj.program_name workbook_name,
         um.program_obj.program_description description,
         um.program_obj.duration duration,
         um.program_obj.cost_per_head cost_per_head,
         um.program_obj.school_year school_year,
         um.program_obj.wars_covered wars_covered
      from
         umo um
      where
         um.program_obj.program_type = LNG5.PRG_TXT_111;

   cursor c2( cworkbook_id integer ) is
      select
         count( * )
      from
         booked_workbooks bw
      where
         bw.booking_id = bid and
         bw.workbook_id = cworkbook_id;
         booked integer;

   sess_id integer;
   rTheme theme%ROWTYPE;
begin
   if not dapi.init( surl, 'BKN.SELECT_WORKBOOKS', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   dapi.pageOpen;
   htp.formOpen( 'bkn.accept_select_workbooks' );
   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   htp.formHidden( 'rurl', rurl );
   htp.formHidden( 'bid', bid );
   htp.formHidden( 'login_type', login_type );
   htp.formHidden( 'p1', '0' );

   htp.p( '<center>' );
   --
   -- Display a message
   --
   if msg is not null then
      htp.p( '<font size="+3" color="#' || rTheme.TEXT_COLOUR || '" FACE="' || rTheme.error_text_font || '">'|| msg || '</font>' );
   end if;
   htp.tableOpen( cattributes=>'width="100%" border="1" cellpadding="2" cellspacing="0"' );
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Select' ), cattributes=>rTheme.qbground );
   htp.tableData( htf.bold( 'Workbook Name' ), cattributes=>rTheme.qbground );
   htp.tableData( htf.bold( 'Duration' ), cattributes=>rTheme.qbground );
   htp.tableData( htf.bold( 'Wars Covered' ), cattributes=>rTheme.qbground );
   htp.tableRowClose;
   for c1rec in c1 loop
      htp.tableRowOpen;
      open c2( c1rec.umo_id );
      fetch c2 into booked;
      close c2;
      if booked = 0 then
         htp.tableData( htf.formCheckBox( 'p1', c1rec.umo_id ), cattributes=>rTheme.qcbground );
      else
         htp.tableData( htf.formCheckBox( 'p1', c1rec.umo_id, 'CHECKED' ), cattributes=>rTheme.qcbground );
      end if;
      htp.tableData( c1rec.workbook_name, cattributes=>rTheme.qcbground );
      htp.tableData( c1rec.duration, cattributes=>rTheme.qcbground );
      htp.tableData( c1rec.wars_covered, cattributes=>rTheme.qcbground );
      htp.tableRowClose;
   end loop;
   htp.tableClose;

   htp.formSubmit( 'action', 'Ok' );
   htp.formSubmit( 'action', 'Cancel' );
   htp.formClose;

   glbx.close_page( rTheme );

   exception
      when others then
         glbx.error_details( PACKAGE_NAME, 'SELECT_WORKBOOKS',errmsg=>sqlerrm );
end select_workbooks;

procedure accept_select_workbooks(
  surl varchar2,
  acid integer,
  rurl varchar2,
  p1   glbx.myarray,
  bid  integer,
  login_type varchar2,
  action varchar2 )
as
   cursor c1 is
      select
         purchase_order_id
      from
         booking
      where
         booking_id = bid;
   cursor c2 is
      select
         workbook_id
      from
         booked_workbooks
      where
         booking_id = bid;
   c1rec c1%ROWTYPE;
   dummy integer;
   msg   varchar2( 200 );
   oldList varchar2( 1000 );
   newLIst varchar2( 1000 );
   lSessionId integer;
begin
   if not dapi.init( surl, 'BKN.ACCEPT_SELECT_WORKBOOKS', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   lSessionId := dapi.getSessionid;
   if not bookingActive( lSessionId ) then
      bookingNotActive( surl, acid );
      return;
   end if;
   if action = 'Ok' then
      --
      -- Audit changes
      --
      oldList := null;
      for c2rec in c2 loop
         oldList := oldList || c2rec.workbook_id || ' ';
      end loop;
      --
      -- Delete mapped workbooks
      --
      delete from booked_workbooks where booking_id = bid;
      --
      -- Add the chosen workbooks
      --
      newList := null;
      for i in p1.first..p1.last loop
         insert into booked_workbooks ( booking_id, workbook_id ) values( bid, p1( i ) );
         newList := newList || p1( i ) || ' ';
      end loop;
      --
      -- After this we have to recalculate the purchase_order if a purchase order exists
      --
      open c1;
      fetch c1 into c1rec;
      close c1;
      if c1rec.purchase_order_id is not null then
         if createShoppingBasketItems( surl, bid ) = 0 then
            --
            -- Fail
            --
            msg := 'Error creating shopping basket items';
         end if;
      end if;
      --
      -- Audit changes
      --
      insert into audit_booking values( SYSDATE, bid, 'BOOKED_WORKBOOKS', 'Booked Workbooks', oldList, newList, acid );
      commit;
      lab_booking_details( surl, acid, bid, rurl );
   end if;
end accept_select_workbooks;

procedure accept_select_profile( surl varchar2, bid integer,
                                 acid integer default null,
                                 sid integer default null,
                                 action varchar2 default null,
                                 user_type char default null,
                                 rurl varchar2 default null )
as
   cursor c1( cbid integer ) is
      select school_id, bus_company_id
      from booking
      where booking_id = cbid;
   --
   -- Work variables
   --
   c1rec c1%ROWTYPE;
   sess_id integer;
   rTheme  theme%ROWTYPE;
   lSessionId integer;
   lAccountId integer;
   lLoginType varchar2( 100 );
begin
   if not dapi.init( surl, 'BKN.ACCEPT_SELECT_profile', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   lLoginType := dapi.getLoginType;
   lSessionId := dapi.getSessionid;

   if action = 'OK' then
      if lLoginType in ( 'OWNER', 'CUSTOMER', 'PROFILE', 'PROFILEG', 'VIRTUAL' ) then
         if user_type = 'E' then
            update booking
               set school_id = sid,
                   school_login_type = 'PROFILE'
               where session_id = lSessionid and
                     status = LNG5.BKN_TXT_004;
         elsif user_type = 'T' then
            update booking
               set bus_company_id = sid,
                   bus_company_login_type = 'PROFILE'
               where session_id = lSessionid and
                     status = LNG5.BKN_TXT_004;
         end if;
      elsif lLoginType in ( 'MANUFACTURER' ) then
      	  open c1( bid );
      	  fetch c1 into c1rec;
      	  close c1;
      	  --
      	  -- Update the change in the audit file
      	  --
         if user_type = 'E' then
            if nvl( c1rec.school_id, 0 ) <> nvl( sid, 0 ) then
               insert into audit_booking
                  values( SYSDATE, bid, 'SCHOOL_ID', lng5.SCL_TXT_100,
                          c1rec.school_id, sid, lAccountId );
            end if;
            update booking
               set school_id = sid, date_modified = SYSDATE
               where booking_id = bid;
         elsif user_type = 'T' then
            if nvl( c1rec.bus_company_id, 0 ) <> nvl( sid, 0 ) then
               insert into audit_booking
                  values( SYSDATE, bid, 'COMPANY_ID', lng5.SCL_TXT_100,
                          c1rec.bus_company_id, sid, lAccountId );
            end if;
            update booking
               set bus_company_id = sid, date_modified = SYSDATE
               where booking_id = bid;
         end if;
      end if;
   end if;
   commit;
   --
   -- Link back to the page that has chosen the school
   --
   if lLoginType in ( 'OWNER', 'CUSTOMER', 'PROFILE', 'PROFILEG','VIRTUAL' ) then
      school_details( surl, acid );
   elsif lLoginType in ( 'MANUFACTURER' ) then
      lab_booking_details( surl, acid, bid, rurl );
   end if;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'ACCEPT_SELECT_PROFILE' ,errmsg=>sqlerrm );
end accept_select_profile;

procedure accept_select_company(
  surl       varchar2,
  acid       integer default null,
  cid        varchar2 default null,
  bid        varchar2 default null,
  action     varchar2 default null,
  login_type varchar2 default null,
  rurl       varchar2 default null )
as
   cursor c1( cbid integer ) is
   	select bus_company_id from booking where booking_id = cbid;
   c1rec c1%ROWTYPE;
   --
   -- Work variables
   --
   sess_id integer;
   n_aid   integer;
begin
   if not dapi.init( surl, 'BKN.ACCEPT_SELECT_COPMANY', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;

   if action = 'OK' then
      if ( login_type in ( 'OWNER', 'CUSTOMER', 'PROFILE', 'PROFILEG','VIRTUAL' ) ) or login_type is null then
         update booking
            set bus_company_id = cid
            where session_id = sess_id and status = LNG5.BKN_TXT_004;
      elsif login_type in ( 'MANUFACTURER' ) then
      	open c1( bid );
      	fetch c1 into c1rec;
      	close c1;
      	--
      	-- Update the change in the audit file
      	--
    		n_aid := dapi.getAccountId;
      	if nvl( c1rec.bus_company_id, 0 ) <> nvl( cid, 0 ) then
         	insert into audit_booking values( SYSDATE, bid, 'BUS_COMPANY_ID', 'Company ID', c1rec.bus_company_id, cid, n_aid );
         end if;
         update booking
            set bus_company_id = cid
            where booking_id = bid;
      end if;
   end if;

   commit;

   --
   -- Link back to the page that has chosen the school
   --
   if ( login_type in ( 'OWNER', 'CUSTOMER', 'PROFILE', 'PROFILEG','VIRTUAL' ) ) or login_type is null then
      -- company_details( surl, acid );
      null;
   elsif login_type in ( 'MANUFACTURER' ) then
      lab_booking_details( surl, acid, bid, rurl );
   end if;

   exception
      when others then
         glbx.error_details( PACKAGE_NAME, 'ACCEPT_SELECT_COMPANY', errmsg=>sqlerrm );
end accept_select_company;

procedure lab_maintain_bookings( surl varchar2, acid integer default null, show_for varchar2 default null )
as
   cursor c1( cmid integer ) is
      select
         c.calendar_id calendar_id,
         c.name name,
         c.pid photographer_id
      from
         manufacturer_photographer mp,
         calendar c
      where
         mp.manufacturer_id = cmid and
         c.pid = mp.pid;
   c1rec c1%ROWTYPE;

   cursor c2 is
      select
         *
      from
         calendar;
   c2rec c2%ROWTYPE;

   cursor c3( cmid integer ) is
      select
         all_photographers
      from
         manufacturer
      where
         manufacturer_id = cmid;

   cursor c4( cmid integer ) is
      select
         std_calendar_id
      from
         school_booking_prefs
      where
         manufacturer_id = cmid;
   c4rec c4%rowtype;

   -- Security variables
   cCusrec  	c3%ROWTYPE;
   owner_id	integer;
   dDateToStart	date;
   sts		varchar2( 100 );
   lMonth	varchar2( 100 );

   -- Look and feel variables
   rTheme	THEME%ROWTYPE;
   theme_rec	theme_types%ROWTYPE;
begin
   if not dapi.init( surl, 'BKN.TYPEOFVISIT', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   rTheme := dapi.getLFRecord;
   dapi.setTitle( 'Choose a Calendar' );
   dapi.pageOpen;
   if show_for is null then
      open c3( owner_id );
      fetch c3 into cCusRec;
      close c3;
      open c4( owner_id );
      fetch c4 into c4rec;
      close c4;
   end if;
   htp.p( '<CENTER>' );

   if show_for is null then
      htp.formOpen( 'bkn.lab_calendar_overview' );
      htp.formhidden( 'pStatus', LNG5.BKN_TXT_005 || ',' || LNG5.BKN_TXT_006 || ',' || 'Reservation Accepted' || ',' || 'Problem' || ',' );
   elsif show_for = 'Reception' then
      htp.formOpen( 'bkn.reception_show_day' );
   end if;

   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );

   htp.tableOpen( cattributes=>TABLE_ATTS );
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Calendar' ), cattributes=>rTheme.qbground );
   htp.tableData( htf.bold( 'Date' ), cattributes=>rTheme.qbground );
   htp.tableData( htf.bold( '&nbsp;' ), cattributes=>rTheme.qbground );
   htp.tableRowClose;

   if TRIM( cCusrec.all_photographers ) in ( 'T', 't' ) then

      htp.tableRowOpen;
      htp.p( '<TD ' || rTheme.qcbground || '>' );
      htp.formSelectOpen( 'calid' );
      htp.formSelectOption( '&lt;all calendars&gt;', cattributes=>'VALUE=""' );
      for c2rec in c2 loop
         if c2rec.calendar_id = c4rec.std_calendar_id then
            htp.formSelectOption( c2rec.name, cselected=>'SELECTED', cattributes=>'VALUE="' || c2rec.calendar_id || '"' );
         else
            htp.formSelectOption( c2rec.name, cattributes=>'VALUE="' || c2rec.calendar_id || '"' );
         end if;
      end loop;
      htp.formSelectClose;
      htp.p( '</TD>' );
      if show_for is null then
        htp.p( '<TD ' || rTheme.qcbground || '>' );
         htp.formSelectOpen( 's_chosen_date', cattributes=>'onChange="selectMonth( );"' );
         htp.formSelectOption( 'Select a month...', cattributes=>'value=""' );
         dDateToStart := sysdate;
         for i in 0..19 loop
           lMonth := TO_CHAR( ADD_MONTHS( SYSDATE, i ), 'Month yyyy' );
           if lMonth = TO_CHAR( dDateToStart, 'Month yyyy' ) then
              htp.formSelectOption( lMonth, cselected=>'SELECTED', cattributes=>'value="' ||
                                    TO_CHAR( ADD_MONTHS( SYSDATE, i ), LNG.MASK ) || '"' );
           else
              htp.formSelectOption( lMonth, cattributes=>'value="' ||
                                    TO_CHAR( ADD_MONTHS( SYSDATE, i ), LNG.MASK ) || '"' );
           end if;
         end loop;
         htp.formSelectClose;
         --htp.tableData( htf.formText( 's_chosen_date', cvalue=>TO_CHAR( SYSDATE, LNG.MASK ) ), cattributes=>rTheme.qcbground );
         htp.p( '</TD>' );
      end if;
      htp.tableData( htf.formSubmit( 'action', 'Show calendar' ), cattributes=>rTheme.qcbground );
      htp.tableRowClose;

   else
      htp.tableRowOpen;
      htp.p( '<TD ' || rTheme.qcbground || '>' );
      htp.formSelectOpen( 'calid' );
      htp.formSelectOption( '&lt;all calendars&gt;', cattributes=>'VALUE=""' );
      for c1rec in c1( owner_id ) loop
         if c1rec.calendar_id = c4rec.std_calendar_id then
            htp.formSelectOption( c1rec.name, cselected=>'SELECTED', cattributes=>'VALUE="' || c1rec.calendar_id || '"' );
         else
            htp.formSelectOption( c1rec.name, cattributes=>'VALUE="' || c1rec.calendar_id || '"' );
         end if;
      end loop;
      htp.formSelectClose;
      if show_for is null then
        htp.p( '<TD ' || rTheme.qcbground || '>' );
         htp.formSelectOpen( 's_chosen_date', cattributes=>'onChange="selectMonth( );"' );
         htp.formSelectOption( 'Select a month...', cattributes=>'value=""' );
         dDateToStart := sysdate;
         for i in 0..19 loop
           lMonth := TO_CHAR( ADD_MONTHS( SYSDATE, i ), 'Month yyyy' );
           if lMonth = TO_CHAR( dDateToStart, 'Month yyyy' ) then
              htp.formSelectOption( lMonth, cselected=>'SELECTED', cattributes=>'value="' ||
                                    TO_CHAR( ADD_MONTHS( SYSDATE, i ), LNG.MASK ) || '"' );
           else
              htp.formSelectOption( lMonth, cattributes=>'value="' ||
                                    TO_CHAR( ADD_MONTHS( SYSDATE, i ), LNG.MASK ) || '"' );
           end if;
         end loop;
         htp.formSelectClose;
         --htp.tableData( htf.formText( 's_chosen_date', cvalue=>TO_CHAR( SYSDATE, LNG.MASK ) ), cattributes=>rTheme.qcbground );
         htp.p( '</TD>' );
      end if;
      htp.tableData( htf.formSubmit( 'action', 'Show calendar' ), cattributes=>rTheme.qcbground );
      htp.tableRowClose;
   end if;

   htp.tableClose;
   htp.formClose;
   -- htp.formSubmit( 'action', lng5.BKN_BUT_003, cattributes=>'onClick="self.location.href=''lab.mng_booking?surl=' || surl || '''; return false;"' );
   htp.p( '</CENTER>' );

   glbx.close_page( rTheme );

   exception
      when others then
         glbx.error_details( PACKAGE_NAME, 'LAB_MAINTAIN_BOOKINGS', errmsg=>sqlerrm );
end lab_maintain_bookings;

procedure lab_show_calendar(
  surl varchar2,
  acid integer default null,
  calid integer default null,
  p_proposed_date varchar2 default null,
  p_days_in_view varchar2 default null )
as
   --
   -- Retrieve occupied time by a resource
   --
   cursor c1( date_to_check date, ccid integer ) is
   select
		    b.booking_id booking_id,
      b.num_of_students num_of_students,
      b.made_by made_by,
      b.school_id school_id,
      b.bus_company_id bus_company_id,
      b.date_time date_time,
      b.purchase_order_id purchase_order_id,
      b.visit_type visit_type
   from
      resource_use ru,
      booking b
   where
      ru.date_time_from <= date_to_check and date_to_check < ru.date_time_to and
      ( ccid is null or ( ccid is not null and b.calendar_id = ccid ) ) and
      b.booking_id = ru.booking_id;
   c1rec c1%ROWTYPE;
   --
   -- Fetch calendar settings
   --
   cursor c2( ccid integer ) is
   select
      calendar_id calid,
      start_time,
      end_time,
      time_block,
      date_format,
      days_in_view
   from
      calendar c
   where
      ( ccid is null or ( ccid is not null and c.calendar_id = ccid ) );
   c2rec c2%ROWTYPE;
   --
   -- Retrieve resource details
   --
   cursor c3( crid integer ) is
   select
      *
   from
      resources
   where
      resource_id = crid;
   c3rec c3%ROWTYPE;
   --
   -- Fetch current booking
   --
   cursor c4( csid integer ) is
   select
      *
   from
      booking
   where
      session_id = csid and
      status = LNG5.BKN_TXT_004;
   c4rec c4%ROWTYPE;
   --
   -- Fetch blocked times for the specified Calendar
   --
   cursor c5( ccid integer, cdate date ) is
   select
      reason
   from
      excluded_calendar_times
   where
      calendar_id = ccid and
      date_time_from <= cdate and
      cdate <= date_time_to;
   c5rec c5%ROWTYPE;
   --
   -- Fetch school holidays
   --
   cursor c6( ccid integer ) is
   select
      *
   from
      school_holidays
   where
      calendar_id = ccid;
   c6rec c6%ROWTYPE;
   --
   -- School/Bus company details
   --
   cursor c7( cid integer ) is
   select
      billing_name
   from
      customer_contact
   where
      aid = cid;
   c7rec c7%ROWTYPE;

   dThisDay     date;
   cThisDay     varchar( 100 );
   dThisTime    date;
   cThisTime    varchar( 100 );
   dThisDayTime date;

   cThisDayTime varchar( 100 );
   c_DateTime1  varchar2( 100 );
   c_DateTime3  varchar2( 100 );
   time_span    integer; -- Time span is the amount of time blocks that should be used for the Education Centre
   time_span2   integer; -- Time span for the Galleries

   bTimeAvailable boolean;
   tableAtts      varchar2( 100 );
   anchorText     varchar2( 100 );
   fontSize       varchar2( 10 );
   bid            integer;

   i_hours   integer;
   i_minutes integer;
   sess_id   integer;
   rTheme    theme%ROWTYPE;
   nRow      integer; -- even or odd row 0 = even 1 is odd

   nTimeLookAhead   integer;
   nNumOfVis        number;
   textNotAvailable varchar2( 200 );
   daysBefore       integer;
   daysAfter        integer;

   days_in_view integer;
   date_time    date;
   explanation  varchar2( 1000 );
   CRLF         varchar2( 10 )  := CHR( 13 ) || CHR( 10 );
   HT           varchar2( 10 )  := CHR( 9 );

   rurl varchar2( 2000 );
begin
   if not dapi.init( surl, 'BKN.LAB_SHOW_CALENDAR', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   rTheme := dapi.getLFRecord;
   dapi.setTitle( LNG5.BKN_TXT_012 );
   dapi.pageOpen;
   fontSize := '8pt';
   --
   -- Initialisation
   --
   date_time := TO_DATE( p_proposed_date, LNG.TSMASK );
   --
   -- Build the return url
   --
   rurl := 'bkn.lab_show_calendar( :surl, :acid';
   if calid is not null then
   	  rurl := rurl || ', calid=>' || calid;
   end if;
   if p_proposed_date is not null then
   	  rurl := rurl || ', p_proposed_date=>'''|| p_proposed_date || '''';
   end if;
   if p_days_in_view is not null then
   	  rurl := rurl || ', p_days_in_view=>''' || p_days_in_view || '''';
   end if;
   rurl := rurl || ' );';
   --
   -- Fetch calendar details
   --
   open c2( calid );
   fetch c2 into c2rec;
   close c2;
   --
   -- Calculate the amount of days to show
   --
   if p_days_in_view is null then
   	  days_in_view := c2rec.days_in_view;
   else
   	  days_in_view := p_days_in_view;
   end if;
   daysAfter := TRUNC( days_in_view/2 );
   daysBefore := days_in_view - daysAfter - 1;

   c_DateTime1 := TO_CHAR( date_time - daysBefore - 1, LNG.TSMASK ); -- First day of the calendar to display
   c_DateTime3 := TO_CHAR( date_time + daysAfter + 1, LNG.TSMASK ); -- Third day of the calendar to display

   htp.p( '<CENTER>' );

   htp.tableOpen( cattributes=>'cellpadding="0" cellspacing="2" border="0" WIDTH="100%"' );

   htp.tableRowOpen;
   --
   -- Print the link to the previous day
   --
   htp.tableData(
      htf.anchor( 'bkn.lab_show_calendar?sUrl=' || sUrl || '&acid=' || acid || '&p_proposed_date=' || c_DateTime1 || '&p_days_in_view=1', 'Previous day' ),
                  cattributes=>'ALIGN="CENTER" WIDTH="100"' );
   --
   -- Print the headers
   --
   for i in -daysBefore..daysAfter loop
      htp.tableData( htf.bold( INITCAP( LOWER( TO_CHAR( date_time + i, LNG5.BKN_TXT_086 ) ) ) ), cattributes=>' WIDTH="160" ALIGN="CENTER"' );
   end loop;
   --
   -- Print the link to the next day
   --
   htp.tableData(
      htf.anchor( 'bkn.lab_show_calendar?sUrl=' || sUrl || '&acid=' || acid || '&p_proposed_date=' || c_DateTime3 || '&p_days_in_view=1', 'Next day'),
                  cattributes=>'ALIGN="CENTER" WIDTH="100"');
   htp.tableRowClose;

   i_hours := TO_NUMBER( TO_CHAR( c2rec.start_time, 'HH24' ) );
   nRow    := 0;

   while i_hours <= TO_NUMBER( TO_CHAR( c2rec.end_time, 'HH24' ) ) loop -- Loop though the hours
      i_minutes := 0;
      while i_minutes < 60 loop                                    -- loop through the minutes
         dThisTime := TO_DATE( TO_CHAR( i_hours, '09' ) || ':' || TO_CHAR( i_minutes, '09' ), 'HH24:MI' );
         cThisTime := TO_CHAR( dThisTime, 'HH24:MI' );
         if nRow = 0 then
            htp.tableRowOpen( cattributes=>'BGCOLOR="#' || rTheme.vert_colour_a || '" STYLE="font-size: ' || fontSize || '"' );
         else
            htp.tableRowOpen( cattributes=>'BGCOLOR="#' || rTheme.vert_colour_b || '" STYLE="font-size: ' || fontSize || '"' );
         end if;
         nRow := mod( 1, nRow );
         htp.p( '<TD>' );
         htp.paragraph( cattributes=>'STYLE="color:#' || rTheme.caption_text_colour || ';font-family:' || rTheme.caption_text_font || ';font-size: ' || fontSize || '"' );
         htp.p( cThisTime );
         htp.p( '</P></TD>' );

         for dayCount in -daysBefore..daysAfter loop
            dThisDay     := date_time + dayCount;
            cThisDay     := TO_CHAR( dThisDay, LNG.MASK );
            dThisDayTime := TO_DATE( cThisDay || ' ' || cThisTime, LNG.TSMASK );
            cThisDayTime := TO_CHAR( dThisDayTime, LNG.TSMASK );

            bTimeAvailable := TRUE;
            textNotAvailable := '';

            if bTimeAvailable then
               htp.p( '<TD>' );
               for c1rec in c1( dThisDayTime, calid ) loop
               	open c7( c1rec.school_id );
               	fetch c7 into c7rec;
               	close c7;
               	explanation := 'Booking id' || HT || c1rec.booking_id || CRLF ||
               	               'Booking RQN' || HT || c1rec.purchase_order_id || CRLF ||
               	               '# students' || HT || c1rec.num_of_students || CRLF ||
               	               'Date of visit' || HT || TO_CHAR( c1rec.date_time, lng.MASK ) || CRLF ||
               	               'Time of arrival' || HT || TO_CHAR( c1rec.date_time, lng.TSMASK_ONLY ) || CRLF ||
               	               'School' || HT || HT || c7rec.billing_name || CRLF ||
               	               'Visit type' || HT || c1rec.visit_type;
               	htp.p( htf.anchor2( 'bkn.lab_booking_details?surl=' || surl || '&acid=' || acid || '&bid=' || c1rec.booking_id || '&rurl=' || rurl, c1rec.booking_id || ' - ' || c7rec.billing_name, cattributes=>'TITLE="' || explanation || '"' ) );
               end loop;
               htp.p( '</TD>' );
            else
               htp.p( '<TD ID="CALENDAR" ' || tableAtts || ' STYLE="color:#' || rTheme.caption_text_colour || ';font-family:' || rTheme.caption_text_font || ';font-size: ' || fontSize || '">' );
               htp.p( textNotAvailable );
               htp.p( '</TD>' );
            end if;

         end loop;
         htp.p( '<TD ID="CALENDAR" ALIGN="CENTER" STYLE="color:#' || rTheme.caption_text_colour || ';font-family:' || rTheme.caption_text_font || ';font-size: ' || fontSize || '">' );
         htp.p( '&nbsp;' );
         htp.p( '</TD>' );
         htp.tableRowClose;
         i_minutes := i_minutes + c2rec.time_block;
      end loop;

      i_hours := i_hours + 1;
   end loop;

   htp.tableRowOpen;
   --
   -- Print the link to the previous day
   --
   htp.tableData(
      htf.anchor( 'bkn.lab_show_calendar?sUrl=' || sUrl || '&acid=' || acid ||
                 '&p_proposed_date=' || c_DateTime1 || '&p_days_in_view=1',
                 'Previous day'
      ), cattributes=>'ALIGN="CENTER" WIDTH="100"'
   );
   -- Print the headers
   for i in -daysBefore..daysAfter loop
      htp.tableData( htf.bold( INITCAP( LOWER( TO_CHAR( date_time + i, LNG5.BKN_TXT_086 ) ) ) ), cattributes=>' WIDTH="160" ALIGN="CENTER"' );
   end loop;
   --
   -- Print the link to the next day
   --
   htp.tableData(
      htf.anchor( 'bkn.lab_show_calendar?sUrl=' || sUrl || '&acid=' || acid ||
                 '&p_proposed_date=' || c_DateTime3 || '&p_days_in_view=1',
                 'Next day'
      ), cattributes=>'ALIGN="CENTER" WIDTH="100"'
   );
   htp.tableRowClose;

   htp.tableClose;
   htp.p( '</FONT>' );

   --
   -- Navigation buttons
   --
   htp.formOpen( 'bkn.lab_calendar_overview' );
   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   htp.formHidden( 's_chosen_date', to_char( date_time, LNG.MASK ) );
   htp.formHidden( 'calid', calid );
   htp.formSubmit( 'action', lng5.BKN_BUT_003 );
   htp.formClose;

   htp.p( '</CENTER>' );
   dapi.pageClose;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'LAB_SHOW_CALENDAR', errmsg=>sqlerrm );
end lab_show_calendar;

procedure lab_booking_details( surl varchar2, acid integer default null,bid varchar2, rurl varchar2 default null, action varchar2 default null )
as
   cursor c1( cbid integer ) is
      select *
      from booking b
      where b.booking_id = cbid;
   c1rec c1%ROWTYPE;

   cursor c2( cbid integer ) is
      select p.umo_id prgid,
             p.program_obj.program_name program_name,
             bp.num_of_visitors num_of_visitors
      from booked_programs bp, umo p
      where bp.booking_id = cbid and p.umo_id = bp.program_id;
   c2rec c2%ROWTYPE;

   -- Retrieve school details
   cursor c4( csid integer ) is
      select *
      from customer_contact
      where aid = csid and user_type = 'E';
   c4rec c4%ROWTYPE;

   -- Retrieve company details
   cursor c5( ccid integer ) is
      select *
      from customer_contact
      where aid = ccid and user_type = 'T';
   c5rec c5%ROWTYPE;

   -- Retrieve customer details
   cursor c6( caid integer ) is
      select *
      from customer_contact
      where aid = caid;
   c6rec c6%ROWTYPE;

   cursor c9( cVisitTypeId integer ) is
      select visit_type_name, class, is_paid_program
      from visit_types
      where visit_type_id = cVisitTypeId;
   c9rec c9%ROWTYPE;

   rTheme	 THEME%ROWTYPE;
   lProgramCount integer;
   def		 school_booking_prefs%ROWTYPE;

begin
   if not dapi.init( surl, 'BKN.LAB_BOOKING_DETAILS', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   def := getDefaults( acid );
   rTheme := dapi.getLFRecord;
   dapi.setTitle( 'Booking Details' );
   dapi.pageOpen;
   -- fetch booking details
   open c1( bid );
   fetch c1 into c1rec;
   close c1;
   htp.p( '<CENTER>' );
   htp.formOpen( 'bkn.modify_booking_details' );
   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   htp.formHidden( 'p_booking_id', c1rec.booking_id );
   htp.formHidden( 'rurl', rurl );
   htp.tableOpen( cattributes=>'border="1" cellpadding="1" cellspacing="1"' );
   -- Booking Request Number
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Booking Request Number' ), cattributes=>rTheme.qbground );
   htp.tableData( c1rec.booking_id, cattributes=>rTheme.qcbground );
   htp.tableRowClose;
   -- Purchase order ID
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Purchase Order ID' ), cattributes=>rTheme.qbground );
   htp.tableData( anchor_receipt(surl, c1rec, acid), cattributes=>rTheme.qcbground );
   htp.tableRowClose;
   -- Status
   htp.tableRowOpen;
   htp.tableData( htf.bold( lng.PHG_TXT_082 ), cattributes=>rTheme.qbground );
   htp.p( '<TD ' || rTheme.qcbground || '>' );
   htp.formSelectOpen( 'p_status' );
   if c1rec.status = LNG5.BKN_TXT_004 then
      htp.formSelectOption( LNG5.BKN_TXT_004, cattributes=>'SELECTED' ); -- Pre booking
   else
      htp.formSelectOption( LNG5.BKN_TXT_004 ); -- Pre booking
   end if;
   if c1rec.status = LNG5.BKN_TXT_005 then
      htp.formSelectOption( LNG5.BKN_TXT_005, cattributes=>'SELECTED' ); -- Reservation
   else
      htp.formSelectOption( LNG5.BKN_TXT_005 ); -- Reservation
   end if;
   if c1rec.status = 'Reservation Accepted' then
      htp.formSelectOption( 'Reservation Accepted', cattributes=>'SELECTED' ); -- Reservation Accepted
   else
      htp.formSelectOption( 'Reservation Accepted' ); -- Reservation
   end if;
   if c1rec.status = LNG5.BKN_TXT_009 then
      htp.formSelectOption( LNG5.BKN_TXT_009, cattributes=>'SELECTED' ); -- Cancelled
   else
      htp.formSelectOption( LNG5.BKN_TXT_009 ); -- Cancelled
   end if;
   if c1rec.status = LNG5.BKN_TXT_006 then
      htp.formSelectOption( LNG5.BKN_TXT_006, cattributes=>'SELECTED' ); -- Full booking
   else
      htp.formSelectOption( LNG5.BKN_TXT_006 ); -- Full booking
   end if;
   if c1rec.status = 'Visit Complete' then
      htp.formSelectOption( 'Visit Complete', cattributes=>'SELECTED' ); -- Visit Complete
   else
      htp.formSelectOption( 'Visit Complete' ); -- Visit Complete
   end if;
   if c1rec.status = LNG3.ADM_TXT_433 then
      htp.formSelectOption( LNG3.ADM_TXT_433, cattributes=>'SELECTED' ); -- Deleted
   else
      htp.formSelectOption( LNG3.ADM_TXT_433 ); -- Deleted
   end if;
   if c1rec.status = 'Problem' then
      htp.formSelectOption( 'Problem', cattributes=>'SELECTED' ); -- Problem
   else
      htp.formSelectOption( 'Problem' ); -- Deleted
   end if;
   htp.formSelectClose;
   htp.p( '</TD>' );
   htp.tableRowClose;
   -- Date of visit
   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_067 ), cattributes=>rTheme.qbground );
   htp.tableData( htf.formText( 'p_date', cvalue=>TO_CHAR( c1rec.date_time, LNG.MASK ) ), cattributes=>rTheme.qcbground );
   htp.tableRowClose;
   -- Time of visit
   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_068 ), cattributes=>rTheme.qbground );
   htp.tableData( htf.formText( 'p_time', cvalue=>TO_CHAR( c1rec.date_time, LNG.TSMASK_ONLY ) ), cattributes=>rTheme.qcbground );
   htp.tableRowClose;
   -- Made by
   open c6( c1rec.made_by );
   fetch c6 into c6rec;
   close c6;

   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Booked by' ), cattributes=>rTheme.qbground );
   htp.tableData( c6rec.billing_name, cattributes=>rTheme.qcbground );
   htp.tableRowClose;
   -- Year Level
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Year level' ), cattributes=>rTheme.qbground );
   htp.tableData( c1rec.school_year, cattributes=>rTheme.qcbground );
   htp.tableRowClose;
   -- Type of visit
   htp.tableRowOpen;
   -- old
   --htp.tableData( htf.bold( 'Type of visit' ), cattributes=>rTheme.qbground );
   --htp.tableData( getVisitTypeClass( c1rec.visit_type ) || ' ( id=' || c1rec.visit_type || ' )', cattributes=>rTheme.qcbground );
   htp.tableData( htf.bold( 'Type of visit' ), cattributes=>rTheme.qbground );
   open c9( c1rec.visit_type );
   fetch c9 into c9rec;
   close c9;
   htp.tableData( c9rec.visit_type_name, cattributes=>rTheme.qcbground );
   htp.tableRowClose;

   if c9rec.is_paid_program = 'T'
    then
     htp.tableRowOpen;
     htp.tableData( htf.bold( 'Who is to pay' ), cattributes=>rTheme.qbground );
     htp.p( '<TD ' || rTheme.qcbground || '>' );
     if c1rec.paid_by = 'E' then
        htp.formRadio( 'creditor', 'E', 'checked' );
     else
        htp.formRadio( 'creditor', 'E' );
     end if;
     htp.p( 'School' );
     htp.nl;
     if c1rec.paid_by = 'T' then
        htp.formRadio( 'creditor', 'T', 'checked' );
     else
        htp.formRadio( 'creditor', 'T' );
     end if;
     htp.p( 'Bus company' );
     htp.p( '</TD>' );
     htp.tableROwClose;
   else
    htp.formhidden( 'creditor', null );
   end if;

   -- Number of students
   htp.tableRowOpen;
   htp.tableData( htf.bold( lng5.BKN_TXT_036 ), cattributes=>rTheme.qbground );
   htp.tableData( htf.formText( 'p_num_of_students', cvalue=>c1rec.num_of_students ), cattributes=>rTheme.qcbground );
   htp.tableRowClose;
   -- Number of adults
   htp.tableRowOpen;
   htp.tableData( htf.bold( lng5.BKN_TXT_048 ), cattributes=>rTheme.qbground );
   htp.tableData( htf.formText( 'p_num_of_adults', cvalue=>c1rec.num_of_adults ), cattributes=>rTheme.qcbground );
   htp.tableRowClose;
   --
   -- If the booking is for a paid program then show the chosen programs
   --
   if getVisitTypeClass( c1rec.visit_type ) = LNG5.BKN_TXT_002 then
      htp.tableRowOpen( cvalign=>'TOP' );
      htp.tableData( htf.bold( LNG5.BKN_TXT_073 ) || ' ' || htf.anchor( 'bkn.select_programs' || '?surl=' || surl || '&acid=' || acid || '&bid=' || bid || '&rurl=' || rurl || '&login_type=MANUFACTURER' || '&msg=', LNG5.BKN_TXT_007 ), cattributes=>rTheme.qbground );
      htp.p( '<TD ' || rTheme.qcbground || '>' );
      htp.tableOpen( cattributes=>'border="0" cellpadding="0" cellspacing="0" width="100%"' );
      for c2rec in c2( bid ) loop
         htp.tableRowOpen( cvalign=>'top' );
         htp.tableData( c2rec.num_of_visitors );
         htp.tableData( 'x' );
         htp.tableData( c2rec.program_name );
         htp.tableRowClose;
      end loop;
      htp.tableClose;
      htp.p( '</TD>' );
      htp.tableRowClose;
   end if;
   -- School and bus company details
   htp.tableRowOpen;
      htp.p( '<td colspan="2" ' || rTheme.qcbground || '>' );
         htp.tableOpen( cattributes=>'border="0" width="100%"' );
            htp.tableRowOpen( cvalign=>'TOP' );
            htp.tableData( htf.bold( lng5.BKN_TXT_014 ) || ' ' ||
                           htf.anchor( 'scl.mng_booking_profiles?surl=' ||
                           surl || '&acid=' || acid || '&user_type=E' ||
                           '&bid=' || bid || '&pFunctionality=' ||
                           SCL.SELECTION || '&rurl=' || rurl, LNG5.BKN_TXT_007 ),
                           cattributes=>rTheme.qbground || ' width="50%"' );
            htp.tableData( htf.bold( lng5.BKN_TXT_015 ) || ' ' ||
                           htf.anchor( 'scl.mng_booking_profiles?surl=' ||
                           surl || '&acid=' || acid || '&user_type=T' ||
                           '&bid=' || bid || '&pFunctionality=' ||
                           SCL.SELECTION || '&rurl=' || rurl, LNG5.BKN_TXT_007 ),
                           cattributes=>rTheme.qbground || ' width="50%"' );
            htp.tableRowClose;
            htp.tableRowOpen( cvalign=>'TOP' );
            -- School details
            open c4( c1rec.school_id );
            fetch c4 into c4rec;
            close c4;
            htp.p( '<TD ' || rTheme.qcbground || '>' );
               htp.p( c4rec.billing_name ); htp.nl;
               htp.p( c4rec.billing_street ); htp.nl;
               htp.p( c4rec.billing_suburb ); htp.nl;
               htp.p( c4rec.billing_postcode || ' ' || c4rec.billing_state ); htp.nl; htp.nl;
               --htp.p( c4rec.sendto_name ); htp.nl;
               htp.p( '(p) ' || c4rec.billing_phone ); htp.nl;
               htp.p( '(f) ' || c4rec.billing_fax ); htp.nl;
               htp.p( '(e) ' || c4rec.billing_email );
            htp.p( '</TD>' );

            if c1rec.bus_company_id is not null then
               open c5( c1rec.bus_company_id );
               fetch c5 into c5rec;
               close c5;
               htp.p( '<TD ' || rTheme.qcbground || '>' );
                  htp.p( c5rec.billing_name ); htp.nl;
                  htp.p( c5rec.billing_street ); htp.nl;
                  htp.p( c5rec.billing_suburb ); htp.nl;
                  htp.p( c5rec.billing_postcode || ' ' || c5rec.billing_state ); htp.nl;
                  htp.p( c5rec.sendto_name ); htp.nl;
                  htp.p( '(p) ' || c5rec.billing_phone ); htp.nl;
                  htp.p( '(f) ' || c5rec.billing_fax ); htp.nl;
                  htp.p( '(e) ' || c5rec.billing_email );
               htp.p( '</TD>' );
            else
               htp.tableData( '&nbsp', cattributes=>rTheme.qcbground );
            end if;
            htp.tableRowClose;
         htp.tableClose;
      htp.p( '</td>' );
   htp.tableRowClose;
   -- Teacher name
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Teacher name' ), cattributes=>rTheme.qbground );
   --htp.tableData( c1rec.contact_person, cattributes=>rTheme.qcbground );
   htp.tableData( htf.formText( 'p_contact_person', cvalue=>c1rec.contact_person ), cattributes=>rTheme.qcbground );
   htp.tableRowClose;
   -- Teacher email
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Teacher email' ), cattributes=>rTheme.qbground );
   --htp.tableData( c1rec.contact_email, cattributes=>rTheme.qcbground );
   htp.tableData( htf.formText( 'p_contact_email', cvalue=>c1rec.contact_email ), cattributes=>rTheme.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Comments' ), cattributes=>rTheme.qbground );
   htp.tableData( '&nbsp;' || c1rec.requirements, cattributes=>rTheme.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( lng.GLB_TXT_078 ), cattributes=>rTheme.qbground );
   htp.tableData( c1rec.date_created, cattributes=>rTheme.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( lng.PHG_TXT_463 ), cattributes=>rTheme.qbground );
   htp.tableData( c1rec.date_modified, cattributes=>rTheme.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Reception note' ), cattributes=>rTheme.qbground );
   htp.tableData( '&nbsp;', cattributes=>rTheme.qcbground );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( htf.formTextAreaOpen( 'p_reception_note', def.TEXTBOX_HEIGHT, def.TEXTBOX_WIDTH ) || c1rec.reception_note || htf.formTextAreaClose, cattributes=>rTheme.qcbground || ' colspan="2"' );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Admin note' ), cattributes=>rTheme.qbground );
   htp.tableData( '&nbsp;' );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( htf.formTextAreaOpen( 'p_admin_note', def.TEXTBOX_HEIGHT, def.TEXTBOX_WIDTH ) || c1rec.admin_note || htf.formTextAreaClose, cattributes=>rTheme.qcbground || ' colspan="2"' );
   htp.tableRowClose;
   htp.tableClose;

   htp.formSubmit( 'action', lng5.BKN_BUT_003 );
   htp.formSubmit( 'action', lng.GLB_TXT_060 );
   htp.formSubmit( 'action', 'View changes' );

   htp.formClose;

   htp.p( '</CENTER>' );
   dapi.pageClose;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'LAB_BOOKING_DETAILS', errmsg=>sqlerrm );
end lab_booking_details;

procedure modify_booking_details(
  surl varchar2,
  acid integer default null,
  action varchar2,
  p_booking_id      varchar2,
  p_date            varchar2,
  p_time            varchar2,
  p_status          varchar2,
  p_num_of_students varchar2,
  p_num_of_adults   varchar2,
  p_reception_note  varchar2,
  p_admin_note      varchar2,
  p_contact_person  varchar2,
  p_contact_email   varchar2,
  creditor          varchar2,
  rurl              varchar2 default null )
as

   cursor c1( cbid integer ) is
   	select date_time, num_of_students, num_of_adults, status
   	from booking where booking_id = cbid;

   c1rec 		c1%ROWTYPE;
   --
   -- Work variables
   --
   new_date_time 	date;
   old_date_time 	date;
   time_shift   	number;
   n_aid         	integer;
   email_sendto 	varchar2( 100 );

begin
  	if action = lng.GLB_TXT_060 then
      open c1( p_booking_id );
      fetch c1 into c1rec;
      close c1;
      --
      -- Record the changes in the audit file
      --
      n_aid := dapi.getAccountId;
      if nvl( c1rec.num_of_students, 0 ) <> nvl( p_num_of_students, 0 ) then
         insert into audit_booking values( SYSDATE, p_booking_id, 'NUM_OF_STUDENTS', lng5.BKN_TXT_036, c1rec.num_of_students, p_num_of_students, n_aid );
      end if;
      if nvl( c1rec.num_of_adults, 0 ) <> nvl( p_num_of_adults, 0 ) then
         insert into audit_booking values( SYSDATE, p_booking_id, 'NUM_OF_ADULTS', lng5.BKN_TXT_048, c1rec.num_of_adults, p_num_of_adults, n_aid );
      end if;
      if nvl( c1rec.status, 'NULL' ) <> nvl( p_status, 'NULL' ) then
         insert into audit_booking values( SYSDATE, p_booking_id, 'STATUS', lng.PHG_TXT_082, c1rec.status, p_status, n_aid );
      end if;
      --
      -- Calculate the shift in time
      --
      new_date_time := TO_DATE( p_date || p_time, lng3.ADM_DATE_02 || lng.TSMASK_ONLY );
      time_shift := new_date_time - c1rec.date_time;
      --
      -- Update booking record
      --
      if send_email( surl, acid, p_booking_id, p_status, email_sendto ) then commit; else rollback; end if;
      update booking
      set
         status = p_status,
         date_time = new_date_time,
         num_of_students = p_num_of_students,
         num_of_adults   = p_num_of_adults,
         reception_note  = substr(p_reception_note,1,2000),
         admin_note      = substr(p_admin_note,1,2000),
         contact_person  = p_contact_person,
         contact_email   = p_contact_email,
         paid_by         = creditor,
         date_modified   = SYSDATE
      where
         booking_id = p_booking_id;
      --
      -- Delete the records from resource use
      --
      delete from resource_use where booking_id = p_booking_id;

      if create_reservation( surl, acid, p_booking_id ) then
         null;
      end if;
      /*
      update resource_use
      set
         date_time_from = date_time_from + time_shift,
         date_time_to = date_time_to + time_shift
      where
         booking_id = p_booking_id;
      */
      commit;
      lab_booking_details( surl, acid, p_booking_id, rurl=>rurl );
   elsif action = 'View changes' then
      lab_view_changes( surl, acid, p_booking_id, rurl );
   elsif action = lng5.BKN_BUT_003 then
      if rurl is not null then
         execute immediate
            'begin ' || rurl || ' end;'
         using surl, acid;
      end if;
   end if;
end modify_booking_details;

procedure lab_view_changes( surl varchar2, acid integer default null, bid varchar2, rurl varchar2 default null )
as
   cursor c1( cbid integer ) is
   	select * from audit_booking where booking_id = cbid order by date_time desc;
   c1rec c1%ROWTYPE;
   cursor c2( ccid integer ) is
   	select billing_name from customer_contact
   	where aid = ccid;
   c2rec c2%ROWTYPE;
   cursor c3( cmid integer ) is
   	select username from manufacturer where manufacturer_id = cmid;
   c3rec c3%ROWTYPE;
   --
   -- Work variables
   --
   rTheme   theme%ROWTYPE;
begin
   if not dapi.init( surl, 'BKN.LAB_VIEW_CHANGES', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   dapi.setTitle( 'List of changes made on bookings' );
   dapi.pageOpen;

   htp.p( '<CENTER>' );

   htp.tableOpen( cattributes=>'cellspacing="2" cellpadding="2" border="1"' );
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Date and time' ), cattributes=>rTheme.qbground );
   htp.tableData( htf.bold( 'Booking ID' ), cattributes=>rTheme.qbground );
   htp.tableData( htf.bold( 'Column name' ), cattributes=>rTheme.qbground );
   htp.tableData( htf.bold( 'Column description' ), cattributes=>rTheme.qbground );
   htp.tableData( htf.bold( 'Original data' ), cattributes=>rTheme.qbground );
   htp.tableData( htf.bold( 'Changed data' ), cattributes=>rTheme.qbground );
   htp.tableData( htf.bold( 'Made by' ), cattributes=>rTheme.qbground );
   htp.tableRowClose;
   for c1rec in c1( bid ) loop
      htp.tableRowOpen;
      htp.tableData( TO_CHAR( c1rec.date_time, lng.TSMASK ), cattributes=>rTheme.qcbground );
      htp.tableData( c1rec.booking_id, cattributes=>rTheme.qcbground );
      htp.tableData( c1rec.column_name, cattributes=>rTheme.qcbground );
      htp.tableData( c1rec.column_desc, cattributes=>rTheme.qcbground );

      if c1rec.column_name = 'SCHOOL_ID' then
      	c2rec := null;
      	open c2( c1rec.original_value );
      	fetch c2 into c2rec;
      	close c2;
         htp.tableData( c2rec.billing_name, cattributes=>rTheme.qcbground );
      elsif c1rec.column_name = 'BUS_COMPANY_ID' then
      	c2rec := null;
      	open c2( c1rec.original_value );
      	fetch c2 into c2rec;
      	close c2;
         htp.tableData( c2rec.billing_name, cattributes=>rTheme.qcbground );
      else
      	htp.tableData( c1rec.original_value, cattributes=>rTheme.qcbground );
      end if;

      if c1rec.column_name = 'SCHOOL_ID' then
      	c2rec := null;
      	open c2( c1rec.changed_value );
      	fetch c2 into c2rec;
      	close c2;
         htp.tableData( c2rec.billing_name, cattributes=>rTheme.qcbground );
      elsif c1rec.column_name = 'BUS_COMPANY_ID' then
      	c2rec := null;
      	open c2( c1rec.changed_value );
      	fetch c2 into c2rec;
      	close c2;
         htp.tableData( c2rec.billing_name, cattributes=>rTheme.qcbground );
      else
      	htp.tableData( c1rec.changed_value, cattributes=>rTheme.qcbground );
      end if;

      open c3( c1rec.aid );
      fetch c3 into c3rec;
      close c3;
      htp.tableData( c3rec.username, cattributes=>rTheme.qcbground );
      htp.tableRowClose;
   end loop;
   htp.tableClose;

   htp.formOpen( 'bkn.lab_booking_details' );
   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   htp.formHidden( 'bid', bid );
   htp.formHidden( 'rurl', rurl );
   htp.formSubmit( 'action', lng5.BKN_BUT_003 );
   htp.formClose;

   htp.p( '</CENTER>' );
   dapi.pageClose;
   exception when others then
      htp.tableClose;
      glbx.error_details( PACKAGE_NAME, 'LAB_VIEW_CHANGES', errmsg=>sqlerrm );
end lab_view_changes;

procedure lab_list_of_bookings( surl varchar2, acid integer default null,
                                p_status varchar2 default null,
                                p_booking_id varchar2 default null,
                                p_date_from varchar2 default null,
                                p_date_to varchar2 default null,
                                p_made_by varchar2 default null,
                                p_visitor varchar2 default null,
                                pVisitType varchar2 default null,
                                pMadeFrom varchar2 default null,
                                pMadeTo varchar2 default null,
                                action in varchar2 default null,
                                firsttime in char default 'F')
as
   -- xxx NOTE: Set to RULE because if set to anything a theoretical bug in V8.1.7.2 (not tested yet in V8.1.7.4 or above) causes very slow performance.
   cursor c1( c_made_by varchar2, c_visitor varchar2, c_status varchar2,
              c_booking_id integer, cdate_from varchar2, cdate_to varchar2,
              cVisitType integer, cMadeFrom varchar2, cMadeTo varchar2 ) is
      select /*+ RULE */
             b.booking_id booking_id, b.status status, b.date_time date_time,
             cm.billing_name made_by, cv.billing_name visitor,
             b.contact_person contact_person, b.contact_phone contact_phone,
             b.contact_email contact_email, b.school_id school_id,
             b.bus_company_id bus_company_id, b.num_of_students num_of_students,
             vt.class visit_class, b.date_created date_created
      from booking b,
           customer_contact cm, /*Customer contact made by*/
           customer_contact cv, /*Customer contact visitor*/
           visit_types vt
      where ( ( c_made_by is null ) or ( c_made_by is not null and upper( cm.billing_name ) like '%' || upper( c_made_by ) || '%' ) ) and
            ( ( c_visitor is null ) or ( c_visitor is not null and upper( cv.billing_name ) like '%' || upper( c_visitor ) || '%' ) ) and
            ( ( c_status is null ) or ( c_status is not null and INSTR( c_status || ',', status || ',' ) > 0 ) ) and
            ( ( c_booking_id is null ) or ( c_booking_id is not null and b.booking_id = c_booking_id ) ) and
            ( ( cdate_from is null ) or ( cdate_from is not null and date_time >= TO_DATE( cdate_from, lng3.ADM_DATE_02 ) ) ) and
            ( ( cdate_to is null ) or ( cdate_to is not null and date_time <= TO_DATE( cdate_to, lng3.ADM_DATE_02 )+1 ) ) and
            ( ( cVisitType is null ) or ( cVisitType is not null and b.visit_type = cVisitType ) ) and
            ( ( cMadeFrom is null ) or ( cMadeFrom is not null and DATE_CONFIRMATION_SENT >= TO_DATE( cMadeFrom, lng3.ADM_DATE_02 ) ) ) and
            ( ( cMadeTo is null ) or ( cMadeTo is not null and DATE_CONFIRMATION_SENT <= TO_DATE( cMadeTo, lng3.ADM_DATE_02 )+1 ) ) and
            ( cm.aid = b.made_by ) and ( cv.aid = b.school_id ) and ( vt.visit_type_id = b.visit_type) and status != 'Deleted'
      order by
         date_time;

   -- xxx NOTE: Set to RULE because if set to anything a theoretical bug in V8.1.7.2 (not tested yet in V8.1.7.4 or above) causes very slow performance.
   cursor c2( c_made_by varchar2, c_visitor varchar2, c_status varchar2,
              c_booking_id integer, cdate_from varchar2, cdate_to varchar2,
              cVisitType integer, cMadeFrom varchar2, cMadeTo varchar2 ) is
      select /*+ RULE */ count( 'x' ) total
      from booking b,
           customer_contact cm, /*Customer contact made by*/
           customer_contact cv, /*Customer contact visitor*/
           visit_types vt
      where ( ( c_made_by is null ) or ( c_made_by is not null and upper( cm.billing_name ) like '%' || upper( c_made_by ) || '%' ) ) and
            ( ( c_visitor is null ) or ( c_visitor is not null and upper( cv.billing_name ) like '%' || upper( c_visitor ) || '%' ) ) and
            ( ( c_status is null ) or ( c_status is not null and INSTR( c_status || ',', status || ',' ) > 0 ) ) and
            ( ( c_booking_id is null ) or ( c_booking_id is not null and b.booking_id = c_booking_id ) ) and
            ( ( cdate_from is null ) or ( cdate_from is not null and date_time >= TO_DATE( cdate_from, lng3.ADM_DATE_02 ) ) ) and
            ( ( cdate_to is null ) or ( cdate_to is not null and date_time <= TO_DATE( cdate_to, lng3.ADM_DATE_02 )+1 ) ) and
            ( ( cVisitType is null ) or ( cVisitType is not null and b.visit_type = cVisitType ) ) and
            ( ( cMadeFrom is null ) or ( cMadeFrom is not null and DATE_CONFIRMATION_SENT >= TO_DATE( cMadeFrom, lng3.ADM_DATE_02 ) ) ) and
            ( ( cMadeTo is null ) or ( cMadeTo is not null and DATE_CONFIRMATION_SENT <= TO_DATE( cMadeTo, lng3.ADM_DATE_02 )+1 ) ) and
            ( cm.aid = b.made_by ) and ( cv.aid = b.school_id ) and ( vt.visit_type_id = b.visit_type) and status != 'Deleted';

   cursor c3( cAccountId integer ) is
      select visit_type_id, visit_type_name, class
      from visit_types
      where pid = (select pid from customer_account where aid = cAccountId );

   c1rec 		c1%ROWTYPE;
   rTheme 		THEME%ROWTYPE;
   rurl 		varchar2( 1000 );
   lCount 		integer;
   lPhotographerId 	integer;
   dt			date;

begin
   if not dapi.init( surl, 'BKN.LAB_LIST_OF_BOOKINGS', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   rTheme := dapi.getLFRecord;
   dapi.setTitle( 'List of bookings with status ' || p_status );
   dapi.pageOpen;
   rurl := 'bkn.lab_list_of_bookings( :surl, :acid );';
   htp.p( '<CENTER>' );

   htp.formOpen( 'bkn.lab_list_of_bookings_filter', cattributes=>'NAME="filter"' );
   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   --
   -- Create table for search options
   --
   htp.tableOpen( cattributes=>'border="1" cellpadding="2" cellspacing="2"' );
   --
   -- Search for Booking request number and status
   --
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Booking request number' ), cattributes=>rTheme.qbground );
   htp.tableData( htf.formText( 'p_booking_id', cvalue=>p_booking_id ), cattributes=>rTheme.qcbground );
   htp.tableData( htf.bold( 'View bookings with status' ), cattributes=>rTheme.qbground );
   htp.p( '<TD ' || rTheme.qcbground || ' ALIGN="LEFT">' );
   --
   -- Create status drop down list
   --
   htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
   htp.tablerowopen;
   htp.formHidden( 'p_status', '0' );
   if INSTR( p_status, LNG5.BKN_TXT_004 ) > 0 then
      htp.tabledata( htf.formCheckbox( 'p_Status', LNG5.BKN_TXT_004, 'CHECKED' ));
   else
   	  htp.tabledata(htf.formCheckbox( 'p_Status', LNG5.BKN_TXT_004 ));
   end if;
   htp.tabledata( LNG5.BKN_TXT_004 );

   if INSTR( p_status || ',', LNG5.BKN_TXT_005 || ',' ) > 0 then
      htp.tabledata(htf.formCheckbox( 'p_Status', LNG5.BKN_TXT_005, 'CHECKED' ));
   else
   	  htp.tabledata(htf.formCheckbox( 'p_Status', LNG5.BKN_TXT_005 ));
   end if;
   htp.tabledata( LNG5.BKN_TXT_005 );
   htp.tablerowclose;

   htp.tablerowopen;
   if INSTR( p_status, 'Reservation Accepted' ) > 0 then
      htp.tabledata(htf.formCheckbox( 'p_Status', 'Reservation Accepted', 'CHECKED' ));
   else
   	  htp.tabledata(htf.formCheckbox( 'p_Status', 'Reservation Accepted' ));
   end if;
   htp.tabledata( 'Reservation Accepted' );

   if INSTR( p_status, LNG5.BKN_TXT_009 ) > 0 then
      htp.tabledata(htf.formCheckbox( 'p_Status', LNG5.BKN_TXT_009, 'CHECKED' ));
   else
   	  htp.tabledata(htf.formCheckbox( 'p_Status', LNG5.BKN_TXT_009 ));
   end if;
   htp.tabledata( LNG5.BKN_TXT_009 );
   htp.tablerowclose;

   htp.tablerowopen;
   if INSTR( p_status, LNG5.BKN_TXT_006 ) > 0 then
      htp.tabledata( htf.formCheckbox( 'p_Status', LNG5.BKN_TXT_006, 'CHECKED' ));
   else
   	  htp.tabledata( htf.formCheckbox( 'p_Status', LNG5.BKN_TXT_006 ));
   end if;
   htp.tabledata( LNG5.BKN_TXT_006 );
   if INSTR( p_status, 'Visit Complete' ) > 0 then
      htp.tabledata( htf.formCheckbox( 'p_Status', 'Visit Complete', 'CHECKED' ));
   else
   	  htp.tabledata( htf.formCheckbox( 'p_Status', 'Visit Complete' ));
   end if;
   htp.tabledata( 'Visit Complete' );
   htp.tablerowclose;

   htp.tablerowopen;
   if INSTR( p_status, 'Problem' ) > 0 then
      htp.tabledata( htf.formCheckbox( 'p_Status', 'Problem', 'CHECKED' ));
   else
   	  htp.tabledata( htf.formCheckbox( 'p_Status', 'Problem' ));
   end if;
   htp.tabledata( 'Problem' );
   htp.tablerowclose;
   htp.tableclose;
   htp.p( '</TD>' );
   htp.tableRowClose;
   --
   -- Search for Made by or Visitor
   --
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Made by' ), cattributes=>rTheme.qbground );
   htp.tableData( htf.formText( 'p_made_by', cvalue=>p_made_by ), cattributes=>rTheme.qcbground );
   htp.tableData( htf.bold( 'Visitor' ), cattributes=>rTheme.qbground );
   htp.tableData( htf.formText( 'p_visitor', cvalue=>p_visitor ), cattributes=>rTheme.qcbground );
   htp.tableRowClose;
   --
   -- Search for from date to to date
   --
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Visit date from ' ) || lng3.ADM_DATE_02, cattributes=>rTheme.qbground );
   htp.tableData( htf.formText( 'p_date_from', cvalue=>p_date_from, cattributes=>'STYLE="text-transform: UPPERCASE"' ), cattributes=>rTheme.qcbground );
   htp.tableData( htf.bold( 'Visit date to ' ) || lng3.ADM_DATE_02, cattributes=>rTheme.qbground );
   htp.tableData( htf.formText( 'p_date_to', cvalue=>p_date_to, cattributes=>'STYLE="text-transform: UPPERCASE"' ), cattributes=>rTheme.qcbground );
   htp.tableRowClose;
   -- Search for the date that the booking has been made
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Date Changed to Full Booking from' || ' ' ) || LNG3.ADM_DATE_02, cattributes=>rTheme.qbground );
   htp.tableData( htf.formText( 'pMadeFrom', cvalue=>pMadeFrom, cattributes=>'STYLE="text-transform: UPPERCASE"' ), cattributes=>rTheme.qcbground );
   htp.tableData( htf.bold( 'Date Changed to Full Booking to' || ' ' ) || LNG3.ADM_DATE_02, cattributes=>rTheme.qbground );
   htp.tableData( htf.formText( 'pMadeTo', cvalue=>pMadeTo, cattributes=>'STYLE="text-transform: UPPERCASE"' ), cattributes=>rTheme.qcbground );
   htp.tableRowClose;
   -- Search on visit type and number of students
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Visit type' ), cattributes=>rTheme.qbground );
   htp.p( '<td ' || rTheme.qcbground || '>' );
   htp.formSelectOpen( 'pVisitType', cattributes=>'style="width: 192;"' );
   htp.formSelectOption( null );
   for visit in c3( acid ) loop
      if visit.visit_type_id = pVisitType then
         htp.formSelectOption( visit.visit_type_name, cselected=>'SELECTED',
                               cattributes=>'value="' || visit.visit_type_id || '"' );
      else
         htp.formSelectOption( visit.visit_type_name,
                               cattributes=>'value="' || visit.visit_type_id || '"' );
      end if;
   end loop;
   htp.formSelectClose;
   htp.p( '</td>' );
   htp.tableData( '&nbsp;' );
   htp.tableData( '&nbsp;' );
   htp.tableRowClose;
   htp.tableClose;
   htp.formReset( 'Reset' );
   htp.formSubmit( 'action', 'View' );
   htp.formClose;

   if firsttime = 'T'
    then
     htp.p( '</CENTER>' );
     dapi.pageClose;
     return;
   end if;

   -- Check if dates are OK:
   begin
    dt := TO_DATE( p_date_from, lng3.ADM_DATE_02 );
   exception
    when others then
     htp.nl;
     htp.bold( 'Invalid Date:' || p_date_from );
     htp.nl;
     htp.bold( 'Must be of format:' || lng3.ADM_DATE_02 );
     htp.nl;
     dapi.pageClose;
     return;
   end;

   -- Check if dates are OK:
   begin
    dt := TO_DATE( p_date_to, lng3.ADM_DATE_02 );
   exception
    when others then
     htp.nl;
     htp.bold( 'Invalid Date:' || p_date_to );
     htp.nl;
     htp.bold( 'Must be of format:' || lng3.ADM_DATE_02 );
     htp.nl;
     dapi.pageClose;
     return;
   end;

   open c2( p_made_by, p_visitor, p_status, p_booking_id, p_date_from,  p_date_to, pVisitType, pMadeFrom, pMadeTo );
   fetch c2 into lCount;
   close c2;

   if lCount = 0 then
      htp.p( 'No rows found' );
   elsif lCount > 250 and ( p_made_by is null and p_visitor is null and p_status is null and p_booking_id is null and p_date_from is null and p_date_to is null ) then
      htp.p( 'Too many rows returned' );
   else
      htp.formOpen( 'bkn.change_booking_status' );
      htp.formHidden( 'surl', surl );
      htp.formHidden( 'acid', acid );

      htp.tableOpen( cattributes=>'border="1" cellpadding="0" cellspacing="1"' );
      htp.tableRowOpen;
      htp.tableData( htf.bold( 'Booking request number' ), cattributes=>rTheme.qbground );
      htp.tableData( htf.bold( 'Status' ), cattributes=>rTheme.qbground );
      htp.tableData( htf.bold( 'Made by' ), cattributes=>rTheme.qbground );
      htp.tableData( htf.bold( 'Visitor' ), cattributes=>rTheme.qbground );
      htp.tableData( htf.bold( 'Date and time of visit' ), cattributes=>rTheme.qbground );
      htp.tableData( htf.bold( 'Booking made on' ), cattributes=>rTheme.qbground );
      htp.tableData( htf.bold( 'Visit Type' ), cattributes=>rTheme.qbground );
      htp.tableData( htf.bold( 'Number of students' ), cattributes=>rTheme.qbground );
      htp.tableData( htf.bold( 'Modify status' ), cattributes=>rTheme.qbground );
      htp.tableRowClose;

      for c1rec in c1( p_made_by, p_visitor, p_status, p_booking_id, p_date_from,  p_date_to, pVisitType, pMadeFrom, pMadeTo ) loop
         htp.tableRowOpen;
         -- Italic if status = Visit Complete
         if c1rec.status = 'Visit Complete'
          then
           htp.tableData( htf.formHidden( 'p1', c1rec.booking_id ) ||
                          htf.anchor( 'bkn.lab_booking_details?surl=' || surl ||
                          '&acid=' || acid || '&bid=' || c1rec.booking_id ||
                          '&rurl=' || rurl, htf.bold( htf.italic(c1rec.booking_id )) ),
                          cattributes=>rTheme.qcbground );
          else
           htp.tableData( htf.formHidden( 'p1', c1rec.booking_id ) ||
                          htf.anchor( 'bkn.lab_booking_details?surl=' || surl ||
                          '&acid=' || acid || '&bid=' || c1rec.booking_id ||
                          '&rurl=' || rurl, htf.bold( c1rec.booking_id ) ),
                          cattributes=>rTheme.qcbground );
         end if;
         htp.tableData( c1rec.status, cattributes=>rTheme.qcbground );
         htp.tableData( c1rec.made_by, cattributes=>rTheme.qcbground );
         htp.tableData( c1rec.visitor, cattributes=>rTheme.qcbground );
         htp.tableData( replace(TO_CHAR( c1rec.date_time, lng.TSMASK ),' ',htf.nl),
                        cattributes=>rTheme.qcbground );
         htp.tableData( replace(TO_CHAR( c1rec.date_created, lng.TSMASK ),' ',htf.nl),
                        cattributes=>rTheme.qcbground );
         htp.tableData( c1rec.visit_class, cattributes=>rTheme.qcbground );
         htp.tableData( NVL( TO_CHAR( c1rec.num_of_students ), '&nbsp;' ),
                        cattributes=>rTheme.qcbground );
         --
         -- Create status drop down list
         --
         htp.p( '<TD ' || rTheme.qcbground || '>' );
         htp.formSelectOpen( 'p2' );
         htp.formSelectOption( '' );
         htp.formSelectOption( LNG5.BKN_TXT_004 );
         htp.formSelectOption( LNG5.BKN_TXT_005 );
         htp.formSelectOption( 'Reservation Accepted' );
         htp.formSelectOption( LNG5.BKN_TXT_009 );
         htp.formSelectOption( LNG5.BKN_TXT_006 );
         htp.formSelectOption( 'Visit Complete' );
         htp.formSelectOption( LNG3.ADM_TXT_433 );
         htp.formSelectOption( 'Problem' );
         htp.formSelectClose;
         htp.p( '</TD>' );
         htp.tableRowClose;
      end loop;
      htp.tableClose;

      -- htp.formSubmit( 'action', lng5.BKN_BUT_003 );
      htp.formSubmit( 'action', lng.GLB_TXT_060 );
      htp.formClose;
   end if;
   htp.p( '</CENTER>' );
   dapi.pageClose;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'LAB_LIST_OF_BOOKINGS', errmsg=>sqlerrm );
end lab_list_of_bookings;

procedure lab_list_of_bookings_filter( surl varchar2, acid integer default null,
                                       p_status glbx.MYARRAY,
                                       p_booking_id varchar2 default null,
                                       p_date_from varchar2 default null,
                                       p_date_to varchar2 default null,
                                       p_made_by varchar2 default null,
                                       p_visitor varchar2 default null,
                                       pVisitType varchar2 default null,
                                       pMadeFrom varchar2 default null,
                                       pMadeTo varchar2 default null,
                                       action in varchar2 default null )
as
   lStatusList varchar2( 4000 ) := NULL;
begin

   for i in p_status.first..p_status.last loop
      if p_status( i ) != '0' then
         lStatusList := lStatusList || p_status( i ) || ',';
      end if;
   end loop;
   lab_list_of_bookings( surl, acid, lStatusList, p_booking_id, p_date_from, p_date_to, p_made_by, p_visitor, pVisitType, pMadeFrom, pMadeTo, action );

end lab_list_of_bookings_filter;

procedure change_booking_status( surl in varchar2, acid in varchar2 default null, p1 in glbx.myArray, p2 in glbx.myArray, action in varchar2 )
as
   cursor c1( cbid integer ) is select status from booking where booking_id = cbid;
   c1rec 	c1%ROWTYPE;
   --
   -- Work variables
   --
   sess_id 	integer;
   n_aid   	integer;
   email_sendto varchar2( 100 );
begin
   if not dapi.init( surl, 'BKN.CHANGE_BOOKING_STATUS', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;

   n_aid := dapi.getAccountId;
   if action in ( lng.GLB_TXT_060 ) then
      for i in p2.first..p2.last loop
         if p2( i ) is not null then
         	c1rec := null;
      		open c1( p1( i ) );
		      fetch c1 into c1rec;
		      close c1;
   		   if nvl( c1rec.status, 'NULL' ) <> nvl( p2( i ), 'NULL' ) then
	   		   insert into audit_booking values( SYSDATE, p1( i ), 'STATUS', lng.PHG_TXT_082, c1rec.status, p2( i ), n_aid );
		      end if;
            if send_email( surl, acid, p1( i ), p2( i ), email_sendto ) then commit; else rollback; end if;
            update booking set status = p2( i ) where booking_id = p1( i );
         end if;
      end loop;
   end if;

   commit;

   if action in ( lng.GLB_TXT_060 ) then
      lab_list_of_bookings( surl, acid, firsttime=>'T'  );
   elsif action in ( lng5.BKN_BUT_003 ) then
   	lab.mng_booking( surl );
   end if;

   exception when others then
      glbx.error_details( PACKAGE_NAME, 'CHANGE_BOOKING_STATUS', errmsg=>sqlerrm );
end change_booking_status;

procedure enter_booking_details( surl varchar2, acid integer, bid varchar2 default null, action varchar2 default null )
as
   cursor c0( cSchoolId integer, cCompanyId integer, cbid integer ) is
      select
         *
      from
         booking
      where
         ( ( cSchoolId is null ) or ( ( cSchoolId is not null ) and ( school_id = cSchoolId or made_by = cSchoolId ) ) ) and
         ( ( cCompanyId is null ) or ( ( cCompanyId is not null ) and ( bus_company_id = cCompanyId or made_by = cCompanyId ) ) ) and
         ( ( cbid is null ) or ( booking_id = cbid ) ) and
         status in ( lng5.BKN_TXT_005, lng5.BKN_TXT_006, 'Reservation Accepted', 'Visit Complete' );

   cursor c1( cSchoolId integer, cCompanyId integer, cbid integer ) is
      select
         *
      from
         booking
      where
         (
         ( cSchoolId is not null and ( school_id = cSchoolId or made_by = cSchoolId ) ) or
         ( cCompanyId is not null and ( bus_company_id = cCompanyId or made_by = cCompanyId ) ) or
         ( cbid is not null and booking_id = cbid )
         ) and
         status in ( lng5.BKN_TXT_005, lng5.BKN_TXT_006, 'Reservation Accepted', 'Visit Complete' );
   c1rec c1%ROWTYPE;

   cursor c2( caid integer ) is
      select
         cc.user_type,
         cc.billing_name name
      from
         customer_contact cc,
         customer_profile cp
      where
         cp.profile_id = caid and
         cp.profile_id = cc.aid;
   c2rec c2%ROWTYPE;
   --
   -- Work variables
   --
   rTheme		THEME%ROWTYPE;
   lAccountId integer;
   lCompanyId integer;
   lSchoolId  integer;
   profileID  integer;
   lUserType char;
begin
   if not dapi.init( surl, 'BKN.ENTER_BOOKING_DETAILS', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   rTheme := dapi.getLFRecord;
   lAccountId := dapi.getAccountId;
   lUserType := dapi.getUserType;
   dapi.setTitle( LNG5.BKN_TXT_085 );
   dapi.pageOpen;
   --
   -- Determine the type of user
   --
   profileID := dapi.getAccountId;
   lSchoolId := null;
   lCompanyId := null;
   if lUserType = 'E' then
      -- School
      lSchoolId := profileID;
   elsif lUserType = 'T' then
      -- Bus company
      lCompanyId := profileID;
   end if;
   htp.p( '<CENTER>' );
   htp.tableOpen( cattributes=>TABLE_ATTS );
      htp.tableRowOpen;
         htp.tableData( htf.bold( lng5.BKN_TXT_069 ), cattributes=>rTheme.qbground );
         htp.tableData( htf.bold( LNG.PHG_TXT_082 ), cattributes=>rTheme.qbground );
         htp.tableData( htf.bold( LNG5.BKN_TXT_089 ), cattributes=>rTheme.qbground );
         htp.tableData( htf.bold( LNG5.BKN_TXT_071 ), cattributes=>rTheme.qbground );
      htp.tableRowClose;

      for c1rec in c1( lSchoolId, lCompanyId, bid ) loop
         htp.tableRowOpen;
            htp.tableData( htf.anchor2( 'bkn.booking_details?surl=' || surl || '&acid=' || acid || '&bid=' || c1rec.booking_id, c1rec.booking_id ), cattributes=>rTheme.qcbground );
            htp.tableData( c1rec.status, cattributes=>rTheme.qcbground );
            htp.tableData( TO_CHAR( c1rec.date_time, LNG.TSMASK ), cattributes=>rTheme.qcbground );
            open c2( c1rec.made_by );
            fetch c2 into c2rec;
            close c2;
            htp.tableData( c2rec.name, cattributes=>rTheme.qcbground );
         htp.tableRowClose;
      end loop;
   htp.tableClose;
   htp.anchor( 'bkn.typeOfVisit?surl=' || surl || '&acid=' || acid, htf.img( DECS.IMAGE_LOCATION || 'booking/pstep.gif', cattributes=>'border="0"' ) );
   htp.p( '</CENTER>' );
   dapi.pageClose;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'ENTER_BOOKING_DETAILS', errmsg=>sqlerrm );
end enter_booking_details;

procedure list_bookings( surl varchar2, acid integer, bid varchar2 default null, action varchar2 default null )
as
   cursor c1( cbid integer, caid integer ) is
   	select *
   	from booking
   	where
   	   ( ( cbid is null ) or ( cbid is not null and booking_id = cbid ) ) and
   	   ( ( made_by = caid ) or ( school_id = caid ) or ( bus_company_id = caid ) ) and
   	   status in ( lng5.BKN_TXT_005, lng5.BKN_TXT_006, 'Reservation Accepted', 'Visit Complete' );
   --
   -- Look and feel variables
   --
   rTheme		THEME%ROWTYPE;
   theme_rec	theme_types%ROWTYPE;
   sess_id     integer;
   loc         varchar2( 200 );
begin
   if not dapi.init( surl, 'BKN.LIST_BOOKINGS', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   dapi.setTitle( LNG5.BKN_TXT_088 );
   htp.p( '<CENTER>' );

   htp.tableOpen( cattributes=>TABLE_ATTS );
   htp.tableRowOpen;
   htp.tableData( htf.bold( lng5.BKN_TXT_069 ), cattributes=>rTheme.qbground );
   htp.tableData( htf.bold( LNG.PHG_TXT_082 ), cattributes=>rTheme.qbground );
   htp.tableData( htf.bold( LNG5.BKN_TXT_089 ), cattributes=>rTheme.qbground );
   htp.tableData( htf.bold( LNG5.BKN_TXT_071 ), cattributes=>rTheme.qbground );
   htp.tableRowClose;

   for c1rec in c1( bid, acid ) loop
   	htp.tableRowOpen;
   	htp.tableData( htf.anchor2( 'bkn.booking_details?surl=' || surl || '&acid=' || acid || '&bid=' || c1rec.booking_id, c1rec.booking_id ), cattributes=>rTheme.qcbground );
   	htp.tableData( c1rec.status, cattributes=>rTheme.qcbground );
   	htp.tableData( TO_CHAR( c1rec.date_time, LNG.TSMASK ), cattributes=>rTheme.qcbground );
   	htp.tableData( c1rec.contact_person, cattributes=>rTheme.qcbground );
   	htp.tableRowClose;
   end loop;

   htp.tableClose;

   htp.formOpen( 'bkn.enter_booking_details' );
   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   htp.formHidden( 'bid', bid );
   htp.formSubmit( 'action', lng5.BKN_BUT_003 );
   htp.formClose;

   htp.p( '</CENTER>' );

   glbx.close_page( rTheme );
   exception when others then
      htp.tableClose;
      glbx.error_details( PACKAGE_NAME, 'LIST_BOOKINGS', errmsg=>sqlerrm );
end list_bookings;

procedure booking_details( surl varchar2, acid integer default null, bid in varchar2, action in varchar2 default null )
as
   cursor c1( cbid integer, caid integer ) is
      select * from booking
      where booking_id >= cbid;
   c1rec c1%ROWTYPE;

   -- Retrieve booked programs
   cursor c2( cbid integer ) is
      select
         p.umo_id prgid,
         p.program_obj.program_name program_name
      from
         booked_programs bp,
         umo p
      where
         bp.booking_id = cbid and
         p.umo_id = bp.program_id;
   c2rec c2%ROWTYPE;

   -- Retrieve workbook details
   cursor c3( cbid integer ) is
      select w.umo_id wid, w.program_obj.program_name workbook_name
      from booked_workbooks bw, umo w
      where bw.booking_id = cbid and w.umo_id = bw.workbook_id;
   c3rec c3%ROWTYPE;

   -- Retrieve school information
   cursor c4( csid integer ) is select * from customer_contact where aid = csid;
   c4rec c4%ROWTYPE;

   -- Retrieve company information
   cursor c5( ccid integer ) is select * from customer_contact where aid = ccid;
   c5rec c5%ROWTYPE;

   -- Retrieve customer details
   cursor c6( caid integer ) is select billing_name name from customer_contact where aid = caid;
   c6rec c6%ROWTYPE;

   -- Retrieve purchase order info
   cursor c7( cpoid integer ) is select * from purchase_order where poid = cpoid;
   c7rec c7%ROWTYPE;

   -- Security variables
   sess_id	integer;
   sts		varchar2( 100 );

   -- Look and feel variables
   rTheme		THEME%ROWTYPE;
   theme_rec	theme_types%ROWTYPE;
begin
   if not dapi.init( surl, 'BKN.BOOKING_DETAILS', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   rTheme := dapi.getLFRecord;
   dapi.setTitle( LNG5.BKN_TXT_088 );
   dapi.pageOpen;
   -- Fetch booking details
   open c1( bid, acid );
   fetch c1 into c1rec;
   close c1;
   -- Fetch school details
   open c4( c1rec.school_id );
   fetch c4 into c4rec;
   close c4;
   -- Fetch company details
   open c5( c1rec.bus_company_id );
   fetch c5 into c5rec;
   close c5;
   -- Fetch creator
   open c6( c1rec.made_by );
   fetch c6 into c6rec;
   close c6;
   -- Fetch purchase order details
   open c7( c1rec.purchase_order_id );
   fetch c7 into c7rec;
   close c7;
   htp.p( '<CENTER>' );
   htp.tableOpen( cattributes=>TABLE_ATTS );
   -- Booking Request Number
   htp.tableRowOpen;
   htp.tableData( htf.bold( lng5.BKN_TXT_069 ), cattributes=>rTheme.qbground );
   htp.tableData( c1rec.booking_id, cattributes=>rTheme.qcbground );
   htp.tableRowClose;
   -- Status
   htp.tableRowOpen;
   htp.tableData( htf.bold( lng.PHG_TXT_082 ), cattributes=>rTheme.qbground );
   htp.tableData( c1rec.status, cattributes=>rTheme.qcbground );
   htp.tableRowClose;
   -- Date and time of visit
   htp.tableRowOpen;
   htp.tableData( htf.bold( lng5.BKN_TXT_089 ), cattributes=>rTheme.qbground );
   htp.tableData( TO_CHAR( c1rec.date_time, LNG.TSMASK ), cattributes=>rTheme.qcbground );
   htp.tableRowClose;
   -- Made By
   htp.tableRowOpen;
   htp.tableData( htf.bold( lng.CST_TXT_142 ), cattributes=>rTheme.qbground );
   htp.tableData( c6rec.name, cattributes=>rTheme.qcbground );
   htp.tableRowClose;
   -- Type of visit
   htp.tableRowOpen;
   htp.tableData( htf.bold( lng5.BKN_TXT_072 ), cattributes=>rTheme.qbground );
   htp.tableData( c1rec.visit_type, cattributes=>rTheme.qcbground );
   htp.tableRowClose;

   if getVisitTypeClass( c1rec.visit_type ) = LNG5.BKN_TXT_002 then
      --
      -- Paid program
      --
      htp.tableRowOpen( cvalign=>'TOP' );
      htp.tableData( htf.bold( lng5.BKN_TXT_073 ), cattributes=>rTheme.qbground );
      htp.p( '<TD ' || rTheme.qcbground || '>' );
      for c2rec in c2( bid ) loop
         htp.p( c2rec.program_name );
         htp.nl;
      end loop;
      htp.p( '</TD>' );
      htp.tableRowClose;
   end if;
   -- School details
   htp.tableRowOpen( cvalign=>'TOP' );
   htp.tableData( htf.bold( lng5.BKN_TXT_014 ), cattributes=>rTheme.qbground );
   htp.p( '<TD ' || rTheme.qcbground || '>' );
   htp.tableOpen( cattributes=>TABLE_ATTS );
      showSchoolDetails( c4rec, rTheme );
   htp.tableClose;
   htp.p( '</TD>' );
   htp.tableRowClose;

   if c1rec.bus_company_id is not null then
      htp.tableRowOpen( cvalign=>'TOP' );
      htp.tableData( htf.bold( lng5.BKN_TXT_015 ), cattributes=>rTheme.qbground );
      htp.p( '<TD ' || rTheme.qcbground || '>' );
      htp.tableOpen( cattributes=>TABLE_ATTS );
         showCompanyDetails( c5rec, rTheme );
      htp.tableClose;
      htp.p( '</TD>' );
      htp.tableRowClose;
   end if;

   if c1rec.requirements is not null then
      htp.tableRowOpen;
      htp.tableData( htf.bold( 'REQUIREMENTS' ), cattributes=>rTheme.qbground );
      htp.tableData( c1rec.requirements, cattributes=>rTheme.qcbground );
      htp.tableRowClose;
   end if;

   htp.tableClose;
   htp.formSubmit( 'action', lng5.BKN_BUT_003, cattributes=>'onClick="history.go( -1 );"' );
   htp.p( '</CENTER>' );
   dapi.pageClose;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'BOOKING_DETAILS', errmsg=>sqlerrm );
end booking_details;

procedure lab_calendar_overview( surl varchar2, acid integer default null,
                                 s_chosen_date varchar2 default null,
                                 calid varchar2 default null,
                                 errText varchar2 default null,
                                 action varchar2 default null,
                                 pStatus varchar2 default null,
                                 pVisitType varchar2 default null)
as
   -- Fetch current booking
   cursor c2( cdate_time date, ccalid integer, cstatus varchar2, cVisitType varchar2 ) is
      select b.booking_id, b.visit_type visit_type,
             b.num_of_students num_of_students,
             b.school_id school_id,
             to_char( b.date_time, lng.TSMASK_ONLY ) time
      from booking b
      where ( TO_CHAR( b.date_time, LNG.MASK ) = TO_CHAR( cdate_time, LNG.MASK ) ) and
            ( cstatus is null or ( cstatus is not null and INSTR( cstatus || ',', b.status || ',' ) > 0 ) ) and
            ( ccalid is null or b.calendar_id = ccalid )
            and
            ( cVisitType is null or cVisitType = b.visit_type )
      order by b.date_time;
   cursor c3( cAccountId integer ) is
      select visit_type_id, visit_type_name, class
      from visit_types
      where pid = (select pid from customer_account where aid = cAccountId );
   -- Fetch School/Bus company information
   cursor c4( cid integer ) is
      select cc.billing_name billing_name
      from customer_contact cc
      where cc.aid = cid;

   -- Work variables
   c2rec c2%ROWTYPE;
   c4rec c4%ROWTYPE;
   dDateToStart    date;
   day_to_start    integer;
   chosen_date     varchar2( 10 );
   i_minutes       integer;

   lRowStyle1 varchar2( 1000 );
   lRowStyle2 varchar2( 1000 );
   sts		 varchar2( 100 );

   sess_id integer;
   c3rec	  manufacturer%ROWTYPE;
   rTheme  theme%ROWTYPE;
   rurl    varchar2( 1000 );

   explanation varchar2( 2000 );
   CRLF        varchar2( 10 )  := CHR( 13 ) || CHR( 10 );
   HT          varchar2( 10 )  := CHR( 9 );
begin
   if not dapi.init( surl, 'BKN.LAB_CALENDAR_OVERVIEW', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   rTheme := dapi.getLFRecord;
   dapi.setTitle( LNG5.BKN_TXT_090 );
   dapi.pageOpen;
   htp.formOpen( 'bkn.lab_cal_set_filter' );
   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   htp.formHidden( 'pChosenDate', s_chosen_date );
   htp.formHidden( 'pCalendarId', calid );
   htp.formHidden( 'pErrorText', errtext );
   htp.formHidden( 'pStatus', null );
   htp.tableOpen( cattributes=>'border="1" cellspacing="2" cellpadding="2"' );
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Show bookings with status' ), cattributes=>rTheme.qbground );
   htp.p( '<td ' || rTheme.qcbground || '>' );
   if INSTR( pStatus || ',', LNG5.BKN_TXT_004 || ',' ) > 0 then
      htp.formCheckbox( 'pStatus', LNG5.BKN_TXT_004, 'CHECKED' );
   else
      htp.formCheckbox( 'pStatus', LNG5.BKN_TXT_004 );
   end if;
   htp.p( LNG5.BKN_TXT_004 );

   if INSTR( pStatus || ',', LNG5.BKN_TXT_005 || ',' ) > 0 then
      htp.formCheckbox( 'pStatus', LNG5.BKN_TXT_005, 'CHECKED' );
   else
      htp.formCheckbox( 'pStatus', LNG5.BKN_TXT_005 );
   end if;
   htp.p( LNG5.BKN_TXT_005 );
   htp.nl;

   if INSTR( pStatus,  'Reservation Accepted' ) > 0 then
      htp.formCheckbox( 'pStatus',  'Reservation Accepted', 'CHECKED' );
   else
      htp.formCheckbox( 'pStatus',  'Reservation Accepted' );
   end if;
   htp.p( 'Reservation Accepted' );

   if INSTR( pStatus, LNG5.BKN_TXT_006 ) > 0 then
      htp.formCheckbox( 'pStatus', LNG5.BKN_TXT_006, 'CHECKED' );
   else
      htp.formCheckbox( 'pStatus', LNG5.BKN_TXT_006 );
   end if;
   htp.p( LNG5.BKN_TXT_006 );
   htp.nl;

   if INSTR( pStatus, 'Visit Complete' ) > 0 then
      htp.formCheckbox( 'pStatus', 'Visit Complete', 'CHECKED' );
   else
      htp.formCheckbox( 'pStatus', 'Visit Complete' );
   end if;
   htp.p( 'Visit Complete' );
   if INSTR( pStatus, LNG5.BKN_TXT_009 ) > 0 then
      htp.formCheckbox( 'pStatus', LNG5.BKN_TXT_009, 'CHECKED' );
   else
      htp.formCheckbox( 'pStatus', LNG5.BKN_TXT_009 );
   end if;
   htp.p( LNG5.BKN_TXT_009 );
   htp.nl;

   if INSTR( pStatus, 'Problem' ) > 0 then
      htp.formCheckbox( 'pStatus', 'Problem', 'CHECKED' );
   else
      htp.formCheckbox( 'pStatus', 'Problem' );
   end if;
   htp.p( 'Problem' );

   htp.p( '</td>' );
   htp.tableData( htf.bold( 'Type of visit ' ), cattributes=>rTheme.qbground );
   htp.p( '<td ' || rTheme.qcbground || '>' );
   htp.formSelectOpen( 'pVisitType', cattributes=>'style="width: 192;"' );
   htp.formSelectOption( null );
   for visit in c3( acid ) loop
      if visit.visit_type_id = pVisitType then
         htp.formSelectOption( visit.visit_type_name, cselected=>'SELECTED',
                               cattributes=>'value="' || visit.visit_type_id || '"' );
      else
         htp.formSelectOption( visit.visit_type_name,
                               cattributes=>'value="' || visit.visit_type_id || '"' );
      end if;
   end loop;
   htp.formSelectClose;
   htp.p( '</td>' );
   htp.tableRowOpen;
   htp.tableData( htf.formSubmit( 'pAction', 'View' ), ccolspan=>'2', cattributes=>'align="right"' );
   htp.tableRowClose;
   htp.tableClose;
   htp.formClose;
   --
   -- Build the return URL
   --
   rurl := 'bkn.lab_calendar_overview( :surl, :acid';
   if s_chosen_date is not null then
   	rurl := rurl || ', s_chosen_date=>''' || s_chosen_date || '''';
   end if;
   if calid is not null then
   	rurl := rurl || ', calid=>''' || calid || '''';
   end if;
   if pStatus is not null then
      rurl := rurl || ', pStatus=>''' || pStatus || '''';
   end if;
   rurl := rurl || ' );';
   --
   -- Define odd and even row colours
   --
   lRowStyle1 := 'STYLE="' || 'background-color: #' || rTheme.vert_colour_a || ';"';
   lRowStyle2 := 'STYLE="' || 'background-color: #' || rTheme.vert_colour_b || ';"';

   if s_chosen_date is null then
      dDateToStart := SYSDATE;
   else
      dDateToStart := TO_DATE( s_chosen_date, LNG.MASK );
   end if;

   htp.p( '<CENTER>' ); -- Center the whole page
   --
   -- Display [error] message
   --
   if errText is not null then
      htp.p( '<font size="+3" color="#' || rTheme.error_text_colour || '" FACE="' || rTheme.error_text_font || '">'|| errText || '</font>' );
   end if;

   htp.tableOpen( cattributes=>TABLE_ATTS ); -- Calendar table
   --
   -- Setup calendar header
   --
   htp.tableRowOpen;
   htp.tableData( htf.anchor2( 'bkn.lab_calendar_overview?surl=' || surl || '&acid=' || acid || '&s_chosen_date=' || TO_CHAR( ADD_MONTHS( dDateToStart,-1 ),  LNG.MASK ) || '&pStatus=' || pStatus, LNG5.BKN_TXT_034 ) ); -- Link to previous month
   htp.tableData( '<center>' || htf.bold( TO_CHAR( dDateToStart, 'MONTH YYYY' ) || '</center>' ), ccolspan=>'7', calign=>'CENTER' );
   htp.tableData( htf.anchor2( 'bkn.lab_calendar_overview?surl=' || surl || '&acid=' || acid || '&s_chosen_date=' || TO_CHAR( ADD_MONTHS( dDateToStart,1 ),  LNG.MASK ) || '&pStatus=' || pStatus, LNG5.BKN_TXT_035 ) ); -- Link to next month
   htp.tableRowClose;
   -- End setup calendar header

   day_to_start := TO_NUMBER( TO_CHAR( dDateToStart, 'DD' ) );
   dDateToStart := dDateToStart - day_to_start;
   day_to_start := TO_NUMBER( TO_CHAR( dDateToStart, 'D' ) );
   dDateToStart := dDateToStart - day_to_start;

   htp.tableRowOpen( 'CENTER', cattributes=>lRowStyle2 );
   htp.tableData( htf.bold( LNG5.BKN_TXT_091 ), 'LEFT' );
   for i in 1..7 loop
      htp.tableData( htf.bold( INITCAP( LOWER( ( TO_CHAR( dDateToStart + i, 'DY' ) ) ) ) ) );
   end loop;
   htp.tableData( '&nbsp;' );
   htp.tableRowClose;
   <<loop_week>>
   for i in 1..5 loop
      if MOD( i, 2 ) = 0 then
         htp.tableRowOpen( cattributes=>lRowStyle2 );
      else
         htp.tableRowOpen( cattributes=>lRowStyle1 );
      end if;
      --
      -- Display week number
      --
      htp.tableData( htf.bold( TO_CHAR( dDateToStart, 'IW' ) ) );
      <<loop_day>>
      for j in 1..7 loop
         --
	 -- Go to the next day
	 --
         dDateToStart := dDateToStart + 1;
         htp.p( '<TD VALIGN="TOP" ALIGN="LEFT" WIDTH="100" HEIGHT="100">' );
         htp.tableOpen( cattributes=>'WIDTH="100%" border="0" cellspacing="0" cellpadding="0" STYLE="font-size: 8pt"' );
         htp.tableRowOpen;
	 --
	 -- Create a link to go to the day
	 --
	 -- Older way
         -- htp.tableData( htf.anchor2( 'bkn.lab_show_calendar?surl=' || surl || '&acid=' || acid || '&calid=' || calid || '&p_proposed_date=' || REPLACE( TO_CHAR( dDateToStart, LNG.TSMASK ),' ', '%20' ) || '&p_days_in_view=1', TO_CHAR( dDateToStart, 'DD' ) ), ccolspan=>'2' );

         htp.tableData( htf.anchor2( 'bkn.reception_show_day?surl=' || surl || '&acid=' || acid || '&calid=' || calid || '&p_proposed_date=' || REPLACE( TO_CHAR( dDateToStart, LNG.TSMASK ),' ', '%20' ) || '&p_days_in_view=1', TO_CHAR( dDateToStart, 'DD' ) ), ccolspan=>'2' );

         htp.tableRowClose;
         <<loop_time>>
         for c2rec in c2( dDateToStart, calid, pStatus, pVisitType ) loop
            open c4( c2rec.school_id );
            fetch c4 into c4rec;
            close c4;
            htp.tableRowOpen;
	    --
	    -- Create the tooltip text
	    --
            explanation := lng5.BKN_TXT_069 || HT || c2rec.booking_id || CRLF ||
                           lng5.BKN_TXT_068 || HT || c2rec.time || CRLF ||
                           lng5.BKN_TXT_036 || HT || c2rec.num_of_students || CRLF ||
                           lng5.BKN_TXT_072 || HT || c2rec.visit_type || CRLF ||
                           lng5.SCL_TXT_101 || HT || c4rec.billing_name;
	    --
	    -- Display the time
	    --
            htp.tableData( htf.bold( htf.anchor2( 'bkn.lab_booking_details?surl=' || surl || '&acid=' || acid || '&bid=' || c2rec.booking_id || '&rurl=' || rurl, c2rec.time, cattributes=>'TITLE="' || explanation || '"' ) ),cattributes=>'VALIGN="TOP"' );
	    --
	    -- Display the school name
	    --
            htp.tableData( c4rec.billing_name, cattributes=>'VALIGN="TOP"' );
            htp.tableRowClose;
         end loop loop_time;
         htp.tableClose;
      end loop loop_day;
      htp.tableData( '&nbsp;' );
      htp.tableRowClose;
   end loop loop_week;

   htp.tableClose; -- Calendar table
   -- End setup calendar

   htp.formSubmit( 'action', lng5.BKN_BUT_003, cattributes=>'onClick="self.location.href=''bkn.lab_maintain_bookings?surl=' || surl || '&acid=' || acid || '''; return false;"' );

   htp.p( '</CENTER>' );

   -- Close tags
   dapi.pageClose;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'LAB_CALENDAR_OVERVIEW', errmsg=>sqlerrm );
end lab_calendar_overview;

procedure lab_cal_set_filter( surl varchar2, acid integer,
                              pChosenDate varchar2 default null,
                              pCalendarId varchar2 default null,
                              pErrorText varchar2 default null,
                              pAction varchar2 default null,
                              pStatus GLBX.MYARRAY,
                              pVisitType varchar2 default null )
as
   lStatus varchar2( 1000 ) := null;
begin
   if not dapi.init( surl, 'BKN.LAB_CAL_SET_FILTER', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   for i in pStatus.first..pStatus.last loop
      lStatus := lStatus || pStatus( i ) || ',';
   end loop;
   lab_calendar_overview( surl, acid, pChosenDate, pCalendarId, pErrorText, pAction, lStatus, pVisitType );
exception when others then
   glbx.error_details( PACKAGE_NAME, 'LAB_CAL_SET_FILTER', errmsg=>sqlerrm );
end lab_cal_set_filter;

procedure default_settings(
  surl varchar2,                                 -- Secure URL
  acid integer,                                  -- Account ID
  msg varchar2 default null )                     -- Message
as
   -- Default details
   cursor c1( cacid integer ) is
   select
      *
   from
      school_booking_prefs
   where
      std_profile_aid = cacid and
      std_profile_pid = ( select pid from customer_account where aid = cacid );
   c1rec c1%ROWTYPE;
   -- Manufacturer details
   cursor c2( cmid integer ) is
   select
      *
   from
      manufacturer
   where
      manufacturer_id = cmid;
   c2rec c2%rowtype;
   -- all photographer details
   cursor c3 is
   select
      pid, business_name
   from
      photographer
   order by
      business_name;
   c3rec c3%ROWTYPE;
   -- photographer details filtered by manufacturer
   cursor c3x( manid integer ) is
   select
      p.pid,
      p.business_name
   from
      photographer p,
      manufacturer_photographer mp
   where
      mp.manufacturer_id = manid and
      mp.pid = p.pid
   order by
      business_name;
   -- Customer account details
   cursor c4( cpid integer ) is
   select
      aid,
      account_name
   from
      customer_account
   where
      pid = cpid;
   c4rec c4%ROWTYPE;
   -- All business features
   cursor c5 is
   select
      distinct theme_type
   from
      theme_types;
   c5rec c5%ROWTYPE;
   -- Limited look and feels
   cursor c6( cpid integer ) is
   select
      theme_name
   from
      limit_laf
   where
      pid = cpid;
   c6rec c6%ROWTYPE;
   -- All look and feels
   cursor c7 is
   select
      distinct theme_name
   from
      theme;
   c7rec c7%ROWTYPE;
   -- Limited business features
   cursor c8( cpid integer ) is
   select
      distinct theme_type
   from
      limit_bf
   where
      pid = cpid;
   c8rec c8%ROWTYPE;
   --
   -- Choose photographer
   --
   cursor c9( cpid integer ) is
   select
      limit_bf, limit_laf
   from
      photographer
   where
      pid = cpid;
   c9rec c9%ROWTYPE;
   -- Select order styles
   cursor c10( cpid integer ) is
   select
      name, oid
   from
      order_style
   where
      pid = cpid;
   c10rec c10%rowtype;
   -- Select calendar
   cursor c11( cpid integer ) is
   select
      calendar_id,
      name
   from
      calendar
   where
      pid = cpid;
   cursor c12( cpid integer ) is
   select
      profile_id,
      account_name
   from
      customer_profile
   where
      profile_id = cpid;
   c12rec c12%ROWTYPE;
   cursor c13( cacid integer ) is
   select
      pid
   from
      customer_account
   where
      aid = cacid;
   cursor c14( cacid integer, cpid integer ) is
   select
      resource_id,
      description
   from
      resources
   where
      aid = cacid and
      pid = cpid;

   pfx	THEME%ROWTYPE;
   lCreateNew boolean;
   lAccountId integer;
   lPhotographerId integer;
begin
   if not dapi.init( surl, 'BKN.DEFAULT_SETTINGS', iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   pfx := dapi.getLFRecord;
   lAccountId := dapi.getAccountId;
   dapi.setTitle( 'Default settings for the booking system' );
   dapi.pageOpen;
   --
   -- Fetch existing default information
   --
   open c1( acid );
   fetch c1 into c1rec;
   lCreateNew := c1%NOTFOUND;
   close c1;
   --
   -- Create new record in the school bookings preferences table
   --
   open c13( acid );
   fetch c13 into lPhotographerId;
   close c13;
   if lCreateNew then
      insert into school_booking_prefs (
         manufacturer_id,
         std_profile_aid,
         std_profile_pid
         )
      values(
         lAccountId,
         acid,
         lPhotographerId );
      commit;
      open c1( acid );
      fetch c1 into c1rec;
      close c1;
   end if;
   --
   -- Retrieve manufacturer details
   --
   open c2( lAccountId );
   fetch c2 into c2rec;
   close c2;
   --
   -- Is there a limit on the look and feels and business features?
   open c9( c1rec.std_profile_pid );
   fetch c9 into c9rec;
   close c9;
   htp.p( '<CENTER>' );
   --
   -- Display a message if any
   --
   if msg is not null then
      htp.p( '<font size="+3" color="#' || pfx.TEXT_COLOUR || '" FACE="' || pfx.error_text_font || '">'|| msg || '</font>' );
   end if;
   htp.formOpen( 'bkn.accept_default_settings', cattributes=>'NAME="form1"' );
   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   htp.tableOpen( cattributes=>TABLE_ATTS );
      htp.tableRowOpen;
         --
         -- Show standard Business features for profiles
         --
         htp.tableData( htf.bold( 'Business feature used to create school and company profiles' ), cattributes=>pfx.qbground || ' align="LEFT"' );
         htp.p( '<TD ' || pfx.qcbground || ' align="LEFT">' );
            htp.formselectopen( 'p_bf' );
            htp.formselectoption( NULL );
            if c9rec.limit_bf = 'F' then
               for c8rec in c8( c1rec.std_profile_pid ) loop
                  if c8rec.theme_type = c1rec.std_profile_bf then
                     htp.formselectoption( c8rec.theme_type, 'SELECTED', cattributes=>'VALUE="' || c8rec.theme_type || '"' );
                  else
                     htp.formselectoption( c8rec.theme_type, cattributes=>'VALUE="' || c8rec.theme_type || '"' );
                  end if;
               end loop;
            else
               for c5rec in c5 loop
                  if c5rec.theme_type = c1rec.std_profile_bf then
                     htp.formselectoption( c5rec.theme_type, 'SELECTED', cattributes=>'VALUE="' || c5rec.theme_type || '"' );
                  else
                     htp.formselectoption( c5rec.theme_type, cattributes=>'VALUE="' || c5rec.theme_type || '"' );
                  end if;
               end loop;
            end if;
            htp.formselectclose;
         htp.p( '</TD>' );
      htp.tableRowClose;
      htp.tableRowOpen;
         htp.tableData( htf.bold( 'Look and Feel used to create school and company profiles' ), cattributes=>pfx.qbground || ' align="LEFT"' );
         htp.p( '<TD ' || pfx.qcbground || ' align="LEFT">' );
            htp.formselectopen( 'p_laf' );
            htp.formselectoption( NULL );
            if c9rec.limit_laf = 'F' then
               for c6rec in c6( c1rec.std_profile_pid ) loop
                  if c6rec.theme_name = c1rec.std_profile_laf then
                     htp.formselectoption( c6rec.theme_name, 'SELECTED', cattributes=>'VALUE="' || c6rec.theme_name || '"' );
                  else
                     htp.formselectoption( c6rec.theme_name, cattributes=>'VALUE="' || c6rec.theme_name || '"' );
                 end if;
               end loop;
            else
               for c7rec in c7 loop
                  if c7rec.theme_name = c1rec.std_profile_laf then
                     htp.formselectoption( c7rec.theme_name, 'SELECTED', cattributes=>'VALUE="' || c7rec.theme_name || '"' );
                  else
                     htp.formselectoption( c7rec.theme_name, cattributes=>'VALUE="' || c7rec.theme_name || '"' );
                 end if;
               end loop;
            end if;
            htp.formSelectClose;
         htp.p( '</TD>' );
      htp.tableRowClose;
      htp.tableRowOpen;
         htp.tableData( htf.bold( 'Order style for schools and bus companies' ), cattributes=>pfx.qbground || ' align="LEFT"' );
         htp.p( '<TD ' || pfx.qcbground || ' align="LEFT" align="LEFT">' );
            htp.formselectOpen( 'p_ord' );
            htp.formselectOption( NULL );
            for c10rec in c10( c1rec.std_profile_pid ) loop
               if c10rec.oid = c1rec.std_order_style then
                  htp.formselectOption( c10rec.name, 'SELECTED', cattributes=>'VALUE="' || c10rec.oid || '"' );
               else
                  htp.formselectOption( c10rec.name, cattributes=>'VALUE="' || c10rec.oid || '"' );
               end if;
            end loop;
            htp.formSelectClose;
         htp.p( '</TD>' );
      htp.tableRowClose;
      htp.tableRowOpen;
         htp.tableData( htf.bold( 'Enter the account name of the user with the role of receptionist' ), cattributes=>pfx.qbground || ' align="LEFT"' );
         open c12( c1rec.receptionist_aid );
         fetch c12 into c12rec;
         close c12;
         htp.p( '<TD ' || pfx.qcbground || ' align="LEFT">' );
            htp.formText( 'p_receptionist', 25, 100, cvalue=>c12rec.account_name );
         htp.p( '</TD>' );
      htp.tableRowClose;
      htp.tableRowOpen;
         htp.tableData( htf.bold( 'Active Calendar' ), cattributes=>pfx.qbground || ' align="LEFT"' );
         htp.p( '<TD ' || pfx.qcbground || ' align="LEFT">' );
            htp.formselectopen( 'p_calendar_id' );
            htp.formselectoption( NULL );
             for c11rec in c11( c1rec.std_profile_pid ) loop
              if c11rec.calendar_id = c1rec.std_calendar_id then
                htp.formselectoption( c11rec.name, 'SELECTED', cattributes=>'VALUE="' || c11rec.calendar_id || '"' );
               else
                htp.formselectoption( c11rec.name, cattributes=>'VALUE="' || c11rec.calendar_id || '"' );
              end if;
             end loop;
             htp.formselectclose;
         htp.p( '</TD>' );
      htp.tableRowClose;
      htp.tableRowOpen;
         htp.tableData( htf.bold( 'The number of students that need 1 adult to supervise' ), cattributes=>pfx.qbground || ' align="LEFT"' );
         htp.p( '<TD ' || pfx.qcbground || ' align="LEFT">' );
            htp.formText( 'p_adult_student_ratio', 25, 100, cvalue=>c1rec.adult_student_ratio );
         htp.p( '</TD>' );
      htp.tableRowClose;
      htp.tableRowOpen;
         htp.tableData( htf.bold( 'What resource represents the Education Centre' ), cattributes=>pfx.qbground || ' align="LEFT"' );
         htp.p( '<td ' || pfx.qcbground || ' align="LEFT">' );
            htp.formSelectOpen( 'pEducationCentre' );
            htp.formselectOption( NULL );
            for c14rec in c14( acid, lPhotographerId ) loop
               if c1rec.education_id = c14rec.resource_id then
                  htp.formSelectOption( c14rec.description, 'SELECTED', cattributes=>'value="' || c14rec.resource_id || '"' );
               else
                  htp.formSelectOption( c14rec.description, cattributes=>'value="' || c14rec.resource_id || '"' );
               end if;
            end loop;
            htp.formSelectClose;
         htp.p( '</td>' );
      htp.tableRowClose;
      htp.tableRowOpen;
         htp.tableData( htf.bold( 'What resource represents the AWM Galleries' ), cattributes=>pfx.qbground || ' align="LEFT"' );
         htp.p( '<td ' || pfx.qcbground || ' align="LEFT">' );
            htp.comment( acid || ', ' || lPhotographerId );
            htp.formSelectOpen( 'pGalleries' );
            htp.formselectOption( NULL );
            for c14rec in c14( acid, lPhotographerId ) loop
               if c1rec.galleries_id = c14rec.resource_id then
                  htp.formSelectOption( c14rec.description, 'SELECTED', cattributes=>'value="' || c14rec.resource_id || '"' );
               else
                  htp.formSelectOption( c14rec.description, cattributes=>'value="' || c14rec.resource_id || '"' );
               end if;
            end loop;
            htp.formSelectClose;
         htp.p( '</td>' );
      htp.tableRowClose;
      htp.tableRowOpen;
         htp.tableData( htf.bold( 'Default Tax Group' ), cattributes=>pfx.qbground || ' align="LEFT"' );
         htp.p( '<TD ' || pfx.qcbground || ' align="LEFT">' );
            htp.formText( 'pdeftax', 25, 100, cvalue=>c1rec.default_tax_group );
         htp.p( '</TD>' );
      htp.tableRowClose;
      htp.tableRowOpen;
         htp.tableData( htf.bold( 'Default XRef Manufacturer Code' ), cattributes=>pfx.qbground || ' align="LEFT"' );
         htp.p( '<TD ' || pfx.qcbground || ' align="LEFT">' );
            htp.formText( 'pdefxref', 25, 100, cvalue=>c1rec.default_xref_mfctr_code );
         htp.p( '</TD>' );
      htp.tableRowClose;
      htp.tableRowOpen;
         htp.tableData( htf.bold( 'HTML Page Prefix appended to visit_type.html, for the location of the Help Page' ), cattributes=>pfx.qbground || ' align="LEFT"' );
         htp.p( '<TD ' || pfx.qcbground || ' align="LEFT">' );
            htp.formText( 'p_visithelp_loc', 35, 1000, cvalue=>c1rec.visithelp_loc );
         htp.p( '</TD>' );
      htp.tableRowClose;

      htp.tableRowOpen;
         htp.tableData( htf.bold( 'HTML Help Page' ), cattributes=>pfx.qbground || ' align="LEFT"' );
         htp.p( '<TD ' || pfx.qcbground || ' align="LEFT">' );
            htp.formText( 'p_html_help', 35, 1000, cvalue=>c1rec.visithelp_loc );
         htp.p( '</TD>' );
      htp.tableRowClose;
      htp.tableRowOpen;
         htp.tableData( htf.bold( 'Home Site Title' ), cattributes=>pfx.qbground || ' align="LEFT"' );
         htp.p( '<TD ' || pfx.qcbground || ' align="LEFT">' );
            htp.formText( 'p_htitle', 35, 1000, cvalue=>c1rec.home_title );
         htp.p( '</TD>' );
      htp.tableRowClose;
      htp.tableRowOpen;
         htp.tableData( htf.bold( 'Home Site URL' ), cattributes=>pfx.qbground || ' align="LEFT"' );
         htp.p( '<TD ' || pfx.qcbground || ' align="LEFT">' );
            htp.formText( 'p_hurl', 35, 1000, cvalue=>c1rec.home_url );
         htp.p( '</TD>' );
      htp.tableRowClose;
      htp.tableRowOpen;
         htp.tableData( htf.bold( 'Textbox Height' ), cattributes=>pfx.qbground || ' align="LEFT"' );
         htp.p( '<TD ' || pfx.qcbground || ' align="LEFT">' );
            htp.formText( 'p_tbox_height', 5, 100, cvalue=>c1rec.textbox_height );
         htp.p( '</TD>' );
      htp.tableRowClose;
      htp.tableRowOpen;
         htp.tableData( htf.bold( 'Textbox Width' ), cattributes=>pfx.qbground || ' align="LEFT"' );
         htp.p( '<TD ' || pfx.qcbground || ' align="LEFT">' );
            htp.formText( 'p_tbox_width', 5, 100, cvalue=>c1rec.textbox_width );
         htp.p( '</TD>' );
      htp.tableRowClose;
      htp.tableRowOpen;
         htp.tableData( htf.bold( 'Title for Branch' ), cattributes=>pfx.qbground || ' align="LEFT"' );
         htp.p( '<TD ' || pfx.qcbground || ' align="LEFT">' );
            htp.formText( 'p_branch', 35, 1000, cvalue=>c1rec.branch_title );
         htp.p( '</TD>' );
      htp.tableRowClose;
      htp.tableRowOpen;
         htp.tableData( htf.bold( 'Title for User Defined Field 1' ), cattributes=>pfx.qbground || ' align="LEFT"' );
         htp.p( '<TD ' || pfx.qcbground || ' align="LEFT">' );
            htp.formText( 'p_udf1', 35, 1000, cvalue=>c1rec.user_defined_1 );
         htp.p( '</TD>' );
      htp.tableRowClose;
      htp.tableRowOpen;
         htp.tableData( htf.bold( 'Title for User Defined Field 2' ), cattributes=>pfx.qbground || ' align="LEFT"' );
         htp.p( '<TD ' || pfx.qcbground || ' align="LEFT">' );
            htp.formText( 'p_udf2', 35, 1000, cvalue=>c1rec.user_defined_2 );
         htp.p( '</TD>' );
      htp.tableRowClose;
      htp.tableRowOpen;
         htp.tableData( htf.bold( 'Title for User Defined Field 3' ), cattributes=>pfx.qbground || ' align="LEFT"' );
         htp.p( '<TD ' || pfx.qcbground || ' align="LEFT">' );
            htp.formText( 'p_udf3', 35, 1000, cvalue=>c1rec.user_defined_3 );
         htp.p( '</TD>' );
      htp.tableRowClose;
      htp.tableRowOpen;
         htp.tableData( htf.bold( 'Title for User Defined Field 4' ), cattributes=>pfx.qbground || ' align="LEFT"' );
         htp.p( '<TD ' || pfx.qcbground || ' align="LEFT">' );
            htp.formText( 'p_udf4', 35, 1000, cvalue=>c1rec.user_defined_4 );
         htp.p( '</TD>' );
      htp.tableRowClose;
      htp.tableRowOpen;
         htp.tableData( htf.bold( 'Title for User Defined Field 5' ), cattributes=>pfx.qbground || ' align="LEFT"' );
         htp.p( '<TD ' || pfx.qcbground || ' align="LEFT">' );
            htp.formText( 'p_udf5', 35, 1000, cvalue=>c1rec.user_defined_5 );
         htp.p( '</TD>' );
      htp.tableRowClose;
      htp.tableRowOpen;
         htp.tableData( htf.bold( 'Title for User Defined Field 6' ), cattributes=>pfx.qbground || ' align="LEFT"' );
         htp.p( '<TD ' || pfx.qcbground || ' align="LEFT">' );
            htp.formText( 'p_udf6', 35, 1000, cvalue=>c1rec.user_defined_6 );
         htp.p( '</TD>' );
      htp.tableRowClose;

   htp.tableClose;
   htp.formSubmit( 'action', lng.CST_BUT_017 );
   htp.formSubmit( 'action', lng.CST_BUT_016 );
   htp.formClose; -- form1
   htp.p( '</center>' );
   dapi.pageClose;
exception when others then
   glbx.error_details( 'LAB', 'DEFAULT_SETTINGS', errmsg=>sqlerrm );
end default_settings;

procedure accept_default_settings(
  surl varchar2,
  acid integer,
  p_bf varchar2 default null,
  p_laf varchar2 default null,
  p_ord integer default null,
  p_tou char default null,
  p_receptionist varchar2 default null,
	 p_calendar_id varchar2 default null,
  p_adult_student_ratio varchar2 default null,
  pEducationCentre varchar2 default null,
  pGalleries varchar2 default null,
  pdeftax in varchar2 default null,
  pdefxref in varchar2 default null,
  p_visithelp_loc in varchar2 default null,
  p_html_help in varchar2 default null,
  p_tbox_height in varchar2 default null,
  p_tbox_width in varchar2 default null,
  p_branch in varchar2 default null,
  p_udf1 in varchar2 default null,
  p_udf2 in varchar2 default null,
  p_udf3 in varchar2 default null,
  p_udf4 in varchar2 default null,
  p_udf5 in varchar2 default null,
  p_udf6 in varchar2 default null,
  p_htitle in varchar2 default null,
  p_hurl in varchar2 default null,
  action varchar2 )
as
   cursor c1( cusername varchar2 ) is
   select
      profile_id
   from
      customer_profile
   where
      account_name = cusername;

   cursor c2( cacid integer ) is
   select
      pid
   from
      customer_account
   where
      aid = cacid;

   EXCEPTION_ERROR Exception;
   lProfileId customer_profile.profile_id%TYPE;
   msg varchar2( 200 ) := null;
   lAdultStudentRatio number;
   lManufacturerId integer;
   lPhotographerId integer;
begin
   if not dapi.init( surl, 'BKN.ACCEPT_DEFAULT_SETTINGS', iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   lManufacturerId := dapi.getAccountId;
   --
   -- check is the username for the receptionist exists
   --
   if p_receptionist is not null then
      open c1( p_receptionist );
      fetch c1 into lProfileId;
      if c1%NOTFOUND then
         msg := msg || 'The username for receptionist is not valid';
      end if;
      close c1;
   end if;
   open c2( acid );
   fetch c2 into lPhotographerId;
   close c2;
   if msg is not null then
      raise EXCEPTION_ERROR;
   end if;
   if action = lng.CST_BUT_017 then
      begin
         lAdultStudentRatio := TO_NUMBER( p_adult_student_ratio );
      exception when others then
         lAdultStudentRatio := 0;
      end;
      update school_booking_prefs
         set
            std_profile_bf  = p_bf,
            std_profile_laf = p_laf,
            std_order_style = p_ord,
            std_type_of_user = p_tou,
            receptionist_aid = lProfileId,
            std_calendar_id = p_calendar_id,
            adult_student_ratio = lAdultStudentRatio,
            education_id = pEducationCentre,
            galleries_id = pGalleries,
            default_tax_group = pdeftax,
            default_xref_mfctr_code = pdefxref,
            visithelp_loc = p_visithelp_loc,
            help_loc = p_html_help,
            textbox_height = p_tbox_height,
            textbox_width = p_tbox_width,
            branch_title = p_branch,
            user_defined_1 = p_udf1,
            user_defined_2 = p_udf2,
            user_defined_3 = p_udf3,
            user_defined_4 = p_udf4,
            user_defined_5 = p_udf5,
            user_defined_6 = p_udf6,
            home_title = p_htitle,
            home_url = p_hurl
         where
            std_profile_aid = acid and
            std_profile_pid = lPhotographerId;
      default_settings( surl, acid, LNG.PHG_TXT_245 );
   elsif action = lng.CST_BUT_016 then
      lab.mng_booking( surl );
   end if;
exception
   when EXCEPTION_ERROR then
      default_settings( surl, acid, msg );
   when others then
      glbx.error_details( 'LAB', 'DEFAULT_SETTINGS', errmsg=>sqlerrm );
end;

procedure lab_reception_screen( surl varchar2, ltype varchar2 default null, acid integer, left_api_parm varchar2 default null, scrolldate in char default 'F' )
as
   cursor c1( cacid integer ) is
   select
      ca.profile_id aid,
      ca.username username
   from
      customer_profile ca,
      school_booking_prefs sbp
   where
      ca.profile_id = sbp.receptionist_aid and
      sbp.std_profile_aid = cacid and
      sbp.std_profile_pid = ( select pid from customer_account where aid = cacid );
   c1rec c1%ROWTYPE;

   cursor c2( caid integer ) is
   select
      a.pw password
   from
      audit_profile_password a
   where
      a.profile_id = caid and
      a.date_changed = ( select max( b.date_changed ) from audit_profile_password b where b.profile_id=caid );
   c2rec c2%ROWTYPE;

   rTheme theme%ROWTYPE;

begin
   if not dapi.init( surl, 'BKN.LAB_RECEPTION_SCREEN', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   reception_show_day( surl, acid, scrolldate=>scrolldate );

exception when others then
   glbx.error_details( PACKAGE_NAME, 'LAB_RECEPTION_SCREEN', errmsg=>sqlerrm );
end lab_reception_screen;

procedure reception_screen( surl varchar2, ltype varchar2 default null, acid integer )
as
begin
   if not dapi.init( surl, 'BKN.RECEPTION_SCREEN', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   lab_maintain_bookings( surl, acid, 'Reception' );
exception when others then
   glbx.error_details( PACKAGE_NAME, 'RECEPTION_SCREEN', errmsg=>sqlerrm );
end reception_screen;

procedure reception_show_day( surl varchar2, acid integer default null,
                              calid varchar2 default null,
                              p_proposed_date varchar2 default null,
                              p_days_in_view varchar2 default '1',
                              action varchar2 default null,
                              scrolldate in char default 'F' )
as
   -- Retrieve occupied time by a resource
   cursor c1( date_to_check date, ccid integer ) is
      select b.booking_id booking_id,
             nvl(b.actual_num_of_programs,b.num_of_students) num_of_students,
             b.made_by made_by,
             b.school_id school_id,
             b.bus_company_id bus_company_id,
             b.date_time date_time,
             b.purchase_order_id purchase_order_id,
             b.visit_type visit_type,
             v.visit_type_name,
             b.status,
             b.actual_num_of_students,
             b.actual_num_of_programs
      from resource_use ru, booking b, visit_types v
      where ( ru.date_time_from <= date_to_check ) and
            ( date_to_check < ru.date_time_to ) and
            ( v.visit_type_id = b.visit_type ) and
            ( ccid is null or ( ccid is not null and ru.calendar_id = ccid ) ) and
            ( b.booking_id = ru.booking_id ) and b.status in (LNG5.BKN_TXT_006,'Visit Complete');
   -- Fetch calendar settings
   cursor c2( ccid integer ) is
      select calendar_id calid, start_time , end_time , time_block ,
             date_format, days_in_view
      from calendar c
      where ( ccid is null or ( ccid is not null and c.calendar_id = ccid ) );
   -- Retrieve resource details
   cursor c3( crid integer ) is
      select *
      from resources
      where resource_id = crid;
   -- Fetch current booking
   cursor c4( csid integer ) is
      select *
      from booking
      where session_id = csid and status = LNG5.BKN_TXT_004;
   -- Fetch blocked times for the specified Calendar
   cursor c5( ccid integer, cdate date ) is
      select reason
      from excluded_calendar_times
      where ( calendar_id = ccid ) and ( date_time_from <= cdate ) and ( cdate <= date_time_to );
   -- Fetch school holidays
   cursor c6( ccid integer ) is
      select *
      from school_holidays
      where calendar_id = ccid;
   -- School/Bus company details
   cursor c7( cid integer ) is
      select billing_name
      from customer_contact
      where aid = cid;
   --
   -- Work variables
   --
   c1rec c1%ROWTYPE;
   c2rec c2%ROWTYPE;
   c3rec c3%ROWTYPE;
   c4rec c4%ROWTYPE;
   c5rec c5%ROWTYPE;
   c6rec c6%ROWTYPE;
   c7rec c7%ROWTYPE;
   dThisDay     date;
   cThisDay     varchar( 100 );
   dThisTime    date;
   cThisTime    varchar( 100 );
   dThisDayTime date;

   cThisDayTime varchar( 100 );
   c_DateTime1  varchar2( 100 );
   c_DateTime3  varchar2( 100 );
   time_span    integer; -- Time span is the amount of time blocks that should be used for the Education Centre
   time_span2   integer; -- Time span for the Galleries

   bTimeAvailable boolean;
   tableAtts      varchar2( 100 );
   anchorText     varchar2( 100 );
   fontSize       varchar2( 10 );
   bid            integer;

   i_hours   integer;
   i_minutes integer;
   sess_id   integer;
   rTheme    theme%ROWTYPE;
   nRow      integer; -- even or odd row 0 = even 1 is odd

   nTimeLookAhead   integer;
   nNumOfVis        number;
   textNotAvailable varchar2( 200 );
   daysBefore       integer;
   daysAfter        integer;

   days_in_view integer;
   date_time    date;
   explanation  varchar2( 1000 );
   CRLF         varchar2( 10 )  := CHR( 13 ) || CHR( 10 );
   HT           varchar2( 10 )  := CHR( 9 );

   rurl varchar2( 2000 );
   lBookingIds varchar2( 4000 ) := ' ';
begin
   if not dapi.init( surl, 'BKN.RECEPTION_SHOW_DAY', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   dapi.setTitle( htf.anchor('bkn.reception_show_day?surl=' || surl || '&scrolldate=' || scrolldate || '&acid=' || acid || '&calid=' || calid || '&p_proposed_date=' || replace(p_proposed_date,' ','+') || '&p_days_in_view=' || p_days_in_view, 'Refresh') );
   rTheme := dapi.getLFRecord;
   dapi.pageOpen;
   fontSize := '8pt';
   -- Initialisation
   date_time := TO_DATE( nvl( p_proposed_date, TO_CHAR( SYSDATE, LNG.TSMASK ) ), LNG.TSMASK );
   -- Build the return url
   rurl := 'reception_show_day( :surl, :acid';
   if calid is not null then
   	rurl := rurl || ', calid=>' || calid;
   end if;
   if p_proposed_date is not null then
   	rurl := rurl || ', p_proposed_date=>'''|| p_proposed_date || '''';
   end if;
   if p_days_in_view is not null then
   	rurl := rurl || ', p_days_in_view=>''' || p_days_in_view || '''';
   end if;
   rurl := rurl || ' )';
   -- Fetch calendar details
   open c2( calid );
   fetch c2 into c2rec;
   close c2;
   -- Calculate the amount of days to show
   days_in_view := NVL( p_days_in_view, c2rec.days_in_view );
   daysAfter := TRUNC( days_in_view/2 );
   daysBefore := days_in_view - daysAfter - 1;
   c_DateTime1 := TO_CHAR( date_time - daysBefore - 1, LNG.TSMASK ); -- First day of the calendar to display
   c_DateTime3 := TO_CHAR( date_time + daysAfter + 1, LNG.TSMASK );  -- Third day of the calendar to display
   htp.p( '<CENTER>' );

   htp.tableOpen( cattributes=>'cellpadding="0" cellspacing="2" border="0" WIDTH="100%"' );
   htp.tableRowOpen;
   -- Print the link to the previous day
   if nvl(scrolldate,'F') = 'F'
    then
     htp.tableData( '&nbsp;', cattributes=>'ALIGN="CENTER" WIDTH="100"' );
    else
     htp.tableData( htf.anchor('bkn.reception_show_day?surl=' || surl || '&acid=' || acid || '&calid=' || calid || '&p_days_in_view=' || p_days_in_view || '&scrolldate=' || scrolldate ||
                               '&p_proposed_date=' || replace(to_char( date_time-1, LNG.TSMASK ),' ','+') || '&action=' || replace(action,' ','+'), '&lt;&lt; Previous Day'), cattributes=>'ALIGN="CENTER" WIDTH="100"' );
   end if;

   -- Print the headers
   for i in -daysBefore..daysAfter loop
      htp.tableData( htf.bold( INITCAP( LOWER( TO_CHAR( date_time + i, LNG5.BKN_TXT_086 ) ) ) ), cattributes=>' WIDTH="160" ALIGN="CENTER"' );
   end loop;

   -- Print the link to the next day
   -- Print the link to the next day
   if nvl(scrolldate,'F') = 'F'
    then
     htp.tableData( '&nbsp;', cattributes=>'ALIGN="CENTER" WIDTH="100"' );
    else
     htp.tableData( htf.anchor('bkn.reception_show_day?surl=' || surl || '&acid=' || acid || '&calid=' || calid || '&p_days_in_view=' || p_days_in_view || '&scrolldate=' || scrolldate ||
                               '&p_proposed_date=' || replace(to_char( date_time+1, LNG.TSMASK ),' ','+') || '&action=' || replace(action,' ','+'), 'Next Day &gt;&gt;'), cattributes=>'ALIGN="CENTER" WIDTH="100"' );
   end if;
   htp.tableRowClose;

   -- A starting time of 08:00
   i_hours := 8;
   nRow    := 0;

   while i_hours <= TO_NUMBER( TO_CHAR( c2rec.end_time, 'HH24' ) ) loop -- Loop though the hours, end time will be 19:00
      i_minutes := 0;
      while i_minutes < 60 loop                                    -- loop through the minutes
         dThisTime := TO_DATE( TO_CHAR( i_hours, '09' ) || ':' || TO_CHAR( i_minutes, '09' ), 'HH24:MI' );
         cThisTime := TO_CHAR( dThisTime, 'HH24:MI' );
         if nRow = 0 then
            htp.tableRowOpen( cattributes=>'BGCOLOR="#' || rTheme.vert_colour_a || '" STYLE="font-size: ' || fontSize || '"' );
         else
            htp.tableRowOpen( cattributes=>'BGCOLOR="#' || rTheme.vert_colour_b || '" STYLE="font-size: ' || fontSize || '"' );
         end if;
         nRow := mod( 1, nRow );
         htp.p( '<TD>' );
         htp.paragraph( cattributes=>'STYLE="color:#' || rTheme.caption_text_colour || ';font-family:' || rTheme.caption_text_font || ';font-size: ' || fontSize || '"' );
         htp.p( cThisTime );
         htp.p( '</P></TD>' );

         for dayCount in -daysBefore..daysAfter loop
            dThisDay     := date_time + dayCount;
            cThisDay     := TO_CHAR( dThisDay, LNG.MASK );
            dThisDayTime := TO_DATE( cThisDay || ' ' || cThisTime, LNG.TSMASK );
            cThisDayTime := TO_CHAR( dThisDayTime, LNG.TSMASK );

            htp.p( '<TD>' );
            for c1rec in c1( dThisDayTime, calid ) loop
               if INSTR( lBookingIds, c1rec.booking_id ) = 0 then
                  -- Not yet processed
                  lBookingIds := lBookingIds || c1rec.booking_id || ' ';
                  open c7( c1rec.school_id );
                  fetch c7 into c7rec;
                  close c7;
                  explanation := 'Booking id'      || HT || c1rec.booking_id || CRLF ||
                                 'Booking RQN'     || HT || c1rec.purchase_order_id || CRLF ||
                                 '# students'      || HT || c1rec.num_of_students || CRLF ||
                                 'Date of visit'   || HT || TO_CHAR( c1rec.date_time, lng.MASK ) || CRLF ||
                                 'Time of arrival' || HT || TO_CHAR( c1rec.date_time, lng.TSMASK_ONLY ) || CRLF ||
                                 'School'          || HT || HT || c7rec.billing_name || CRLF ||
                                 'Visit type'      || HT || c1rec.visit_type;
                  if c1rec.status = 'Visit Complete'
                   then
                   htp.p( htf.anchor2( 'bkn.reception_booking_details?surl=' || surl ||
                          '&acid=' || acid || '&bid=' || c1rec.booking_id || '&rurl=' ||
                          rurl, htf.italic(c7rec.billing_name),
                          ctarget=>'_blank', cattributes=>'TITLE="' || explanation || '"' ) ||
                          htf.italic(' [' || nvl(c1rec.actual_num_of_programs,nvl(c1rec.actual_num_of_students,c1rec.num_of_students)) || '-' || substr(c1rec.visit_type_name,1,4) || ']'));
                   else
                   htp.p( htf.anchor2( 'bkn.reception_booking_details?surl=' || surl ||
                          '&acid=' || acid || '&bid=' || c1rec.booking_id || '&rurl=' ||
                          rurl, c7rec.billing_name,
                          ctarget=>'_blank', cattributes=>'TITLE="' || explanation || '"' ) ||
                          ' [' || nvl(c1rec.actual_num_of_programs,nvl(c1rec.actual_num_of_students,c1rec.num_of_students)) || '-' || substr(c1rec.visit_type_name,1,4) || ']');
                  end if;
               end if;
            end loop;
            htp.p( '</TD>' );

         end loop;
         htp.p( '<TD ID="CALENDAR" ALIGN="CENTER" STYLE="color:#' || rTheme.caption_text_colour || ';font-family:' || rTheme.caption_text_font || ';font-size: ' || fontSize || '">' );
         htp.p( '&nbsp;' );
         htp.p( '</TD>' );
         htp.tableRowClose;
         i_minutes := i_minutes + c2rec.time_block;
      end loop;
      i_hours := i_hours + 1;
   end loop;

   htp.tableRowOpen;
   -- Print the link to the previous day
   if nvl(scrolldate,'F') = 'F'
    then
     htp.tableData( '&nbsp;', cattributes=>'ALIGN="CENTER" WIDTH="100"' );
    else
     htp.tableData( htf.anchor('bkn.reception_show_day?surl=' || surl || '&acid=' || acid || '&calid=' || calid || '&p_days_in_view=' || p_days_in_view || '&scrolldate=' || scrolldate ||
                               '&p_proposed_date=' || replace(to_char( date_time-1, LNG.TSMASK ),' ','+') || '&action=' || replace(action,' ','+'), '&lt;&lt; Previous Day'), cattributes=>'ALIGN="CENTER" WIDTH="100"' );
   end if;

   -- Print the headers
   for i in -daysBefore..daysAfter loop
      htp.tableData( htf.bold( INITCAP( LOWER( TO_CHAR( date_time + i, LNG5.BKN_TXT_086 ) ) ) ), cattributes=>' WIDTH="160" ALIGN="CENTER"' );
   end loop;
   -- Print the link to the next day
   if nvl(scrolldate,'F') = 'F'
    then
     htp.tableData( '&nbsp;', cattributes=>'ALIGN="CENTER" WIDTH="100"' );
    else
     htp.tableData( htf.anchor('bkn.reception_show_day?surl=' || surl || '&acid=' || acid || '&calid=' || calid || '&p_days_in_view=' || p_days_in_view || '&scrolldate=' || scrolldate ||
                               '&p_proposed_date=' || replace(to_char( date_time+1, LNG.TSMASK ),' ','+') || '&action=' || replace(action,' ','+'), 'Next Day &gt;&gt;'), cattributes=>'ALIGN="CENTER" WIDTH="100"' );
   end if;

   htp.tableRowClose;
   htp.tableClose;
   htp.p( '</FONT>' );
   -- Navigation buttons
   htp.p( '</CENTER>' );
   glbx.close_page( rTheme );

   exception when others then
      glbx.error_details( PACKAGE_NAME, 'RECEPTION_SHOW_DAY', errmsg=>sqlerrm );
end reception_show_day;

procedure reception_booking_details( surl varchar2, acid integer default null,
                                     bid integer, rurl varchar2 default null,
                                     action varchar2 default null,
                                     msg varchar2 default null,
                                     firsttime in char default 'T')
as
   cursor c1( cbid integer ) is
      select *
      from booking b
      where b.booking_id = cbid;
   -- Retrieve program details
   cursor c2( cbid integer ) is
      select p.umo_id prgid,
             p.program_obj.program_name program_name,
             bp.num_of_visitors num_of_visitors
      from booked_programs bp, umo p
      where bp.booking_id = cbid and
         p.umo_id = bp.program_id;
   cursor c2x( cbid integer ) is
      select count( 'x' ) total
      from booked_programs bp, umo p
      where bp.booking_id = cbid and p.umo_id = bp.program_id;
   --
   -- Retrieve workbook details
   --
   cursor c3( cbid integer ) is
      select w.umo_id wid, w.program_obj.program_name workbook_name
      from booked_workbooks bw, umo w
      where bw.booking_id = cbid and w.umo_id = bw.workbook_id;
   cursor c3x( cbid integer ) is
      select count( 'x' ) total
      from booked_workbooks bw, umo w
      where bw.booking_id = cbid and w.umo_id = bw.workbook_id;
   --
   -- Retrieve school details
   --
   cursor c4( csid integer ) is
      select *
      from customer_contact
      where aid = csid and user_type = 'E';
   --
   -- Retrieve company details
   --
   cursor c5( ccid integer ) is
      select *
      from customer_contact
      where aid = ccid and user_type = 'T';
   --
   -- Retrieve customer details
   --
   cursor c6( caid integer ) is
      select *
      from customer_contact
      where aid = caid;

   cursor c7( cpoid integer ) is
      select count( 'x' ) total
      from purchase_order
      where poid = cpoid and
            status in ( select order_option
                        from workflow_state_options
                        where order_by <= 5 and work_state = 0 );

   cursor c8( cprofileId integer ) is
      select username, password_owner, aid
      from customer_profile
      where profile_id = cprofileId;

   cursor c9( cVisitTypeId integer ) is
      select visit_type_name, class, is_paid_program
      from visit_types
      where visit_type_id = cVisitTypeId;

   -- Look and feel variables
   c1rec 		c1%ROWTYPE;
   c2rec 		c2%ROWTYPE;
   c2xrec 		c2x%ROWTYPE;
   c3rec 		c3%ROWTYPE;
   c3xrec 		c3x%ROWTYPE;
   c4rec 		c4%ROWTYPE;
   c5rec 		c5%ROWTYPE;
   c6rec 		c6%ROWTYPE;
   c7rec 		c7%ROWTYPE;
   c8rec 		c8%ROWTYPE;
   c9rec 		c9%ROWTYPE;
   rTheme		THEME%ROWTYPE;
   xsurl		varchar2(100);
   xlrec		login_session%ROWTYPE;
   def			school_booking_prefs%ROWTYPE;

begin
   if glbx.extract_master_parameter('COOKIE_ENABLED') = 'TRUE'
    then
      xsurl := piction_cookie( xlrec );
      owa_util.mime_header('text/html', FALSE);
       owa_cookie.remove(nvl(glbx.extract_master_parameter('COOKIE_NAME'),'PICTION_COOKIE'), xsurl);
      owa_util.http_header_close;
   end if;
   if not dapi.init( surl, 'BKN.LAB_RECEPTION_SCREEN', acid, iscust=>FALSE, reset=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   rTheme := dapi.getLFRecord;
   dapi.setTitle( LNG5.BKN_TXT_029 );
   dapi.pageOpen;
   open c1( bid );
   fetch c1 into c1rec;
   close c1;
   open c8( c1rec.made_by );
   fetch c8 into c8rec;
   close c8;
   open c7( c1rec.purchase_order_id );
   fetch c7 into c7rec;
   close c7;
   def := getDefaults( nvl(acid,c8rec.aid) );

   htp.p( '<center>' );
   --
   -- Display error message if any
   --
   if msg is not null then
      htp.p( '<font size="+3" color="#' || rTheme.error_text_colour || '" FACE="' || rTheme.error_text_font || '">'|| msg || '</font>' );
   end if;

   -- Relogin
   --lab.login_connectas(surl, profid=>NULL );

   htp.formOpen( 'bkn.reception_checkout', cattributes=>'name="form1"' );
   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   htp.formHidden( 'bid', c1rec.booking_id );
   htp.formHidden( 'rurl', rurl );
   htp.formhidden( 'FIRSTTIME', firsttime );
   htp.tableOpen( cattributes=>'border="1" cellpadding="2" cellspacing="2"' );

   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Current information' ), ccolspan=>'4', cattributes=>rTheme.qbground || ' align=center width="50%"' );
   htp.tableRowClose;
   --
   -- Booking request number
   --
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Booking Request number' ), cattributes=>rTheme.qbground );
   htp.tableData( c1rec.booking_id, cattributes=>rTheme.qcbground );
   htp.tableRowClose;
   --
   -- Purchase order iD
   --
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Purchase order ID' ), cattributes=>rTheme.qbground );
   htp.tableData( anchor_receipt(surl, c1rec, acid), cattributes=>rTheme.qcbground );
   htp.tableRowClose;
   --
   -- Date
   --
   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_067 ), cattributes=>rTheme.qbground );
   htp.tableData( TO_CHAR( c1rec.date_time, lng3.ADM_DATE_02 ), cattributes=>rTheme.qcbground );
   htp.tableRowClose;
   --
   -- Time
   --
   htp.tableRowOpen;
   htp.tableData( htf.bold( LNG5.BKN_TXT_068 ), cattributes=>rTheme.qbground );
   htp.tableData( TO_CHAR( c1rec.date_time, lng.TSMASK_ONLY ), cattributes=>rTheme.qcbground );
   htp.tableRowClose;
   --
   -- Created by
   --
   if c1rec.made_by is not null then
      open c6( c1rec.made_by );
      fetch c6 into c6rec;
      close c6;

      htp.tableRowOpen;
      htp.tableData( htf.bold( LNG5.BKN_TXT_071 ), cattributes=>rTheme.qbground );
      htp.tableData( c6rec.billing_name, cattributes=>rTheme.qcbground );
      htp.tableRowClose;
   end if;
   --
   -- Type of visit
   --
   open c9( c1rec.visit_type );
   fetch c9 into c9rec;
   close c9;
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Type of visit' ), cattributes=>rTheme.qbground );
   htp.tableData( c9rec.visit_type_name || ' (' || c9rec.class || ')',
                  cattributes=>rTheme.qcbground );
   htp.tableRowClose;
   --
   -- Number of students
   --
   -- xxx paid_by
   if c9rec.is_paid_program = 'T'
    then
     htp.tableRowOpen;
     htp.tableData( htf.bold( 'Who is to pay' ), cattributes=>rTheme.qbground );
     htp.p( '<TD ' || rTheme.qcbground || '>' );
     if c1rec.paid_by = 'E' then htp.p( 'School' );
     elsif c1rec.paid_by = 'T' then htp.p( 'Bus company' );
     else
     htp.p( 'n/a' );
     end if;
     htp.tableRowClose;
   end if;

   htp.tableRowOpen;
   htp.tableData( htf.bold( lng5.BKN_TXT_046 ), cattributes=>rTheme.qbground );
   htp.tableData( c1rec.school_year, cattributes=>rTheme.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( lng5.BKN_TXT_036 ), cattributes=>rTheme.qbground );
   htp.tableData( c1rec.num_of_students, cattributes=>rTheme.qcbground );
   htp.tableRowClose;

   htp.tableRowOpen;
   htp.tableData( htf.bold( lng5.BKN_TXT_048 ), cattributes=>rTheme.qbground );
   htp.tableData( c1rec.num_of_adults, cattributes=>rTheme.qcbground );
   htp.tableRowClose;
   --
   -- If the booking is for a paid program then show the chosen programs, if any
   --
   open c2x( bid );
   fetch c2x into c2xrec;
   close c2x;
   if c2xrec.total > 0 then
      if getVisitTypeClass( c1rec.visit_type ) = LNG5.BKN_TXT_002 then
         htp.tableRowOpen( cvalign=>'TOP' );
         htp.tableData( htf.bold( LNG5.BKN_TXT_073 ), cattributes=>rTheme.qbground );
         htp.p( '<TD>' );
         htp.tableopen( cattributes=>'border="0" cellpadding="0" cellspacing="1"' );
         for c2rec in c2( bid ) loop
            htp.tableRowOpen;
            htp.tableData( htf.bold( c2rec.num_of_visitors ) );
            htp.tableData( 'x' );
            htp.tableData( c2rec.program_name );
            htp.tableRowClose;
         end loop;
         htp.tableClose;
         htp.p( '</TD>' );
         htp.tableRowClose;
      end if;
   end if;
   --
   -- Show the school details
   --
   if c1rec.school_id is not null then
      open c4( c1rec.school_id );
      fetch c4 into c4rec;
      close c4;
      htp.tableRowOpen( cvalign=>'TOP' );
      htp.tableData( htf.bold( lng5.BKN_TXT_014 ), cattributes=>rTheme.qbground );
      htp.p( '<TD ' || rTheme.qcbground || '>' );
         htp.p( c4rec.billing_name );
         htp.nl;
         htp.p( c4rec.billing_street );
         htp.nl;
         htp.p( c4rec.billing_suburb || ' ' || c4rec.billing_state || ' ' ||
                c4rec.billing_postcode );
      htp.p( '</TD>' );
      htp.tableRowClose;
   end if;
   --
   -- Show company details
   --
   if c1rec.bus_company_id is not null then
      open c5( c1rec.bus_company_id );
      fetch c5 into c5rec;
      close c5;

      htp.tableRowOpen( cvalign=>'TOP' );
      htp.tableData( htf.bold( lng5.BKN_TXT_015 ), cattributes=>rTheme.qbground );
      htp.p( '<TD>' );
         htp.p( c5rec.billing_name );
         htp.nl;
         htp.p( c5rec.billing_street );
         htp.nl;
         htp.p( c5rec.billing_suburb || ' ' || c5rec.billing_state || ' ' ||
                c5rec.billing_postcode );
      htp.p( '</TD>' );
      htp.tableRowClose;
   end if;
   --
   -- Techer name
   --
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Teacher name' ), cattributes=>rTheme.qbground || ' width="50%"' );
   htp.tableData( c1rec.contact_person, cattributes=>rTheme.qcbground );
   htp.tableRowClose;
   --
   -- Techer email
   --
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Teacher email' ), cattributes=>rTheme.qbground || ' width="50%"' );
   htp.tableData( c1rec.contact_email, cattributes=>rTheme.qcbground );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Actual information' ), ccolspan=>'4', cattributes=>rTheme.qbground || ' ALIGN=CENTER' );
   htp.tableRowClose;
   --
   -- Actual number of students
   --
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Who is to pay' ), cattributes=>rTheme.qbground );
   htp.p( '<TD ' || rTheme.qcbground || '>' );
   if c1rec.paid_by = 'E' then htp.p( 'School' );
   elsif c1rec.paid_by = 'T' then htp.p( 'Bus company' );
   else
    htp.p( 'n/a' );
   end if;
   htp.tableRowClose;

   htp.tableRowOpen( cattributes=>'style="vertical-align: top;"' );
   htp.tableData( htf.bold( 'Actual number of students' ), cattributes=>rTheme.qbground || ' width="50%"' ); -- changed from students
   htp.p( '<td ' || rTheme.qcbground || '>' );
    if (((( c1rec.purchase_order_id is null ) or ( c7rec.total > 0 )) and not (c9rec.is_paid_program = 'F')) and trunc(c1rec.date_time) <= trunc(sysdate)) or
            (c9rec.is_paid_program = 'F' and trunc(c1rec.date_time) <= trunc(sysdate) and c1rec.status = LNG5.BKN_TXT_006)
     then
      htp.formText( 'pNumberOfStudentsx', 3, 3, cvalue=>c1rec.actual_num_of_programs );
     else
      htp.p( nvl(to_char(c1rec.actual_num_of_programs), '&nbsp;' ) );
    end if;
   htp.p( '</td>' );
   htp.tableRowClose;

   if c9rec.is_paid_program = 'T'
    then
     htp.tableRowOpen( cattributes=>'style="vertical-align: top;"' );
     --htp.tableData( htf.bold( 'Actual number of programs' ), cattributes=>rTheme.qbground || ' width="50%"' );
     htp.tableData( htf.bold( 'Number of students participating in Program' ), cattributes=>rTheme.qbground || ' width="50%"' );
     htp.p( '<td ' || rTheme.qcbground || '>' );
     htp.formHidden( 'pProgramId', null );
     htp.formHidden( 'pNumberOfStudents', null );
     if getVisitTypeClass( c1rec.visit_type ) = LNG5.BKN_TXT_002 then
        htp.formHidden( 'num_of_visitors', 0 );
        htp.tableOpen( cattributes=>'border="0" cellpadding="0" cellspacing="1"' );
          for c2rec in c2( bid ) loop
          htp.tableRowOpen;
           if (((( c1rec.purchase_order_id is null ) or ( c7rec.total > 0 )) and not (c9rec.is_paid_program = 'F')) and trunc(c1rec.date_time) <= trunc(sysdate)) or
              (c9rec.is_paid_program = 'F' and trunc(c1rec.date_time) <= trunc(sysdate)) and c1rec.status = LNG5.BKN_TXT_006
            then
             if firsttime = 'T'
              then
               htp.tableData( htf.formHidden( 'pProgramId', c2rec.prgid ) || htf.formtext( 'pNumberOfStudents', 3, 3, null ) );
              else
               htp.tableData( htf.formHidden( 'pProgramId', c2rec.prgid ) || htf.formtext( 'pNumberOfStudents', 3, 3, c2rec.num_of_visitors ) );
           end if;
          else
           htp.tabledata( nvl(to_char(c2rec.num_of_visitors),'&nbsp;') );
         end if;
         htp.tableData( 'x' );
         htp.tableData( c2rec.program_name );
         htp.tableRowClose;
      end loop;
      htp.tableClose;
     else
      if (((( c1rec.purchase_order_id is null ) or ( c7rec.total > 0 )) and not (c9rec.is_paid_program = 'F')) and trunc(c1rec.date_time) <= trunc(sysdate)) or
              (c9rec.is_paid_program = 'F' and trunc(c1rec.date_time) <= trunc(sysdate) and c1rec.status = LNG5.BKN_TXT_006)
       then
        htp.formText( 'num_of_visitors', cvalue=>c1rec.actual_num_of_students );
      else
        htp.p( nvl(to_char(c1rec.actual_num_of_students), '&nbsp;' ) );
      end if;
    end if;
   htp.p( '</td>' );
   htp.tableRowClose;
   else
     htp.formHidden( 'pProgramId', null );
     htp.formHidden( 'pNumberOfStudents', null );
   end if;

   --
   -- Actual number of adults
   --
   htp.tableRowOpen( cattributes=>'style="vertical-align: top;"' );
   htp.tableData( htf.bold( 'Actual number of adults' ), cattributes=>rTheme.qbground || ' width="50%"' );
   if (((( c1rec.purchase_order_id is null ) or ( c7rec.total > 0 )) and not (c9rec.is_paid_program = 'F')) and trunc(c1rec.date_time) <= trunc(sysdate)) or
            (c9rec.is_paid_program = 'F' and trunc(c1rec.date_time) <= trunc(sysdate) and c1rec.status = LNG5.BKN_TXT_006)
    then
     htp.tableData( htf.formText( 'num_of_adults', cvalue=>c1rec.actual_num_adults ), cattributes=>rTheme.qcbground );
    else
     htp.tableData( nvl(to_char(c1rec.actual_num_adults),'&nbsp;'), cattributes=>rTheme.qcbground );
   end if;
   htp.tableRowClose;
   if c1rec.bus_company_id is not null then
      --
      -- Who is to pay
      --
      if (((( c1rec.purchase_order_id is null ) or ( c7rec.total > 0 )) and
            not (c9rec.is_paid_program = 'F')) and trunc(c1rec.date_time) <= trunc(sysdate))
       then
        htp.tableRowOpen;
        htp.tableData( htf.bold( 'Who is to pay' ), cattributes=>rTheme.qbground );
        htp.p( '<TD ' || rTheme.qcbground || '>' );
        if c1rec.paid_by = 'E' then
           htp.formRadio( 'creditor', 'E', 'checked' );
        else
           htp.formRadio( 'creditor', 'E' );
        end if;
        htp.p( 'School' );
        htp.nl;
        if c1rec.paid_by = 'T' then
           htp.formRadio( 'creditor', 'T', 'checked' );
        else
           htp.formRadio( 'creditor', 'T' );
        end if;
        htp.p( 'Bus company' );
        htp.p( '</TD>' );
        htp.tableROwClose;
      else
        if c1rec.paid_by = 'E'
         then
          htp.tableRowOpen;
          htp.tableData( htf.bold( 'Who is to pay' ), cattributes=>rTheme.qbground );
          htp.p( '<TD ' || rTheme.qcbground || '>' );
          htp.p( 'School' );
          htp.p( '</TD>' );
          htp.tableROwClose;
        end if;
      end if;
   else
      htp.formHidden( 'creditor', SCHOOL_PAYS );
   end if;
   --
   -- Note
   --
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Note' ), cattributes=>rTheme.qbground || ' width="50%"' );
   htp.tableData( '&nbsp;' );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( htf.formTextAreaOpen( 'note', def.TEXTBOX_HEIGHT, def.TEXTBOX_WIDTH ) || c1rec.reception_note || htf.formTextAreaClose, cattributes=>rTheme.qcbground || ' colspan="2"' );
   htp.tableRowClose;

   htp.tableClose;

   -- htp.formSubmit( 'action', lng5.BKN_BUT_003 );

   --
   -- Checkout Button
   if ((( c1rec.purchase_order_id is null ) or ( c7rec.total > 0 )) and not (c9rec.is_paid_program = 'F')) and trunc(c1rec.date_time) <= trunc(sysdate)
    then
      htp.formSubmit( 'action', lng.CST_BUT_127 );
  -- elsif c1rec.visit_type in ('2','Self Guided') and trunc(c1rec.date_time) <= trunc(sysdate) and c1rec.status = LNG5.BKN_TXT_006
   elsif c9rec.is_paid_program = 'F' and trunc(c1rec.date_time) <= trunc(sysdate) and c1rec.status = LNG5.BKN_TXT_006
    then
      htp.formSubmit( 'action', 'Visit Complete' );
   end if;

   --
   --

   htp.formClose;
   htp.nl;
   htp.nl;
    htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
   htp.p( '</CENTER>' );
   dapi.pageClose;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'RECEPTION_BOOKING_DETAILS', errmsg=>sqlerrm );
end reception_booking_details;

function piction_cookie( lrec out login_session%ROWTYPE )
 return varchar2
as
  cursor c1(surl varchar2) is select * from login_session where securl = surl;

  c1rec	c1%ROWTYPE;
  ck	owa_cookie.cookie;
  id	varchar2(100);

begin
  -- Piction Cookie Feature has been disabled.
  if glbx.extract_master_parameter('COOKIE_ENABLED') = 'FALSE'
   then
    return( NULL );
  end if;

  ck := owa_cookie.get(nvl(glbx.extract_master_parameter('COOKIE_NAME'),'PICTION_COOKIE'));
  if ck.num_vals = 0
   then
    return( NULL );
  end if;
  -- insert into temp values ('Z:' || ck.vals(1) ); commit;
  -- insert into temp values ('Z:' || glbx.truncsurl(ck.vals(1)) ); commit;
  id := glbx.truncsurl(ck.vals(1));
  open c1(id);
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
    close c1;
    return( NULL );
  end if;
  close c1;
  lrec := c1rec;
  return( id );
exception
 when others
  then
  htp.bold(sqlerrm);
   return( NULL );
end piction_cookie;

procedure reception_checkout( surl varchar2, acid integer, bid integer,
                              rurl varchar2, num_of_visitors varchar2 default null,
                              num_of_adults   varchar2, note varchar2,
                              creditor varchar2 default null,
                              action varchar2 default null,
                              pProgramId GLBX.MYARRAY,
                              pNumberOfStudents GLBX.MYARRAY,
                              pNumberOfStudentsx varchar2 default null,
                              firsttime in char default 'T')
as
   cursor c1( cBookingId integer ) is
      select *
      from booking
      where booking_id = cBookingId;
   cursor c2( cLoginType varchar2, cAccountId integer ) is
      select *
      from customer_contact
      where login_type = cLogintype and
            aid = cAccountId;
   cursor c3( cLogintype varchar2, cAccountId integer ) is
      select sessid
      from login_session
      where login_type = cLogintype and
            aid = cAccountId
      order by date_created desc;
   cursor c4( cBookingId integer, cProgramId integer ) is
      select num_of_visitors
      from booked_programs
      where booking_id = bid and program_id = cProgramid;
   cursor c9( cVisitTypeId integer ) is
      select visit_type_name, class, is_paid_program
      from visit_types
      where visit_type_id = cVisitTypeId;

   /*
      Work variables
   */
   c1rec 		c1%ROWTYPE;
   c2rec 		c2%ROWTYPE;
   c3rec 		c3%ROWTYPE;
   c4rec 		c4%ROWTYPE;
   c9rec 		c9%ROWTYPE;
   msg 			varchar2( 100 ) := '';
   goto_checkout 	boolean;
   lNewSurl 		varchar2( 100 );
   lProfileId 		integer;
   tmp			integer;
   lNumOfVisitors 	integer := 0;
   vad 			integer;
   vadx			integer;
   i 			pls_integer;
   email_sendto 	varchar2( 100 );
   xsurl		varchar2(100);
   xlrec		login_session%ROWTYPE;

begin
   if not dapi.init( surl, 'BKN.RECEPTION_CHECKOUT', acid, iscust=>FALSE, reset=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   open c1( bid );
   fetch c1 into c1rec;
   close c1;
   open c9( c1rec.visit_type );
   fetch c9 into c9rec;
   close c9;
   if action = lng5.BKN_BUT_003 then
      bkn.reception_show_day( surl, acid, p_days_in_view=>'1' );

   elsif action = 'Visit Complete' then -- Visit Completed
      begin tmp := num_of_visitors; exception when others then bkn.reception_booking_details( surl, acid, bid, rurl, action, 'Bad Number of Students Value entered', 'F' ); return; end;
      begin tmp := num_of_adults; exception when others then bkn.reception_booking_details( surl, acid, bid, rurl, action, 'Bad Number of Adults Value entered', 'F' ); return; end;
      if num_of_visitors is null and c9rec.is_paid_program = 'T' then bkn.reception_booking_details( surl, acid, bid, rurl, action, 'You must enter in a value for number of students', 'F' ); return; end if;
      if num_of_adults is null then bkn.reception_booking_details( surl, acid, bid, rurl, action, 'You must enter in a value for number of adults', 'F' ); return; end if;
      vad := num_of_adults;
      begin vadx := pNumberOfStudentsx; exception when others then bkn.reception_booking_details( surl, acid, bid, rurl, action, 'Bad Number of Students entered', 'F' ); return; end;
      if vad <= 0 then bkn.reception_booking_details( surl, acid, bid, rurl, action, 'Number of Adults entered must be greater than 0', 'F' ); return; end if;
      if vadx <= 0 and c9rec.is_paid_program = 'T' then bkn.reception_booking_details( surl, acid, bid, rurl, action, 'Number of Students entered must be greater than 0', 'F' ); return; end if;
      if send_email( surl, acid, bid, 'Visit Complete', email_sendto ) then commit; else rollback; end if;
      if c9rec.is_paid_program = 'T' then
        update booking
           set actual_num_of_students = num_of_visitors,
               actual_num_adults = vad,
               actual_num_of_programs = vadx,
               reception_note = substr(note,1,2000),
               status = 'Visit Complete'
           where booking_id = bid;
      else
        update booking
           set actual_num_of_students = vadx,
               actual_num_adults = vad,
           --    actual_num_of_programs = vadx,
               reception_note = substr(note,1,2000),
               status = 'Visit Complete'
           where booking_id = bid;
      end if;
      commit;
      bkn.reception_booking_details( surl, acid, bid, rurl, action, 'Status changed to Visit Completed', 'F' );

   elsif action = lng.CST_BUT_127 then -- Checkout
      goto_checkout := true;
      begin
         lNumOfVisitors := TO_NUMBER( num_of_visitors );
      exception when others then
         lNumOfVisitors := 0;
      end;
      if num_of_adults is null then bkn.reception_booking_details( surl, acid, bid, rurl, action, 'You must enter in a value for number of adults', 'F' ); return; end if;
      vad := num_of_adults;
      begin vadx := pNumberOfStudentsx; exception when others then bkn.reception_booking_details( surl, acid, bid, rurl, action, 'Bad Number of Students entered', 'F' ); return; end;
      if vad <= 0 then bkn.reception_booking_details( surl, acid, bid, rurl, action, 'Number of Adults entered must be greater than 0', 'F' ); return; end if;
      if vadx <= 0 then bkn.reception_booking_details( surl, acid, bid, rurl, action, 'Number of Students entered must be greater than 0', 'F' ); return; end if;
      for i in pNumberOfStudents.first..pNumberOfStudents.last loop
         lNumOfVisitors := lNumOfVisitors + NVL( pNumberOfStudents( i ), 0 );
         if pProgramId( i ) is not null then
            open c4( bid, pProgramId( i ) );
            fetch c4 into c4rec;
            close c4;
            if c4rec.num_of_visitors != pNumberOfStudents( i ) then
               update booked_programs
                  set num_of_visitors = NVL( pNumberOfStudents( i ), 0 )
                  where booking_id = bid and program_id = pProgramId( i );
               insert into audit_booking
                  values(
                     SYSDATE, bid, 'BOOKED_PROGRAMS', 'Number of visitors',
                     'For program ' || pProgramId( i ) || ' number_of_visitors=' ||
                     c4rec.num_of_visitors, 'changed to ' || pNumberOfStudents( i ),
                     acid );
            end if;
         end if;
      end loop;
      commit;
      if nvl( lNumOfVisitors, 0 ) <= 0 then
         msg := msg || 'Please specify the number of students actually visiting';
         goto_checkout := false;
      end if;
      if creditor is null then
         msg := msg || 'Please specify who is to pay';
         goto_checkout := false;
      end if;
      if goto_checkout then
         vad := num_of_adults;
         update booking
            set actual_num_of_students = (select sum(num_of_visitors) from booked_programs where booking_id = bid),
                actual_num_adults = vad,
                actual_num_of_programs = vadx,
                reception_note = substr(note,1,2000),
                paid_by = decode(visit_type,'2',null,creditor)
            where booking_id = bid;
         commit;
         -- We can go ahead with the checkout
         -- Before that we have to relogin as the account that is paying for the booking
         -- School or Bus company and copy over the purchase order details
         if creditor = SCHOOL_PAYS then
            lProfileId := c1rec.school_id;
         elsif creditor = COMPANY_PAYS then
            lProfileId := c1rec.bus_company_id;
         else
            bkn.reception_booking_details( surl, acid, bid, rurl, action, 'Please select who is to pay', 'F' );
            return;
         end if;

         if firsttime = 'T'
          then
           lNewSurl := loginAsProfile( surl, lProfileId );
          else
           lNewSurl := surl;
         end if;

         -- .
         if ( createPurchaseOrder( lNewSurl, acid, bid ) = 0 ) then
            msg := 'Checkout for booking request ' || bid;
            fname.disp_payment_screen( lNewSurl, acid, msg, 'FULL' );
            return;
         else
            msg := msg || LNG5.BKN_TXT_028;
            bkn.reception_booking_details( lNewSurl, acid, bid, rurl, action, msg, 'F' );
         end if;

      else
         bkn.reception_booking_details( surl, acid, bid, rurl, action, msg, 'F' );
      end if;
   end if;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'RECEPTION_CHECKOUT', errmsg=>sqlerrm );
end reception_checkout;

function getmanid
 return integer
is
 cursor c1( mtype varchar2 ) is select manufacturer_id from manufacturer where man_type = mtype;
 c1rec  c1%ROWTYPE;
begin
 open c1( 'BOOKINGS' );
 fetch c1 into c1rec;
 close c1;
 return( c1rec.manufacturer_id );
end getmanid;

function createPurchaseOrder( surl varchar2, acid integer, bid integer ) return pls_integer
as
   /*
    * Cursor definitions
    */
   cursor c1( cbid integer ) is
      select purchase_order_id, made_by, school_id, bus_company_id,
             actual_num_of_students, paid_by, contact_person,
             contact_phone, contact_email
      from booking
      where booking_id = cbid;
   cursor c4( csid integer ) is
      select *
      from customer_contact
      where aid = csid and login_type = 'PROFILE' and user_type = 'E';
   cursor c5( ccid integer ) is
      select *
      from customer_contact
      where aid = ccid and login_type = 'PROFILE' and user_type = 'T';
   cursor c6( cbid integer ) is
      select um.program_obj program_obj, greatest(nvl(bp.num_of_visitors,0),nvl(um.extras.orderby_nmb,0)) num_of_visitors
      from umo um, booked_programs bp
      where um.umo_id = bp.program_id and bp.booking_id = cbid;
   cursor c7( cbid integer ) is
      select um.program_obj
      from umo um, booked_workbooks bw
      where ( um.umo_id = bw.workbook_id ) and ( bw.booking_id = cbid );
   cursor c8( cProfileId integer ) is
      select *
      from customer_account
      where aid = ( select aid from customer_profile where profile_id = cProfileId );
   cursor c9( cProfileId integer ) is
      select *
      from order_style
      where oid = ( select MAX(oid)
                    from customer_price_book
                    where aid = cProfileId and ltype = 'PROFILE' );
   cursor c10( vsurl varchar2 ) is select * from login_session where securl = vsurl;
   /*
    *  Work variables
    */
   c1rec c1%ROWTYPE;
   c4rec c4%ROWTYPE;
   c5rec c5%ROWTYPE;
   c6rec c6%ROWTYPE;
   c7rec c7%ROWTYPE;
   cusrec c8%ROWTYPE;
   c10rec c10%ROWTYPE;
   lSessionId integer;
   lProfileId integer;
   lAccountId integer;
   lPhotographerId integer;
   rOrderStyle order_style%ROWTYPE;
   rPurchaseOrder purchase_order%ROWTYPE;

   p_contact_name    purchase_order.contact_name%TYPE;
   p_contact_phone   purchase_order.contact_phone%TYPE;
   p_sendto_name     purchase_order.sendto_name%TYPE;
   p_sendto_firstname     purchase_order.sendto_firstname%TYPE;
   p_sendto_lastname     purchase_order.sendto_lastname%TYPE;
   p_sendto_street   purchase_order.sendto_street%TYPE;
   p_sendto_suburb   purchase_order.sendto_suburb%TYPE;
   p_sendto_state     purchase_order.sendto_state%TYPE;
   p_sendto_postcode purchase_order.sendto_postcode%TYPE;
   p_sendto_country  purchase_order.sendto_country%TYPE;

   p_billing_name     purchase_order.billing_name%TYPE;
   p_billing_firstname     purchase_order.billing_firstname%TYPE;
   p_billing_lastname     purchase_order.billing_lastname%TYPE;
   p_billing_street   purchase_order.billing_street%TYPE;
   p_billing_suburb   purchase_order.billing_suburb%TYPE;
   p_billing_state     purchase_order.billing_state%TYPE;
   p_billing_postcode purchase_order.billing_postcode%TYPE;
   p_billing_country  purchase_order.billing_country%TYPE;

   p_contact_email       purchase_order.contact_email%TYPE;
   new_shopping_id       shopping_basket.shopping_id%TYPE;
   new_purchase_order_id purchase_order.poid%TYPE;
   manid		 integer;
   pdef			school_booking_prefs%ROWTYPE;

begin
   if not dapi.init( surl, 'BKN.createPurchaseOrder', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return 1;
   end if;
   --lSessionId := dapi.getSessionId;
   -- DAPI is still using the old SURL
   open c10( glbx.truncsurl( surl ) );
   fetch c10 into c10rec;
   close c10;
   lSessionId := c10rec.sessid;
   lAccountId := dapi.getAccountId;
   lPhotographerId := dapi.getPhotographerId;
   pdef := getDefaults_prof( dapi.GLOBAL_PROFILE_ID );

   open c1( bid );
   fetch c1 into c1rec;
   close c1;
   -- Create a new purchase order record if one does not exist yet, otherwise
   -- use the purchase_order_id that is stored in the booking record.
   -- if c1rec.purchase_order_id is null then
   if c1rec.paid_by = SCHOOL_PAYS then
      lProfileId := c1rec.school_id;
   elsif c1rec.paid_by = COMPANY_PAYS then
      lProfileId := c1rec.bus_company_id;
   end if;
   open c8( lProfileId );
   fetch c8 into cusrec;
   close c8;
   open c9( lProfileId );
   fetch c9 into rOrderStyle;
   close c9;
   fname.create_purchase_order( surl, lSessionId, 'PreOrder - No Order Made',
                                lProfileId, 'PROFILE', cusrec, rOrderStyle,
                                rPurchaseOrder );
   new_purchase_order_id := rPurchaseOrder.poid;
   -- Attach the purchase order to the active booking
   update booking
      set purchase_order_id = new_purchase_order_id
      where booking_id = bid;
   commit;
   -- Enter the purchase order details
   open c4( c1rec.school_id );
   fetch c4 into c4rec;
   close c4;
   -- The school details are used for the sendto details
   p_sendto_name := c4rec.billing_name;
   p_sendto_street := c4rec.billing_street;
   p_sendto_suburb := c4rec.billing_suburb;
   p_sendto_state := c4rec.billing_state;
   p_sendto_postcode := c4rec.billing_postcode;
   p_sendto_country := c4rec.billing_country;
   if c1rec.paid_by = SCHOOL_PAYS then
      -- Paid by school
      p_billing_name     := c4rec.billing_name;
      p_billing_street   := c4rec.billing_street;
      p_billing_suburb   := c4rec.billing_suburb;
      p_billing_state     := c4rec.billing_state;
      p_billing_postcode := c4rec.billing_postcode;
      p_billing_country  := c4rec.billing_country;
   elsif c1rec.paid_by = COMPANY_PAYS then
      -- Paid by bus company
      open c5( c1rec.bus_company_id );
      fetch c5 into c5rec;
      close c5;
      p_billing_name     := c5rec.billing_name;
      p_billing_street   := c5rec.billing_street;
      p_billing_suburb   := c5rec.billing_suburb;
      p_billing_state     := c5rec.billing_state;
      p_billing_postcode := c5rec.billing_postcode;
      p_billing_country  := c5rec.billing_country;
   end if;
   -- Use a column in the purchase order to store the booking ID

     -- Determine Tax
     rPurchaseOrder.other_cost := nvl(rOrderStyle.pricing_gst,0);
     if rPurchaseOrder.other_cost > 0
      then
       if rOrderStyle.pricing_gst_int_sales = 'F' and
          rPurchaseOrder.local_internation = 'INTERNATIONAL'
        then
         rPurchaseOrder.other_cost := 0;
       end if;
     end if;
     -- Is GST Inclusive?
     rPurchaseOrder.gst_incl := rOrderStyle.pricing_gst_inclusive;
   glbx.fixnm(p_sendto_name,p_sendto_firstname,p_sendto_lastname);
   glbx.fixnm(p_billing_name,p_billing_firstname,p_billing_lastname);
   update purchase_order
      set customer_column1 = bid,
          billing_name     = p_billing_name,
          billing_firstname     = p_billing_firstname,
          billing_lastname     = p_billing_lastname,
          billing_street   = p_billing_street,
          billing_suburb   = p_billing_suburb,
          billing_state    = p_billing_state,
          billing_postcode = p_billing_postcode,
          billing_country  = p_billing_country,
          sendto_name      = p_sendto_name,
          sendto_firstname      = p_sendto_firstname,
          sendto_lastname      = p_sendto_lastname,
          sendto_street    = p_sendto_street,
          sendto_suburb    = p_sendto_suburb,
          sendto_state     = p_sendto_state,
          sendto_postcode  = p_sendto_postcode,
          sendto_country   = p_sendto_country,
          date_purchased   = SYSDATE,
          delivery_cost    = 0,
          is_b2c           = 'T',
          printed_out      = 'F',
          sessid           = lSessionId,
          pid              = lPhotographerId,
          other_cost       = nvl(rPurchaseOrder.other_cost,0),
          gst_incl         = rPurchaseOrder.gst_incl
      where poid = new_purchase_order_id;
   -- Create shopping basket items
   -- Clean up older shopping basket items first
   delete from shopping_basket where poid = new_purchase_order_id;
   commit;
   manid := getmanid;
   -- Fill the shopping basket items with the program details
   for c6rec in c6( bid ) loop
      select s_shopping_basket.nextval into new_shopping_id from dual;
      insert into shopping_basket (
         poid,
         shopping_id,
         qty,
         isgallery,
         photo_cost,
         photo_size,
         film_name,
         lab_id,
         xref_mfctr_code)
      values (
         new_purchase_order_id,
         new_shopping_id,
         c6rec.num_of_visitors,
         'B',
         c6rec.program_obj.cost_per_head,
         c6rec.program_obj.program_name,
         c6rec.program_obj.program_name,
         manid,
         pdef.default_xref_mfctr_code);
   end loop;
   commit;
   return 0;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'CREATEPURCHASEORDER', errmsg=>sqlerrm );
end createPurchaseOrder;

function getDefaults( pPhotographerId integer, acid integer )
   return school_booking_prefs%ROWTYPE
as
   cursor c1( cpid integer, cacid integer ) is
   select
      *
   from
      school_booking_prefs
   where
      std_profile_aid = cacid and
      std_profile_pid = cpid;
   rDefaults school_booking_prefs%ROWTYPE;
   sess_id integer;
begin
   open c1( pPhotographerId, acid );
   fetch c1 into rDefaults;
   close c1;
   return rDefaults;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'GETDEFAULTS', errmsg=>sqlerrm );
end getDefaults;

procedure lab_make_a_booking(
  surl varchar2,
  acid integer )
as
   rTheme   theme%ROWTYPE;
begin
   if not dapi.init( surl, 'BKN.LAB_MAKE_A_BOOKING', iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   dapi.setTitle( LNG5.BKN_TXT_163 );
   dapi.pageOpen;
   htp.p( '<center>' );
   htp.p( LNG5.BKN_TXT_016 );
   htp.nl;
   htp.anchor( 'scl.mng_booking_profiles?surl=' || surl || '&acid=' || acid || '&user_type=E' || '&pFunctionality=' || SCL.CONNECTAS, LNG5.BKN_TXT_020 );
   htp.nl;
   htp.anchor( 'scl.mng_booking_profiles?surl=' || surl || '&acid=' || acid || '&user_type=T' || '&pFunctionality=' || SCL.CONNECTAS, LNG5.BKN_TXT_022 );
   htp.p( '</center>' );
   dapi.pageClose;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'LAB_MAKE_A_BOOKING', errmsg=>sqlerrm );
end lab_make_a_booking;

procedure lab_mng_visit_types( surl varchar2, acid integer )
as
   cursor c1( cpid integer ) is
   select
      *
   from
      visit_types
   where
      pid = cpid;
   c1rec c1%ROWTYPE;
   cursor c2( cacid integer ) is
   select
      pid
   from
      customer_account
   where
      aid = cacid;
   lPhotographerId integer;
   pfx theme%ROWTYPE;
begin
   if not dapi.init( surl, 'BKN.LAB_MNG_VISIT_TYPES', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   dapi.setTitle( 'Manage Visit Types' );
   pfx := dapi.getLFRecord;
   dapi.pageOpen;
   htp.p( '<center>' );
   htp.formOpen( 'bkn.lab_insert_visit_types' );
   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   htp.formSubmit( 'pInsert', 'Insert' );
   htp.tableOpen( cattributes=>'border="1" cellpadding="2" cellspacing="2"' );
   htp.tableHeader( 'ID', cattributes=>pfx.qbground );
   htp.tableHeader( 'Name', cattributes=>pfx.qbground );
   htp.tableHeader( 'Class', cattributes=>pfx.qbground );
   htp.tableHeader( 'Valid From', cattributes=>pfx.qbground );
   htp.tableHeader( 'Valid To', cattributes=>pfx.qbground );
   htp.tableHeader( 'Click to Delete', cattributes=>pfx.qbground );
   open c2( acid );
   fetch c2 into lPhotographerId;
   close c2;
   for c1rec in c1( lPhotographerId ) loop
      htp.tableRowOpen;
      htp.tableData( htf.anchor( 'bkn.lab_update_visit_types?surl=' || surl || '&acid=' || acid || '&pVisitType=' || c1rec.visit_type_id, c1rec.visit_type_id ), cattributes=>pfx.qcbground );
      htp.tableData( c1rec.visit_type_name, cattributes=>pfx.qcbground );
      htp.tableData( c1rec.class, cattributes=>pfx.qcbground );
      htp.tableData( TO_CHAR( c1rec.valid_from_date, LNG.MASK ), cattributes=>pfx.qcbground );
      htp.tableData( TO_CHAR( c1rec.valid_to_date, LNG.MASK ), cattributes=>pfx.qcbground );
      htp.tableData( htf.anchor( 'bkn.lab_delete_visit_types?surl=' || surl || '&acid=' || acid || '&pVisitType=' || c1rec.visit_type_id, 'Delete' ), cattributes=>pfx.qcbground );
      htp.tableRowClose;
   end loop;
   htp.tableClose;
   htp.formSubmit( 'pInsert', 'Insert' );
   htp.formClose;
   htp.p( '</center>' );
   dapi.pageClose;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'LAB_MNG_VISIT_TYPES', errmsg=>sqlerrm );
end lab_mng_visit_types;

procedure lab_insert_visit_types( surl varchar2, acid integer, pInsert varchar2 default null, pErrorMessage varchar2 default null )
as
   pfx theme%ROWTYPE;
begin
   if not dapi.init( surl, 'BKN.LAB_INSERT_VISIT_TYPES', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   pfx := dapi.getLFRecord;
   dapi.setTitle( 'Insert a Visit Type' );
   dapi.pageOpen;
   htp.p( '<center>' );
   htp.header( 2, pErrorMessage, cattributes=>'class="ERROR"' );
   htp.formOpen( 'bkn.lab_accept_insert_visit_types' );
   htp.formHidden( 'surl', surl );
   htp.formhidden( 'acid', acid );
   htp.tableOpen( cattributes=>'border="1" cellpadding="2" cellspacing="2"' );
   htp.tableRowOpen;
   htp.tableHeader( 'Name', cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'pName', 50, 100 ), cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableHeader( 'Class', cattributes=>pfx.qbground );
   htp.p( '<td ' || pfx.qcbground || ' ALIGN="LEFT"' || '>' );
   htp.formSelectOpen( 'pClass' );
   htp.formSelectOption( LNG5.BKN_TXT_002 );
   htp.formSelectOption( LNG5.BKN_TXT_003 );
   htp.formSelectClose;
   htp.p( '</td>' );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableHeader( 'Valid From ( ' || LNG.MASK || ' )', cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'pValidFrom' ), cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableHeader( 'Valid To ( ' || LNG.MASK || ' )', cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'pValidTo' ), cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableHeader( 'Time From ( ' || LNG.TSMASK_ONLY || ' )', cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'pTimeFrom' ), cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableHeader( 'Time To ( ' || LNG.TSMASK_ONLY || ' )', cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'pTimeTo' ), cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
   htp.tableRowClose;
   htp.tableRowOpen;
    htp.tableHeader( 'Requires Payment', cattributes=>pfx.qbground );
    htp.tableData( htf.formCheckbox( 'pIspaid', 'T', 'CHECKED' ), cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableHeader( 'Description', cattributes=>pfx.qbground );
   htp.tableData( htf.formTextAreaOpen( 'pDescription', 6, 50 ) || htf.formTextAreaClose, cattributes=>pfx.qcbground );
   htp.tableRowClose;
   htp.tableClose;
   htp.formSubmit( 'pInsert', 'Insert' );
   htp.formSubmit( 'pCancel', 'Cancel' );
   htp.formClose;
   htp.p( '</center>' );
   dapi.pageClose;
end lab_insert_visit_types;

procedure lab_accept_insert_visit_types(
  surl varchar2,
  acid integer,
  pName varchar2 default null,
  pClass varchar2 default null,
  pValidFrom varchar2 default null,
  pValidTo varchar2 default null,
  pTimeFrom varchar2 default null,
  pTimeTo varchar2 default null,
  pDescription varchar2 default null,
  pIspaid char default 'F',
  pInsert varchar2 default null,
  pCancel varchar2 default null )
as
   cursor c1( caid integer ) is
   select
      pid
   from
      customer_account
   where
      aid = caid;

   lReturnMessage varchar2( 1000 );
   lId integer;
   lName visit_types.visit_type_name%TYPE;
   lClass visit_types.class%TYPE;
   lValidFrom visit_types.valid_from_date%TYPE;
   lValidTo visit_types.valid_to_date%TYPE;
   lValidFromTime visit_types.valid_from_time%TYPE;
   lValidToTime visit_types.valid_to_time%TYPE;
   lDescription visit_types.description%TYPE;
   lDummyDate date;
   lPhotographerId integer;
begin
   if pCancel is not null then
      goto cancel_procedure;
   end if;
   if not dapi.init( surl, 'BKN.LAB_ACCEPT_INSERT_VISIT_TYPES', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   begin
      lValidFrom := TO_DATE( pValidFrom, LNG.MASK );
   exception when others then
      lReturnMessage := lReturnMessage || '<br>Invalid date format for from date';
   end;
   begin
      lValidTo := TO_DATE( pValidTo, LNG.MASK );
   exception when others then
      lReturnMessage := lReturnMessage || '<br>Invalid date format for to date';
   end;
   begin
      lDummyDate := TO_DATE( pTimeFrom, LNG.TSMASK_ONLY );
      lValidFromTime := pTimeFrom;
   exception when others then
      lReturnMessage := lReturnMessage || '<br>Invalid time format for from time';
   end;
   begin
      lDummyDate := TO_DATE( pTimeTo, LNG.TSMASK_ONLY );
      lValidToTime := pTimeTo;
   exception when others then
      lReturnMessage := lReturnMessage || '<br>Invalid time format for to time';
   end;
   lName := pName;
   lClass := pClass;
   lDescription := pDescription;
   if lReturnMessage is not null then
      lab_insert_visit_types( surl, acid, null, lReturnMessage );
      return;
   end if;
   open c1( acid );
   fetch c1 into lPhotographerId;
   close c1;
   select s_visit_types.nextval into lid from dual;
   insert into visit_types (
      pid,
      visit_type_id,
      visit_type_name,
      class,
      valid_from_date,
      valid_to_date,
      valid_from_time,
      valid_to_time,
      is_paid_program,
      description )
   values(
      lPhotographerId,
      lId,
      lName,
      lClass,
      lValidFrom,
      lValidTo,
      lValidFromTime,
      lValidToTime,
      pIspaid,
      lDescription );
   commit;
   <<cancel_procedure>>
   lab_mng_visit_types( surl, acid );
exception when others then
   glbx.error_details( PACKAGE_NAME, 'LAB_ACCEPT_INSERT_VISIT_TYPES', errmsg=>sqlerrm );
end lab_accept_insert_visit_types;

procedure lab_update_visit_types( surl varchar2, acid integer, pVisitType integer, pErrorMessage varchar2 default null )
as
   cursor c1( ctypeid integer, caid integer ) is
   select
      *
   from
      visit_types
   where
      visit_type_id = ctypeid and
      pid = ( select pid from customer_account where aid = caid );
   c1rec c1%ROWTYPE;

   cursor c4( ccid integer ) is
      select * from school_holidays where calendar_id = ccid
      order by date_from;
   c4rec c4%ROWTYPE;

   pfx theme%ROWTYPE;
begin
   if not dapi.init( surl, 'BKN.LAB_INSERT_VISIT_TYPES', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   pfx := dapi.getLFRecord;
   dapi.setTitle( 'Update Visit Type' );
   dapi.addStyle( 'TH', '{text-align: left}' );
   dapi.pageOpen;
   open c1( pVisitType, acid );
   fetch c1 into c1rec;
   close c1;
   htp.p( '<center>' );
   htp.header( 2, pErrorMessage, cattributes=>'class="ERROR"' );
   htp.formOpen( 'bkn.lab_accept_update_visit_types' );
   htp.formHidden( 'surl', surl );
   htp.formhidden( 'acid', acid );
   htp.formhidden( 'pId', pVisitType );
   htp.tableOpen( cattributes=>'border="1" cellpadding="2" cellspacing="2"' );
   htp.tableRowOpen;
   htp.tableHeader( 'Name', cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'pName', 50, 100, cvalue=>c1rec.visit_type_name ), cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableHeader( 'Class', cattributes=>pfx.qbground );
   htp.p( '<td ' || pfx.qcbground || ' ALIGN="LEFT"' || '>' );
   htp.formSelectOpen( 'pClass' );
   if c1rec.class = LNG5.BKN_TXT_002 then
      htp.formSelectOption( LNG5.BKN_TXT_002, 'SELECTED' );
      htp.formSelectOption( LNG5.BKN_TXT_003 );
   elsif c1rec.class = LNG5.BKN_TXT_003 then
      htp.formSelectOption( LNG5.BKN_TXT_002 );
      htp.formSelectOption( LNG5.BKN_TXT_003, 'SELECTED' );
   else
      htp.formSelectOption( LNG5.BKN_TXT_002 );
      htp.formSelectOption( LNG5.BKN_TXT_003 );
   end if;
   htp.formSelectClose;
   htp.p( '</td>' );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableHeader( 'Valid From ( ' || LNG.MASK || ' )', cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'pValidFrom', cvalue=>TO_CHAR( c1rec.valid_from_date, LNG.MASK ) ), cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableHeader( 'Valid To ( ' || LNG.MASK || ' )', cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'pValidTo', cvalue=>TO_CHAR( c1rec.valid_to_date, LNG.MASK ) ), cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableHeader( 'Time From ( ' || LNG.TSMASK_ONLY || ' )', cattributes=>pfx.qbground );
   htp.tableData( htf.formText( 'pTimeFrom', cvalue=>c1rec.valid_from_time ), cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
   htp.tableRowClose;
   htp.tableRowOpen;
    htp.tableHeader( 'Time To ( ' || LNG.TSMASK_ONLY || ' )', cattributes=>pfx.qbground );
    htp.tableData( htf.formText( 'pTimeTo', cvalue=>c1rec.valid_to_time ), cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
   htp.tableRowClose;
   htp.tableRowOpen;
    htp.tableHeader( 'Requires Payment', cattributes=>pfx.qbground );
    if c1rec.is_paid_program = 'T'
     then
      htp.tableData( htf.formCheckbox( 'pIspaid', 'T', 'CHECKED' ), cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
     else
      htp.tableData( htf.formCheckbox( 'pIspaid', 'T' ), cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
    end if;
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableHeader( 'Description', cattributes=>pfx.qbground );
   htp.tableData( htf.formTextAreaOpen( 'pDescription', 6, 50 ) || c1rec.description || htf.formTextAreaClose, cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
   htp.tableRowClose;
   htp.tableClose;
   htp.formSubmit( 'pUpdate', 'Update' );
   htp.formSubmit( 'pCancel', 'Cancel' );
   htp.formClose;
   htp.formOpen( 'bkn.enter_school_holidays' );
   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   htp.formHidden( 'pVisitTypeId', c1rec.visit_type_id );
   htp.tableOpen( cattributes=>'cellpadding="0" cellspacing="0" border="1"' );
      htp.tableRowOpen;
         htp.tableData( LNG5.BKN_TXT_095, ccolspan=>'5', cattributes=>pfx.qbground );
      htp.tableRowClose;
      htp.tableRowOpen;
         htp.tableData( htf.bold( LNG5.BKN_TXT_054 || '<br>( ' || LNG.MASK || ' )' ), cattributes=>pfx.qbground );
         htp.tableData( htf.bold( LNG5.BKN_TXT_055 || '<br>( ' || LNG.MASK || ' )' ), cattributes=>pfx.qbground );
         htp.tableData( htf.bold( LNG5.BKN_TXT_093 || '<br>( ' || LNG.TSMASK_ONLY || ' )' ), cattributes=>pfx.qbground );
         htp.tableData( htf.bold( LNG5.BKN_TXT_094 || '<br>( ' || LNG.TSMASK_ONLY || ' )' ), cattributes=>pfx.qbground );
         htp.tableData( htf.bold( LNG5.BKN_TXT_021 ), cattributes=>pfx.qbground );
      htp.tableRowClose;
         for c4rec in c4( c1rec.visit_type_id ) loop
            htp.tableRowOpen;
               htp.tableData( TO_CHAR( c4rec.date_from, LNG.MASK ), cattributes=>pfx.qcbground );
               htp.tableData( TO_CHAR( c4rec.date_to, LNG.MASK ), cattributes=>pfx.qcbground );
               htp.tableData( c4rec.opening_time, cattributes=>pfx.qcbground );
               htp.tableData( c4rec.closing_time, cattributes=>pfx.qcbground );
               htp.tableData( htf.anchor( 'bkn.delete_school_holidays?surl=' || surl || '&acid=' || acid || '&pVisitTypeId=' || c1rec.visit_type_id || '&pDateFrom=' || TO_CHAR( c4rec.date_from, LNG.TSMASK ) || '&pDateTo=' || TO_CHAR( c4rec.date_to, LNG.TSMASK ), LNG5.BKN_TXT_021 ), cattributes=>pfx.qcbground );
            htp.tableRowClose;
         end loop;
      htp.tableRowOpen;
         htp.tableData( htf.formText( 'pDateFrom', cvalue=>'' ), cattributes=>pfx.qcbground );
         htp.tableData( htf.formText( 'pDateTo', cvalue=>'' ), cattributes=>pfx.qcbground );
         htp.tableData( htf.formText( 'pTimeFrom', cvalue=>'' ), cattributes=>pfx.qcbground );
         htp.tableData( htf.formText( 'pTimeTo', cvalue=>'' ), cattributes=>pfx.qcbground );
         htp.tableData( '&nbsp;', cattributes=>pfx.qcbground );
      htp.tableRowClose;
   htp.tableClose;
   htp.formSubmit( 'pAction',LNG5.BKN_TXT_107 );
   htp.formClose;
   htp.p( '</center>' );
   dapi.pageClose;
end lab_update_visit_types;

procedure enter_school_holidays(
  surl varchar2,
  acid integer default null,
  pVisitTypeId varchar2,
  pDateFrom varchar2,
  pDateTo varchar2,
  pTimeFrom varchar2,
  pTimeTo varchar2,
  pAction varchar2 )
as
   msg       varchar2( 1000 ) := NULL;
   lDateTimeFrom date;
   lDateTimeTo   date;
begin
   if not dapi.init( surl, 'BKN.ENTER_SCHOOL_HOLIDAYS', iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   begin
      lDateTimeFrom := TO_DATE( pDateFrom || ' ' || pTimeFrom, LNG.MASK || ' ' || LNG.TSMASK_ONLY );
   exception when others then
      msg := msg || htf.nl || LNG3.ADM_TXT_633 || '''' || pDateFrom || ' ' || pTimeFrom || '''';
      lDateTimeFrom := NULL;
   end;
   begin
      lDateTimeTo := TO_DATE( pDateTo || ' ' || pTimeTo, LNG.MASK || ' ' || LNG.TSMASK_ONLY );
   exception when others then
      msg := msg || htf.nl || LNG3.ADM_TXT_633 || '''' || pDateTo || ' ' || pTimeTo || '''';
      lDateTimeTo := NULL;
   end;
   if msg is NULL then
      insert into school_holidays
      ( calendar_id,
       date_from,
       date_to,
       opening_time,
       closing_time
       )
      values
      ( pVisitTypeId,
       lDateTimeFrom,
       lDateTimeTo,
       pTimeFrom,
       pTimeTo
      );
   end if;
   lab_update_visit_types( surl, acid, pVisitTypeId, msg );
exception when others then
   glbx.error_details( PACKAGE_NAME, 'ENTER_SCHOOL_HOLIDAYS', errmsg=>sqlerrm );
end enter_school_holidays;

procedure delete_school_holidays( surl varchar2, acid integer default null, pVisitTypeId varchar2, pDateFrom varchar2, pDateTo varchar2 )
as
begin
   delete from school_holidays
   where ( calendar_id = pVisitTypeId ) and
      date_from = TO_DATE( pDateFrom, LNG.TSMASK ) and
      date_to   = TO_DATE( pDateTo, LNG.TSMASK );
   lab_update_visit_types( surl, acid, pVisitTypeId );
end delete_school_holidays;

procedure lab_accept_update_visit_types(
  surl varchar2,
  acid integer,
  pId integer,
  pName varchar2 default null,
  pClass varchar2 default null,
  pValidFrom varchar2 default null,
  pValidTo varchar2 default null,
  pTimeFrom varchar2 default null,
  pTimeTo varchar2 default null,
  pDescription varchar2 default null,
  pUpdate varchar2 default null,
  pIspaid char default 'F',
  pCancel varchar2 default null )
as
   cursor c1( caid integer ) is
   select
      pid
   from
      customer_account
   where
      aid = caid;

   lReturnMessage varchar2( 1000 );
   lId integer;
   lName visit_types.visit_type_name%TYPE;
   lClass visit_types.class%TYPE;
   lValidFrom visit_types.valid_from_date%TYPE;
   lValidTo visit_types.valid_to_date%TYPE;
   lValidFromTime visit_types.valid_from_time%TYPE;
   lValidToTime visit_types.valid_to_time%TYPE;
   lDescription visit_types.description%TYPE;
   lDummyDate date;
   lPhotographerId integer;
begin
   if pCancel is not null then
      goto cancel_procedure;
   end if;
   if not dapi.init( surl, 'BKN.LAB_ACCEPT_UPDATE_VISIT_TYPES', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   begin
      lValidFrom := TO_DATE( pValidFrom, LNG.MASK );
   exception when others then
      lReturnMessage := lReturnMessage || '<br>Invalid date format for from date';
   end;
   begin
      lValidTo := TO_DATE( pValidTo, LNG.MASK );
   exception when others then
      lReturnMessage := lReturnMessage || '<br>Invalid date format for to date';
   end;

   begin
      lDummyDate := TO_DATE( pTimeFrom, LNG.TSMASK_ONLY );
      lValidFromTime := to_char(lDummyDate,'HH24:MI');
   exception when others then
      lReturnMessage := lReturnMessage || '<br>Invalid time format for from time';
   end;
   begin
      lDummyDate := TO_DATE( pTimeTo, LNG.TSMASK_ONLY );
      lValidToTime := to_char(lDummyDate,'HH24:MI');
   exception when others then
      lReturnMessage := lReturnMessage || '<br>Invalid time format for to time';
   end;

   lId := pId;
   lName := pName;
   lClass := pClass;
   lDescription := pDescription;
   if lReturnMessage is not null then
      lab_update_visit_types( surl, acid, lId, lReturnMessage );
      return;
   end if;
   open c1( acid );
   fetch c1 into lPhotographerId;
   close c1;
   update visit_types set
      visit_type_name = lName,
      class = lClass,
      valid_from_date = lValidFrom,
      valid_to_date = lValidTo,
      valid_from_time = lValidFromTime,
      valid_to_time = lValidToTime,
      is_paid_program = pIspaid,
      description = lDescription
   where
      visit_type_id = lId and
      pid = lPhotographerId;
   commit;
   <<cancel_procedure>>
   lab_mng_visit_types( surl, acid );
exception when others then
   glbx.error_details( PACKAGE_NAME, 'LAB_ACCEPT_UPDATE_VISIT_TYPES', errmsg=>sqlerrm );
end lab_accept_update_visit_types;

procedure lab_delete_visit_types( surl varchar2, acid integer, pVisitType integer )
as
   cursor c1( cvisitid integer, caid integer ) is
   select
      *
   from
      visit_types
   where
      visit_type_id = cvisitid and
      pid = ( select pid from customer_account where aid = caid );
   c1rec c1%ROWTYPE;
   pfx theme%ROWTYPE;
begin
   if not dapi.init( surl, 'BKN.LAB_INSERT_VISIT_TYPES', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   pfx := dapi.getLFRecord;
   dapi.pageOpen;
   open c1( pVisitType, acid );
   fetch c1 into c1rec;
   close c1;
   htp.p( '<center>' );
   htp.formOpen( 'bkn.lab_accept_delete_visit_types' );
   htp.formHidden( 'surl', surl );
   htp.formhidden( 'acid', acid );
   htp.formhidden( 'pId', pVisitType );
   htp.tableOpen( cattributes=>'border="1" cellpadding="2" cellspacing="2"' );
   htp.tableRowOpen;
   htp.tableHeader( 'Name', cattributes=>pfx.qbground );
   htp.tableData( c1rec.visit_type_name, cattributes=>pfx.qcbground );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableHeader( 'Class', cattributes=>pfx.qbground );
   htp.tableData( c1rec.class, cattributes=>pfx.qcbground );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableHeader( 'Valid From ( ' || LNG.MASK || ' )', cattributes=>pfx.qbground );
   htp.tableData( TO_CHAR( c1rec.valid_from_date, LNG.MASK ), cattributes=>pfx.qcbground );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableHeader( 'Valid To ( ' || LNG.MASK || ' )', cattributes=>pfx.qbground );
   htp.tableData( TO_CHAR( c1rec.valid_to_date, LNG.MASK ), cattributes=>pfx.qcbground );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableHeader( 'Time From ( ' || LNG.TSMASK_ONLY || ' )', cattributes=>pfx.qbground );
   htp.tableData( c1rec.valid_from_time, cattributes=>pfx.qcbground );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableHeader( 'Time To ( ' || LNG.TSMASK_ONLY || ' )', cattributes=>pfx.qbground );
   htp.tableData( c1rec.valid_to_time, cattributes=>pfx.qcbground );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableHeader( 'Description', cattributes=>pfx.qbground );
   htp.tableData( c1rec.description, cattributes=>pfx.qcbground );
   htp.tableRowClose;
   htp.tableClose;
   htp.formSubmit( 'pDelete', 'Delete' );
   htp.formSubmit( 'pCancel', 'Cancel' );
   htp.formClose;
   htp.p( '</center>' );
   dapi.pageClose;
end lab_delete_visit_types;

procedure lab_accept_delete_visit_types(
  surl varchar2,
  acid integer,
  pId integer,
  pDelete varchar2 default null,
  pCancel varchar2 default null )
as
   cursor c1( caid integer ) is
   select
      pid
   from
      customer_account
   where
      aid = caid;
   lPhotographerId integer;
   lId visit_types.visit_type_id%TYPE;
begin
   if pCancel is not null then
      goto cancel_procedure;
   end if;
   open c1( acid );
   fetch c1 into lPhotographerId;
   close c1;
   lId := pId;
   delete
   from
      visit_types vt
   where
      vt.visit_type_id = lId and
      vt.pid = lPhotographerId;
   commit;
   <<cancel_procedure>>
   lab_mng_visit_types( surl, acid );
exception when others then
   glbx.error_details( PACKAGE_NAME, 'LAB_ACCEPT_DELETE_VISIT_TYPES', errmsg=>sqlerrm );
end lab_accept_delete_visit_types;

procedure mng_booking( surl varchar2, acid integer )
as
   cursor c1( caid integer ) is
   select
      pid
   from
      customer_account
   where
      aid = caid;
   cursor c2(mfid integer) is select * from manufacturer where manufacturer_id = mfid;

   c2rec		manufacturer%ROWTYPE;
   pfx		THEME%ROWTYPE;
   lPhotographerId integer;
begin
   if not dapi.init( surl, 'BKN.MNG_BOOKING', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   pfx := dapi.getLFRecord;
   dapi.pageOpen;
   open c1( acid );
   fetch c1 into lPhotographerId;
   close c1;
   open c2(dapi.getAccountId);
   fetch c2 into c2rec;
   close c2;
   -- Show selection options
   htp.fontOpen( csize=>'-3' );
   htp.bold( 'Default settings' );
   htp.uListOpen;
   htp.listItem( htf.anchor2( 'bkn.default_settings?surl=' || surl || '&acid=' || acid, 'Default settings', ctarget=>'MANAGE_BOOKING_DATA' ), cattributes=>pfx.qcbground );
   htp.uListClose;
   htp.bold( 'Master Data' );
   htp.uListOpen;
   htp.listItem( htf.anchor2( 'bkn.lab_mng_visit_types?surl=' || surl || '&acid=' || acid, 'Manage Visit Types', ctarget=>'MANAGE_BOOKING_DATA' ), cattributes=>pfx.qcbground );
   htp.listItem( htf.anchor2( 'cal.update_calendar?surl=' || surl || '&acid=' || lPhotographerId, 'Manage Calendars', ctarget=>'MANAGE_BOOKING_DATA' ), cattributes=>pfx.qcbground );
   htp.listItem( htf.anchor2( 'scl.mng_booking_profiles?surl=' || surl || '&acid=' || acid || '&user_type=E', 'Maintain schools', ctarget=>'MANAGE_BOOKING_DATA' ), cattributes=>pfx.qcbground );
   htp.listItem( htf.anchor2( 'scl.mng_booking_profiles?surl=' || surl || '&acid=' || acid || '&user_type=T', 'Maintain bus companies', ctarget=>'MANAGE_BOOKING_DATA' ), cattributes=>pfx.qcbground );
   htp.listItem( htf.anchor2( 'prg.maintain_program?surl=' || surl || '&acid=' || acid || '&program_type=' || LNG5.PRG_TXT_110, 'Maintain programs', ctarget=>'MANAGE_BOOKING_DATA' ), cattributes=>pfx.qcbground );
   htp.listItem( htf.anchor2( 'prg.maintain_program?surl=' || surl || '&acid=' || acid || '&program_type=' || LNG5.PRG_TXT_111, 'Maintain workbooks', ctarget=>'MANAGE_BOOKING_DATA' ), cattributes=>pfx.qcbground );
   htp.listItem( htf.anchor2( 'rsc.maintain_resources?surl=' || surl || '&acid=' || acid, 'Maintain resources', ctarget=>'MANAGE_BOOKING_DATA' ), cattributes=>pfx.qcbground );
   htp.listItem( htf.anchor2( 'ste.maintain_state?surl=' || surl || '&acid=' || acid, 'Maintain states', ctarget=>'MANAGE_BOOKING_DATA' ), cattributes=>pfx.qcbground );
   htp.uListClose;
   htp.bold( 'Manage Bookings' );
   htp.uListOpen;
   htp.listItem( htf.anchor2( 'bkn.lab_maintain_bookings?surl=' || surl || '&acid=' || acid, 'View calendar', ctarget=>'MANAGE_BOOKING_DATA' ), cattributes=>pfx.qcbground );
   htp.listItem( htf.anchor2( 'bkn.lab_list_of_bookings?surl=' || surl || '&acid=' || acid || '&firsttime=T', 'List bookings', ctarget=>'MANAGE_BOOKING_DATA' ), cattributes=>pfx.qcbground );
   htp.listItem( htf.anchor2( 'bkn.lab_reception_screen?surl=' || surl || '&acid=' || acid || '&scrolldate=' || substr(c2rec.man_bf,21,1), 'Enter reception screen', ctarget=>'MANAGE_BOOKING_DATA' ), cattributes=>pfx.qcbground );
   htp.listItem( htf.anchor2( 'bkn.lab_make_a_booking?surl=' || surl || '&acid=' || acid, 'Create a booking', ctarget=>'MANAGE_BOOKING_DATA' ), cattributes=>pfx.qcbground );
   htp.uListClose;
   htp.fontClose;
   dapi.pageClose;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'MNG_BOOKING', errmsg=>sqlerrm );
end mng_booking;

procedure booking_admin( surl varchar2, acid integer )
as
begin
   if not dapi.init( surl, 'BKN.BOOKING_ADMIN', iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   htp.framesetOpen( ccols=>'230,*' );
      htp.frame( 'bkn.mng_booking?surl=' || surl || '&acid=' || acid, 'MANAGE_BOOKING_MENU', '0', '0', 'YES', 'YES' );
      htp.frame( null, 'MANAGE_BOOKING_DATA', '0', '0', 'YES', 'NO' );
   htp.framesetClose;
exception when others then
   glbx.error_details( PACKAGE_NAME, 'BOOKING_ADMIN', errmsg=>sqlerrm );
end booking_admin;

function send_Email( surl varchar2, acid integer default null, pBookingid integer, new_status varchar2, pIsSendto out varchar2 ) return boolean
as

   cursor c1( cbid integer ) is select * from booking b where booking_id = cbid;

   cursor c2( cbid integer ) is
   select
      um.program_obj.program_name program_name,
      um.program_obj.url url,
      bp.num_of_visitors num_of_visitors,
      um.extras.orderby_nmb min_nmb,
      um.program_obj.cost_per_head cph
   from
      booking b,
      booked_programs bp,
      umo um
   where
      b.booking_id = bp.booking_id and
      um.umo_id = program_id and
      b.booking_id = cbid;

   cursor c3( cid integer ) is select * from customer_contact where aid = cid and login_type = 'PROFILE';
   cursor c4( cid integer ) is select billing_name from customer_contact where aid = cid;

   c1rec 		c1%ROWTYPE;
   c3rec 		c3%ROWTYPE;
   c3arec 		c3%ROWTYPE;
   gcode 		GLBX.MYARRAY;
   gparam 		GLBX.MYARRAY;
   lSessionId 		integer;
   sentOk 		boolean := FALSE;
   rTheme 		theme%ROWTYPE;
   email_template 	varchar2( 256 );
   email_subject 	varchar2( 256 );
   email_sendto 	varchar2( 256 );
   programs 		varchar2( 4000 );

begin
   -- return TRUE;
   open c1( pBookingId );
   fetch c1 into c1rec;
   close c1;
   if new_status is null then return( TRUE ); end if;
   if c1rec.status is null then return( TRUE ); end if;
   if new_status = c1rec.status then return( TRUE ); end if;

   if new_status = LNG5.BKN_TXT_005 -- Reservation
    then
     email_subject := 'Thank-you for booking.' || '(' || pBookingId || ')';
   elsif new_status = 'Accepted Reservation' -- Accepted Reservation
    then
     email_subject := 'Booking Request' || ' ' || pBookingId;
   elsif new_status = 'Problem' -- Problem
    then
     email_subject := 'Problem with Booking Request.' || '(' || pBookingId || ')';
   elsif new_status = LNG5.BKN_TXT_009 -- Cancelled
    then
     email_subject := 'Booking Request Cancelled.' || '(' || pBookingId || ')';
   elsif new_status = LNG5.BKN_TXT_006 -- Full Booking
    then
     email_subject := 'Booking Request Confirmed.' || '(' || pBookingId || ')';
     update booking set date_confirmation_sent = sysdate where booking_id = pBookingId;
     commit;
   elsif new_status = 'Visit Complete' -- Visit Complete
    then
     email_subject := 'Thank-you for Visiting.' || '(' || pBookingId || ')';
   elsif new_status = 'Reservation Accepted' -- Reservation Accepted
    then
     email_subject := 'Booking Reservation.' || '(' || pBookingId || ')';
   else
     email_subject := 'Booking Reservation.' || '(' || pBookingId || ')';
   end if;

   open c3( c1rec.made_by );
   fetch c3 into c3arec;
   close c3;
   email_sendto := nvl(c3arec.billing_email,c1rec.contact_email);
   if c1rec.paid_by = SCHOOL_PAYS then
      open c3( c1rec.school_id );
      fetch c3 into c3rec;
      close c3;
   elsif c1rec.paid_by = COMPANY_PAYS then
      open c3( c1rec.bus_company_id );
      fetch c3 into c3rec;
      close c3;
   end if;

   email_template := 'booking_' || replace(new_status,' ','_') || '_' || c3arec.user_type || '_' || c3rec.user_type || '_' || c1rec.visit_type || '.tmp';

   gcode( 1 )  := 'BOOKING_RESERVATION_NUMBER';
   gparam( 1 ) := c1rec.booking_id;
   gcode( 2 )  := 'TEACHERS_NAME';
   gparam( 2 ) := c1rec.contact_person;
   gcode( 3 )  := 'DATE';
   gparam( 3 ) := TO_CHAR( c1rec.date_time, 'DD Month YYYY' );
   gcode( 4 )  := 'TIME';
   gparam( 4 ) := TO_CHAR( c1rec.date_time, LNG.TSMASK_ONLY );
   for c2rec in c2( pBookingId ) loop
      programs := programs || c2rec.program_name || CRLF;
      programs := programs || TAB || 'for ' || c2rec.num_of_visitors || ' students' || CRLF;
      programs := programs || TAB || '@ ' || trim(to_char( c2rec.cph, LNG.MONEY_FORMAT )) || '/student incl GST.';
      if nvl(c2rec.num_of_visitors,1) < nvl(c2rec.min_nmb,1)
       then
        programs := programs || ' ' || '(min ' || trim(to_char( c2rec.cph * c2rec.min_nmb, LNG.MONEY_FORMAT )) || ')' || CRLF;
       else
        programs := programs || CRLF;
      end if;
      -- programs := programs || TAB || 'For info see: ' || c2rec.url || CRLF;
   end loop;
   gcode( 5 )  := 'PROGRAMS';
   gparam( 5 ) := programs;
   gcode( 6 )  := 'ADULTS';
   gparam( 6 ) := c1rec.num_of_adults;
   gcode( 7 )  := 'BILLING_NAME';
   gparam( 7 ) :=  nvl(c3rec.billing_name,'The school or bus company');
   gcode( 8 )  := 'SCHOOL_NAME';
   open c4( c1rec.school_id );
   fetch c4 into gparam( 8 );
   if c4%NOTFOUND then gparam(8) := 'No School Found.'; end if;
   close c4;
   gcode( 9 )  := 'BUS_COMPANY_NAME';
   open c4( c1rec.bus_company_id );
   fetch c4 into gparam( 9 );
   if c4%NOTFOUND then gparam(9) := 'No Bus Company Found.'; end if;
   close c4;
   gcode( 10 )  := 'CONTACT_NAME';
   gparam( 10 ) := c1rec.contact_person;
   gcode( 11 )  := 'STUDENTS';
   gparam( 11 ) := c1rec.num_of_students;
   gcode( 12 )  := 'LEVEL';
   gparam( 12 ) := c1rec.school_year;
   gcode( 13 )  := 'COST';
   gparam( 13 ) := to_char(glbx.grand_total_payment(c1rec.PURCHASE_ORDER_ID,include_gift_certificate=>FALSE),LNG.MONEY_FORMAT);
   gcode( 14 )  := 'MADE_BY_NAME';
   gparam( 14 ) :=  nvl(c3arec.billing_name,'The school or bus company');

   begin
      glbx.send( gcode, gparam, lower(email_template), email_sendto, email_subject, nvl(glbx.extract_master_parameter( 'BOOKING_MAIL_FROM' ),glbx.extract_master_parameter( 'MAIL_FROM' )) );
      sentOk := TRUE;
      pIsSendto := email_sendto;
   exception when others then
      sentOk := FALSE;
   end;
   return sentOk;
end send_email;

/** Login 1 show a screen where the user has to type in the name and select a state */
procedure login1( acid integer, pName varchar2 default null, pState varchar2 default null )
as
begin
   htp.p( '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">' );
   htp.htmlOpen;
   htp.headOpen;
   htp.title( 'Education' );
   htp.p( '<link rel="StyleSheet" href="' || BKN_STYLESHEET || '" type="text/css">' );
   htp.headClose;
   htp.bodyOpen;
   htp.p( '<script type="text/javascript" src="' || BKN_TOPSCRIPT || '"></script>' );
   htp.p( '<div class="bodytext">' );
   htp.header( 1, 'Make a booking' );
   htp.tableOpen;
   htp.tableClose;
   htp.formopen( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'bkn.login2' );
   htp.formHidden( 'acid', acid );
   htp.tableOpen( cattributes=>'border="0" cellpadding="0" cellspacing="0"' );
   htp.tableRowOpen;
   htp.tableData( '<label for="company_school">Name of company/school*:</label>' );
   htp.tableData( htf.formtext( 'pName', '46', '60', pName, cattributes=>'id="company_school"' ) );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( 'State*:' );
   htp.tableData( ste.get_state_lov( 'pState', pState, TRUE ) );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( '&nbsp;' );
   htp.tableData( htf.formImage( 'pSubmit', DECS.IMAGE_LOCATION || 'booking/continue.gif',
                  cattributes=>'border="0"' ) );
   htp.tableRowClose;
   htp.tableClose;
   htp.formClose;
   htp.p( '</div>' );
   htp.p( '<script type="text/javascript" src="' || BKN_BOTTOMSCRIPT || '"></script>' );
   htp.bodyClose;
   htp.htmlClose;
end login1;

procedure login2( acid integer, pName varchar2 default null,
                  pState varchar2 default null, pSubmit varchar2 default null )
as
   cursor c0( cAcid integer, cName varchar2, cState varchar2 ) is
   select
      cp.username         username,
      cp.account_name     account_name,
      cp.profile_id       profile_id,
      cc.billing_name     billing_name,
      cc.billing_suburb   billing_suburb,
      cc.billing_state    billing_state,
      cc.billing_branch   billing_branch
   from
      customer_contact cc,
      customer_profile cp
   where
      ( ( cName is null )   or ( upper( billing_name ) like '%' || upper( cName ) || '%' ) ) and
      ( ( cState is null )  or ( upper( billing_state ) = upper( cState ) ) ) and
      cc.user_type in ( 'E', 'T' ) and
      cc.login_type = 'PROFILE' and
      cc.aid = cp.profile_id and
      cp.aid = cAcid
   order by
      billing_name;
   c0rec c0%ROWTYPE;

   lContinue 	BOOLEAN := TRUE;
   lCount 	integer := 0;
   def		school_booking_prefs%ROWTYPE;

begin
   /* Do some testing beforehand */
   /* if the name is empty return to the previous screen */
   if lContinue then lContinue := pName is not null;
   end if;
   /* if the state is empty return to the previous screen */
   if lContinue then lContinue := pState is not null;
   end if;
   /* if the submit button is empty return to the previous screen */
   if lContinue then lContinue := pSubmit is not null;
   end if;
   if NOT lContinue then
      login1( acid, pName, pState );
      return;
   end if;

   def := getDefaults( dapi.getPhotographerId, acid );

   /* Passed the tests */
   htp.p( '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">' );
   htp.htmlOpen;
   htp.headOpen;
   htp.title( 'Education' );
   htp.p( '<link rel="StyleSheet" href="' || BKN_STYLESHEET || '" type="text/css">' );
   htp.headClose;
   htp.bodyOpen;
   htp.p( '<script type="text/javascript" src="' || BKN_TOPSCRIPT || '"></script>' );
   htp.p( '<div class="bodytext">' );
   htp.comment( acid );
   htp.comment( pName );
   htp.comment( pState );
   htp.header( 2, 'Make a Booking' );
   htp.nl;
   htp.p( 'Please select your company or school:' );
   htp.nl;
   htp.nl;
   htp.tableOpen( cattributes=>'border="0" cellpadding="5" cellspacing="0"' );
   htp.tableRowOpen( cattributes=>'style="background-color: grey"' );
   htp.tableHeader( 'Company or school' );
   htp.tableHeader( 'Town' );
   htp.tableHeader( 'State' );
   htp.tableHeader( nvl(def.branch_title,'Campus') );
   htp.tableRowClose;

   for c0rec in c0( acid, pName, pState ) loop
      lCount := lCount + 1;
      htp.tableRowOpen;
      htp.tableData( htf.anchor( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'bkn.login3?acid=' ||
                                 acid ||
                                 '&pProfileId=' || c0rec.profile_id,
                                 c0rec.account_name ) );
      htp.tableData( c0rec.billing_suburb );
      htp.tableData( c0rec.billing_state );
      htp.tableData( c0rec.billing_branch );
      htp.tableRowClose;
   end loop;
   if lCount = 0 then
      htp.tableRowOpen;
      htp.tableData( 'Sorry, there is no school with this name in this state. Please try again.', ccolspan=>'3' );
      htp.tableRowClose;
   end if;
   htp.tableClose;
   htp.nl;
   htp.p( '<p>Not on the list? Contact our <a href="' || def.help_loc || '">bookings officer</a>.</p>' );
   htp.p( '</div>' );
   htp.p( '<script type="text/javascript" src="' || BKN_BOTTOMSCRIPT || '"></script>' );
   htp.bodyClose;
   htp.htmlClose;
end login2;

procedure login3( acid integer, pProfileId integer, errmsg in varchar2 default null )
as
   cursor c0(cProfileId integer) is
      select billing_name, billing_street, billing_suburb, billing_state, billing_postcode
      from customer_contact
      where aid = cProfileId;
   cursor c1(cProfileId integer) is select username from customer_profile where profile_id = cProfileId;

   c0rec c0%ROWTYPE;
   c1rec c1%ROWTYPE;

begin
   open c0( pProfileId );
   fetch c0 into c0rec;
   close c0;
   open c1( pProfileId );
   fetch c1 into c1rec;
   close c1;
   htp.p( '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">' );
   htp.htmlOpen;
   htp.headOpen;
   htp.title( 'Education' );
   htp.p( '<link rel="StyleSheet" href="' || BKN_STYLESHEET || '" type="text/css">' );
   htp.headClose;
   htp.bodyOpen;
   htp.p( '<script type="text/javascript" src="' || BKN_TOPSCRIPT || '"></script>' );
   htp.p( '<div class="bodytext">' );
   htp.comment( c1rec.username );
   if errmsg is not null then htp.header(1,errmsg,'CENTER'); end if;
   htp.header( 2, 'Make a Booking' );
   htp.p( '<p>You are from:</p>' );
   htp.p( '<p class="indent20"><span class="red">' );
   htp.p( c0rec.billing_name );
   htp.nl;
   htp.p( c0rec.billing_street );
   htp.nl;
   htp.p( c0rec.billing_suburb || ' ' || c0rec.billing_state || ' ' ||
          c0rec.billing_postcode );
   htp.p( '</span></p>' );
   htp.formOpen( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'bkn.login4' );
   htp.formHidden( 'acid', acid );
   htp.formHidden( 'pUsername', c1rec.username );
   htp.formHidden( 'pProfileId', pProfileId );
   htp.tableOpen( cattributes=>'border="0" cellpadding="2" cellspacing="0"' );
   htp.tableRowOpen;
   htp.tableData( 'Password:' );
   htp.tableData( htf.formPassword( 'pPassword' ) );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( '&nbsp;' );
   htp.tableData( htf.formImage( 'pSubmit', DECS.IMAGE_LOCATION || 'booking/continue.gif', cattributes=>'border="0"' ) );
   htp.tableRowClose;
   htp.tableClose;
   htp.formClose;
   if acid is not null
    then
     --htp.anchor( 'bkn.getPassword?pProfileId=' || pProfileId, 'Not sure what the password is?' );
     htp.bold(  'Not sure what the password is?' );
     htp.nl;
     htp.anchor( 'bkn.getPassword?pProfileId=' || pProfileId, 'Click here to have it emailed to you.' );
   end if;
   htp.p( '</div>' );
   htp.p( '<script type="text/javascript" src="' || BKN_BOTTOMSCRIPT || '"></script>' );
   htp.bodyClose;
   htp.htmlClose;
end login3;

procedure getPassword( pProfileId in integer )
is
 cursor c1(pProfileId integer) is select * from customer_contact where aid = pProfileId and login_type = 'PROFILE';

 CURSOR cu_find_password (profid integer) IS
      SELECT cp.profile_id, cp.account_name, cc.contact_email, a.pw, cp.username, cc.billing_name, cp.aid acid
      FROM   customer_profile cp, customer_contact cc, audit_profile_password a
      WHERE  cp.profile_id = a.profile_id(+)
      AND    cp.profile_id = cc.aid
      AND    cp.profile_id = profid;

 c1rec  		c1%ROWTYPE;
 cu_find_password_rec 	cu_find_password%ROWTYPE;
 ps_error_text		varchar2(1000);
 a_param		GLBX.MYARRAY;			 -- array of paramater names for sending email
 a_value		GLBX.MYARRAY;			 -- array of paramater values for sending email
 def		        school_booking_prefs%ROWTYPE;

begin
 open c1(pProfileId);
 fetch c1 into c1rec;
 close c1;
   htp.p( '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">' );
   htp.htmlOpen;
   htp.headOpen;
   htp.title( 'Education' );
   htp.p( '<link rel="StyleSheet" href="' || BKN_STYLESHEET || '" type="text/css">' );
   htp.headClose;
   htp.bodyOpen;
   htp.p( '<script type="text/javascript" src="' || BKN_TOPSCRIPT || '"></script>' );
   htp.p( '<div class="bodytext">' );
   htp.comment( c1rec.sendto_name );
   def := getDefaults( dapi.getPhotographerId, c1rec.aid );
   if c1rec.billing_email is null
    then
     htp.nl;
     htp.bold( 'No contact email was supplied for this account. Unable to send password.' );
     htp.nl;
     htp.p( '<p>Please contact our <a href="' || def.help_loc || '">bookings officer</a>.</p>' );

    else

      -- Check that the username they entered is on the system
      ps_error_text := NULL;
      OPEN cu_find_password(pProfileId);
      FETCH cu_find_password INTO cu_find_password_rec;
      IF cu_find_password%NOTFOUND THEN
        ps_error_text :='The username you entered cannot be found.' || '<p>Please contact our <a href="' || def.help_loc || '">bookings officer</a>.</p>';

      -- check that we know their password
      ELSIF cu_find_password_rec.pw IS NULL THEN
        ps_error_text := 'We have found your account but cannot retrieve your password.' || '<p>Please contact our <a href="' || def.help_loc || '">bookings officer</a>.</p>';

      END IF;
      CLOSE cu_find_password;

     if ps_error_text is null
      then
       a_param(1) := 'ACCOUNT_NAME';
       a_value(1) := 'Name     :  ' || cu_find_password_rec.account_name;
       a_param(2) := 'USERNAME';
       a_value(2) := cu_find_password_rec.username;
       a_param(3) := 'PASSWORD';
       a_value(3) := cu_find_password_rec.pw;
       a_param(4) := 'NAME';
       a_value(4) := cu_find_password_rec.billing_name;
       glbx.send( a_param,
                  a_value,
                 'booking_forgotten_password.tmp',
                  p_to=> c1rec.billing_email,
                  p_subj=>'Password',
                  p_from=>nvl(glbx.extract_master_parameter( 'BOOKING_MAIL_FROM' ),glbx.extract_master_parameter( 'MAIL_FROM' )), scode=>'BK2');

       htp.nl;
       htp.bold( 'Your password has been emailed to ' || c1rec.billing_email );
       htp.nl;
      else
       htp.nl;
       htp.bold( ps_error_text);
       htp.nl;
     end if;

   end if;
   htp.p( '</div>' );
   htp.p( '<script type="text/javascript" src="' || BKN_BOTTOMSCRIPT || '"></script>' );
   htp.bodyClose;
   htp.htmlClose;
end getPassword;

procedure login4( acid integer, pUsername varchar2 default null,
                  pPassword varchar2 default null, pProfileId integer,
                  pSubmit varchar2 default null )
as
   lContinue BOOLEAN := TRUE;
   lStatus varchar2( 100 );
   lSessionid login_session.sessid%TYPE;
   lScreenType login_session.screen_type%TYPE;
   lSecureUrl login_session.securl%TYPE;
begin
   /* Do some testing beforehand */
   /* if the name is empty return to the previous screen */
   if lContinue then
      lContinue := pUsername is not null;
   end if;
   /* if the password is empty return to the previous screen */
   if lContinue then
      lContinue := pPassword is not null;
   end if;
   /* if the submit button is empty return to the previous screen */
   if lContinue then
      lContinue := pSubmit is not null;
   end if;
   if NOT lContinue then
      bkn.login3( acid, pProfileId );
      return;
   end if;
   glbx.logon_user( un=>pUsername, pw=>pPassword, sts=>lStatus, session_id=>lSessionId,
                    stype=>lScreenType, surl=>lSecureUrl );
   if lstatus not in ('PHOTOGRAPHER','CUSTOMER','MANUFACTURER','PROFILE','PROFILEG','VIRTUAL') or
      lSecureUrl is null
    then
     login3( acid, pProfileId, lStatus );
     return;
   end if;

   enterBookingPage( lSecureUrl, acid, null );
end login4;

procedure login_connectas( surl varchar2, acid integer, profid integer )
as
   newsurl	varchar2(100) := NULL;
begin
   newsurl := loginAsProfile( surl, profid );
   enterBookingPage( newsurl, acid, null );
exception when others then
   glbx.error_details( 'LAB', 'LOGIN_CONNECTAS', acid , profid, errmsg=>sqlerrm );
end login_connectas;

procedure prebook( surl varchar2, acid integer default null, ispast in char default 'F', bknnmb in varchar2 default null )
as

   cursor c1(profid integer) is
    select *
    from booking
    where made_by = profid and
          trunc(date_time) >= trunc(sysdate) and
          status not in ('Pre Booking')
    order by date_time asc;

   cursor c1_tot(profid integer) is
    select count('x') tot
    from booking
    where made_by = profid and
          trunc(date_time) >= trunc(sysdate) and
          status not in ('Pre Booking');

   cursor c2(profid integer) is
    select *
    from booking
    where made_by = profid and
          trunc(date_time) <= trunc(sysdate) and
          status not in ('Pre Booking')
    order by date_time asc;

   cursor c2_tot(profid integer) is
    select count('x') tot
    from booking
    where made_by = profid and
          trunc(date_time) <= trunc(sysdate) and
          status not in ('Pre Booking');

   cursor c3(profid integer, bknnmb integer) is
    select *
    from booking
    where made_by = profid and
          booking_id = bknnmb and
          status not in ('Pre Booking');

   cursor c3_tot(profid integer, bknnmb integer) is
    select count('x') tot
    from booking
    where made_by = profid and
          booking_id = bknnmb and
          status not in ('Pre Booking');

   cursor c4(profid integer) is select username from customer_profile where profile_id = profid;

   c1rec 	booking%ROWTYPE;
   c4rec	c4%ROWTYPE;
   c4arec	c4%ROWTYPE;
   pfx          theme%ROWTYPE;
   lSessionId   integer;
   lAccountId   integer;
   tot		integer;
   booknmb	integer;

procedure bookrec( brec in booking%rowtype )
as

 cursor cp( bookid integer ) is
  select um.program_obj program_obj, bp.num_of_visitors num_of_visitors
  from umo um, booked_programs bp
  where um.umo_id = bp.program_id and
        bp.booking_id = bookid;

 cursor c2( profid integer ) is select * from customer_contact where login_type = 'PROFILE' and aid = profid;

 c2rec  c2%ROWTYPE;

begin
 htp.tablerowopen;
  htp.tabledata( htf.bold( brec.booking_id ), cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
  htp.tabledata( brec.status, cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
  htp.tabledata( replace(to_char( brec.date_time, LNG.TSMASK ),' ',htf.nl), cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
  if brec.made_by = brec.school_id and brec.bus_company_id is not null
   then
    open c4( brec.bus_company_id );
    fetch c4 into c4rec;
    close c4;
  elsif brec.made_by = brec.bus_company_id and brec.school_id is not null
   then
    open c4( brec.school_id );
    fetch c4 into c4rec;
    close c4;
  elsif brec.bus_company_id is null
   then
    open c4( brec.school_id );
    fetch c4 into c4rec;
    close c4;
  else
    open c4( brec.bus_company_id );
    fetch c4 into c4rec;
    close c4;
  end if;
  htp.tabledata( replace(c4rec.username,';',htf.nl), cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
  htp.tabledata( nvl(to_char(brec.num_of_students),'?') || ' / ' || nvl(to_char(brec.num_of_adults),'?'), cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );

  if brec.contact_person  is not null
   then
    htp.tabledata( brec.contact_person || htf.nl || brec.contact_email, cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );

  elsif brec.bus_company_id is not null and brec.school_id is not null
   then
    open c2( brec.school_id );
    fetch c2 into c2rec;
    close c2;
    htp.tabledata( c2rec.billing_name || htf.nl || c2rec.billing_email, cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );

  else
    if brec.contact_person is null
     then
      open c2( brec.school_id );
      fetch c2 into c2rec;
      close c2;
      htp.tabledata( c2rec.billing_name || htf.nl || c2rec.billing_email, cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
     else
      htp.tabledata( brec.contact_person || htf.nl || brec.contact_email, cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
    end if;
  end if;

  htp.tabledata( nvl(brec.reception_note,'&nbsp;'), cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
  htp.p( '<TD ' || pfx.qcbground || ' ALIGN="LEFT">' );
  if brec.visit_type = '2'
   then
    htp.p( 'Self Guided' );
   else
    for cprogrec in cp( brec.booking_id ) loop
     htp.p( cprogrec.program_obj.program_name || ' ' || '(' || cprogrec.num_of_visitors || ')' );
     htp.nl;
    end loop;
    htp.p( '&nbsp;' );
  end if;
  htp.p( '</TD>' );
 htp.tablerowclose;
end bookrec;

begin
   if not dapi.init( surl, 'BKN.PREBOOK', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;
   lSessionId := dapi.getSessionid;
   lAccountId := dapi.getAccountId;
   pfx := dapi.getLFRecord;
   open c4( lAccountId );
   fetch c4 into c4arec;
   close c4;
   htp.header(3, replace(c4arec.username,';',','), 'CENTER' );

   begin booknmb := to_number( bknnmb ); exception when others then booknmb := NULL; end;
   if booknmb is not null
    then
     htp.header( 2, 'Individual Booking' || ':' || booknmb, 'CENTER' );
     open c3_tot( lAccountId, booknmb );
     fetch c3_tot into tot;
     close c3_tot;
   elsif ispast = 'T'
    then
     htp.header( 2, 'Past Bookings', 'CENTER' );
     open c2_tot( lAccountId );
     fetch c2_tot into tot;
     close c2_tot;
   else
     htp.header( 2, 'Future Bookings', 'CENTER' );
     open c1_tot( lAccountId );
     fetch c1_tot into tot;
     close c1_tot;
   end if;

   htp.tableopen( cattributes=>'width="100%" cellpadding=0 cellspacing=0 border=0' );
   htp.tablerowopen;
   if ispast = 'T'
    then
     htp.tabledata( htf.anchor( 'bkn.prebook?surl=' || surl || '&acid=' || acid || '&ispast=F', 'Future Bookings' ), cattributes=>'align="LEFT"');
    else
     htp.tabledata( htf.anchor( 'bkn.prebook?surl=' || surl || '&acid=' || acid || '&ispast=T', 'Past Bookings' ), cattributes=>'align="LEFT"');
   end if;
   htp.p( '<TD align="RIGHT">' );
   htp.formopen( 'bkn.prebook' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'ACID', acid );
   htp.formhidden( 'ISPAST', ispast );
   htp.formtext( 'BKNNMB', 10, 20 );
   htp.formsubmit( null, 'Booking Number' );
   htp.formclose;
   htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tableclose;

   if tot = 0
    then
     htp.nl;
     htp.header( 2, 'No Results Found' );

    else
     htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
      htp.tablerowopen;
       htp.tabledata( htf.bold( 'Booking Number' ),cattributes=>pfx.qbground || ' ALIGN="CENTER"' );
       htp.tabledata( htf.bold( 'Status' ),cattributes=>pfx.qbground || ' ALIGN="CENTER"' );
       htp.tabledata( htf.bold( 'Date of Visit' ),cattributes=>pfx.qbground || ' ALIGN="CENTER"' );
       if c1rec.made_by = c1rec.school_id and c1rec.bus_company_id is not null
        then
           htp.tabledata( htf.bold( 'Bus Company' ),cattributes=>pfx.qbground || ' ALIGN="CENTER"' );
        elsif c1rec.made_by = c1rec.bus_company_id and c1rec.school_id is not null
         then
           htp.tabledata( htf.bold( 'School' ),cattributes=>pfx.qbground || ' ALIGN="CENTER"' );
        elsif c1rec.bus_company_id is null
         then
           htp.tabledata( htf.bold( 'School' ),cattributes=>pfx.qbground || ' ALIGN="CENTER"' );
        else
           htp.tabledata( htf.bold( 'Bus Company' ),cattributes=>pfx.qbground || ' ALIGN="CENTER"' );
       end if;
       htp.tabledata( htf.bold( 'Students / Adults' ),cattributes=>pfx.qbground || ' ALIGN="CENTER"' );
       htp.tabledata( htf.bold( 'Teacher<BR>Details' ),cattributes=>pfx.qbground || ' ALIGN="CENTER"' );
       htp.tabledata( htf.bold( 'Comments' ),cattributes=>pfx.qbground || ' ALIGN="CENTER"' );
       htp.tabledata( htf.bold( 'Visit Details' ),cattributes=>pfx.qbground || ' ALIGN="CENTER"' );
      htp.tablerowclose;
       if booknmb is not null
        then
         for c3rec in c3( lAccountId, booknmb ) loop
          bookrec( c3rec );
         end loop;
       elsif ispast = 'T'
        then
         for c2rec in c2( lAccountId ) loop
          bookrec( c2rec );
         end loop;
       else
         for c1rec in c1( lAccountId ) loop
          bookrec( c1rec );
         end loop;
       end if;
     htp.tableclose;
   end if;
   htp.nl;
   /*
   htp.line;
   htp.nl;
   htp.bold( 'Search' );
   htp.formopen( 'bkn.prebook' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'ACID', acid );
    htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
     htp.tablerowopen;
      htp.tabledata( 'Past Bookings' );
      htp.tabledata( htf.formcheckbox( 'ISPAST', 'T' ) );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( 'Booking Number' );
      htp.tabledata( htf.formtext( 'BKNNMB', 20, 20 ) );
     htp.tablerowclose;
    htp.tableclose;
    htp.nl;
    htp.formsubmit( null, 'Search' );
    htp.formclose;
   */
   dapi.pageClose;

exception when others then
  glbx.error_details( 'BKN', 'PREBOOK', errmsg=>sqlerrm);
end prebook;

function  visithelp( surl in varchar2, acid in integer, anch in varchar2, visit_id in integer )
 return varchar2
as
 -- htp.p( 'Select the ' || visithelp );
  cursor c1( cacid integer) is
      select * from school_booking_prefs
      where std_profile_aid = cacid and
            std_profile_pid = ( select pid
                                from customer_account
                                where aid = cacid );
  c1rec  c1%ROWTYPE;
begin
 open c1(acid);
 fetch c1 into c1rec;
 if c1%FOUND
  then
   close c1;
   if c1rec.visithelp_loc is null
    then
     return('<A HREF="javascript: window.open(''bkn.bookhelp?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || ''',''bookhelp'',''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=700,height=500'');void('''');">' || anch || '</A>' );
    else
     -- Because James said so, but when he wants it back again:  || '.html'
     return('<A HREF="javascript: window.open(''' || c1rec.visithelp_loc || ''',''bookhelp'',''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=700,height=500'');void('''');">' || anch || '</A>' );
   end if;
  else
   close c1;
   return('<A HREF="javascript: window.open(''bkn.bookhelp?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || ''',''bookhelp'',''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=700,height=500'');void('''');">' || anch || '</A>' );
 end if;
end visithelp;

procedure bookhelp( surl in varchar2, acid in integer )
as
   def		      school_booking_prefs%ROWTYPE;
begin
   if not dapi.init( surl, 'BKN.BOOKHELP', acid, iscust=>FALSE ) then
      dapi.initFailed( surl,extra_parameter=>'BOOKING' );
      return;
   end if;

   def := getDefaults( dapi.getPhotographerId, acid );
htp.p(
'<body lang=EN-US style=''tab-interval:36.0pt''>

<div class=Section1>

<p class=MsoNormal style=''line-height:150%''><span style=''font-size:14.0pt;
mso-bidi-font-size:10.0pt;line-height:150%;font-family:"Book Antiqua";
color:black''>FACILITATED PROGRAMS<o:p></o:p></span></p>

<p class=MsoNormal style=''line-height:150%''><span style=''font-size:14.0pt;
mso-bidi-font-size:10.0pt;line-height:150%;font-family:"Book Antiqua";
color:black''><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style=''line-height:150%''><span style=''font-size:14.0pt;
mso-bidi-font-size:10.0pt;line-height:150%;font-family:"Book Antiqua";
color:black''>Facilitated programs give your students a focussed education
experience presented in the Memorial¿s galleries by education staff. <o:p></o:p></span></p>

<p class=MsoNormal style=''margin-left:18.0pt;text-indent:-18.0pt;line-height:
150%;mso-list:l0 level1 lfo1;tab-stops:list 18.0pt''><![if !supportLists]><span
style=''font-size:12.0pt;mso-bidi-font-size:10.0pt;line-height:150%;font-family:
Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol''><span
style=''mso-list:Ignore''>·<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]><span style=''font-size:12.0pt;mso-bidi-font-size:
10.0pt;line-height:150%;font-family:"Book Antiqua"''>Curriculum-linked programs
for primary and secondary students relate to History, English, the Arts, Science
and Technology. <o:p></o:p></span></p>

<p class=MsoNormal style=''margin-left:18.0pt;text-indent:-18.0pt;line-height:
150%;mso-list:l0 level1 lfo1;tab-stops:list 18.0pt''><![if !supportLists]><span
style=''font-size:12.0pt;mso-bidi-font-size:10.0pt;line-height:150%;font-family:
Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol''><span
style=''mso-list:Ignore''>·<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]><span style=''font-size:12.0pt;mso-bidi-font-size:
10.0pt;line-height:150%;font-family:"Book Antiqua"''>Programs are preceded by an
orientation to the ' || def.home_title || '. Allow an extra 15 minutes.<o:p></o:p></span></p>

<p class=MsoNormal style=''margin-left:18.0pt;text-indent:-18.0pt;line-height:
150%;mso-list:l0 level1 lfo1;tab-stops:list 18.0pt''><![if !supportLists]><span
style=''font-size:12.0pt;mso-bidi-font-size:10.0pt;line-height:150%;font-family:
Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol''><span
style=''mso-list:Ignore''>·<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]><span style=''font-size:12.0pt;mso-bidi-font-size:
10.0pt;line-height:150%;font-family:"Book Antiqua";color:black''>Many programs
use hands-on items and draw on real objects and fascinating stories.</span><span
style=''font-size:12.0pt;mso-bidi-font-size:10.0pt;line-height:150%;font-family:
"Book Antiqua"''><o:p></o:p></span></p>

<p class=MsoNormal style=''margin-left:18.0pt;text-indent:-18.0pt;line-height:
150%;mso-list:l0 level1 lfo1;tab-stops:list 18.0pt''><![if !supportLists]><span
style=''font-size:12.0pt;mso-bidi-font-size:10.0pt;line-height:150%;font-family:
Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol''><span
style=''mso-list:Ignore''>·<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]><span style=''font-size:12.0pt;mso-bidi-font-size:
10.0pt;line-height:150%;font-family:"Book Antiqua"''>Groups are limited to 15
students<o:p></o:p></span></p>

<p class=MsoNormal style=''margin-left:18.0pt;text-indent:-18.0pt;line-height:
150%;mso-list:l0 level1 lfo1;tab-stops:list 18.0pt''><![if !supportLists]><span
style=''font-size:12.0pt;mso-bidi-font-size:10.0pt;line-height:150%;font-family:
Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol''><span
style=''mso-list:Ignore''>·<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]><span style=''font-size:12.0pt;mso-bidi-font-size:
10.0pt;line-height:150%;font-family:"Book Antiqua"''>All programs are $3.30
(including GST) per student. Supervising adults are free of charge. <o:p></o:p></span></p>

<p class=MsoNormal style=''margin-left:18.0pt;text-indent:-18.0pt;line-height:
150%;mso-list:l0 level1 lfo1;tab-stops:list 18.0pt''><![if !supportLists]><span
style=''font-size:12.0pt;mso-bidi-font-size:10.0pt;line-height:150%;font-family:
Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol''><span
style=''mso-list:Ignore''>·<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]><span style=''font-size:12.0pt;mso-bidi-font-size:
10.0pt;line-height:150%;font-family:"Book Antiqua"''>Bookings are available from
9.00am to 4.00pm every day<o:p></o:p></span></p>

<h4 style=''line-height:150%''><span style=''font-size:14.0pt;mso-bidi-font-size:
10.0pt;line-height:150%;font-family:"Book Antiqua";color:black;font-style:normal''><o:p>&nbsp;</o:p></span></h4>

<h4 style=''line-height:150%''><span style=''font-size:14.0pt;mso-bidi-font-size:
10.0pt;line-height:150%;font-family:"Book Antiqua";color:black;font-style:normal''>SELF-GUIDED
VISITS<o:p></o:p></span></h4>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<p class=MsoBodyText2><span style=''font-weight:normal''>These visits allow
teachers to direct the learning experience of their students.<span
style=''mso-spacerun:yes''>  </span><o:p></o:p></span></p>

<p class=MsoNormal style=''margin-left:18.0pt;text-indent:-18.0pt;line-height:
150%;mso-list:l0 level1 lfo1;tab-stops:list 18.0pt''><![if !supportLists]><span
style=''font-size:12.0pt;mso-bidi-font-size:10.0pt;line-height:150%;font-family:
Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol''><span
style=''mso-list:Ignore''>·<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]><span style=''font-size:12.0pt;mso-bidi-font-size:
10.0pt;line-height:150%;font-family:"Book Antiqua"''>All groups are given an
orientation to the ' || def.home_title || ' on arrival. <o:p></o:p></span></p>

<p class=MsoNormal style=''margin-left:18.0pt;text-indent:-18.0pt;line-height:
150%;mso-list:l0 level1 lfo1;tab-stops:list 18.0pt''><![if !supportLists]><span
style=''font-size:12.0pt;mso-bidi-font-size:10.0pt;line-height:150%;font-family:
Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol''><span
style=''mso-list:Ignore''>·<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]><span style=''font-size:12.0pt;mso-bidi-font-size:
10.0pt;line-height:150%;font-family:"Book Antiqua"''>Bookings available 10.00 am
to 4.00 pm daily, extended to 9.00 am to 4.00 pm during the NSW and ACT school
holidays. <o:p></o:p></span></p>

<p class=MsoNormal style=''margin-left:18.0pt;text-indent:-18.0pt;line-height:
150%;mso-list:l0 level1 lfo1;tab-stops:list 18.0pt''><![if !supportLists]><span
style=''font-size:12.0pt;mso-bidi-font-size:10.0pt;line-height:150%;font-family:
Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol''><span
style=''mso-list:Ignore''>·<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]><span style=''font-size:12.0pt;mso-bidi-font-size:
10.0pt;line-height:150%;font-family:"Book Antiqua"''>Teachers are asked to keep
their group together and stay with students throughout their visit.<o:p></o:p></span></p>

<p class=MsoNormal style=''margin-left:18.0pt;text-indent:-18.0pt;line-height:
150%;mso-list:l0 level1 lfo1;tab-stops:list 18.0pt''><![if !supportLists]><span
style=''font-size:12.0pt;mso-bidi-font-size:10.0pt;line-height:150%;font-family:
Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol''><span
style=''mso-list:Ignore''>·<span style=''font:7.0pt "Times New Roman"''>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span></span><![endif]><span style=''font-size:12.0pt;mso-bidi-font-size:
10.0pt;line-height:150%;font-family:"Book Antiqua"''>Allow at least 2 hours for
your visit.<o:p></o:p></span></p>

<p class=MsoNormal><span style=''font-size:12.0pt;mso-bidi-font-size:10.0pt''><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><b style=''mso-bidi-font-weight:normal''><span
style=''font-size:12.0pt;mso-bidi-font-size:10.0pt''><o:p>&nbsp;</o:p></span></b></p>

</div>

</body>'
);

exception when others then
  glbx.error_details( 'BKN', 'HELP', errmsg=>sqlerrm);
end bookhelp;

function booking_school_year( aussie_state in varchar2, year_level in varchar2, students in integer, is_primary in char default 'F', is_school in char default 'F' )
 return number
as
 x 	number;
 lw	integer;
 hg	integer;
 lwo	boolean;
 hgo	boolean;
begin

 lwo := FALSE;
 hgo := FALSE;
 -- Assume year level is in format m-n
 x := instr(year_level,'-');
 begin
  lw := substr(year_level,1,x-1);
 exception
  when others then
   if upper(substr(year_level,x-1,1)) = 'K' then lw := 0; end if;
   if upper(substr(year_level,x-1,1)) = 'O' then lwo := TRUE; end if;
 end;

 begin
  hg := substr(year_level,x+1);
 exception
  when others then
   if upper(substr(year_level,x+1)) = 'O' then hgo := TRUE; end if;
   hg := null;
 end;

 if lwo and hgo and is_primary = 'O' then return( students ); end if;

 if lw is null and hg is not null then lw := hg;
 elsif lw is not null and hg is null then hg := lw;   -- if lower is not null and higher is null, make higher equal to lowe
 elsif lw is null and hg is null then return( 0 ); -- return if both are null
 elsif lw > hg then x := hg; hg := lw; lw := x;       -- If one value is bigger than the other, swap them around
 end if;

 -- Adjust for the different states
 if upper(aussie_state) in ('SA','QLD','NT','WA')
  then
   lw := lw - 1;
   hg := hg - 1;
 end if;

 if (lwo and hg <= 6) or (hgo and lw <= 6) --Other and Primary
  then
   if is_primary = 'T' then return( round(students/2) ); end if;
   if is_primary = 'O' then return( round(students/2) ); end if;
   return( 0 );
 elsif lwo or hgo -- Other and Secondary
  then
   if is_primary = 'F' then return( round(students/2) ); end if;
   if is_primary = 'O' then return( round(students/2) ); end if;
   return( 0 );
 end if;

 if lw <= 6 and hg <= 6
  then
   if is_primary = 'T' then return( students ); else return( 0 ); end if;
 elsif lw > 6 and hg > 6 then
   if is_primary = 'F' then return( students ); else return( 0 ); end if;
 else
   if is_school = 'T'
    then
     if is_primary = 'T' then return( ((7-lw) / (1+hg-lw)) * students ); else return( ((hg-6) / (1+hg-lw)) * students ); end if;
    else
     if is_primary = 'T' then return( round(((7-lw) / (1+hg-lw)) * students ) ); else return( round(((hg-6) / (1+hg-lw)) * students ) ); end if;
   end if;
 end if;

 /*
 select booking_school_year(c.billing_state,school_year,sum(num_of_students),'T')
 from booking b, customer_contact c
 where b.school_id = c.aid
 group by billing_state,school_year
*/

end booking_school_year;

end bkn;

/
