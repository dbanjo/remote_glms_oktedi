CREATE OR REPLACE package WEBSYS.scl
as

MAINTENANCE       constant integer := 1;
CONNECTAS         constant integer := 2;
SELECTION         constant integer := 3;
LOGIN             constant integer := 4;
SELECTIONGUEST    constant integer := 5;

/*
*/
procedure mng_booking_profiles(
  surl varchar2,                                 -- Secure URL
  acid integer,                                  -- Account ID when logged in as manufacturer or photographer
  user_type varchar2,                            -- User type of the profile 'E' for School or 'T' for Bus Company
  p_id varchar2 default null,                    -- Profile ID
  p_name varchar2 default null,                  -- Profile name
  p_street varchar2 default null,                -- Street name
  p_suburb varchar2 default null,                -- Suburb
  p_country varchar2 default null,                  -- country
  p_pcode varchar2 default null,                 -- Postal Code
  p_state varchar2 default null,                 -- State
  p_email varchar2 default null,                 -- Email
  action varchar2 default null,                  -- What button is pressed?
  search_range varchar2 default '0Z',            -- Search range the user clicked on
  pFunctionality integer default MAINTENANCE,    -- What is the list called for, can be: MAINTENANCE, CONNECTAS, SELECTION, LOGIN
  bid integer default null,                      -- Booking ID if creating a booking
  rurl varchar2 default null,
  firsttime in char default 'T');                   -- Return URL

procedure update_profile(
  surl    varchar2,
  acid    integer,
  user_type varchar2,
  sid     integer,
  errText varchar2 default null);

procedure accept_update_profile(
  surl                varchar2,
  acid                integer,
  user_type           varchar2,
  P_id                integer,
  P_name              varchar2,
  P_street            varchar2,
  P_suburb            varchar2,
  P_country           varchar2,
  P_pcode             varchar2,
  P_state             varchar2,
  P_email             varchar2,
  P_fax               varchar2,
  P_phone             varchar2,
  P_teachers_name     varchar2,
  P_teachers_phone    varchar2,
  P_teachers_email    varchar2,
  P_Branch	      varchar2 default null,
  P_udf1	      varchar2 default null,
  P_udf2	      varchar2 default null,
  P_udf3	      varchar2 default null,
  P_udf4	      varchar2 default null,
  P_udf5	      varchar2 default null,
  P_udf6	      varchar2 default null,
  p_profile_nam       varchar2 default null,
  p_profile_un        varchar2 default null,
  p_profile_pw        varchar2 default null,
  p_profile_cpw       varchar2 default null,
  p_profile_pwg       varchar2 default null,
  p_date_expires      varchar2 default null,
  p_customer_disabled varchar2 default 'F',
  action              varchar2 default null);

procedure insert_profile(
  surl                varchar2,
  acid                integer,
  user_type varchar2,
  errText             varchar2 default null,
  P_name       varchar2 default null,
  P_street            varchar2 default null,
  P_suburb            varchar2 default null,
  P_country              varchar2 default null,
  P_pcode             varchar2 default null,
  P_state             varchar2 default null,
  P_email             varchar2 default null,
  P_fax        varchar2 default null,
  P_phone      varchar2 default null,
  P_teachers_name     varchar2 default null,
  P_teachers_phone    varchar2 default null,
  P_teachers_email    varchar2 default null,
  P_Branch	 	varchar2 default null,
  P_udf1	 	varchar2 default null,
  P_udf2	 	varchar2 default null,
  P_udf3	 	varchar2 default null,
  P_udf4	 	varchar2 default null,
  P_udf5	 	varchar2 default null,
  P_udf6	 	varchar2 default null,
  p_profile_name      varchar2 default null,
  p_profile_un        varchar2 default null,
  p_profile_pw        varchar2 default null,
  p_profile_cpw       varchar2 default null,
  p_profile_pwg       varchar2 default null,
  p_date_expires      varchar2 default null,
  p_customer_disabled varchar2 default 'F',
  action              varchar2 default null);

procedure accept_insert_profile(
  surl                varchar2,
  acid                integer,
  p_user_type varchar2,
  P_name       varchar2 default null,
  P_street            varchar2 default null,
  P_suburb            varchar2 default null,
  P_country              varchar2 default null,
  P_pcode             varchar2 default null,
  P_state             varchar2 default null,
  P_email             varchar2 default null,
  P_fax        varchar2 default null,
  P_phone      varchar2 default null,
  P_teachers_name     varchar2 default null,
  P_teachers_phone    varchar2 default null,
  P_teachers_email    varchar2 default null,
  P_Branch	 	varchar2 default null,
  P_udf1	 	varchar2 default null,
  P_udf2	 	varchar2 default null,
  P_udf3	 	varchar2 default null,
  P_udf4	 	varchar2 default null,
  P_udf5	 	varchar2 default null,
  P_udf6	 	varchar2 default null,
  p_profile_name      varchar2 default null,
  p_profile_un        varchar2 default null,
  p_profile_pw        varchar2 default null,
  p_profile_cpw       varchar2 default null,
  p_profile_pwg       varchar2 default null,
  p_date_expires      varchar2 default null,
  p_customer_disabled varchar2 default 'F',
  action              varchar2 default null);

procedure delete_profile(
  surl  varchar2,
  acid  integer,
  user_type varchar2,
  sid   integer);

procedure accept_delete_profile(
  surl   varchar2,
  acid   integer,
  user_type varchar2,
  sid    integer,
  action varchar2 default null);

end scl; -- end package

/
