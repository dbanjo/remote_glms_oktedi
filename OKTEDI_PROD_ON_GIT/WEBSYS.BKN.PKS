CREATE OR REPLACE package WEBSYS.bkn
as

/******************************************************************************
* Program public constants
******************************************************************************/
BKN_STYLESHEET    constant varchar2( 200 ) := 'http://www.awm.gov.au/style/style.css';
BKN_TOPSCRIPT     constant varchar2( 200 ) := 'http://www.awm.gov.au/scripts/top.js';
BKN_BOTTOMSCRIPT  constant varchar2( 200 ) := 'http://www.awm.gov.au/scripts/bottom.js';
--BKN_STYLESHEET    constant varchar2( 200 ) := 'http://155.187.10.31:3339/images/booking/style.css';
--BKN_TOPSCRIPT     constant varchar2( 200 ) := 'http://155.187.10.31:3339/images/booking/top.js';
--BKN_BOTTOMSCRIPT  constant varchar2( 200 ) := 'http://155.187.10.31:3339/images/booking/bottom.js';
--BKN_STYLESHEET    constant varchar2( 200 ) := 'http://mars/images/booking/style.css';
--BKN_TOPSCRIPT     constant varchar2( 200 ) := 'http://mars/images/booking/top.js';
--BKN_BOTTOMSCRIPT  constant varchar2( 200 ) := 'http://mars/images/booking/bottom.js';
/******************************************************************************
* Text constants
******************************************************************************/
-- System wide constants
BKN_TXT_000_001 constant varchar2(200)    :=  'Book a facilitated program';
BKN_TXT_000_002 constant varchar2(200)    :=  'Book a self guided tour';
BKN_TXT_000_003 constant varchar2(200)    :=  'This booking is no longer active!';
BKN_TXT_000_004 constant varchar2(200)    :=  'There seem to be no calendar defined for this customer';
BKN_TXT_000_005 constant varchar2(200)    :=  'Your booking has been deleted, inform your administrator of this error before trying again';

-- Screen BKN001
BKN_TXT_001_001 constant varchar2(200)    :=  '<p>Number of students:';
BKN_TXT_001_002 constant varchar2(200)    :=  '<p>Select the <a href="#">type of visit</a>:';
BKN_TXT_001_003 constant varchar2(200)    :=  '<p>When would you like to visit?';

BKN_TXT_001_993 constant varchar2(200)    :=  'The date is in the past';
BKN_TXT_001_994 constant varchar2(200)    :=  'Invalid time given, choose a later time';
BKN_TXT_001_995 constant varchar2(200)    :=  'Invalid time given, choose an earlier time';
BKN_TXT_001_996 constant varchar2(200)    :=  'The date is invalid for this visit type';
BKN_TXT_001_997 constant varchar2(200)    :=  'There is no calendar active for the chosen date';
BKN_TXT_001_998 constant varchar2(200)    :=  'Please specify number of students';
BKN_TXT_001_999 constant varchar2(200)    :=  'Please use numeric characters';

-- Screen BKN002
BKN_TXT_002_001 constant varchar2(200)    :=  '<p>Select your arrival time:</p>';
BKN_TXT_002_002 constant varchar2(200)    :=  'Time available';
BKN_TXT_002_003 constant varchar2(200)    :=  'Time negotiable';
BKN_TXT_002_004 constant varchar2(200)    :=  'Time booked';
BKN_TXT_002_005 constant varchar2(200)    :=  '[Previous Day]';
BKN_TXT_002_006 constant varchar2(200)    :=  '[Next Day]';

-- Screen BKN003
BKN_TXT_003_001 constant varchar2(200)    :=  'Enter visit details';
BKN_TXT_003_002 constant varchar2(200)    :=  'School';
BKN_TXT_003_003 constant varchar2(200)    :=  'Visit details';
BKN_TXT_003_004 constant varchar2(200)    :=  'Date';
BKN_TXT_003_005 constant varchar2(200)    :=  'Time';
BKN_TXT_003_006 constant varchar2(200)    :=  'Year level';
BKN_TXT_003_007 constant varchar2(200)    :=  'Teacher details';
BKN_TXT_003_008 constant varchar2(200)    :=  'Name';
BKN_TXT_003_009 constant varchar2(200)    :=  'E-mail address';
BKN_TXT_003_010 constant varchar2(200)    :=  'Any comments or special needs?';
BKN_TXT_003_011 constant varchar2(200)    :=  'To';
BKN_TXT_003_012 constant varchar2(200)    :=  'Click to select a school';

