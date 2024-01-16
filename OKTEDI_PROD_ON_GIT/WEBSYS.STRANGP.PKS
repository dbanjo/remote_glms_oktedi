CREATE OR REPLACE package WEBSYS.strangp
as

 TYPE         column_desc is record(v_col varchar2(1000), v_alias varchar2(1000));
 TYPE         column_array is table of column_desc index by binary_integer;
 TYPE         limit_container_records is record ( bol1 varchar2(20), movement_no1 varchar2(40), seal1 varchar2(20), lower_limit int, upper_limit int, bol2 varchar2(20), movement_no2 varchar2(40), seal2 varchar2(20), grand_total int );
 TYPE         limit_dan_records is record ( movement_no1 varchar2(40), seal1 varchar2(20), deliveryno1 number(8), hb1 varchar(100), lower_limit int, upper_limit int, movement_no2 varchar2(40), seal2 varchar2(20), deliveryno2 number(8), hb2 varchar(100), grand_total int );
 TYPE         limit_records_type IS VARRAY(250) OF limit_container_records; 
 TYPE         limit_dans_records_type IS VARRAY(250) OF limit_dan_records; 
 TYPE src_rid IS TABLE OF rowid INDEX BY BINARY_INTEGER;
 empty_array	GLBX.MYARRAY;
 g_outbound_color varchar2(20) := '":#4EB5E2"';
 g_inbound_color  varchar2(20) := '":#00468C"';
 g_outbound_site varchar2(10) := glbx.extract_master_parameter('OUTBOUND_DEFAULT_SITE');
 g_convoy_week_start CONSTANT VARCHAR2(9) := 'MONDAY';

 procedure lov(surl in varchar2, call_name in varchar2, parm in varchar2, lrange in varchar2 default '*', src in varchar2 default null, msg in varchar2 default null, accin varchar2 default 'EDIT', src1 in varchar2 default null );
 procedure accept_lov( surl in varchar2, parm in varchar2, lrange in varchar2, action in varchar2, src in varchar2, p0 in GLBX.MYARRAY default strangp.empty_array, p1 in GLBX.MYARRAY default strangp.empty_array, p2 in GLBX.MYARRAY default strangp.empty_array, p3 in GLBX.MYARRAY default strangp.empty_array, p4 in GLBX.MYARRAY default strangp.empty_array, p5 in GLBX.MYARRAY default strangp.empty_array,p5d in GLBX.MYARRAY default strangp.empty_array,p5e in GLBX.MYARRAY default strangp.empty_array,p5f in GLBX.MYARRAY default strangp.empty_array, p5g in GLBX.MYARRAY default strangp.empty_array, p5h in GLBX.MYARRAY default strangp.empty_array, p5i in GLBX.MYARRAY default strangp.empty_array, p5j in GLBX.MYARRAY default strangp.empty_array, src1 in varchar2 default null );

 procedure trac_search( surl in varchar2, msg in varchar2 default null );
 procedure receive(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null, vrecctr in varchar2 default null );
 procedure receive_top(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null );
 procedure receive_bottom(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, msg in varchar2 default NULL );
 procedure po_pool_list( parm in varchar2,v_delno in number, v_po in varchar2, v_poitem in number default null, ismand in boolean DEFAULT FALSE, isedit in boolean DEFAULT TRUE );
 procedure pooladdVendor( vdelno in number, vName in varchar2, vCustid in number, vStreet in varchar2,vCity in varchar2, vDistrict in varchar2, vRegion in varchar2, vPostl_code in varchar2, vCountry in varchar2);
 procedure pooladdMaterial( vCode in varchar2, vDesc in varchar2, vPoUnitISO in varchar2, vMatl_group in varchar2, vVendor in varchar2);

 procedure grnstatus_list( parm in varchar2, v_grnstatus in varchar2, ismand in boolean DEFAULT FALSE, isedit in boolean DEFAULT TRUE );
 procedure receive_po(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, msg in varchar2 default NULL, checked_po in varchar2 default null, p3 in varchar2 default null, p5 in varchar2 default null );
 procedure accept_receive_po(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer,
                             detrid in varchar2, p0 in varchar2, p1 in varchar2, p2 in varchar2 default null, p20 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2,
                             p51 in varchar2, p52 in varchar2, p53 in varchar2, p53a in varchar2, p53d in varchar2,pgrn in varchar2,grnst in varchar2,grnit in varchar2, fmode in varchar2,
                             d3 in varchar2, d4 in varchar2, d5 in varchar2, d6 in varchar2, d7 in varchar2, st in varchar2, d6e in varchar2, d7e in varchar2, d8 in varchar2, d8a in varchar2, cancel in varchar2 default null,
                             save_record in varchar2 default null, first_record in varchar2 default null, previous_record in varchar2 default null, next_record in varchar2 default null, last_record in varchar2 default null, insert_record in varchar2 default null, delete_record in varchar2 default null, copy_record in varchar2 default null, checked_po in varchar2 default null);
 procedure accept_receive_top( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2, p1 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2, p8 in varchar2, p3n in varchar2, p3nn in varchar2, r1 in varchar2, r2 in varchar2, r3 in varchar2, p20a in varchar2, action in varchar2 );
 procedure ost_185_screen(surl in varchar2, action in varchar2 default 'NEW', msg in varchar default null);
 procedure ost_185_batch(surl in varchar2, msg in varchar default null);
 procedure accept_ost_185_batch( surl in varchar2, job_name in varchar2, p1 in varchar2, p2 in varchar2, action in varchar2 default 'CANCEL');
 procedure generate_ost185( surl in varchar2, vtoday in date, is_batch in varchar2 default 'FALSE' );
 procedure confirm_delete_detailrs(surl in varchar2, rid in varchar2, scid in varchar2, detrid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, msg in varchar2 default NULL );
 procedure confirm_delete_po(surl in varchar2, rid in varchar2, scid in varchar2, detrid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, msg in varchar2 default NULL );
 procedure accept_delete_detailrs(surl in varchar2, rid in varchar2, scid in varchar2, detrid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer, action in varchar2 );
 procedure accept_delete_po(surl in varchar2, rid in varchar2, scid in varchar2, detrid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer, action in varchar2 );

