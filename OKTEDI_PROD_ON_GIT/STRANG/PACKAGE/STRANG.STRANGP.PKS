CREATE OR REPLACE package STRANG.strangp
as

 TYPE src_rid IS TABLE OF rowid INDEX BY BINARY_INTEGER;

 procedure lov(surl in varchar2, call_name in varchar2, parm in varchar2, lrange in varchar2 default '*', src in varchar2 default null, msg in varchar2 default null, accin varchar2 default 'EDIT', src1 in varchar2 default null );
 procedure accept_lov( surl in varchar2, parm in varchar2, lrange in varchar2, action in varchar2, src in varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, src1 in varchar2 default null );

 procedure receive(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null, vrecctr in varchar2 default null );
 procedure receive_top(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null );
 procedure receive_bottom(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, msg in varchar2 default NULL );
 procedure receive_po(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, msg in varchar2 default NULL );
 procedure accept_receive_po(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer,
                             detrid in varchar2, p0 in varchar2, p1 in varchar2, p2 in varchar2 default null, p3 in varchar2, p4 in varchar2, p5 in varchar2,
                             d3 in varchar2, d4 in varchar2, d5 in varchar2, d6 in varchar2, d7 in varchar2, d8 in varchar2, cancel in varchar2 default null,
                             save_record in varchar2 default null, first_record in varchar2 default null, previous_record in varchar2 default null, next_record in varchar2 default null, last_record in varchar2 default null, insert_record in varchar2 default null, delete_record in varchar2 default null, copy_record in varchar2 default null);
 procedure accept_receive_top( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2, p1 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2, p8 in varchar2, action in varchar2 );
 procedure confirm_delete_detailrs(surl in varchar2, rid in varchar2, scid in varchar2, detrid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, msg in varchar2 default NULL );
 procedure confirm_delete_po(surl in varchar2, rid in varchar2, scid in varchar2, detrid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, msg in varchar2 default NULL );
 procedure accept_delete_detailrs(surl in varchar2, rid in varchar2, scid in varchar2, detrid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer, action in varchar2 );
 procedure accept_delete_po(surl in varchar2, rid in varchar2, scid in varchar2, detrid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer, action in varchar2 );

 procedure accept_receive_detailr(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer,
                                 detrid in varchar2, p1 in varchar2, p2 in varchar2 default null, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2, p8 in varchar2,
                                 a1 in varchar2 default null, d5 in varchar2, d6 in varchar2, d8 in varchar2, cancel in varchar2 default null,
                                 save_record in varchar2 default null, previous_record in varchar2 default null, next_record in varchar2 default null, insert_record in varchar2 default null, delete_record in varchar2 default null, split_record in varchar2 default null);

 procedure split_detailrs(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, msg in varchar2 default NULL );
 procedure accept_split_detailrs(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, action in varchar2, p1 in varchar2, p2 in GLBX.MYARRAY );
 procedure accept_manual_split(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, action in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY );

 procedure movement(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null );
 procedure accept_movement( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, action in varchar2,
                            p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2 default 'F', p5 in varchar2, p6 in varchar2, p7 in varchar2,
                            p8 in varchar2, p9 in varchar2, p10 in varchar2, p11 in varchar2, p12 in varchar2 default '1',
                            px1 in varchar2, px2 in varchar2, px3 in varchar2 );
 procedure mass_movement( surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, nmb in integer, msg in varchar2 default null );
 procedure accept_mass_movement( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY );

 procedure shp(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null );
 procedure shp2(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null );
 procedure accept_shp( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, action in varchar2,
                       p1 in varchar2, p1a in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2,
                       p8 in varchar2, p9 in varchar2, p9m in varchar2, p10 in varchar2, p11 in varchar2, p12 in varchar2, p13 in varchar2, p14 in varchar2, p15 in varchar2 );
 procedure accept_shp2( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, action in varchar2,
                        r1 in varchar2, r2 in varchar2, r3 in varchar2, r4 in varchar2, r5 in varchar2, r5v in varchar2,
                        r6 in varchar2, r7 in varchar2, r8 in varchar2, r9 in varchar2,
                        r10 in varchar2, r11 in varchar2 default null, r12 in varchar2, r13 in varchar2, r14 in varchar2, r15 in varchar2,
                        r16 in varchar2, r17 in varchar2, r18 in varchar2, r19 in varchar2, r20 in varchar2, r21 in varchar2, r22 in varchar2 );
 procedure entry_maintain(surl in varchar2, strt in varchar2, strt2 in varchar2 default null, rid in varchar2, vrecctr in varchar2, msg in varchar2 default null );
 procedure entry_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in GLBX.MYARRAY, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                               v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, errmsg in GLBX.MYARRAY, msg in varchar2 default null );
 procedure accept_entry_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in GLBX.MYARRAY, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                               v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY );
  procedure container_maintain(surl in varchar2, strt in varchar2, strt2 in varchar2 default null, rid in varchar2, vrecctr in varchar2, msg in varchar2 default null );
  procedure container_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in GLBX.MYARRAY, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                                v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, errmsg in GLBX.MYARRAY, msg in varchar2 default null );
  procedure accept_container_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in GLBX.MYARRAY, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                                v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY );
 procedure genduty(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null, action in varchar2 default null );
 procedure confirm_genduty(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null );
 procedure generate_ships_manifest( vship_id varchar2, action in varchar2 default 'LINE_NO', typ in varchar2 default 'SHIP', entryno in integer default null, vste in varchar2 );

 procedure inv(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null );
 procedure accept_inv( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, action in varchar2,
                       p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2, p8 in varchar2,
                       p9 in varchar2, p10 in varchar2, p11 in varchar2, p12 in varchar2, psts in varchar2,
                       r0 in GLBX.MYARRAY, r1 in GLBX.MYARRAY, r2 in GLBX.MYARRAY, r3 in GLBX.MYARRAY, r4 in GLBX.MYARRAY, r5 in GLBX.MYARRAY, r6 in GLBX.MYARRAY, r7 in GLBX.MYARRAY,
                       g0 in GLBX.MYARRAY, g1 in GLBX.MYARRAY, g2 in GLBX.MYARRAY, g3 in GLBX.MYARRAY, g4 in GLBX.MYARRAY, g5 in GLBX.MYARRAY, g6 in GLBX.MYARRAY);
 procedure inv2(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null );
 procedure accept_inv2( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, action in varchar2,
                        r0 in GLBX.MYARRAY, r1 in GLBX.MYARRAY, r2 in GLBX.MYARRAY, r3 in GLBX.MYARRAY, r4 in GLBX.MYARRAY, r5 in GLBX.MYARRAY, r6 in GLBX.MYARRAY );

 procedure edit_mawb( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, mwb in varchar2 default null, msg in varchar2 default null );
 procedure accept_edit_mawb( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, p0 in varchar2, p1 in varchar2, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY );
 procedure edit_mawb_ecn( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, mwb in varchar2 default null, msg in varchar2 default null );
 procedure accept_edit_mawb_ecn( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, p0 in varchar2, p1 in varchar2, action in varchar2, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY );
 procedure edit_bol( surl in varchar2, rid in varchar2, rid2 in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, shpid in varchar2 default null, msg in varchar2 default null );
 procedure accept_edit_bol( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, rid2 in varchar2, p0 in varchar2, p1 in varchar2, action in varchar2, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY );
 procedure edit_ecn( surl in varchar2, rid in varchar2, rid2 in varchar2 default null, scid in varchar2, parm in varchar2, access_id in varchar2 default null, shpid in varchar2 default null, msg in varchar2 default null );
 procedure accept_edit_ecn( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, rid2 in varchar2, p0 in varchar2, p1 in varchar2, action in varchar2, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY );

 procedure assign_det( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null, fl in varchar2, lcl in varchar2 default 'F' );
 procedure accept_assign_det( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, action in varchar2, fl in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );

 procedure cascade_movement( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, oldid in varchar2, oldseal in varchar2, mtype in varchar2, msg in varchar2 default null );
 procedure accept_cascade_movement( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2, mtype in varchar2, old_movement in varchar2, old_seal in varchar2 default null, new_movement in varchar2, new_seal in varchar2 default null);

 procedure menu( surl in varchar2, rnd in varchar2, mtype in varchar2, msearch in varchar2 default null, action in varchar2 default 'SEARCH', rid in varchar2 default null );
 procedure duty_edit(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null );

 procedure duty_edit(surl in varchar2, entry in integer );
 procedure accept_duty( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, action in varchar2, p1 in varchar2, p2 in varchar2 );
 procedure invoke_report( surl in varchar2, repname in varchar2, r1 in varchar2 default null, r2 in varchar2 default null, r3 in varchar2 default null );
 procedure mng_cust( surl in varchar2, rid in varchar2 default null, id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null, scid in varchar2 default null, access_id in varchar2 default null );
 procedure accept_mng_cust( surl in varchar2, rid in varchar2, p1 in varchar2 default null, p2 in varchar2 default null, p3 in varchar2 default null, p4 in varchar2 default null,
                            p5 in varchar2 default null, p6 in varchar2 default null, p7 in varchar2 default null, p8 in varchar2 default null, p9 in varchar2 default null,
                            p10 in varchar2 default null, p11 in varchar2 default null, p12 in varchar2 default null, p13 in varchar2 default null, p14 in varchar2 default null, action in varchar2 );
 procedure mng_charge( surl in varchar2, rid in varchar2 default null, id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null );
 procedure accept_mng_charge( surl in varchar2, rid in varchar2, p1 in varchar2 default null, p2 in varchar2 default null, p3 in varchar2 default null, p4 in varchar2 default null,
                              p5 in varchar2 default null, p6 in varchar2 default null, p7a in varchar2, p7b in varchar2, p7c in varchar2, action in varchar2 );
 procedure hotsync( surl in varchar2 );
 procedure accept_hotsync( surl in varchar2, p2 in varchar2, p3 in varchar2 default NULL, p4 in varchar2 default 'F', p5 in varchar2 default null, p6 in varchar2 default 'F', p7 in varchar2 default 'F', p8 in varchar2 default 'F' );
 procedure assign_hawb( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null );
 procedure edit_ecn_log( surl in varchar2, lg in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, msg in varchar2 default null );
 procedure accept_edit_ecn_log( surl in varchar2, lg in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, action in varchar2, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY );
 procedure analyse_hotsync( surl in varchar2 );
 procedure check_dupl(surl in varchar2, tname in varchar2, cname in varchar2, pkcol1 in varchar2, pkcol2 in varchar2 );
 procedure delete_dupl(surl in varchar2, tname in varchar2, rw in varchar2 );
 procedure accept_trac_search( surl in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2 );
 procedure manentry(surl in varchar2, rid in varchar2 default null, scid in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null, access_id in varchar2 default null, msg in varchar2 default null, id in varchar2 default null );
 procedure accept_manentry(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, old_entry in varchar2, entryno in varchar2, access_id in varchar2 default null, action in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );
 procedure manentry_page2(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null );
 procedure accept_manentry_page2(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, old_entry in varchar2, access_id in varchar2 default null, action in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );
 procedure manentry_page3(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null );
 procedure accept_manentry_page3(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, old_entry in varchar2, access_id in varchar2 default null, action in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );
 procedure confirm_manentry_delete(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null );
 procedure accept_manentry_delete(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, old_entry in varchar2, access_id in varchar2 default null, action in varchar2 );
 procedure recalc_weight( mvid varchar2, ctrtype varchar2 default null, sl in varchar2 default null, mtype in varchar2 default null );
 procedure do_download_gl( vdir in varchar2 default null, fname in varchar2 default null, frm in varchar2 default null, fto in varchar2 default null, run_once in char default 'F' );
 procedure start_batch_job;
 procedure stop_batch_job;
 procedure mng_ctr( surl in varchar2, rid in varchar2 default null, id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null );
 procedure accept_mng_ctr( surl in varchar2, rid in varchar2, id in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2 default null, p8 in varchar2, p9 in varchar2 default null, p10 in varchar2, p11 in varchar2, p12 in varchar2, action in varchar2 );
 procedure confirm_ctr_delete(surl in varchar2, rid in varchar2);
 procedure accept_ctr_delete(surl in varchar2, rid in varchar2, action in varchar2 );
 procedure mng_categories( surl in varchar2, rid in varchar2 default null, id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null );
 procedure accept_mng_categories( surl in varchar2, rid in varchar2, id in varchar2, p1 in varchar2 default null, p2 in varchar2 default null, p3 in varchar2 default null, p4 in varchar2 default null, p5 in varchar2, p6 in varchar2, p7 in varchar2, p8 in varchar2, action in varchar2 );
 procedure mng_onlocs( surl in varchar2, id in varchar2 );
 procedure mng_onlocs( surl in varchar2, arr_rid in src_rid, id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null );
 procedure onlocs_del( surl in varchar2, rid in varchar2 );
 procedure accept_mng_onlocs( Surl in varchar2, arr_rid in glbx.myarray, id in varchar2, p1 in glbx.myarray, p2 in glbx.myarray, p3 in glbx.myarray, p4 in glbx.myarray, p5 in glbx.myarray, p6 in glbx.myarray, p7 in glbx.myarray, p8 in glbx.myarray, p9 in glbx.myarray, action in varchar2 );
 procedure mng_offlocs( surl in varchar2, id in varchar2 );
 procedure mng_offlocs( surl in varchar2, arr_rid in src_rid, id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null );
 procedure offlocs_del( surl in varchar2, rid in varchar2 );
 procedure accept_mng_offlocs( Surl in varchar2, arr_rid in glbx.myarray, id in varchar2, p1 in glbx.myarray, p2 in glbx.myarray, p3 in glbx.myarray, p4 in glbx.myarray, p5 in glbx.myarray, p6 in glbx.myarray, p7 in glbx.myarray, p8 in glbx.myarray, p9 in glbx.myarray, action in varchar2 );
 procedure ctr_menu( surl in varchar2 );
 procedure ctr_track( surl in varchar2, rid in varchar2 default null, id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null );
 procedure accept_ctr_track( surl in varchar2, rid in varchar2, p1 in glbx.myarray, p2 in glbx.myarray, p3 in glbx.myarray, p4 in glbx.myarray, action in varchar2 );
 procedure ctrdel( surl in varchar2, sno in varchar2, rn in varchar2 );
 function data_access( acid in integer, typ in varchar2, rid in rowid, ext in varchar2 default null ) return varchar2;

procedure delivery_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in GLBX.MYARRAY, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                              v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, errmsg in GLBX.MYARRAY, msg in varchar2 default null );
procedure accept_delivery_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in GLBX.MYARRAY, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                              v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY );

end strangp;
/
