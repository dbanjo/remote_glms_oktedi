CREATE OR REPLACE package body WEBSYS.strangs
as


strang_directory varchar2(100) := 'p:\piction\mail_output';


  cursor ctariff( vpk number ) is
  select rnumb, tariff
  from
  (
   select rownum rnumb, tariff, description, colc
   from
   (
    select /*+ ALL_ROWS */ distinct l1.cola tariff, l2.description, l2.colc
    from strang.pos p, strang.lov l1, strang.lov l2
    where l1.lov_name = 'INVENT' and
          l2.lov_name = 'TARIFF' and
          l1.cola = l2.code and
          l1.code = p.inventoryno and
          p.deliveryno in
           (select distinct deliveryno
            from strang.detailrs dr
           where dr.entry_no = vpk
          )
    order by l1.cola
    )
  )
  order by rnumb;

 procedure ins_gen_rec( gen_rec strang.sad_general_data%ROWTYPE );
 procedure ins_fol_rec( fol_rec strang.sad_following%ROWTYPE );
 function f15_parameter_range( parm_id in varchar2, parm1 in varchar2, parm2 in varchar2 ) return varchar2;
 function form_15_continue(colin varchar2, entryno in number, tariff in varchar2, rnumb in integer default null, vtot in integer) return varchar2;
 procedure add_email_log(v_disp_type in varchar2, v_template in varchar2, v_mail_file in varchar2, v_mail_from in varchar2, v_mail_to in varchar2, v_mail_subject in varchar2, v_is_sms in varchar2, v_at_step in varchar2, v_error in varchar2);
 procedure pline(c in out utl_smtp.connection, bfr in varchar2 );
