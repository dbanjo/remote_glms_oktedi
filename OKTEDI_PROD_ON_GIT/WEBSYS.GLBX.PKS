CREATE OR REPLACE package WEBSYS.glbx
as

 TYPE myarray 	   IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
 TYPE myarray_nmb  IS TABLE OF number INDEX BY BINARY_INTEGER;
 TYPE screen_sizes IS TABLE OF INTEGER;
 TYPE frame_sizes  IS TABLE OF VARCHAR2(20);

 EMPTY_ARRAY		owa.vc_arr;

 IMAGE_LOCATION				constant varchar2(50)	:= '/images/'; -- kept for strang and oltp.sql only

 CURRENT_VERSION			constant varchar2(30)	:= 'V4.8.2f';

 -- Colours
 TABLE_BACKGROUND			constant varchar2(30) 	:= 'bgcolor="#c0c0c0"';
 TITLE_BACKGROUND			constant varchar2(30) 	:= 'bgcolor="#000060"';
 QUERY_BACKGROUND			constant varchar2(30) 	:= 'bgcolor="#C0C0A0"';
 QUERY_CELL_BACKGROUND			constant varchar2(30) 	:= 'bgcolor="#E0E0D0"';
 QUERY_CELL_BACKGROUND1			constant varchar2(30) 	:= 'FFFFFF';
 QUERY_CELL_BACKGROUND2 		constant varchar2(30) 	:= 'FFFACD';

 -- Display Format Masks
 MB_MASK				constant varchar2(50)	:= '999,999,990.99';
 KB_MASK				constant varchar2(50)	:= '999,999,990.9';
 UPLOAD_NAME				constant varchar2(100)  := '<INPUT TYPE="FILE" NAME="FILE">';
 UPLOAD_NAME_NOTAG			constant varchar2(100)  := '<INPUT TYPE="FILE" NAME="FILE"'; -- Note that the angle end bracket is removed

 -- Limits
 PHOTO_PROOF_DISPLAY			constant integer	:= 50;
 C_PROG_MAX_SIZE			constant integer	:= 12000000;
 C_PROG_MAX_WATERMARK			constant integer	:= 1000000;

 -- Locations
 GLOBAL_DIR				constant varchar2(40)	:= 'LOAD_FILES';
 PICTION_LOGIN_PAGE			constant varchar2(255) 	:= '/index.html';
 PICTION_CHECK_ORDER_PAGE		constant varchar2(255) 	:= 'fname.check_order';
 DEFAULT_FILE 				constant varchar2(40)	:= 'files.txt';
 STRESS_TEST				constant boolean	:= FALSE;
 DBG_CTR				integer;

 -- External HTML Files (all these files are located in the MAIL_TEMPLATE directory)
 EXT_CONTACTUS				constant varchar2(100)	:= 'contactus.html';
 EXT_FEEDBACK				constant varchar2(100)	:= 'feedback.html';
 EXT_HELP				constant varchar2(100)	:= 'help.html';
 EXT_LEGAL				constant varchar2(100)	:= 'legal.html';
 EXT_PRIVACY				constant varchar2(100)	:= 'privacy.html';
 EXT_README_NOTES			constant varchar2(100)	:= 'readme.html';
 EXT_TERMS_AND_CONDITIONS		constant varchar2(100)	:= 'terms_and_conditions.html';
 EXT_MAIN_IMAGE				constant varchar2(100)	:= 'main_image.html';
 EXT_ORDER_STYLE_TERMS_HTML		constant varchar2(100)	:= 'order_style_terms.html';

 cursor sPfx(sess_id integer) is select disp_prefix from theme th, customer_account ca, login_session ls where th.theme_name = ca.theme_name and ca.aid=ls.aid and ls.sessid = sess_id ;
 cursor pPfx(phgid integer) is select disp_prefix from theme th, customer_account ca, photographer ph where th.theme_name = ca.theme_name and ph.pid=ca.pid;
 -- Placed here to get around a V9i issue with compiling

 function get_sfx( sess_id in integer ) return varchar2;
 function get_hfx( phgid in integer ) return varchar2;
 function photo_lf( ownid in integer ) return THEME%ROWTYPE;
 function photo_pref( pid integer, acid integer, prefname varchar2 ) return varchar2;
 function userpref_sess(sess_id in integer, txt in varchar2) return varchar2;
 function scrollbar( msg in varchar2, bar_type in varchar2 default 'SCROLLBAR' ) return varchar2;
 function backimg( surl in varchar2, acid in integer default null, backcol in varchar2, bckimg in integer default null, ownr in varchar2 default 'OWNER', extra_js in varchar2 default null) return varchar2;
 function censor (txt in varchar2, maxlength in integer default null, ignore_lf in boolean default FALSE, ignore_html in boolean default FALSE)  return varchar2;
 function get_thm( acid in integer ) return THEME%ROWTYPE;
 function get_thm( thm in varchar2 ) return THEME%ROWTYPE;
 function get_email(surl in varchar2) return varchar2;
 function get_country(surl in varchar2) return varchar2;
 function conv_nmb( val in varchar2, typ in varchar2 default 'MONEY' ) return number;
 function extract_fname( fname in varchar2, ftype in varchar2 DEFAULT 'NO_EXTENSION', maxlength in integer DEFAULT 100) return varchar2;
 function conv_account( profile_rec in CUSTOMER_PROFILE%ROWTYPE, customer_rec in CUSTOMER_ACCOUNT%ROWTYPE ) return CUSTOMER_ACCOUNT%ROWTYPE;
 function get_aidx( sesid in integer, gtype in varchar2, ltype in varchar2 ) return customer_account%ROWTYPE;
 function get_aid( sesid in integer, gtype in varchar2, ltype in out varchar2 ) return customer_account%ROWTYPE;
 function get_cusrec( sess_id in integer, ltype in out varchar2, acid in integer, profid out integer ) return customer_account%ROWTYPE;
 function encrypt( password IN Varchar2, use_gcard in boolean default FALSE, special_key in varchar2 default null) return varchar2;
 function get_random_sessionid return integer;
 function randstring return varchar2;
 function linkdisp( surl in varchar2, v_umo integer, to_umo in integer, linkstrength in number, linktype in varchar2, filmname in varchar2, photoname in varchar2, stype in integer, acid in integer ) return varchar2;
 function get_dir( val in varchar2, lvl in varchar2 ) return varchar2;
 function indnt( pscene integer ) return integer;
 function rndsurl( surl in varchar2 ) return varchar2;
 function truncsurl( surl in varchar2 ) return varchar2;
 function man_discount( manid integer, phgid integer ) return number;
 function strip_special_characters( str in varchar2 ) return varchar2;
 function page_break(  val in varchar2 default null ) return varchar2;
 function meta_sql_query( v_umo in integer, utype in varchar2, lov_list in varchar2 ) return varchar2;
 function encrypt_data( input_string in integer ) return varchar2;
 function validate_encrypted_data( keyval in varchar2, output_nmb out integer ) return boolean;
 function certificate_remaining( certid in integer ) return number;
 function historic_purchase_orders( sess_id in integer ) return glbx.myarray;
 function certificate_validate( certid in varchar2, acid in integer, cert_rec out GIFT_CERTIFICATE%ROWTYPE, err out varchar2 ) return boolean;
 function embed_image_map( surl in varchar2, v_umo in integer, adj in number, acid in integer ) return varchar2;
 function extract_umos( umos in varchar2 ) return GLBX.MYARRAY;
 function keyword_anchor( surl in varchar2, txt in varchar2, acid in integer default null, js in boolean default FALSE, parent in boolean default FALSE ) return varchar2;
 function since_last_session( surl in varchar2 ) return number;
 function disp_mt( surl in varchar2, ltype in varchar2, v_umo in integer, utype in varchar2, bf_167 in char, pfx in THEME%ROWTYPE, acid in integer, show_cols in GLBX.MYARRAY, noscreen in boolean default FALSE, parent in boolean default FALSE) return boolean;
 function authority_outstanding( profid integer ) return number;
 function get_order_style( acid in integer, profid in integer, logintype in varchar2, b2c_value out varchar2 ) return integer;
 function get_theme_types(ttype in varchar2) return theme_types%ROWTYPE;
 function get_order_style(void in integer) return order_style%ROWTYPE;
 function get_purchase_order(sess_id in integer) return purchase_order%ROWTYPE;
 function img_meta_edit( v_umo in integer, utype in varchar2, pfx in THEME%ROWTYPE, single_edit in boolean, stype in integer, acid in integer, format_type in varchar2 default 'PHOTOGRAPHER', bftr in varchar2 default null ) return boolean;
 function update_meta_data( surl in varchar2, v_umo in integer, acid in integer, utype in varchar2, ltype in varchar2, tag_id in GLBX.MYARRAY, tag_name in GLBX.MYARRAY, tag_value in GLBX.MYARRAY, reterrors in out GLBX.MYARRAY, reterrors_ctr in out integer ) return boolean;
 function randword return varchar2;
 function adjust_for_http( http_address in varchar2 ) return varchar2;
 function where_called( called_from in varchar2 ) return integer;
 function available_to( ltype in varchar2 ) return integer;
 function encrypt_password( input_string in varchar2, maxlength in integer default 128 ) return varchar2;
 function decrypt_password( input_string_hex in varchar2, maxlength in integer default 128 ) return varchar2;
 function quality_loop( p1 in varchar2, existing_value in varchar2 default null, show_hdr_ftr in boolean default TRUE) return varchar2;
 function fndtheme( vsess in integer, acid in integer default null ) return varchar2;

 -- Order Totals
 function retrieve_pricing_value( parm_key in varchar2, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY_NMB ) return number;
 function extract_purchase_value( vpoid in integer, parm_key in varchar2 ) return number;
 function total_payment( poid integer ) return number;
 function individual_payment( vsbid integer ) return number;
 function grand_total_payment( poid in integer, include_gift_certificate in boolean default TRUE ) return number;
 function quick_grand_total_payment( poid in integer, item in varchar2 default null ) return number;

 procedure extract_grand_total_payment( poid in integer, gst_value out number, discounts out number, cert_total out number, gtotal out number, include_gift_certificate in boolean default TRUE );
 procedure extract_photographer_order( poid in integer, gst in number, subtotal out number, gtotal out number, handling out number, commission out number, phg_receives out number, tax out number, postage out number, include_gift_certificate in boolean default TRUE );
 procedure purchase_each_cost( purchrec in purchase_order%ROWTYPE, additional_options out number, surcharge out number, gst out number, postage out number, discount out number );
 procedure calculate_pricing( vpoid in integer, parm1 in out NOCOPY GLBX.MYARRAY, parm2 in out NOCOPY GLBX.MYARRAY_NMB );

 procedure process_acct_details( surl in varchar2, acid in integer, p1 in varchar2, p1b in varchar2 default null, p2 in varchar2, p2a in varchar2, p2b in varchar2, p3 in varchar2, p4 in varchar2, p4a in varchar2, p5 in varchar2, p6 in varchar2, p6f in varchar2, p7 in varchar2, p8 in varchar2,
                                 action in varchar2 default null, profid in integer default null, ppub in varchar2 default 'F', pmet in varchar2 default 'F', event_to_use in varchar2 default null);
 procedure logon_user( un in varchar2, pw in varchar2, sts out varchar2, session_id out integer, stype out integer, Click_To_Login in varchar2 default null, em in varchar2 default null, un_email in char default 'F', job in varchar2 default null, surl out varchar2, country in varchar2 default null, existing_sessid_is in integer default null );
 procedure adm_cookie_id( surl in varchar2, owner_id out integer, sts out varchar2, progcalled in varchar2 default null );
 procedure forgotten_password( un in varchar2 );
 procedure accept_login( un in varchar2 default null, pw in varchar2 default null, Click_To_Login in varchar2 default null, em in varchar2 default null, unsolicited_email in varchar2 default 'F', job in varchar2 default null, country in varchar2 default null, simplesearch in varchar2 default NULL, v_umo in varchar2 default NULL, v_product_id in varchar2 default null, screen_name in varchar2 default null, screen_parms in varchar2 default null, screen_type in varchar2 default 'RIGHT', rnd in varchar2 default null);
 procedure login_page(msg in varchar2 default null, un in varchar2 default null, em in varchar2 default null, job in varchar2 default null, style in varchar2 default 'INITIAL', pfx in THEME%ROWTYPE default null, on_form in char DEFAULT 'TTTTTT', unsolicited_email in varchar2 default 'F', country in varchar2 default null, pw in varchar2 default null, promptoption in varchar2 default 'E', simplesearch in varchar2 default NULL, v_umo in varchar2 default NULL, v_product_id in varchar2 default null, screen_name in varchar2 default null, screen_parms in varchar2 default null, screen_type in varchar2 default 'RIGHT');
 procedure acct_logoff( surl in varchar2, iscust in varchar2 default 'T', force_logoff in varchar2 default 'F', other_logoff in varchar2 default null);
 procedure redisplay_login_page( msg in varchar2, nodisplay in boolean default FALSE, extra_parameter in varchar2 default null );
 procedure acct_home( surl in varchar2, acid in integer default null, rnd in integer default 1234);
 procedure account_temp_disabled( c1rec CUSTOMER_ACCOUNT%ROWTYPE );
 procedure modify_cust_access( surl in varchar2, acid in integer default null, p1 in varchar2, p2 in varchar2);
 procedure list_all_audio( surl in varchar2, acid in integer);
 procedure show_help( surl in varchar2 default null, helpid in varchar2 default null, typ in varchar2 default null, logtyp in varchar2 default NULL, highlightword in varchar2 default NULL);
 procedure grab_email_address( acid in integer, p1 in varchar2, p2 in varchar2 default 'F' );
 procedure send_emails( surl in varchar2, p1 in varchar2, acid in integer );
 procedure beta_bug( surl in varchar2, acid in integer default null);
 procedure accept_beta_bug(acid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2 );
 procedure process_mfc_details( surl in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2, p8 in varchar2, p9 in varchar2 default 'F', p10 in varchar2, p11 in varchar2, p12 in varchar2, p13 in varchar2, p14 in varchar2, p15 in varchar2, action in varchar2 );
 procedure request_extension( acid in integer );
 procedure accept_extension( acid in integer, p1 in varchar2, p2 in varchar2 );
 procedure change_password( surl in varchar2, acid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, action in varchar2 );
 procedure send_the_mail_smtp(fname in varchar2, p_from in varchar2, p_to in varchar2, p_subj in varchar2, is_sms in varchar2 DEFAULT 'FALSE', is_attachment in varchar2 default 'FALSE', infile in varchar2 default null );
 procedure determine_wm( ph1 in ORDSYS.ORDIMAGE, ph2 in ORDSYS.ORDIMAGE, wm in varchar2, xcoord out integer, ycoord out integer, sts out integer);
 procedure header_msg( txt in varchar2, newline in boolean default TRUE );
 procedure scene_display( surl in varchar2, custrec in CUSTOMER_ACCOUNT%ROWTYPE, pfx in THEME%ROWTYPE, ltype in varchar2, stype in integer, owner_id in integer, bf92 in char, bf131 in char, imghdr in varchar2, titlegif in varchar2, proftot in integer default 0, expanded_scenes in GLBX.MYARRAY, showtotal in boolean default FALSE, align in varchar2 default 'ALIGN="LEFT"', new_nested in varchar2 default null );
 procedure transfer_link( surl in varchar2, v_umo in integer, to_umo in integer, src in varchar2, acid in integer );
 procedure validate_meta_tag( tag_value in varchar2, tag_record in UMO_ATTRIBUTES%ROWTYPE, result out varchar2 );
 procedure phg_expired_pwd(p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2);
 procedure displog( surl in varchar2, acid integer, action in varchar2 default 'VIEW', acc in varchar2 default 'ADMIN', new_window in varchar2 default 'T' );
 procedure display_warranty( surl in varchar2, wid in integer, phgid in integer );
 procedure instruction( txt in varchar2, pfx in theme%ROWTYPE );
 procedure meta_lov( parm in varchar2, mandatory in varchar2, lov_list in varchar2, value in varchar2, multilist in varchar2 default null );
 procedure meta_sql( v_umo in integer, utype in varchar2, parm in varchar2, mandatory in varchar2, lov_list in varchar2, value in varchar2 );
 procedure relogin( surl in varchar2, acid in integer );
 procedure external_html_file(surl in varchar2, cusrec in customer_account%ROWTYPE, display_type in varchar2, tag_name in GLBX.MYARRAY, tag_title in GLBX.MYARRAY, fname in varchar2 default null );
 procedure image_nmb_index( surl in varchar2, cusrec in customer_account%ROWTYPE, pfx in THEME%ROWTYPE, ltype in varchar2, acid in integer, gap in integer default 10 );
 procedure certificate_history( cert_rec in GIFT_CERTIFICATE%ROWTYPE, pfx in THEME%ROWTYPE );
 procedure phg_account_disabled;
 procedure display_query(acid in integer, srcnme in varchar2, ltype in varchar2, sess_id in integer, vpid in integer, lbox in varchar2, rowsret out integer);
 procedure home_disptable( home_rec in home_news%ROWTYPE, surl in varchar2, acid in varchar2, stype in integer, ltype in varchar2, pfx in THEME%ROWTYPE, cusrec in customer_account%ROWTYPE, theme_rec in THEME_TYPES%ROWTYPE, profid in integer );
 procedure get_all_order_details(sess_id in integer, ltype in out varchar2, acid in integer, profid out integer, cusrec out customer_account%rowtype, pfx out theme%rowtype, theme_rec out theme_types%rowtype, purchord out purchase_order%rowtype, voidrec out order_style%rowtype );
 procedure powered_by_piction(surl in varchar2, left_api_parm in varchar2, search_total in integer, display_detail in varchar2, ltype varchar2, acid in integer);

 procedure meta_prompt( surl in varchar2, acid in integer, ltype in varchar2, tgroup in varchar2, v_umo in integer default null, button_found in out boolean, onegrouponly in integer default null, can_edit in char default 'T', query_mode in boolean default FALSE, default_names in glbx.myarray, default_values in glbx.myarray, recno in integer default null, rectotal in integer default null );
 procedure meta_query_perform( surl in varchar2, acid in integer, sess_id in integer, ltype in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY );
 procedure meta_query_navigate( surl in varchar2, acid in integer, curr_umo in integer, navigate_option in varchar2, next_umo out integer, currno in integer, recno out integer );
 procedure meta_handle_query_action(surl in varchar2, acid in integer, sess_id in integer, ltype in varchar2, action in varchar2, qmode in char, file in varchar2, pUmoId in integer, lUmoId in out integer, currno in integer, recno out integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY );

 procedure online_poll(surl in varchar2, stype in integer, ltype in varchar2, profid in integer, acid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, over_width in varchar2 default null );
 procedure accept_online_poll( surl in varchar2, acid in integer, p1 in varchar2 default null, find in varchar2 default null );
 procedure noframe( surl in varchar2, called_from in varchar2 default null );
 procedure external_file_load( surl in varchar2, file in varchar2, fdir in out varchar2, fname in out varchar2 );
 procedure comma_delimited(bfr in varchar2, comma_delim out GLBX.MYARRAY, delimchar in char default ',');
 procedure dbg( vinf in varchar2, vsurl in varchar2 default null, vproc in varchar2 default null );

 --
 -- Documented API Package Headers
 --
 procedure main_title( surl varchar2, ttl in varchar2, bodyb in varchar2 default null, helpid in varchar2 default null, stype in integer default 1,
                       sstyle in varchar2 default 'Times New Roman', sclr in varchar2 default 'fffccc', lnk in varchar2 default 'ACTIVE',
                       det_sstyle in varchar2 default 'Arial', det_sclr in varchar2 default '000000', det_font in varchar2 default 'ffffff',
                       h2_sstyle in varchar2 default null, h2_sclr in varchar2 default null, hover in varchar2 default 'C0C0C0', disptop in varchar2 default 'F',
                       finc in integer default 0, errclr in varchar2 default 'FF0000', errfnt in varchar2 default 'Times New Roman', instclr in varchar2 default '0000FF', instfnt in varchar2 default 'Arial', instfntinc in integer default 0,
                       jscript in varchar2 default null, title_only in boolean DEFAULT FALSE, excolour in varchar2 default null, exfont in varchar2 default null, ltype in varchar2 default null, small_link in boolean default FALSE,
                       my_class in varchar2 default null, my_font in varchar2 default null, my_size in varchar2 default null, my_colour in varchar2 default null,
                       icra_label in varchar2 default null, top_padding in integer default 5, left_padding in integer default 5, uline in varchar2 default null, sim_three_frame in char default 'F',
                       uline_active in varchar2 default null, uline_visited in varchar2 default null, retlink in varchar2 default null, ispopup in boolean default FALSE, stylesh in varchar2 default null);
 procedure cookie_id( surl in varchar2, stype out varchar2, ltype out varchar2, owner_id out integer, sts out varchar2, call_type in varchar2 default 'O', progcalled in varchar2 default null, retrieved_id in integer default null, dispwhat in varchar2 default null, iscust in boolean default TRUE, reset in boolean default TRUE, ignore_cookie_check in boolean default FALSE );
 procedure show_public_accounts( photographer_id in integer, bgcolor in varchar2 default 'FFFFFF', style in varchar2 default 'URL',
                                 title in varchar2 default null, justify in varchar2 default 'CENTER',
                                 table_parm in varchar2 default NULL, table_data in varchar2 default NULL,
                                 jobref in varchar2 default '%', disp_no_img in varchar2 default 'F', business_feature in varchar2 default '%',
                                 instruction_text in varchar2 default null, bar_title in varchar2 default null, anchor in varchar2 default null,
                                 returl in varchar2 default null, returl_display in varchar2 default null, number_links in varchar2 default null, rnd in varchar2 default null,
                                 ctarget in varchar2 default '_top', html_page in varchar2 default null, subdir in varchar2 default null);
 procedure show_all_accounts( photographer_id in integer, bgcolor in varchar2 default 'FFFFFF', style in varchar2 default 'URL',
                              title in varchar2 default null, justify in varchar2 default 'CENTER',
                              table_parm in varchar2 default NULL, table_data in varchar2 default NULL,
                              jobref in varchar2 default '%', disp_no_img in varchar2 default 'F', business_feature in varchar2 default '%',
                              instruction_text in varchar2 default null, bar_title in varchar2 default null, anchor in varchar2 default null,
                              returl in varchar2 default null, returl_display in varchar2 default null, number_links in varchar2 default null, rnd in varchar2 default null,
                              ctarget in varchar2 default '_top', html_page in varchar2 default null, subdir in varchar2 default null);
 procedure error_details(pkn in varchar2 default null, prc in varchar2 default null, vpid in integer default null, vaid in integer default null, vphid in integer default null, vpoid in integer default null, errmsg in varchar2 default null, extdet in varchar2 default null, display_error_page in boolean default TRUE);
 procedure send(gcode in GLBX.MYARRAY,gparam in GLBX.MYARRAY,infile in varchar2,p_to in varchar2,p_subj in varchar2 default NULL,p_from in varchar2 default NULL,p_cc in varchar2 default NULL,p_bcc in varchar2 default NULL, is_sms in boolean default FALSE, is_report in boolean default FALSE, ltype in varchar2 default null, own_id in integer default null, extension in varchar2 default null, is_attachment in boolean default FALSE, scode in varchar2 default null, v_pid in integer default null, v_aid in integer default null, v_profile_id in integer default null );
 procedure send_workflow( gcode in GLBX.MYARRAY, gparam in GLBX.MYARRAY, infile in varchar2, tname  in varchar2, job in out varchar2, printer in varchar2 );
 procedure image_matte( pfx in THEME%ROWTYPE, wd in integer, hg in integer, trg in varchar2, trgdisp in varchar2, ctarget in varchar2 );
 procedure extended_search_api( surl in varchar2, ltype in varchar2, result_list in UMP.SEARCH_RESULT_PHG, search_total in integer,
                                display_detail in char default NULL, title in varchar2 default null, help_file_code in varchar2 default null,
                                left_api in varchar2 default null, left_api_parm in varchar2 default null, footer_api in varchar2 default null,
                                current_page_number in varchar2, no_results_message in varchar2 default null, acid in integer default null,
                                msg in varchar2 default null, extra_term in varchar2 default null );
 procedure create_profile( surl in varchar2, profile_name in varchar2, profile_un in varchar2, profile_pw in varchar2, profile_pwg in varchar2 default null,
                           bftr in varchar2, laf in varchar2, transfer_lbox in boolean default FALSE, acid in integer default null, disconnect_session in boolean default TRUE, return_surl out varchar2, result out varchar2, use_existing_surl in boolean default TRUE );
 procedure modify_profile( surl in varchar2, parm1 in GLBX.MYARRAY, parm2 in GLBX.MYARRAY, result out varchar2, update_purchase_order_surl in varchar2 default null );
 procedure delete_profile( surl in varchar2, profile_un in varchar2, acid in integer default null, result out varchar2 );
 procedure relogin( surl in varchar2, un in varchar2, pw in varchar2, sts out varchar2, nsurl out varchar2, use_existing_surl in boolean default TRUE );
 procedure public_registration( acid in integer );
 procedure close_page( pfx in THEME%ROWTYPE );
 procedure reconnect( failurl in varchar2 default null, simplesearch in varchar2 default null, v_umo in varchar2 default NULL, v_product_id in varchar2 default null, screen_name in varchar2 default null, screen_parms in varchar2 default null, screen_type in varchar2 default 'RIGHT' );
 procedure reset_cookie( new_surl in varchar2, use_javascript in boolean default TRUE );
 procedure fixnm( nm in varchar2, fn out varchar2, lnm out varchar2 );

 function novelty_option( surl in varchar2, pfx in theme%ROWTYPE, footer_api in varchar2, left_api_parm in varchar2,  current_page_number in integer, display_detail in char, cusrec in customer_account%ROWTYPE, ltype in varchar2, called_from in varchar2, display in varchar2, loc_id in integer ) return varchar2;
 function extract_master_parameter( pname in varchar2 ) return varchar2;
 function userpref(phgid in integer, acid in integer, txt in varchar2) return varchar2;
 function userlist return glbx.myarray;
 function userexists( un in varchar2 ) return boolean;
 function proposed_users( un in varchar2, limit in integer default 5 ) return glbx.myarray;
 function gif_exists( url in varchar2 ) return boolean;
 function sctrl( tname in varchar2, ctrl in varchar2, stype in integer ) return varchar2;

 function saved_preference_value( acid in integer, profid in integer, ltype in varchar2, preference_name in varchar2 ) return varchar2;
 function saved_preference_update( acid in integer, profid in integer, ltype in varchar2, preference_name in varchar2, preference_value in varchar2 ) return boolean;
 function saved_preference_delete( acid in integer, profid in integer, ltype in varchar2, preference_name in varchar2 ) return boolean;

 --
 -- Procedure and Functions currently on hold for possible reuse
 --
 -- function  get_pfx( acid in integer, typ in varchar2 default 'PREFIX' ) return varchar2;
 -- procedure adjust_screen_size( stype in integer default 1 );
 -- function display_screen_size( pfx in varchar2 default 'w_d_', stype in integer, backcol in varchar2 default glbx.TITLE_BACKGROUND ) return varchar2;

 function external_query_show( v_umo in integer, utype in varchar2, value in varchar2, edit_type in varchar2, lov_list in varchar2, sql_select_mask in varchar2, external_query in char ) return varchar2;
 procedure show_checkbox( c2rec in customer_meta_data%ROWTYPE, c3rec in umo_attributes%ROWTYPE, value in varchar2 );
 procedure external_email( phgid in integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, option1 in GLBX.MYARRAY, option2 in GLBX.MYARRAY, submit in varchar2 default null );
 function get_login_application( sess_id in integer, keyval in varchar2 ) return varchar2;
 function update_login_application( sess_id in integer, keyval in varchar2, newval in varchar2 ) return boolean;
 function auto_file_type( v_filename in varchar2 ) return varchar2;
 function find_nmb( val in varchar2 ) return integer;
 function match_password( value1 in varchar2, value2 in varchar2 ) return boolean;
 procedure file_listing( start_directory in varchar2, include_subdirs in boolean, load_using_file boolean default FALSE, fname in varchar2 default null, fdir in varchar2 default null, rsess in out varchar2, error_message out varchar2 );

 function guess_date( val in varchar2 ) return varchar2;
 function guess_date_circa( val in varchar2, date_type in varchar2 ) return varchar2;
 function guess_number( val in varchar2 ) return varchar2;
 function guess_money( val in varchar2 ) return varchar2;
 function guess_boolean( val in varchar2, ifnull in boolean default FALSE, ifunknown in boolean default TRUE ) return boolean;

 -- Portlet Calls
 procedure portlet( pid in varchar2, name in varchar2 );
 procedure portlet( pid in varchar2, name in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );
 procedure portlet( photographer_id in varchar2, portlet_name in varchar2 );
 procedure portlet( photographer_id in varchar2, portlet_name in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );
 procedure portlet( username in varchar2, name in varchar2 );
 procedure portlet( username in varchar2, name in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );
 procedure portlet_send( portid in integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, action in varchar2 );

 -- Link Calls
function delete_link(v_umo in integer ) return boolean;
function add_link( from_umo in integer, to_umo in integer, annote in varchar2 default null, isfinal in char default 'T', lktype in char default 'T' ) return boolean;
function disp_link_history( start_umo in integer, tbl in varchar2, hdr in varchar2, td1 in varchar2, td2 in varchar2, trg in varchar2, lktype in char default 'T' ) return boolean;

end glbx;
/


GRANT EXECUTE ON WEBSYS.GLBX TO STRANG;

GRANT EXECUTE ON WEBSYS.GLBX TO STX1;