procedure accept_receive_detailr(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer,
                                detrid in varchar2, p1 in varchar2, p2 in varchar2 default null, p3 in varchar2, p4 in varchar2, p4L in varchar2, p4W in varchar2, p4H in varchar2, p4C in varchar2, p5 in varchar2, p6 in varchar2,p6i in varchar2, p7 in varchar2, p8 in varchar2,
                                p9 in varchar2, a1 in varchar2 default null, d5 in varchar2, d6 in varchar2, d8 in varchar2, cancel in varchar2 default null,
                                save_record in varchar2 default null, previous_record in varchar2 default null, next_record in varchar2 default null, insert_record in varchar2 default null, delete_record in varchar2 default null, split_record in varchar2 default null);

 procedure split_detailrs(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, msg in varchar2 default NULL );
 procedure accept_split_detailrs(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, action in varchar2, p1 in varchar2, p2 in GLBX.MYARRAY );
 procedure accept_manual_split(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, action in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY );

procedure movement(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null, c_rid in varchar2 default null );
 procedure accept_movement( surl in varchar2,  scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, action in varchar2,  msg in varchar2 default NULL,
                             p1 in varchar2,  p2 in varchar2,  p3 in varchar2,   p4 in varchar2 default 'F', p5 in varchar2, p5i in varchar2, p6i in varchar2, p6 in varchar2, p7 in varchar2,
                             p8 in varchar2,  p9 in varchar2,  p10 in varchar2,  p10a in varchar2, p10b in varchar2, p11 in varchar2, p12 in varchar2 default '1', p12a in varchar2 default null,
                             px1 in varchar2, px2 in varchar2, px3 in varchar2,  pp in varchar2, cp in varchar2, p20 in varchar2, p20a in varchar2, p20b in varchar2, p21 in varchar2, p22 in varchar2, p22a in varchar2, p23 in varchar2, p24 in varchar2,
                             p25 in varchar2, p26 in varchar2, p27 in varchar2,  p28 in varchar2, p29 in varchar2, p30 in varchar2, p31 in varchar2, p32 in varchar2, p33 in varchar2, p34 in varchar2,
			                 p35 in varchar2, p36 in varchar2, p37 in varchar2,  p38 in varchar2, p39 in varchar2, p40 in varchar2,
			                 p41 in varchar2, p42 in varchar2, p43 in varchar2,  p44 in varchar2, p45 in varchar2, p46 in varchar2, p47 in varchar2, p48 in varchar2, p49 in varchar2, p50 in varchar2,
                             p51 in varchar2, p3D in varchar2, p3L in varchar2,  p52 in varchar2, p53 in varchar2, p47a in varchar2, p48a in varchar2, p52a in varchar2, pa in varchar2 default null);

 procedure mass_movement( surl in varchar2, crec in strang.movements%ROWTYPE, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, nmb in integer, v_list in varchar2 default null, msg in varchar2 default null );
 procedure accept_mass_movement( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY  );
 procedure shp(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null );
procedure accept_shp( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, action in varchar2,
                      p1 in varchar2, p1a in varchar2, p2 in varchar2, p3 in varchar2,  p3i in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2,
                      p8 in varchar2, p9 in varchar2, p9m in varchar2, p10 in varchar2, p11 in varchar2, p12 in varchar2, p13 in varchar2, p14 in varchar2, p15 in varchar2, p16 in varchar2,
					  p17 in varchar2, p18 in varchar2, p19 in varchar2,
                      pc1 in varchar2, pc2 in varchar2, pc3 in varchar2, pc4 in varchar2, p50 in varchar2, p20a in varchar2);
  procedure entry_maintain(surl in varchar2, strt in varchar2, strt2 in varchar2 default null, rid in varchar2, vrecctr in varchar2, msg in varchar2 default null );

 procedure entry_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in GLBX.MYARRAY, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                               v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, v1i in GLBX.MYARRAY, v8i in GLBX.MYARRAY, v8ii in GLBX.MYARRAY, errmsg in GLBX.MYARRAY, msg in varchar2 default null );
 procedure accept_entry_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in GLBX.MYARRAY, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                               v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, v1i in GLBX.MYARRAY, v8i in GLBX.MYARRAY, v8ii in GLBX.MYARRAY );
  procedure po_item_no_maintain(surl in varchar2, strt in varchar2, strt2 in varchar2 default null, rid in varchar2, vrecctr in varchar2, msg in varchar2 default null );
  procedure poitemno_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                                v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v9_1 in GLBX.MYARRAY, v9 in GLBX.MYARRAY, v3_1 in GLBX.MYARRAY, v3_1_1 in GLBX.MYARRAY, v3_2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, v1i in GLBX.MYARRAY, v8i in GLBX.MYARRAY, errmsg in GLBX.MYARRAY, msg in varchar2 default null );
