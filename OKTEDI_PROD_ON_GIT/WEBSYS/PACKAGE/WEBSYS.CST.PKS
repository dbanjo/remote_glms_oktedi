CREATE OR REPLACE package WEBSYS.cst
as

 TYPE listint 	IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;

function lightbox_headers(p1 in varchar2, acid in integer, ltype in varchar2 ) return varchar2;
function popup_size( stype in integer, umrec in umo%ROWTYPE, pfx in theme%ROWTYPE, display_original in varchar2 ) return varchar2;
function is_bf( theme_rec in theme_types%ROWTYPE, ltype in varchar2, nmb1 in integer, nmb2 in integer, exp1 in char, exp2 in char, nmb3 in integer default null, exp3 in char default null ) return boolean;
function packaged_product_check( callloc in varchar2, vpoid in integer, pbook in phg_price_book%ROWTYPE, ltype in varchar2 ) return boolean;
function attach_package_item( nmb in integer, purchord purchase_order%ROWTYPE, c3rec in item_package_product%ROWTYPE, c5rec in phg_price_item%ROWTYPE, c5arec in shopping_basket%ROWTYPE ) return boolean;
function main_image(surl in varchar2, stype in integer, ltype in varchar2, acid in integer, umorec in umo%ROWTYPE, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, usemap in varchar2, photo_name in varchar2, style in varchar2 default 'CELL', footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2, voidrec in order_style%ROWTYPE ) return varchar2;

procedure acct_master( surl varchar2, stype in integer default 1, bplatform in varchar2 default null, bvers in varchar2 default NULL, bos in varchar2 default null, simplesearch in varchar2 default null, v_umo in varchar2 default NULL, v_product_id in varchar2 default null, screen_name in varchar2 default null, screen_parms in varchar2 default null, screen_type in varchar2 default null );
procedure acct_search( surl varchar2, acid in integer default null, search_call in varchar2 default NULL );
procedure acct_bottom( surl in varchar2, stype in integer, simplesearch in varchar2 default null, v_umo in varchar2 default NULL, v_product_id in varchar2 default null, screen_name in varchar2 default null, screen_parms in varchar2 default null, screen_type in varchar2 default null);
procedure disp_by_scene( surl varchar2, result_list in ump.search_result_phg, search_total in integer,
                         left_api in varchar2, left_api_parm in varchar2,
                         display_detail in char, title in varchar2, help_file_code in varchar2, footer_api in varchar2,
                         current_page_number in integer, no_results_message in varchar2 default null, acid in integer default null,
                         msg in varchar2 default null, extra_term in varchar2 default null );
procedure accept_display( surl varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, pa in GLBX.MYARRAY, pb in GLBX.MYARRAY, pc in GLBX.MYARRAY, ppn in GLBX.MYARRAY,
                          left_api_parm in varchar2 default null, footer_api in varchar2, current_page_number in varchar2 default 1, display_detail in char  DEFAULT null,
                          add_to_trolley in varchar2 default null, display in varchar2 default null, modify_details in varchar2 default null, add_lightbox in varchar2 default null, del_lightbox in varchar2 default null, empty_lightbox in varchar2 default null, acid in integer default null, lboxid in integer default null );
