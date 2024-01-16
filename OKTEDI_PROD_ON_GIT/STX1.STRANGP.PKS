CREATE OR REPLACE package STX1.strangp
as

 TYPE src_rid IS TABLE OF rowid INDEX BY BINARY_INTEGER;

 empty_array		owa.vc_arr;
 G_ERR			varchar2(1000); -- used in validate time
 ENABLE_OLD_OPTIONS	boolean;
 G_ROWS			constant integer		:= 20;

 procedure lov(surl in varchar2, call_name in varchar2, parm in varchar2, lrange in varchar2 default '*', src in varchar2 default null, msg in varchar2 default null, accin varchar2 default 'EDIT', src1 in varchar2 default null, is_popup in char default 'T' );
 procedure accept_lov( surl in varchar2, parm in varchar2, lrange in varchar2, action in varchar2, src in varchar2, p0 in owa.vc_arr default strangp.empty_array, p1 in owa.vc_arr default strangp.empty_array, p2 in owa.vc_arr default strangp.empty_array, p3 in owa.vc_arr default strangp.empty_array, p4 in owa.vc_arr default strangp.empty_array, p5 in owa.vc_arr default strangp.empty_array,p5d in owa.vc_arr default strangp.empty_array,p5e in owa.vc_arr default strangp.empty_array,p5f in owa.vc_arr default strangp.empty_array, p5g in owa.vc_arr default strangp.empty_array, p5h in owa.vc_arr default strangp.empty_array, p5i in owa.vc_arr default strangp.empty_array, p5j in owa.vc_arr default strangp.empty_array, src1 in varchar2 default null, is_popup in char default 'T' );

 procedure trac_search( surl in varchar2, msg in varchar2 default null );
 procedure receive(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null, vrecctr in varchar2 default null, norder in varchar2 default null, n_local in char default 'L', rows_show in integer default null );
 procedure receive_single(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null, vrecctr in varchar2 default null, norder in varchar2 default null, n_local in char default 'L' );
 procedure receive_top(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null, norder in varchar2 default null, n_local in char default 'L' );
 procedure receive_bottom(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, msg in varchar2 default NULL, force_single_disp in char default 'F', popup in char default 'F' );
 procedure receive_po(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, msg in varchar2 default NULL, force_single_disp in char default 'F', popup in char default 'F' );
 procedure accept_receive_po( num_entries in number, name_array in owa.vc_arr, value_array in owa.vc_arr, reserved in owa.vc_arr );
 procedure accept_receive_top( surl in varchar2, rid in owa.vc_arr, scid in varchar2, parm in varchar2, access_id in varchar2, p1 in owa.vc_arr, p3 in owa.vc_arr, p4 in owa.vc_arr, p5 in owa.vc_arr, p6 in owa.vc_arr, p8 in owa.vc_arr, p3n in owa.vc_arr, action in varchar2, norder in varchar2 default null, n_local in char default 'L' );
 procedure ost_185_screen(surl in varchar2, action in varchar2 default 'NEW', msg in varchar default null);
 procedure ost_185_batch(surl in varchar2, msg in varchar default null);
 procedure accept_ost_185_batch( surl in varchar2, job_name in varchar2, p1 in varchar2, p2 in varchar2, action in varchar2 default 'CANCEL');
 procedure generate_ost185( surl in varchar2, vtoday in date, is_batch in varchar2 default 'FALSE' );
 procedure confirm_delete_detailrs(surl in varchar2, rid in varchar2, scid in varchar2, detrid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, msg in varchar2 default NULL, force_single_disp in char default 'F', popup in char default 'F' );
 procedure confirm_delete_po(surl in varchar2, rid in varchar2, scid in varchar2, detrid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, msg in varchar2 default NULL, force_single_disp in char default 'F', popup in char default 'F' );
 procedure accept_delete_detailrs(surl in varchar2, rid in varchar2, scid in varchar2, detrid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer, action in varchar2, force_single_disp in char default 'F', popup in char default 'F' );
 procedure accept_delete_po(surl in varchar2, rid in varchar2, scid in varchar2, detrid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer, action in varchar2, force_single_disp in char default 'F', popup in char default 'F' );

 procedure accept_receive_detailr( num_entries in number, name_array in owa.vc_arr, value_array in owa.vc_arr, reserved in owa.vc_arr );

 procedure split_detailrs(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, msg in varchar2 default NULL, force_single_disp in char default 'F', popup in char default 'F' );
 procedure accept_split_detailrs(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, action in varchar2, p1 in varchar2, p2 in owa.vc_arr, force_single_disp in char default 'F', popup in char default 'F' );
 procedure accept_manual_split(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, action in varchar2, p1 in owa.vc_arr, p2 in owa.vc_arr, p3 in owa.vc_arr, force_single_disp in char default 'F', popup in char default 'F');

 procedure movement(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null, xtra1 in varchar2 default null, xtra2 in varchar2 default null, xtra3 in varchar2 default null, rows_show in integer default G_ROWS, norder in varchar2 default null, n_local in char default 'L', force_single_disp in char default 'F' );
 procedure accept_movement( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, action in varchar2,
                            p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2 default 'F', p5 in varchar2, p5i in varchar2, p6i in varchar2, p6 in varchar2, p7 in varchar2,
                            p8 in varchar2, p9 in varchar2, p10 in varchar2, p10a in varchar2, p11 in varchar2, p12 in varchar2 default '1',
                            px1 in varchar2, px2 in varchar2, px3 in varchar2, pp in varchar2, cp in varchar2,
                            cv1 in varchar2  default null, cv2 in  varchar2 default null, cv3 in  varchar2 default null, cv4 in  varchar2 default null, cv5 in  varchar2 default null, cv6 in  varchar2 default null, cv7  in varchar2 default null, cv8 in  varchar2 default null, cv9 in  varchar2 default null, cv10 in varchar2 default null,
                            cv11 in varchar2 default null, cv12 in varchar2 default null, cv13 in varchar2 default null, cv14 in varchar2 default null, cv15 in varchar2 default null, cv16 in varchar2 default null, cv17 in varchar2 default null, cv18 in varchar2 default null, cv19 in varchar2 default null, cv20 in varchar2 default null,
                            cv21 in varchar2 default null, cv22 in varchar2 default null, cv23 in varchar2 default null, cv24 in varchar2 default null, cv25 in varchar2 default null, cv26 in varchar2 default null, cv27 in varchar2 default null, cv28 in varchar2 default null, cv29 in varchar2 default null, cv30 in varchar2 default null,
                            cv31 in varchar2 default null, cv32 in varchar2 default null, cv33 in varchar2 default null, cv34 in varchar2 default null, cv35 in varchar2 default null, cv36 in varchar2 default null, cv37 in varchar2 default null, cv38 in varchar2 default null, cv39 in varchar2 default null, cv40 in varchar2 default null,
                            cv41 in varchar2 default null, cv42 in varchar2 default null, cv43 in varchar2 default null, cv44 in varchar2 default null, cv45 in varchar2 default null, cv46 in varchar2 default null, cv47 in varchar2 default null,
			    xtra1 in varchar2 default null, xtra2 in varchar2 default null, xtra3 in varchar2 default null, rows_show in integer default G_ROWS, norder in varchar2 default null, n_local in char default 'L', force_single_disp in char default 'F'
                           );
 procedure mass_movement( surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, nmb in integer, msg in varchar2 default null );
 procedure accept_mass_movement( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, p1 in owa.vc_arr, p2 in owa.vc_arr, p3 in owa.vc_arr, p4 in owa.vc_arr, p5 in owa.vc_arr );
 procedure shp(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, vdef in char default 'S', mtype in varchar2 default null, rows_show in integer default G_ROWS, norder in varchar2 default null, n_local in char default 'L', force_single_disp in char default 'F', xtra1 in varchar2 default 'ALL' );
 procedure accept_shp( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, action in varchar2,
                       p1 in varchar2, p1a in varchar2, p2 in varchar2, p3 in varchar2, p3i in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2,
                       p8 in varchar2, p9 in varchar2, p9m in varchar2, p10 in varchar2, p11 in varchar2, p12 in varchar2, p13 in varchar2, p14 in varchar2, p15 in varchar2, p16 in varchar2,
                       pc1 in varchar2 default null, pc2 in varchar2 default null, pc3 in varchar2 default null, pc4 in varchar2 default null,
                       pconv1 in varchar2 default null, pconv2 in varchar2 default null, pconv3 in varchar2 default null, pconv4 in varchar2 default null, pconv5 in varchar2 default null,
                       pconv6 in varchar2 default null, pconv7 in varchar2 default null, pconv8 in varchar2 default null, pconv9 in varchar2 default null, pconv10 in varchar2 default null,
                       pconv11 in varchar2 default null, pconv12 in varchar2 default null, pconv13 in varchar2 default null, pconv14 in varchar2 default null, pconv15 in varchar2 default null,
                       pconv16 in varchar2 default null, pconv17 in varchar2 default null, pconv18 in varchar2 default null, pconv19 in varchar2 default null, pconv20 in varchar2 default null,
                       pconv21 in varchar2 default null, pconv22 in varchar2 default null, pconv23 in varchar2 default null, pconv24 in varchar2 default null, pconv25 in varchar2 default null,
                       pconv26 in varchar2 default null, pconv27 in varchar2 default null, pconv28 in varchar2 default null, pconv29 in varchar2 default null, pconv30 in varchar2 default null,
                       pconv31 in varchar2 default null, pconv32 in varchar2 default null, pconv33 in varchar2 default null, pconv34 in varchar2 default null, pconv35 in varchar2 default null,
                       pconv36 in varchar2 default null, pconv37 in varchar2 default null, pconv38 in varchar2 default null, pconv39 in varchar2 default null, pconv40 in varchar2 default null,
                       pconv41 in varchar2 default null, pconv42 in varchar2 default null, pconv43 in varchar2 default null, pconv44 in varchar2 default null, pconv45 in varchar2 default null,
                       mtype in varchar2 default null, rows_show in integer default G_ROWS, norder in varchar2 default null, n_local in char default 'L', force_single_disp in char default 'F', xtra1 in varchar2 default 'ALL'
                      );
 procedure accept_shp_mass( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, action in varchar2,mtype in varchar2 default null, rows_show in integer default G_ROWS, norder in varchar2 default null, n_local in char default 'L', force_single_disp in char default 'F', xtra1 in varchar2 default 'ALL',
                            p1 in owa.vc_arr, p2 in owa.vc_arr, p3 in owa.vc_arr, p4 in owa.vc_arr, p5 in owa.vc_arr, ridarr in owa.vc_arr );
 procedure entry_maintain(surl in varchar2, strt in varchar2, strt2 in varchar2 default null, rid in varchar2, vrecctr in varchar2, msg in varchar2 default null, force_single_disp in char default 'F', popup in char default 'F' );
 procedure entry_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in owa.vc_arr, pk2 in owa.vc_arr, pk3 in owa.vc_arr,
                               v1 in owa.vc_arr, v2 in owa.vc_arr, v3 in owa.vc_arr, v4 in owa.vc_arr, v5 in owa.vc_arr, v6 in owa.vc_arr, v7 in owa.vc_arr, v8 in owa.vc_arr, v1i in owa.vc_arr, v8i in owa.vc_arr, v8ii in owa.vc_arr, errmsg in owa.vc_arr, msg in varchar2 default null, force_single_disp in char default 'F', popup in char default 'F' );
 procedure accept_entry_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in owa.vc_arr, pk2 in owa.vc_arr, pk3 in owa.vc_arr,
                               v1 in owa.vc_arr, v2 in owa.vc_arr, v3 in owa.vc_arr, v4 in owa.vc_arr, v5 in owa.vc_arr, v6 in owa.vc_arr, v7 in owa.vc_arr, v8 in owa.vc_arr, v1i in owa.vc_arr, v8i in owa.vc_arr, v8ii in owa.vc_arr, force_single_disp in char default 'F', popup in char default 'F' );
  procedure po_item_no_maintain(surl in varchar2, strt in varchar2, strt2 in varchar2 default null, rid in varchar2, vrecctr in varchar2, msg in varchar2 default null, force_single_disp in char default 'F', popup in char default 'F' );
  procedure poitemno_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk2 in owa.vc_arr, pk3 in owa.vc_arr,
                                v1 in owa.vc_arr, v2 in owa.vc_arr, v9 in owa.vc_arr, v3_1 in owa.vc_arr, v3_1_1 in owa.vc_arr, v3_2 in owa.vc_arr, v3 in owa.vc_arr, v4 in owa.vc_arr, v5 in owa.vc_arr, v6 in owa.vc_arr, v7 in owa.vc_arr, v8 in owa.vc_arr, v1i in owa.vc_arr, v8i in owa.vc_arr, v9i in owa.vc_arr, errmsg in owa.vc_arr, msg in varchar2 default null, force_single_disp in char default 'F', popup in char default 'F' );
  procedure accept_poitemno_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk2 in owa.vc_arr, pk3 in owa.vc_arr,
                                v1 in owa.vc_arr, v2 in owa.vc_arr, v9 in owa.vc_arr, v3_1 in owa.vc_arr, v3_1_1 in owa.vc_arr, v3_2 in owa.vc_arr, v3 in owa.vc_arr, v4 in owa.vc_arr, v5 in owa.vc_arr, v6 in owa.vc_arr, v7 in owa.vc_arr, v8 in owa.vc_arr, v1i in owa.vc_arr, v8i in owa.vc_arr, v9i in owa.vc_arr, force_single_disp in char default 'F', popup in char default 'F' );