procedure accept_poitemno_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                              v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v9_1 in out GLBX.MYARRAY, v9 in GLBX.MYARRAY, v3_1 in GLBX.MYARRAY, v3_1_1 in GLBX.MYARRAY,v3_2 in GLBX.MYARRAY,v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, v1i in GLBX.MYARRAY, v8i in GLBX.MYARRAY, action in varchar2 default null  );
-- 20160615
  procedure po_inventory_maintain(surl in varchar2, strt in varchar2, rid in varchar2, vrecctr in varchar2, msg in varchar2 default null );
  procedure poinventory_maintain_mass(surl in varchar2, p1 in varchar2, rid in varchar2, vrecctr in varchar2, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                                v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v9 in GLBX.MYARRAY, v3_1 in GLBX.MYARRAY, v3_1_1 in GLBX.MYARRAY, v3_2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, v1i in GLBX.MYARRAY, v8i in GLBX.MYARRAY, errmsg in GLBX.MYARRAY, msg in varchar2 default null );
  procedure accept_poinvent_maintain_mass(surl in varchar2, p1 in varchar2, rid in varchar2, vrecctr in varchar2, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                                v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v9 in GLBX.MYARRAY, v3_1 in GLBX.MYARRAY, v3_1_1 in GLBX.MYARRAY, v3_2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, v1i in GLBX.MYARRAY, v8i in GLBX.MYARRAY );
--20160615
-- 20160714
  procedure po_inventdate_maintain(surl in varchar2, strt in varchar2, rid in varchar2, vrecctr in varchar2, msg in varchar2 default null );
  procedure poinvdte_maintain_mass(surl in varchar2, p1 in varchar2,  p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                                v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v9 in GLBX.MYARRAY, v3_1 in GLBX.MYARRAY, v3_1_1 in GLBX.MYARRAY, v3_2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, v1i in GLBX.MYARRAY, v8i in GLBX.MYARRAY, errmsg in GLBX.MYARRAY, msg in varchar2 default null );
  procedure accept_poinvdte_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                                v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v9 in GLBX.MYARRAY, v3_1 in GLBX.MYARRAY, v3_1_1 in GLBX.MYARRAY, v3_2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, v1i in GLBX.MYARRAY, v8i in GLBX.MYARRAY );
--20160714

 procedure container_maintain(surl in varchar2, strt in varchar2, strt2 in varchar2 default null, rid in varchar2, vrecctr in varchar2, msg in varchar2 default null );
-- procedure container_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in GLBX.MYARRAY, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
--                               v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, v1i in GLBX.MYARRAY, v8i in GLBX.MYARRAY, v8ii in GLBX.MYARRAY, v9 in GLBX.MYARRAY, v9i in GLBX.MYARRAY, v10 in GLBX.MYARRAY, errmsg in GLBX.MYARRAY, msg in varchar2 default null );

procedure container_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in GLBX.MYARRAY, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                               v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY,  v8i in GLBX.MYARRAY, v8ii in GLBX.MYARRAY, v9 in GLBX.MYARRAY, v9i in GLBX.MYARRAY, v10 in GLBX.MYARRAY, v11 in GLBX.MYARRAY, v12 in GLBX.MYARRAY, errmsg in GLBX.MYARRAY, msg in varchar2 default null );

 procedure accept_container_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in GLBX.MYARRAY, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                               v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY,  v8i in GLBX.MYARRAY, v8ii in GLBX.MYARRAY, v9 in GLBX.MYARRAY, v9i in GLBX.MYARRAY, v10 in GLBX.MYARRAY, v11 in GLBX.MYARRAY, v12 in GLBX.MYARRAY, ACTION in varchar2 default null );

 procedure log_maintain(surl in varchar2, strt in varchar2, rid in varchar2, vrecctr in varchar2, msg in varchar2 default null );
 procedure log_maintain_mass(surl in varchar2, p1 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in GLBX.MYARRAY, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                               v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY,
                               v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, v1i in GLBX.MYARRAY, v8i in GLBX.MYARRAY, v8ii in GLBX.MYARRAY, v9 in GLBX.MYARRAY,
                               v9i in GLBX.MYARRAY, v10 in GLBX.MYARRAY, errmsg in GLBX.MYARRAY, msg in varchar2 default null );
 procedure accept_log_maintain_mass(surl in varchar2, p1 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in GLBX.MYARRAY, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                               v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, 
                               v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, v1i in GLBX.MYARRAY, v8i in GLBX.MYARRAY, v8ii in GLBX.MYARRAY, v9 in GLBX.MYARRAY, 
                               v9i in GLBX.MYARRAY, v10 in GLBX.MYARRAY);
 procedure genduty(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null, action in varchar2 default null );
 procedure confirm_genduty(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null );
 procedure generate_ships_manifest( vship_id varchar2, action in varchar2 default 'LINE_NO', typ in varchar2 default 'SHIP', entryno in number default null, vste in varchar2 );

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
 procedure accept_edit_mawb( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, p0 in varchar2, p1 in varchar2, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY,
                            p6 in GLBX.MYARRAY, p7 in GLBX.MYARRAY, p8 in GLBX.MYARRAY, action in varchar2 default 'NO_REPEAT' );
 procedure edit_mawb_ecn( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, mwb in varchar2 default null, msg in varchar2 default null );
 procedure accept_edit_mawb_ecn( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, p0 in varchar2, p1 in varchar2, action in varchar2, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p3i in GLBX.MYARRAY );
-- procedure edit_bol( surl in varchar2, rid in varchar2, rid2 in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, shpid in varchar2 default null, msg in varchar2 default null );
-- procedure accept_edit_bol( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, rid2 in varchar2, p0 in varchar2, p1 in varchar2, action in varchar2, p2 in GLBX.MYARRAY, p3a in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6 in GLBX.MYARRAY, p7 in GLBX.MYARRAY, p8 in GLBX.MYARRAY );