procedure disp_acct_photo( surl varchar2, photo_id in integer, msg in varchar2 default null, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2, acid in integer default null, how_display in varchar2 default 'TRADITIONAL', extra_term in varchar2 default null );
--procedure add_name( surl in varchar2, photo_id in integer, stp in varchar2 default 'MS', footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2, acid in integer default null );
--procedure accept_add_name( surl varchar2,photo_id in integer, action in varchar2, stp in varchar2, p1 in GLBX.MYARRAY, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2, acid in integer default null);
--procedure delete_name( surl in varchar2, phgid in integer, nme in varchar2, stp in varchar2, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2, acid in integer default null );
--procedure add_comment( surl in varchar2, photo_id in integer, stp in varchar2 default 'MS', footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2, acid in integer default null );
--procedure accept_add_comment( surl in varchar2, photo_id in integer, action in varchar2, stp in varchar2, p1 in varchar2, p1a in varchar2, p2 in varchar2, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2, acid in integer default null );
--procedure delete_comment( surl in varchar2, phgid in integer, posid in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2, acid in integer default null );
procedure acct_topx( surl in varchar2, stypex in integer, bypass_check in varchar2 default 'F', ttl in varchar2 default NULL, helpid in varchar2 default NULL);
procedure acct_leftx( surl in varchar2, scnm in integer default null, expanded_scenes in GLBX.MYARRAY, left_api in varchar2 default null, left_api_parm in varchar2 default null, new_nested in varchar2 default null);
procedure acct_details( surl in varchar2, acid in integer default null, msg in varchar2 default null);
procedure acct_phg( surl in varchar2, acid in integer default null);
procedure acct_showinf( surl in varchar2, typ in varchar2 );
procedure load_img(surl in varchar2, typ in varchar2 default 'PHOTO');
procedure tload(surl in varchar2, file in GLBX.MYARRAY, pname in GLBX.MYARRAY, scnm in varchar2, typ in varchar2);
procedure screen_sze(surl in varchar2, simplesearch in varchar2 default null, v_umo in varchar2 default NULL, v_product_id in varchar2 default null, screen_name in varchar2 default null, screen_parms in varchar2 default null, screen_type in varchar2 default null);
procedure display_gallery(surl in varchar2, msg in varchar2 default null);
procedure run_query( surl varchar2, p1 in varchar2, p1n in varchar2, p1s in char default 'F', p1a in varchar2 default null, umoids in varchar2 default null, isglb in varchar2 default 'F', acid in integer, lbox in varchar2 default 'F', display_number in varchar2 default null, sorton in char default 'N', image_dim in char default 'A', p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, ps in GLBX.MYARRAY, sec_details in ump.SECURITY_DETAILS default ump.empty_sec );
procedure run_query_mfc( surl in varchar2, p1 in varchar2, p1n in varchar2, p1s in char default 'F', isglb in varchar2 default 'F', p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6a in varchar2, p6b in varchar2,
                         p7a in varchar2 default 'F', p7b in varchar2 default 'F', p8 in varchar2, ps in varchar2 default 'F', acid in integer, lbox in varchar2 default 'F', display_number in varchar2 default null );
