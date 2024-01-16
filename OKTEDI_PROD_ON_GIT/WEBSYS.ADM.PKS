CREATE OR REPLACE package WEBSYS.adm
as

 TYPE myarray 	IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;

 function run_unload_group( nme in integer ) return boolean;
 function generate_help_index return boolean;
 procedure test_page( id in varchar2, msg in varchar2 default null );
 procedure accept_test_page( p1 in varchar2, p2 in varchar2 );
 procedure joshua( id in varchar2 );
 procedure acct_top(surl in varchar2);
 procedure acct_bottom( surl in varchar2, msg in varchar2 );
 procedure acct_logoff(surl in varchar2, msg in varchar2 default null);
 procedure acct_mfc( surl in varchar2, msg in varchar2 default null );
 procedure acct_mfc_leftx(surl in varchar2);
 procedure acct_list_photo( surl varchar2,st in varchar2, typ in varchar2 default LNG.GLB_TXT_076 );
 procedure acct_list_mfc( surl in varchar2, st in varchar2 );
 procedure acct_charge( surl in varchar2, msg in varchar2 default null );
 procedure acct_charge_left(surl in varchar2);
 procedure acct_charge_right( surl in varchar2, id in integer default 0, msg in varchar2 default null );
 procedure accept_charge( surl varchar2, plan_id in integer, p1 in varchar2, p2 in varchar2, p2a in varchar2, p2b in varchar2, p2c in varchar2, p2d in varchar2, pr1 in varchar2, pr2 in varchar2, pr3 in varchar2, pr4 in varchar2,
                          p2e in varchar2, p2n in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2, p8 in varchar2, p9 in varchar2,
                          pa in varchar2, pwda in varchar2, pwdb in varchar2, ev1 in GLBX.MYARRAY, ev2 in GLBX.MYARRAY, ev3 in GLBX.MYARRAY, ev4 in GLBX.MYARRAY, ev5 in GLBX.MYARRAY,
                          ev6 in GLBX.MYARRAY, ev7 in GLBX.MYARRAY, ev8 in GLBX.MYARRAY, ev9 in GLBX.MYARRAY );
 procedure mng_photographer( surl in varchar2, phgid in integer default 0, lc in integer default 0 );
 procedure mng_mfc( surl in varchar2, manid in integer default 0 );
 procedure edit_phg_left( surl in varchar2, phgid in integer );
 procedure edit_mfc_left( surl in varchar2, manid in integer );
 procedure edit_phg_details( surl in varchar2, phgid in integer, msg in varchar2 default null );
 procedure edit_mfc_details( surl in varchar2, manid in integer, msg in varchar2 default null );
 procedure list_all(surl in varchar2);
 procedure accept_phgid( surl varchar2, phgid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p3a in varchar2, p4 in varchar2, pwdexp in varchar2, p5 in varchar2, pskl1 in char default 'F', pskl2 in varchar2,
                         pa in varchar2, p6 in varchar2, p6a in varchar2, p6c in varchar2, p7 in varchar2 default 'F', p8 in varchar2 default 'READ ONLY', pfrn in varchar2 default 'F',
                         p8f in varchar2, p8j in varchar2, p9 in varchar2, peaa in varchar2 default 'F', pcc in varchar2 default 'F', pmax in varchar2, pres in varchar2, rstr in varchar2,
                         pobj in MYARRAY, p9a in MYARRAY , p10 in varchar2, p10a in MYARRAY, p11 in varchar2, p11a in MYARRAY, p12 in MYARRAY, prl in GLBX.MYARRAY, p13 in varchar2 );
 procedure accept_manid( surl in varchar2, manid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, pwdexp in varchar2, p5 in varchar2,
                         p6 in varchar2, pa in varchar2, p7 in GLBX.MYARRAY, p8 in varchar2, p9 in GLBX.MYARRAY, prl in GLBX.MYARRAY, pl in char, p10 in varchar2,
                         p11 in varchar2, p12 in varchar2, pls in GLBX.MYARRAY, p13 in varchar2 );
 procedure mnt_scene(surl in varchar2);
 procedure scene_left(surl in varchar2);
 procedure scene_right( surl in varchar2, scnm in varchar2 default null, msg in varchar2 default null );
 procedure accept_scene( surl in varchar2, scnm in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, a0 in MYARRAY, a1 in MYARRAY, a2 in MYARRAY );
 procedure mnt_prefs( surl in varchar2, msg in varchar2 default null );
 procedure accept_prefs( surl in varchar2, a0 in MYARRAY, a1 in MYARRAY, a2 in MYARRAY, a3 in MYARRAY );
 procedure mnt_conns(surl in varchar2, msg in varchar2 default null, phgid in integer default null );
 procedure disconnect_elapsed( surl in varchar2, ty in varchar2 );
 procedure mnt_table(surl in varchar2, msg in varchar2 default null);
 procedure delete_phg( surl in varchar2, phgid in integer, del in varchar2 );
 procedure delete_mfc( surl in varchar2, manid in integer, del in varchar2 );
 procedure phg_connect_as(surl in varchar2, phgid in integer, typ in varchar2 default 'P');
 procedure mfc_connect_as(surl in varchar2, manid in integer);
 --procedure large_load(surl in varchar2, phgid in integer, acid in integer default null, typ in varchar2 default 'FILE', msg in varchar2 default null);
 procedure edit_phg_orders( surl in varchar2, phgid in integer, isphg in varchar2 default 'F' );
 /*
 procedure accept_large_loadx( surl in varchar2, phgid in integer, typ in varchar2, p1 in varchar2, p2 in GLBX.MYARRAY, p3 in varchar2, p4 in varchar2, penbl in varchar2 default 'F', strorig in varchar2 default 'F', debug in varchar2 default 'F', ftploc in varchar2, objtype in varchar2,
                               p5 in varchar2, p6 in varchar2, p6a in varchar2, p7 in varchar2, p7a in varchar2, p8 in varchar2, p9 in varchar2, p10 in varchar2, load_bad in varchar2 default 'F',
                               p11 in varchar2, p11a in varchar2, p11b in varchar2, p11c in varchar2, p12 in GLBX.MYARRAY, p27 in varchar2, p28 in varchar2, p29 in varchar2, p30 in varchar2, p31 in varchar2 DEFAULT 'FALSE',
                               p40 in varchar2 DEFAULT NULL, p41 in varchar2 DEFAULT 'F', p50 in varchar2, p51 in varchar2, p52 in varchar2, p53 in varchar2, p54 in varchar2, p55 in varchar2);
 procedure accept_large_load( surl in varchar2, phgid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, penbl in varchar2 default 'F', strorig in varchar2 default 'F', debug in varchar2 default 'F', ftploc in varchar2, objtype in varchar2,
                              p5 in varchar2, p6 in varchar2, p6a in varchar2, p7 in varchar2, p7a in varchar2, p8 in varchar2, p9 in varchar2, p10 in varchar2, load_bad in varchar2 default 'F',
                              p11 in varchar2, p11a in varchar2, p11b in varchar2, p11c in varchar2, p12 in varchar2, p27 in varchar2, p28 in varchar2, p29 in varchar2, p30 in varchar2, p31 in varchar2 DEFAULT 'FALSE', global_scene_id in integer default null,
                              p40 in varchar2 DEFAULT NULL, p41 in varchar2 DEFAULT 'F', p42 in varchar2 DEFAULT 'ONLINE');
 */
 procedure adm_acct_orders(surl in varchar2, phgid in integer default null, isphg in varchar2 default 'F');
 procedure order_summary( surl in varchar2, phgid in integer default null, isphg in varchar2 default 'F' );
 procedure order_report(surl varchar2,phgid in integer, acid in integer, yearfrom in varchar2 default '2000', yearto in varchar2 default '2010', monthfrom in varchar2 default LNG.LAB_TXT_073, monthto in varchar2 default LNG.LAB_TXT_084, dayfrom in varchar2 default '01', dayto in varchar2 default '31', brk in varchar2 default 'F', brk2 in varchar2 default 'F', brk3 in varchar2 default 'F', brk4 in varchar2 default null, pname in varchar2 default null, isphg in varchar2 default 'F', roc in varchar2 default 'F');
 procedure generate_stats(surl in varchar2, p1 in varchar2);
 procedure dba_admin(surl in varchar2, msg in varchar2 default null);
 procedure trapped_errors(surl in varchar2, msg in varchar2 default null);
 procedure form_load(surl in varchar2, phgid in integer, msg in varchar2 default null);
 procedure cull_trapped_errors(surl in varchar2, p1 in varchar2);
 procedure mfc_keys(surl in varchar2);
 procedure accept_mfc_keys( surl in varchar2, p1 in myarray, p2 in myarray );
 procedure mfc_photo_size(surl in varchar2);
 procedure accept_photo_size( surl in varchar2, p1 in myarray);
 procedure mfc_frames(surl in varchar2);
 procedure accept_mfc_frames( surl in varchar2, p1 in myarray, p2 in myarray);
 --procedure mfc_forms(surl in varchar2, manid integer);
 --procedure accept_mfc_forms( surl in varchar2, manid integer, p1 in myarray );
 procedure beta_users(surl in varchar2, typ in varchar2 default 'STND', msg in varchar2 default null);
 procedure accept_beta_users( surl in varchar2, id in MYARRAY, ct in MYARRAY, p1 in MYARRAY );
 procedure program_stats(surl in varchar2);
 procedure expire_phg_cust( surl in varchar2, phgid in integer );
 procedure modify_expiry( surl in varchar2, phgid in integer, acid in integer, custype in varchar2 default 'CUSTOMER' );
 procedure accept_modify_expiry( surl varchar2, phgid in integer, acid in integer, p1 in varchar2, p2 in varchar2, p3 in char default 'F', p4 in varchar2, p5 varchar2, p6 in char default 'F', custype in varchar2 );
 procedure unload_defn( surl in varchar2, msg in varchar2 default null );
 procedure unload_defn_leftx(surl in varchar2);
 procedure acct_unload_defn_right( surl in varchar2, gid in integer default 0, tname in varchar2 default null, msg in varchar2 default null );
 procedure accept_unload(surl varchar2,gid in integer, tname in varchar2 default null, p1 in varchar2, p2 in varchar2, p2c in varchar2, p2a in varchar2, p3 in varchar2, p4 in varchar2 default 'F', p5 in varchar2, p6 in varchar2, p7 in varchar2,
                         p8a in varchar2, p8b in varchar2, p8c in varchar2, p9a in varchar2, p9b in varchar2, p3char in char, rp1 in varchar2, rp2 in varchar2, action in varchar2, cp1 in MYARRAY, cp2 in MYARRAY );
 procedure xml_unload(surl in varchar2, typ in varchar2, p1 in varchar2, p2 in varchar2 );
 procedure accept_upload_defn(surl in varchar2, p1 in varchar2, p2 in varchar2 default 'F', p3 in varchar2 default 'F', p4 in varchar2);
 procedure b2c_create(surl in varchar2, phgid in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2 );
 procedure phg_account( surl in varchar2, phid integer, msg in varchar2 );
 procedure accept_mod_phg( surl in varchar2, phid integer, p1 in varchar2, p2 in varchar2, p3 in varchar2 default 'F', p3a in varchar2 default 'F' );
 procedure accept_mod_phg2( surl in varchar2, phid integer, p1 in varchar2, p2 in varchar2, p3 in varchar2 );
 procedure expired_acct(surl in varchar2);
 procedure send_renewal( surl in varchar2, phid integer );
 procedure load_create(surl in varchar2, phgid integer, msg in varchar2 default null);
 procedure storage_manager(surl in varchar2);
 procedure storage_report(surl in varchar2);
 procedure storage_inc(surl in varchar2, typ in varchar2, tot in integer, tot_free in integer );
 procedure accept_storage_inc(surl in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2 );
 procedure stop_piction(surl in varchar2);
 procedure dump_slideshow( surl in varchar2, phgid in integer );
 procedure download_slide( surl in varchar2, p1 in MYARRAY, acid in integer, dirloc in varchar2 );
 procedure form_redirect(surl in varchar2, phgid in integer, msg in varchar2 default null );
 procedure accept_redirect(surl in varchar2, phgid in integer, p1 in varchar2 );
 procedure mnt_redirect(surl in varchar2, msg in varchar2 default null );
 procedure accept_mnt_redirect(surl in varchar2, p1 in MYARRAY, p2 in MYARRAY );
 procedure main_title( surl in varchar2, acct in integer, ttl in varchar2, other_elements in varchar2 default null, style in varchar2 default 'BIG', helpid in varchar2 default null );
 procedure change_password( surl in varchar2, acct in integer, msg in varchar2 default null );
 procedure accept_change_password( surl in varchar2, acct in varchar2, p0 in varchar2 default null, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2 default 'F');
 procedure meta_tags( surl in varchar2, msg in varchar2 default null );
 procedure accept_meta_tags( surl in varchar2, p1 in MYARRAY, p2 in MYARRAY, p2a in MYARRAY, p3 in MYARRAY, p4 in MYARRAY, p5 in MYARRAY, p6 in MYARRAY, p7 in MYARRAY, p8 in MYARRAY, p8a in MYARRAY, p8h in MYARRAY, p9 in MYARRAY, p10 in MYARRAY, p11 in MYARRAY );
 procedure scene_utility( surl in varchar2, scnm in varchar2, typ in varchar2, scid in integer );
 procedure ftp_sites(surl in varchar2, msg in varchar2 default null );
 procedure accept_ftp_sites( surl in varchar2, p1 in MYARRAY, p2 in MYARRAY, p3 in MYARRAY, p4 in MYARRAY );
 procedure admin_accounts( surl in varchar2, msg in varchar2 default null );
 procedure admin_roles(surl in varchar2, msg in varchar2 default null );
 procedure admin_roles_edit(surl in varchar2, rname in varchar2, msg in varchar2 default null );
 procedure accept_admin_roles( surl in varchar2, rname in varchar2, p1 in MYARRAY );
 procedure del_admin( surl in varchar2, acct in varchar2, typ in varchar2 default 'DELETE' );
 procedure delete_role( surl in varchar2, rname in varchar2 );
 procedure mnt_conns_mgmt(surl in varchar2, msg in varchar2 default null );
 procedure disconnect(surl in varchar2, sess_id in integer );
 procedure audit_drill_ls(surl in varchar2, msg in varchar2 default null, drilldate in varchar2 default 'YEAR', drillclient in varchar2 default 'ALL', vdrillclient in varchar2 default null, drillfrom in varchar2 default null, drillto in varchar2 default null, incpurch in varchar2 default 'F', incbar in varchar2 default 'T', aact in varchar2 default 'F' );
 procedure audit_cull( surl in varchar2, msg in varchar2 default null );
 procedure accept_audit_cull( surl in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2);
 procedure restrict_ip( surl in varchar2, msg in varchar2 default null );
 procedure accept_restrict_ip( surl in varchar2, p1 in MYARRAY );
 procedure conv_priv_pub( surl in varchar2, uscid integer, scnm in varchar2 );
 procedure metatg( surl varchar2, id in integer, msg in varchar2 default null );
 procedure accept_metag( surl varchar2, id in integer, p3 in varchar2, p4 in varchar2, p4o in varchar2, p2 in varchar2 default 'F', p5 in varchar2 default 'F', p6 in varchar2 default 'F', p7 in varchar2 default 'F', p8 in varchar2 default 'F', p8h in varchar2 default 'F', p8p in varchar2 default 'F', p8x in varchar2 default 'F',
                         p9 in varchar2, p10 in varchar2, p11 in varchar2, phlp in varchar2, p12s in varchar2 default null, p12u in varchar2 default null, p12i in varchar2 default null, p12d in varchar2 default null );
 procedure meta_tag_exception( surl in varchar2, id in integer default null, msg in varchar2 default null );
 procedure remove_job(surl in varchar2, id in integer);
 procedure mngbatch( surl varchar2, vload_id integer, action in varchar2 );
 procedure dispord(surl in varchar2, purchid in integer, clear_cc in varchar2 default 'FALSE', action in varchar2 default null);
 procedure accept_charge_event(surl varchar2, phid integer, opt1a in varchar2, opt1b in varchar2, opt2a in varchar2, ev1 in GLBX.MYARRAY, ev2 in GLBX.MYARRAY );
 procedure interest_group( surl varchar2, msg in varchar2 default null );
 procedure accept_interest_group( surl varchar2, p1 in MYARRAY, p2 in MYARRAY );
 procedure mfc_form_load(surl varchar2, manid in integer, msg in varchar2 default null);
 procedure vmonitor( surl varchar2, msg in varchar2 default null );
 procedure vmonitor_option( surl varchar2, opt in integer, sqladdr in varchar2 default null, topstmt in varchar2 default '10', ig in varchar2 default 'F', stmtid in integer default null );
 procedure defrep( surl in varchar2, msg in varchar2 default null  );
 procedure mnt_defrep( surl in varchar2, repid in integer, msg in varchar2 default null, ctg in varchar2 default 'GENERIC' );
 procedure accept_mnt_defrep( surl in varchar2, repid in integer, p1 in varchar2, p2 in varchar2, p3 in integer, p4 in varchar2, p_api in varchar2, pra0 in GLBX.MYARRAY, pra in GLBX.MYARRAY, prb in GLBX.MYARRAY, prc in GLBX.MYARRAY, prd in GLBX.MYARRAY, pre in GLBX.MYARRAY, prf in GLBX.MYARRAY, rpa in GLBX.MYARRAY, rpb in GLBX.MYARRAY, rpx in GLBX.MYARRAY );
 procedure brands( surl in varchar2, msg in varchar2 default null  );
 procedure accept_brands( surl varchar2, p1 in MYARRAY, p2 in MYARRAY );
 procedure dict( surl in varchar2, search_term in varchar2 default null, term_type in varchar2 default null, search_number in varchar2 default '100', msg in varchar2 default null );
 procedure accept_dict( surl varchar2, action in varchar2, search_number in varchar2, p1 in varchar2, p2 in GLBX.MYARRAY, p3 in varchar2 default null );
 procedure delete_metatag( surl varchar2, id in integer );
 procedure theme_objects( surl varchar2, ttype in varchar2 );
 procedure accept_theme_objects( surl in varchar2, ttype in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY );
 procedure manage_fonts(surl varchar2, msg in varchar2 default null );
 procedure accept_manage_fonts( surl varchar2, p1 in MYARRAY, p2 in MYARRAY );
 procedure sec_roles( surl in varchar2 );
 procedure role_edit( surl in varchar2, rid in integer, msg in varchar2 default null );
 procedure accept_role_edit( surl in varchar2, rid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, r1 in GLBX.MYARRAY, r2 in GLBX.MYARRAY, r3 in GLBX.MYARRAY, r4 in GLBX.MYARRAY, r5 in GLBX.MYARRAY, r6 in GLBX.MYARRAY, r7 in GLBX.MYARRAY, r8 in GLBX.MYARRAY );
 procedure del_role_edit( surl in varchar2, rid in integer, towner in varchar2, tname in varchar2 );
 procedure manage_report( surl in varchar2, repid in integer, action in varchar2 default 'COPY' );
 procedure mfc_types(surl varchar2, msg in varchar2 default null );
 procedure accept_mfc_types( surl varchar2, p1 in MYARRAY, p2 in MYARRAY );
 procedure preorder_stats(surl varchar2, msg in varchar2 default null );
 procedure preorder_list(surl varchar2, phgid in integer );
 procedure load_stats(surl varchar2, msg in varchar2 default null );
 procedure quick_create(surl in varchar2, msg in varchar2 default null);
 procedure accept_quick_create(surl in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );
 procedure gcertificates(surl varchar2, phgid in integer );
 procedure modify_charge_event( surl in varchar2, phid in integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );
 procedure list_outstanding_invoices( surl in varchar2 );
 procedure gcert_stats( surl varchar2 );
 procedure manage_help(surl varchar2 );
 procedure control_help(surl varchar2, fn in integer );
 procedure class( surl varchar2, msg in varchar2 default null );
 procedure accept_class( surl varchar2, p1 in MYARRAY, p2 in MYARRAY );
 procedure illegal_access(surl varchar2, sorton in varchar2 default '1', cull in varchar2 default null );
 procedure comm(surl varchar2, msg in varchar2 default null );
 procedure comm_table(surl varchar2, tn in varchar2 default null, msg in varchar2 default null );
 procedure comm_table_edit(surl varchar2, tn in varchar2, cn in varchar2, msg in varchar2 default null);
 procedure accept_comm_table(surl varchar2, tn in varchar2, cn in varchar2, p1 in varchar2, action in varchar2);
 procedure comm_utl(surl varchar2, fn in varchar2, msg in varchar2 default null);
 procedure cbo_table(surl varchar2, msg in varchar2 default null );
 procedure chaining(surl varchar2, msg in varchar2 default null );
 procedure projcodes(surl varchar2, msg in varchar2 default null );
 procedure accept_projcodes( surl varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY );
 procedure audit_email_log( surl in varchar2, msg in varchar2 default null );
 procedure currencies( surl in varchar2, msg in varchar2 default null );
 procedure accept_currencies( surl in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY );
 procedure novelties(surl in varchar2, msg in varchar2 default null);
 procedure accept_novelties(surl in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY);
 procedure load_reconcilliation_data( surl varchar2, msg in varchar2 );
 procedure accept_load_reconcilliation( surl in varchar2, file in varchar2, p1 in varchar2, p2 in varchar2 );
 procedure cusobjs( surl varchar2, msg in varchar2 default null );
 procedure otemp( surl varchar2, msg in varchar2 default null );
 procedure otemp_edit( surl varchar2, tname in varchar2, msg in varchar2 default null );
 procedure otemp_edit_util( surl varchar2, tname in varchar2, utl in varchar2, p1 in varchar2 default null );
 procedure otemp_edit_accept( surl varchar2, tname in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );
 procedure zip_unzip(surl varchar2, msg in varchar2 default null );
 procedure accept_zip(surl varchar2, p1 in varchar2, p2 in GLBX.MYARRAY, p3 in char default 'F', p4 in char default 'F', p5 in varchar2 );
 procedure accept_unzip(surl varchar2, p1 in varchar2, p2 in varchar2, p3 in char default 'F' );
 procedure xml_attach_meta(surl varchar2, acid in integer, msg in varchar2 default null);
 procedure accept_xml_attach_meta(surl in varchar2, acid in integer, file in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, action in varchar2 );
 procedure image_load( surl varchar2, phgid in integer, acid in integer, typ in varchar2, usr in varchar2 default 'CUSTOMER', msg in varchar2 default null );
 procedure accept_image_load_load( surl in varchar2, phgid in integer, acid in integer, ltype in varchar2, usr in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY );
 procedure run_load_job( surl in varchar2, vload_id in integer, runfrom in varchar2, p_j in integer default null, p_rsess in integer default null, parallel_range_from in integer default null, parallel_range_to in integer default null );
 procedure mng_ftrs(surl varchar2, src in varchar2 default null, ins in char default 'F', msg in varchar2 default null);
 procedure accept_mng_ftrs(surl varchar2, src in varchar2 default null, vid in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6 in GLBX.MYARRAY, action in varchar2);
 procedure monitor_screen( surl in varchar2, vload_id in integer, trm in char default 'F' );
 procedure dist( surl in varchar2, vload_id in integer );

end adm;
/
