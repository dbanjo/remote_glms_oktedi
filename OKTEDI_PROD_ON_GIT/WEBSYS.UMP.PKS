CREATE OR REPLACE package WEBSYS.ump
as

 TYPE dirlist IS RECORD
  (
    filename 	 varchar2(1000),
    filesize	 integer
  );

 TYPE quotalist IS RECORD
  (
    plan_style 	 	varchar2(100),
    plan_name 	 	varchar2(100),
    renewal		varchar2(100),
    max_photo_size	integer,
    max_photos		integer,
    max_storage		integer,
    total_used		integer,
    total_asset		integer,
    numb_ph_orig	integer,
    size_ph_orig	integer,
    numb_ph_web		integer,
    size_ph_web		integer,
    numb_ph_thmb	integer,
    size_ph_thmb	integer,
    numb_ph_back	integer,
    size_ph_back	integer,
    numb_doc_orig	integer,
    size_doc_orig	integer,
    numb_aud_orig	integer,
    size_aud_orig	integer,
    numb_vid_orig	integer,
    size_vid_orig	integer,
    numb_bp_orig	integer,
    size_bp_orig	integer,
    numb_bp_online	integer,
    size_bp_online	integer
  );

 TYPE security_details IS RECORD
  (
    ltype		varchar2(100),
    pid			integer,
    aid			integer,
    profid		integer,
    returnto		varchar2(20),
    sessid		integer,
    em			varchar2(100),
    query		varchar2(4000)
  );

 TYPE parameters IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
 TYPE myarray 	IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
 TYPE myarray_int 	IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
 TYPE search_result_phg IS TABLE OF UMO%ROWTYPE INDEX BY BINARY_INTEGER;
 TYPE dirlisting IS TABLE OF dirlist INDEX BY BINARY_INTEGER;


 TYPE directory_list IS RECORD
  (
    fullpath 	 varchar2(4000),
    directory 	 varchar2(4000),
    filename 	 varchar2(4000),
    filesize	 integer,
    filetype	 varchar2(100),
    security 	 varchar2(4000),
    datetime	 date
  );