-- 20160615
  procedure po_inventory_maintain(surl in varchar2, strt in varchar2, rid in varchar2, vrecctr in varchar2, msg in varchar2 default null, force_single_disp in char default 'F', popup in char default 'F' );
  procedure poinventory_maintain_mass(surl in varchar2, p1 in varchar2, rid in varchar2, vrecctr in varchar2, pk2 in owa.vc_arr, pk3 in owa.vc_arr,
                                v1 in owa.vc_arr, v2 in owa.vc_arr, v9 in owa.vc_arr, v3_1 in owa.vc_arr, v3_1_1 in owa.vc_arr, v3_2 in owa.vc_arr, v3 in owa.vc_arr, v4 in owa.vc_arr, v5 in owa.vc_arr, v6 in owa.vc_arr, v7 in owa.vc_arr, v8 in owa.vc_arr, v1i in owa.vc_arr, v8i in owa.vc_arr, errmsg in owa.vc_arr, msg in varchar2 default null, force_single_disp in char default 'F', popup in char default 'F' );
  procedure accept_poinvent_maintain_mass(surl in varchar2, p1 in varchar2, rid in varchar2, vrecctr in varchar2, pk2 in owa.vc_arr, pk3 in owa.vc_arr,
                                v1 in owa.vc_arr, v2 in owa.vc_arr, v9 in owa.vc_arr, v3_1 in owa.vc_arr, v3_1_1 in owa.vc_arr, v3_2 in owa.vc_arr, v3 in owa.vc_arr, v4 in owa.vc_arr, v5 in owa.vc_arr, v6 in owa.vc_arr, v7 in owa.vc_arr, v8 in owa.vc_arr, v1i in owa.vc_arr, v8i in owa.vc_arr, force_single_disp in char default 'F', popup in char default 'F' );