BKN_TXT_003_997 constant varchar2(200)    :=  'Please select a school';
BKN_TXT_003_998 constant varchar2(200)    :=  'Please select a year level from';
BKN_TXT_003_999 constant varchar2(200)    :=  'Please specify teacher e-mail';

-- Screen BKN004
BKN_TXT_004_001 constant varchar2(200)    :=  'Choose your program(s)';
BKN_TXT_004_002 constant varchar2(200)    :=  'Allocate your <NUMBER_OF_STUDENTS> to one or more programs';
BKN_TXT_004_003 constant varchar2(200)    :=  'Number of students';
BKN_TXT_004_004 constant varchar2(200)    :=  'Program';
BKN_TXT_004_005 constant varchar2(200)    :=  'Year level';
BKN_TXT_004_006 constant varchar2(200)    :=  'More info';

BKN_TXT_004_997 constant varchar2(200)    :=  'Please nominate a program for each of your students';
BKN_TXT_004_998 constant varchar2(200)    :=  '';
BKN_TXT_004_999 constant varchar2(200)    :=  '';
/**
* ========================================================================<br/>
* Project:         School Booking System<br/>
* Description:     The school booking system gives the ability to book a<br/>
*                  visit online.<br/>
* ========================================================================<br/>
* @headcom
*/

function booking_school_year( aussie_state in varchar2, year_level in varchar2, students in integer, is_primary in char default 'F', is_school in char default 'F' ) return number;
/**
* Retrieves  a record with booking defaults.
* @param pManufacturerId           Manufacturer ID
* @return               Defaults record
*/
function getDefaults( acid integer ) return school_booking_prefs%ROWTYPE;

/**
* enterBookingApi is used to start the booking sequence.
* @param surl Secure url
* @param screen_parms Paramaters to be formwarded
*/
procedure enterBookingApi( surl varchar2, acid integer default null );

/**
* Takes you to the booking system. It can also be started from bkn.accept_type_of_visit.
* @param surl Secure URL
* @param acid Account ID when logged in as a photographer or manufacturer.
* @param left_api_parm Extra parameter.
*/
procedure enterBookingPage( surl varchar2, acid integer default null,
                            left_api_parm varchar2 default null );

/**
* The user can select the type of visit he or she want to make a reservation for.
* @param surl Secure URL
* @param acid Account ID when loggin in as a photographer or manufacturer.
* @param left_api_parm Extra parameter.
*/
procedure typeOfVisit( surl varchar2, acid integer default null,
                       left_api_parm varchar2 default null );

/**
* The user has selected a type of visit to make a booking for
* @param surl Secure URL
* @param acid Account ID when loggen in as a photographer or manufacturer
* @param p_visit_type Type of visit chosen by the user
* @param left_api_parm Extra parameter
*/
procedure acceptTypeOfVisit( surl varchar2, acid integer default null,
                             p_visit_type varchar2 default null,
                             left_api_parm varchar2 default null );

/**
* Step 1: The user has to specify the number of students and select a preferred
* date for the visit.
* @param surl Secure URL
* @param acid Account ID
* @param hour the hour of the preferred visit
* @param minutes the minutes of the preferred visit
* @param nov Number of students
* @param date_to_start Date of the visit
* @param chosen_date Chosen date in the screen
* @param org_tour Is it an organised tour
* @param err_text Error message
*/
procedure details( surl varchar2, acid integer default null, hour varchar2 default null,
                   minutes varchar2 default null, nov varchar2 default null,
                   date_to_start varchar2 default null, chosen_date varchar2 default null,
                   org_tour varchar2 default null, err_text varchar2 default null );

