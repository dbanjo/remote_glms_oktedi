CREATE OR REPLACE package WEBSYS.phg
as

 TYPE myarray 	IS TABLE OF VARCHAR2(32767) INDEX BY BINARY_INTEGER;
 TYPE listint 	IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;

 procedure phg_master( surl in varchar2, stype in integer default 1, bplatform in varchar2 default null, bvers in varchar2 default NULL, bos in varchar2 default null, simplesearch in varchar2 default null, v_umo in varchar2 default NULL, v_product_id in varchar2 default null);
 procedure screen_sze( surl in varchar2, simplesearch in varchar2 default null, v_umo in varchar2 default NULL, v_product_id in varchar2 default null);
 procedure readme( surl in varchar2);
 procedure phg_header( surl in varchar2,rnd in integer default 1234);
 procedure phg_accts(surl in varchar2, rnd in integer default 1234, delall in varchar2 default 'F', search_range in varchar2 default '0Z', msg in varchar2 default null);
 procedure phg_accept_preferences( surl in varchar2, acid in integer, p0 in myarray, p1 in myarray );
 procedure phg_acct_master( surl in varchar2, acid in integer, msg in varchar2 default null, profid in integer default null );
 procedure phg_acct_left( surl in varchar2, acid in integer, expanded_scenes in GLBX.MYARRAY, new_nested in varchar2 default null );
 procedure phg_renewal(surl in varchar2,rnd in integer default 1234);
 procedure ack_renewal(surl in varchar2);
 procedure phg_acct_details( surl in varchar2, acid in integer, msg in varchar2 default null, profid in integer default null );
 procedure phg_acct_msg( surl in varchar2, acid in integer, msg in varchar2 );
 procedure phg_utlts_prefs( surl in varchar2, acid in integer, msg in varchar2 default null);
 procedure phg_create_new_acct( surl in varchar2, msg in varchar2 default null);
 procedure tload(surl in varchar2, acid in integer, file in myarray, pname in myarray, scnm in myarray, rid in varchar2, fsz in varchar2, fty in varchar2, cmp in varchar2, kms in varchar2 default 'F', kmx in varchar2 default 'PHOTO', action in varchar2, thcmp in varchar2 default 'STANDARD');
 procedure lload(surl in varchar2, acid in integer, file in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6 in GLBX.MYARRAY, p7 in GLBX.MYARRAY, p8 in GLBX.MYARRAY, imgtype in varchar2, v_umo in integer default null );
 procedure phg_photo_add( surl in varchar2, acid in integer, a1 in myarray );
 procedure phg_disp_by_scene_fm( surl in varchar2, acid in integer, scnm in varchar2 );
 procedure phg_prefs( surl in varchar2, acid in integer, msg in varchar2 default null );
 procedure phg_prefs_txt( surl in varchar2, acid in integer, msg in varchar2 default null );
 procedure phg_prefs_phz( surl in varchar2, acid in integer, msg in varchar2 default null, profid in integer default null );
 procedure phg_prefs_img( surl in varchar2, acid in integer, imgtype in varchar2, msg in varchar2 default null );
 procedure phg_prefs_img_icon( surl in varchar2, acid in integer, imgtype in varchar2, msg in varchar2 default null );
 procedure mnt_resize( surl in varchar2, acid in integer, action in varchar2 default 'MENU', msg in varchar2 default null);
 procedure accept_resize(surl in varchar2, acid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in char default 'F', p6 in char default 'F', action in varchar2);
 procedure accept_prefs_phz( surl in varchar2, acid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2 default 'F', p5 in varchar2, p6 in varchar2, p7 in varchar2, p8 in varchar2 default 'F', profid in integer default null );
 procedure disp_err( surl in varchar2, errcode in varchar2, acid in integer, msg in varchar2, profid in integer default null );
 procedure photo_fast_edit_acct( surl in varchar2, acid in integer, mctr in integer default 1, mwidth in integer default 0, typ in varchar2 default 'SCENE', typval in varchar2 default null, newwin in varchar2 default LNG.PHG_TXT_046 );
 procedure photo_fast_edit_acct_mst( surl in varchar2, acid in integer, mwidth in integer default 0, typ in varchar2 default 'SCENE', typval in varchar2 default null, mctr in integer default null, stype in integer default 1);
 procedure photo_fast_edit_acct_medium( surl in varchar2, acid in integer, mwidth in integer default 0, typ in varchar2 default 'SCENE', typval in varchar2 default null, mctr in integer default null, stype in integer default 1);
 procedure photo_fast_edit_top( surl in varchar2, acid in integer, mwidth in integer default 0, typ in varchar2 default 'SCENE');
 procedure photo_fast_edit_bottom( surl in varchar2, acid in integer, mwidth in integer default 0, typ in varchar2 default 'SCENE');
 procedure accept_fast_edit(surl in varchar2,acid in integer, mctr in integer, mwidth in integer default 1, typ in varchar2, typval in varchar2, p11 in varchar2 default null,
                            p11a in varchar2 default null, p11b in varchar2 default null, p11c in varchar2 default null, newwin in varchar2,
                            a0 in MYARRAY, a1 in MYARRAY, a2 in MYARRAY, a3 in MYARRAY, ar in MYARRAY, rota in MYARRAY, rotb in MYARRAY, rotc in MYARRAY, rotd in MYARRAY, rote in MYARRAY, afc in MYARRAY);
 procedure phg_modify( surl in varchar2, acid in integer, phgid in integer, msg in GLBX.MYARRAY, footer_api in varchar2, left_api_parm in varchar2, current_page_number in varchar2, display_detail in varchar2);
 procedure accept_phg_modify( surl in varchar2, file in varchar2 default NULL, acid in integer, phgid in integer, ftp in varchar2 default null, ftpv in varchar2 default null, c94 in varchar2 default 'T',
                              p1 in varchar2, p2 in varchar2, p3 in varchar2, p3i in varchar2, p3r in varchar2, p3f in varchar2, p3z in varchar2, p3n in varchar2, p3s in varchar2, isglobal in varchar2 default 'F', pricing in varchar2 default 'S',
                              p4 in varchar2 default 'FALSE', p5 in varchar2 default LNG.PHG_TXT_231, p6 in varchar2 default LNG.PHG_TXT_231, p7a in varchar2 default null, p7b in varchar2 default null,
                              p8a in varchar2 default null, p8b in varchar2 default null, p8c in varchar2 default null, p8d in varchar2 default null, prst in varchar2 default 'F', pr9q in varchar2 default '1',
                              p9 in varchar2 default null, p10 in varchar2 default LNG.PHG_TXT_231 , p11 in varchar2 default LNG.PHG_TXT_231, p11a in varchar2 default null, p11b in varchar2 default null, p11c in varchar2 default null, p12 in varchar2 default LNG.PHG_TXT_231, action in varchar2,
                              footer_api in varchar2, left_api_parm in varchar2, current_page_number in varchar2, display_detail in varchar2, gcd in glbx.myarray, gcp in glbx.myarray, tag_id in glbx.myarray, tag_name in glbx.myarray, tag_value in glbx.myarray);
 procedure phg_personal( surl in varchar2, msg in varchar2 default null);
 procedure accept_phg_personal(surl in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p5a in varchar2 default 'F', p5b in varchar2, p6 in varchar2,
                               p7 in varchar2, p8 in varchar2, p9 in varchar2, p10 in varchar2, p4a in varchar2, p4b in varchar2, p11 in varchar2, p12 in varchar2,
                               p13 in varchar2, p14 in varchar2, p15a in varchar2 DEFAULT 'F', p15b in varchar2 DEFAULT 'F', p15c in varchar2 DEFAULT 'F', p15d in varchar2 DEFAULT 'F',
                               p15e in varchar2 DEFAULT 'F', p15f in varchar2 DEFAULT 'F', p15g in varchar2 DEFAULT 'F', p16 in varchar2,
                               p17a in varchar2 DEFAULT 'F', p17b in varchar2 DEFAULT 'F', p17c in varchar2 DEFAULT 'F', p17d in varchar2 DEFAULT 'F', p17e in varchar2 DEFAULT 'F', p18 in varchar2,
                               p19a in varchar2, p19b in varchar2, p19c in varchar2, p11a in varchar2,
                               pmca in varchar2, pmcb in varchar2, pmcc in varchar2, pmcd in varchar2, pmce in varchar2 default 'FALSE', pmcf in varchar2 default 'FALSE');
 procedure customer_logon(surl in varchar2, acid in integer, login_type in varchar2 DEFAULT 'OWNER', profid in integer default NULL);
 procedure phg_stats_prefs( surl in varchar2, acid in integer, msg in varchar2 default null, type in varchar2 default null );
 procedure phg_stat_acct( surl in varchar2, acid in integer );
 procedure phg_stat_all( surl in varchar2, acid in integer );
 procedure phg_stat_cplan( surl in varchar2, acid in integer );
 procedure phg_stat_comment( surl in varchar2, acid in integer );
 procedure phg_stat_guestem( surl in varchar2, acid in integer );
 procedure phg_stat_usage( surl in varchar2, acid in integer );
 procedure phg_stat_gcard( surl in varchar2, acid in integer );
 procedure phg_home(surl in varchar2, acid in integer);
 procedure accept_prefs_thb( surl in varchar2, acid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in char default 'F' );
 procedure phg_prefs_thb( surl in varchar2, acid in integer, msg in varchar2 default null );
 procedure delete_logo( surl in varchar2, acid in integer, v_umo in integer, imgtype in varchar2 );
 procedure private_scenes( surl in varchar2, acid in integer, msg in varchar2 default null);
 procedure accept_private_scenes( surl in varchar2, acid in integer, action in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY);
 procedure delete_account( surl in varchar2, acid in integer, action in varchar2 );
 procedure delete_disabled_photos(surl in varchar2, acid in integer, msg in varchar2 default null);
 procedure accept_delete_disabled_photos( surl in varchar2, acid in integer, p1 in varchar2 default 'F', p2 in varchar2 default 'F', p3 in varchar2 default 'F', p4 in varchar2, p5 in varchar2 default 'F', p6 in varchar2 default 'F', p7 in varchar2 default 'F', p8 in varchar2 default 'F', p9 in varchar2 default 'F', p10 in varchar2 default 'F', ps in varchar2 default 'F', delcategory in varchar2, p3n in varchar2 default 'F' );
 procedure manage_gallery(surl in varchar2, acid in integer,msg in varchar2);
 procedure gallery_top(surl in varchar2, acid in integer, msg in varchar2 default null);
 procedure gallery_bottom(surl in varchar2, acid in integer);
 procedure gallery_load(surl in varchar2, acid in integer, file in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2 default 'F');
 procedure phg_password(surl in varchar2, acid in integer, msg in varchar2 default null);
 procedure phg_mass_ch(surl in varchar2, acid in integer, action in varchar2, msg in varchar2 default null, startover in char default 'F');
 procedure accept_mass_ch( surl in varchar2, acid in integer, typ in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY );
 procedure check_images( surl in varchar2, acid in integer );
 procedure mng_prof_scenes(surl in varchar2, acid in integer, profid in integer, msg in varchar2 default null);
 procedure accept_prof_scenes(surl in varchar2, acid in integer, profid in integer, action in varchar2, p1 in MYARRAY);
 procedure mng_prof_order(surl in varchar2, acid in integer, profid in integer, msg in varchar2 default null);
 procedure accept_prof_order(surl in varchar2, acid in integer, profid in integer, action in varchar2, p1 in MYARRAY, p2 in MYARRAY, p3 in MYARRAY, p4 in MYARRAY, p5 in MYARRAY);
 procedure phg_rename(surl in varchar2, acid in integer, scene in varchar2 default null, msg in varchar2 default null);
 procedure accept_rename(surl in varchar2, acid in integer, scene in varchar2, p1 in MYARRAY, p2 in MYARRAY );
 procedure phg_prefs_img_wm( surl in varchar2, acid in integer, imgtype in varchar2, msg in varchar2 default null );
 procedure scene_utility( surl in varchar2, scnm in varchar2, typ in varchar2, scid in integer, acid in integer );
 procedure phg_move(surl in varchar2, acid in integer, newcust in varchar2 default null, msg in varchar2 default null, pm in varchar2 default 'M', p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY);
 procedure accept_move(surl in varchar2, acid in integer, newcust in integer, scene in varchar2, pm in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY);
 procedure restore_from_backup( surl in varchar2, acid in integer, msg in varchar2 default null );
 procedure accept_restore_from_backup(surl in varchar2, acid in integer, p1 in varchar2 );
 procedure phg_edit_link(surl in varchar2, acid in integer, v_umo in varchar2, msg in varchar2 default null );
 procedure link_control(surl in varchar2, acid in integer, v_umo in varchar2, to_umo in GLBX.MYARRAY, action in varchar2 );
 procedure phg_restore( surl in varchar2, acid in integer );
 procedure isglobal_photos(surl in varchar2, acid in integer, msg in varchar2 default null);
 procedure accept_isglobal_photos( surl in varchar2, acid in integer, p1 in varchar2 default 'F', p2 in varchar2 default 'F', p3 in varchar2 default 'F', p4 in varchar2 default 'F', pub_category in varchar2, priv_category in varchar2 );
 procedure cust_roles( surl in varchar2, acid in integer, msg in varchar2 default null );
 procedure accept_cust_roles( surl in varchar2, acid in integer, p1 in GLBX.MYARRAY );
 procedure phg_statall(surl in varchar2, msg in varchar2 default null);
 procedure map_store(surl in varchar2, acid in integer, msg in varchar2 default null );
 procedure accept_map_store( surl in varchar2, acid in integer, p1 in GLBX.MYARRAY );
 procedure phg_stat_search( surl in varchar2, acid in integer, action in varchar2 default LNG5.EXT_TXT_002 );
 procedure accept_fast_meta(surl in varchar2, acid in integer, mctr in integer, a3 in varchar2, rot in varchar2, mwidth in integer default 1, newwin in varchar2, typ in varchar2, typval in varchar2,
                            p11 in varchar2, p11a in varchar2, p11b in varchar2, a0 in MYARRAY, tag_umo in MYARRAY, tag_id in MYARRAY, tag_name in glbx.myarray, tag_value in MYARRAY );
 procedure meta_tload(surl in varchar2, acid in integer, file in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, v_umo in integer default null, action in varchar2 default null );
 procedure meta_img_load( surl in varchar2, acid in integer, stype  in integer, ltype in varchar2, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, target in char, v_umo in integer default null );
 procedure novelty_access( surl in varchar2, acid in integer, msg in varchar2 default null );
 procedure accept_novelty_access( surl in varchar2, acid in integer, p1 in varchar2, p2 in GLBX.MYARRAY );
 procedure sanity( surl in varchar2, acid in integer, msg in varchar2 default null );
 procedure toggle_meta( surl in varchar2, acid in integer, msg in varchar2 default null );
 procedure accept_toggle_meta( surl in varchar2, acid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2 );
 procedure metatag( surl in varchar2, acid in integer, v_umo in integer, metaload in varchar2 );
 procedure gcard_access( surl in varchar2, acid in integer, msg in varchar2 default null );
 procedure accept_gcard_access( surl in varchar2, acid in integer, p1 in varchar2, p2 in GLBX.MYARRAY );
 procedure eml_temp( surl in varchar2, acid in integer, msg in varchar2 default null );
 procedure accept_eml_temp( surl in varchar2, acid in integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );
 procedure define_eml_temp( surl in varchar2, acid in integer, tmpl in varchar2, action in varchar2, v_pid in integer default null, v_acid in integer default null, v_profile_id in integer default null );

end phg;

/