--20160615
-- 20160714
  procedure po_inventdate_maintain(surl in varchar2, strt in varchar2, rid in varchar2, vrecctr in varchar2, msg in varchar2 default null, force_single_disp in char default 'F', popup in char default 'F' );
  procedure poinvdte_maintain_mass(surl in varchar2, p1 in varchar2,  p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk2 in owa.vc_arr, pk3 in owa.vc_arr,
                                v1 in owa.vc_arr, v2 in owa.vc_arr, v9 in owa.vc_arr, v3_1 in owa.vc_arr, v3_1_1 in owa.vc_arr, v3_2 in owa.vc_arr, v3 in owa.vc_arr, v4 in owa.vc_arr, v5 in owa.vc_arr, v6 in owa.vc_arr, v7 in owa.vc_arr, v8 in owa.vc_arr, v1i in owa.vc_arr, v8i in owa.vc_arr, errmsg in owa.vc_arr, msg in varchar2 default null, force_single_disp in char default 'F', popup in char default 'F' );
  procedure accept_poinvdte_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk2 in owa.vc_arr, pk3 in owa.vc_arr,
                                v1 in owa.vc_arr, v2 in owa.vc_arr, v9 in owa.vc_arr, v3_1 in owa.vc_arr, v3_1_1 in owa.vc_arr, v3_2 in owa.vc_arr, v3 in owa.vc_arr, v4 in owa.vc_arr, v5 in owa.vc_arr, v6 in owa.vc_arr, v7 in owa.vc_arr, v8 in owa.vc_arr, v1i in owa.vc_arr, v8i in owa.vc_arr, force_single_disp in char default 'F', popup in char default 'F' );