TYPE directory_list_arr IS TABLE OF directory_list INDEX BY BINARY_INTEGER;


 CURRDIR	dirlisting;
 empty_sec	security_details;

 function uma_attribute( surl varchar2,ump_id in integer, attrib_id in integer ) return varchar2;
 function uma_attribute( surl varchar2,ump_id in integer, objtype in varchar2, subcat in varchar2 ) return varchar2;
 function uma_scene( surl varchar2,ump_id in integer, scene_id in integer ) return varchar2;
 function retrieve_scenes( surl varchar2,v_owner_id in integer, v_owned_by in varchar2, v_category in varchar2, v_phgr in integer, v_parent_id in integer default null, v_title_id in integer default NULL, display_style in varchar2 default 'LIST' ) return varchar2;
 function c_err(code in integer) return varchar2;
 function acct_details(surl varchar2,owner_id in integer, acid in integer) return varchar2;
 function extract_tokens( tval in varchar2, ctr in integer, split_numbers in boolean default FALSE, tokens in out nocopy myarray ) return varchar2;
 function check_daily_queries return boolean;
 function random_file_name( ext in varchar2 default 'jpg' ) return varchar2;
 function random_file_location( ext in varchar2, file_suffix in varchar2 default null ) return varchar2;
 function process_audcmd( surl in varchar2, phgid in integer, acid in integer, v_umo in myarray_int, show_params in char default 'F', entered_params_p1 in UMP.MYARRAY, entered_params_p2 in UMP.MYARRAY ) return UMP.MYARRAY;
 function process_image_magick( surl in varchar2, phgid in integer, acid in integer, v_umo in myarray_int, montage_id in integer, v_magick in integer, recreate_tnail in char, show_params in char default 'F', entered_params_p1 in UMP.MYARRAY, entered_params_p2 in UMP.MYARRAY ) return UMP.MYARRAY;
 function create_document_tnail( surl varchar2, v_umo integer ) return varchar2;
 function create_directory_images(surl in varchar2, acid in integer ) return boolean;

 procedure load_uma( surl varchar2,parm1 in UMP.PARAMETERS, parm2 in UMP.PARAMETERS, retval out varchar2, new_umo_id out myarray_int, bypass_surl in boolean default FALSE  );
 procedure modify_uma( surl varchar2,parm1 in UMP.PARAMETERS, parm2 in UMP.PARAMETERS, retval out varchar2 );
 procedure retrieve_uma( surl varchar2,parm1 in UMP.PARAMETERS, parm2 in UMP.PARAMETERS );
 procedure wav( surl varchar2,parm1 in UMP.PARAMETERS, parm2 in UMP.PARAMETERS );
 procedure aiff( surl varchar2,parm1 in UMP.PARAMETERS, parm2 in UMP.PARAMETERS );
 procedure mp3( surl varchar2,parm1 in UMP.PARAMETERS, parm2 in UMP.PARAMETERS );
 procedure get_quota( surl varchar2,owner_type in varchar2, owner_id in integer, pname in varchar2, acid in integer, quota out ump.quotalist );
 procedure advanced_search_phg( surl varchar2, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null, query_date in date default SYSDATE-10000, sec_details in SECURITY_DETAILS default empty_sec, ctx in char default 'F' );
 procedure manufacturer_search_phg( surl varchar2, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null, query_date in date default SYSDATE-10000, sec_details in SECURITY_DETAILS default empty_sec );
 procedure meta_tag_search( surl varchar2, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null, query_date in date default SYSDATE-10000, sec_details in SECURITY_DETAILS default empty_sec ) ;
 procedure audio_index( v_umo in integer, schemaname in varchar2, howloaded in varchar2 default 'BATCH', action in varchar2 default 'INSERT' );
 procedure video_index( v_umo in integer, schemaname in varchar2, howloaded in varchar2 default 'BATCH', action in varchar2 default 'INSERT' );
 procedure relational_index( v_umo in integer, schemaname in varchar2, howloaded in varchar2 default 'BATCH', action in varchar2 default 'INSERT' );
 procedure blueprint_index( v_umo in integer, schemaname in varchar2, howloaded in varchar2 default 'BATCH', action in varchar2 default 'INSERT' );
 procedure document_index( v_umo in integer, schemaname in varchar2, howloaded in varchar2 default 'BATCH', action in varchar2 default 'INSERT' );
 procedure load_uma_exit( password in varchar2, parm1 in UMP.PARAMETERS, parm2 in UMP.PARAMETERS, retval out varchar2, new_umo_id out myarray_int );

 function umo_modify_entry( v_umo in integer, attribid in integer, key_val in varchar2, acid in integer, position in integer, actual_api in varchar2, extract_numbers in char) return boolean;
 procedure meta_tag_api( password in varchar2, tag_option in varchar2, v_umo in integer, tag_type in varchar2, tag_name in varchar2, tag_value in varchar2 default null, result out varchar2 );
 procedure meta_tag_api( password in varchar2, search_on in varchar2, search_parameter in varchar2, tag_option in varchar2, customer_username in varchar2, tag_type in varchar2, tag_name in varchar2, tag_value in varchar2 default null, result out varchar2 );
 procedure meta_tag_api( password in varchar2, primary_key_tag in varchar2, primary_key_tag_value in varchar2, tag_option in varchar2, customer_username in varchar2, tag_type in varchar2, tag_name in varchar2, tag_value in varchar2 default null, create_if_not_exist in boolean default FALSE, result out varchar2 );