/**
* Accept the user entries of the former screen
* @param surl Secure URL
* @param acid Account ID
* @param pVisitDate Date of the visit
* @param pHour Hour of the visit
* @param pMinute Minute of the visit
* @param pMeridian PM or AM
* @param pGroupSize Number of students
* @param pOrganisedTour If it is an organised tour DEPRICATED
* @param pPreviousMonth User clicked previous month button
* @param pNextMonth User clicked next month button
* @param pCancel User clicks cancel button
* @param pPreviousStep User clicked on back button
* @param pNextStep User clicked next step
* @param pSelectMonth User selected a new month
* @param pCommand Command field
*/
procedure accept_details( surl varchar2, acid integer default null, pVisitDate varchar2,
                          pHour varchar2, pMinute varchar2, pMeridian varchar2,
                          pGroupSize varchar2, pOrganisedTour varchar2 default null,
                          pPreviousMonth varchar2 default null, pNextMonth varchar2 default null,
                          pCancel varchar2 default null, pPreviousStep varchar2 default null,
                          pNextStep varchar2 default null, pSelectMonth varchar2 default null,
                          pCommand varchar2 default null,
                          pTypeOfVisit varchar2 default null );

/**
* Step 2: Show calendar lists all the times that are available for the user.
* @param surl Secure URL
* @param acid Account ID
* @param proposed_date Proposed date
*/
procedure show_calendar( surl varchar2, acid integer, proposed_date varchar2 default null, errmsg in varchar2 default null );

/**
* Lists the times
* @param surl Secure URL
* @param acid Account ID
* @param proposed_date Proposed date
* @param inFrame Is the page shown inside a frame?
*/
procedure sub_show_calendar( sUrl varchar2, acid integer, proposed_date varchar2 default null,
                             inFrame varchar2 );

/**
* User has selected a time.
* @param surl Secure URL
* @param acid Account ID
* @param new_date_time Chosen date and time
* @param pContactEdOfficer User clicked on contact education officer button
* @param pCancel User clicked on the cancel button
* @param pBack User clicked back button
* @param action User clicked on something
*/
procedure accept_calendar( surl varchar2, acid integer default null, new_date_time varchar2,
                           pContactEdOfficer varchar2 default null, pCancel varchar2 default null,
                           pBack varchar2 default null, action varchar2 default null );

/**
* Navigate through the days in the select time screen
* @param surl Secure URL
* @param acid Account ID
* @param proposed_date Proposed date
* @param pPreviousDay User clicked on previous day button
* @param pNextDay User clicked on next day button
*/
procedure navigate_calendar( surl varchar2, acid integer, proposed_date varchar2,
                             pPreviousDay varchar2 default null, pNextDay varchar2 default null );

/**
* When the user wants to contact the education officer this screen will appear.
* @param surl Secure URL
* @param acid Account ID
* @param rurl Return URL
*/
procedure contact_awm_staff( surl varchar2, acid integer default null, rurl varchar2 default null );

/**
* The form to contact the education officer is being submitted.
* @param surl Secure URL
* @param acid Account ID
* @param p_name School or company name
* @param p_date Date of visit
* @param p_hour Hour of visit
* @param p_minute Minut of visit
* @param p_meridian PM or AM
* @param p_groupsize Number of students
* @param p_details Text with details
* @param p_phone Phone number for contact
* @param pCancel User clicked cancel button
* @param pSend User clicked Send button
* @param rurl return url
*/
procedure accept_contact_awm( surl varchar2, acid integer default null, p_name varchar2,
                              p_date varchar2, p_hour varchar2, p_minute varchar2,
                              p_meridian varchar2, p_groupsize varchar2, p_details varchar2,
                              p_phone varchar2, pCancel varchar2 default null,
                              pSend varchar2 default null, rurl varchar2 default null );

/**
* Step 3: User has to enter details of the visit
* @param surl Secure URL
* @param acid Account ID
* @param errText Error message to display on the screen
* @param pContactName Name of the contact person
* @param pContactEmail Email of the contact person
* @param pYearFrom Chosen year level from
* @param pYearTo Chosen year level to
* @param pNumberOfAdults Number of adults
*/
procedure school_details( surl varchar2, acid integer default null,
                          errText in varchar2 default null, pContactName varchar2 default null,
                          pContactEmail varchar2 default null, pYearFrom varchar2 default null,
                          pYearTo varchar2 default null, pNumberOfAdults varchar2 default null );

