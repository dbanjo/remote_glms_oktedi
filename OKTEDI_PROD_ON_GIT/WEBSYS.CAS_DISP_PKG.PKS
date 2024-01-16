CREATE OR REPLACE PACKAGE WEBSYS.CAS_DISP_PKG AS

  /**********************************
   PUBLIC MODULE DEFINITIONS
  ***********************************/

  FUNCTION fn_get_attribute( pi_umo_id PLS_INTEGER
                           , ps_attr_category VARCHAR2
                           , ps_mode VARCHAR2 DEFAULT 'concat'
                           , ps_concat VARCHAR2 DEFAULT '; '
                           )
  RETURN VARCHAR2;


  PROCEDURE pr_get_record (
      surl 			IN VARCHAR2
    , ltype 			IN VARCHAR2
    , acid  			IN NUMBER DEFAULT NULL
    , owner_id 			IN INTEGER
    , pi_query_id 		IN INTEGER DEFAULT 0
    , umrec 			IN UMO%ROWTYPE
    , ps_selected_coll 		IN VARCHAR2 DEFAULT NULL
    , ps_view_type 		IN VARCHAR2 DEFAULT NULL
    , current_page_number 	IN INTEGER DEFAULT 0
    , left_api_parm 		IN VARCHAR2 DEFAULT NULL
    , ps_access_level 		IN VARCHAR2 DEFAULT NULL
    );


  PROCEDURE extract_leftapi_parm( left_api_parm IN VARCHAR2
                                , i_query_id OUT INTEGER
                                , s_selected_coll OUT VARCHAR2
                                , s_view_type OUT VARCHAR2
                                );


  PROCEDURE pr_disp_child_objects( surl IN VARCHAR2
                                  , acid  IN NUMBER DEFAULT NULL
                                  , pi_umo_id IN INTEGER DEFAULT 0
                                  , ps_display_title IN VARCHAR2 DEFAULT NULL
                                  , ps_display_type IN VARCHAR2 DEFAULT 'RAW'
                                  , ps_display_what IN VARCHAR2 DEFAULT 'HTML'
                                  );


  PROCEDURE pr_summary_scr( surl IN VARCHAR2
                          , left_api_parm  IN VARCHAR2 DEFAULT ''
                          );


  PROCEDURE pr_detailed_scr (
      surl 			IN VARCHAR2
    , acid 			IN NUMBER 	DEFAULT NULL
    , pi_query_id 		IN INTEGER	DEFAULT 0
    , pi_umo_id 		IN INTEGER 	DEFAULT 0
    , ps_selected_coll 		IN VARCHAR2 	DEFAULT NULL
    , ps_view_type 		IN VARCHAR2 	DEFAULT NULL
    , current_page_number 	IN INTEGER 	DEFAULT 0
    , ps_message 		IN VARCHAR2 	DEFAULT NULL
    , ps_access_level		IN VARCHAR2
    );


  PROCEDURE pr_results_scr( surl IN VARCHAR2
                          , stype IN INTEGER DEFAULT 0

-- added these ones M
                     , ltype IN VARCHAR2 DEFAULT NULL
                     , umrec IN UMP.SEARCH_RESULT_PHG
                     , cusrec IN CUSTOMER_ACCOUNT%ROWTYPE
                     , pfx IN THEME%ROWTYPE
                     , theme_rec IN THEME_TYPES%ROWTYPE
                     , footer_api IN VARCHAR2 DEFAULT NULL
                     , display_detail IN VARCHAR2 DEFAULT NULL
                     , left_api IN VARCHAR2 DEFAULT NULL
                     , left_api_parm IN VARCHAR2 DEFAULT NULL
                     , cusloc IN VARCHAR2 DEFAULT NULL
                     , lbox IN VARCHAR2 DEFAULT NULL
                     , acid IN INTEGER DEFAULT NULL

                          , owner_id IN NUMBER DEFAULT NULL
                          , pi_query_id IN INTEGER DEFAULT 0
                          , starting_record IN INTEGER DEFAULT 1
                          , search_total IN INTEGER DEFAULT 0

                         , pi_umo_id IN INTEGER DEFAULT 0
                         , ps_umo_coll IN VARCHAR2 DEFAULT 'ALL'
                         , pi_has_images IN INTEGER DEFAULT 0
                         , ps_selected_coll IN VARCHAR2 DEFAULT 'ALL'
                         , ps_view_type IN VARCHAR2 DEFAULT NULL
                         , ps_message VARCHAR2 DEFAULT NULL
                         );


  PROCEDURE pr_display( surl IN VARCHAR2
                      , stype IN INTEGER DEFAULT 0
                      , ltype IN VARCHAR2 DEFAULT NULL
                      , umrec IN UMP.SEARCH_RESULT_PHG
                      , cusrec IN CUSTOMER_ACCOUNT%ROWTYPE
                      , pfx IN THEME%ROWTYPE
                      , theme_rec IN THEME_TYPES%ROWTYPE
                      , footer_api IN VARCHAR2 DEFAULT NULL
                      , starting_record IN INTEGER DEFAULT 1
                      , search_total IN INTEGER DEFAULT 0
                      , display_detail IN VARCHAR2 DEFAULT NULL
                      , left_api IN VARCHAR2 DEFAULT NULL
                      , left_api_parm IN VARCHAR2 DEFAULT NULL
                      , cusloc IN VARCHAR2 DEFAULT NULL
                      , lbox IN VARCHAR2 DEFAULT NULL
                      , acid IN INTEGER DEFAULT NULL
                      , owner_id IN INTEGER DEFAULT NULL
                      , msg IN VARCHAR DEFAULT NULL
                      );


  PROCEDURE pr_collate_results( surl 		IN VARCHAR2
                              , acid 		IN NUMBER DEFAULT NULL
                              , left_api_parm 	IN VARCHAR2 DEFAULT NULL
                              , start_from 	IN INTEGER DEFAULT 1			-- now, this is the staring record
                              , display_detail 	IN CHAR DEFAULT NULL
                              , ps_message 	IN VARCHAR DEFAULT NULL
                              , ps_title	 	IN VARCHAR DEFAULT 'Search Results'
                              );


  PROCEDURE pr_get_public_image (
    ps_rkey 	in varchar2 default null
  , ps_accnum 	in varchar2 default null
  , ps_what 	in VARCHAR2 default 'thumb'
  );


  PROCEDURE pr_get_public_record (
    ps_mkey 	in varchar2 default null
  , ps_accnum 	in varchar2 default null
  );


  PROCEDURE pr_get_photo_rec_for_roh (
    ps_mkey 	in varchar2 default null
  , ps_accnum 	in varchar2 default null
  );


END CAS_DISP_PKG;

/