-- procedure edit_local_bol( surl in varchar2, rid in varchar2, rid2 in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, shpid in varchar2 default null, msg in varchar2 default null );
-- procedure accept_edit_local_bol( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, rid2 in varchar2, p0 in varchar2, p1 in varchar2, action in varchar2, p2 in GLBX.MYARRAY, p3a in GLBX.MYARRAY, p3 in GLBX.MYARRAY );

 procedure edit_ecn( surl in varchar2, rid in varchar2, rid2 in varchar2 default null, scid in varchar2, parm in varchar2, access_id in varchar2 default null, shpid in varchar2 default null, msg in varchar2 default null );
 procedure accept_edit_ecn( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, rid2 in varchar2, p0 in varchar2, p1 in varchar2, action in varchar2, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p3i in GLBX.MYARRAY );

 procedure assign_det( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null, fl in varchar2, lcl in varchar2 default 'F' );
 --procedure accept_assign_det( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, action in varchar2, fl in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );

 procedure accept_assign_det( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2
                           , action in varchar2, fl in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY
                           , p1A in GLBX.MYARRAY, p2A in GLBX.MYARRAY
                           , p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6 in GLBX.MYARRAY, p7 in GLBX.MYARRAY, p7A in GLBX.MYARRAY  );
 procedure cascade_movement( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, oldid in varchar2, oldseal in varchar2, mtype in varchar2, msg in varchar2 default null );
 procedure accept_cascade_movement( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2, mtype in varchar2, old_movement in varchar2, old_seal in varchar2 default null, new_movement in varchar2, new_seal in varchar2 default null);

 procedure menu( surl in varchar2, rnd in varchar2, mtype in varchar2, msearch in varchar2 default null, action in varchar2 default 'SEARCH', rid in varchar2 default null );
 procedure duty_edit(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null );

 procedure duty_edit(surl in varchar2, entry in number );
 procedure accept_duty( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, action in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2 , p4 in varchar2 );
 procedure invoke_report( surl in varchar2, repname in varchar2, r1 in varchar2 default null, r2 in varchar2 default null, r3 in varchar2 default null );
 procedure mng_cust( surl in varchar2, rid in varchar2 default null, id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null, scid in varchar2 default null, access_id in varchar2 default null );
 procedure accept_mng_cust( surl in varchar2, rid in varchar2, p1 in varchar2 default null, p1i in varchar2, p2 in varchar2 default null, p3 in varchar2 default null, p4 in varchar2 default null,
                            p5 in varchar2 default null, p6 in varchar2 default null, p7 in varchar2 default null, p8 in varchar2 default null, p9 in varchar2 default null,
                            p10 in varchar2 default null, p11 in varchar2 default null, p12 in varchar2 default null, p13 in varchar2 default null, p14 in varchar2 default null, p14a in varchar2 default null, action in varchar2,
                            r2 in varchar2, r2_1 in varchar2, r2_2 in varchar2, r3 in varchar2, r4 in varchar2, r5 in varchar2, r5v in varchar2,
			    r6 in varchar2, r6_1 in varchar2, r6_2 in varchar2, r6_3 in varchar2, r6_4 in varchar2, r6_5 in varchar2, r6_6 in varchar2, r6_7 in varchar2, r6_8 in varchar2,
			    r7 in varchar2, r8 in varchar2, r9 in varchar2,
			    r10 in varchar2, r11 in varchar2 default null, r12 in varchar2, r13 in varchar2, r13_1 in varchar2, r13_2 in varchar2, r13_3 in varchar2,
			    r13_4 in varchar2,r13_5 in varchar2,  r14 in varchar2, r15 in varchar2,
			    r15_1 in varchar2,r15_2 in varchar2,r15_3 in varchar2,r15_4 in varchar2,r15_5 in varchar2,r15_6 in varchar2,r15_7 in varchar2,r15_8 in varchar2,
			    r16 in varchar2, r17 in varchar2, r18 in varchar2, r19 in varchar2, r20 in varchar2, r20_1 in varchar2, r20_2 in varchar2, r21 in varchar2, r22 in varchar2);
 procedure mng_charge( surl in varchar2, rid in varchar2 default null, id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null );
 procedure accept_mng_charge( surl in varchar2, rid in varchar2, p1 in varchar2 default null, p2 in varchar2 default null, p3 in varchar2 default null, p4 in varchar2 default null,
                              p5 in varchar2 default null, p6 in varchar2 default null, p7a in varchar2, p7b in varchar2, p7c in varchar2, action in varchar2 );
 procedure hotsync( surl in varchar2 );
 procedure accept_hotsync( surl in varchar2, p2 in varchar2, p3 in varchar2 default NULL, p4 in varchar2 default 'F', p5 in varchar2 default null, p6 in varchar2 default 'F', p7 in varchar2 default 'F', p8 in varchar2 default 'F' );
 procedure assign_hawb( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null );
 procedure edit_ecn_log( surl in varchar2, lg in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, msg in varchar2 default null );
 --procedure accept_edit_ecn_log( surl in varchar2, lg in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, action in varchar2, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p3i in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6 in GLBX.MYARRAY, p7 in GLBX.MYARRAY, p8 in GLBX.MYARRAY, p9 in GLBX.MYARRAY, p10 in GLBX.MYARRAY  );
 procedure accept_edit_ecn_log( surl in varchar2, lg in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, action in varchar2, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY,  p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6 in GLBX.MYARRAY, p7 in GLBX.MYARRAY, p8 in GLBX.MYARRAY, p9 in GLBX.MYARRAY, p10 in GLBX.MYARRAY, p11 in GLBX.MYARRAY, p12 in GLBX.MYARRAY);
 procedure analyse_hotsync( surl in varchar2 );
 procedure check_dupl(surl in varchar2, tname in varchar2, cname in varchar2, pkcol1 in varchar2, pkcol2 in varchar2 );
 procedure delete_dupl(surl in varchar2, tname in varchar2, rw in varchar2 );
 procedure accept_trac_search( surl in varchar2, p1 in varchar2, p1a in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p4i in varchar2, p4ii in varchar2, p4a in varchar2, p5 in varchar2, p6 in varchar2, p4aa in varchar2, p7c in varchar2, p8c in varchar2, p9 in varchar2);
 procedure manentry(surl in varchar2, rid in varchar2 default null, scid in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null, access_id in varchar2 default null, msg in varchar2 default null, id in varchar2 default null );
 procedure accept_manentry(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, old_entry in varchar2, entryno in varchar2, access_id in varchar2 default null, action in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );
 procedure manentry_page2(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null );
 procedure accept_manentry_page2(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, old_entry in varchar2, access_id in varchar2 default null, action in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );
 procedure manentry_page3(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null );
 procedure accept_manentry_page3(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, old_entry in varchar2, access_id in varchar2 default null, action in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );
 procedure confirm_manentry_delete(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null );
 procedure accept_manentry_delete(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, old_entry in varchar2, access_id in varchar2 default null, action in varchar2 );
 procedure recalc_weight( mvid varchar2, ctrtype varchar2 default null, sl in varchar2 default null, mtype in varchar2 default null, rid varchar2 default null );
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
 function check_invoice_attachment (deliveryno in varchar2) return varchar2;
 function check_invoice_name (deliveryno in varchar2) return varchar2;
 