procedure delete_query( surl in varchar2, p1 in varchar2, typ in varchar2 default 'A', search_call in varchar2, acid in integer );
procedure mfc_clearance( surl in varchar2, mcid in integer, msg in varchar2 default null );
procedure accept_mfc_clearance( surl in varchar2, mcid in integer, p1 in varchar2 );
procedure show_mfc_clearance( surl in varchar2, rnd in varchar2 default null );
procedure create_new_addr( surl varchar2, p1 in varchar2, acid in integer default null );
procedure edit_addr( surl varchar2, addrid in integer, acid in integer default null, msg in varchar2 default null);
procedure accept_addr( surl varchar2, addrid in integer, acid in integer default null, p1 in GLBX.MYARRAY);
procedure del_addr( surl varchar2, addrid in integer, acid in integer default null);
procedure meta_tag_search( surl varchar2, acctype in varchar2, p1n in varchar2, p1s in char default 'F', acid in integer, lbox in varchar2 default 'F', attrid in GLBX.MYARRAY, edit_type in GLBX.MYARRAY, P1 in GLBX.MYARRAY, PS in GLBX.MYARRAY, TAG_VALUE in GLBX.MYARRAY, AOR IN GLBX.MYARRAY, PSHOW IN GLBX.MYARRAY, display_number in varchar2 default null );
procedure tender_list(surl varchar2, rnd in varchar2, msg in varchar2 default null);
procedure modify_tender_list(surl varchar2, tid in varchar2, msg in varchar2 default null);
procedure accept_tender_list( surl varchar2, tid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p3d in varchar2, action in varchar2, r0 in GLBX.MYARRAY, r1 in GLBX.MYARRAY, r2 in GLBX.MYARRAY, r3 in GLBX.MYARRAY, r4 in GLBX.MYARRAY );
procedure reverse_list(surl varchar2, rnd in varchar2, msg in varchar2 default null);
procedure manage_reverse(surl varchar2, raid in integer, msg in varchar2 default null);
procedure accept_reverse_bid( surl in varchar2, raid in integer, p1 in varchar2, action in varchar2 );
procedure simple_search( surl in varchar2, p1 in varchar2, p2 in varchar2 default 'N', p3 in GLBX.MYARRAY, acid in integer, age in varchar2 default null, umoids in varchar2 default null, find in varchar2 default null, display_number in varchar2 default null, sorton in char default 'N', image_dim in char default 'A', sec_details in ump.SECURITY_DETAILS default ump.empty_sec );
procedure goto_page( surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, display_detail in varchar2, search_total in integer, acid in integer, currpage in integer, page in varchar2 );
procedure disp_category( surl in varchar2, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null );
procedure disp_lightbox( surl in varchar2, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null );
procedure disp_store( surl in varchar2, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null );
procedure disp_event( surl in varchar2, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null );
procedure srfq( surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null, msg in varchar2 default null, p1 in varchar2 default null, p2 in varchar2 default null, p3 in varchar2 default null, p4 in varchar2 default null );
procedure accept_srfq( surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in char, acid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, action in varchar2 );
procedure previous_orders( surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null, msg in varchar2 default null, disp_close_window in char default 'F' );
procedure mng_previous_orders( surl in varchar2, otype in char, ordid in varchar2, footer_api in varchar2, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null, disp_close_window in char default 'F' );
procedure auth_payment( surl in varchar2, acid in integer default null, msg in varchar2 default null, footer_api in varchar2 default null, left_api_parm in varchar2 default null, newwin in char default 'F' );
procedure auth_payment_report( surl in varchar2, acid in integer default null, footer_api in varchar2 default null, left_api_parm in varchar2 default null, newwin in char default 'F' );
procedure cust_contact( surl in varchar2, acid in integer, profid in integer, action in varchar2 default 'UPDATE', cust_type in char default null, msg in varchar2 default null, err_inst in integer default null, err_cust in customer_contact%ROWTYPE default null, extra_inf in varchar2 default null,
                        footer_api in varchar2 default null, left_api_parm in varchar2 default null, start_from in integer default null, display_detail in char default null );
procedure accept_cust_contact( surl in varchar2, acid in integer, profid in integer, contid in integer, ltype in varchar2, action in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY,
                               footer_api in varchar2 default null, left_api_parm in varchar2 default null, start_from in integer default null, display_detail in char default null );
procedure display_thumbnail(surl in varchar2, ltype in varchar2, umrec in UMO%ROWTYPE,theme_rec in theme_types%ROWTYPE, pfx in THEME%ROWTYPE,
                            footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, hor_caption in varchar2,
                            document_api in varchar2, video_api in varchar2, audio_api in varchar2, relational_api in varchar2, blueprint_api in varchar2, acid in integer default null, display_original in varchar2 default null, stype in integer default 1, extra_term in varchar2 default null, image_style in varchar2 default 'STYLE="display:block;"' );