--20160714

 procedure container_maintain(surl in varchar2, strt in varchar2, strt2 in varchar2 default null, rid in varchar2, vrecctr in varchar2, msg in varchar2 default null, force_single_disp in char default 'F', popup in char default 'F' );
 procedure container_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in owa.vc_arr, pk2 in owa.vc_arr, pk3 in owa.vc_arr,
                               v1 in owa.vc_arr, v2 in owa.vc_arr, v3 in owa.vc_arr, v4 in owa.vc_arr, v5 in owa.vc_arr, v6 in owa.vc_arr, v7 in owa.vc_arr, v8 in owa.vc_arr, v1i in owa.vc_arr, v8i in owa.vc_arr, v8ii in owa.vc_arr, v9 in owa.vc_arr, v9i in owa.vc_arr, v10 in owa.vc_arr, errmsg in owa.vc_arr, msg in varchar2 default null, force_single_disp in char default 'F', popup in char default 'F' );
 procedure accept_container_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in owa.vc_arr, pk2 in owa.vc_arr, pk3 in owa.vc_arr,
                               v1 in owa.vc_arr, v2 in owa.vc_arr, v3 in owa.vc_arr, v4 in owa.vc_arr, v5 in owa.vc_arr, v6 in owa.vc_arr, v7 in owa.vc_arr, v8 in owa.vc_arr, v1i in owa.vc_arr, v8i in owa.vc_arr, v8ii in owa.vc_arr, v9 in owa.vc_arr, v9i in owa.vc_arr, v10 in owa.vc_arr, force_single_disp in char default 'F', popup in char default 'F' );
 procedure log_maintain(surl in varchar2, strt in varchar2, rid in varchar2, vrecctr in varchar2, msg in varchar2 default null, force_single_disp in char default 'F', popup in char default 'F' );
 procedure log_maintain_mass(surl in varchar2, p1 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in owa.vc_arr, pk2 in owa.vc_arr, pk3 in owa.vc_arr,
                               v1 in owa.vc_arr, v2 in owa.vc_arr, v3 in owa.vc_arr, v4 in owa.vc_arr, v5 in owa.vc_arr, v6 in owa.vc_arr, v7 in owa.vc_arr, v8 in owa.vc_arr, v1i in owa.vc_arr, v8i in owa.vc_arr, v8ii in owa.vc_arr, v9 in owa.vc_arr, v9i in owa.vc_arr, v10 in owa.vc_arr, errmsg in owa.vc_arr, msg in varchar2 default null, force_single_disp in char default 'F', popup in char default 'F' );
 procedure accept_log_maintain_mass(surl in varchar2, p1 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in owa.vc_arr, pk2 in owa.vc_arr, pk3 in owa.vc_arr,
                               v1 in owa.vc_arr, v2 in owa.vc_arr, v3 in owa.vc_arr, v4 in owa.vc_arr, v5 in owa.vc_arr, v6 in owa.vc_arr, v7 in owa.vc_arr, v8 in owa.vc_arr, v1i in owa.vc_arr, v8i in owa.vc_arr, v8ii in owa.vc_arr, v9 in owa.vc_arr, v9i in owa.vc_arr, v10 in owa.vc_arr, force_single_disp in char default 'F', popup in char default 'F' );
 procedure genduty(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null, action in varchar2 default null );
 procedure confirm_genduty(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null );
 procedure generate_ships_manifest( vship_id varchar2, action in varchar2 default 'LINE_NO', typ in varchar2 default 'SHIP', entryno in number default null, vste in varchar2 );

 procedure inv(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null );
 procedure accept_inv( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, action in varchar2,
                      p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2, p8 in varchar2,
                      p9 in varchar2, p10 in varchar2, p11 in varchar2, p12 in varchar2, psts in varchar2,
                      r0 in owa.vc_arr, r1 in owa.vc_arr, r2 in owa.vc_arr, r3 in owa.vc_arr, r4 in owa.vc_arr, r5 in owa.vc_arr, r6 in owa.vc_arr, r7 in owa.vc_arr,
                      g0 in owa.vc_arr, g1 in owa.vc_arr, g2 in owa.vc_arr, g3 in owa.vc_arr, g4 in owa.vc_arr, g5 in owa.vc_arr, g6 in owa.vc_arr);
 procedure inv2(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null );
 procedure accept_inv2( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, action in varchar2,
                        r0 in owa.vc_arr, r1 in owa.vc_arr, r2 in owa.vc_arr, r3 in owa.vc_arr, r4 in owa.vc_arr, r5 in owa.vc_arr, r6 in owa.vc_arr );

 procedure edit_mawb( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, mwb in varchar2 default null, msg in varchar2 default null );
 procedure accept_edit_mawb( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, p0 in varchar2, p1 in varchar2, p2 in owa.vc_arr, p3 in owa.vc_arr, p4 in owa.vc_arr, p5 in owa.vc_arr );
 procedure edit_mawb_ecn( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, mwb in varchar2 default null, msg in varchar2 default null );
 procedure accept_edit_mawb_ecn( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, p0 in varchar2, p1 in varchar2, action in varchar2, p2 in owa.vc_arr, p3 in owa.vc_arr, p3i in owa.vc_arr );
 procedure edit_bol( surl in varchar2, rid in varchar2, rid2 in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, shpid in varchar2 default null, msg in varchar2 default null );
 procedure accept_edit_bol( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, rid2 in varchar2, p0 in varchar2, p1 in varchar2, action in varchar2, p2 in owa.vc_arr, p3a in owa.vc_arr, p3 in owa.vc_arr );
 procedure edit_ecn( surl in varchar2, rid in varchar2, rid2 in varchar2 default null, scid in varchar2, parm in varchar2, access_id in varchar2 default null, shpid in varchar2 default null, msg in varchar2 default null );
 procedure accept_edit_ecn( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, rid2 in varchar2, p0 in varchar2, p1 in varchar2, action in varchar2, p2 in owa.vc_arr, p3 in owa.vc_arr, p3i in owa.vc_arr );

 procedure assign_det( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null, fl in varchar2, lcl in varchar2 default 'F', ispopup in char default 'F' );
 procedure accept_assign_det( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, action in varchar2, fl in varchar2, p1 in owa.vc_arr, p2 in owa.vc_arr, ispopup in char default 'F' );

 procedure cascade_movement( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, oldid in varchar2, oldseal in varchar2, mtype in varchar2, msg in varchar2 default null );
 procedure accept_cascade_movement( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2, mtype in varchar2, old_movement in varchar2, old_seal in varchar2 default null, new_movement in varchar2, new_seal in varchar2 default null);

 procedure menu_start( surl in varchar2, acid in integer);
 procedure menu( surl in varchar2, rnd in varchar2, mtype in varchar2, msearch in varchar2 default null, action in varchar2 default 'SEARCH', rid in varchar2 default null, acid in integer default null, xtra1 in varchar2 default null, xtra2 in varchar2 default null, xtra3 in varchar2 default null, norder in varchar2 default null, n_local in char default 'LA', rows_show in integer default null );
 procedure duty_edit(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null );

 procedure duty_edit(surl in varchar2, entry in number );
 procedure accept_duty( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, action in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2 , p4 in varchar2 );
 procedure invoke_report( surl in varchar2, repname in varchar2, r1 in varchar2 default null, r2 in varchar2 default null, r3 in varchar2 default null );
 procedure mng_cust( surl in varchar2, rid in varchar2 default null, id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null, scid in varchar2 default null, access_id in varchar2 default null, is_popup in char default 'F' );
 procedure accept_mng_cust( surl in varchar2, rid in varchar2, p1 in varchar2 default null, p1i in varchar2, p2 in varchar2 default null, p3 in varchar2 default null, p4 in varchar2 default null,
                            p5 in varchar2 default null, p6 in varchar2 default null, p7 in varchar2 default null, p8 in varchar2 default null, p9 in varchar2 default null,
                            p10 in varchar2 default null, p11 in varchar2 default null, p12 in varchar2 default null, p13 in varchar2 default null, p14 in varchar2 default null, p14a in varchar2 default null, action in varchar2,
                            r2 in varchar2, r2_1 in varchar2, r2_2 in varchar2, r3 in varchar2, r4 in varchar2, r5 in varchar2, r5v in varchar2,
			    r6 in varchar2, r6_1 in varchar2, r6_2 in varchar2, r6_3 in varchar2, r6_4 in varchar2, r6_5 in varchar2, r6_6 in varchar2, r6_7 in varchar2, r6_8 in varchar2,
			    r7 in varchar2, r8 in varchar2, r9 in varchar2,
			    r10 in varchar2, r11 in varchar2 default null, r12 in varchar2, r13 in varchar2, r13_1 in varchar2, r13_2 in varchar2, r13_3 in varchar2,
			    r13_4 in varchar2,r13_5 in varchar2,  r14 in varchar2, r15 in varchar2,
			    r15_1 in varchar2,r15_2 in varchar2,r15_3 in varchar2,r15_4 in varchar2,r15_5 in varchar2,r15_6 in varchar2,r15_7 in varchar2,r15_8 in varchar2,
			    r16 in varchar2, r17 in varchar2, r18 in varchar2, r19 in varchar2, r20 in varchar2, r20_1 in varchar2, r20_2 in varchar2, r21 in varchar2, r22 in varchar2, is_popup in char default 'F');
 procedure mng_charge( surl in varchar2, rid in varchar2 default null, id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null );
 procedure accept_mng_charge( surl in varchar2, rid in varchar2, p1 in varchar2 default null, p2 in varchar2 default null, p3 in varchar2 default null, p4 in varchar2 default null,
                           p5 in varchar2 default null, p6 in varchar2 default null, p7a in varchar2, p7b in varchar2, p7c in varchar2, action in varchar2 );
 procedure assign_hawb( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null, ispopup in char default 'F' );
 procedure hotsync( surl in varchar2 );
 procedure accept_hotsync( surl in varchar2, p2 in varchar2, p3 in varchar2 default NULL, p4 in varchar2 default 'F', p5 in varchar2 default null, p6 in varchar2 default 'F', p7 in varchar2 default 'F', p8 in varchar2 default 'F' );
 procedure edit_ecn_log( surl in varchar2, lg in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, msg in varchar2 default null, force_single_disp in char default 'F', popup in char default 'F' );
 procedure accept_edit_ecn_log( surl in varchar2, lg in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, action in varchar2, p2 in owa.vc_arr, p3 in owa.vc_arr, p3i in owa.vc_arr, p4 in owa.vc_arr, p5 in owa.vc_arr, p6 in owa.vc_arr, p7 in owa.vc_arr, p8 in owa.vc_arr, p9 in owa.vc_arr, p10 in owa.vc_arr, force_single_disp in char default 'F', popup in char default 'F'  );
 procedure analyse_hotsync( surl in varchar2 );
 procedure check_dupl(surl in varchar2, tname in varchar2, cname in varchar2, pkcol1 in varchar2, pkcol2 in varchar2 );
 procedure delete_dupl(surl in varchar2, tname in varchar2, rw in varchar2 );
 procedure accept_trac_search( surl in varchar2, p1 in varchar2, p1a in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p4i in varchar2, p4ii in varchar2, p4a in varchar2, p5 in varchar2, p6 in varchar2, p4aa in varchar2 );
 procedure manentry(surl in varchar2, rid in varchar2 default null, scid in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null, access_id in varchar2 default null, msg in varchar2 default null, id in varchar2 default null );
 procedure accept_manentry(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, old_entry in varchar2, entryno in varchar2, access_id in varchar2 default null, action in varchar2, p1 in owa.vc_arr, p2 in owa.vc_arr );
 procedure manentry_page2(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null );
 procedure accept_manentry_page2(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, old_entry in varchar2, access_id in varchar2 default null, action in varchar2, p1 in owa.vc_arr, p2 in owa.vc_arr );
 procedure manentry_page3(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null );
 procedure accept_manentry_page3(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, old_entry in varchar2, access_id in varchar2 default null, action in varchar2, p1 in owa.vc_arr, p2 in owa.vc_arr );
 procedure confirm_manentry_delete(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null );
 procedure accept_manentry_delete(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, old_entry in varchar2, access_id in varchar2 default null, action in varchar2 );
 procedure recalc_weight( mvid varchar2, ctrtype varchar2 default null, sl in varchar2 default null, mtype in varchar2 default null );
 procedure do_download_gl( vdir in varchar2 default null, fname in varchar2 default null, frm in varchar2 default null, fto in varchar2 default null, run_once in char default 'F' );