procedure delivery_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in GLBX.MYARRAY, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                              v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, errmsg in GLBX.MYARRAY, msg in varchar2 default null );
procedure accept_delivery_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in GLBX.MYARRAY, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                              v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY );
procedure ctrs_mass_png_alln(surl in varchar2, parm in varchar2, action in varchar2, access_id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, shipid in number default null );

procedure ctrs_mass_png_alln_update(surl in varchar2
                               , parm in varchar2
                               , action in varchar2
                               , v_rid_cs in owa.vc_arr
                               , v1 in owa.vc_arr
                               , v2 in owa.vc_arr
                               , v3 in out owa.vc_arr
                               , v4 in out owa.vc_arr
                               , v5 in out owa.vc_arr
                               , v6 in out owa.vc_arr
                               , v7 in out owa.vc_arr
                            --   , v8 in out owa.vc_arr  -- remove this 
                               , v9 in out owa.vc_arr
                               , v10 in out owa.vc_arr
                               , v11 in out owa.vc_arr
                               , v12 in out owa.vc_arr
                               , v13 in out owa.vc_arr
                               , v14 in out owa.vc_arr
                               , v15 in out owa.vc_arr
                            --   , v16 in out owa.vc_arr  -- remove this
                            --   , v17 in out owa.vc_arr  -- remove this
                               , v18 in out owa.vc_arr  
                               , v19 in out owa.vc_arr
                               , v20 in out owa.vc_arr
                            --   , v21 in out owa.vc_arr  -- remove this
                            --   , v22 in out owa.vc_arr  -- remove this 
                            --   , v23 in out owa.vc_arr  -- remove this
                               , v24 in out owa.vc_arr
                               , v25 in out owa.vc_arr
                               , v26 in out owa.vc_arr
                               , errmsg in out owa.vc_arr
                               , access_id in varchar2 default null
                               , msg in varchar2 default null
                               , call_name in varchar2 default null );

--procedure ctrs_mass_png_alln_update(surl in varchar2
--                               , parm in varchar2
--                               , action in varchar2
--                               , v_rid_cs in owa.vc_arr
--                               , v1 in owa.vc_arr
--                               , v2 in owa.vc_arr
--                               , v3 in out owa.vc_arr
--                               , v4 in out owa.vc_arr
--                               , v5 in out owa.vc_arr
--                               , v6 in out owa.vc_arr
--                               , v7 in out owa.vc_arr
--                               , v8 in out owa.vc_arr
--                               , v9 in out owa.vc_arr
--                               , v10 in out owa.vc_arr
--                               , v11 in out owa.vc_arr
--                               , v12 in out owa.vc_arr
--                               , v13 in out owa.vc_arr
--                               , v14 in out owa.vc_arr
--                               , v15 in out owa.vc_arr
--                               , v16 in out owa.vc_arr
--                               , v17 in out owa.vc_arr
--                               , v18 in out owa.vc_arr
--                               , v19 in out owa.vc_arr
--                               , v20 in out owa.vc_arr
--                               , v21 in out owa.vc_arr
--                               , v22 in out owa.vc_arr
--                               , v23 in out owa.vc_arr
--                               , v24 in out owa.vc_arr
--                               , v25 in out owa.vc_arr
--                               , v26 in out owa.vc_arr
--                               , errmsg in out owa.vc_arr
--                               , access_id in varchar2 default null
--                               , msg in varchar2 default null
--                               , call_name in varchar2 default null );
                               
                               
                               