procedure whatsnew( surl in varchar2, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null );
procedure mng_lightbox(surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in varchar2, acid in integer default null, msg in varchar2 default null, ispopup in boolean default FALSE );
procedure accept_mng_lightbox(surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in varchar2, acid in integer default null, p1 in varchar2, p2 in varchar2 default null, lbox in varchar2, action in varchar2 );
procedure lightbox_note(surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in varchar2, acid in integer default null, v_umo integer, msg in varchar2 default null );
procedure add_all_lightbox(surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in varchar2, acid in integer default null, p1 in varchar2, msg in varchar2 default null );
procedure accept_lightbox_note(surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in varchar2, acid in integer default null, v_umo integer, p1 in varchar2, p2 in varchar2, action in varchar2 );
procedure intercept_icon( surl in varchar2, v_umo in integer );
procedure meta_edit( surl in varchar2, v_umo in integer, acid in integer, reterrors in GLBX.MYARRAY );
procedure accept_meta_edit( surl in varchar2, v_umo in integer, acid in integer, tag_id in glbx.myarray, tag_name in glbx.myarray, tag_value in glbx.myarray );
procedure disp_standard_search(surl in varchar2, stype in integer, ltype in varchar2, profid in integer, acid integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, style in varchar2 default 'STANDARD' );
procedure small_buttons( surl in varchar2, ltype in varchar2, cusrec in customer_account%ROWTYPE, umrec in umo%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, voidrec in order_style%ROWTYPE, footer_api in varchar2, left_api_parm in varchar2, lbox in varchar2, cusloc in varchar2, overdv in varchar2, ctr in integer, acid in integer, hor_but out varchar2, display_detail in char, display_original in varchar2 default null, stype in integer default 1, extra_term in varchar2 default null);
procedure image_object( surl in varchar2, ltype in varchar2, cusrec in customer_account%ROWTYPE, umrec in umo%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, voidrec in order_style%ROWTYPE, footer_api in varchar2, left_api_parm in varchar2, ctr in integer, acid in integer, display_detail in char, display_original in varchar2, stype in integer default 1, inhomepage in boolean default FALSE, extra_term in varchar2 default null);
procedure initialise_control_buttons( surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, cusloc in varchar2, dispvert in char, acid integer );
procedure control_buttons(surl in varchar2, sess_id integer, ltype in varchar2, title in varchar2, umrec in UMP.SEARCH_RESULT_PHG, cusrec in customer_account%ROWTYPE, left_api_parm in varchar2,
                          start_from in integer, search_total in integer, footer_api in varchar2, numb_photos in integer, lbox in varchar2, lboxall in varchar2,
                          theme_rec in theme_types%ROWTYPE, pfx in THEME%ROWTYPE, dispvert in varchar2 default 'T', acid in integer default null, control_style in varchar2, pbook in phg_price_book%ROWTYPE );
procedure disp_privacy(surl in varchar2, ltype in varchar2, profid in integer, acid integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE );
procedure image_statistics( ltype in varchar2, theme_rec in theme_types%ROWTYPE, umrec in umo%ROWTYPE );
procedure disp_meta_query_search(surl in varchar2, ltype in varchar2, owner_id in integer, profid in integer, acid integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE );
procedure accept_display_mfctr( surl varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, pa in GLBX.MYARRAY, pb in GLBX.MYARRAY, pc in GLBX.MYARRAY, ppn in GLBX.MYARRAY,
                                left_api_parm in varchar2 default null, footer_api in varchar2, current_page_number in varchar2 default 1, display_detail in char  DEFAULT null,
                                add_to_trolley in varchar2 default null, display in varchar2 default null, modify_details in varchar2 default null, add_lightbox in varchar2 default null,
                                del_lightbox in varchar2 default null, empty_lightbox in varchar2 default null, acid in integer default null, lboxid in integer default null );
procedure call_novelty( p1 in varchar2, run_novelty in varchar2 default null );
procedure view_html( surl in varchar2, typ in varchar2, v_umo in integer, acid in integer, sterm in varchar2 default null);
procedure packprod(surl in varchar2, ltype in varchar2, stype in integer, sess_id in integer, profid in integer, acid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purchord in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, left_api in varchar2, left_api_parm in varchar2, msg in varchar2 default null);
procedure accept_packprod( surl in varchar2, left_api_parm in varchar2, left_api in varchar2, p1 in varchar2, action in varchar2, acid in integer );
procedure packprod_hdr( surl in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in char, acid in integer );
procedure packprod_edit( surl in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in char, acid in integer, pkg in integer default null );
procedure accept_packprod_edit( surl in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in char, acid in integer, pkg in integer default null, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, action in varchar2 );
procedure packprod_individual( surl in varchar2, left_api_parm in varchar2, left_api in varchar2, acid in integer );
procedure accept_packprod_edit_basket( surl in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in char, acid in integer, pkg in integer default null, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p6 in GLBX.MYARRAY, action in varchar2 );
procedure accept_confirm_addmore( surl in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in char, acid in integer, pkg in integer default null, action in varchar2 );
procedure handle_toggle( surl in varchar2, footer in varchar2, left_api_parm in varchar2, start_from in varchar2, display_detail in varchar2, acid in integer );

end cst;
/
