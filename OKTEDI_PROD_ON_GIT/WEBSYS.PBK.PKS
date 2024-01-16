CREATE OR REPLACE package WEBSYS.pbk
as

 procedure main( surl varchar2, msg in varchar2 default null);
 procedure phg_reverse_email(surl varchar2, acid in integer, typ in varchar2, ebook in varchar2 );
 procedure addr( surl varchar2, msg in varchar2 default null);
 procedure create_new_addr( surl varchar2, p1 in varchar2 );
 procedure edit_addr( surl varchar2, addrid in integer, msg in varchar2 default null);
 procedure accept_addr( surl varchar2, addrid in integer, action in varchar2, p1 in GLBX.MYARRAY);
 procedure del_addr( surl varchar2, addrid in integer);
 procedure accept_new_pb(surl varchar2, p1 in varchar2, p2 in GLBX.MYARRAY, p3 in varchar2 default 'F', p4 in varchar2 );
 procedure edit_item( surl varchar2, id in integer, msg in varchar2 default null );
 procedure list_item( surl varchar2, id in integer, booktot in integer default null, rng in integer default 1, src in varchar2 default null );
 procedure modify_item( surl varchar2,id in integer, pbit in integer, msg in varchar2 default NULL, booktot in integer default null );
 procedure accept_modify(surl in varchar2, id in integer, pbit in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2 DEFAULT 'F', p5 in varchar2, p6 in varchar2, p9 in varchar2 DEFAULT 'F',
                         pmfct1 in varchar2 default null, pdl_l in varchar2, pdl_i in varchar2, pdl_desc in varchar2, pprd in varchar2, pprd_desc in varchar2, psr_l in varchar2, psr_i in varchar2,  tm1 in varchar2, tm2 in varchar2, tm3 in varchar2, itm1 in varchar2, itm2 in varchar2, itm3 in varchar2,
                         pstk in varchar2 default null, pstk_msg in varchar2 default null, pstck_a in char default 'F', pitm_1 in char default 'F', pitm_2 in varchar2 default null, pitm_3 in varchar2 default null, pitm_4 in varchar2 default null,
                         p10 in varchar2, p11a in varchar2, p11b in varchar2, psa in varchar2 default 'F', psb in varchar2 default null, pclass in varchar2, action in varchar2, pwk in varchar2 default null, pdwna in varchar2 default null, pdwnb in varchar2 default null,
                         pmt0 in GLBX.MYARRAY, pmt1 in GLBX.MYARRAY, pmt2 in GLBX.MYARRAY, ry1 in GLBX.MYARRAY, ry2 in GLBX.MYARRAY, ry3 in GLBX.MYARRAY, booktot in integer default null);
 procedure report( surl varchar2, id integer );
 procedure delete_price_book( surl varchar2, id integer );
 procedure mng_warranty( surl varchar2, msg in varchar2 default null);
 procedure accept_warranty( surl in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );
 procedure mng_clearance( surl varchar2, msg in varchar2 default null);
 procedure edit_clearance( surl varchar2, mcid in integer, msg in varchar2 default null);
 procedure accept_edit_clearance( surl in varchar2, mcid in integer, p1 in varchar2, p2a in varchar2, p2b in varchar2, p2c in varchar2, p3 in varchar2, p4 in integer, p5 in varchar2,
                                  p6a in varchar2 default 'F', p6b in varchar2 default 'F', p6c in varchar2 default 'F', p6d in varchar2 default 'F', p7a in varchar2 default 'F', p7c in varchar2 default 'F',
                                  p7b in varchar2, p8 in GLBX.MYARRAY, action in varchar2);
 procedure tender_list(surl varchar2, msg in varchar2 default null);
 procedure modify_tender_list(surl varchar2, acid in integer, tid in varchar2, msg in varchar2 default null);
 procedure accept_tender_list( surl varchar2, acid in integer, tid in integer, p1 in varchar2, p1c in varchar2, p2 in varchar2, p3 in varchar2, p3d in varchar2, p4 in varchar2 default null, action in varchar2, r0 in GLBX.MYARRAY, r1 in GLBX.MYARRAY, r2 in GLBX.MYARRAY, r3 in GLBX.MYARRAY, r4 in GLBX.MYARRAY );
 procedure accept_tender_mfctr( surl varchar2, acid in integer, tid in integer, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY );
 procedure tender_mfctr(surl varchar2, acid in integer, mid in integer, tid in varchar2, msg in varchar2 default null);
 procedure bid_tender_mfctr(surl varchar2, acid in integer, itid in integer, tid in varchar2, msg in varchar2 default null);
 procedure accept_bid_tender( surl varchar2, acid in integer, tid in integer, itid in integer, p1 in GLBX.MYARRAY, p2 in varchar2 default 'F' );
 procedure reverse_list(surl varchar2, msg in varchar2 default null);
 procedure manage_reverse(surl varchar2, raid in integer, msg in varchar2 default null);
 procedure accept_manage_reverse( surl varchar2, raid in integer, action in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p5h in varchar2, p5m in varchar2, p6 in varchar2, p7 in GLBX.MYARRAY, p8 in GLBX.MYARRAY, p9 in GLBX.MYARRAY, p10 in GLBX.MYARRAY );
 procedure home_page_option(surl varchar2, acid in integer, msg in varchar2 default null);
 procedure accept_home_page_option( surl in varchar2, acid in varchar2, p0 in varchar2, p2 in varchar2, p4 in varchar2, p5 in varchar2, pext in varchar2 default null, p1 in GLBX.MYARRAY );
 procedure mass_create( surl varchar2, id integer, p1 in varchar2 default 'F', p2 in varchar2 default '0' );
 procedure contactus( surl in varchar2, typ in varchar2 default 'P', msg in varchar2 default null );
 procedure accept_contactus( surl in varchar2, p1 in varchar2, typ in varchar2 );
 procedure mng_clearance_order(surl varchar2, mcid in integer, msg in varchar2 default null);
 procedure send_email( surl varchar2, addrid in integer, p1 in varchar2, p2 in varchar2 );
 procedure mng_profiles(surl varchar2, acid in integer, startid in varchar2 default 'AC', msg in varchar2 default null, search_profile in varchar2 default null, search_username in varchar2 default null, search_bftr in varchar2 default null, search_laf in varchar2 default null, search_aname in varchar2 default null, search_created in varchar2 default null );
 procedure delete_profile(surl in varchar2,acid in integer, profid in integer, msg in varchar2 default null);
 procedure delete_profile_confirm(surl in varchar2, acid in integer, profid in integer, action in varchar2);
 procedure album_mgmt(surl in varchar2, acid in integer, msg in varchar2 default null);
 procedure gcertificate(surl in varchar2, acid in integer, msg in varchar2 default null);
 procedure manage_gift(surl in varchar2, acid in integer, gcid in integer, msg in varchar2 default null);
 procedure accept_manage_gift(surl in varchar2, acid in integer, gcid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, action in varchar2, p4 in varchar2 default null, p5 in varchar2 default null, p6 in varchar2 default null);
 procedure increase_event_plan(surl in varchar2, msg in varchar2 default null );
 procedure accept_increase_event(surl in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );
 procedure confirm_increase_event(surl in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, action in varchar2 );
 procedure mng_usr_event(surl in varchar2, acid in integer, pagenmb in integer default 1, msg in varchar2 default null );
 procedure accept_mng_usr_event(surl in varchar2, acid in integer, pe1 in varchar2, pe2 in varchar2, pe3 in varchar2, pe4 in varchar2, pagenmb in integer, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, ispub in GLBX.MYARRAY );
 procedure reverse_event(surl in varchar2, acid in integer, msg in varchar2 default null );
 procedure accept_reverse_event( surl in varchar2, acid in integer, p1 in varchar2, p2 in varchar2, p3 in char default 'F', p4 in char default 'F' );
 procedure mng_authority(surl in varchar2, acid in integer, profid integer, msg in varchar2 default null );
 procedure accept_mng_authority(surl in varchar2, acid in integer, profid integer, p1 in varchar2, p2 in GLBX.MYARRAY, p3 in varchar2, p3a in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2, action in varchar2 );
 procedure mng_simple_rfq(surl in varchar2, see_archived in varchar2 default 'F', msg in varchar2 default null);
 procedure edit_simple_rfq(surl in varchar2, see_archived in varchar2 default 'F', srfqid in integer, msg in varchar2 default null);
 procedure accept_simple_rfq(surl in varchar2, srfqid in integer, see_archived in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in GLBX.MYARRAY, p7 in GLBX.MYARRAY, p8 in GLBX.MYARRAY, p9 in GLBX.MYARRAY, p10 in GLBX.MYARRAY, p11 in GLBX.MYARRAY, p12 in GLBX.MYARRAY, p0 in GLBX.MYARRAY, pc in GLBX.MYARRAY, p13 in varchar2, action in varchar2 );
 procedure mng_register(surl in varchar2, acid in integer, msg in varchar2 default null );
 procedure accept_mng_register(surl in varchar2, acid in integer, p3 in varchar2, p4a in varchar2, p4b in varchar2, p4c in varchar2, p4d in varchar2, p4e in varchar2,
                               p5a in varchar2, p5b in varchar2, p5c in varchar2, p5d in varchar2, p5e in varchar2,
                               p6 in varchar2, p1a in GLBX.MYARRAY, p1b in GLBX.MYARRAY, p1c in GLBX.MYARRAY, p1d in GLBX.MYARRAY, p1e in GLBX.MYARRAY, p2 in GLBX.MYARRAY );
 procedure mng_workflow(surl in varchar2, msg in varchar2 default null );
 procedure mng_workflow_set(surl in varchar2, workid in integer, msg in varchar2 default null );
 procedure mng_workflow_task_del(surl in varchar2, workid in integer, vsts in integer );
 procedure mng_workflow_task(surl in varchar2, workid in integer, vsts in varchar2, p1 in varchar2, msg in varchar2 default null );
 procedure accept_new_workflow( surl in varchar2, p1 in varchar2, p2 in integer );
 procedure mng_workflow_activity(surl in varchar2, actid in integer, p1 in varchar2, msg in varchar2 default null );
 procedure accept_mng_workflow( surl in varchar2, p1 in varchar2, actid in integer, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, r1 in GLBX.MYARRAY, r2 in GLBX.MYARRAY, r3 in GLBX.MYARRAY, r4 in GLBX.MYARRAY, r5 in GLBX.MYARRAY );
 procedure accept_workflow_task( surl in varchar2, workid in integer, vsts in integer, p1 in varchar2, p2 in varchar2, p3 in GLBX.MYARRAY, p3d in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY );
 procedure accept_mng_workflow_set(surl in varchar2, workid in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );
 procedure mng_workflow_state(surl in varchar2, wsid in integer, p1 in varchar2, msg in varchar2 default null );
 procedure workflow_activity_delete(surl in varchar2, actid in integer, ord in integer );
 procedure accept_mng_state( surl in varchar2, p1 in varchar2, wsid in integer, spi in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY );
 procedure mng_workflow_state_del(surl in varchar2, wsid in integer );
 procedure price_book_copy( surl varchar2, id integer, p1 varchar2, booktot in integer default null );
 procedure mass_change( surl varchar2, id integer );
 procedure accept_mass_change( surl varchar2, id integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2,
                               r1 in varchar2, r2 in varchar2, r3 in varchar2, r4 in varchar2, r5 in varchar2, r6 in varchar2, r7 in varchar2, r8 in varchar2, r9 in varchar2 );
 procedure product_search( surl in varchar2, id in integer, pbit in integer, msg in varchar2 default null );
 procedure accept_product_search( surl in varchar2, id in integer, pbit in integer, p1 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2 );
 procedure edit_workflow_query(surl in varchar2, workid in integer, vsts in integer, qry in integer, msg in varchar2 default null );
 procedure accept_edit_workflow_query(surl in varchar2, workid in integer, vsts in integer, qry in integer, action in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6 in GLBX.MYARRAY, p7 in GLBX.MYARRAY );
 procedure add_mfctr( surl in varchar2, id in integer, msg in varchar2 default null );
 procedure accept_add_mfctr( surl in varchar2, id in varchar2, p2 in GLBX.MYARRAY );
 procedure del_mfctr( surl in varchar2, id in integer, msg in varchar2 default null );
 procedure accept_del_mfctr( surl in varchar2, id in varchar2, p2 in GLBX.MYARRAY );
 procedure del_workflow_set(surl in varchar2, workid in integer, msg in varchar2 default null );
 procedure del_workflow_activity(surl in varchar2, actid in integer, p1 in varchar2, msg in varchar2 default null );
 procedure view_workflow_set(surl in varchar2, workid in integer, msg in varchar2 default null );
 procedure download_objects( surl in varchar2, ppm in integer, p1 in varchar2 default null, p2 in varchar2 default null, msg in varchar2 default null );
 procedure accept_download_objects( surl in varchar2, ppm in integer, p1 in varchar2 default null, p2 in varchar2 default null, action in varchar2, r1 in GLBX.MYARRAY, r2 in GLBX.MYARRAY, r3 in GLBX.MYARRAY, r4 in GLBX.MYARRAY, r5 in GLBX.MYARRAY, r6 in GLBX.MYARRAY );
 procedure view_workflow_details( surl in varchar2, workid in integer, shp in integer, msg in varchar2 default null );
 procedure utility_workflow( surl in varchar2, workid in integer, shp in integer, action in varchar2, msg in varchar2 default null );
 procedure utility_workflow_ext( surl in varchar2, workid in integer, shp in integer, action_step in integer, action in varchar2, p1 in varchar2, msg in varchar2 default null );
 procedure usemap( surl in varchar2, v_umo in integer, acid in integer, msg in varchar2 default null );
 procedure accept_usemap( surl in varchar2, v_umo in integer, acid in integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6 in GLBX.MYARRAY );
 procedure homenews( surl in varchar2, acid in integer, hnw in integer, msg in varchar2 default null );
 procedure accept_homenews( surl in varchar2, acid in varchar2, hnw in integer,
                            p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2, p8 in varchar2,
                            p9 in varchar2, p10 in varchar2, p11 in varchar2, p12 in GLBX.MYARRAY, p13 in varchar2, p14 in varchar2, p14m in varchar2,
                            p15 in varchar2, p16 in varchar2, p17 in varchar2, p18 in varchar2, p19 in varchar2, p20 in varchar2, p21 in varchar2, p22 in varchar2, action in varchar2);
 procedure workflow_chart(surl in varchar2, workid in integer, msg in varchar2 default null );
 procedure meta_screen(surl in varchar2, acid in integer, msg in varchar2 default null);
 procedure edit_meta_screen(surl in varchar2, acid in integer, target in varchar2, msg in varchar2 default null);
 procedure accept_meta_screen(surl in varchar2, acid in integer, target in varchar2,
                              pg1 in GLBX.MYARRAY, pg2 in GLBX.MYARRAY, pg3 in GLBX.MYARRAY, pg4 in GLBX.MYARRAY, pg5 in GLBX.MYARRAY, pg6 in GLBX.MYARRAY,
                              pd0 in GLBX.MYARRAY, pd1 in GLBX.MYARRAY, pd2 in GLBX.MYARRAY, pd3 in GLBX.MYARRAY, pd4 in GLBX.MYARRAY, pd5 in GLBX.MYARRAY, pd6 in GLBX.MYARRAY, pd7 in GLBX.MYARRAY, pd8 in GLBX.MYARRAY, pd9 in GLBX.MYARRAY);
 procedure edit_query(surl in varchar2, acid in integer, target in varchar2, msg in varchar2 default null);
 procedure edit_query_statement(surl in varchar2, acid in integer, target in varchar2, qry in integer, msg in varchar2 default null );
 procedure accept_edit_query_stmt(surl in varchar2, acid in integer, target in varchar2, qry in integer, action in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6 in GLBX.MYARRAY, p7 in GLBX.MYARRAY );
 procedure accept_edit_query( surl in varchar2, acid in integer, target in varchar2, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY );
 procedure accept_defined_screen( surl in varchar2, acid in integer, tgroup in varchar2, called_from in varchar2, callid in integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, action in varchar2 default null, sectionMenu in varchar2 default null, pageMenu in varchar2 default null );
 procedure user_defined_screen( surl in varchar2, acid in integer, tgroup in varchar2, called_from in varchar2, callid in integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY );
 procedure copy_meta_screen( surl in varchar2, acid in integer, newacid in integer, target in varchar2 );
 procedure del_mng_state(surl in varchar2, wsid in integer, p1 in varchar2, spi in integer );
 procedure userfee( surl varchar2, id integer, msg in varchar2 default null );
 procedure accept_userfee( surl varchar2, id integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6 in GLBX.MYARRAY, p7 in GLBX.MYARRAY, p8 in GLBX.MYARRAY, p9 in GLBX.MYARRAY, p10 in GLBX.MYARRAY );
 procedure packprod( surl varchar2, id integer, msg in varchar2 default null );
 procedure accept_packprod( surl varchar2, id integer, p1 in varchar2, p2 in varchar2 );
 procedure package_details( surl varchar2, id in integer, pbit in integer, msg in varchar2 default null );
 procedure accept_package_details( surl varchar2, id integer, pbit in integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );
 procedure phg_online_order(surl in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );

end pbk;

/