/**
* Accept the entries of the details screen
* @param surl Secure URL
* @param acid Account ID
* @param P_contact_person Name of the contact person
* @param P_contact_phone Phone number of the contact person
* @param P_contact_fax Fax number of the contact person
* @param P_contact_email Email address of the contact person
* @param P_school_year_from Year level from
* @param P_school_year_to Year level to
* @param P_num_of_adults Number of adults
* @param P_requirements Extra details
* @param pPreviousStep User clicked previous step button
* @param pCancel User clicked cancel button
* @param pNextStep User clicked next step button
* @param pSelectSchool User is selecting a school from a list
*/
procedure accept_school_details( surl varchar2, acid integer default null,
                                 P_contact_person varchar2, P_contact_phone varchar2,
                                 P_contact_fax varchar2, P_contact_email varchar2,
                                 P_school_year_from varchar2, P_school_year_to varchar2,
                                 P_num_of_adults varchar2, P_requirements varchar2,
                                 pPreviousStep varchar2 default null,
                                 pCancel varchar2 default null,
                                 pNextStep varchar2 default null,
                                 pSelectSchool varchar2 default null );

/**
* Step 4: User has to select programs and allocate number of students per program.
* @param surl Secure URL
* @param acid Account ID
* @param pErrorText Optional error message
*/
procedure program_details( surl varchar2, acid integer default null,
                           pErrorText varchar2 default null );
/**
* Process the program details
* @param surl Secure URL
* @param acid Account ID
* @param p1 Array with number of students
* @param p2 Array with program id's
* @param p3 Checked workbooks
* @param p4 Array with workbook id's
* @param pPreviousStep User clicked on previous step button
* @param pCancel User clicked on cancel button
* @param pNextStep User clicked on next button
*/
procedure accept_program_details( surl varchar2, acid integer default null,
                                  p1 glbx.myArray, p2 glbx.myArray, p3 glbx.myArray,
                                  p4 glbx.myArray, pPreviousStep varchar2 default null,
                                  pCancel varchar2 default null, pNextStep varchar2 default null );

/**
* Step 5: User selects who is to pay for the visit
* @param surl Secure URL
* @param acid Account ID
* @param errText Optional error message
*/

procedure payment_details( surl varchar2, acid integer default null, errText varchar2 default null );
/**
* Accept the details about the payment.
* @param surl Secure URL
* @param acid Account ID
* @param creditor The profile ID of the person who is to pay (school or company)
* @param payment
* @param totalAmount total amount to be paid
* @param pPreviousStep User clicked on back button
* @param pCancel User clicked on cancel button
* @param pNextStep User clicked next button
*/

procedure accept_payment_details( surl varchar2, acid integer default null,
                                  creditor char default null, payment varchar2 default null,
                                  totalAmount varchar2 default null,
                                  pPreviousStep varchar2 default null,
                                  pCancel varchar2 default null, pNextStep varchar2 default null );

/**
* Step 6: All the information is shown to the user, user has to accept to make a reservation
* @param surl Secure URL
* @param acid Account ID
*/
procedure check_details( surl varchar2, acid integer default null );

/**
* Process the check details screen.
* @param surl Secure URL
* @param acid Account ID
* @param pPreviousStep User clicked on back button
* @param pCancel User clicked on the cancel button
* @param pConfirm User clicked on the confirm button
* @param pContactEdOfficer User clicked on contact education officer button
*/
procedure accept_check_details( surl varchar2, acid integer default null,
                                pPreviousStep varchar2 default null,
                                pCancel varchar2 default null,
                                pConfirm varchar2 default null,
                                pContactEdOfficer varchar2 default null );

/**
* Last page of the booking sequence.
* @param surl Secure URL
* @param acid Account ID
* @param bid Booking ID
* @param email_sendto Email address where the confirmation email has been sent to
*/
procedure end_page( surl varchar2, acid integer default null, bid varchar2, email_sendto varchar2 default null );

/**
* Check if the booking is not active
* @param surl Secure URL
* @param acid Account ID
*/
procedure bookingNotActive( surl varchar2, acid integer default null );

/**
* Cancel the current booking.
* @param surl Secure URL
* @param acid Account ID
* @param action Result of a submit button
*/
procedure cancelBooking( surl varchar2, acid integer default null, action varchar2 default null );

/**
* After presenting a list to the user the user selects a school or buscompany from the list.
* @param surl Secure URL
* @param bid Booking ID
* @param acid Account ID
* @param sid School ID
* @param action Result of a submit button
* @param user_type Type of user from the list ('T' for Tour operators, 'E' for schools).
* @param rurl Return URL
*/
procedure accept_select_profile( surl varchar2, bid integer, acid integer default null,
                                 sid integer default null, action varchar2 default null,
                                 user_type char default null, rurl varchar2 default null );