-- function base64( nmb integer ) return varchar2;
-- function conv_3bytes( fbytes varchar2 ) return varchar2;
-- procedure dump_blob( c in out utl_smtp.connection, img in blob );
 procedure dump_blob( c in out utl_smtp.connection, img in blob, fname in varchar2 default null, display_mime_header in boolean default FALSE );
 procedure create_dir( fdirname in varchar2, floc in varchar2 );
 function retrieve_physical_original( fnm in varchar2, blb in out blob ) return boolean;
 function send_files_smtp(p_from in varchar2, p_to in varchar2, p_subj in varchar2 ) return boolean;

 procedure zip( zip_filename in varchar2, file_to_add in varchar2, move_files in BOOLEAN default FALSE )
 as
  display_output GLBX.MYARRAY;
  bl		 boolean;
 begin
  if glbx.extract_master_parameter('REPORTS_DATABASE') = 'TRUE' then return; end if; -- only zips if files are stored outside the database
  bl := os_command.zip( zip_filename, FALSE, FALSE, file_to_add, display_output, move_files=>move_files );
  dbms_lock.sleep(2);
 exception when others then null;
 end zip;

 function get_lov( cd in varchar2, lname in varchar2 default 'CONTROLS' )
  return varchar2
 as
  cursor c1 is select * from strang.lov where lov_name = lname and code = cd;
  c1rec c1%ROWTYPE;
 begin
  open c1;
  fetch c1 into c1rec;
  close c1;
  return( c1rec.description );
 end get_lov;

 procedure email_sad_file(surl in varchar2, pk in varchar2 )
 as

 cursor c6(ltype varchar2, acid integer) is
  select contact_mobile,billing_email,contact_email
  from customer_contact
  where (ltype = 'OWNER' and aid = acid) or
        (ltype = 'PROFILE' and aid = acid)
 union all
  select contact contact_mobile, contact_email billing_email,contact_email
  from manufacturer
  where ltype = 'MANUFACTURER' and manufacturer_id = acid
 union all
  select mobile_phone contact_mobile, contact_email billing_email,contact_email
  from photographer
  where ltype = 'PHOTOGRAPHER' and pid = acid;

 c1rec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
  sts		varchar2(100);
 owner_id	integer;
 c6rec		c6%ROWTYPE;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;

 begin
  glbx.cookie_id( surl, stype, ltype, owner_id, sts, call_type=>'S', progcalled=>'STRANGS.EMAIL_SAD_FILE', ignore_cookie_check=>TRUE );
  c1rec := glbx.get_aid( owner_id, 'S', ltype );
  open c6(ltype,c1rec.aid);
  fetch c6 into c6rec;
  close c6;
  gcode(1) := NULL;
  gparam(1) := NULL;
  glbx.send( gcode, gparam, strang_directory || '\' || pk || '.sad', p_to=>nvl(c6rec.billing_email,c6rec.contact_email), p_subj=>'SAD:' || pk, p_from=>glbx.extract_master_parameter('MAIL_FROM'),is_report=>TRUE,ltype=>ltype,own_id=>owner_id, is_attachment=>TRUE);

 end email_sad_file;

 procedure email_sad_file_multi(surl in varchar2 )
 as

 cursor c6(ltype varchar2, acid integer) is
  select contact_mobile,billing_email,contact_email
  from customer_contact
  where (ltype = 'OWNER' and aid = acid) or
        (ltype = 'PROFILE' and aid = acid)
 union all
  select contact contact_mobile, contact_email billing_email,contact_email
  from manufacturer
  where ltype = 'MANUFACTURER' and manufacturer_id = acid
 union all
  select mobile_phone contact_mobile, contact_email billing_email,contact_email
  from photographer
  where ltype = 'PHOTOGRAPHER' and pid = acid;

 c1rec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
  sts		varchar2(100);
 owner_id	integer;
 c6rec		c6%ROWTYPE;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;
 zip_file       varchar2(1000);
 display_output GLBX.MYARRAY;
 bl		 boolean;

 begin
  glbx.cookie_id( surl, stype, ltype, owner_id, sts, call_type=>'S', progcalled=>'STRANGS.EMAIL_SAD_FILE_MULTI', ignore_cookie_check=>TRUE );
  c1rec := glbx.get_aid( owner_id, 'S', ltype );
  open c6(ltype,c1rec.aid);
  fetch c6 into c6rec;
  close c6;
  gcode(1) := NULL;
  gparam(1) := NULL;

  if dapi.GLOBAL_ARRAY.count > 0 and dapi.GLOBAL_ARRAY.count <= MAX_NON_ZIP_SAD
   then
    if send_files_smtp(p_from=>glbx.extract_master_parameter('MAIL_FROM'), p_to=>nvl(c6rec.billing_email,c6rec.contact_email), p_subj=>'SAD: ' || glbx.extract_fname(dapi.GLOBAL_ARRAY(dapi.GLOBAL_ARRAY.first)) || ' - ' || glbx.extract_fname(dapi.GLOBAL_ARRAY(dapi.GLOBAL_ARRAY.last))) then null; end if;
--    for j in dapi.GLOBAL_ARRAY.first..dapi.GLOBAL_ARRAY.last loop
--     bl := os_command.delete_file( dapi.GLOBAL_ARRAY(j), display_output );
--    end loop;
--    bl := os_command.delete_file( zip_file, display_output );
  elsif dapi.GLOBAL_ARRAY.count > MAX_NON_ZIP_SAD
   then
    zip_file := glbx.extract_fname(dapi.GLOBAL_ARRAY(1), 'PWD') || glbx.extract_fname(dapi.GLOBAL_ARRAY(1)) || '.zip';
    for j in dapi.GLOBAL_ARRAY.first..dapi.GLOBAL_ARRAY.last loop
     zip(zip_file, dapi.GLOBAL_ARRAY(j), move_files=>TRUE);
     null;
    end loop;
    -- glbx.send( gcode, gparam, glbx.extract_fname(zip_file, 'FILE'), p_to=>nvl(c6rec.billing_email,c6rec.contact_email), p_subj=>'SAD:' || dapi.GLOBAL_START_NUMBER || ' - ' || dapi.GLOBAL_END_NUMBER, p_from=>glbx.extract_master_parameter('MAIL_FROM'),is_report=>TRUE,ltype=>ltype,own_id=>owner_id, is_attachment=>TRUE);
    dapi.GLOBAL_ARRAY.delete;
    dapi.GLOBAL_ARRAY(1) := zip_file;
    if send_files_smtp(p_from=>glbx.extract_master_parameter('MAIL_FROM'), p_to=>nvl(c6rec.billing_email,c6rec.contact_email), p_subj=>'SAD: ' || dapi.GLOBAL_START_NUMBER || ' - ' || dapi.GLOBAL_END_NUMBER) then null; end if;
    bl := os_command.delete_file( zip_file, display_output );
  else
    glbx.dbg('STRANGS.EMAIL_SAD_FILE_MULTI. No files to send. File array count: ' || dapi.GLOBAL_ARRAY.count);
  end if;
 end email_sad_file_multi;

 procedure list_entry(surl in varchar2, msg in varchar2 default null, from_range in number default null, to_range in number default null )
 as

  cursor c1(frm number, frto number) is select * from strang.duty where entry_no >= frm and entry_no <= frto order by entry_no desc;
  cursor c2( ventry number) is
   select c.customer
   from strang.detailrs d, strang.receivals r, strang.customers c
   where d.entry_no = ventry and
         d.deliveryno = r.deliveryno and
         r.supplier_customer_id = c.customer_id;

  crec		customer_account%ROWTYPE;
  c2rec		c2%ROWTYPE;
  pfx		THEME%ROWTYPE;
  ltype		varchar2(100);
  stype		integer;
  owner_id	integer;
  vrecctr	integer;
  sts		varchar2(100);
  vaccess	varchar2(20);
  ttl		varchar2(200);
  seclevel	varchar2(100);
  val		varchar2(1000);

 begin
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGS.EDIT_ENTRY' );
   if sts is not null
    then
    glbx.redisplay_login_page( sts, TRUE );
    return;
   end if;
   vaccess := strangp.data_access( owner_id, 'DETAILRS', null );

  crec := glbx.get_aid( owner_id, 'C', ltype );
  pfx := glbx.get_thm( crec.theme_name );
  seclevel := oltp.security_role( owner_id );
  glbx.main_title( surl, 'SAD - Find Entry No',glbx.backimg(surl,crec.aid,pfx.text_back,crec.background_img,ltype),helpid=>'STR05',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, title_only=>TRUE);

  if msg is not null
   then
    htp.bold( msg );
    htp.nl;
  end if;

  if from_range is not null
   then
    htp.tableopen;
     htp.tablerowopen;
      htp.tabledata( htf.bold( 'Entry No' ) );
      htp.tabledata( htf.bold( 'Total Invoice' ) );
      htp.tabledata( htf.bold( 'Supplier Name' ) );
     htp.tablerowclose;
    for c1rec in c1(from_range, nvl(to_range,from_range)) loop
     htp.tablerowopen;
      htp.tabledata( htf.anchor( 'strangs.edit_entry?surl=' || surl || '&pk=' || c1rec.entry_no, c1rec.entry_no ));
      htp.tabledata( round(c1rec.total_invoice,2) );
      open c2( c1rec.entry_no );
      fetch c2 into c2rec;
      close c2;
      htp.tabledata( c2rec.customer );
     htp.tablerowclose;
    end loop;
    htp.tableclose;
  end if;

  htp.formopen( 'strangs.accept_list_entry' );
  htp.formhidden( 'SURL', surl );
  htp.tableopen;
   htp.tablerowopen;
    htp.tabledata( 'Range of Entries to View' );
    htp.tabledata( htf.formtext( 'P1', 10, 10 ) || ' to ' );
    htp.tabledata( htf.formtext( 'P2', 10, 10 ) );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( 'Specify Entry No' );
    htp.tabledata( htf.formtext( 'P3', 10, 10 ) );
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( null, 'Find Entry' );
  htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGS', 'LIST_ENTRY',null,owner_id,errmsg=>sqlerrm);
end list_entry;

 function guess_number( nmb in varchar2 )
  return number
 as
 begin
  return( to_number(nmb) );
 exception
  when others then return( null );
 end guess_number;

 procedure accept_list_entry(surl in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2 default null )
 as
 begin
  if guess_number(p1) is not null
   then
    list_entry(surl, from_range=>strang.ent.get_entry_no(guess_number(p1)), to_range=>strang.ent.get_entry_no(guess_number(p2)) );
    return;
  end if;
  if guess_number(p3) is not null
   then
    edit_entry( surl, strang.ent.get_entry_no(guess_number(p3)) );
    return;
  end if;

  list_entry( surl, 'Please specify Valid Entry No' );
 end accept_list_entry;

 procedure edit_entry(surl in varchar2, pk in varchar2, msg in varchar2 default null, oid in integer default null )
 as

  cursor c1( vowner varchar2,tname varchar2 ) is select * from all_tab_columns where owner = vowner and table_name = tname and column_name not in ('ENTRY_NO','ORDER_BY') order by column_id;
  cursor c2( vowner varchar2, tname varchar2, cname varchar2 ) is select comments from all_col_comments where owner = vowner and table_name = tname and column_name = cname;

  crec		customer_account%ROWTYPE;
  c2rec		c2%ROWTYPE;
  pfx		THEME%ROWTYPE;
  ltype		varchar2(100);
  stype		integer;
  owner_id	integer;
  vrecctr	integer;
  sts		varchar2(100);
  vaccess	varchar2(20);
  ttl		varchar2(200);
  seclevel	varchar2(100);
  val		varchar2(1000);
  vtariff	varchar2(100);
  vtbl		varchar2(100);

 begin
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGS.EDIT_ENTRY' );
   if sts is not null
    then
    glbx.redisplay_login_page( sts, TRUE );
    return;
   end if;
   vaccess := strangp.data_access( owner_id, 'DETAILRS', null );

  crec := glbx.get_aid( owner_id, 'C', ltype );
  pfx := glbx.get_thm( crec.theme_name );
  seclevel := oltp.security_role( owner_id );
  if oid is null
   then
    vtbl := 'SAD_GENERAL_DATA';
    glbx.main_title( surl, 'SAD - Entry No Verification for : ' || strang.ent.get_entry_no(pk,'X') || ' (customer ' || strang.ent2.ret_customer(pk) || ')',glbx.backimg(surl,crec.aid,pfx.text_back,crec.background_img,ltype),helpid=>'STR05',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, title_only=>TRUE);
   else
    for jrec in ctariff( pk ) loop
     vtariff := jrec.tariff;
     if oid = jrec.rnumb then exit; end if;
    end loop;
    vtbl := 'SAD_FOLLOWING';
    glbx.main_title( surl, 'SAD - Entry No Verification for : ' || strang.ent.get_entry_no(pk,'X') || ' Tariff: ' || vtariff  || ' (customer ' || strang.ent2.ret_customer(pk) || ')', glbx.backimg(surl,crec.aid,pfx.text_back,crec.background_img,ltype),helpid=>'STR05',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, title_only=>TRUE);
  end if;

  if msg is not null
   then
    htp.bold( msg );
    htp.nl;
  end if;

  htp.formopen( 'strangs.accept_edit_entry' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'PK', pk );
  htp.formhidden( 'OID', oid );
  htp.tableopen;
  for c1rec in c1( 'STRANG', vtbl ) loop
   htp.tablerowopen;
    if oid is null
     then
      htp.tabledata( htf.formhidden( 'P0', c1rec.column_name ) || htf.formhidden( 'P2', 'G' ) || htf.formhidden( 'P3', null ) || htf.bold( regexp_replace(c1rec.column_name,'(^SAD_)([0-9]{1,}[_])(.*)', '\3') ) );
     else
      htp.tabledata( htf.formhidden( 'P0', c1rec.column_name ) || htf.formhidden( 'P2', 'F' ) || htf.formhidden( 'P3', oid ) || htf.bold( regexp_replace(c1rec.column_name,'(^SAD_)([0-9]{1,}[_])(.*)', '\3') ) );
    end if;
    c2rec := null;
    open c2( 'STRANG', c1rec.table_name, c1rec.column_name );
    fetch c2 into c2rec;
    close c2;
    htp.tabledata( c2rec.comments, NULL );
    begin
     val := null;
     if oid is null
      then
       execute immediate 'select ' || c1rec.column_name || ' from strang.sad_general_data where entry_no = :pk' into val using pk;
      else
       execute immediate 'select ' || c1rec.column_name || ' from strang.sad_following where entry_no = :pk and order_by = :oid' into val using pk, oid;
     end if;
    exception
     when others then null;
    end;
    htp.tabledata( htf.formtext( 'P1', 30, 1000, val ) );
   htp.tablerowclose;
  end loop;

  htp.tableclose;
  htp.nl;
  if oid is null
   then
    htp.tableopen;
     htp.tablerowopen;
      htp.tabledata( htf.bold( 'Item' ) );
      htp.tabledata( htf.bold( 'Tariff' ) );
     htp.tablerowclose;
    for jrec in ctariff( pk ) loop
     htp.tablerowopen;
     htp.tablerowopen;
      htp.tabledata( jrec.rnumb );
      htp.tabledata( jrec.tariff );
      htp.tabledata( htf.anchor( 'strangs.edit_entry?surl=' || surl || '&pk=' || pk || '&oid=' || jrec.rnumb, '[Edit]' ) );
     htp.tablerowclose;
     htp.tablerowclose;
    end loop;
    htp.tableclose;
    htp.nl;
    htp.formsubmit( 'ACTION', 'Cancel and Return' );
    htp.formsubmit( 'ACTION', 'Save Details' );
    htp.formsubmit( 'ACTION', 'Save and Generate SAD' );
   else
    htp.formsubmit( 'ACTION', 'Cancel and Return' );
    htp.formsubmit( 'ACTION', 'Save Details' );
    htp.formsubmit( 'ACTION', 'Save Details and Return' );
  end if;
  htp.formclose;
  htp.formsubmit( cvalue =>'Cancel', cattributes => 'onclick="self.close()"' );

 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGS', 'EDIT_ENTRY',null,owner_id,errmsg=>sqlerrm);
end edit_entry;

procedure accept_edit_entry( surl in varchar2, pk in varchar2, oid in integer, p0 in glbx.myarray, p1 in glbx.myarray, p2 in glbx.myarray, p3 in glbx.myarray, action in varchar2 )
as

  crec		customer_account%ROWTYPE;
  pfx		THEME%ROWTYPE;
  ltype		varchar2(100);
  stype		integer;
  owner_id	integer;
  vrecctr	integer;
  sts		varchar2(100);
  vaccess	varchar2(20);
  ttl		varchar2(200);
  seclevel	varchar2(100);
  val		varchar2(1000);
  msg	        varchar2(1000);

 begin
   glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGS.ACCEPT_EDIT_ENTRY' );
   if sts is not null
    then
    glbx.redisplay_login_page( sts, TRUE );
    return;
   end if;
   vaccess := strangp.data_access( owner_id, 'DETAILRS', null );

  crec := glbx.get_aid( owner_id, 'C', ltype );
  pfx := glbx.get_thm( crec.theme_name );
  seclevel := oltp.security_role( owner_id );

  if upper(action) = 'CANCEL AND RETURN'
   then
    if oid is not null then
     edit_entry( surl, pk, 'ACTION CANCELLED' );
    else
     edit_entry( surl, pk, 'ACTION CANCELLED', oid );
    end if;
    return;
  end if;

  for j in p0.first..p0.last loop
   begin
    if p2(j) = 'G'
     then
      execute immediate 'update strang.sad_general_data set ' || p0(j) || ' = ''' || p1(j) || ''' where entry_no = :pk' using pk;
    elsif p2(j) = 'F'
     then
      execute immediate 'update strang.sad_following set ' || p0(j) || ' = ''' || p1(j) || ''' where entry_no = :pk and order_by = :op' using pk, p3(j);
    end if;
   exception
    when others then glbx.dbg( 'Err on ' || p0(j) || '-' || p1(j) );
   end;
  end loop;

  if action = 'Save and Generate SAD'
   then
    generate_sad(pk, msg, 2, FALSE);
    edit_entry(surl, pk, msg );
  elsif action = 'Save Details and Return' or oid is null
   then
    edit_entry(surl, pk, 'Action Performed' );
   else
    edit_entry(surl, pk, 'Action Performed', oid );
  end if;

exception when others then
 glbx.error_details( 'STRANGS', 'ACCEPT_EDIT_ENTRY',null,owner_id,errmsg=>sqlerrm);
end accept_edit_entry;

function sad_generate_form15( pk in varchar2 )
 return varchar2
as

  gen_rec	strang.sad_general_data%ROWTYPE;
  fol_rec	strang.sad_following%ROWTYPE;
  max_loop	integer;
  vcust		varchar2(1000);
  vdebug	varchar2(100);

 begin


   vdebug := 'Start-0';
   gen_rec.entry_no		  := pk;
   gen_rec.sad_004_nb_valuation_import := null;
   gen_rec.sad_005_nb_valuation_export := null;
   vdebug := 'Start-10';
   gen_rec.sad_010_nb_transit_route := null;
   gen_rec.sad_011_nb_items_segment := null;
   gen_rec.sad_012_nb_taxes	  := null;
   gen_rec.sad_013_import_val_note := null;
   gen_rec.sad_014_user_year	  := f15_parameter_range( '', pk, vcust );
   vdebug := 'Start-15';
   gen_rec.sad_015_cuo_cod	  := null;
   gen_rec.sad_016_declarant	  := f15_parameter_range( 'AD', pk, vcust );
   gen_rec.sad_017_user_nber	  := null;
   vdebug := 'Start-18';
   gen_rec.sad_018_not_defined	  := null;
   gen_rec.sad_019_typ_dec	  := f15_parameter_range( 'AS', pk, vcust );
   vdebug := 'Start-20';
   gen_rec.sad_020_typ_proc	  := null;
   gen_rec.sad_021_typ_transit	  := null;
   gen_rec.sad_022_exporter	  := null;
   gen_rec.sad_023_manif_nber	  := null;
   gen_rec.sad_024_lst_nber	  := null;
   gen_rec.sad_025_reg_serial	  := null;
   gen_rec.sad_026_reg_nber	  := null;
   gen_rec.sad_027_reg_date	  := null;
   gen_rec.sad_028_itm_total	  := f15_parameter_range( 'A00', pk, vcust );
   gen_rec.sad_029_pack_total	  := f15_parameter_range( 'A000', pk, vcust );
   vdebug := 'Start-30';
   gen_rec.sad_030_consignee	  := null;
   gen_rec.sad_031_financial	  := f15_parameter_range( 'AH', pk, vcust );
   gen_rec.sad_032_cty_1dlp	  := 'AU';
   gen_rec.sad_033_tra_cty	  := 'AU';
   gen_rec.sad_034_val_details	  := null;
   gen_rec.sad_035_cap_ref	  := null;
   gen_rec.sad_036_cty_expcod	  := 'AU';
   gen_rec.sad_037_cty_expreg	  := f15_parameter_range( '000A', pk, vcust );
   gen_rec.sad_038_cty_destcod	  := null;
   gen_rec.sad_039_cty_destreg	  := 'PAPUA NEW GUINEA';
   vdebug := 'Start-40';
   gen_rec.sad_040_trsp_iddepar	  := null;
   gen_rec.sad_041_trsp_natdepar  := null;
   gen_rec.sad_042_ctnr_flag	  := '1';
   gen_rec.sad_043_tod_cod	  := f15_parameter_range( 'A8', pk, vcust );
   gen_rec.sad_044_tod_nam	  := null;
   gen_rec.sad_045_tod_sit	  := null;
   gen_rec.sad_046_trsp_idbord	  := null;
   gen_rec.sad_047_trspnatbord	  := null;
   gen_rec.sad_048_cur_cod	  := f15_parameter_range( 'AF', pk, vcust );
   gen_rec.sad_049_tot_invoiced	  := f15_parameter_range( 'AE', pk, vcust );
   vdebug := 'Start-50';
   gen_rec.sad_050_tra_cod1	  := null;
   gen_rec.sad_051_tra_cod2	  := null;
   gen_rec.sad_052_mot_bord	  := '1';
   gen_rec.sad_053_mot_inland	  := null;
   gen_rec.sad_054_lop_cod	  := f15_parameter_range( 'AB', pk, vcust );
   gen_rec.sad_055_top_cod	  := null;
   gen_rec.sad_056_cuo_bord	  := null;
   gen_rec.sad_057_loc_goods	  := f15_parameter_range( 'A3', pk, vcust );
   gen_rec.sad_058_bnk_cod	  := null;
   gen_rec.sad_059_bnk_bra	  := null;
   vdebug := 'Start-60';
   gen_rec.sad_060_bnk_fnber	  := null;
   gen_rec.sad_061_def_pay	  := null;
   gen_rec.sad_062_whs_cod	  := null;
   gen_rec.sad_063_whs_time	  := null;
   gen_rec.sad_064_total_sdi	  := null;
   gen_rec.sad_065_asmt_serial	  := null;
   gen_rec.sad_066_asmt_nber	  := null;
   gen_rec.sad_067_asmt_date	  := null;
   gen_rec.sad_068_rcpt_serial	  := null;
   gen_rec.sad_069_rcpt_nber	  := null;
   vdebug := 'Start-70';
   gen_rec.sad_070_rcpt_date	  := null;
   gen_rec.sad_071_grty_amount	  := null;
   gen_rec.sad_072_grty_date	  := null;
   gen_rec.sad_073_tot_fees	  := null;
   gen_rec.sad_074_total_taxes	  := null;
   gen_rec.sad_075_ctrl_results	  := null;
   gen_rec.sad_076_dec_place	  := null;
   gen_rec.sad_077_dec_date	  := null;
   gen_rec.sad_078_dec_repnam	  := null;
   gen_rec.sad_079_cof_nam	  := null;
   vdebug := 'Start-80';
   gen_rec.sad_080_not_defined	  := null;
   gen_rec.sad_081_etotinv_valc	  := null;
   gen_rec.sad_082_etotinv_cur	  := null;
   gen_rec.sad_083_etotinv_rat	  := f15_parameter_range( 'A9', pk, vcust );
   gen_rec.sad_084_etotinv_ref	  := null;
   gen_rec.sad_085_etotinv_valn	  := null;
   gen_rec.sad_086_etotifr_valc	  := null;
   gen_rec.sad_087_etotifr_cur	  := null;
   gen_rec.sad_088_etotifr_rat	  := f15_parameter_range( 'A9', pk, vcust );
   gen_rec.sad_089_etotifr_ref	  := null;
   vdebug := 'Start-90';
   gen_rec.sad_090_etotifr_valn	  := null;
   gen_rec.sad_091_etotded_valc	  := null;
   gen_rec.sad_092_etotded_cur	  := null;
   gen_rec.sad_093_etotded_rat	  := f15_parameter_range( 'A9', pk, vcust );
   gen_rec.sad_094_etotded_ref	  := null;
   gen_rec.sad_095_etotdef_valn	  := null;
   gen_rec.sad_096_etotadd_cst	  := null;
   gen_rec.sad_097_etotgros_mass  := null;
   gen_rec.sad_098_efob_valn	  := f15_parameter_range( 'A9', pk, vcust );
   gen_rec.sad_081_itotinv_valc	  := null;
   gen_rec.sad_082_itotinv_cur	  := null;
   gen_rec.sad_083_itotinv_rat	  := f15_parameter_range( 'A9', pk, vcust );
   gen_rec.sad_084_itotinv_ref	  := null;
   gen_rec.sad_085_itotinv_valn	  := null;
   gen_rec.sad_086_itotefr_valc	  := null;
   gen_rec.sad_087_itotefr_cur	  := null;
   gen_rec.sad_088_itotefr_rat	  := f15_parameter_range( 'A9', pk, vcust );
   gen_rec.sad_089_itotefr_ref	  := null;
   vdebug := 'Start-90b';
   gen_rec.sad_090_itotefr_valn	  := null;
   gen_rec.sad_091_itotins_valc	  := null;
   gen_rec.sad_092_itotins_cur	  := null;
   gen_rec.sad_093_itotins_rat	  := f15_parameter_range( 'A9', pk, vcust );
   gen_rec.sad_094_itotins_ref	  := null;
   gen_rec.sad_095_itotins_valn	  := null;
   gen_rec.SAD_096_ITOTOTC_VALC	  := null;
   gen_rec.sad_097_itototc_cur	  := null;
   gen_rec.SAD_098_ITOTOTC_RAT	  := f15_parameter_range( 'A9', pk, vcust );
   gen_rec.SAD_098_ITOTOTC_RAT	  := null;
   vdebug := 'Start-100';
   gen_rec.SAD_100_ITOTOTC_VALN	  := null;
   gen_rec.sad_101_itotifr_valc	  := null;
   gen_rec.sad_102_itotifr_cur	  := null;
   gen_rec.sad_103_itotifr_rat	  := null;
   gen_rec.SAD_104_ITOTIFR_REF	  := null;
   gen_rec.sad_105_itotifr_valn	  := null;
   gen_rec.sad_106_itotded_valc	  := null;
   gen_rec.sad_107_itotded_cur	  := null;
   gen_rec.sad_108_itotded_rat	  := null;
   gen_rec.sad_109_itotded_ref	  := null;
   vdebug := 'Start-110';
   gen_rec.sad_110_itotded_valn	  := null;
   gen_rec.sad_111_itotadd_cst	  := null;
   gen_rec.sad_112_icif_valn	  := null;
   gen_rec.sad_113_itotgros_mass  := null;
   gen_rec.sad_114_itotstat_val	  := null;
   gen_rec.sad_115_exp_nam	  := f15_parameter_range( 'A4', pk, vcust );
   gen_rec.sad_116_exp_add1	  := null;
   gen_rec.sad_117_exp_add2	  := null;
   gen_rec.sad_118_exp_city	  := null;
   gen_rec.sad_119_exp_zip	  := null;
   vdebug := 'Start-120';
   gen_rec.sad_120_con_nam	  := f15_parameter_range( 'A6', pk, vcust );
   gen_rec.sad_121_con_add1	  := f15_parameter_range( 'A6', pk, vcust );
   gen_rec.sad_122_con_add2	  := null;
   gen_rec.sad_123_con_city	  := null;
   gen_rec.sad_124_con_zip	  := f15_parameter_range( 'A6', pk, vcust );
   gen_rec.sad_125_fin_nam	  := null;
   gen_rec.sad_126_fin_add	  := null;
   gen_rec.sad_127_fin_city	  := null;
   gen_rec.sad_128_dec_nam	  := f15_parameter_range( 'AC', pk, vcust );
   gen_rec.sad_129_dec_add	  := null;
   gen_rec.sad_130_dec_city	  := null;

   ins_gen_rec( gen_rec );

   max_loop := f15_parameter_range( 'A0', pk, vcust );
   vdebug := 'Start-followup-B';
   for jrec in ctariff( pk ) loop
    vdebug := 'Start-followup-B:' || jrec.rnumb;
    fol_rec := null;

    -- form_15_continue( '', pk, jrec.tariff, jrec.rnumb, max_loop );
    fol_rec.entry_no		 := pk;
    fol_rec.order_by		 := jrec.rnumb;
    vdebug := 'Start-130:' || jrec.rnumb;
    fol_rec.sad_131_itm_nber	 := null;
    fol_rec.sad_132_pack_mark1	 := null;
    fol_rec.sad_133_pack_mark2	 := null;
    fol_rec.sad_134_hs_cod	 := null;
    fol_rec.sad_135_hsprec_cod	 := null;
    fol_rec.sad_136_undefined1	 := null;
    fol_rec.sad_137_undefined2	 := null;
    fol_rec.sad_138_tar_spc	 := null;
    fol_rec.sad_139_goods_desc1	 := f15_parameter_range( 'AWWWWW', pk, vcust );
    vdebug := 'Start-140:' || jrec.rnumb;
    fol_rec.sad_140_goods_desc2	 := f15_parameter_range( 'AWWWWW', pk, vcust );
    fol_rec.sad_141_goods_desc3	 := f15_parameter_range( 'AWWWWW', pk, vcust );
    fol_rec.sad_142_pack_nber	 := null;
    fol_rec.sad_143_pack_kindcod	 := null;
    fol_rec.sad_144_cty_origcod	 := null;
    fol_rec.sad_145_cty_origreg	 := null;
    fol_rec.sad_146_gross_mass	 := null;
    fol_rec.sad_147_prefer_cod	 := null;
    fol_rec.sad_148_ctnr_nber1	 := f15_parameter_range( 'AWWWW', pk, vcust );
    fol_rec.sad_149_ctnr_nber2	 := f15_parameter_range( 'AWWWW', pk, vcust );
    vdebug := 'Start-150:' || jrec.rnumb;
    fol_rec.sad_150_ctnr_nber3	 := f15_parameter_range( 'AWWWW', pk, vcust );
    fol_rec.SAD_151_CTNR_NBER4	 := f15_parameter_range( 'AWWWW', pk, vcust );
    vdebug := 'Start-152:' || jrec.rnumb;
    fol_rec.sad_152_extd_proc	 := form_15_continue( 'G1', pk, jrec.tariff, jrec.rnumb, max_loop );
    vdebug := 'Start-153:' || jrec.rnumb;
    fol_rec.sad_153_nat_proc	 := form_15_continue( 'G2', pk, jrec.tariff, jrec.rnumb, max_loop );
    vdebug := 'Start-154:' || jrec.rnumb;
    fol_rec.sad_154_net_mass	 := form_15_continue( 'G3', pk, jrec.tariff, jrec.rnumb, max_loop );
    fol_rec.sad_155_quota	 := null;
    fol_rec.sad_156_trsp_doc	 := null;
    fol_rec.sad_157_supp_units	 := null;
    fol_rec.sad_158_itm_price	 := null;
    fol_rec.sad_159_val_method	 := null;
    vdebug := 'Start-160:' || jrec.rnumb;
    fol_rec.sad_160_lic_nber	 := null;
    fol_rec.sad_161_dval_amount	 := null;
    fol_rec.sad_162_dqty		 := null;
    fol_rec.sad_163_value_details := null;
    fol_rec.sad_164_ai_cod	 := null;
    fol_rec.sad_165_adj_rate	 := null;
    fol_rec.sad_166_prev_doc	 := null;
    fol_rec.sad_167_prev_whscod	 := null;
    fol_rec.sad_168_free_text	 := null;
    fol_rec.sad_169_reserved	 := null;
    vdebug := 'Start-170:' || jrec.rnumb;
    fol_rec.sad_170_stat_val	 := null;
    fol_rec.sad_171_itm_totamt	 := null;
    fol_rec.sad_172_itm_totmop	 := null;
    fol_rec.sad_173_att_documents := null;
    fol_rec.SAD_174_IITMSUP_VAL1	 := null;
    fol_rec.SAD_175_IITMSUP_VAL2	 := null;



  ins_fol_rec( fol_rec );
 end loop;

 commit;
 return( 'Staging table populated' );

exception when others then
 return( 'Failed: ' || sqlerrm || '. At:' || vdebug);
end sad_generate_form15;


procedure ins_gen_rec( gen_rec strang.sad_general_data%ROWTYPE )
as
  cursor c1( vpk integer ) is select 'x' exst from strang.sad_following where entry_no = vpk;
  c1rec c1%ROWTYPE;
begin
  open c1(gen_rec.entry_no);
  fetch c1 into c1rec;
  if c1%FOUND
   then
    close c1;
    update strang.sad_general_data
    set    row = gen_rec
    where  entry_no = gen_rec.entry_no;

/*
     set
         sad_004_nb_valuation_import    =  gen_rec.sad_004_nb_valuation_import,
         sad_005_nb_valuation_export    =  gen_rec.sad_005_nb_valuation_export,
         sad_010_nb_transit_route	=  gen_rec.sad_010_nb_transit_route	,
         sad_011_nb_items_segment	=  gen_rec.sad_011_nb_items_segment	,
         sad_012_nb_taxes		=  gen_rec.sad_012_nb_taxes		,
         sad_013_import_val_note	=  gen_rec.sad_013_import_val_note	,
         sad_014_user_year		=  gen_rec.sad_014_user_year		,
         sad_015_cuo_cod		=  gen_rec.sad_015_cuo_cod		,
         sad_016_declarant		=  gen_rec.sad_016_declarant		,
         sad_017_user_nber		=  gen_rec.sad_017_user_nber		,
         sad_018_not_defined		=  gen_rec.sad_018_not_defined		,
         sad_019_typ_dec		=  gen_rec.sad_019_typ_dec		,
         sad_020_typ_proc		=  gen_rec.sad_020_typ_proc		,
         sad_021_typ_transit		=  gen_rec.sad_021_typ_transit		,
         sad_022_exporter		=  gen_rec.sad_022_exporter		,
         sad_023_manif_nber		=  gen_rec.sad_023_manif_nber		,
         sad_024_lst_nber		=  gen_rec.sad_024_lst_nber		,
         sad_025_reg_serial		=  gen_rec.sad_025_reg_serial		,
         sad_026_reg_nber		=  gen_rec.sad_026_reg_nber		,
         sad_027_reg_date		=  gen_rec.sad_027_reg_date		,
         sad_028_itm_total		=  gen_rec.sad_028_itm_total		,
         sad_029_pack_total		=  gen_rec.sad_029_pack_total		,
         sad_030_consignee		=  gen_rec.sad_030_consignee		,
         sad_031_financial		=  gen_rec.sad_031_financial		,
         sad_032_cty_1dlp		=  gen_rec.sad_032_cty_1dlp		,
         sad_033_tra_cty		=  gen_rec.sad_033_tra_cty		,
         sad_034_val_details		=  gen_rec.sad_034_val_details		,
         sad_035_cap_ref		=  gen_rec.sad_035_cap_ref		,
         sad_036_cty_expcod		=  gen_rec.sad_036_cty_expcod		,
         sad_037_cty_expreg		=  gen_rec.sad_037_cty_expreg		,
         sad_038_cty_destcod		=  gen_rec.sad_038_cty_destcod		,
         sad_039_cty_destreg		=  gen_rec.sad_039_cty_destreg		,
         sad_040_trsp_iddepar		=  gen_rec.sad_040_trsp_iddepar		,
         sad_041_trsp_natdepar		=  gen_rec.sad_041_trsp_natdepar	,
         sad_042_ctnr_flag		=  gen_rec.sad_042_ctnr_flag		,
         sad_043_tod_cod		=  gen_rec.sad_043_tod_cod		,
         sad_044_tod_nam		=  gen_rec.sad_044_tod_nam		,
         sad_045_tod_sit		=  gen_rec.sad_045_tod_sit		,
         sad_046_trsp_idbord		=  gen_rec.sad_046_trsp_idbord		,
         sad_047_trspnatbord		=  gen_rec.sad_047_trspnatbord		,
         sad_048_cur_cod		=  gen_rec.sad_048_cur_cod		,
         sad_049_tot_invoiced		=  gen_rec.sad_049_tot_invoiced		,
         sad_050_tra_cod1		=  gen_rec.sad_050_tra_cod1		,
         sad_051_tra_cod2		=  gen_rec.sad_051_tra_cod2		,
         sad_052_mot_bord		=  gen_rec.sad_052_mot_bord		,
         sad_053_mot_inland		=  gen_rec.sad_053_mot_inland		,
         sad_054_lop_cod		=  gen_rec.sad_054_lop_cod		,
         sad_055_top_cod		=  gen_rec.sad_055_top_cod		,
         sad_056_cuo_bord		=  gen_rec.sad_056_cuo_bord		,
         sad_057_loc_goods		=  gen_rec.sad_057_loc_goods		,
         sad_058_bnk_cod		=  gen_rec.sad_058_bnk_cod		,
         sad_059_bnk_bra		=  gen_rec.sad_059_bnk_bra		,
         sad_060_bnk_fnber		=  gen_rec.sad_060_bnk_fnber		,
         sad_061_def_pay		=  gen_rec.sad_061_def_pay		,
         sad_062_whs_cod		=  gen_rec.sad_062_whs_cod		,
         sad_063_whs_time		=  gen_rec.sad_063_whs_time		,
         sad_064_total_sdi		=  gen_rec.sad_064_total_sdi		,
         sad_065_asmt_serial		=  gen_rec.sad_065_asmt_serial		,
         sad_066_asmt_nber		=  gen_rec.sad_066_asmt_nber		,
         sad_067_asmt_date		=  gen_rec.sad_067_asmt_date		,
         sad_068_rcpt_serial		=  gen_rec.sad_068_rcpt_serial		,
         sad_069_rcpt_nber		=  gen_rec.sad_069_rcpt_nber		,
         sad_070_rcpt_date		=  gen_rec.sad_070_rcpt_date		,
         sad_071_grty_amount		=  gen_rec.sad_071_grty_amount		,
         sad_072_grty_date		=  gen_rec.sad_072_grty_date		,
         sad_073_tot_fees		=  gen_rec.sad_073_tot_fees		,
         sad_074_total_taxes		=  gen_rec.sad_074_total_taxes		,
         sad_075_ctrl_results		=  gen_rec.sad_075_ctrl_results		,
         sad_076_dec_place		=  gen_rec.sad_076_dec_place		,
         sad_077_dec_date		=  gen_rec.sad_077_dec_date		,
         sad_078_dec_repnam		=  gen_rec.sad_078_dec_repnam		,
         sad_079_cof_nam		=  gen_rec.sad_079_cof_nam		,
         sad_080_not_defined		=  gen_rec.sad_080_not_defined		,
         sad_081_etotinv_valc		=  gen_rec.sad_081_etotinv_valc		,
         sad_082_etotinv_cur		=  gen_rec.sad_082_etotinv_cur		,
         sad_083_etotinv_rat		=  gen_rec.sad_083_etotinv_rat		,
         sad_084_etotinv_ref		=  gen_rec.sad_084_etotinv_ref		,
         sad_085_etotinv_valn		=  gen_rec.sad_085_etotinv_valn		,
         sad_086_etotifr_valc		=  gen_rec.sad_086_etotifr_valc		,
         sad_087_etotifr_cur		=  gen_rec.sad_087_etotifr_cur		,
         sad_088_etotifr_rat		=  gen_rec.sad_088_etotifr_rat		,
         sad_089_etotifr_ref		=  gen_rec.sad_089_etotifr_ref		,
         sad_090_etotifr_valn		=  gen_rec.sad_090_etotifr_valn		,
         sad_091_etotded_valc		=  gen_rec.sad_091_etotded_valc		,
         sad_092_etotded_cur		=  gen_rec.sad_092_etotded_cur		,
         sad_093_etotded_rat		=  gen_rec.sad_093_etotded_rat		,
         sad_094_etotded_ref		=  gen_rec.sad_094_etotded_ref		,
         sad_095_etotdef_valn		=  gen_rec.sad_095_etotdef_valn		,
         sad_096_etotadd_cst		=  gen_rec.sad_096_etotadd_cst		,
         sad_097_etotgros_mass	=  gen_rec.sad_097_etotgros_mass	,
         sad_098_efob_valn		=  gen_rec.sad_098_efob_valn		,
         sad_081_itotinv_valc		=  gen_rec.sad_081_itotinv_valc		,
         sad_082_itotinv_cur		=  gen_rec.sad_082_itotinv_cur		,
         sad_083_itotinv_rat		=  gen_rec.sad_083_itotinv_rat		,
         sad_084_itotinv_ref		=  gen_rec.sad_084_itotinv_ref		,
         sad_085_itotinv_valn		=  gen_rec.sad_085_itotinv_valn		,
         sad_086_itotefr_valc		=  gen_rec.sad_086_itotefr_valc		,
         sad_087_itotefr_cur		=  gen_rec.sad_087_itotefr_cur		,
         sad_088_itotefr_rat		=  gen_rec.sad_088_itotefr_rat		,
         sad_089_itotefr_ref		=  gen_rec.sad_089_itotefr_ref		,
         sad_090_itotefr_valn		=  gen_rec.sad_090_itotefr_valn		,
         sad_091_itotins_valc		=  gen_rec.sad_091_itotins_valc		,
         sad_092_itotins_cur		=  gen_rec.sad_092_itotins_cur		,
         sad_093_itotins_rat		=  gen_rec.sad_093_itotins_rat		,
         sad_094_itotins_ref		=  gen_rec.sad_094_itotins_ref		,
         sad_095_itotins_valn		=  gen_rec.sad_095_itotins_valn		,
         SAD_096_ITOTOTC_VALC		=  gen_rec.SAD_096_ITOTOTC_VALC		,
         sad_097_itototc_cur		=  gen_rec.sad_097_itototc_cur		,
         SAD_098_ITOTOTC_RAT		=  gen_rec.SAD_098_ITOTOTC_RAT		,
         SAD_100_ITOTOTC_VALN		=  gen_rec.SAD_100_ITOTOTC_VALN		,
         sad_101_itotifr_valc		=  gen_rec.sad_101_itotifr_valc		,
         sad_102_itotifr_cur		=  gen_rec.sad_102_itotifr_cur		,
         sad_103_itotifr_rat		=  gen_rec.sad_103_itotifr_rat		,
         SAD_104_ITOTIFR_REF		=  gen_rec.SAD_104_ITOTIFR_REF		,
         sad_105_itotifr_valn		=  gen_rec.sad_105_itotifr_valn		,
         sad_106_itotded_valc		=  gen_rec.sad_106_itotded_valc		,
         sad_107_itotded_cur		=  gen_rec.sad_107_itotded_cur		,
         sad_108_itotded_rat		=  gen_rec.sad_108_itotded_rat		,
         sad_109_itotded_ref		=  gen_rec.sad_109_itotded_ref		,
         sad_110_itotded_valn		=  gen_rec.sad_110_itotded_valn		,
         sad_111_itotadd_cst		=  gen_rec.sad_111_itotadd_cst		,
         sad_112_icif_valn		=  gen_rec.sad_112_icif_valn		,
         sad_113_itotgros_mass		=  gen_rec.sad_113_itotgros_mass	,
         sad_114_itotstat_val		=  gen_rec.sad_114_itotstat_val		,
         sad_115_exp_nam		=  gen_rec.sad_115_exp_nam		,
         sad_116_exp_add1		=  gen_rec.sad_116_exp_add1		,
         sad_117_exp_add2		=  gen_rec.sad_117_exp_add2		,
         sad_118_exp_city		=  gen_rec.sad_118_exp_city		,
         sad_119_exp_zip		=  gen_rec.sad_119_exp_zip		,
         sad_120_con_nam		=  gen_rec.sad_120_con_nam		,
         sad_121_con_add1		=  gen_rec.sad_121_con_add1		,
         sad_122_con_add2		=  gen_rec.sad_122_con_add2		,
         sad_123_con_city		=  gen_rec.sad_123_con_city		,
         sad_124_con_zip		=  gen_rec.sad_124_con_zip		,
         sad_125_fin_nam		=  gen_rec.sad_125_fin_nam		,
         sad_126_fin_add		=  gen_rec.sad_126_fin_add		,
         sad_127_fin_city		=  gen_rec.sad_127_fin_city		,
         sad_128_dec_nam		=  gen_rec.sad_128_dec_nam		,
         sad_129_dec_add		=  gen_rec.sad_129_dec_add		,
         sad_130_dec_city		=  gen_rec.sad_130_dec_city
   where
     entry_no = gen_rec.entry_no;
*/
    return;
  end if;
  close c1;
  insert into strang.sad_general_data
  values gen_rec;
/*
  (
   entry_no			,
   sad_004_nb_valuation_import  ,
   sad_005_nb_valuation_export  ,
   sad_010_nb_transit_route	,
   sad_011_nb_items_segment	,
   sad_012_nb_taxes		,
   sad_013_import_val_note	,
   sad_014_user_year		,
   sad_015_cuo_cod		,
   sad_016_declarant		,
   sad_017_user_nber		,
   sad_018_not_defined		,
   sad_019_typ_dec		,
   sad_020_typ_proc		,
   sad_021_typ_transit		,
   sad_022_exporter		,
   sad_023_manif_nber		,
   sad_024_lst_nber		,
   sad_025_reg_serial		,
   sad_026_reg_nber		,
   sad_027_reg_date		,
   sad_028_itm_total		,
   sad_029_pack_total		,
   sad_030_consignee		,
   sad_031_financial		,
   sad_032_cty_1dlp		,
   sad_033_tra_cty		,
   sad_034_val_details		,
   sad_035_cap_ref		,
   sad_036_cty_expcod		,
   sad_037_cty_expreg		,
   sad_038_cty_destcod		,
   sad_039_cty_destreg		,
   sad_040_trsp_iddepar		,
   sad_041_trsp_natdepar	,
   sad_042_ctnr_flag		,
   sad_043_tod_cod		,
   sad_044_tod_nam		,
   sad_045_tod_sit		,
   sad_046_trsp_idbord		,
   sad_047_trspnatbord		,
   sad_048_cur_cod		,
   sad_049_tot_invoiced		,
   sad_050_tra_cod1		,
   sad_051_tra_cod2		,
   sad_052_mot_bord		,
   sad_053_mot_inland		,
   sad_054_lop_cod		,
   sad_055_top_cod		,
   sad_056_cuo_bord		,
   sad_057_loc_goods		,
   sad_058_bnk_cod		,
   sad_059_bnk_bra		,
   sad_060_bnk_fnber		,
   sad_061_def_pay		,
   sad_062_whs_cod		,
   sad_063_whs_time		,
   sad_064_total_sdi		,
   sad_065_asmt_serial		,
   sad_066_asmt_nber		,
   sad_067_asmt_date		,
   sad_068_rcpt_serial		,
   sad_069_rcpt_nber		,
   sad_070_rcpt_date		,
   sad_071_grty_amount		,
   sad_072_grty_date		,
   sad_073_tot_fees		,
   sad_074_total_taxes		,
   sad_075_ctrl_results		,
   sad_076_dec_place		,
   sad_077_dec_date		,
   sad_078_dec_repnam		,
   sad_079_cof_nam		,
   sad_080_not_defined		,
   sad_081_etotinv_valc		,
   sad_082_etotinv_cur		,
   sad_083_etotinv_rat		,
   sad_084_etotinv_ref		,
   sad_085_etotinv_valn		,
   sad_086_etotifr_valc		,
   sad_087_etotifr_cur		,
   sad_088_etotifr_rat		,
   sad_089_etotifr_ref		,
   sad_090_etotifr_valn		,
   sad_091_etotded_valc		,
   sad_092_etotded_cur		,
   sad_093_etotded_rat		,
   sad_094_etotded_ref		,
   sad_095_etotdef_valn		,
   sad_096_etotadd_cst		,
   sad_097_etotgros_mass	,
   sad_098_efob_valn		,
   sad_081_itotinv_valc		,
   sad_082_itotinv_cur		,
   sad_083_itotinv_rat		,
   sad_084_itotinv_ref		,
   sad_085_itotinv_valn		,
   sad_086_itotefr_valc		,
   sad_087_itotefr_cur		,
   sad_088_itotefr_rat		,
   sad_089_itotefr_ref		,
   sad_090_itotefr_valn		,
   sad_091_itotins_valc		,
   sad_092_itotins_cur		,
   sad_093_itotins_rat		,
   sad_094_itotins_ref		,
   sad_095_itotins_valn		,
   SAD_096_ITOTOTC_VALC		,
   sad_097_itototc_cur		,
   SAD_098_ITOTOTC_RAT		,
   SAD_100_ITOTOTC_VALN		,
   sad_101_itotifr_valc		,
   sad_102_itotifr_cur		,
   sad_103_itotifr_rat		,
   SAD_104_ITOTIFR_REF		,
   sad_105_itotifr_valn		,
   sad_106_itotded_valc		,
   sad_107_itotded_cur		,
   sad_108_itotded_rat		,
   sad_109_itotded_ref		,
   sad_110_itotded_valn		,
   sad_111_itotadd_cst		,
   sad_112_icif_valn		,
   sad_113_itotgros_mass	,
   sad_114_itotstat_val		,
   sad_115_exp_nam		,
   sad_116_exp_add1		,
   sad_117_exp_add2		,
   sad_118_exp_city		,
   sad_119_exp_zip		,
   sad_120_con_nam		,
   sad_121_con_add1		,
   sad_122_con_add2		,
   sad_123_con_city		,
   sad_124_con_zip		,
   sad_125_fin_nam		,
   sad_126_fin_add		,
   sad_127_fin_city		,
   sad_128_dec_nam		,
   sad_129_dec_add		,
   sad_130_dec_city
)
  values
  (
   gen_rec.entry_no			,
   gen_rec.sad_004_nb_valuation_import  ,
   gen_rec.sad_005_nb_valuation_export  ,
   gen_rec.sad_010_nb_transit_route	,
   gen_rec.sad_011_nb_items_segment	,
   gen_rec.sad_012_nb_taxes		,
   gen_rec.sad_013_import_val_note	,
   gen_rec.sad_014_user_year		,
   gen_rec.sad_015_cuo_cod		,
   gen_rec.sad_016_declarant		,
   gen_rec.sad_017_user_nber		,
   gen_rec.sad_018_not_defined		,
   gen_rec.sad_019_typ_dec		,
   gen_rec.sad_020_typ_proc		,
   gen_rec.sad_021_typ_transit		,
   gen_rec.sad_022_exporter		,
   gen_rec.sad_023_manif_nber		,
   gen_rec.sad_024_lst_nber		,
   gen_rec.sad_025_reg_serial		,
   gen_rec.sad_026_reg_nber		,
   gen_rec.sad_027_reg_date		,
   gen_rec.sad_028_itm_total		,
   gen_rec.sad_029_pack_total		,
   gen_rec.sad_030_consignee		,
   gen_rec.sad_031_financial		,
   gen_rec.sad_032_cty_1dlp		,
   gen_rec.sad_033_tra_cty		,
   gen_rec.sad_034_val_details		,
   gen_rec.sad_035_cap_ref		,
   gen_rec.sad_036_cty_expcod		,
   gen_rec.sad_037_cty_expreg		,
   gen_rec.sad_038_cty_destcod		,
   gen_rec.sad_039_cty_destreg		,
   gen_rec.sad_040_trsp_iddepar		,
   gen_rec.sad_041_trsp_natdepar	,
   gen_rec.sad_042_ctnr_flag		,
   gen_rec.sad_043_tod_cod		,
   gen_rec.sad_044_tod_nam		,
   gen_rec.sad_045_tod_sit		,
   gen_rec.sad_046_trsp_idbord		,
   gen_rec.sad_047_trspnatbord		,
   gen_rec.sad_048_cur_cod		,
   gen_rec.sad_049_tot_invoiced		,
   gen_rec.sad_050_tra_cod1		,
   gen_rec.sad_051_tra_cod2		,
   gen_rec.sad_052_mot_bord		,
   gen_rec.sad_053_mot_inland		,
   gen_rec.sad_054_lop_cod		,
   gen_rec.sad_055_top_cod		,
   gen_rec.sad_056_cuo_bord		,
   gen_rec.sad_057_loc_goods		,
   gen_rec.sad_058_bnk_cod		,
   gen_rec.sad_059_bnk_bra		,
   gen_rec.sad_060_bnk_fnber		,
   gen_rec.sad_061_def_pay		,
   gen_rec.sad_062_whs_cod		,
   gen_rec.sad_063_whs_time		,
   gen_rec.sad_064_total_sdi		,
   gen_rec.sad_065_asmt_serial		,
   gen_rec.sad_066_asmt_nber		,
   gen_rec.sad_067_asmt_date		,
   gen_rec.sad_068_rcpt_serial		,
   gen_rec.sad_069_rcpt_nber		,
   gen_rec.sad_070_rcpt_date		,
   gen_rec.sad_071_grty_amount		,
   gen_rec.sad_072_grty_date		,
   gen_rec.sad_073_tot_fees		,
   gen_rec.sad_074_total_taxes		,
   gen_rec.sad_075_ctrl_results		,
   gen_rec.sad_076_dec_place		,
   gen_rec.sad_077_dec_date		,
   gen_rec.sad_078_dec_repnam		,
   gen_rec.sad_079_cof_nam		,
   gen_rec.sad_080_not_defined		,
   gen_rec.sad_081_etotinv_valc		,
   gen_rec.sad_082_etotinv_cur		,
   gen_rec.sad_083_etotinv_rat		,
   gen_rec.sad_084_etotinv_ref		,
   gen_rec.sad_085_etotinv_valn		,
   gen_rec.sad_086_etotifr_valc		,
   gen_rec.sad_087_etotifr_cur		,
   gen_rec.sad_088_etotifr_rat		,
   gen_rec.sad_089_etotifr_ref		,
   gen_rec.sad_090_etotifr_valn		,
   gen_rec.sad_091_etotded_valc		,
   gen_rec.sad_092_etotded_cur		,
   gen_rec.sad_093_etotded_rat		,
   gen_rec.sad_094_etotded_ref		,
   gen_rec.sad_095_etotdef_valn		,
   gen_rec.sad_096_etotadd_cst		,
   gen_rec.sad_097_etotgros_mass	,
   gen_rec.sad_098_efob_valn		,
   gen_rec.sad_081_itotinv_valc		,
   gen_rec.sad_082_itotinv_cur		,
   gen_rec.sad_083_itotinv_rat		,
   gen_rec.sad_084_itotinv_ref		,
   gen_rec.sad_085_itotinv_valn		,
   gen_rec.sad_086_itotefr_valc		,
   gen_rec.sad_087_itotefr_cur		,
   gen_rec.sad_088_itotefr_rat		,
   gen_rec.sad_089_itotefr_ref		,
   gen_rec.sad_090_itotefr_valn		,
   gen_rec.sad_091_itotins_valc		,
   gen_rec.sad_092_itotins_cur		,
   gen_rec.sad_093_itotins_rat		,
   gen_rec.sad_094_itotins_ref		,
   gen_rec.sad_095_itotins_valn		,
   gen_rec.SAD_096_ITOTOTC_VALC		,
   gen_rec.sad_097_itototc_cur		,
   gen_rec.SAD_098_ITOTOTC_RAT		,
   gen_rec.SAD_098_ITOTOTC_RAT		,
   gen_rec.SAD_100_ITOTOTC_VALN		,
   gen_rec.sad_101_itotifr_valc		,
   gen_rec.sad_102_itotifr_cur		,
   gen_rec.sad_103_itotifr_rat		,
   gen_rec.SAD_104_ITOTIFR_REF		,
   gen_rec.sad_105_itotifr_valn		,
   gen_rec.sad_106_itotded_valc		,
   gen_rec.sad_107_itotded_cur		,
   gen_rec.sad_108_itotded_rat		,
   gen_rec.sad_109_itotded_ref		,
   gen_rec.sad_110_itotded_valn		,
   gen_rec.sad_111_itotadd_cst		,
   gen_rec.sad_112_icif_valn		,
   gen_rec.sad_113_itotgros_mass	,
   gen_rec.sad_114_itotstat_val		,
   gen_rec.sad_115_exp_nam		,
   gen_rec.sad_116_exp_add1		,
   gen_rec.sad_117_exp_add2		,
   gen_rec.sad_118_exp_city		,
   gen_rec.sad_119_exp_zip		,
   gen_rec.sad_120_con_nam		,
   gen_rec.sad_121_con_add1		,
   gen_rec.sad_122_con_add2		,
   gen_rec.sad_123_con_city		,
   gen_rec.sad_124_con_zip		,
   gen_rec.sad_125_fin_nam		,
   gen_rec.sad_126_fin_add		,
   gen_rec.sad_127_fin_city		,
   gen_rec.sad_128_dec_nam		,
   gen_rec.sad_129_dec_add		,
   gen_rec.sad_130_dec_city
);
*/
 end ins_gen_rec;

 procedure ins_fol_rec( fol_rec strang.sad_following%ROWTYPE )
 as
  cursor c1( vid integer, vord integer) is select 'x' exst from strang.sad_following where entry_no = vid and order_by = vord;
  c1rec c1%ROWTYPE;
 begin
  open c1(fol_rec.entry_no, fol_rec.order_by);
  fetch c1 into c1rec;
  if c1%FOUND
   then
    close c1;
    update strang.sad_following
     set
       sad_131_itm_nber		=  fol_rec.sad_131_itm_nber	,
       sad_132_pack_mark1	=  fol_rec.sad_132_pack_mark1	,
       sad_133_pack_mark2	=  fol_rec.sad_133_pack_mark2	,
       sad_134_hs_cod		=  fol_rec.sad_134_hs_cod	,
       sad_135_hsprec_cod	=  fol_rec.sad_135_hsprec_cod	,
       sad_136_undefined1	=  fol_rec.sad_136_undefined1	,
       sad_137_undefined2	=  fol_rec.sad_137_undefined2	,
       sad_138_tar_spc		=  fol_rec.sad_138_tar_spc	,
       sad_139_goods_desc1	=  fol_rec.sad_139_goods_desc1	,
       sad_140_goods_desc2	=  fol_rec.sad_140_goods_desc2	,
       sad_141_goods_desc3	=  fol_rec.sad_141_goods_desc3	,
       sad_142_pack_nber	=  fol_rec.sad_142_pack_nber	,
       sad_143_pack_kindcod	=  fol_rec.sad_143_pack_kindcod	,
       sad_144_cty_origcod	=  fol_rec.sad_144_cty_origcod	,
       sad_145_cty_origreg	=  fol_rec.sad_145_cty_origreg	,
       sad_146_gross_mass	=  fol_rec.sad_146_gross_mass	,
       sad_147_prefer_cod	=  fol_rec.sad_147_prefer_cod	,
       sad_148_ctnr_nber1	=  fol_rec.sad_148_ctnr_nber1	,
       sad_149_ctnr_nber2	=  fol_rec.sad_149_ctnr_nber2	,
       sad_150_ctnr_nber3	=  fol_rec.sad_150_ctnr_nber3	,
       SAD_151_CTNR_NBER4	=  fol_rec.SAD_151_CTNR_NBER4	,
       sad_152_extd_proc	=  fol_rec.sad_152_extd_proc	,
       sad_153_nat_proc		=  fol_rec.sad_153_nat_proc	,
       sad_154_net_mass		=  fol_rec.sad_154_net_mass	,
       sad_155_quota		=  fol_rec.sad_155_quota	,
       sad_156_trsp_doc		=  fol_rec.sad_156_trsp_doc	,
       sad_157_supp_units	=  fol_rec.sad_157_supp_units	,
       sad_158_itm_price	=  fol_rec.sad_158_itm_price	,
       sad_159_val_method	=  fol_rec.sad_159_val_method	,
       sad_160_lic_nber		=  fol_rec.sad_160_lic_nber	,
       sad_161_dval_amount	=  fol_rec.sad_161_dval_amount	,
       sad_162_dqty		=  fol_rec.sad_162_dqty		,
       sad_163_value_details	=  fol_rec.sad_163_value_details,
       sad_164_ai_cod		=  fol_rec.sad_164_ai_cod	,
       sad_165_adj_rate		=  fol_rec.sad_165_adj_rate	,
       sad_166_prev_doc		=  fol_rec.sad_166_prev_doc	,
       sad_167_prev_whscod	=  fol_rec.sad_167_prev_whscod	,
       sad_168_free_text	=  fol_rec.sad_168_free_text	,
       sad_169_reserved		=  fol_rec.sad_169_reserved	,
       sad_170_stat_val		=  fol_rec.sad_170_stat_val	,
       sad_171_itm_totamt	=  fol_rec.sad_171_itm_totamt	,
       sad_172_itm_totmop	=  fol_rec.sad_172_itm_totmop	,
       sad_173_att_documents	=  fol_rec.sad_173_att_documents,
       SAD_174_IITMSUP_VAL1	=  fol_rec.SAD_174_IITMSUP_VAL1	,
       SAD_175_IITMSUP_VAL2	=  fol_rec.SAD_175_IITMSUP_VAL2
   where
     entry_no = fol_rec.entry_no and
     order_by = fol_rec.order_by;
    return;
  end if;
  close c1;

  insert into strang.sad_following
  (
   entry_no,
   order_by,
   sad_131_itm_nber	,
   sad_132_pack_mark1	,
   sad_133_pack_mark2	,
   sad_134_hs_cod	,
   sad_135_hsprec_cod	,
   sad_136_undefined1	,
   sad_137_undefined2	,
   sad_138_tar_spc	,
   sad_139_goods_desc1	,
   sad_140_goods_desc2	,
   sad_141_goods_desc3	,
   sad_142_pack_nber	,
   sad_143_pack_kindcod	,
   sad_144_cty_origcod	,
   sad_145_cty_origreg	,
   sad_146_gross_mass	,
   sad_147_prefer_cod	,
   sad_148_ctnr_nber1	,
   sad_149_ctnr_nber2	,
   sad_150_ctnr_nber3	,
   SAD_151_CTNR_NBER4	,
   sad_152_extd_proc	,
   sad_153_nat_proc	,
   sad_154_net_mass	,
   sad_155_quota	,
   sad_156_trsp_doc	,
   sad_157_supp_units	,
   sad_158_itm_price	,
   sad_159_val_method	,
   sad_160_lic_nber	,
   sad_161_dval_amount	,
   sad_162_dqty		,
   sad_163_value_details,
   sad_164_ai_cod	,
   sad_165_adj_rate	,
   sad_166_prev_doc	,
   sad_167_prev_whscod	,
   sad_168_free_text	,
   sad_169_reserved	,
   sad_170_stat_val	,
   sad_171_itm_totamt	,
   sad_172_itm_totmop	,
   sad_173_att_documents,
   SAD_174_IITMSUP_VAL1	,
   SAD_175_IITMSUP_VAL2
   )
     values
     (
   fol_rec.entry_no,
   fol_rec.order_by,
   fol_rec.sad_131_itm_nber	,
   fol_rec.sad_132_pack_mark1	,
   fol_rec.sad_133_pack_mark2	,
   fol_rec.sad_134_hs_cod	,
   fol_rec.sad_135_hsprec_cod	,
   fol_rec.sad_136_undefined1	,
   fol_rec.sad_137_undefined2	,
   fol_rec.sad_138_tar_spc	,
   fol_rec.sad_139_goods_desc1	,
   fol_rec.sad_140_goods_desc2	,
   fol_rec.sad_141_goods_desc3	,
   fol_rec.sad_142_pack_nber	,
   fol_rec.sad_143_pack_kindcod	,
   fol_rec.sad_144_cty_origcod	,
   fol_rec.sad_145_cty_origreg	,
   fol_rec.sad_146_gross_mass	,
   fol_rec.sad_147_prefer_cod	,
   fol_rec.sad_148_ctnr_nber1	,
   fol_rec.sad_149_ctnr_nber2	,
   fol_rec.sad_150_ctnr_nber3	,
   fol_rec.SAD_151_CTNR_NBER4	,
   fol_rec.sad_152_extd_proc	,
   fol_rec.sad_153_nat_proc	,
   fol_rec.sad_154_net_mass	,
   fol_rec.sad_155_quota	,
   fol_rec.sad_156_trsp_doc	,
   fol_rec.sad_157_supp_units	,
   fol_rec.sad_158_itm_price	,
   fol_rec.sad_159_val_method	,
   fol_rec.sad_160_lic_nber	,
   fol_rec.sad_161_dval_amount	,
   fol_rec.sad_162_dqty		,
   fol_rec.sad_163_value_details,
   fol_rec.sad_164_ai_cod	,
   fol_rec.sad_165_adj_rate	,
   fol_rec.sad_166_prev_doc	,
   fol_rec.sad_167_prev_whscod	,
   fol_rec.sad_168_free_text	,
   fol_rec.sad_169_reserved	,
   fol_rec.sad_170_stat_val	,
   fol_rec.sad_171_itm_totamt	,
   fol_rec.sad_172_itm_totmop	,
   fol_rec.sad_173_att_documents,
   fol_rec.SAD_174_IITMSUP_VAL1	,
   fol_rec.SAD_175_IITMSUP_VAL2
   );
 end ins_fol_rec;

function f15_parameter_range( parm_id in varchar2, parm1 in varchar2, parm2 in varchar2 )
 return varchar2
as

 -- Parm1 = ENTRY_NO
 -- Parm2 = CUSTOMER

 cursor c1( parm1 number ) is
  select /*+ ALL_ROWS */ *
  from strang.ships_airway
  where ship_id in ( select ship_id
                     from strang.movements m, strang.detailrs dr
                     where entry_no = parm1 and
                           m.movement_no = dr.movement_no and
                           nvl(m.seal,'|') = nvl(dr.camov_seal,'|'));


 cursor c2( lv varchar2, cd varchar2 ) is
  select /*+ ALL_ROWS */ *
  from strang.lov
  where lov_name = lv and
        code = cd;

 cursor c2a( lv varchar2, cd varchar2 ) is
  select /*+ ALL_ROWS */ *
  from strang.lov
  where lov_name = lv and
        cola = cd;

 cursor c2b( cd varchar2 ) is
  select /*+ ALL_ROWS */ *
  from strang.lov l
  where l.lov_name = 'CONTROLS' and
        l.cola = WEBSYS.OLTP.F_USER_SITE and
        code = cd;

 -- SS says this is the right way to do this.

 cursor c3( parm1 number, parm2 varchar2 ) is
  select /*+ ALL_ROWS */ sum(p.tamount) sm
  from strang.pos p
  where p.deliveryno in
   (select distinct dr.deliveryno
    from strang.detailrs dr
    where entry_no = parm1
   );

 cursor c5(cid integer) is select * from strang.customers where customer_id = cid;

 cursor c6(parm1 number, parm2 varchar2 ) is
  select /*+ ALL_ROWS */ sum(revton * c.freight * d.exrate) sm
  from strang.customers c, strang.detailrs dr, strang.receivals r, strang.movements m, strang.ships_airway s, strang.duty d
  where dr.entry_no = parm1 and
        d.entry_no = dr.entry_no and
        c.customer = parm2 and
        m.ship_id = s.ship_id and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        dr.deliveryno = r.deliveryno and
        nvl(r.cust_customer_id,0) = c.customer_id and
        customer_type = 'CUSTOMER';

 cursor c7(entryno number) is
  select /*+ ALL_ROWS */ distinct c.customer, r.curr, l2.description exrate
  from strang.receivals r, strang.detailrs dr, strang.customers c, strang.lov l2, strang.ships_airway sa, strang.movements m
  where dr.entry_no = entryno and
        dr.deliveryno = r.deliveryno and
        m.ship_id = sa.ship_id and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        l2.lov_name = 'UNRATTAB' and
        l2.code = r.curr and
        to_date(glbx.guess_date(l2.cola),'DD-MON-YYYY') <= sa.estarrive and
        nvl(to_date(glbx.guess_date(l2.colb),'DD-MON-YYYY'),sa.estarrive) >= sa.estarrive and
        nvl(r.supplier_customer_id,0) = c.customer_id and
        c.customer_type = 'SUPPLIER';

 cursor c8(custname varchar2) is
  select /*+ ALL_ROWS */ *
  from strang.customers
  where customer = custname and
        customer_type = 'CUSTOMER';

 cursor c9(entryno number) is
  select /*+ ALL_ROWS */ *
  from strang.duty
  where entry_no = entryno;

 cursor c10(custid integer) is
  select /*+ ALL_ROWS */ *
  from strang.customers
  where customer_id = custid;

 cursor c11a(entryno number) is
  select count('x') cnt
  from strang.duty d
  where previous_entry_no = entryno;

 cursor c11b(entryno number) is
  select min(line_no) mn, max(line_no) mx
  from strang.detailrs dr
  where entry_no = entryno;

 cursor c11(shpid integer, entryno number, parm2 varchar2) is
  select /*+ ALL_ROWS */ dr.entry_no, min(line_no) mn, max(line_no) mx
  from strang.detailrs dr, strang.receivals r, strang.movements m
  where m.ship_id = shpid and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        dr.deliveryno = r.deliveryno and
        dr.deliveryno in
         (select dr2.deliveryno from strang.detailrs dr2 where dr2.entry_no = entryno)
  group by dr.entry_no;

 cursor c12( entryno number ) is
   select /*+ ALL_ROWS */ nvl(m.bol,m.movement_no) bol
    from strang.detailrs dr, strang.movements m
    where dr.entry_no = entryno and
          m.movement_no = dr.movement_no and
          nvl(m.seal,'|') = nvl(dr.camov_seal,'|');

cursor c13( entryno number ) is
 select /*+ ALL_ROWS */ l1.description, pktpe_packtype, sum(qty) tot
 from strang.detailrs dr, strang.lov l1
 where entry_no = entryno and
       l1.lov_name = 'PACKTYPES' and
       l1.code = dr.pktpe_packtype
 group by l1.description, pktpe_packtype;

cursor c13b(shpid integer, entryno number) is
 select /*+ ALL_ROWS */ dr.entry_no, l1.description, pktpe_packtype, sum(qty) tot
 from strang.detailrs dr, strang.lov l1, strang.receivals r, strang.movements m
  where m.ship_id = shpid and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        dr.deliveryno = r.deliveryno and
        dr.deliveryno in
         (select dr2.deliveryno from strang.detailrs dr2 where dr2.entry_no = entryno) and
        l1.lov_name = 'PACKTYPES' and
        l1.code = dr.pktpe_packtype
 group by dr.entry_no, l1.description, pktpe_packtype;

cursor c14( entryno number ) is
 select /*+ ALL_ROWS */ distinct po
 from strang.detailrs dr, strang.pos p
 where entry_no = entryno and
       p.deliveryno = dr.deliveryno
 order by po;

cursor c14b(shpid integer, entryno number, parm2 varchar2) is
 select /*+ ALL_ROWS */ distinct po
 from strang.detailrs dr, strang.receivals r, strang.movements m, strang.pos p
  where m.ship_id = shpid and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        dr.deliveryno = r.deliveryno and
        dr.deliveryno in
         (select dr2.deliveryno from strang.detailrs dr2 where dr2.entry_no = entryno) and
        p.deliveryno = dr.deliveryno
 order by po;

cursor c15( entryno number, pktpe varchar2 ) is
 select /*+ ALL_ROWS */ detaildesc
 from strang.detailrs
 where entry_no = entryno and
       pktpe_packtype = pktpe
 group by detaildesc;

cursor c16( entryno number ) is
 select /*+ ALL_ROWS */ distinct movement_no
 from strang.detailrs dr
 where entry_no = entryno
 order by movement_no;

-- tariff, rate, excise
cursor c17( entryno number ) is
 select /*+ ALL_ROWS */ distinct l1.cola tariff, l2.description, l2.colc
 from strang.pos p, strang.lov l1, strang.lov l2,
 (select entry_no
  from strang.duty
  where entry_no = entryno and
       nvl(previous_entry_no,0) = 0 ) z2
 where l1.lov_name = 'INVENT' and
       l2.lov_name = 'TARIFF' and
       l1.cola = l2.code and
       l1.code = p.inventoryno and
       p.deliveryno in
       (select distinct deliveryno
        from strang.detailrs dr
        where dr.entry_no = entryno);

cursor c17x( entryno number ) is
 select /*+ ALL_ROWS */ distinct l1.cola tariff, l2.description, l2.colc
 from strang.pos p, strang.lov l1, strang.lov l2
 where l1.lov_name = 'INVENT' and
       l2.lov_name = 'TARIFF' and
       l1.cola = l2.code and
       l1.code = p.inventoryno and
       p.deliveryno in
       (select distinct deliveryno
        from strang.detailrs dr
        where dr.entry_no = entryno
       ) and
      (l1.cola,l1.code) not in
      (select x1.cola, x1.code
       from
       (
        select /*+ ALL_ROWS */ distinct z1.cola, z1.code
        from strang.detailrs dr, strang.pos p, strang.lov z1
        where entry_no = entryno and
              p.deliveryno = dr.deliveryno and
              p.inventoryno = z1.code and
              z1.lov_name = 'INVENT'
        order by z1.cola
       ) x1
      where rownum < 5
      );

cursor c18( entryno number ) is
 select /*+ ALL_ROWS */ min(line_no) line_no, m.movement_no, ship_id
 from strang.detailrs dr, strang.movements m
 where entry_no = entryno and
       dr.movement_no = m.movement_no and
       nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
 group by m.movement_no,ship_id;

cursor c19( shipid integer ) is
 select /*+ ALL_ROWS */ *
 from strang.ships_airway
 where ship_id = shipid;

cursor c21( entryno number ) is
 select /*+ ALL_ROWS */  count( distinct l1.cola ) tot
 from strang.pos p, strang.lov l1, strang.detailrs dr
 where dr.entry_no = entryno and
       dr.deliveryno = p.deliveryno and
       p.inventoryno = l1.code and
       l1.lov_name = 'INVENT';


 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c8rec		c8%ROWTYPE;
 c9rec		c9%ROWTYPE;
 c10rec		c10%ROWTYPE;
 c11rec		c11%ROWTYPE;
 c11arec	c11a%ROWTYPE;
 c11brec	c11b%ROWTYPE;
 c12rec		c12%ROWTYPE;
 c18rec		c18%ROWTYPE;
 c19rec		c19%ROWTYPE;
 c21rec		c21%ROWTYPE;
 ttl		number;
 exr		number;
 temptot	number;
 tmp		varchar2(32767);
 tmp2		varchar2(32767);
 v_err		varchar2(32767);

 function tot( entryno number, tariff varchar2 )
  return number
 is

   cursor c1(entryno number) is select * from strang.duty where entry_no = entryno;
   cursor c2(entryno number, tariff varchar2 ) is
    select sum(nvl(tamount,0)) tot
    from strang.pos p, strang.lov l1
    where l1.lov_name = 'INVENT' and
          l1.code = p.inventoryno and
          l1.cola = tariff and
          p.deliveryno in
          (select distinct deliveryno
           from strang.detailrs dr
           where dr.entry_no = entryno);

   c1rec c1%ROWTYPE;
   c2rec c2%ROWTYPE;

 begin
    open c1(entryno);
    fetch c1 into c1rec;
    close c1;
    open c2(entryno,tariff);
    fetch c2 into c2rec;
    close c2;
    return(round(c1rec.ratio_factor * c2rec.tot,2));
 end;

begin
 if parm_id = 'A0'
  then
   -- Calculate total Items
   open c21(parm1);
   fetch c21 into c21rec;
   close c21;
    return( to_char(c21rec.tot) );

 elsif parm_id = 'A1'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   WEBSYS.strangp.generate_ships_manifest( c1rec.ship_id ,'EXCISE', 'SHIP', parm1, WEBSYS.OLTP.USER_SITE );
   return( NULL );
    -- recalculate duty table values
 elsif parm_id = 'A2'
  then
   -- Ships_airway
    open c8(parm2);
    fetch c8 into c8rec;
    close c8;
   return( c8rec.cpc );
 elsif parm_id = 'A3'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   open c2('LOCATIONS',c1rec.portdisc);
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 elsif parm_id = 'A4'
  then
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   return( c7rec.customer );
 elsif parm_id = 'A5'
  then
    open c8(parm2);
    fetch c8 into c8rec;
    close c8;
   return( c8rec.p2acode );
 elsif parm_id = 'A6'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   return( c8rec.customer );
 elsif parm_id = 'A6X'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   return( c8rec.street || ' ' || c8rec.suburb || htf.nl || c8rec.state || ' ' || c8rec.postcode || ', ' || c8rec.country );
 elsif parm_id = 'A7'
  then
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   open c2a('COUNTRIES',c7rec.curr);
   fetch c2a into c2rec;
   close c2a;
   return( c2rec.description || '&nbsp;&nbsp;&nbsp;&nbsp;' || c2rec.code );
 elsif parm_id = 'A8'
  then
    open c8(parm2);
    fetch c8 into c8rec;
    close c8;
   return( c8rec.terms_of_delivery );
 elsif parm_id = 'A9'
  then
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   return( round(nvl(c9rec.exrate,1),4) );
 elsif parm_id = 'AA'
  then
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   if c9rec.previous_entry_no is null
    then
     return( c9rec.ratio_factor );
    else
     return( NULL );
   end if;
 elsif parm_id = 'AB'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   open c2('LOCATIONS',c1rec.portload);
   fetch c2 into c2rec;
   close c2;
   return( c2rec.description );
 elsif parm_id = 'AC'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   open c10(c8rec.customs_agent);
   fetch c10 into c10rec;
   close c10;
   return( c10rec.customer );
 elsif parm_id = 'AD'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   return( c8rec.account_number );
 elsif parm_id = 'AE'
  then
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   if c9rec.previous_entry_no is null
    then
     open c3(parm1,parm2);
     fetch c3 into c3rec;
     close c3;
     return( to_char(c3rec.sm,'99999999.99') );
    else
     return( NULL );
   end if;

 elsif parm_id = 'AF'
  then
   open c7(parm1);
   fetch c7 into c7rec;
   close c7;
   open c2a('COUNTRIES',c7rec.curr);
   fetch c2a into c2rec;
   close c2a;
   return( c2rec.cola );

 elsif parm_id = 'AG'
  then
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   if c9rec.previous_entry_no is null
    then
     return( to_char(c9rec.correct_freight * nvl(c9rec.exrate,1) ,'99999999.99') );
    else
     return( NULL );
   end if;

 elsif parm_id = 'AH'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   return( c8rec.licence_no || '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' || parm1 );

 elsif parm_id = 'AI'
  then
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   if c9rec.previous_entry_no is null
    then
     return( to_char(c9rec.insurance * nvl(c9rec.exrate,1) ,'99999999.99') );
    else
     return( NULL );
   end if;

 elsif parm_id = 'AJ'
  then
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   if c9rec.previous_entry_no is null
    then
     return( to_char(c9rec.other_costs * nvl(c9rec.exrate,1) ,'99999999.99') );
    else
     return( NULL );
   end if;

 elsif parm_id = 'AK'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   if c1rec.ship_airway = 'S'
    then
     return( 'SEA&nbsp;&nbsp;&nbsp;&nbsp;1' );
   elsif c1rec.ship_airway = 'A'
    then
     return ('AIR&nbsp;&nbsp;&nbsp;&nbsp;2');
   else
    return( NULL );
   end if;
 elsif parm_id = 'AL'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   return( to_char(c1rec.estarrive,'DD.MM.YYYY') );
 elsif parm_id = 'AM'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   if upper(substr(c8rec.attachments_invoices,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AN'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   if upper(substr(c8rec.attachments_packing,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AO'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   if upper(substr(c8rec.attachments_order,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AP'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   if upper(substr(c8rec.attachments_licence,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AQ'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   if upper(substr(c8rec.attachments_freight,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;
 elsif parm_id = 'AR'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   if upper(substr(c8rec.attachments_other,1,1)) = 'Y'
    then
     return( 'Y' );
    else
     return( ' ' );
   end if;

 elsif parm_id = 'AS'
  then
   open c1(parm1);
   fetch c1 into c1rec;
   close c1;
   return( c1rec.shipname || ' ' || c1rec.voy );

 elsif parm_id = 'AT'
  then
   open c11a(parm1);
   fetch c11a into c11arec;
   close c11a;
   if c11arec.cnt = 0
    then
     open c11b(parm1);
     fetch c11b into c11brec;
     close c11b;
      if c11brec.mn = c11brec.mx
       then
        return( c11brec.mn );
       else
        return( c11brec.mn || ' - ' || c11brec.mx );
      end if;
    else
     open c1(parm1);
     fetch c1 into c1rec;
     close c1;
     for c11rec in c11(c1rec.ship_id, parm1, parm2) loop
      if c11rec.mn = c11rec.mx
       then
        tmp := tmp || ',' || c11rec.mn;
       else
        tmp := tmp || ',' ||  c11rec.mn || ' - ' || c11rec.mx;
      end if;
     end loop;
     return( substr(tmp,2) );
   end if;

 elsif parm_id = 'AU'
  then
   open c12(parm1);
   fetch c12 into c12rec;
   close c12;
   return( c12rec.bol );

 elsif parm_id = 'AV'
  then
   /*
   for c13rec in c13( parm1 ) loop
    tmp := tmp || htf.nl || c13rec.tot;
   end loop;
   return( substr( tmp, (length(htf.nl)*1)+1) );
   */
   return( NULL );

 elsif parm_id = 'AW'
  then
   open c9( parm1 );
   fetch c9 into c9rec;
   close c9;
   open c11a(parm1);
   fetch c11a into c11arec;
   close c11a;
   if c11arec.cnt = 0 -- no partshipments
    then
     tmp := htf.tableopen;
     for c13rec in c13( parm1 ) loop
      tmp := tmp || htf.tablerowopen || htf.tabledata(c13rec.tot, cattributes=>'width=50 valign="TOP" style="font-size:7.0pt; font-family:Arial"');
      for c15rec in c15( parm1, c13rec.pktpe_packtype ) loop
       tmp2 := tmp2 || c15rec.detaildesc || ',';
      end loop;
      tmp := tmp || htf.tabledata(c13rec.description || ':' || substr(tmp2,1,length(tmp2)-1), cattributes=>'valign="TOP" style="font-size:7.0pt; font-family:Arial"') || htf.tablerowclose;
      tmp2 := NULL;
     end loop;
     tmp := tmp || htf.tableclose;
     -- PO
     for c14rec in c14( parm1 ) loop
      tmp := tmp || c14rec.po || ',';
     end loop;
   else
     open c1(parm1);
     fetch c1 into c1rec;
     close c1;
     tmp := htf.tableopen;
     for c13brec in c13b(c1rec.ship_id, parm1) loop
      tmp := tmp || htf.tablerowopen || htf.tabledata(c13brec.tot, cattributes=>'width=50 valign="TOP" style="font-size:7.0pt; font-family:Arial"');
      for c15rec in c15( c13brec.entry_no, c13brec.pktpe_packtype ) loop
       tmp2 := tmp2 || c15rec.detaildesc || ',';
      end loop;
      tmp := tmp || htf.tabledata(c13brec.description || ':' || substr(tmp2,1,length(tmp2)-1), cattributes=>'valign="TOP" style="font-size:7.0pt; font-family:Arial"') || htf.tablerowclose;
      tmp2 := NULL;
     end loop;
     tmp := tmp || htf.tableclose;
     -- PO
     for c14brec in c14b(c1rec.ship_id, parm1, parm2) loop
      tmp := tmp || c14brec.po || ',';
     end loop;
   end if;

   -- Movements
   for c16rec in c16( parm1 ) loop
    tmp := tmp || c16rec.movement_no || ',';
   end loop;

   open c1(parm1);
   fetch c1 into c1rec;
   close c1;

   tmp := substr(tmp,1,length(tmp)-1) || htf.nl || htf.nl || c1rec.pcomment;

   if c9rec.previous_entry_no is not null
    then
     open c18(c9rec.previous_entry_no);
     fetch c18 into c18rec;
     close c18;
     open c19(c18rec.ship_id);
     fetch c19 into c19rec;
     close c19;
     tmp := tmp || htf.nl ||
     'I HEREBY DECLARE THAT THE VALUE FOR THE ABOVE MENTIONED GOODS HAD BEEN ENTERED FOR DUTY PAYMENT ON THE MANIFEST FOR THE ' ||
     c19rec.shipname || ' ' || c19rec.voy || ', LINE NUMBER ' || c18rec.line_no || '.<BR>WARRANT NO: _____________________ ' ||
     ' PART SHIPMENT OF CONTAINER NO ' || c18rec.movement_no || '.' || htf.nl;
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
     open c10(c8rec.customs_agent);
     fetch c10 into c10rec;
     close c10;
     tmp := tmp || c10rec.customer || ' ' || c10rec.street;
   end if;
   return( tmp );
 elsif parm_id = 'AX'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   open c10(c8rec.customs_agent);
   fetch c10 into c10rec;
   close c10;
   return( c10rec.customer );
 elsif parm_id = 'AY'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
--   if upper(substr(c8rec.position );

 elsif parm_id = 'B1-OLD'
  then
   -- in new form calculation is simplified
   return( NULL );
   ttl := 0;
   for c17rec in c17(parm1) loop
     ttl := ttl + tot(parm1,c17rec.tariff) * (nvl(to_number(c17rec.description),0)/100);
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );
 elsif parm_id = 'B2-OLD'
  then
   ttl := 0;
   for c17rec in c17(parm1) loop
     temptot := tot(parm1,c17rec.tariff);
     ttl := ttl + ((temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100));
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );
 elsif parm_id = 'B3-OLD'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   ttl := 0;
   for c17rec in c17(parm1) loop
    temptot := tot(parm1,c17rec.tariff);
    ttl := ttl +
       (temptot +
          temptot * (nvl(to_number(c17rec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100)
         ) *
        (nvl(to_number(c8rec.vat),0)/100);
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );

  elsif parm_id = 'B2'
  then
   -- Total First Page
   ttl := 0;
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   for c17rec in c17(parm1) loop
     if c17%ROWCOUNT > 4 then exit; end if;
     ttl := ttl + tot(parm1,c17rec.tariff) * (nvl(to_number(c17rec.description),0)/100);
   end loop;
   for c17rec in c17(parm1) loop
     if c17%ROWCOUNT > 4 then exit; end if;
     ttl := ttl + ((tot(parm1,c17rec.tariff) + tot(parm1,c17rec.tariff) * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100));
   end loop;
   for c17rec in c17(parm1) loop
    if c17%ROWCOUNT > 4 then exit; end if;
    temptot := tot(parm1,c17rec.tariff);
    ttl := ttl +
       (temptot +
          temptot * (nvl(to_number(c17rec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100)
         ) *
        (nvl(to_number(c8rec.vat),0)/100);
   end loop;
/* 2 % LEVY CALCULATION
*/
   for c17rec in c17(parm1) loop
    if c17%ROWCOUNT > 4 then exit; end if;
    temptot := tot(parm1,c17rec.tariff);

    ttl := ttl +
       round(((nvl(to_number(c8rec.levy_rate),0)/100)*(temptot +
		(round(temptot * (nvl(to_number(c17rec.description),0)/100),2)) +
		(round( (temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) *
                (nvl(to_number(c17rec.colc),0)/100),2)))),2);
   end loop;



   return( to_char(round(ttl,2),'999999990.99') );

  elsif parm_id = 'B3'
  then
   -- Total Other Pages
   ttl := 0;
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   for c17rec in c17(parm1) loop
     if c17%ROWCOUNT > 4 then
      ttl := ttl + tot(parm1,c17rec.tariff) * (nvl(to_number(c17rec.description),0)/100);
     end if;
   end loop;
   for c17rec in c17(parm1) loop
     if c17%ROWCOUNT > 4 then
       ttl := ttl + ((tot(parm1,c17rec.tariff) + tot(parm1,c17rec.tariff) * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100));
      end if;
   end loop;
   for c17rec in c17(parm1) loop
    if c17%ROWCOUNT > 4 then
     temptot := tot(parm1,c17rec.tariff);
     ttl := ttl +
       (temptot +
          temptot * (nvl(to_number(c17rec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100)
         ) *
        (nvl(to_number(c8rec.vat),0)/100);
     end if;
   end loop;

/* 2 % LEVY CALCULATION
*/
   for c17rec in c17(parm1) loop
    if c17%ROWCOUNT > 4 then
     temptot := tot(parm1,c17rec.tariff);
     ttl := ttl +
       round(((nvl(to_number(c8rec.levy_rate),0)/100)*(temptot +
		(round(temptot * (nvl(to_number(c17rec.description),0)/100),2)) +
		(round( (temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) *
                (nvl(to_number(c17rec.colc),0)/100),2)))),2);
     end if;
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );

elsif parm_id = 'B4'
  then
   -- Total All Pages
   ttl := 0;
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   for c17rec in c17(parm1) loop
     ttl := ttl + tot(parm1,c17rec.tariff) * (nvl(to_number(c17rec.description),0)/100);
   end loop;
   for c17rec in c17(parm1) loop
     ttl := ttl + ((tot(parm1,c17rec.tariff) + tot(parm1,c17rec.tariff) * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100));
   end loop;
   for c17rec in c17(parm1) loop
    temptot := tot(parm1,c17rec.tariff);
    ttl := ttl +
       (temptot +
          temptot * (nvl(to_number(c17rec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) * (nvl(to_number(c17rec.colc),0)/100)
         ) *
        (nvl(to_number(c8rec.vat),0)/100);
   end loop;
/* 2 % LEVY CALCULATION
*/
   for c17rec in c17(parm1) loop
    temptot := tot(parm1,c17rec.tariff);
     ttl := ttl +
       round(((nvl(to_number(c8rec.levy_rate),0)/100)*(temptot +
		(round(temptot * (nvl(to_number(c17rec.description),0)/100),2)) +
		(round( (temptot + temptot * (nvl(to_number(c17rec.description),0)/100)) *
                (nvl(to_number(c17rec.colc),0)/100),2)))),2);
   end loop;

   return( to_char(round(ttl,2),'999999990.99') );

 elsif parm_id = 'XB1'
  then
   ttl := 0;
   for c17xrec in c17x(parm1) loop
     ttl := ttl + tot(parm1,c17xrec.tariff) * (nvl(to_number(c17xrec.description),0)/100);
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );

 elsif parm_id = 'XB2'
  then
   ttl := 0;
   for c17xrec in c17x(parm1) loop
     temptot := tot(parm1,c17xrec.tariff);
     ttl := ttl + ((temptot + temptot * (nvl(to_number(c17xrec.description),0)/100)) * (nvl(to_number(c17xrec.colc),0)/100));
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );

 elsif parm_id = 'XB3'
  then
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   ttl := 0;
   for c17xrec in c17x(parm1) loop
    temptot := tot(parm1,c17xrec.tariff);
    ttl := ttl +
       (temptot +
          temptot * (nvl(to_number(c17xrec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c17xrec.description),0)/100)) * (nvl(to_number(c17xrec.colc),0)/100)
         ) *
        (nvl(to_number(c8rec.vat),0)/100);
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );

 elsif parm_id = 'XB4'
  then
   ttl := 0;
   open c8(parm2);
   fetch c8 into c8rec;
   close c8;
   for c17xrec in c17x(parm1) loop
     ttl := ttl + tot(parm1,c17xrec.tariff) * (nvl(to_number(c17xrec.description),0)/100);
   end loop;
   for c17xrec in c17x(parm1) loop
     ttl := ttl + ((tot(parm1,c17xrec.tariff) + tot(parm1,c17xrec.tariff) * (nvl(to_number(c17xrec.description),0)/100)) * (nvl(to_number(c17xrec.colc),0)/100));
   end loop;
   for c17xrec in c17x(parm1) loop
    temptot := tot(parm1,c17xrec.tariff);
    ttl := ttl +
       (temptot +
          temptot * (nvl(to_number(c17xrec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c17xrec.description),0)/100)) * (nvl(to_number(c17xrec.colc),0)/100)
         ) *
        (nvl(to_number(c8rec.vat),0)/100);
   end loop;
   return( to_char(round(ttl,2),'999999990.99') );

 elsif parm_id = 'REPORT_A'
  then
   -- Calculate total Page Numbers to determine if the continuation report should be run
   if parm1 is null then return( 'RUN' ); end if;
   open c21(parm1);
   fetch c21 into c21rec;
   close c21;
   if c21rec.tot < 5
    then
     return( '0' );
   else
     return( 'RUN' );
   end if;

 elsif parm_id = 'REPORT_B'
  then
   -- Calculate total Page Numbers to determine if the continuation report should be run
   if parm1 is null then return( 'RUN' ); end if;
   open c9(parm1);
   fetch c9 into c9rec;
   close c9;
   if c9rec.previous_entry_no is not null
    then
     return( '0' );
   else
     return( 'RUN' );
   end if;

 elsif parm_id = 'SIG'
  then
   -- Calculate total Page Numbers to determine if the continuation report should be run
   open c2b('FORM 15 SIGNATURE');
   fetch c2b into c2rec;
   if c2b%NOTFOUND
    then
     close c2b;
     return( '__________________________________________' );
    else
     close c2b;
     return( '<IMG SRC="file:///c:/signature/' || c2rec.description || '" BORDER=0 WIDTH="80" HEIGHT="60">' );
   end if;

 elsif parm_id = 'SAD'
  then
    if upper(parm2) in ( 'YES', 'Y' , 'TRUE' , 'T' )
     then
      generate_sad(parm1, v_err);
    end if;
 end if;
 return( null );
exception
 when others then return( null );
end f15_parameter_range;

function form_15_continue(colin varchar2, entryno in number, tariff in varchar2, rnumb in integer default null, vtot in integer)
 return varchar2
as

 cursor c1(entryno number, tariff varchar2) is
  select /*+ ALL_ROWS */ distinct description
  from strang.lov l1, strang.detailrs dr, strang.pos p
  where l1.cola = tariff and
        dr.entry_no = entryno and
        p.inventoryno = l1.code and
        dr.deliveryno = p.deliveryno and
        lov_name = 'INVENT';


 cursor c2(entryno number, tariff varchar2) is
  select /*+ ALL_ROWS */ *
  from strang.ships_airway
  where ship_id in
   (select ship_id
   from strang.movements m, strang.detailrs dr, strang.pos p, strang.lov l1
   where entry_no = entryno and
         dr.deliveryno = p.deliveryno and
         p.inventoryno = l1.code and
         l1.lov_name = 'INVENT' and
         l1.cola = tariff and
         m.movement_no = dr.movement_no and
         nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
   );

 cursor c3( entryno number, tariff varchar2 ) is
  select /*+ ALL_ROWS */ nvl(sum(amount),0) sm
  from strang.pos p, strang.detailrs dr, strang.lov l1
  where p.deliveryno = dr.deliveryno and
         dr.deliveryno = p.deliveryno and
         p.inventoryno = l1.code and
         l1.lov_name = 'INVENT' and
         l1.cola = tariff and
         dr.entry_no = entryno;

 cursor c4( entryno number ) is
  select /*+ ALL_ROWS */ ctry_countrycode
  from strang.pos p, strang.detailrs dr
  where p.deliveryno = dr.deliveryno and
         dr.deliveryno = p.deliveryno and
         dr.entry_no = entryno;

 cursor c5( tariff varchar2 ) is
 select  /*+ ALL_ROWS */ *
 from strang.lov
 where lov_name = 'TARIFF' and
       code = tariff;

 cursor c6(entryno number, tariff varchar2 ) is
  select /*+ ALL_ROWS */ sum(revton * c.freight) sm
  from strang.detailrs dr, strang.movements m, strang.ships_airway s, strang.pos p, strang.lov l1, strang.receivals r, strang.customers c
  where dr.entry_no = entryno and
        m.movement_no = dr.movement_no and
        dr.deliveryno = p.deliveryno and
        dr.deliveryno = r.deliveryno and
        r.cust_customer_id = c.customer_id and
        p.inventoryno = l1.code and
        l1.lov_name = 'INVENT' and
        l1.cola = tariff and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        m.ship_id = s.ship_id;

 cursor c7( entryno number, tariff varchar2 ) is
  select /*+ ALL_ROWS */ sum(p.qty) qty
  from strang.pos p, strang.lov i
  where p.inventoryno = i.code and
        i.lov_name = 'INVENT' and
        i.cola = tariff and
        p.deliveryno in
        (select distinct deliveryno
         from strang.detailrs
         where entry_no = entryno);

 cursor c7a( tariff varchar2 ) is
  select /*+ ALL_ROWS */ l2.cola
  from strang.lov l2
  where l2.lov_name = 'TARIFF' and
        l2.code = tariff;

 cursor c8( entryno number ) is
  select /*+ ALL_ROWS */ *
  from strang.ships_airway
  where ship_id in ( select ship_id
                     from strang.movements m, strang.detailrs dr
                     where entry_no = entryno and
                           m.movement_no = dr.movement_no and
                           nvl(m.seal,'|') = nvl(dr.camov_seal,'|'));

 cursor c9(entryno number) is
   select /*+ ALL_ROWS */ distinct c.customer, r.curr, l2.description exrate
   from strang.receivals r, strang.detailrs dr, strang.customers c, strang.lov l2, strang.ships_airway sa, strang.movements m
   where dr.entry_no = entryno and
         dr.deliveryno = r.deliveryno and
        m.ship_id = sa.ship_id and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
         l2.lov_name = 'UNRATTAB' and
         l2.code = r.curr and
         l2.cola <= sa.estarrive and
        to_date(glbx.guess_date(l2.cola),'DD-MON-YYYY') <= sa.estarrive and
        nvl(to_date(glbx.guess_date(l2.colb),'DD-MON-YYYY'),sa.estarrive) >= sa.estarrive and
         nvl(r.supplier_customer_id,0) = c.customer_id and
         c.customer_type = 'SUPPLIER';


cursor c17( entryno number, rfrom integer, rto integer ) is
select tariff, description, colc
from
(
 select rownum rnumb, tariff, description, colc
 from
 (
  select /*+ ALL_ROWS */ distinct l1.cola tariff, l2.description, l2.colc
  from strang.pos p, strang.lov l1, strang.lov l2
  where l1.lov_name = 'INVENT' and
        l2.lov_name = 'TARIFF' and
        l1.cola = l2.code and
        l1.code = p.inventoryno and
        p.deliveryno in
         (select distinct deliveryno
          from strang.detailrs dr
         where dr.entry_no = entryno
        )
  )
)
where rnumb >= rfrom and rnumb < rto;

cursor c18( entryno number ) is
select tariff, description, colc
from
(
 select rownum rnumb, tariff, description, colc
 from
 (
  select /*+ ALL_ROWS */ distinct l1.cola tariff, l2.description, l2.colc
  from strang.pos p, strang.lov l1, strang.lov l2
  where l1.lov_name = 'INVENT' and
        l2.lov_name = 'TARIFF' and
        l1.cola = l2.code and
        l1.code = p.inventoryno and
        p.deliveryno in
         (select distinct deliveryno
          from strang.detailrs dr
         where dr.entry_no = entryno
        )
  )
);


cursor c21( entryno number ) is
 select /*+ ALL_ROWS */  count( distinct l1.cola ) tot
 from strang.pos p, strang.lov l1, strang.detailrs dr
 where dr.entry_no = entryno and
       dr.deliveryno = p.deliveryno and
       p.inventoryno = l1.code and
       l1.lov_name = 'INVENT';

 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c7arec		c7a%ROWTYPE;
 c8rec		c8%ROWTYPE;
 c9rec		c9%ROWTYPE;
 c21rec		c21%ROWTYPE;
 pagefrom	integer;
 pageto		integer;
 b1		number;
 b2		number;
 b3		number;
 b4		number;
 b5		number;
 temptot	number;
 exrate		varchar2(100);
 xb1		varchar2(100);
 xb2		varchar2(100);
 xb3		varchar2(100);
 xb4		varchar2(100);
 xb5		varchar2(100);
 tmp 		varchar2(32767);
 tmp2 		varchar2(32767);
 tmp3		varchar2(32767);
 tmp4 		number;
 tmp5		number;
 tmp6 		number;
 tmp7		number;
 tmp8		varchar2(32767);
 ttl		number;

 function ispartshipment( entryno number )
  return boolean
 is

   cursor c1(entryno number) is select * from strang.duty where entry_no = entryno;
   c1rec  c1%ROWTYPE;
 begin
  open c1(entryno);
  fetch c1 into c1rec;
  close c1;
  if nvl(c1rec.previous_entry_no,0) > 0
   then
    return( TRUE );
   else
    return( FALSE );
  end if;
 end ispartshipment;

 function tot( entryno number, tariff varchar2, ctype in varchar2 default 'CURR' )
  return number
 is

   cursor c1(entryno number) is select * from strang.duty where entry_no = entryno;

   cursor c2(entryno number, tariff varchar2 ) is
    select sum(nvl(tamount,0)) tot
    from strang.pos p, strang.lov l1
    where l1.lov_name = 'INVENT' and
          l1.code = p.inventoryno and
          l1.cola = tariff and
          p.deliveryno in
          (select distinct dr.deliveryno
           from strang.detailrs dr
           where  dr.entry_no = entryno );

   c1rec c1%ROWTYPE;
   c2rec c2%ROWTYPE;

 begin
    open c1(entryno);
    fetch c1 into c1rec;
    close c1;
    open c2(entryno,tariff);
    fetch c2 into c2rec;
    close c2;
    if ctype = 'CURR'
     then
      return(round(c1rec.ratio_factor * c2rec.tot,2));
     else
      return(round(c2rec.tot,2));
    end if;
 end;

begin
if colin = 'AX'
 then
  if rnumb = 1 then strang_global.GLOBAL_VARS.delete; end if;
  strang_global.GLOBAL_VARS(rnumb).rnumb := rnumb;
  strang_global.GLOBAL_VARS(rnumb).entryno := entryno;
  strang_global.GLOBAL_VARS(rnumb).tariff := tariff;
end if;

if colin = 'AX'
 then
 if mod(rnumb,3) = 1
  then
   -- Start of New Page. Calculate Header
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 2
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 2) / 3) + 2;
   end if;
   pagefrom := trunc((rnumb - 2) / 3) + 2;

   if pagefrom > 2
     then
     tmp := '<span style=''font-size:1.0pt;mso-bidi-font-size:10.0pt;font-family:Arial; mso-fareast-font-family:"Times New Roman";mso-bidi-font-family:"Times New Roman"; mso-ansi-language:EN-US;mso-fareast-language:EN-US;mso-bidi-language:AR-SA''><br clear=all style=''mso-special-character:line-break;page-break-before:always''></span>';
   end if;

   tmp := tmp ||
'<div align=center>
<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=625
 style=''width:469.05pt;border-collapse:collapse;border:none''>
 <tr style=''height:7.7pt''>
  <td width=334 colspan=13 rowspan=2 style=''width:250.25pt;border-top:solid windowtext 1.0pt;
  border-left:solid windowtext 1.0pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:7.7pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>PAPUA
  NEW GUINEA CUSTOMS </span></b></p>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>CUSTOMS
  DECLARATION  (continuation page)</span></b></p>
  </td>
  <td width=129 colspan=7 style=''width:96.4pt;border:solid windowtext 1.0pt;
  border-left:none;background:#CCCCCC;padding:0cm 5.35pt 0cm 5.35pt;height:
  7.7pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></p>
  </td>
  <td width=163 colspan=10 style=''width:122.4pt;border:solid windowtext 1.0pt;
  border-left:none;background:#CCCCCC;padding:0cm 5.35pt 0cm 5.35pt;height:
  7.7pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>A OFFICE
  OF DECLARATION</span></p>
  </td>
 </tr>
 <tr style=''height:9.65pt''>
  <td width=129 colspan=7 style=''width:96.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:9.65pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>1.
  DECLARATION</span></p>
  </td>
  <td width=71 colspan=6 style=''width:53.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:9.65pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Office
  code </span></p>
  </td>
  <td width=92 colspan=4 style=''width:68.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:9.65pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></p>
  </td>
 </tr>
';
 else
   tmp := NULL;
 end if;

elsif colin = 'AX1'
 then
 if mod(rnumb,3) = 1
  then
   -- Start of New Page. Calculate Header
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 2
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 2) / 3) + 2;
   end if;
   pagefrom := trunc((rnumb - 2) / 3) + 2;


   tmp := tmp ||
' <tr style=''height:10.5pt''>
  <td width=66 rowspan=4 style=''width:49.15pt;border:solid windowtext 1.0pt;
  border-bottom:none;padding:0cm 5.35pt 0cm 5.35pt;height:10.5pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></p>
  </td>
  <td width=183 colspan=7 style=''width:137.05pt;border:solid windowtext 1.0pt;
  border-left:none;background:white;padding:0cm 5.35pt 0cm 5.35pt;height:10.5pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>8.
  Importer                                TC N°:</span></p>
  </td>
  <td width=85 colspan=5 style=''width:64.05pt;border:solid windowtext 1.0pt;
  border-left:none;background:white;padding:0cm 5.35pt 0cm 5.35pt;height:10.5pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial;background:
  lime''>'|| f15_parameter_range( 'A5', entryno, null) ||'</span></p>
  </td>
  <td width=129 colspan=7 style=''width:96.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:10.5pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></p>
  </td>
  <td width=71 colspan=6 style=''width:53.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:10.5pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>OfficeName</span></p>
  </td>
  <td width=92 colspan=4 style=''width:68.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:10.5pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''> </span></p>
  </td>
 </tr>';
 else
   tmp := NULL;
 end if;


elsif colin = 'AX2'
 then
 if mod(rnumb,3) = 1
  then
   -- Start of New Page. Calculate Header
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 2
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 2) / 3) + 2;
   end if;
   pagefrom := trunc((rnumb - 2) / 3) + 2;

   tmp := tmp ||
  '<tr style=''height:12.15pt''>
  <td width=268 colspan=12 style=''width:201.1pt;border:none;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:12.15pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>
  '|| f15_parameter_range( 'A6', entryno, null) ||'</span></b></p>
  </td>
  <td width=129 colspan=7 style=''width:96.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:12.15pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>  </span></b></p>
  </td>
  <td width=71 colspan=6 style=''width:53.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:12.15pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Manifest
  n°       </span></p>
  </td>
  <td width=92 colspan=4 style=''width:68.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:12.15pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></p>
  </td>
 </tr>
 <tr style=''height:12.6pt''>
  <td width=268 colspan=12 style=''width:201.1pt;border:none;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:12.6pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>
  '|| f15_parameter_range( 'A6X', entryno, null) ||'</span></b></p>
  </td>
  <td width=70 colspan=3 style=''width:52.85pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:12.6pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>3.  Pages</span></p>
  </td>
  <td width=58 colspan=4 style=''width:43.55pt;border:solid windowtext 1.0pt;
  border-left:none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:
  12.6pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>4.</span></p>
  </td>
  <td width=71 colspan=6 style=''width:53.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:12.6pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Registration</span></p>
  </td>
  <td width=92 colspan=4 style=''width:68.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:12.6pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></p>
  </td>
 </tr>
';
 else
   tmp := NULL;
 end if;


elsif colin = 'AY'
 then
 if mod(rnumb,3) = 1
  then
   -- Start of New Page. Calculate Header
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 2
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 2) / 3) + 2;
   end if;
   pagefrom := trunc(rnumb / 3) + 2;

   tmp := tmp ||
  ' <tr style=''height:14.25pt''>
  <td width=268 colspan=12 style=''width:201.1pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:14.25pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>
  '|| f15_parameter_range( 'A6XX', entryno, null) ||'</span></b></p>
  </td>
  <td width=70 colspan=3 style=''width:52.85pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:14.25pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>' || to_char(pagefrom) || ' of ' || to_char(pageto) ||'
  </span></b></p>
  </td>
  <td width=58 colspan=4 style=''width:43.55pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#E0E0E0;padding:0cm 5.35pt 0cm 5.35pt;height:14.25pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></p>
  </td>
  <td width=71 colspan=6 style=''width:53.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:14.25pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Date</span></p>
  </td>
  <td width=92 colspan=4 style=''width:68.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:14.25pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>
  </span></p>
  </td>
 </tr>
';
 else
   tmp := NULL;
 end if;


-- continuation page items 31 through to 46


elsif colin = 'CPA'
 then
 tmp :=
 '
 <tr style=''height:8.4pt''>
  <td width=66 style=''width:49.15pt;border:solid windowtext 1.0pt;border-bottom:
  none;padding:0cm 5.35pt 0cm 5.35pt;height:8.4pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>31.</span></p>
  </td>
  <td width=268 colspan=12 style=''width:201.1pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:8.4pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''> </span></p>
  </td>
  <td width=70 colspan=3 style=''width:52.85pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:8.4pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>32.  Item  </span></p>
  </td>
  <td width=221 colspan=14 style=''width:165.95pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:8.4pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>33.
  Commodity code</span></p>
  </td>
 </tr>
';

elsif colin = 'CPB'
 then
   if tariff is not null
    then
      tmp2 := f15_parameter_range( 'AT', entryno, null);
     else
      tmp2 := NULL;
   end if;
   if tariff is not null
    then
      tmp3 := rnumb;
     else
      tmp3 := NULL;
   end if;

tmp :=
'
 <tr style=''height:16.8pt''>
  <td width=66 rowspan=8 style=''width:49.15pt;border:solid windowtext 1.0pt;
  border-top:none;padding:0cm 5.35pt 0cm 5.35pt;height:16.8pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Packages
  and Description of goods</span></p>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>         </span></p>
  </td>
  <td width=104 colspan=3 style=''width:78.15pt;border:none;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:16.8pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Marks
  &amp; nos. on packages </span></p>
  </td>
  <td width=164 colspan=9 style=''width:122.95pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:none;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:16.8pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>MANIFEST LINE NO/S:'|| tmp2 ||'</span></b></p>
  </td>
  <td width=34 colspan=2 style=''width:25.75pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:16.8pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=36 style=''width:27.1pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#DFDFDF;
  padding:0cm 5.35pt 0cm 5.35pt;height:16.8pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>N°.</span></p>
  </td>
';


elsif colin = 'CPC'
 then
 if tariff is not null
  then
   open c5(tariff);
   fetch c5 into c5rec;
   close c5;
   open c2(entryno,tariff);
   fetch c2 into c2rec;
   close c2;
   tmp2 := tariff;
  else
   tmp2 := NULL;
  end if;
  if tariff is not null
   then
     tmp3 := f15_parameter_range( 'AWW', entryno, null);
    else
     tmp3 := NULL;
    end if;

tmp :=
  '
  <td width=221 colspan=14 style=''width:165.95pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:16.8pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
 </tr>
 <tr style=''height:2.1pt''>
  <td width=104 colspan=3 style=''width:78.15pt;border:solid windowtext 1.0pt;
  border-left:none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:
  2.1pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>&nbsp;</span></p>
  </td>
  <td width=234 colspan=12 style=''width:175.8pt;border:solid windowtext 1.0pt;
  border-left:none;padding:0cm 5.35pt 0cm 5.35pt;height:2.1pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></p>
  </td>
  <td width=73 colspan=7 style=''width:54.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:2.1pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>34.
  Cty.Origin</span></p>
  </td>
  <td width=97 colspan=4 style=''width:73.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:2.1pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>35. Gr.
  mass kg</span></p>
  </td>';

elsif colin = 'CPD'
 then
 if tariff is not null
  then
   tmp2 := f15_parameter_range( 'AWWW', entryno, null);
 else
   tmp2 := NULL;
 end if;

tmp:='
  <td width=51 colspan=3 style=''width:38.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:2.1pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>36.Pref</span></p>
  </td>
 </tr>
 <tr style=''height:6.7pt''>
  <td width=104 colspan=3 style=''width:78.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''> No/kind
  of pkgs </span></p>
  </td>
  <td width=234 colspan=12 style=''width:175.8pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=13 style=''width:10.1pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#DFDFDF;
  padding:0cm 2.8pt 0cm 2.8pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>a</span></p>
  </td>';

elsif colin = 'CPE'
 then
 if tariff is not null
  then
   open c7(entryno,tariff);
   fetch c7 into c7rec;
   close c7;
   open c7a(tariff);
   fetch c7a into c7arec;
   close c7a;
   if c7arec.cola is null
    then
     tmp2 := NULL;
   else
     tmp2 := c7rec.qty || ' ' || c7arec.cola;
   end if;
  else
   tmp2 := NULL;
 end if;

  if tariff is not null
   then
    open c4(entryno);
    fetch c4 into c4rec;
    close c4;
  else
   c4rec.ctry_countrycode := ' ';
  end if;


tmp :=
 '
  <td width=35 colspan=2 style=''width:25.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 2.8pt 0cm 2.8pt;height:6.7pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=25 colspan=4 style=''width:18.9pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 2.8pt 0cm 2.8pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>'|| c4rec.ctry_countrycode ||'</span></p>
  </td>
  <td width=97 colspan=4 style=''width:73.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 2.8pt 0cm 2.8pt;height:6.7pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=51 colspan=3 style=''width:38.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 2.8pt 0cm 2.8pt;height:6.7pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
 </tr>';


elsif colin = 'CPF'
 then

tmp :=
'
 <tr style=''height:6.7pt''>
  <td width=339 colspan=15 style=''width:253.95pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Container
  N°(s) </span></p>
  </td>
  <td width=73 colspan=7 style=''width:54.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>37.Procedure</span></p>
  </td>
  <td width=97 colspan=4 style=''width:73.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>38. Net
  mass kg</span></p>
  </td>
  <td width=51 colspan=3 style=''width:38.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#CCCCCC;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>39.  </span></p>
  </td>
 </tr>
';


elsif colin = 'CPG'
 then
  if tariff is not null
   then
    tmp2 := f15_parameter_range( 'AWWWW', entryno, null);
   else
    tmp2 := NULL;
  end if;
 if tariff is not null
  then
   open c7(entryno,tariff);
   fetch c7 into c7rec;
   close c7;
   open c7a(tariff);
   fetch c7a into c7arec;
   close c7a;
   if c7arec.cola is null
    then
     tmp3 := NULL;
   else
     tmp3 := c7rec.qty || ' ' || c7arec.cola;
   end if;
  else
   tmp3 := NULL;
 end if;

tmp :=
 '
 <tr style=''height:6.7pt''>
  <td width=339 colspan=15 style=''width:253.95pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=43 colspan=2 style=''width:32.35pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>4000</span></b></p>
  </td>
  <td width=30 colspan=5 style=''width:22.6pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>000</span></b></p>
  </td>
  <td width=97 colspan=4 style=''width:73.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=51 colspan=3 style=''width:38.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#999999;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></p>
  </td>
 </tr>';

elsif colin = 'CPH'
 then

  if tariff is not null
   then
   for c1rec in c1(entryno,tariff) loop
    tmp2 := tmp2 || ', ' || c1rec.description;
   end loop;
   tmp2 := substr(tmp2,length(', ')+1);
--    tmp2 := f15_parameter_range( 'AWWWWW', entryno, null);
   else
    tmp2 := NULL;
  end if;
  if tariff is not null
   then
    tmp3 := f15_parameter_range( 'AU', entryno, null);
   else
    tmp3 := NULL;
  end if;

tmp :=
 '
 <tr style=''height:6.7pt''>
  <td width=339 colspan=15 style=''width:253.95pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Description
  of the goods:</span></p>
  </td>
  <td width=221 colspan=14 style=''width:165.95pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>40. Bill of
  Lading /Airway Bill No./Preceding Docs</span></p>
  </td>
 </tr>
 <tr style=''height:11.2pt''>
  <td width=339 colspan=15 rowspan=2 style=''width:253.95pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:11.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=221 colspan=14 style=''width:165.95pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:11.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
 </tr>';

elsif colin = 'CPS'
 then
tmp :='';


elsif colin = 'CPT'
 then
tmp :='
 <tr style=''height:8.4pt''>
  <td width=63 colspan=6 style=''width:47.35pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:8.4pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>41.Tariff
  Qty</span></p>
  </td>
  <td width=56 colspan=3 style=''width:42.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:8.4pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>41.Sup.
  Qty</span></p>
  </td>
  <td width=77 colspan=3 style=''width:57.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:8.4pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>42.Item
  FCY Price</span></p>
  </td>
  <td width=26 colspan=2 style=''width:19.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:8.4pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>43.</span></p>
  </td>
 </tr>
';

elsif colin = 'CPU'
 then
tmp :=' <tr style=''height:12.3pt''>
  <td width=66 style=''width:49.15pt;border-top:none;border-left:solid windowtext 1.0pt;
  border-bottom:none;border-right:solid windowtext 1.0pt;padding:0cm 5.35pt 0cm 5.35pt;
  height:12.3pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>44.</span></p>
  </td>
  <td width=103 colspan=2 style=''width:77.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:12.3pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Licence n°
  :</span></p>
  </td>
  <td width=78 colspan=4 style=''width:58.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:12.3pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=36 colspan=2 style=''width:26.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:12.3pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>/DV:</span></p>
  </td>
';

elsif colin = 'CPV'
 then
tmp :='  <td width=37 colspan=2 style=''width:27.75pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:12.3pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=48 colspan=3 style=''width:35.65pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:12.3pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>/DQ: </span></p>
  </td>
';

elsif colin = 'CPW'
 then
tmp :='';



elsif colin = 'CPX'
 then
tmp :='
  <td width=38 colspan=2 style=''width:28.5pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:12.3pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
';

elsif colin = 'CPY'
 then
  if tariff is not null
   then
    open c7(entryno,tariff);
    fetch c7 into c7rec;
    close c7;
    open c7a(tariff);
    fetch c7a into c7arec;
    close c7a;
    if c7arec.cola is null
     then
      tmp2 := NULL;
    else
      tmp2 := c7rec.qty || ' ' || c7arec.cola;
    end if;
   else
    tmp2 := NULL;
  end if;

  if tariff is not null
   then
    tmp3 := to_char(tot(entryno,tariff,'FOREIGN'),'999999990.99');
  else
    tmp3 := NULL;
  end if;


tmp :='
  <td width=63 colspan=6 style=''width:47.35pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:12.3pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=56 colspan=3 style=''width:42.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:12.3pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=77 colspan=3 style=''width:57.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:12.3pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=26 colspan=2 style=''width:19.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#999999;padding:0cm 5.35pt 0cm 5.35pt;height:12.3pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></p>
  </td>
 </tr>
';

elsif colin = 'CPZ'
 then
tmp :=' <tr style=''height:6.7pt''>
  <td width=66 rowspan=2 style=''width:49.15pt;border:none;border-left:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Add. info</span></p>
  </td>
  <td width=103 colspan=2 style=''width:77.2pt;border:solid windowtext 1.0pt;
  border-top:none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Attach
  doc:</span></p>
  </td>
  <td width=236 colspan=13 style=''width:176.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=196 colspan=12 style=''width:146.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>46. Value
  for Duty PGK</span></p>
  </td>
  <td width=26 colspan=2 style=''width:19.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>45.</span></p>
  </td>
 </tr>
';


elsif colin = 'CPSS'
 then
tmp := '';

elsif colin = 'CPTT'
 then
 if tariff is not null
 then
   tmp2 := to_char(tot(entryno,tariff),'999999990.99');
 else
   tmp2 := NULL;
 end if;

tmp := '<tr style=''height:6.7pt''>
  <td width=103 colspan=2 style=''width:77.2pt;border:solid windowtext 1.0pt;
  border-top:none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Additional
  info</span></p>
  </td>
  <td width=236 colspan=13 style=''width:176.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=196 colspan=12 style=''width:146.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=26 colspan=2 style=''width:19.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#999999;padding:0cm 5.35pt 0cm 5.35pt;height:6.7pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></p>
  </td>
 </tr>
 ';

-- end of commonality for first and subsequent pages, items 31 through to 46

-- beginning of section 47 for first page

elsif colin = 'CPUU'
 then
 if mod(rnumb,3) = 0
  then
   return( NULL );
 end if;

elsif colin = 'CPVV'
 then
 if mod(rnumb,3) = 0
  then
   return( NULL );
end if;
-- BEGINNING OF END CALUCATIONS FOR CONTINUATION PAGE

elsif colin in ('CP1_1_1','CP1_1_2' )
 then

  if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
   then
    open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);
    fetch c2 into c2rec;
    close c2;
    tmp2 := to_char(to_number(c5rec.description),'990.99');
  else
    tmp2 := NULL;
  end if;

   if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
     fetch c5 into c5rec;
     close c5;
     tmp3 := to_char(round(tot(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff) * (nvl(to_number(c5rec.description),0)/100),2),'999999990.99');
    else
     tmp3 := NULL;
   end if;
   if colin = 'CP1_1_1' then return( tmp2 ); else return( tmp3 ); end if;

elsif colin in ('CP2_1_1','CP2_1_2')
  then

  if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
   then
    open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);
    fetch c2 into c2rec;
    close c2;
    tmp2 := to_char(to_number(c5rec.description),'990.99');
  else
    tmp2 := null;
  end if;

   if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
     fetch c5 into c5rec;
     close c5;
     tmp3 := to_char(round(tot(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff) * (nvl(to_number(c5rec.description),0)/100),2),'999999990.99');
    else
     tmp3 := NULL;
   end if;
   if colin = 'CP2_1_1' then return( tmp2 ); else return( tmp3 ); end if;



 -- return( 'X:' || ascii( substr(tmp,522,1) ) || '-' || ascii( substr(tmp,523,1)) || '-' || ascii( substr(tmp,524,1) ) );

elsif colin in ('CP1_2_1','CP1_2_2')
  then
  if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
   then
    open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);
    fetch c2 into c2rec;
    close c2;
    if to_number(nvl(c5rec.colc,'0') ) > 0
     then
      tmp2 := to_char(to_number(c5rec.colc),'990.99');
     else
      tmp2 := NULL;
    end if;
      else
    tmp2 := NULL;
   end if;

    if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
     then
      open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
      fetch c5 into c5rec;
      close c5;
      temptot := tot(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);
      tmp3 := to_char(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                   (nvl(to_number(c5rec.colc),0)/100),2),'999999990.99');
     else
      tmp3 := NULL;
    end if;
   if colin = 'CP1_2_1' then return( tmp2 ); else return( tmp3 ); end if;


elsif colin = 'CP2_2'
  then
if mod(rnumb,3) = 0
 then

  if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
   then
    open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);
    fetch c2 into c2rec;
    close c2;
    if to_number(nvl(c5rec.colc,'0') ) > 0
     then
      tmp2 := to_char(to_number(c5rec.colc),'990.99') || '%';
     else
      tmp2 := NULL;
    end if;
      else
    tmp2 := NULL;
   end if;

    if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
     then
      open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
      fetch c5 into c5rec;
      close c5;
      temptot := tot(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);
      tmp3 := to_char(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                   (nvl(to_number(c5rec.colc),0)/100),2),'999999990.99');
     else
      tmp3 := NULL;
    end if;
  tmp :='  <td width=35 colspan=2 style=''width:26.3pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>Excise</span></p>
  </td>
  <td width=101 colspan=7 style=''width:75.55pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=31 colspan=3 style=''width:22.9pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=107 colspan=5 style=''width:80.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>1</span></b></p>
  </td>
 </tr>
  ';
else
  tmp2:= NULL;
  tmp3:= NULL;
end if;



elsif colin = 'CP1_3'
  then
if mod(rnumb,3) = 0
 then
   if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
     fetch c5 into c5rec;
     close c5;
     open c2(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);
     fetch c2 into c2rec;
     close c2;
     if nvl(to_number(c2rec.vat),0) > 0
      then
       tmp2 := to_char(to_number(c2rec.vat),'990.99') || '%';
     end if;
    else
     tmp2 := NULL;
    end if;

     if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
      then
       open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
       fetch c5 into c5rec;
       close c5;
       open c2(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);
       fetch c2 into c2rec;
       close c2;
       temptot := tot(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);
       tmp3 := to_char(
         round(
               (temptot +
                temptot * (nvl(to_number(c5rec.description),0)/100) +
                (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
               ) *
              (nvl(to_number(c2rec.vat),0)/100),2)
                      ,'999999990.99');
       else
        tmp3 := NULL;
      end if;


  tmp :=' <tr style=''height:12.2pt''>
  <td width=38 style=''width:28.7pt;border:solid windowtext 1.0pt;border-top:
  none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:12.2pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>VAT</span></p>
  </td>
  <td width=89 colspan=3 style=''width:66.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=28 style=''width:21.2pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=86 colspan=4 style=''width:64.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>1</span></b></p>
  </td>
  ';
 else
    tmp2:= NULL;
    tmp3:= NULL;
 end if;


elsif colin = 'CP2_3'
  then
if mod(rnumb,3) = 0
 then
   if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
     fetch c5 into c5rec;
     close c5;
     open c2(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);
     fetch c2 into c2rec;
     close c2;
     if nvl(to_number(c2rec.vat),0) > 0
      then
       tmp2 := to_char(to_number(c2rec.vat),'990.99') || '%';
     end if;
    else
     tmp2 := NULL;
    end if;

     if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
      then
       open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
       fetch c5 into c5rec;
       close c5;
       open c2(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);
       fetch c2 into c2rec;
       close c2;
       temptot := tot(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);
       tmp3 := to_char(
         round(
               (temptot +
                temptot * (nvl(to_number(c5rec.description),0)/100) +
                (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
               ) *
              (nvl(to_number(c2rec.vat),0)/100),2)
                      ,'999999990.99');
       else
        tmp3 := NULL;
      end if;


  tmp :='  <td width=35 colspan=2 style=''width:26.3pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>VAT</span></p>
  </td>
  <td width=101 colspan=7 style=''width:75.55pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=31 colspan=3 style=''width:22.9pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=107 colspan=5 style=''width:80.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>1</span></b></p>
  </td>
 </tr>
';
    else
      tmp2:= NULL;
      tmp3:= NULL;
    end if;

elsif colin = 'CP1_4'
  then
if mod(rnumb,3) = 0
 then
   if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
     fetch c5 into c5rec;
     close c5;
     open c2(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);
     fetch c2 into c2rec;
     close c2;
     if nvl(to_number(c2rec.levy_rate),0) > 0
      then
       tmp2 := to_char(to_number(c2rec.levy_rate),'990.99') || '%';
     end if;
    else
     tmp2 := NULL;
    end if;

   if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
     fetch c5 into c5rec;
     close c5;
     open c2(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);
     fetch c2 into c2rec;
     close c2;
     temptot := tot(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);

     tmp3 := to_char((nvl(to_number(c2rec.levy_rate),0)/100)
     		*(temptot +
 		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
 		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2))),'999999990.99');
     else
      tmp3 := NULL;
    end if;

  tmp :=' <tr style=''height:12.2pt''>
  <td width=38 style=''width:28.7pt;border:solid windowtext 1.0pt;border-top:
  none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:12.2pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial;background:
  lime''>Levy</span></p>
  </td>
  <td width=89 colspan=3 style=''width:66.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=28 style=''width:21.2pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=86 colspan=4 style=''width:64.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>1</span></b></p>
  </td>
  ';
  else
    tmp2:= NULL;
    tmp3:= NULL;
  end if;

elsif colin = 'CP2_4'
  then
if mod(rnumb,3) = 0
 then

   if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
     fetch c5 into c5rec;
     close c5;
     open c2(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);
     fetch c2 into c2rec;
     close c2;
     if nvl(to_number(c2rec.levy_rate),0) > 0
      then
       tmp2 := to_char(to_number(c2rec.levy_rate),'990.99') || '%';
     end if;
    else
     tmp2 := NULL;
    end if;

   if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
     fetch c5 into c5rec;
     close c5;
     open c2(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);
     fetch c2 into c2rec;
     close c2;
     temptot := tot(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);

     tmp3 := to_char((nvl(to_number(c2rec.levy_rate),0)/100)
     		*(temptot +
 		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
 		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2))),'999999990.99');
     else
      tmp3 := NULL;
    end if;

  tmp :='  <td width=35 colspan=2 style=''width:26.3pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial;background:
  lime''>Levy</span></p>
  </td>
  <td width=101 colspan=7 style=''width:75.55pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=31 colspan=3 style=''width:22.9pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=107 colspan=5 style=''width:80.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>1</span></b></p>
  </td>
 </tr>
';
  else
    tmp2:= NULL;
    tmp3:= NULL;
  end if;

elsif colin = 'CP1_5'
  then
if mod(rnumb,3) = 0
 then
   if strang_global.GLOBAL_VARS(rnumb-2).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-2).tariff);
     fetch c5 into c5rec;
     close c5;
     open c2(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);
     fetch c2 into c2rec;
     close c2;

     tmp4 := round(tot(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff) * (nvl(to_number(c5rec.description),0)/100),2);
     temptot := tot(strang_global.GLOBAL_VARS(rnumb-2).entryno,strang_global.GLOBAL_VARS(rnumb-2).tariff);
     tmp5 := round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                  (nvl(to_number(c5rec.colc),0)/100),2);
     tmp6 :=
          round(
                (temptot +
                 temptot * (nvl(to_number(c5rec.description),0)/100) +
                 (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
                ) *
               (nvl(to_number(c2rec.vat),0)/100),2);
     tmp7 := (nvl(to_number(c2rec.levy_rate),0)/100)
     		*(temptot +
 		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
 		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2)));
     tmp8 := to_char(tmp4 + tmp5 + tmp6 + tmp7,'999999990.99');
    else
      tmp8 := NULL;
    end if;

  tmp :='

 <tr style=''height:13.55pt''>
  <td width=155 colspan=5 style=''width:116.3pt;border:solid windowtext 1.0pt;
  border-top:none;padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>TOTAL
  FIRST ITEM  : '|| tmp8 ||'</span></p>
  </td>
  <td width=86 colspan=4 style=''width:64.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  ';
 else
    tmp8 := NULL;
 end if;

elsif colin = 'CP2_5'
  then
if mod(rnumb,3) = 0
 then
   if strang_global.GLOBAL_VARS(rnumb-1).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb-1).tariff);
     fetch c5 into c5rec;
     close c5;
     open c2(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);
     fetch c2 into c2rec;
     close c2;

     tmp4 := round(tot(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff) * (nvl(to_number(c5rec.description),0)/100),2);
     temptot := tot(strang_global.GLOBAL_VARS(rnumb-1).entryno,strang_global.GLOBAL_VARS(rnumb-1).tariff);
     tmp5 := round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                  (nvl(to_number(c5rec.colc),0)/100),2);
     tmp6 :=
          round(
                (temptot +
                 temptot * (nvl(to_number(c5rec.description),0)/100) +
                 (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
                ) *
               (nvl(to_number(c2rec.vat),0)/100),2);
     tmp7 := (nvl(to_number(c2rec.levy_rate),0)/100)
     		*(temptot +
 		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
 		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2)));
     tmp8 := to_char(tmp4 + tmp5 + tmp6 + tmp7,'999999990.99');
    else
      tmp8 := NULL;
    end if;


  tmp :='  <td width=166 colspan=12 style=''width:124.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>TOTAL
  SECOND ITEM :  '|| tmp8 ||'</span></p>
  </td>
  <td width=107 colspan=5 style=''width:80.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''> </span></b></p>
  </td>
  <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:13.55pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
 </tr>
 ';
 else
   tmp8:= NULL;
 end if;

elsif colin = 'CPTITLE'
  then
if mod(rnumb,3) = 0
  then
    tmp :=' <tr style=''height:8.4pt''>
   <td width=38 style=''width:28.7pt;border:solid windowtext 1.0pt;border-top:
   none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:8.4pt''>
   <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Type</span></p>
   </td>
   <td width=89 colspan=3 style=''width:66.4pt;border-top:none;border-left:none;
   border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
   background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:8.4pt''>
   <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Tax base</span></p>
   </td>
   <td width=28 style=''width:21.2pt;border-top:none;border-left:none;border-bottom:
   solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#DFDFDF;
   padding:0cm 3.5pt 0cm 3.5pt;height:8.4pt''>
   <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>%</span></p>
   </td>
   <td width=86 colspan=4 style=''width:64.15pt;border-top:none;border-left:none;
   border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
   background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:8.4pt''>
   <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Amount</span></p>
   </td>
   <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
   border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
   background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:8.4pt''>
   <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>MP</span></p>
   </td>
   <td width=166 colspan=12 style=''width:124.75pt;border-top:none;border-left:
   none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
   background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:8.4pt''>
   <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Type</span></p>
   </td>
   <td width=107 colspan=5 style=''width:80.2pt;border-top:none;border-left:none;
   border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
   background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:8.4pt''>
   <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>Amount</span></p>
   </td>
   <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
   solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#DFDFDF;
   padding:0cm 3.5pt 0cm 3.5pt;height:8.4pt''>
   <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>MP</span></p>
   </td>
  </tr>
 ';
 else tmp:=null;
 end if;


elsif colin = 'CP3_1'
  then
if mod(rnumb,3) = 0
 then
  if strang_global.GLOBAL_VARS(rnumb).tariff is not null
   then
    open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);
    fetch c2 into c2rec;
    close c2;
    tmp2 := to_char(to_number(c5rec.description),'990.99') || '%';
  else
    tmp2 := NULL;
  end if;

   if strang_global.GLOBAL_VARS(rnumb).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
     fetch c5 into c5rec;
     close c5;
     tmp3 := to_char(round(tot(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff) * (nvl(to_number(c5rec.description),0)/100),2),'999999990.99');
    else
     tmp3 := NULL;
   end if;

  tmp :=' <tr style=''height:13.45pt''>
  <td width=38 style=''width:28.7pt;border:solid windowtext 1.0pt;border-top:
  none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:13.45pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>Duty</span></p>
  </td>
  <td width=89 colspan=3 style=''width:66.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=28 style=''width:21.2pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=86 colspan=4 style=''width:64.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>1</span></b></p>
  </td>
';
end if;

elsif colin = 'CPGT_1'
  then
 if mod(rnumb,3) = 0
  then
   -- Last Element on the Page, produce the summary page total
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 2
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 2) / 3) + 2;
   end if;
   pagefrom := trunc(rnumb/3) + 1;


   open c8(entryno);
   fetch c8 into c8rec;
   close c8;

   b1 := 0;

   for c18rec in c18(entryno) loop
      temptot := tot(entryno,c18rec.tariff);
      b1 := nvl(b1,0) + temptot * (nvl(to_number(c18rec.description),0)/100);
   end loop;

   xb1 := to_char(b1,'99999999.99'); -- Total C - Customs Duty

    tmp :='  <td width=166 colspan=12 style=''width:124.75pt;border-top:none;border-left:
    none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
    <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>Duty</span></p>
    </td>
    <td width=107 colspan=5 style=''width:80.2pt;border-top:none;border-left:none;
    border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
    padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
    <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| xb1 ||'</span></b></p>
    </td>
    <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
    solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
    height:13.45pt''>
    <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>1</span></b></p>
    </td>
   </tr>
  ';
  end if;

elsif colin = 'CP3_2'
  then
if mod(rnumb,3) = 0
 then
  if strang_global.GLOBAL_VARS(rnumb).tariff is not null
   then
    open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);
    fetch c2 into c2rec;
    close c2;
    if to_number(nvl(c5rec.colc,'0') ) > 0
     then
      tmp2 := to_char(to_number(c5rec.colc),'990.99') || '%';
     else
      tmp2 := NULL;
    end if;
      else
    tmp2 := NULL;
   end if;

    if strang_global.GLOBAL_VARS(rnumb).tariff is not null
     then
      open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
      fetch c5 into c5rec;
      close c5;
      temptot := tot(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);
      tmp3 := to_char(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                   (nvl(to_number(c5rec.colc),0)/100),2),'999999990.99');
     else
      tmp3 := NULL;
    end if;

  tmp :=' <tr style=''height:13.45pt''>
  <td width=38 style=''width:28.7pt;border:solid windowtext 1.0pt;border-top:
  none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:13.45pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>Excise</span></p>
  </td>
  <td width=89 colspan=3 style=''width:66.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=28 style=''width:21.2pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=86 colspan=4 style=''width:64.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>1</span></b></p>
  </td>
  ';
end if;

elsif colin = 'CPGT_2'
  then
 if mod(rnumb,3) = 0
  then
   -- Last Element on the Page, produce the summary page total
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 2
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 2) / 3) + 2;
   end if;
   pagefrom := trunc(rnumb/3) + 1;


   open c8(entryno);
   fetch c8 into c8rec;
   close c8;
   temptot := 0;
   b1 := 0;
   b2 := 0;
   b3 := 0;
   b5 := 0;
   for c18rec in c18(entryno) loop --(FEB06 check)
      temptot := tot(entryno,c18rec.tariff);
      b2 := nvl(b2,0) + ((temptot + temptot * (nvl(to_number(c18rec.description),0)/100)) * (nvl(to_number(c18rec.colc),0)/100));
   end loop;

   xb2 := to_char(b2,'99999999.99'); -- Total D - Excise Duty

  tmp :='  <td width=166 colspan=12 style=''width:124.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>Excise</span></p>
  </td>
  <td width=107 colspan=5 style=''width:80.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| xb2 ||'</span></b></p>
  </td>
  <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:13.45pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>1</span></b></p>
  </td>
  </tr>
  ';
 end if;


elsif colin = 'CP3_3'
  then
if mod(rnumb,3) = 0
 then
   if strang_global.GLOBAL_VARS(rnumb).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
     fetch c5 into c5rec;
     close c5;
     open c2(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);
     fetch c2 into c2rec;
     close c2;
     if nvl(to_number(c2rec.vat),0) > 0
      then
       tmp2 := to_char(to_number(c2rec.vat),'990.99') || '%';
     end if;
    else
     tmp2 := NULL;
    end if;

     if strang_global.GLOBAL_VARS(rnumb).tariff is not null
      then
       open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
       fetch c5 into c5rec;
       close c5;
       open c2(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);
       fetch c2 into c2rec;
       close c2;
       temptot := tot(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);
       tmp3 := to_char(
         round(
               (temptot +
                temptot * (nvl(to_number(c5rec.description),0)/100) +
                (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
               ) *
              (nvl(to_number(c2rec.vat),0)/100),2)
                      ,'999999990.99');
       else
        tmp3 := NULL;
      end if;

  tmp :=' <tr style=''height:12.2pt''>
  <td width=38 style=''width:28.7pt;border:solid windowtext 1.0pt;border-top:
  none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:12.2pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>VAT</span></p>
  </td>
  <td width=89 colspan=3 style=''width:66.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=28 style=''width:21.2pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=86 colspan=4 style=''width:64.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>1</span></b></p>
  </td>
 ';
 end if;


elsif colin = 'CPGT_3'
  then
 if mod(rnumb,3) = 0
  then
   -- Last Element on the Page, produce the summary page total
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 2
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 2) / 3) + 2;
   end if;
   pagefrom := trunc(rnumb/3) + 1;


   open c8(entryno);
   fetch c8 into c8rec;
   close c8;

   b3 := 0;
   for c18rec in c18(entryno) loop --(FEB06 check)
      temptot := tot(entryno,c18rec.tariff);
      b3 := nvl(b3,0) +
       (temptot +
          temptot * (nvl(to_number(c18rec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c18rec.description),0)/100)) * (nvl(to_number(c18rec.colc),0)/100)
         ) *
        (nvl(to_number(c8rec.vat),0)/100);
   end loop;

   xb3 := to_char(b3,'99999999.99'); -- Total E - Vat

  tmp :='  <td width=166 colspan=12 style=''width:124.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>VAT</span></p>
  </td>
  <td width=107 colspan=5 style=''width:80.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| xb3 ||'</span></b></p>
  </td>
  <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>1</span></b></p>
  </td>
 </tr>
 ';
 end if;


elsif colin = 'CP3_4'
  then
if mod(rnumb,3) = 0
 then
   if strang_global.GLOBAL_VARS(rnumb).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
     fetch c5 into c5rec;
     close c5;
     open c2(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);
     fetch c2 into c2rec;
     close c2;
     if nvl(to_number(c2rec.levy_rate),0) > 0
      then
       tmp2 := to_char(to_number(c2rec.levy_rate),'990.99') || '%';
     end if;
    else
     tmp2 := NULL;
    end if;

   if strang_global.GLOBAL_VARS(rnumb).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
     fetch c5 into c5rec;
     close c5;
     open c2(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);
     fetch c2 into c2rec;
     close c2;
     temptot := tot(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);

     tmp3 := to_char((nvl(to_number(c2rec.levy_rate),0)/100)
     		*(temptot +
 		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
 		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2))),'999999990.99');
     else
      tmp3 := NULL;
    end if;

  tmp :=' <tr style=''height:12.2pt''>
  <td width=38 style=''width:28.7pt;border:solid windowtext 1.0pt;border-top:
  none;background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:12.2pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial;background:
  lime''>Levy</span></p>
  </td>
  <td width=89 colspan=3 style=''width:66.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=28 style=''width:21.2pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=86 colspan=4 style=''width:64.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>1</span></b></p>
  </td>
  ';
  end if;


elsif colin = 'CPGT_4'
  then
 if mod(rnumb,3) = 0
  then
   -- Last Element on the Page, produce the summary page total
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   if c21rec.tot < 2
    then
     pageto := 1;
   else
    pageto := trunc((c21rec.tot - 2) / 3) + 2;
   end if;
   pagefrom := trunc(rnumb/3) + 1;


   open c8(entryno);
   fetch c8 into c8rec;
   close c8;

   b5 := 0;
/* 2 % LEVY CALCULATION
*/
   for c18rec in c18(entryno) loop --(FEB06 check)
      temptot := tot(entryno,c18rec.tariff);
      b5 := nvl(b5,0) +
		((nvl(to_number(c8rec.levy_rate),0)/100)
		*(temptot +
		(round(temptot * (nvl(to_number(c18rec.description),0)/100),2)) +
		(round( (temptot + temptot * (nvl(to_number(c18rec.description),0)/100)) *
                (nvl(to_number(c18rec.colc),0)/100),2))));
   end loop;

   xb5 := to_char(b5,'99999999.99'); -- Total F - Levy


  tmp :='  <td width=166 colspan=12 style=''width:124.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><span style=''font-size:8.0pt;font-family:Arial''>Levy</span></p>
  </td>
  <td width=107 colspan=5 style=''width:80.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>'|| xb5 ||'</span></b></p>
  </td>
  <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
  height:12.2pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>1</span></b></p>
  </td>
  </tr>
  ';
 end if;


elsif colin = 'CP3_5'
  then
if mod(rnumb,3) = 0
  then
   if strang_global.GLOBAL_VARS(rnumb).tariff is not null
    then
     open c5(strang_global.GLOBAL_VARS(rnumb).tariff);
     fetch c5 into c5rec;
     close c5;
     open c2(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);
     fetch c2 into c2rec;
     close c2;

     tmp4 := round(tot(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff) * (nvl(to_number(c5rec.description),0)/100),2);
     temptot := tot(strang_global.GLOBAL_VARS(rnumb).entryno,strang_global.GLOBAL_VARS(rnumb).tariff);
     tmp5 := round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                  (nvl(to_number(c5rec.colc),0)/100),2);
     tmp6 :=
          round(
                (temptot +
                 temptot * (nvl(to_number(c5rec.description),0)/100) +
                 (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
                ) *
               (nvl(to_number(c2rec.vat),0)/100),2);
     tmp7 := (nvl(to_number(c2rec.levy_rate),0)/100)
     		*(temptot +
 		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
 		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2)));
     tmp8 := to_char(tmp4 + tmp5 + tmp6 + tmp7,'999999990.99');
    else
      tmp8 := NULL;
    end if;

  tmp :=' <tr style=''height:13.55pt''>
  <td width=155 colspan=5 style=''width:116.3pt;border:solid windowtext 1.0pt;
  border-top:none;padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
  <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>TOTAL
  THIRD ITEM  : '|| tmp8 ||'</span></p>
  </td>
  <td width=86 colspan=4 style=''width:64.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  <td width=25 colspan=2 style=''width:18.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
  <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
  </td>
  ';
 end if;
elsif colin = 'CPGT_5'
  then
 if mod(rnumb,3) = 0
  then
   -- Last Element on the Page, produce the summary page total

   ttl := 0;
   open c8(entryno);
   fetch c8 into c8rec;
   close c8;
   temptot := 0;
   b1 := 0;
   b2 := 0;
   b3 := 0;
   b5 := 0;
   for c18rec in c18(entryno) loop
      temptot := tot(entryno,c18rec.tariff);
      b1 := nvl(b1,0) + temptot * (nvl(to_number(c18rec.description),0)/100);
      b2 := nvl(b2,0) + ((temptot + temptot * (nvl(to_number(c18rec.description),0)/100)) * (nvl(to_number(c18rec.colc),0)/100));
      b3 := nvl(b3,0) +
       (temptot +
          temptot * (nvl(to_number(c18rec.description),0)/100) +
          (temptot + temptot * (nvl(to_number(c18rec.description),0)/100)) * (nvl(to_number(c18rec.colc),0)/100)
         ) *
        (nvl(to_number(c8rec.vat),0)/100);
      b5 := nvl(b5,0) +
		((nvl(to_number(c8rec.levy_rate),0)/100)
		*(temptot +
		(round(temptot * (nvl(to_number(c18rec.description),0)/100),2)) +
		(round( (temptot + temptot * (nvl(to_number(c18rec.description),0)/100)) *
                (nvl(to_number(c18rec.colc),0)/100),2))));
   end loop;
   b4 := round(b1 + b2 + b3 + b5,2);
   tmp :='  <td width=166 colspan=12 style=''width:124.75pt;border-top:none;border-left:
   none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
   padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
   <p class=MsoNormal><span style=''font-size:6.0pt;font-family:Arial''>GLOBAL
   TOTAL : '|| to_char(b4,'99999999.99') ||'</span></p>
   </td>
   <td width=107 colspan=5 style=''width:80.2pt;border-top:none;border-left:none;
   border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
   padding:0cm 3.5pt 0cm 3.5pt;height:13.55pt''>
   <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''> </span></b></p>
   </td>
   <td width=21 style=''width:15.8pt;border-top:none;border-left:none;border-bottom:
   solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 3.5pt 0cm 3.5pt;
   height:13.55pt''>
   <p class=MsoNormal><b><span style=''font-size:8.0pt;font-family:Arial''>&nbsp;</span></b></p>
   </td>
   </tr>
   </table>';
  if pagefrom = pageto
    then
      NULL;
  else
    tmp := tmp || '<br clear=all style=''mso-special-character:line-break;page-break-before:always''>';
  end if;
 end if;

-- end of continuation page



-- beginning of commonality for first page, items 31 through to 46

elsif colin = 'A'
 then
 tmp :=
 ' <tr style=''height:8.1pt''>
  <td width=68 style=''width:51.05pt;border-top:none;border-left:solid windowtext 1.0pt;
  border-bottom:none;border-right:solid windowtext 1.0pt;padding:0cm 5.35pt 0cm 5.35pt;
  height:8.1pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>31.</span></p>
  </td>
  <td width=318 colspan=18 style=''width:238.7pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:8.1pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''> </span></p>
  </td>
  <td width=63 colspan=5 style=''width:47.25pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:8.1pt''>
  <p class=MsoNormal style=''margin-top:0cm;margin-right:-6.2pt;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>32.  Item  </span></p>
  </td>
  <td width=268 colspan=21 style=''width:200.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:8.1pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>33.
  Commodity code</span></p>
  </td>
 </tr>
';

elsif colin = 'B'
 then
   if tariff is not null
    then
      tmp2 := f15_parameter_range( 'AT', entryno, null);
     else
      tmp2 := NULL;
   end if;
   if tariff is not null
    then
      tmp3 := rnumb;
     else
      tmp3 := NULL;
   end if;

tmp :=
' <tr style=''height:16.25pt''>
  <td width=68 rowspan=6 style=''width:51.05pt;border-top:none;border-left:solid windowtext 1.0pt;
  border-bottom:none;border-right:solid windowtext 1.0pt;padding:0cm 5.35pt 0cm 5.35pt;
  height:16.25pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Packages
  and Description of goods</span></p>
  </td>
  <td width=108 colspan=4 style=''width:81.35pt;border:none;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><a name=CommCode><span style=''font-size:8.0pt;font-family:Arial;
  letter-spacing:-.3pt''>Marks &amp; No. of packages </span></a></p>
  </td>
  <td width=210 colspan=14 style=''width:157.35pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:none;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;text-indent:
  1.75pt;line-height:9.0pt''>&nbsp;<b><span style=''font-size:8.0pt;font-family:
  Arial;letter-spacing:-.3pt''>MANIFEST LINE NO/S:'|| tmp2 ||'</span></b></p>
  </td>
  <td width=40 colspan=2 style=''width:29.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''> <b>'|| tmp3 ||'</b></span></p>
  </td>
  <td width=23 colspan=3 style=''width:17.5pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal style=''margin-top:0cm;margin-right:-6.2pt;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>N°.</span></p>
  </td>
';


elsif colin = 'C'
 then
 if tariff is not null
  then
   open c5(tariff);
   fetch c5 into c5rec;
   close c5;
   open c2(entryno,tariff);
   fetch c2 into c2rec;
   close c2;
   tmp2 := tariff;
  else
   tmp2 := NULL;
  end if;
  if tariff is not null
   then
     tmp3 := f15_parameter_range( 'AWW', entryno, null);
    else
     tmp3 := NULL;
    end if;

tmp :=
  '  <td width=268 colspan=21 style=''width:200.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''>&nbsp;<b><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:
  -.3pt''>'|| tmp2 ||'</span></b></p>
  </td>
 </tr>
 <tr style=''height:2.05pt''>
  <td width=108 colspan=4 style=''width:81.35pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:2.05pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''>&nbsp;</p>
  </td>
  <td width=273 colspan=19 style=''width:204.55pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:2.05pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''>&nbsp;<b><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:
  -.3pt''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=82 colspan=9 style=''width:61.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:2.05pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>34.
  Cty.Or code </span></p>
  </td>
  <td width=117 colspan=10 style=''width:87.8pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:2.05pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>35.
  Gr. mass kg</span></p>
  </td>';

elsif colin = 'D'
 then
 if tariff is not null
  then
   tmp2 := f15_parameter_range( 'AWWW', entryno, null);
 else
   tmp2 := NULL;
 end if;

tmp:='  <td width=69 colspan=2 style=''width:51.55pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:2.05pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>36.
  Pref.</span></p>
  </td>
 </tr>
 <tr style=''height:6.5pt''>
  <td width=108 colspan=4 style=''width:81.35pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''line-height:9.0pt''><span style=''font-size:8.0pt;
  font-family:Arial;letter-spacing:-.3pt''> No/kind of pkgs </span></p>
  </td>
  <td width=273 colspan=19 style=''width:204.55pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;<b><span style=''font-size:
  8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=13 style=''width:10.1pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#DFDFDF;
  padding:0cm 2.8pt 0cm 2.8pt;height:6.5pt''>
  <p class=MsoNormal style=''line-height:9.0pt''><span style=''font-size:8.0pt;
  font-family:Arial;letter-spacing:-.3pt''>a</span></p>
  </td>';

elsif colin = 'E'
 then
 if tariff is not null
  then
   open c7(entryno,tariff);
   fetch c7 into c7rec;
   close c7;
   open c7a(tariff);
   fetch c7a into c7arec;
   close c7a;
   if c7arec.cola is null
    then
     tmp2 := NULL;
   else
     tmp2 := c7rec.qty || ' ' || c7arec.cola;
   end if;
  else
   tmp2 := NULL;
 end if;

  if tariff is not null
   then
    open c4(entryno);
    fetch c4 into c4rec;
    close c4;
  else
   c4rec.ctry_countrycode := ' ';
  end if;


tmp :=
 '<td width=68 colspan=8 style=''width:51.35pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 2.8pt 0cm 2.8pt;height:6.5pt''>
  <p class=MsoNormal style=''line-height:9.0pt''><span style=''font-size:8.0pt;
  font-family:Arial;letter-spacing:-.3pt''> <b>'|| c4rec.ctry_countrycode ||'</b></span></p>
  </td>
  <td width=117 colspan=10 style=''width:87.8pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 2.8pt 0cm 2.8pt;height:6.5pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;<b><span style=''font-size:
  8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=69 colspan=2 style=''width:51.55pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 2.8pt 0cm 2.8pt;height:6.5pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;</p>
  </td>
 </tr>';


elsif colin = 'F'
 then

tmp :=
' <tr style=''height:6.5pt''>
  <td width=108 colspan=4 style=''width:81.35pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Container
  N°(s) </span></p>
  </td>
  <td width=273 colspan=19 style=''width:204.55pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''>&nbsp;</p>
  </td>
  <td width=82 colspan=9 style=''width:61.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>37.
  Procedure</span></p>
  </td>
  <td width=117 colspan=10 style=''width:87.8pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>38.
  Net mass kg</span></p>
  </td>
  <td width=69 colspan=2 style=''width:51.55pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#D9D9D9;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>39.
  </span></p>
  </td>
 </tr>';


elsif colin in ('G1','G2','G3')
 then
  if tariff is not null
   then
    tmp2 := f15_parameter_range( 'AWWWW', entryno, null);
   else
    tmp2 := null;
  end if;
  if colin = 'G1' then return( tmp2 ); end if;

 if tariff is not null
  then
   open c7(entryno,tariff);
   fetch c7 into c7rec;
   close c7;
   open c7a(tariff);
   fetch c7a into c7arec;
   close c7a;
   if c7arec.cola is null
    then
     return( null );
   else
     -- tmp3 := c7rec.qty || ' ' || c7arec.cola;
     if colin = 'G2' then return( c7rec.qty ); else return( substr(c7arec.cola,1,instr(c7arec.cola,' ')) ); end if;
   end if;
  else
   return( null );
 end if;


elsif colin = 'H'
 then

  if tariff is not null
   then
  -- for c1rec in c1(entryno,tariff) loop
  --  tmp2 := tmp2 || ', ' || c1rec.description;
  -- end loop;
--   tmp2 := substr(tmp2,length(', ')+1);
    tmp2 := f15_parameter_range( 'AWWWWW', entryno, null);
   else
    tmp2 := NULL;
  end if;
-- tmp2 := tariff || '-' || entryno;
    tmp2 := f15_parameter_range( 'AWWWWW', entryno, null);

  if tariff is not null
   then
    tmp3 := f15_parameter_range( 'AU', entryno, null);
   else
    tmp3 := NULL;
  end if;

tmp :=
 ' <tr style=''height:6.5pt''>
  <td width=381 colspan=23 style=''width:285.9pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Description
  of the goods:</span></p>
  </td>
  <td width=268 colspan=21 style=''width:200.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>40.
  Bill of Lading /Airway Bill No. / Previous doc.</span></p>
  </td>
 </tr>
 <tr style=''height:13.55pt''>
  <td width=68 rowspan=2 style=''width:51.05pt;border:solid windowtext 1.0pt;
  border-top:none;padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''line-height:9.0pt''><b><span style=''font-size:9.0pt;
  font-family:Arial;letter-spacing:-.3pt''>                    </span></b></p>
  </td>
  <td width=381 colspan=23 rowspan=2 style=''width:285.9pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;<b><span style=''font-size:
  8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=268 colspan=21 style=''width:200.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;<b><span style=''font-size:
  8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp3 ||'</span></b></p>
  </td>
 </tr>';

elsif colin = 'S'
 then
tmp :='';


elsif colin = 'T'
 then
tmp :='
< <tr style=''height:6.5pt''>
  <td width=82 colspan=9 style=''width:61.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>41.a
  Tariff Qty</span></p>
  </td>
  <td width=65 colspan=5 style=''width:48.75pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>41.b
  Supp. Qty</span></p>
  </td>
  <td width=76 colspan=6 style=''width:56.65pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>42.
  Item price FCY</span></p>
  </td>
  <td width=45 style=''width:33.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>43.</span></p>
  </td>
 </tr>';

elsif colin = 'U'
 then
tmp :='
 <tr style=''height:11.9pt''>
  <td width=68 style=''width:51.05pt;border-top:none;border-left:solid windowtext 1.0pt;
  border-bottom:none;border-right:solid windowtext 1.0pt;padding:0cm 5.35pt 0cm 5.35pt;
  height:11.9pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>44.</span></p>
  </td>
  <td width=107 colspan=3 style=''width:80.55pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:11.9pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Licence
  n° :</span></p>
  </td>
  <td width=102 colspan=7 style=''width:76.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:11.9pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''>&nbsp;</p>
  </td>
  <td width=36 colspan=3 style=''width:26.85pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:11.9pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>/DV:</span></p>
  </td>';

elsif colin = 'V'
 then
tmp :='
  <td width=52 colspan=4 style=''width:39.3pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:11.9pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''>&nbsp;</p>
  </td>
  <td width=49 colspan=2 style=''width:36.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:11.9pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>/DQ:
  </span></p>
  </td>
';

elsif colin = 'X'
 then
tmp :='  <td width=35 colspan=4 style=''width:26.05pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:11.9pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''>&nbsp;</p>
  </td>
';

elsif colin = 'Y'
 then
  if tariff is not null
   then
    open c7(entryno,tariff);
    fetch c7 into c7rec;
    close c7;
    open c7a(tariff);
    fetch c7a into c7arec;
    close c7a;
    if c7arec.cola is null
     then
      tmp2 := NULL;
    else
      tmp2 := c7rec.qty || ' ' || c7arec.cola;
    end if;
   else
    tmp2 := NULL;
  end if;

  if tariff is not null
   then
    tmp3 := to_char(tot(entryno,tariff,'FOREIGN'),'999999990.99');
  else
    tmp3 := NULL;
  end if;


tmp :='  <td width=82 colspan=9 style=''width:61.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:11.9pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''>&nbsp;<b><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:
  -.3pt''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=65 colspan=5 style=''width:48.75pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:11.9pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''>&nbsp;<b><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:
  -.3pt''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=76 colspan=6 style=''width:56.65pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:11.9pt''>
  <p class=MsoNormal align=right style=''margin-bottom:0cm;margin-bottom:.0001pt;
  text-align:right;line-height:9.0pt''><span style=''font-size:8.0pt;font-family:
  Arial;letter-spacing:-.3pt''> <b>'|| tmp3 ||'</b></span></p>
  </td>
  <td width=45 style=''width:33.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:11.9pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''>&nbsp;</p>
  </td>
 </tr>

';

elsif colin = 'Z'
 then
tmp :=' <tr style=''height:7.05pt''>
  <td width=68 rowspan=3 style=''width:51.05pt;border:solid windowtext 1.0pt;
  border-top:none;padding:0cm 5.35pt 0cm 5.35pt;height:7.05pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Additional
  Information</span></p>
  </td>
  <td width=107 colspan=3 style=''width:80.55pt;border:none;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:7.05pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Attach
  doc. codes:</span></p>
  </td>
  <td width=274 colspan=20 rowspan=2 style=''width:205.35pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:7.05pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''>&nbsp;</p>
  </td>
  <td width=268 colspan=21 style=''width:200.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#D9D9D9;padding:0cm 5.35pt 0cm 5.35pt;height:7.05pt''>
  <h2>&nbsp;</h2>
  </td>
 </tr>
';


elsif colin = 'SS'
 then
tmp := ' <tr style=''height:6.5pt''>
  <td width=107 colspan=3 style=''width:80.55pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''>&nbsp;</p>
  </td>
  <td width=199 colspan=19 style=''width:149.25pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial''>46. Value for Duty PGK</span></p>
  </td>
  <td width=69 colspan=2 style=''width:51.55pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#CCCCCC;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>45.
  </span></p>
  </td>
 </tr>';

elsif colin = 'TT'
 then
 if tariff is not null
 then
   tmp2 := to_char(tot(entryno,tariff),'999999990.99');
 else
   tmp2 := NULL;
 end if;

tmp := '
 <tr style=''height:6.5pt''>
  <td width=107 colspan=3 style=''width:80.55pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''line-height:9.0pt''><span style=''font-size:8.0pt;
  font-family:Arial;letter-spacing:-.3pt''>Additional info:</span></p>
  </td>
  <td width=274 colspan=20 style=''width:205.35pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;</p>
  </td>
  <td width=199 colspan=19 style=''width:149.25pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal align=center style=''margin-right:8.8pt;text-align:center;
  line-height:9.0pt''><b><span style=''font-size:8.0pt;font-family:Arial;
  letter-spacing:-.3pt''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=69 colspan=2 style=''width:51.55pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:6.5pt''>
  <p class=MsoNormal style=''margin-right:8.8pt;line-height:9.0pt''>&nbsp;</p>
  </td>
 </tr>
';

-- end of commonality for first and subsequent pages, items 31 through to 46

-- beginning of section 47 for first page

elsif colin = 'UU'
 then
tmp := ' <tr style=''height:16.25pt''>
  <td width=68 style=''width:51.05pt;border-top:none;border-left:solid windowtext 1.0pt;
  border-bottom:none;border-right:solid windowtext 1.0pt;padding:0cm 5.35pt 0cm 5.35pt;
  height:16.25pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>47.</span></p>
  </td>
  <td width=54 style=''width:40.5pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#DFDFDF;
  padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal align=center style=''margin-bottom:0cm;margin-bottom:.0001pt;
  text-align:center;line-height:9.0pt''><span style=''font-size:8.0pt;font-family:
  Arial;letter-spacing:-.3pt''>Type</span></p>
  </td>
  <td width=85 colspan=6 style=''width:63.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal align=center style=''margin-bottom:0cm;margin-bottom:.0001pt;
  text-align:center;line-height:9.0pt''><span style=''font-size:8.0pt;font-family:
  Arial;letter-spacing:-.3pt''>Tax base</span></p>
  </td>';

elsif colin = 'VV'
 then
tmp := '<td width=50 colspan=2 style=''width:37.6pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal align=center style=''margin-bottom:0cm;margin-bottom:.0001pt;
  text-align:center;line-height:9.0pt''><span style=''font-size:8.0pt;font-family:
  Arial;letter-spacing:-.3pt''>Rate</span></p>
  </td>
  <td width=95 colspan=7 style=''width:71.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal align=center style=''margin-bottom:0cm;margin-bottom:.0001pt;
  text-align:center;line-height:9.0pt''><span style=''font-size:8.0pt;font-family:
  Arial;letter-spacing:-.3pt''>Amount</span></p>
  </td>
  <td width=34 colspan=2 style=''width:25.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>MP</span></p>
  </td>
  <td width=114 colspan=12 style=''width:85.3pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>48.
  Account No.</span></p>
  </td>';

elsif colin = 'WW'
 then
tmp := '<td width=31 colspan=2 style=''width:23.35pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>MP</span></p>
  </td>
  <td width=99 colspan=9 style=''width:73.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>48.
  Account No.</span></p>
  </td>
  <td width=87 colspan=3 style=''width:65.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:16.25pt''>
  <p class=MsoNormal style=''margin-bottom:0cm;margin-bottom:.0001pt;line-height:
  9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>49.
  Warehouse  / days susp. </span></p>
  </td>
 </tr>
';

elsif colin = 'XX'
 then
 if tariff is not null
  then
   open c5(tariff);
   fetch c5 into c5rec;
   close c5;
   open c2(entryno,tariff);
   fetch c2 into c2rec;
   close c2;
   tmp2 := to_char(to_number(c5rec.description),'990.99') || '%';
 else
   tmp2 := NULL;
 end if;

  if tariff is not null
   then
    open c5(tariff);
    fetch c5 into c5rec;
    close c5;
    tmp3 := to_char(round(tot(entryno,tariff) * (nvl(to_number(c5rec.description),0)/100),2),'999999990.99');
   else
    tmp3 := NULL;
  end if;

tmp := ' <tr style=''height:19.3pt''>
  <td width=68 rowspan=4 style=''width:51.05pt;border-top:none;border-left:solid windowtext 1.0pt;
  border-bottom:none;border-right:solid windowtext 1.0pt;padding:0cm 5.35pt 0cm 5.35pt;
  height:19.3pt''>
  <p class=MsoNormal style=''line-height:9.0pt''><b><span style=''font-size:9.0pt;
  font-family:Arial;letter-spacing:-.3pt''>      </span></b><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Calculation of
  Taxes</span></p>
  </td>
  <td width=54 style=''width:40.5pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#DFDFDF;
  padding:0cm 5.35pt 0cm 5.35pt;height:19.3pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;<span style=''font-size:
  8.0pt;font-family:Arial;letter-spacing:-.3pt''>Duty</span></p>
  </td>
  <td width=85 colspan=6 style=''width:63.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:19.3pt''>
  <p class=MsoNormal align=right style=''text-align:right;line-height:9.0pt''>&nbsp;</p>
  </td>
  <td width=50 colspan=2 style=''width:37.6pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:19.3pt''>
  <p class=MsoNormal align=center style=''text-align:center;line-height:9.0pt''><b><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=95 colspan=7 style=''width:71.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:19.3pt''>
  <p class=MsoNormal align=right style=''text-align:right;line-height:9.0pt''><b><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp3 ||'</span></b></p>
  </td>';

elsif colin = 'YY'
 then
tmp := '
  <td width=34 colspan=2 style=''width:25.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:19.3pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;<b><span style=''font-size:
  8.0pt;font-family:Arial;letter-spacing:-.3pt''>1</span></b></p>
  </td>
  <td width=114 colspan=12 style=''width:85.3pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:19.3pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;</p>
  </td>
  <td width=130 colspan=11 style=''width:97.3pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:19.3pt''>
  <p class=MsoNormal style=''line-height:9.0pt''><span style=''font-size:8.0pt;
  font-family:Arial;letter-spacing:-.3pt''>&nbsp;</span></p>
  </td>
  <td width=18 style=''width:13.85pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:19.3pt''>
  <p class=MsoNormal style=''line-height:9.0pt''><span style=''font-size:8.0pt;
  font-family:Arial;letter-spacing:-.3pt''>/</span></p>
  </td>
  <td width=69 colspan=2 style=''width:51.55pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:19.3pt''>
  <p class=MsoNormal style=''line-height:9.0pt''><span style=''font-size:8.0pt;
  font-family:Arial;letter-spacing:-.3pt''>&nbsp;</span></p>
  </td>
 </tr>
';

elsif colin = 'ZZ'
 then
 if tariff is not null
  then
   open c5(tariff);
   fetch c5 into c5rec;
   close c5;
   open c2(entryno,tariff);
   fetch c2 into c2rec;
   close c2;
   if to_number(nvl(c5rec.colc,'0') ) > 0
    then
     tmp2 := to_char(to_number(c5rec.colc),'990.99') || '%';
    else
     tmp2 := NULL;
   end if;
     else
   tmp2 := NULL;
  end if;

    if tariff is not null
     then
      open c5(tariff);
      fetch c5 into c5rec;
      close c5;
      temptot := tot(entryno,tariff);
      tmp3 := to_char(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                   (nvl(to_number(c5rec.colc),0)/100),2),'999999990.99');
     else
      tmp3 := NULL;
    end if;

tmp := ' <tr style=''height:17.45pt''>
  <td width=54 style=''width:40.5pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#DFDFDF;
  padding:0cm 5.35pt 0cm 5.35pt;height:17.45pt''>
  <h5 style=''margin-bottom:6.0pt''>&nbsp;<span style=''font-size:8.0pt;
  font-family:Arial;font-weight:normal''>Excise</span></h5>
  </td>
  <td width=85 colspan=6 style=''width:63.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:17.45pt''>
  <p class=MsoNormal align=right style=''text-align:right;line-height:9.0pt''>&nbsp;</p>
  </td>
  <td width=50 colspan=2 style=''width:37.6pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:17.45pt''>
  <p class=MsoNormal align=center style=''text-align:center;line-height:9.0pt''>&nbsp;<b><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=95 colspan=7 style=''width:71.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:17.45pt''>
  <p class=MsoNormal align=right style=''text-align:right;line-height:9.0pt''>&nbsp;<b><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp3 ||'</span></b></p>
  </td>
  <td width=34 colspan=2 style=''width:25.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:17.45pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;<b><span style=''font-size:
  8.0pt;font-family:Arial;letter-spacing:-.3pt''>1</span></b></p>
  </td>
  <td width=331 colspan=26 style=''width:248.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#D9D9D9;padding:0cm 5.35pt 0cm 5.35pt;height:17.45pt''>
  <h1 style=''margin-bottom:6.0pt''><span style=''letter-spacing:0pt''>B.
  ACCOUNTING DETAILS</span></h1>
  </td>
 </tr>
';

elsif colin = 'SSS'
 then

  if tariff is not null
   then
    open c5(tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(entryno,tariff);
    fetch c2 into c2rec;
    close c2;
    if nvl(to_number(c2rec.vat),0) > 0
     then
      tmp2 := to_char(to_number(c2rec.vat),'990.99') || '%';
    end if;
   else
    tmp2 := NULL;
   end if;

     if tariff is not null
      then
       open c5(tariff);
       fetch c5 into c5rec;
       close c5;
       open c2(entryno,tariff);
       fetch c2 into c2rec;
       close c2;
       temptot := tot(entryno,tariff);
       tmp3 := to_char(
         round(
               (temptot +
                temptot * (nvl(to_number(c5rec.description),0)/100) +
                (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
               ) *
              (nvl(to_number(c2rec.vat),0)/100),2)
                      ,'999999990.99');
       else
        tmp3 := NULL;
      end if;


tmp := ' <tr style=''height:14.95pt''>
  <td width=54 style=''width:40.5pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#DFDFDF;
  padding:0cm 5.35pt 0cm 5.35pt;height:14.95pt''>
  <h5 style=''margin-bottom:6.0pt''>&nbsp;<span style=''font-size:8.0pt;
  font-family:Arial;font-weight:normal''>VAT</span></h5>
  </td>
  <td width=85 colspan=6 style=''width:63.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:14.95pt''>
  <p class=MsoNormal align=right style=''text-align:right;line-height:9.0pt''>&nbsp;</p>
  </td>
  <td width=50 colspan=2 style=''width:37.6pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:14.95pt''>
  <p class=MsoNormal align=center style=''text-align:center;line-height:9.0pt''>&nbsp;<b><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=95 colspan=7 style=''width:71.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:14.95pt''>
  <p class=MsoNormal align=right style=''text-align:right;line-height:9.0pt''>&nbsp;<b><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp3 ||'</span></b></p>
  </td>
';

elsif colin = 'TTT'
 then
tmp := '  <td width=34 colspan=2 style=''width:25.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:14.95pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;<b><span style=''font-size:
  8.0pt;font-family:Arial;letter-spacing:-.3pt''>1</span></b></p>
  </td>
  <td width=90 colspan=8 style=''width:67.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#D9D9D9;padding:0cm 5.35pt 0cm 5.35pt;height:14.95pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Mode of paymt
  :</span></p>
  </td>
  <td width=127 colspan=12 style=''width:95.45pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#D9D9D9;padding:0cm 5.35pt 0cm 5.35pt;height:14.95pt''>
  <h1 style=''margin-bottom:6.0pt''>&nbsp;</h1>
  </td>
  <td width=44 colspan=4 style=''width:33.3pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#D9D9D9;padding:0cm 5.35pt 0cm 5.35pt;height:14.95pt''>
  <h1 style=''margin-bottom:6.0pt''>&nbsp;</h1>
  </td>
  <td width=69 colspan=2 style=''width:51.55pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#D9D9D9;padding:0cm 5.35pt 0cm 5.35pt;height:14.95pt''>
  <h1 style=''margin-bottom:6.0pt''>&nbsp;</h1>
  </td>
 </tr>
';

elsif colin = 'UUU'
 then

  if tariff is not null
   then
    open c5(tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(entryno,tariff);
    fetch c2 into c2rec;
    close c2;
    if nvl(to_number(c2rec.levy_rate),0) > 0
     then
      tmp2 := to_char(to_number(c2rec.levy_rate),'990.99') || '%';
    end if;
   else
    tmp2 := NULL;
   end if;

  if tariff is not null
   then
    open c5(tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(entryno,tariff);
    fetch c2 into c2rec;
    close c2;
    temptot := tot(entryno,tariff);

    tmp3 := to_char((nvl(to_number(c2rec.levy_rate),0)/100)
    		*(temptot +
		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                (nvl(to_number(c5rec.colc),0)/100),2))),'999999990.99');
    else
     tmp3 := NULL;
   end if;

tmp := ' <tr style=''height:7.9pt''>
  <td width=54 style=''width:40.5pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;background:#DFDFDF;
  padding:0cm 5.35pt 0cm 5.35pt;height:7.9pt''>
  <h5 style=''margin-bottom:6.0pt''>&nbsp;<span style=''font-size:8.0pt;
  font-family:Arial;font-weight:normal''>Levy</span></h5>
  </td>
  <td width=85 colspan=6 style=''width:63.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:7.9pt''>
  <p class=MsoNormal align=right style=''text-align:right;line-height:9.0pt''>&nbsp;</p>
  </td>
  <td width=50 colspan=2 style=''width:37.6pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:7.9pt''>
  <p class=MsoNormal align=center style=''text-align:center;line-height:9.0pt''>&nbsp;<b><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp2 ||'</span></b></p>
  </td>
  <td width=95 colspan=7 style=''width:71.4pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:7.9pt''>
  <p class=MsoNormal align=right style=''text-align:right;line-height:9.0pt''>&nbsp;<b><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>'|| tmp3 ||'</span></b></p>
  </td>';

elsif colin = 'VVV'
 then

tmp := '
  <td width=34 colspan=2 style=''width:25.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:7.9pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;<b><span style=''font-size:
  8.0pt;font-family:Arial;letter-spacing:-.3pt''>1</span></b></p>
  </td>
  <td width=90 colspan=8 style=''width:67.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#D9D9D9;padding:0cm 5.35pt 0cm 5.35pt;height:7.9pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Assessment N°.
  :</span></p>
  </td>
  <td width=127 colspan=12 style=''width:95.45pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#D9D9D9;padding:0cm 5.35pt 0cm 5.35pt;height:7.9pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;</p>
  </td>
  <td width=44 colspan=4 style=''width:33.3pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#D9D9D9;padding:0cm 5.35pt 0cm 5.35pt;height:7.9pt''>
  <p class=MsoNormal style=''line-height:9.0pt''><span style=''font-size:8.0pt;
  font-family:Arial;letter-spacing:-.3pt''>Date :</span></p>
  </td>
  <td width=69 colspan=2 style=''width:51.55pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#D9D9D9;padding:0cm 5.35pt 0cm 5.35pt;height:7.9pt''>
  <p class=MsoNormal style=''line-height:9.0pt''>&nbsp;</p>
  </td>
 </tr>
';

elsif colin = 'WWW'
 then

  if tariff is not null
   then
    open c5(tariff);
    fetch c5 into c5rec;
    close c5;
    open c2(entryno,tariff);
    fetch c2 into c2rec;
    close c2;

    tmp4 := round(tot(entryno,tariff) * (nvl(to_number(c5rec.description),0)/100),2);
    temptot := tot(entryno,tariff);
    tmp5 := round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                 (nvl(to_number(c5rec.colc),0)/100),2);
    tmp6 :=
         round(
               (temptot +
                temptot * (nvl(to_number(c5rec.description),0)/100) +
                (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) * (nvl(to_number(c5rec.colc),0)/100)
               ) *
              (nvl(to_number(c2rec.vat),0)/100),2);
    tmp7 := (nvl(to_number(c2rec.levy_rate),0)/100)
    		*(temptot +
		(round(temptot * (nvl(to_number(c5rec.description),0)/100),2)) +
		(round( (temptot + temptot * (nvl(to_number(c5rec.description),0)/100)) *
                (nvl(to_number(c5rec.colc),0)/100),2)));
    tmp8 := to_char(tmp4 + tmp5 + tmp6 + tmp7,'999999990.99');
   else
     tmp8 := NULL;
   end if;


tmp := ' <tr style=''height:13.55pt''>
  <td width=68 style=''width:51.05pt;border:none;border-left:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''>&nbsp;</p>
  </td>
  <td width=284 colspan=16 style=''width:213.2pt;border:solid windowtext 1.0pt;
  border-top:none;padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal align=right style=''margin-top:6.0pt;margin-right:0cm;
  margin-bottom:0cm;margin-left:0cm;margin-bottom:.0001pt;text-align:right;
  line-height:9.0pt''><a name=Text4><b><span style=''font-size:8.0pt;font-family:
  Arial;letter-spacing:-.3pt''>TOTAL (Item 1)  : '|| tmp8 ||'</span></b></a></p>
  </td>
  <td width=34 colspan=2 style=''width:25.45pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''>&nbsp;</p>
  </td>
';

elsif colin = 'XXX'
 then

tmp := '  <td width=90 colspan=8 style=''width:67.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Receipt Number</span></p>
  </td>
  <td width=127 colspan=12 style=''width:95.45pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''>&nbsp;</p>
  </td>
  <td width=44 colspan=4 style=''width:33.3pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Date :</span></p>
  </td>
  <td width=69 colspan=2 style=''width:51.55pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''>&nbsp;</p>
  </td>
 </tr>
';

elsif colin = 'YYY'
 then
tmp := ' <tr style=''height:13.55pt''>
  <td width=68 style=''width:51.05pt;border:solid windowtext 1.0pt;border-right:
  none;background:#E5E5E5;padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''>&nbsp;</p>
  </td>
  <td width=113 colspan=6 style=''width:84.4pt;border:solid windowtext 1.0pt;
  border-top:none;background:#D9D9D9;padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <h1 style=''margin-top:6.0pt''><span style=''letter-spacing:0pt''>     Value
  Details</span></h1>
  </td>
  <td width=145 colspan=8 style=''width:108.85pt;border:solid windowtext 1.0pt;
  border-left:none;background:#E5E5E5;padding:0cm 5.35pt 0cm 5.35pt;height:
  13.55pt''>
  <p class=MsoNormal align=center style=''margin-top:6.0pt;margin-right:0cm;
  margin-bottom:0cm;margin-left:0cm;margin-bottom:.0001pt;text-align:center;
  line-height:9.0pt''><span style=''font-size:8.0pt;font-family:Arial;letter-spacing:
  -.3pt''>Amount</span></p>
  </td>
  <td width=61 colspan=4 style=''width:45.45pt;border:solid windowtext 1.0pt;
  border-left:none;background:#E5E5E5;padding:0cm 5.35pt 0cm 5.35pt;height:
  13.55pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Currency</span></p>
  </td>
  <td width=90 colspan=8 style=''width:67.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:#DFDFDF;padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Guarantee&nbsp;:</span></p>
  </td>
';

elsif colin = 'ZZZ'
 then
tmp := '  <td width=127 colspan=12 style=''width:95.45pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  background:white;padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''>&nbsp;</p>
  </td>
  <td width=44 colspan=4 style=''width:33.3pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''><span
  style=''font-size:8.0pt;font-family:Arial;letter-spacing:-.3pt''>Date :</span></p>
  </td>
  <td width=69 colspan=2 style=''width:51.55pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.35pt 0cm 5.35pt;height:13.55pt''>
  <p class=MsoNormal style=''margin-top:6.0pt;margin-right:0cm;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:9.0pt''>&nbsp;</p>
  </td>
 </tr>
';
-- end of section 47 for first page


elsif colin = 'L'
 then
  -- Calculate Total Number of Rows for rownum rounded up to the nearest 10..this is a very odd calculation!!
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   c21rec.tot := ((trunc((c21rec.tot - 2) / 3) + 1) * 3) + 1;
   return( to_char(c21rec.tot) );

elsif colin = 'M'
 then
  -- Calculate Total Number of Rows
   /*
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   */
   c21rec.tot := vtot;
   c21rec.tot := c21rec.tot - 1;
   return( to_char(c21rec.tot) );

elsif colin = 'N'
 then
  -- Calculate Total Number of Rows
   open c21(entryno);
   fetch c21 into c21rec;
   close c21;
   return( to_char(c21rec.tot) );

end if;

return( tmp );
exception
 when others then return( sqlerrm );
end form_15_continue;

procedure add_email_log(v_disp_type in varchar2, v_template in varchar2, v_mail_file in varchar2, v_mail_from in varchar2, v_mail_to in varchar2, v_mail_subject in varchar2, v_is_sms in varchar2, v_at_step in varchar2, v_error in varchar2)
as
 s_mail_to	varchar2(4000);
begin
 s_mail_to := substr(v_mail_to,1,4000);
 insert into email_log(date_created,disp_type,template,mail_file,mail_from,mail_to,mail_subject,is_sms,at_step,error)
  values
   (sysdate,v_disp_type,v_template,v_mail_file,v_mail_from,s_mail_to,v_mail_subject,v_is_sms,v_at_step,v_error);
 commit;
end add_email_log;

procedure pline(c in out utl_smtp.connection, bfr in varchar2 )
as
begin
 utl_smtp.write_data(c, utl_tcp.CRLF || bfr);
end pline;

function retrieve_physical_original( fnm in varchar2, blb in out blob )
 return boolean
as

 vfdir        varchar2(100);
 load_file    bfile;
 obj_length   integer;

begin
 create_dir( 'ZIPLOC', glbx.extract_fname(fnm, 'PWD'));

 load_file := bfilename( 'ZIPLOC', glbx.extract_fname(fnm, 'FILE') );

 dbms_lob.fileopen( load_file, dbms_lob.file_readonly );
 obj_length := dbms_lob.getlength(load_file);
 dbms_lob.loadfromfile( blb, load_file, obj_length );
 dbms_lob.fileclose(load_file);
 commit;
 return( TRUE );

exception
 when others then
  glbx.dbg('Retrieve original error: ' || sqlerrm);
  return( FALSE );
end retrieve_physical_original;

/*
function base64( nmb integer ) return varchar2
 as
 begin
  return( substr('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/',nvl(nmb,0)+1,1) );
end base64;

function conv_3bytes( fbytes varchar2 ) return varchar2
 as
  nmb 	integer;
  x	integer;
  y	integer;
  z	integer;
  a	integer; --4867657
 begin
  nmb := (65536*ascii(substr(fbytes,1,1))) + (256*ascii(substr(fbytes,2,1))) + ascii(substr(fbytes,3,1));
  x := trunc(nmb/262144); -- 18
  y := trunc((nmb - (x*262144))/4096);
  z := trunc(((nmb - (x*262144) - (y*4096)))/64);
  a := nmb - (x*262144) - (y*4096) - (z*64);
  return( base64(x) || base64(y) || base64(z) || base64(a)); -- || ':' || to_char(x) || '-' || to_char(y) || '-' || to_char(z) || '-' || to_char(a)
end conv_3bytes;

procedure dump_blob( c in out utl_smtp.connection, img in blob )
as

 v_count	integer;
 c_imgchunk	binary_integer;
 v_imgchunk	binary_integer;
 v_buffer 	raw(255);
 contentlength  integer;
 bfr		varchar2(2000);
 xbufr		varchar2(2000);

begin

-- replace with call to C prog
-- dump blob to file
-- convert file
-- read file in and pline it

 if dbms_lob.getlength(img) = 0 then return; end if;

  c_imgchunk := 57;
  v_imgchunk := 57;
  v_count := 0;
  begin
   loop
    dbms_lob.read(img,v_imgchunk,(v_count*c_imgchunk)+1,v_buffer);
    v_count := v_count + 1;
    bfr := NULL;
    xbufr := sys.utl_raw.cast_to_varchar2(v_buffer);
    for j in 1..19 loop
     bfr := bfr || conv_3bytes(substr(xbufr,((j-1)*3)+1,3));
    end loop;
    pline( c, bfr );
   end loop;
  exception
   when no_data_found then null;
   when others
    then return;
  end;
  bfr := NULL;
  xbufr := sys.utl_raw.cast_to_varchar2(v_buffer);
  if mod(length(xbufr),3) = 1 then xbufr := xbufr || chr(0) || chr(0);
  elsif mod(length(xbufr),3) = 2 then xbufr := xbufr || chr(0);
  end if;
  for j in 1..length(trunc(length(v_buffer)/3)) loop
   bfr := bfr || conv_3bytes(substr(xbufr,((j-1)*3)+1,3));
  end loop;
  pline( c, bfr );
exception
 when others then return;
end dump_blob;
*/

procedure dump_blob( c in out utl_smtp.connection, img in blob, fname in varchar2 default null, display_mime_header in boolean default FALSE )
as

 v_count	integer;
 c_imgchunk	binary_integer;
 v_imgchunk	binary_integer;
 v_buffer 	raw(32767);
 v_chunk	varchar2(32767);
 contentlength  integer;
 bfr		varchar2(2000);
 xbufr		varchar2(2000);
 bl		boolean;

begin
 if dbms_lob.getlength(img) = 0 then return; end if;

 if display_mime_header
  then
   pline( c,'--');
   pline( c,'Content-Type: APPLICATION/octet-stream; name="' || fname || '"' );
   pline( c,'Content-Transfer-Encoding: BASE64' );
   pline( c,'Content-Description:' );
   pline( c,'' );
  end if;

  if dbms_lob.getlength( img ) = 0 then return; end if;

  c_imgchunk := 57;
  v_imgchunk := 57;
  v_count := 0;
  begin
   loop
    dbms_lob.read(img, v_imgchunk,(v_count*c_imgchunk)+1,v_buffer);
    v_count := v_count + 1;
    bfr := NULL;
    xbufr := sys.utl_raw.cast_to_varchar2( utl_encode.base64_encode( v_buffer ) );
    xbufr := replace(replace(xbufr,chr(13),null),chr(10),null);
    pline( c, xbufr );
   end loop;
  exception
   when no_data_found then null;
   when others
    then
     glbx.dbg( 'Dump Blob Error:' || sqlerrm );
     null;
  end;
  pline( c, bfr );

exception
 when others then return;
end dump_blob;

procedure create_dir( fdirname in varchar2, floc in varchar2 )
as
 cursor c1( floc varchar2 ) is select directory_name from all_directories where directory_path = floc;
 c1rec   c1%ROWTYPE;
begin
 open c1( floc );
 fetch c1 into c1rec;
 if c1%FOUND
  then
   close c1;
   return;
 end if;
 close c1;

 execute immediate 'create or replace directory ' || fdirname || ' as ''' || floc || '''';
end create_dir;

function send_files_smtp(p_from in varchar2, p_to in varchar2, p_subj in varchar2 )
 return boolean
as

blb          blob;
l_template   utl_file.file_type;
l_output2    utl_file.file_type;
p_body       varchar2(4000);
c            utl_smtp.connection;
at_step      varchar2(20);
x            integer;
ctr          integer;
currj        integer;
lastctr      integer;
disphtml     varchar2(32767);
fnm          varchar2(1000);

procedure send_header(c in out utl_smtp.connection, name in varchar2, header in varchar2, nline in boolean default TRUE) as
 begin
  if nline
   then
    utl_smtp.write_data(c,name || ':' || header || utl_tcp.CRLF );
   else
    utl_smtp.write_data(c,name || ':' || header );
  end if;
end;

begin

 -- dbms_output.put_line(glbx.extract_master_parameter('SMTP_SERVER'));
 at_step := 'Step1';
 c := utl_smtp.open_connection(glbx.extract_master_parameter('SMTP_SERVER')); -- SMTP Server
 at_step := 'Step2';
 utl_smtp.helo(c,glbx.extract_master_parameter('SMTP_SERVER') );
 at_step := 'Step2a';
 utl_smtp.mail(c,'<' || p_from || '>');
 at_step := 'Step3';

 if instr(p_to,',') > 0
  then
   x := 1;
   lastctr := 0;
   loop
    ctr := instr(p_to,',',1,x);
    if ctr = 0
     then
      utl_smtp.rcpt(c,'<' || trim(substr(p_to,lastctr+1)) || '>');
      exit;
    end if;
    utl_smtp.rcpt(c,'<' || trim(substr(p_to,lastctr+1,(ctr-lastctr)-1)) || '>');
    x := x + 1;
    lastctr := ctr;
   end loop;
  else
   utl_smtp.rcpt(c,'<' || trim(p_to) || '>');
 end if;

 at_step := 'Step4';
 utl_smtp.open_data(c);
 at_step := 'Step5';
 send_header(c, 'From','"Sender" <' || p_from || '>');
 at_step := 'Step6';
 send_header(c, 'To','"Recipient" <' || replace(p_to,',','><') || '>');
 at_step := 'Step7';
 send_header(c, 'Subject',p_subj,FALSE);
 at_step := 'Step8';
 pline(c,'MIME-Version: 1.1');

 -- Display Mime Type Headers
 pline(c,'Content-Type: multipart/related; boundary="----=_UMO_ID_' || '3D2D4C15C6C7EF3943C2EE26' || '"');

 dbms_lob.createtemporary( blb, FALSE);
 for j in dapi.GLOBAL_ARRAY.first..dapi.GLOBAL_ARRAY.last loop
 fnm := dapi.GLOBAL_ARRAY(j);
 -- glbx.dbg('Loading file: ' || fnm);
 if retrieve_physical_original(fnm,blb)
  then
   pline(c, null);
   pline(c, '------=_UMO_ID_' || '3D2D4C15C6C7EF3943C2EE26');
   if upper(glbx.extract_fname(fnm, 'SUFFIX')) = 'ZIP'
    then
     pline( c,'Content-Type: ' || 'application/x-zip-compressed' || '; name="' || nvl(glbx.extract_fname(fnm, 'FILE'),'download.file') || '"' );
   else
     pline( c,'Content-Type: ' || 'application/octet-stream' || '; name="' || nvl(glbx.extract_fname(fnm, 'FILE'),'download.file') || '"' );
   end if;
   -- glbx.dbg('[' || dbms_lob.getlength(blb) || ']: ' || nvl(glbx.extract_fname(fnm, 'FILE'),'download.file'));
   pline( c,'Content-Transfer-Encoding: base64' );
   pline( c,'Content-Disposition: attachment; filename="' || nvl(glbx.extract_fname(fnm, 'FILE'),'download.file') || '"' );
   -- pline( c,'Content-ID: ' || '3D2D4C15C6C7EF3943C2EE26_BLOB'  );
   pline( c,null);
   dump_blob( c, blb );
   dbms_lob.trim(blb, 0);
  end if;
 end loop;
 begin dbms_lob.freetemporary(blb); exception when others then null; end;

 pline( c, '------=_UMO_ID_' || '3D2D4C15C6C7EF3943C2EE26' || '--' ); -- to_char(v_umo)

 at_step := 'Step9';
 utl_smtp.close_data(c);
 utl_smtp.quit(c);
 add_email_log('EMAIL SEND',glbx.extract_master_parameter('MAIL_OUTPUT_DIR') || '-' || glbx.extract_master_parameter('SMTP_SERVER'),'Image Name:' || fnm,p_from,p_to,p_subj,'F','SMTP Send:' || at_step,null);
 return( TRUE );

 exception
  when others
   then
    add_email_log('ERROR ON SEND', 'UMO ID:' || currj || '-' || glbx.extract_master_parameter('SMTP_SERVER'),'Image Name:' || fnm,p_from,p_to,p_subj,'F','SMTP Send Error:' || at_step,sqlerrm);
    return( FALSE );
end send_files_smtp;

procedure accept_sads_by_ship(surl varchar2, shipid number, vact varchar2 default 'STATUS')
as

cursor c1(vjob varchar2) is
 select *
 from   user_scheduler_jobs
 where  upper(job_name) = vjob
 ;

cursor c2(v_ship integer) is
 select *
 from   strang.sads_by_ship_log
 where  ship_id = v_ship
 order  by order_by
 ;

v_job_prefix  CONSTANT varchar2(100) := 'SADS_BY_SHIP_';
c1rec         c1%ROWTYPE;
v_job         varchar2(100);

begin
htp.htmlopen;
htp.headopen;
htp.p('<link rel="stylesheet" type="text/css" href="/images/str/style.css" />'); htp.nl;
htp.headclose;
htp.bodyopen;

v_job := v_job_prefix || shipid;
open c1(v_job);
fetch c1 into c1rec;
case vact
 when 'STATUS'
  then
   if c1%FOUND
    then
     htp.header(1, 'Job ' || v_job || '. State = ' || c1rec.state); htp.nl;
   else
     htp.header(1, 'Job ' || v_job || '. NOT FOUND'); htp.nl;
   end if;
   htp.anchor('strangs.accept_sads_by_ship?surl=' || surl || '&shipid=' || shipid, 'Refresh');
   htp.tableopen;
   htp.tablerowopen;
    htp.tableheader('Time');
  htp.tableheader('Message');
   htp.tablerowclose;
   for c2rec in c2(shipid) loop
    htp.tablerowopen;
   htp.tabledata(to_char(c2rec.tm, 'dd-Mon-yyyy hh24:mi:ss'));
   htp.tabledata(c2rec.message);
  htp.tablerowclose;
   end loop;
   htp.tableclose;
   if c1%NOTFOUND
    then
     htp.anchor('strangs.accept_sads_by_ship?surl=' || surl || '&shipid=' || shipid || '&vact=CULL', 'Cull Logs'); htp.nl;
   end if;
 when 'CULL'
  then
   delete from strang.sads_by_ship_log where  ship_id = shipid;
   commit;
   htp.header(1, 'Logs deleted');
 when 'TERMINATE'
  then
   dbms_scheduler.stop_job(v_job);
   htp.header(1, 'Job ' || v_job || ' cancelled');
 when 'START'
  then
   if c1%FOUND
    then
     htp.header(1, 'Job ' || v_job || ' already running');
   else
     dbms_scheduler.create_job( job_name=> v_job
                              , job_type=> 'STORED_PROCEDURE'
                              , job_action=> 'strangs.sads_by_ship'
                              , number_of_arguments=> 2
                              , enabled=> FALSE
                              , comments=> 'Generate SADS for Ship ID ' || shipid
                              )
     ;
     dbms_scheduler.set_job_argument_value( job_name => v_job
                                          , argument_position => 1
                                          , argument_value => surl
                                          )
     ;
     dbms_scheduler.set_job_argument_value( job_name => v_job
                                          , argument_position => 2
                                          , argument_value => shipid
                                          )
     ;
     dbms_scheduler.enable(v_job);
     htp.header(1, 'Job ' || v_job || ' submitted');
   end if;
end case;
if vact='STATUS'
 then
  htp.anchor('strangs.accept_sads_by_ship?surl=' || surl || '&shipid=' || shipid, 'Refresh'); htp.nl;
else
  htp.anchor('strangs.accept_sads_by_ship?surl=' || surl || '&shipid=' || shipid, 'Status'); htp.nl;
end if;
if c1%FOUND and vact <> 'TERMINATE'
 then
  htp.anchor('strangs.accept_sads_by_ship?surl=' || surl || '&shipid=' || shipid || '&vact=TERMINATE', 'Stop Job'); htp.nl;
end if;
htp.bold( '<a href="" onClick="self.close()">' || 'Close Window' || '</a>'); htp.nl;
close c1;
htp.bodyclose;
htp.htmlclose;
exception when others then
  begin close c1; exception when others then null; end;
  glbx.error_details( 'STRANGS', 'ACCEPT_SADS_BY_SHIP',dapi.GLOBAL_CUSTOMER_ACCOUNT.pid,dapi.GLOBAL_CUSTOMER_ACCOUNT.aid,errmsg=>sqlerrm,extdet=>'SHIP_ID:' || shipid);
end accept_sads_by_ship;

procedure sads_by_ship(surl varchar2, shipid number)
as



cursor c1(shipid in number) is
select distinct m.bol, min(dr.entry_no) parm1, max(dr.entry_no) parm1a
from
strang.movements m, strang.ships_airway s, strang.receivals r, strang.detailrs dr
where
s.ship_id = shipid and
m.ship_id = s.ship_id and
r.cust_customer_id = 1 and
r.deliveryno = dr.deliveryno and
m.movement_no = dr.movement_no and
nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
group by bol
order by bol;

cursor c1a(shipid in number) is
select distinct dr.hawb_hawbno, min(dr.entry_no) parm1, max(dr.entry_no) parm1a
from
strang.movements m, strang.ships_airway s, strang.receivals r, strang.detailrs dr
where
s.ship_id = shipid and
m.ship_id = s.ship_id and
r.cust_customer_id = 1 and
r.deliveryno = dr.deliveryno and
m.movement_no = dr.movement_no and
nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
group by hawb_hawbno
order by hawb_hawbno;

cursor c2(shipid in number) is
select distinct c.customer
from strang.customers c
where
customer_id = 1;

cursor c3(shipid in number) is
select shipname, voy, ship_airway
from   strang.ships_airway
where  ship_id = shipid
;

c1rec    c1%ROWTYPE;
c2rec    c2%ROWTYPE;
c3rec    c3%ROWTYPE;
ltype    varchar2(100);
stype    integer;
owner_id  integer;
sts    varchar2(100);
retval      varchar2(4000);
ctr         integer;
v_validate_num  integer; -- added by DB on 17/7/2023
v_error_desc   varchar2(500); -- added by DB on 17/7/2023


-- Start inline procedures
procedure log_status(v_msg varchar2, v_act varchar2 default 'APPEND', v_commit boolean default TRUE) is
begin
 ctr := ctr + 1;
 case v_act
 when 'RESET'
  then delete from strang.sads_by_ship_log where ship_id = shipid;
 when 'APPEND'
  then
   insert into strang.sads_by_ship_log(ship_id, order_by, tm, message)
   values (shipid, ctr, sysdate, v_msg)
   ;
 end case;
 if v_commit then commit; end if;
exception when others then null;
end log_status;
-- End inline procedures

begin

glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.SHP' );
if sts is not null
 then
 glbx.redisplay_login_page( sts, TRUE );
 return;
end if;

open c2(shipid);
fetch c2 into c2rec;
close c2;

open c3(shipid);
fetch c3 into c3rec;
close c3;

dapi.GLOBAL_ARRAY.delete;
ctr := 0;
log_status(NULL,'RESET',TRUE);
log_status('Ship/MAWB: ' || c3rec.shipname || ' ' || c3rec.voy || ' - STARTED');

if c3rec.ship_airway = 'S' then
 for c1rec in c1( shipid ) loop
  v_validate_num := null;
  v_validate_num := strang.validate_entry( c2rec.customer,c1rec.parm1,c1rec.parm1a,'RANGE');
   
 -- if strang.validate_entry( c2rec.customer,c1rec.parm1,c1rec.parm1a,'RANGE') < 1
  if nvl(v_validate_num,1) =  -1 then
     -- htp.p('Incomplete SAD '|| c1rec.bol ||' Entry numbers '|| c1rec.parm1 ||' To '|| c1rec.parm1a); htp.nl;
     log_status('Incomplete SAD: Inventoryno is null '|| c1rec.bol ||' Entry numbers '|| c1rec.parm1 ||' To '|| c1rec.parm1a);
  elsif nvl(v_validate_num,1) =  -2 then 
     log_status('Incomplete SAD: Inventoryno not in lookup '|| c1rec.bol ||' Entry numbers '|| c1rec.parm1 ||' To '|| c1rec.parm1a);
  elsif nvl(v_validate_num,1) =  -3 then
     log_status('Incomplete SAD: Inventory code has no tariff '|| c1rec.bol ||' Entry numbers '|| c1rec.parm1 ||' To '|| c1rec.parm1a);
  elsif nvl(v_validate_num,1) =  -4 then
     log_status('Incomplete SAD: Inventory tariff not in lookup '|| c1rec.bol ||' Entry numbers '|| c1rec.parm1 ||' To '|| c1rec.parm1a);
  elsif nvl(v_validate_num,1) =  -5 then
      log_status('Incomplete SAD: PO item unit_unitused invalid for tariff '|| c1rec.bol ||' Entry numbers '|| c1rec.parm1 ||' To '|| c1rec.parm1a);
  elsif nvl(v_validate_num,1) =  -6 then
      log_status('Incomplete SAD: Exchange rate not found for ship''s ETA '|| c1rec.bol ||' Entry numbers '|| c1rec.parm1 ||' To '|| c1rec.parm1a);
  elsif nvl(v_validate_num,1) =  -7 then
      log_status('Incomplete SAD: Line no is null '|| c1rec.bol ||' Entry numbers '|| c1rec.parm1 ||' To '|| c1rec.parm1a);
  elsif strang.validate_single_customer( c2rec.customer,c1rec.parm1,c1rec.parm1a,'RANGE') < 1
   then
     -- htp.p('Multiple Customers for SAD '|| c1rec.bol ||' Entry numbers '|| c1rec.parm1 ||' To '|| c1rec.parm1a); htp.nl;
     log_status('Multiple Customers for SAD '|| c1rec.bol ||' Entry numbers '|| c1rec.parm1 ||' To '|| c1rec.parm1a);
  else

    log_status(c1rec.parm1 || ' CONSOLIDATE: Started');
    retval := strang.f_sad_sad_com( 'ZZ', c1rec.parm1, c1rec.parm1a);
    log_status(c1rec.parm1 || ' CONSOLIDATE: Completed; GENERATE Started');
    retval := strang.f15_parameter_range_com( 'SAD_SAD_COM_NOEMAIL', c1rec.parm1,'Y' );
    log_status(c1rec.parm1 || ' GENERATE: Completed; DE-CONSOLIDATE Started');
    retval := strang.f_sad_sad_com( 'ZZZ', c1rec.parm1, c1rec.parm1a );
    log_status(c1rec.parm1 || ' DE-CONSOLIDATE: Completed');
    if dapi.GLOBAL_ARRAY.count = 0 then
       log_status(c1rec.parm1 || ' No records sent - please check updated exchange rate list');
    end if;
    log_status(rpad('=', length('1.011843') + 26, '='));
  end if;
 end loop;
else
 for c1arec in c1a( shipid ) loop
  v_validate_num := null;
  v_validate_num := strang.validate_entry( c2rec.customer,c1arec.parm1,c1arec.parm1a,'RANGE');
  if nvl(v_validate_num,1) = -1 then 
     -- htp.p('Incomplete SAD '|| c1arec.hawb_hawbno ||' Entry numbers '|| c1arec.parm1 ||' To '|| c1arec.parm1a); htp.nl;
     log_status('Incomplete SAD: Inventoryno is null '|| c1arec.hawb_hawbno ||' Entry numbers '|| c1arec.parm1 ||' To '|| c1arec.parm1a);
  elsif nvl(v_validate_num,1)=  -2 then 
     log_status('Incomplete SAD: Inventoryno not in lookup  '|| c1arec.hawb_hawbno ||' Entry numbers '|| c1arec.parm1 ||' To '|| c1arec.parm1a);
  elsif nvl(v_validate_num,1) =  -3 then
     log_status('Incomplete SAD: Inventory code has no tariff '|| c1arec.hawb_hawbno ||' Entry numbers '|| c1arec.parm1 ||' To '|| c1arec.parm1a);
  elsif nvl(v_validate_num,1) =  -4 then
     log_status('Incomplete SAD: Inventory tariff not in lookup '|| c1arec.hawb_hawbno ||' Entry numbers '|| c1arec.parm1 ||' To '|| c1arec.parm1a);
  elsif nvl(v_validate_num,1) =  -5 then
     log_status('Incomplete SAD: PO item unit_unitused invalid for tariff '|| c1arec.hawb_hawbno ||' Entry numbers '|| c1arec.parm1 ||' To '|| c1arec.parm1a);
  elsif nvl(v_validate_num,1) =  -6 then
     log_status('Incomplete SAD: Exchange rate not found for ship''s ETA '|| c1arec.hawb_hawbno ||' Entry numbers '|| c1arec.parm1 ||' To '|| c1arec.parm1a);
  elsif nvl(v_validate_num,1) =  -7 then
     log_status('Incomplete SAD: Line no is null '|| c1arec.hawb_hawbno ||' Entry numbers '|| c1arec.parm1 ||' To '|| c1arec.parm1a); 
  elsif strang.validate_single_customer( c2rec.customer,c1arec.parm1,c1arec.parm1a,'RANGE') < 1
   then
     -- htp.p('Multiple Customers for SAD '|| c1arec.bol ||' Entry numbers '|| c1arec.parm1 ||' To '|| c1arec.parm1a); htp.nl;
     log_status('Multiple Customers for SAD '|| c1arec.hawb_hawbno ||' Entry numbers '|| c1arec.parm1 ||' To '|| c1arec.parm1a);
  else
    log_status(c1arec.parm1 || ' CONSOLIDATE: Started');
    retval := strang.f_sad_sad_com( 'ZZ', c1arec.parm1, c1arec.parm1a);
    log_status(c1arec.parm1 || ' CONSOLIDATE: Completed; GENERATE Started');
    retval := strang.f15_parameter_range_com( 'SAD_SAD_COM_NOEMAIL', c1arec.parm1,'Y' );
    log_status(c1arec.parm1 || ' GENERATE: Completed; DE-CONSOLIDATE Started');
    retval := strang.f_sad_sad_com( 'ZZZ', c1arec.parm1, c1arec.parm1a );
    log_status(c1arec.parm1 || ' DE-CONSOLIDATE: Completed');
    if dapi.GLOBAL_ARRAY.count = 0 then
       log_status(c1rec.parm1 || ' No records sent - please check updated exchange rate list');
    end if;
    log_status(rpad('=', length('1.011843') + 26, '='));
  end if;
 end loop;
end if;
log_status('Ship/MAWB: ' || c3rec.shipname || ' ' || c3rec.voy || ' - Sending Email');

websys.strangs.email_sad_file_multi(dapi.GLOBAL_SURL);
log_status('Ship/MAWB: ' || c3rec.shipname || ' ' || c3rec.voy || ' - COMPLETE');

-- htp.p( 'SADs for ship emailed' ); htp.nl;

exception
  when others then
   log_status('Error: ' || sqlerrm);
end sads_by_ship;


end strangs;
/


GRANT EXECUTE ON WEBSYS.STRANGS TO STRANG;