procedure accept_ctrs_mass_png_alln_up( surl in varchar2
                                       , parm in varchar2
                                       , access_id in varchar2
                                       , call_name in varchar2
                                       , v_rid_cs in owa.vc_arr
                                       , v1 in owa.vc_arr
                                       , v2 in owa.vc_arr
                                       , v3 in out owa.vc_arr
                                       , v4 in out owa.vc_arr
                                       , v5 in out owa.vc_arr
                                       , v6 in out owa.vc_arr
                                       , v7 in out owa.vc_arr
                                --       , v8 in out owa.vc_arr
                                       , v9 in out owa.vc_arr
                                       , v10 in out owa.vc_arr
                                       , v11 in out owa.vc_arr
                                       , v12 in out owa.vc_arr
                                       , v13 in out owa.vc_arr
                                       , v14 in out owa.vc_arr
                                       , v15 in out owa.vc_arr
                                --       , v16 in out owa.vc_arr
                                --       , v17 in out owa.vc_arr
                                       , v18 in out owa.vc_arr
                                       , v19 in out owa.vc_arr
                                       , v20 in out owa.vc_arr
                                --       , v21 in out owa.vc_arr
                                --       , v22 in out owa.vc_arr
                                --       , v23 in out owa.vc_arr
                                       , v24 in out owa.vc_arr
                                       , v25 in out owa.vc_arr
                                       , v26 in out owa.vc_arr
                                       , action in varchar2
                                       );
--procedure accept_ctrs_mass_png_alln_up( surl in varchar2
--                                       , parm in varchar2
--                                       , access_id in varchar2
--                                       , call_name in varchar2
--                                       , v_rid_cs in owa.vc_arr
--                                       , v1 in owa.vc_arr
--                                       , v2 in owa.vc_arr
--                                       , v3 in out owa.vc_arr
--                                       , v4 in out owa.vc_arr
--                                       , v5 in out owa.vc_arr
--                                       , v6 in out owa.vc_arr
--                                       , v7 in out owa.vc_arr
--                                       , v8 in out owa.vc_arr
--                                       , v9 in out owa.vc_arr
--                                       , v10 in out owa.vc_arr
--                                       , v11 in out owa.vc_arr
--                                       , v12 in out owa.vc_arr
--                                       , v13 in out owa.vc_arr
--                                       , v14 in out owa.vc_arr
--                                       , v15 in out owa.vc_arr
--                                       , v16 in out owa.vc_arr
--                                       , v17 in out owa.vc_arr
--                                       , v18 in out owa.vc_arr
--                                       , v19 in out owa.vc_arr
--                                       , v20 in out owa.vc_arr
--                                       , v21 in out owa.vc_arr
--                                       , v22 in out owa.vc_arr
--                                       , v23 in out owa.vc_arr
--                                       , v24 in out owa.vc_arr
--                                       , v25 in out owa.vc_arr
--                                       , v26 in out owa.vc_arr
--                                       , action in varchar2
--                                       );

procedure download_cargo_csv(surl in varchar2, action in varchar2);
procedure assign_priority( mv in varchar2, sl in varchar2 );
procedure convoy_ctr_list( parm in varchar2, v_portload in varchar2, v_movement in varchar2 default null, v_io in varchar2 default 'I', ismand in boolean DEFAULT FALSE, isedit in boolean DEFAULT TRUE );
procedure detail_items(surl in varchar2, rid in varchar2, recctr integer,  parm in varchar2 default null, msg in varchar2 default null );
procedure detail_items_accept(  surl in varchar2
                               , rid in varchar2
							   , recctr integer
							   , recItm in owa.vc_arr default glbx.empty_array
							   , pktpe_packtype in owa.vc_arr default glbx.empty_array
							   , lngth in owa.vc_arr default glbx.empty_array
							   , width in owa.vc_arr default glbx.empty_array
							   , height in owa.vc_arr default glbx.empty_array
							   , weight in owa.vc_arr default glbx.empty_array
							   , smp in owa.vc_arr default glbx.empty_array
							   , container in owa.vc_arr default glbx.empty_array
							   , seal in owa.vc_arr default glbx.empty_array
							   , packed_date in owa.vc_arr default glbx.empty_array
                               , packed_by in owa.vc_arr default glbx.empty_array
							   , action in varchar2
							   , parm in varchar2 default null
							   );
procedure ctrs_mass_png_alls(surl in varchar2, parm in varchar2, action in varchar2, access_id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, shipid number default null, vloc in varchar2 default 'MOTUKEA' );
procedure ctrs_mass_png_alls_Update(surl in varchar2
                               , parm in varchar2
                               , action in varchar2
                               , v_rid_cs in owa.vc_arr
                               , v1 in owa.vc_arr
                               , v2 in owa.vc_arr
                               , v3 in out owa.vc_arr
                               , v4 in out owa.vc_arr
                               , v5 in out owa.vc_arr
                               , v6 in out owa.vc_arr
                               , v7 in out owa.vc_arr
                               , v8 in out owa.vc_arr
                               , v9 in out owa.vc_arr
                               , v10 in out owa.vc_arr
                               , v11 in out owa.vc_arr
                               , v12 in out owa.vc_arr
                               , v13 in out owa.vc_arr
                               , v14 in out owa.vc_arr
                               , v15 in out owa.vc_arr
                               , v16 in out owa.vc_arr
                               , v17 in out owa.vc_arr
                               , v18 in out owa.vc_arr
                               , v19 in out owa.vc_arr
                               , v20 in out owa.vc_arr
                               , v21 in out owa.vc_arr
                               , v22 in out owa.vc_arr
                               , v23 in out owa.vc_arr
                               , v24 in out owa.vc_arr
                               , v25 in out owa.vc_arr
                               , v26 in out owa.vc_arr
                               , v27 in out owa.vc_arr
                               , v28 in out owa.vc_arr
                               , v29 in out owa.vc_arr
                               , errmsg in out owa.vc_arr
                               , access_id in varchar2 default null
                               , msg in varchar2 default null
                               , call_name in varchar2 default null );