/**
* Accept the selection of a company
* @param surl Secure URL
* @param acid Account ID
* @param cid Company ID
* @param bid Booking ID
* @param action Result of a submit button
* @param login_type 'PROFILE'
* @param rurl Return URL
*/
procedure accept_select_company( surl varchar2, acid integer default null,
                                 cid varchar2 default null, bid varchar2 default null,
                                 action varchar2 default null,
                                 login_type varchar2 default null, rurl varchar2 default null );

/**
* @param surl Secure URL
* @param acid Account ID
* @param bid Booking ID
* @param action Result of a submit button
*/
procedure enter_booking_details( surl varchar2, acid integer, bid varchar2 default null,
                                 action varchar2 default null );
/**
* @param surl Secure URL
* @param acid Account ID
* @param bid Booking ID
* @param action Result of submit button
*/
procedure booking_details( surl varchar2, acid integer default null, bid in varchar2,
                           action in varchar2 default null );


--
-- Administration Screens
--

/**
* @param surl Secure URL
* @param acid Account ID
*/
procedure booking_admin( surl varchar2, acid integer );
/**
* @param surl Secure URL
* @param acid Account ID
*/
procedure mng_booking( surl varchar2, acid integer );

/**
* Default settings for the booking system
* @param surl Secure URL
* @param acid Account ID
* @param msg Optional message string
*/
procedure default_settings( surl varchar2, acid integer, msg varchar2 default null );

/**
* Accept settings in the default settings screen
* @param surl Secure URL
* @param acid Account ID
* @param p_bf Business feature for schools and buses
* @param p_laf Look and feel for schools and buses
* @param p_ord Order style for schools and buses
* @param p_tou
* @param p_receptionist Username of the receptionist role
* @param p_calendar_id Default calendar for Admin screens
* @param p_adult_student_ratio The number of students that need to be accompanied by 1 adult
* @param pEducationCentre The ID of the resource that is the education centre
* @param pGalleries The ID of the resource that is the galleries
* @param action The result of a submit button
*/
procedure accept_default_settings( surl varchar2, acid integer, p_bf varchar2 default null,
                                   p_laf varchar2 default null, p_ord integer default null,
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
                                   action varchar2 );

procedure lab_maintain_bookings( surl varchar2, acid integer default null, show_for varchar2 default null );
procedure lab_calendar_overview( surl varchar2, acid integer default null,
                                 s_chosen_date varchar2 default null,
                                 calid varchar2 default null,
                                 errText varchar2 default null,
                                 action varchar2 default null,
                                 pStatus varchar2 default null,
                                 pVisitType varchar2 default null);
procedure lab_cal_set_filter( surl varchar2, acid integer,
                              pChosenDate varchar2 default null,
                              pCalendarId varchar2 default null,
                              pErrorText varchar2 default null,
                              pAction varchar2 default null,
                              pStatus GLBX.MYARRAY,
                              pVisitType varchar2 default null );
procedure lab_show_calendar( surl varchar2, acid integer default null, calid integer default null, p_proposed_date varchar2 default null, p_days_in_view varchar2 default null );

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
                                firsttime in char default 'F' );
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
                                       action in varchar2 default null );
procedure change_booking_status( surl in varchar2, acid in varchar2 default null, p1 in glbx.myArray, p2 in glbx.myArray, action in varchar2 );

procedure lab_booking_details( surl varchar2, acid integer default null, bid in varchar2, rurl varchar2 default null, action varchar2 default null );
procedure modify_booking_details( surl varchar2, acid integer default null, action varchar2, p_booking_id varchar2, p_date varchar2, p_time varchar2, p_status varchar2, p_num_of_students varchar2, p_num_of_adults varchar2, p_reception_note varchar2, p_admin_note varchar2,  p_contact_person  varchar2, p_contact_email varchar2, creditor varchar2, rurl varchar2 default null );

procedure list_bookings( surl varchar2, acid integer, bid varchar2 default null, action varchar2 default null );

procedure lab_view_changes( surl varchar2, acid integer default null, bid varchar2, rurl varchar2 default null );

procedure lab_make_a_booking( surl varchar2, acid integer );