-- procedure start_batch_job;
-- procedure stop_batch_job;
 procedure start_batch_job(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null );
 procedure stop_batch_job(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null );
 procedure mng_ctr( surl in varchar2, rid in varchar2 default null, id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null );
 procedure accept_mng_ctr( surl in varchar2, rid in varchar2, id in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2 default null, p8 in varchar2, p9 in varchar2 default null, p10 in varchar2, p11 in varchar2, p12 in varchar2, action in varchar2 );
 procedure confirm_ctr_delete(surl in varchar2, rid in varchar2);
 procedure accept_ctr_delete(surl in varchar2, rid in varchar2, action in varchar2 );
 procedure mng_categories( surl in varchar2, rid in varchar2 default null, id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null );
 procedure accept_mng_categories( surl in varchar2, rid in varchar2, id in varchar2, p1 in varchar2 default null, p2 in varchar2 default null, p3 in varchar2 default null, p4 in varchar2 default null, p5 in varchar2, p6 in varchar2, p7 in varchar2, p8 in varchar2, action in varchar2 );
 procedure mng_onlocs( surl in varchar2, id in varchar2 );
 procedure mng_onlocs( surl in varchar2, arr_rid in src_rid, id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null );
 procedure onlocs_del( surl in varchar2, rid in varchar2 );
 procedure accept_mng_onlocs( Surl in varchar2, arr_rid in owa.vc_arr, id in varchar2, p1 in owa.vc_arr, p2 in owa.vc_arr, p3 in owa.vc_arr, p4 in owa.vc_arr, p5 in owa.vc_arr, p6 in owa.vc_arr, p7 in owa.vc_arr, p8 in owa.vc_arr, p9 in owa.vc_arr, action in varchar2 );
 procedure mng_offlocs( surl in varchar2, id in varchar2 );
 procedure mng_offlocs( surl in varchar2, arr_rid in src_rid, id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null );
 procedure offlocs_del( surl in varchar2, rid in varchar2 );
 procedure accept_mng_offlocs( Surl in varchar2, arr_rid in owa.vc_arr, id in varchar2, p1 in owa.vc_arr, p2 in owa.vc_arr, p3 in owa.vc_arr, p4 in owa.vc_arr, p5 in owa.vc_arr, p6 in owa.vc_arr, p7 in owa.vc_arr, p8 in owa.vc_arr, p9 in owa.vc_arr, action in varchar2 );
 procedure ctr_menu( surl in varchar2 );
 function data_access( typ in varchar2 ) return varchar2;
 procedure ctr_track( surl in varchar2, rid in varchar2 default null, id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null );
 procedure accept_ctr_track( surl in varchar2, rid in varchar2, p1 in owa.vc_arr, p2 in owa.vc_arr, p3 in owa.vc_arr, p4 in owa.vc_arr, action in varchar2 );
 procedure ctrdel( surl in varchar2, sno in varchar2, rn in varchar2 );

 procedure delivery_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in owa.vc_arr, pk2 in owa.vc_arr, pk3 in owa.vc_arr,
                              v1 in owa.vc_arr, v2 in owa.vc_arr, v3 in owa.vc_arr, v4 in owa.vc_arr, v5 in owa.vc_arr, v6 in owa.vc_arr, v7 in owa.vc_arr, v8 in owa.vc_arr, errmsg in owa.vc_arr, msg in varchar2 default null );
 procedure accept_delivery_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in owa.vc_arr, pk2 in owa.vc_arr, pk3 in owa.vc_arr,
                              v1 in owa.vc_arr, v2 in owa.vc_arr, v3 in owa.vc_arr, v4 in owa.vc_arr, v5 in owa.vc_arr, v6 in owa.vc_arr, v7 in owa.vc_arr, v8 in owa.vc_arr );
 procedure main_title( ttl in varchar2 default null, helpid in varchar2 default null, dispmenu in boolean default TRUE);
 function customer_state(vprof in integer) return varchar2;
 function security_role( vprofid in integer ) return varchar2;
 procedure receive_top2(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null, rows_show in integer default G_ROWS, norder in varchar2 default null, n_local in char default 'L' );
 procedure convoy(surl in varchar2, vpk in integer, msg in varchar2 default null, ispopup in char default 'F');
 procedure accept_convoy(surl in varchar2, vpk in integer, p0 in owa.vc_arr, p1 in owa.vc_arr, p2 in owa.vc_arr, p3 in owa.vc_arr, p4 in owa.vc_arr, p5 in owa.vc_arr, p6 in owa.vc_arr, p7 in owa.vc_arr, p8 in owa.vc_arr, p9 in owa.vc_arr, p10 in owa.vc_arr, p11 in owa.vc_arr, pm1 in owa.vc_arr, pm2 in owa.vc_arr, pm3 in owa.vc_arr, action in varchar2, ispopup in char default 'F');
 procedure masterplan(surl in varchar2, start_date in date, msg in varchar2 default null);
 function guess_time( v in varchar2 ) return varchar2;
 procedure usersumm( surl in varchar2 );
 procedure accept_receive_top2( surl in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2, rid in owa.vc_arr, n1 in owa.vc_arr, n2 in owa.vc_arr, action in varchar2, norder in varchar2 default null, n_local in char default 'L', rows_show in integer );
 procedure pool_popup(surl in varchar2, rid in varchar2, vsrc in varchar2 default null, msg in varchar2 default null);
 procedure pool_popup_search(surl in varchar2, rid in varchar2, vsrc in varchar2, action in varchar2);
 procedure popcapacity(surl in varchar2, vpk in integer, cdet in varchar2, rnd in varchar2 default null);
 procedure mv_popup(surl in varchar2, vpk in integer, fctr in integer, cdet in varchar2, ctrl in varchar2);
 procedure mv_popup_date(surl in varchar2, vdt in varchar2, fctr in integer, cdet in varchar2, ctrl in varchar2);
 procedure accept_masterplan( num_entries in number, name_array in owa.vc_arr, value_array in owa.vc_arr, reserved in owa.vc_arr );
 procedure accept_masterplan_shp( num_entries in number, name_array in owa.vc_arr, value_array in owa.vc_arr, reserved in owa.vc_arr );

 procedure t1( num_entries in number, name_array in owa.vc_arr, value_array in owa.vc_arr, reserved in owa.vc_arr );

end strangp;
/