procedure accept_ctrs_mass_png_alls_Up( surl in varchar2
                                       , parm in varchar2
                                       , access_id in varchar2
                                       , call_name in varchar2
                                       , v_rid_cs in owa.vc_arr
                                       , v1 in owa.vc_arr
                                       , v2 in owa.vc_arr
                                       , v3 in out owa.vc_arr
                                       , v4 in out owa.vc_arr
                                       , v5 in out owa.vc_arr
                                       , v6 in out owa.vc_arr
                                       , v7 in out owa.vc_arr
                                       , v8 in out owa.vc_arr
                                       , v9 in out owa.vc_arr
                                       , v10 in out owa.vc_arr
                                       , v11 in out owa.vc_arr
                                       , v12 in out owa.vc_arr
                                       , v13 in out owa.vc_arr
                                       , v14 in out owa.vc_arr
                                       , v15 in out owa.vc_arr
                                       , v16 in out owa.vc_arr
                                       , v17 in out owa.vc_arr
                                       , v18 in out owa.vc_arr
                                       , v19 in out owa.vc_arr
                                       , v20 in out owa.vc_arr
                                       , v21 in out owa.vc_arr
                                       , v22 in out owa.vc_arr
                                       , v23 in out owa.vc_arr
                                       , v24 in out owa.vc_arr
                                       , v25 in out owa.vc_arr
                                       , v26 in out owa.vc_arr
                                       , v27 in out owa.vc_arr
                                       , v28 in out owa.vc_arr
                                       , v29 in out owa.vc_arr
                                       , action in varchar2
                                       );
procedure bols(surl in varchar2, scid in integer, rid_ss in rowid, rid_bs rowid default null, parm in varchar2, action in varchar2, access_id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null
              , p1 in varchar2 default null, p2 in varchar2 default null, p3 in varchar2 default null, p4 in varchar default null);
procedure accept_bols( surl in varchar2,scid in integer, rid_ss in rowid, rid_bs in rowid, parm in varchar2, access_id in varchar2, action in varchar2,
            p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2 );
procedure hbs (surl in varchar2, scid in integer, rid_ss in rowid, rid_bs rowid default null, rid_hs rowid default null, parm in varchar2, action in varchar2, access_id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null );
procedure accept_hbs( surl in varchar2, scid in integer, rid_ss in rowid, rid_bs in rowid, rid_hs in rowid, parm in varchar2, access_id in varchar2, action in varchar2, call_name in varchar2 default null, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2 );
procedure hb_list( rid_bs in rowid, parm in varchar2, vhb in varchar2, ismand in boolean default FALSE, isedit in boolean default TRUE );              
--procedure containers_mass(surl in varchar2, scid in integer, rid_ss in rowid, rid_bs rowid default null, rid_hs rowid default null, parm in varchar2, action in varchar2, access_id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null );
procedure containers_mass (surl in varchar2, scid in integer, rid_ss in rowid, rid_bs rowid default null, rid_hs rowid default null, parm in varchar2, action in varchar2, access_id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, lrange in varchar2 default '*' );
procedure containers_mass_update(surl in varchar
                               , scid in integer
                               , rid_ss in rowid
                               , rid_bs rowid default null
                               , rid_hs rowid default null
                               , parm in varchar2
                               , action in varchar2
                               , v_rid_cs in owa.vc_arr
                               , v1 in owa.vc_arr
                               , v2 in owa.vc_arr
                               , v2a in owa.vc_arr
                               , v3 in out owa.vc_arr
                               , v4 in out owa.vc_arr
                               , v5 in out owa.vc_arr
                               , v6 in out owa.vc_arr
                               , v7 in out owa.vc_arr
                               , v8 in out owa.vc_arr
                               , v9 in out owa.vc_arr
                               , v10 in out owa.vc_arr
                               , v11 in out owa.vc_arr
                               , lrange in varchar2 default '*' 
                               , limit_records in limit_records_type default null
                               , errmsg in out owa.vc_arr
                               , access_id in varchar2 default null
                               , msg in varchar2 default null
                               , call_name in varchar2 default null );


procedure accept_containers_mass_update( surl in varchar2
                                       , scid in integer
                                       , rid_ss in rowid
                                       , rid_bs in rowid default null
                                       , rid_hs in rowid default null
                                       , parm in varchar2
                                       , access_id in varchar2
                                       , call_name in varchar2 default null
                                       , v_rid_cs in owa.vc_arr
                                       , v1 in owa.vc_arr
                                       , v2 in out owa.vc_arr
                                       , v2a in out owa.vc_arr
                                       , v3 in out owa.vc_arr
                                       , v4 in out owa.vc_arr
                                       , v5 in out owa.vc_arr
                                       , v6 in out owa.vc_arr
                                       , v7 in out owa.vc_arr
                                       , v8 in out owa.vc_arr
                                       , v9 in out owa.vc_arr
                                       , v10 in out owa.vc_arr
                                       , v11 in out owa.vc_arr
                                       , lrange in varchar2 default '*' 
                                       , limit_exceeded in varchar2 default 'FALSE'
                                    --   , v_limit_records in out owa.vc_arr
                                       , action in varchar2
                                       );