procedure lab_mng_visit_types( surl varchar2, acid integer );
procedure lab_insert_visit_types( surl varchar2, acid integer, pInsert varchar2 default null, pErrorMessage varchar2 default null );
procedure lab_accept_insert_visit_types( surl varchar2, acid integer, pName varchar2 default null, pClass varchar2 default null, pValidFrom varchar2 default null, pValidTo varchar2 default null, pTimeFrom varchar2 default null, pTimeTo varchar2 default null, pDescription varchar2 default null, pIspaid char default 'F', pInsert varchar2 default null, pCancel varchar2 default null );
procedure lab_update_visit_types( surl varchar2, acid integer, pVisitType integer, pErrorMessage varchar2 default null );
procedure enter_school_holidays( surl varchar2, acid integer default null, pVisitTypeId varchar2, pDateFrom varchar2, pDateTo varchar2, pTimeFrom varchar2, pTimeTo varchar2, pAction varchar2 );
procedure delete_school_holidays( surl varchar2, acid integer default null, pVisitTypeId varchar2, pDateFrom varchar2, pDateTo varchar2 );
procedure lab_accept_update_visit_types( surl varchar2, acid integer, pId integer, pName varchar2 default null, pClass varchar2 default null, pValidFrom varchar2 default null, pValidTo varchar2 default null, pTimeFrom varchar2 default null, pTimeTo varchar2 default null, pDescription varchar2 default null, pUpdate varchar2 default null, pIspaid char default 'F', pCancel varchar2 default null );
procedure lab_delete_visit_types( surl varchar2, acid integer, pVisitType integer );
procedure lab_accept_delete_visit_types( surl varchar2, acid integer, pId integer, pDelete varchar2 default null, pCancel varchar2 default null );
--
-- Reception Screens
--
procedure lab_reception_screen( surl varchar2, ltype varchar2 default null, acid integer, left_api_parm varchar2 default null, scrolldate in char default 'F' );
procedure reception_screen( surl varchar2, ltype varchar2 default null, acid integer );
procedure reception_show_day( surl varchar2, acid integer default null, calid varchar2 default null, p_proposed_date varchar2 default null, p_days_in_view varchar2 default '1', action varchar2 default null, scrolldate in char default 'F' );
procedure reception_booking_details( surl varchar2, acid integer default null, bid integer, rurl varchar2 default null, action varchar2 default null, msg varchar2 default null, firsttime in char default 'T' );
procedure reception_checkout( surl varchar2, acid integer, bid integer,
                              rurl varchar2, num_of_visitors varchar2 default null,
                              num_of_adults   varchar2, note varchar2,
                              creditor varchar2 default null,
                              action varchar2 default null,
                              pProgramId GLBX.MYARRAY,
                              pNumberOfStudents GLBX.MYARRAY,
                              pNumberOfStudentsx varchar2 default null,
                              firsttime in char default 'T' );

procedure select_programs( surl varchar2, acid integer, bid integer, rurl varchar2, login_type varchar2, msg varchar2 default null );
procedure accept_select_programs( surl varchar2, acid integer, rurl varchar2, p1 glbx.myarray, p2 glbx.myarray, bid integer, login_type varchar2, action varchar2 );
procedure select_workbooks( surl varchar2, acid integer, bid integer, rurl varchar2, login_type varchar2, msg varchar2 default null );
procedure accept_select_workbooks( surl varchar2, acid integer, rurl varchar2, p1 glbx.myarray, bid integer, login_type varchar2, action varchar2 );

--
-- Login procedure
--
procedure login1( acid integer, pName varchar2 default null,
                  pState varchar2 default null );
procedure login2( acid integer, pName varchar2 default null,
                  pState varchar2 default null, pSubmit varchar2 default null );
procedure login3( acid integer, pProfileId integer, errmsg in varchar2 default null );
procedure login4( acid integer, pUsername varchar2 default null, pPassword varchar2 default null,
                  pProfileId integer, pSubmit varchar2 default null );
procedure login_connectas( surl varchar2, acid integer, profid integer );
procedure prebook( surl varchar2, acid integer default null, ispast in char default 'F', bknnmb in varchar2 default null );
procedure bookhelp( surl in varchar2, acid in integer );
function visithelp( surl in varchar2, acid in integer, anch in varchar2, visit_id in integer ) return varchar2;
procedure getPassword( pProfileId in integer );
procedure show_receipt( surl in varchar2, vpoid integer, acid integer );

end bkn;

/