-- procedure c_get_blob(retsess out varchar2, v_umo out integer, outblob in out NOCOPY blob, width out integer, height out integer, MAXBUFLEN in integer, too_big out integer,
--                      tnail out integer, rotate_wmark out integer, p1 out integer,
--                      merge_blob in out NOCOPY blob, merge_width out integer, merge_height out integer, merge_lucent out integer, merge_clr out integer, merge_x out integer, merge_y out integer, schemaname out varchar2, filename in out varchar2, filename2 in out varchar2,
--                      prt1 in out varchar2, prt2 in out varchar2, prt3 in out varchar2, zipindex out UMP.MYARRAY);
-- procedure c_upd_blob(retsess in varchar2, v_umo in integer, too_big in integer, tnail in integer, schemaname in varchar2 default user, vlob in out blob);
-- procedure c_dir(retfilename in varchar2, filesize in integer);
-- procedure convblob( tblob in out blob, typ in varchar2 );

 procedure image_prescript( retsess out varchar2, cmd out integer, vblob out blob, v_umo out integer, reload_images out integer, input_file out varchar2, output_file out varchar2, montage_file out varchar2, montage_blob out blob, visual_output_file out varchar2, numbparms out integer, myindex in out UMP.MYARRAY, schemaname out varchar2, extra_parms out integer, extra_umo in out UMP.MYARRAY, extra_umo_file in out UMP.MYARRAY );
 --procedure image_postscript( retsess in varchar2, return_parms in out UMP.MYARRAY );

 procedure show_public_image( v_umo in integer, call in varchar2 default 'STANDARD' );
 procedure show_public_image( name in varchar2, ctr in integer default 1, call in varchar2 default 'STANDARD' );
 function show_public_image( v_umo in integer, call in varchar2 default 'STANDARD' ) return umo%ROWTYPE;

 procedure webservice( parm1 in ump.parameters, parm2 in ump.parameters );
 procedure init( acid in integer, utype in varchar2, v_umo out integer );

 function file_copy( source in varchar2, destination in varchar2 ) return boolean;
 function random_directory return varchar2;
 function directory_delete(source in varchar2) return boolean;
 function file_remove( source in varchar2 ) return boolean;
 function file_rename( source in varchar2, destination in varchar2 ) return boolean;
 function file_extract_source( v_umo in integer, acid in integer, utype in varchar2, destination in varchar2 ) return boolean;
 function file_printer_template( template in varchar2, destination in varchar2, destfilename in varchar2, parm1 in UMP.MYARRAY, parm2 in UMP.MYARRAY ) return boolean;
 function file_print( printer_name in varchar2, print_template in varchar2, lptid in integer default 1, parm1 in UMP.MYARRAY, parm2 in UMP.MYARRAY ) return boolean;
 function zip_wildcard( store_path_name in boolean, search_sub_directories in boolean, zip_filename in varchar2, zip_files_wildcard in varchar2 ) return boolean;
 function zip( store_path_name in boolean, search_sub_directories in boolean, zip_filename in varchar2, zip_files in UMP.MYARRAY ) return boolean;
 function unzip( store_path_name in boolean, unzip_filename in varchar2, unzip_directory in varchar2 ) return boolean;
 function directory_listing(fdir in varchar2, ptr in integer ) return boolean;
 function directory_listing(fdir in varchar2, arrlist in out NOCOPY ump.directory_list_arr) return boolean;
 function identify_image( surl in varchar2, acid in integer, v_umo in integer, parmarr1 in out nocopy ump.parameters, parmarr2 in out nocopy  ump.parameters ) return boolean;
 function image_magick_load( surl in varchar2, umo_rec in umo%ROWTYPE, parm1 in UMP.PARAMETERS, parm2 in UMP.PARAMETERS ) return boolean;
 function image_magick_watermark( surl in varchar2, v_umo in integer, acid in integer, parm1 in UMP.PARAMETERS, parm2 in UMP.PARAMETERS ) return boolean;
 function image_magick_rotate( surl in varchar2, v_umo in integer, acid in integer, rotate in varchar2, parm1 in UMP.PARAMETERS, parm2 in UMP.PARAMETERS ) return boolean;
 function rip_audio( surl in varchar2, phgid in integer, jarr in integer, vparm1 in UMP.PARAMETERS, vparm2 in UMP.PARAMETERS, new_umo_id out myarray_int ) return varchar2;
 function attach_metadata( surl in varchar2, doc in sys.xmldom.DOMDocument, v_umo in integer) return boolean;

end ump;

/