procedure bol_list( rid_ss in rowid, parm in varchar2, vbol in varchar2 default null, ismand in boolean default FALSE, isedit in boolean default TRUE );
--procedure bolhb_list( rid_ss in rowid, bl in varchar2, parm in varchar2, ismand in boolean default FALSE, isedit in boolean default TRUE );
procedure copy_bols(surl in varchar2, scid in integer, rid_ss in rowid, p1 in varchar2, parm in varchar2, access_id in varchar2 default null, action in varchar2 );
procedure Dans(surl in varchar2, scid in integer, rid_ss in rowid, rid_bs rowid, rid_cs rowid default null, rid_hs rowid default null, parm in varchar2, action in varchar2, access_id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, lrange in varchar2 default '*' );
procedure Dans_Update(surl in varchar2
                               , scid in integer
                               , rid_ss in rowid
                               , rid_bs rowid
                               , rid_cs rowid default null
                               , rid_hs rowid default null
                               , parm in varchar2
                               , action in varchar2
                               , v_rid_r in out owa.vc_arr
                               , v_rid_cs in out owa.vc_arr
                               , v1 in out owa.vc_arr
                               , v2 in out owa.vc_arr
                               , v3 in out owa.vc_arr
                               , v4 in out owa.vc_arr
                               , v5 in out owa.vc_arr
                               , v6 in out owa.vc_arr
                               , v7 in out owa.vc_arr
                               , v8 in out owa.vc_arr
                               , v9 in out owa.vc_arr
                               , v10 in out owa.vc_arr
                               , v11 in out owa.vc_arr
                               , v12 in out owa.vc_arr
                               , v13 in out owa.vc_arr
                               , v14 in out owa.vc_arr
                               , v15 in out owa.vc_arr
                               , v16 in out owa.vc_arr
                               , v17 in out owa.vc_arr
                               , v18 in out owa.vc_arr
                               , v19 in out owa.vc_arr
                               , lrange in varchar2 default '*' 
                               , limit_records in limit_dans_records_type default null
                               , errmsg in out owa.vc_arr
                               , access_id in varchar2 default null
                               , msg in varchar2 default null
                               , call_name in varchar2 default null );
  

procedure accept_dans_update( surl in varchar2
                                       , scid in integer
                                       , rid_ss in rowid
                                       , rid_bs in rowid
                                       , rid_cs rowid default null
                                       , rid_hs in rowid default null
                                       , parm in varchar2
                                       , access_id in varchar2
                                       , call_name in varchar2
                                       , v_rid_r in out owa.vc_arr
                                       , v_rid_cs in out owa.vc_arr
                                       , v1 in out owa.vc_arr
                                       , v2 in out owa.vc_arr
                                       , v3 in out owa.vc_arr
                                       , v4 in out owa.vc_arr
                                       , v5 in out owa.vc_arr
                                       , v6 in out owa.vc_arr
                                       , v7 in out owa.vc_arr
                                       , v8 in out owa.vc_arr
                                       , v9 in out owa.vc_arr
                                       , v10 in out owa.vc_arr
                                       , v11 in out owa.vc_arr
                                       , v12 in out owa.vc_arr
                                       , v13 in out owa.vc_arr
                                       , v14 in out owa.vc_arr
                                       , v15 in out owa.vc_arr
                                       , v16 in out owa.vc_arr
                                       , v17 in out owa.vc_arr
                                       , v18 in out owa.vc_arr
                                       , v19 in out owa.vc_arr
                                       , lrange in varchar2 default '*' 
                                       , limit_exceeded in varchar2 default 'FALSE'
                                       , action in varchar2
                                       );
procedure load_files(surl in varchar2, rid in varchar2, vtyp varchar2 default 'INVOICE', msg in varchar2 default null);
procedure load_files_accept(surl in varchar2, rid in varchar2, vtyp varchar2, infile owa.vc_arr, action varchar2);
function http_file_listing(u_target varchar2, file_list in out glbx.myarray) return integer;
function trunc_to_week_start(in_date in date) return date;
function day_of_week(in_date in date) return number;
function week_of_year(in_date in date) return number;
function to_char_week(in_date in date) return varchar2;
procedure mng_smp( surl in varchar2, rid in varchar2 default null, access_id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null, scid in varchar2 default null);
procedure accept_mng_smp( surl in varchar2, rid in varchar2, access_id in varchar2, p1 in varchar2 default null, p2 in varchar2 default null, p3 in varchar2 default null, p4 in varchar2 default null,
                           p5 in varchar2 default null, p6 in varchar2 default null, p7 in varchar2 default null, p8 in varchar2 default null, p9 in varchar2 default null,
                           p10 in varchar2 default null, p11L in varchar2 default null, p11W in varchar2 default null, p11H in varchar2 default null, p12 in varchar2 default null, p13 in varchar2 default null, p14 in varchar2 default null,
                           action in varchar2, parm in varchar2 default null );
procedure assign_smp_det( surl in varchar2, rid in varchar2, scid in varchar2 default null, parm in varchar2 default null, access_id in varchar2 default null, msg in varchar2 default null, fl in varchar2, lcl in varchar2 default 'F' );
procedure accept_assign_smp_det( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, action in varchar2, fl in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );
procedure recalc_weight_smp( rid varchar2, mtype in varchar2 default null );
procedure part_shipment_window (surl in varchar2, mvid in varchar2, seal in varchar2 default null);
procedure load_container_photos(surl in varchar2, rid in varchar2, vtyp varchar2 default 'FRONT', msg in varchar2 default null);
procedure load_container_photos_accept(surl in varchar2, rid in varchar2, vtyp varchar2, infile owa.vc_arr, action varchar2);
end strangp;
/


GRANT EXECUTE ON WEBSYS.STRANGP TO STRANG;

GRANT EXECUTE ON WEBSYS.STRANGP TO STX1;
