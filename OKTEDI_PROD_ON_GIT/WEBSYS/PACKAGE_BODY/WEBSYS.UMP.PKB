CREATE OR REPLACE package body WEBSYS.ump
as

 Gparmarr1 	 ump.parameters;
 Gparmarr2 	 ump.parameters;
 GLOBAL_OUTPUT   varchar2(100);
 GLOBAL_METADATA boolean;

 function find_parameter( parm_name in varchar2, parm1 in UMP.PARAMETERS, parm2 in UMP.PARAMETERS, retval out varchar2 ) return boolean;
 function photo_convert( imgtype in varchar2 default 'JPEG', compr in varchar2 default 'LOW', orig in varchar2 default 'JPEG' ) return varchar2;
 function calculate_resize( original_width in integer, original_height in integer, original_length in integer, scaleto in integer, scalethreshold in integer ) return varchar2;
 function check_quota( surl varchar2,owner_type in varchar2, owner_id in integer, acid in integer, size_bytes in integer, bypass_check in varchar2, pname in varchar2, retval out varchar2) return boolean;
 function scene_title( scene_id in integer, scene_ord out integer) return varchar2;
 function check_ignore( checkval in varchar2, ignore_str in varchar2, infloop in integer default 0 ) return boolean;
 function conv_compr( compr in varchar2 ) return varchar2;
 function extract_fname( nme in varchar2 ) return varchar2;
 function check_image( pmaster in ORDSYS.ORDIMAGE, serrm in varchar2, scode in number ) return varchar2;
 function retrieve_email( acid integer, phgid integer, ltype varchar2 ) return varchar2;
 function extract_tokens( tval in varchar2, ctr in integer, split_numbers in char, tokens in out nocopy myarray ) return varchar2;

 procedure delete_websys( fname in varchar2, nocommit in varchar2 default 'COMMIT' );
 procedure modify_entry( v_umo in integer, attrib_id in integer, data_value in varchar2, acid in integer, posid in integer default 1, action in varchar2 default 'INSERT', bypass_procedure in varchar2 default null, extract_numbers in char default 'F');
 procedure create_scene( v_category in varchar2, v_title in varchar2, v_owner in varchar2, v_ordering in varchar2, v_owner_id in integer, v_parent_id in integer default null );
 procedure new_images_email( sec_details in SECURITY_DETAILS, result_list in UMP.SEARCH_RESULT_PHG, totrec in integer );
 procedure access_denied_image;
 procedure upload_zip( surl in varchar2, ows_name in varchar2, vparm1 in UMP.PARAMETERS, vparm2 in UMP.PARAMETERS, retval out varchar2, new_umo_id out myarray_int );
 procedure unload_zip( surl in varchar2, zipfile_location in varchar2, vparm1 in UMP.PARAMETERS, vparm2 in UMP.PARAMETERS, retval out varchar2, new_umo_id out myarray_int );
 procedure set_timestamp( v_umo in integer, com in varchar2 );
 procedure process_display_output( display_output GLBX.MYARRAY );
 procedure webservice_search( surl in varchar2, result_list in UMP.SEARCH_RESULT_PHG );
 procedure resize_master( pimg in out ORDSYS.ORDIMAGE, ctx in out raw );

 procedure init( acid in integer, utype in varchar2, v_umo out integer )
 as
  cursor c1 is select substr(version,1,instr(version,'.')-1) version from v$instance;
  cursor c2(utype varchar2) is select object_class from object_class where upper(umo_type) = utype and is_default = 'T';

  c1rec  c1%ROWTYPE;
  c2rec  c2%ROWTYPE;
 begin

  -- Note: Review storage issues here. Might need to reserve some space because an object might have a number of updates to it.
  open c1;
  fetch c1 into c1rec;
  close c1;

  open c2(nvl(upper(utype),'PHOTO'));
  fetch c2 into c2rec;
  close c2;
  c2rec.object_class := nvl(c2rec.object_class,'PHOTO');

  select s_umo.nextval into v_umo from dual;
  set_timestamp( v_umo, 'Initialise Before' );
  if c1rec.version = '8'
   then
    execute immediate
     'insert into umo
        ( umo_id,date_created,parent_id,aid,umo_type,photo_original_loc,umo_scene_id,umo_owner,ftp_location,ftp_virtual_dir,
          photo_original,photo_master,photo_thumbnail,photo_backup,
          audio_original,audio_thumbnail,
          video_original,blueprint_obj,program_obj,
          doc_body, doc_length, extras, sessid, signature, object_class )
       values
        ( :v_umo, sysdate, null, :acid, :utype, null, null, null, null, null,
          ORDSYS.ORDImage(ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,NULL,NULL,NULL,NULL,NULL),
          ORDSYS.ORDImage(ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,NULL,NULL,NULL,NULL,NULL),
          ORDSYS.ORDImage(ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,NULL,NULL,NULL,NULL,NULL),
          ORDSYS.ORDImage(ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,NULL,NULL,NULL,NULL,NULL),
          ORDSYS.ORDAudio(NULL,ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,empty_clob(),NULL,NULL,NULL,NULL,NULL,NULL),
          ORDSYS.ORDAudio(NULL,ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,empty_clob(),NULL,NULL,NULL,NULL,NULL,NULL),
          ORDSYS.ORDVideo(NULL,ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,empty_clob(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
          BLUEPRINT_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,empty_blob(),empty_blob()),
          PROGRAM_TYPE(null,null,null,null,null,null,null,null,null,null,null,null),
          empty_blob(), null, repeated_fields(null,null,null,null,null,null,null,''TRUE'',''TRUE'' ),null,null,:object_class
        )' using v_umo, acid, nvl(upper(utype),'PHOTO'), c2rec.object_class;
    elsif c1rec.version in ('9','10')
     then
    execute immediate
     'insert into umo
        ( umo_id,date_created,parent_id,aid,umo_type,photo_original_loc,umo_scene_id,umo_owner,ftp_location,ftp_virtual_dir,
          photo_original,photo_master,photo_thumbnail,photo_backup,
          audio_original,audio_thumbnail,
          video_original,blueprint_obj,program_obj,
          doc_body, doc_length, extras, sessid, signature, object_class )
       values
        ( :v_umo, sysdate, null, :acid, :utype, null, null, null, null, null,
          ORDSYS.ORDImage(ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,NULL,NULL,NULL,NULL,NULL),
          ORDSYS.ORDImage(ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,NULL,NULL,NULL,NULL,NULL),
          ORDSYS.ORDImage(ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,NULL,NULL,NULL,NULL,NULL),
          ORDSYS.ORDImage(ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,NULL,NULL,NULL,NULL,NULL),
          ORDSYS.ORDAudio(NULL,ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,empty_clob(),NULL,NULL,NULL,NULL,NULL,NULL),
          ORDSYS.ORDAudio(NULL,ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,empty_clob(),NULL,NULL,NULL,NULL,NULL,NULL),
          ORDSYS.ORDVideo(NULL,ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,empty_clob(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
          BLUEPRINT_TYPE(NULL,NULL,NULL,NULL,NULL,NULL,empty_blob(),empty_blob()),
          PROGRAM_TYPE(null,null,null,null,null,null,null,null,null,null,null,null),
          empty_blob(), null, repeated_fields(null,null,null,null,null,null,null,''TRUE'',''TRUE'' ),null,ORDSYS.ORDImageSignature.init(),:object_class
        )' using v_umo, acid, nvl(upper(utype),'PHOTO'), c2rec.object_class;
    end if;
  set_timestamp( v_umo, 'Initialise After' );
end init;

 procedure load_uma( surl varchar2, parm1 in UMP.PARAMETERS, parm2 in UMP.PARAMETERS, retval out varchar2, new_umo_id out myarray_int, bypass_surl in boolean default FALSE )
 as

  cursor c1(v_umo_id integer) is select * from umo where umo_id = v_umo_id for update nowait;
  cursor c2(acid integer, fname varchar2, objtype varchar2) is
   select umo_id
   from umo um
   where upper(nvl(photo_original_loc,fname)) = upper(fname) and
         aid = acid and
         umo_type=objtype;
  cursor cattr(objtype varchar2, acid integer) is
   select *
   from umo_attributes
   where umo_type = objtype and
         ((business_feature is null) or
          (business_feature is not null and business_feature = (select theme_type from customer_account ca where ca.aid = acid))
         );
  --cursor c4(ows_name varchar2) is select oc.length from ows_content oc,ows_object ob where oc.oid = ob.oid and ob.name = ows_name;
  cursor c4a(ows_name varchar2) is select doc_size length from apache_ows_content where name = ows_name;
  cursor c5( acid integer ) is select pid from customer_account where aid = acid;
  cursor c6(ows_name varchar2) is select blob_content from apache_ows_content where name = ows_name for update nowait;

  imagex	ORDSYS.ORDImage;
  imagey	ORDSYS.ORDImage;
  umo_rec	c1%ROWTYPE;
  --imgB2  	ORDSYS.ORDimgF;
  document_bfile bfile;
  load_file	bfile;
  work_img	blob;
  v_extras	REPEATED_FIELDS := repeated_fields(null,null,null,null,null,null,null,'TRUE','TRUE');
  c4rec		c4a%ROWTYPE;
  obj_length	integer;
  v_umo		integer;
  result 	integer;
  thb_qual	number;
  phgid		integer;
  delete_obj	boolean;
  initialised   boolean;
  nocompressif	integer;
  format_type	varchar2(40);
  mime_type	varchar2(100);
  objtype	varchar2(1000);
  umo_ownr	varchar2(1000);
  category	varchar2(1000);
  acid		integer;
  owner_id	integer;
  before_size	integer;
  retval1	varchar2(1000);
  retval2	varchar2(1000);
  retval3	varchar2(1000);
  retval4	varchar2(1000);
  retval5	varchar2(1000);
  retval6	varchar2(1000);
  retval7	varchar2(1000);
  retval8	varchar2(1000);
  retval9	varchar2(1000);
  convstr	varchar2(1000);
  byp_quota	varchar2(1000);
  store_orig	varchar2(1000);
  ftype		varchar2(1000);
  vrollid	varchar2(1000);
  vfsize	varchar2(1000);
  ows_name	varchar2(1000);
  def_ftp	varchar2(1000);
  def_ftp_loc	varchar2(1000);
  reload_photo	varchar2(1000);
  retsess	varchar2(100);
  session_id	integer;
  srt		integer;
  step		varchar2(100);
  sts		varchar2(200);
  ctx 		RAW(4000) := NULL;
  pfx		theme%ROWTYPE;

 begin

  set_timestamp( v_umo, 'Load Start of Image' );
  step := 'Start';
  if not find_parameter( 'DEBUG', parm1, parm2, retval ) then retval := 'FALSE'; end if;
  retval3 := retval;

  if retval3 = 'TRUE'
   then
    for j in parm1.first..parm1.last loop
     htp.p( parm1(j) || '-' || parm2(j) ); htp.nl;
    end loop;
  end if;

  if not find_parameter( 'LOAD_FROM_FILE_OR_UPLOAD', parm1, parm2, retval ) then return; end if;
  retval3 := retval;
  if not find_parameter( 'OBJECT_TYPE', parm1, parm2, retval ) then return; end if;
  objtype := retval;
  if objtype = 'AUTO'
   then
    if not find_parameter( 'FILM_NAME', parm1, parm2, retval ) then retval := '.JPG'; end if;
    objtype := nvl(glbx.auto_file_type( retval ),'PHOTO');
  end if;
  if not find_parameter( 'UMO_OWNER', parm1, parm2, retval ) then retval := 'PHOTOGRAPHER'; end if;
  umo_ownr := retval;
  if not find_parameter( 'AID', parm1, parm2, retval ) then if umo_ownr <> 'ADMINISTRATOR' then return; end if; retval := NULL; end if;
  acid := to_number(retval);
  if not find_parameter( 'PARENT_UMO_ID', parm1, parm2, retval ) then retval := NULL; end if;
  retval5 := retval;
  if not find_parameter( 'ORIGINAL_LOCATION', parm1, parm2, retval ) then retval := NULL; end if;
  retval6 := replace(retval,'''','''''');
  if not find_parameter( 'KEEP_STATUS', parm1, parm2, retval ) then retval := 'KEEP'; end if;
  retval7 := retval;
  if not find_parameter( 'SCENE_ID', parm1, parm2, retval ) then retval := NULL; end if;
  retval8 := retval;
  if not find_parameter( 'BYPASS_QUOTA_CHECK', parm1, parm2, retval ) then retval := 'FALSE'; end if;
  byp_quota := retval;
  if not find_parameter( 'CATEGORY', parm1, parm2, retval ) then retval := 'WEDDING'; end if;
  category := retval;
  if not find_parameter( 'STORE_ORIGINAL', parm1, parm2, retval ) then retval := 'FALSE'; end if;
  store_orig := retval;
  if not find_parameter( 'NOCOMPRESSIF', parm1, parm2, retval ) then retval := null; end if;
  nocompressif := to_number(retval);
  retval := NULL;
  if not find_parameter( 'SESSION_ID', parm1, parm2, retval ) then session_id := null; end if;
  begin session_id := to_number(retval); exception when others then session_id := null; end;

 pfx := glbx.get_thm( acid );

  -- Delete original if requested
  step := 'Look to Delete';
  if substr(retval7,1,1) = 'D'
   then
    delete from log_photo_mod where phid = v_umo;
    delete from umo_index where umo_id = v_umo;
    delete from umo_attribute where umo_id = v_umo;
    delete from umo_link um where umo_id = v_umo;
    delete from umo_link um where to_umo_id = v_umo;
    if objtype = 'DOCUMENT'
     then
      ump.document_index(v_umo=>v_umo,schemaname=>user,howloaded=>NULL,action=>'DELETE');
    end if;
    update umo set attribute2 = 'F' where (umo_scene_id,aid) = (select umo_scene_id,aid from umo where umo_id = v_umo) and object_class = 'DIRECTORY';
    delete from umo where umo_id = v_umo;
    if objtype = 'BACKGROUND' then update customer_account set background_img = null where aid = acid; end if;
    commit;
  end if;

  initialised := FALSE;
  if substr(retval7,1,1) in ('K','R')
   then
    if substr(retval7,1,1) = 'R' -- Replace Photo. Use the original location to determine if the file exists.
     then
       v_umo := NULL;
       open c2(acid,retval6,objtype);
       fetch c2 into v_umo;
       close c2;
    end if;
    if substr(retval7,1,1) = 'R' and v_umo is not null -- Either replace the original photo or load in a new pne
     then
      retval4 := scene_title( to_number(retval8),v_extras.orderby_scene );
      v_extras.title := retval4;
     else
      retval4 := scene_title( to_number(retval8),v_extras.orderby_scene );
      v_extras.title := retval4;
      if not find_parameter( 'FTPLOC', parm1, parm2, retval ) then retval := null; end if;
      def_ftp_loc := retval;
      if def_ftp_loc is not null then def_ftp := glbx.extract_fname(retval6,'EXTENSION',1000); end if;

      -- Create new UMO Record
      init( acid, objtype, v_umo );
      initialised := TRUE;

      update umo um
       set
        parent_id = to_number( retval5 ),
        umo_scene_id= retval8,
        umo_owner = umo_ownr,
        ftp_location = def_ftp,
        ftp_virtual_dir = def_ftp_loc,
        sessid = session_id
      where
       umo_id = v_umo;
      if objtype = 'PHOTO'  then update umo um set photo_original_loc = retval6 where umo_id = v_umo; end if;
      if objtype = 'AUDIO'  then update umo um set audio_original_loc = retval6 where umo_id = v_umo; end if;
      if objtype = 'VIDEO'  then update umo um set video_original_loc = retval6 where umo_id = v_umo; end if;
      if objtype = 'DOCUMENT'  then update umo um set document_original_loc = retval6 where umo_id = v_umo; end if;
      if objtype = 'BLUEPRINT'  then update umo um set um.blueprint_obj.blueprint_original_loc = retval6 where umo_id = v_umo; end if;
      -- For Thumbnail Directory Recreation. Used to indicate it needs to be updated.
      update umo set attribute2 = 'F' where (umo_scene_id,aid) = (select umo_scene_id,aid from umo where umo_id = v_umo ) and object_class = 'DIRECTORY';
     end if;

   else -- LOAD AGAIN (Not Used)
    if not find_parameter( 'UMO_ID', parm1, parm2, retval ) then return; end if;
    v_umo := to_number( retval );
    if objtype <> 'AUDIO' then update umo set audio_original_loc = nvl(audio_original_loc,retval6) where umo_id = v_umo; end if;
  end if;
  new_umo_id(1) := v_umo;

  if not find_parameter( 'CONVERT_TO', parm1, parm2, retval ) then retval := NULL; end if;
  retval8 := retval;
  if not find_parameter( 'COMPRESSION', parm1, parm2, retval ) then retval := NULL; end if;
  retval9 := conv_compr(retval);
  convstr := photo_convert( retval8, retval9 );

  if retval3 = 'UPLOAD'
   then
     step := 'UPLOAD';
     if not find_parameter( 'OWS_NAME', parm1, parm2, retval ) then return; end if;
     ows_name := retval;
     if upper(glbx.extract_fname(ows_name,'SUFFIX')) in ('ZIP','GZ','Z')
      then
       -- Uploaded file is a zip file. Will unpack it, and then call load_uma to load it
       delete from umo where umo_id = v_umo;
       upload_zip( surl, ows_name, parm1, parm2, retval, new_umo_id );
       return;
     end if;

     if not find_parameter( 'RELOAD_PHOTO', parm1, parm2, retval ) then retval := 'X'; end if;
     reload_photo := retval;
     if find_parameter( 'PHOTOGRAPHER_QUOTA', parm1, parm2, retval )
      then
         open c4a( ows_name );
         fetch c4a into c4rec;
         close c4a;
         if c4rec.length > to_number(retval)
          then
           delete_websys( ows_name, 'NOCOMMIT' );
           if reload_photo = 'X' then delete from umo where umo_id = v_umo; end if;
           retval := LNG2.UMP_TXT_024 || retval || LNG2.UMP_TXT_025;
           commit;
           return;
         end if;
     end if;
     open c6(ows_name);
     fetch c6 into work_img;
     close c6;

     -- Uploaded object is now stored in work_img
     obj_length := dbms_lob.getlength(work_img);
     --insert into temp values(obj_length); commit;
     if umo_ownr = 'PHOTOGRAPHER'
      then
       if not find_parameter( 'PHGR_ID', parm1, parm2, retval ) then return; end if;
       owner_id := to_number(retval);
      else
       owner_id := acid;
     end if;
     --insert into temp values('Step2'); commit;

     if not check_quota( surl, umo_ownr, owner_id, acid, obj_length, byp_quota, category, retval)
      then
       -- cleanup if quota exceeded
       rollback;
       if reload_photo = 'X' then delete from umo where umo_id = v_umo; end if;
       delete_websys( ows_name );
       retval := nvl(retval,'QUOTA EXCEEDED');
       commit;
       return;
     end if;

     open c1( v_umo );
     fetch c1 into umo_rec;
     close c1;
     --insert into temp values('Step3:' || reload_photo || '-' || objtype);
     if objtype in ('PHOTO','GALLERY','MANUFACTURER')
      then
       if reload_photo in ('T','X')
        then
         dbms_lob.copy(umo_rec.photo_master.source.localdata, work_img, obj_length );
         begin
          umo_rec.photo_master.setproperties;
         exception
          when others
           then
            if image_magick_load(surl,umo_rec, parm1, parm2)
             then
              commit;
              open c1(umo_rec.umo_id);
              fetch c1 into umo_rec;
              close c1;
             else
              retval := check_image(umo_rec.photo_master,sqlerrm,sqlcode);
              new_umo_id(1) := null;
              rollback;
              if reload_photo = 'X' then delete from umo where umo_id = v_umo; end if;
              commit;
             return;
            end if;
         end;
        else
         dbms_lob.copy(umo_rec.photo_original.source.localdata, work_img, obj_length );
         begin umo_rec.photo_original.setproperties; exception
          when others then update umo um set um.photo_original.contentlength = obj_length where umo_id = v_umo; end; -- Need to put some more intelligence here into guessing what the format could be
         update umo set photo_original = umo_rec.photo_original where umo_id = v_umo;
       end if;

       if store_orig = 'TRUE' and reload_photo in ('T','X')
        then
          umo_rec.photo_master.copy(umo_rec.photo_original);
          update umo set photo_original = umo_rec.photo_original where umo_id = v_umo;
       end if;

       if (nocompressif is not null) and (obj_length < (nocompressif * 1024)) and reload_photo in ('T','X')
        then
         convstr := photo_convert( retval8, LNG.PHG_ALT_427,umo_rec.photo_master.compressionformat );
        else
         convstr := photo_convert( retval8, retval9, umo_rec.photo_master.compressionformat );
       end if;

     --insert into temp values('Step5:' || retval9 || '-' || convstr);
      -- Check if the Image is Corrupted. If it is, try and fix it.
      begin
         if retval9 in ('S',LNG.PHG_ALT_427) and reload_photo in ('T','X') -- 'Do not Compress'
          then
           if umo_rec.photo_master.mimetype not in ('image/jpeg','image/pjpeg','image/gif')
            then
              umo_rec.photo_master.process(convstr);
           end if;
          else
           if convstr is not null and reload_photo in ('T','X')
            then
             umo_rec.photo_master.process(convstr);
          end if;
        end if;
      exception
       when others
        then
          if image_magick_load(surl,umo_rec,parm1,parm2)
           then
             commit;
             open c1(umo_rec.umo_id);
             fetch c1 into umo_rec;
             close c1;
            else
             retval := check_image(umo_rec.photo_master,sqlerrm,sqlcode);
             new_umo_id(1) := null;
             rollback;
             if reload_photo = 'X' then delete from umo where umo_id = v_umo;  end if;
             commit;
             return;
           end if;
      end;

     elsif objtype in ('ADVERT','BACKGROUND','ICON','WATERMARK','SLIDE')
      then
       dbms_lob.copy(umo_rec.photo_master.source.localdata, work_img, obj_length );
       umo_rec.photo_master.setproperties;
     elsif objtype = 'AUDIO'
      then
       dbms_lob.copy(umo_rec.audio_original.source.localdata, work_img, obj_length );
       myaudio.audio_api( origfile=>ows_name, filetype=>format_type, mimetype=>mime_type );
       umo_rec.audio_original.setFormat(format_type);
       umo_rec.audio_original.setMimeType(mime_type);
       umo_rec.audio_original.description := obj_length;
       audio_index(v_umo, user, 'BROWSER', 'INSERT');
     elsif objtype = 'VIDEO'
      then
       dbms_lob.copy(umo_rec.video_original.source.localdata, work_img, obj_length );
       -- umo_rec.video_original.setproperties( ctx );
       update umo um set um.video_original.description = to_char(obj_length),um.video_original_loc = ows_name where umo_id = v_umo;
       video_index(v_umo, user, 'BROWSER', 'INSERT');
     elsif objtype = 'RELATIONAL'
      then
       relational_index(v_umo, user, 'BROWSER', 'INSERT');
     elsif objtype = 'BLUEPRINT'
      then
       dbms_lob.copy(umo_rec.blueprint_obj.localdata, work_img, obj_length );
       update umo um set um.blueprint_obj.blueprint_length = obj_length,um.blueprint_obj.blueprint_original_loc = photo_original_loc where umo_id = v_umo;
       commit;
       blueprint_index(v_umo, user, 'BROWSER', 'INSERT');
     elsif objtype = 'DOCUMENT'
      then
       dbms_lob.copy(umo_rec.doc_body, work_img, obj_length );
       update umo set doc_length = obj_length,document_original_loc = nvl(photo_original_loc,document_original_loc) where umo_id = v_umo;
       commit;
       document_index(v_umo, user, 'BROWSER', 'INSERT');
     end if;
     delete_websys( ows_name, 'NOCOMMIT' );
     insert into log_photo_mod(aid,phid,date_modified,mod_type,extra_det) values (acid,owner_id,sysdate,'UPLOAD',retval7);

  elsif (retval3 = 'FILE')
   then
    step := 'File';
    if not find_parameter( 'LOAD_DIRECTORY', parm1, parm2, retval ) then return; end if;
    retval1 := replace(retval,'''','''''');
    if not find_parameter( 'FILE_NAME', parm1, parm2, retval ) then return; end if;
    retval2 := retval;
    set_timestamp( v_umo, 'Recreate Directory' );
    execute immediate 'create or replace directory ' || GLBX.GLOBAL_DIR || user || to_char(v_umo) || ' as ''' || retval1 || '''';
    set_timestamp( v_umo, 'Load Image Object' );
    open c1( v_umo );
    fetch c1 into umo_rec;
    close c1;
    delete_obj := FALSE;

    if objtype in ('PHOTO','GALLERY','MANUFACTURER')
     then
      set_timestamp( v_umo, 'umo_rec.photo_master.setSource' );
      umo_rec.photo_master.setSource('FILE', GLBX.GLOBAL_DIR || user || to_char(v_umo), retval2);
      set_timestamp( v_umo, 'umo_rec.photo_master.import(ctx)' );
      begin umo_rec.photo_master.import(ctx);
       exception when others
        then
         if image_magick_load(surl,umo_rec,parm1,parm2)
          then
           commit;
           open c1(umo_rec.umo_id);
           fetch c1 into umo_rec;
           close c1;
          else
           retval := LNG2.UMP_TXT_016 || ':' || GLBX.GLOBAL_DIR || user || to_char(v_umo) || ':' || retval1 || '-' || retval2 || ' ' || sqlerrm;
           delete from umo where umo_id = v_umo;
           commit;
           return;
         end if;
       end;
      if store_orig = 'TRUE'
        then
          umo_rec.photo_master.copy(umo_rec.photo_original);
	  update umo set photo_original = umo_rec.photo_original where umo_id = v_umo;
      end if;
      before_size := umo_rec.photo_master.contentlength;

      if retval9 in ('S',LNG.PHG_ALT_427) -- Do not Compress
       then
         if umo_rec.photo_master.mimetype not in ('image/jpeg','image/pjpeg','image/gif')
          then
            umo_rec.photo_master.process(convstr);
            -- If the after size is way bigger than the before size then try it as a GIF
            if (before_size * 1.4) < umo_rec.photo_master.contentlength
             then
              -- backout
              umo_rec.photo_master.import(ctx);
              -- try as GIF
              umo_rec.photo_master.process('fileformat=GIFF compressionFormat=GIFLZW ');
            end if;
         end if;

       else
         if (nocompressif is not null) and (nvl(dbms_lob.getlength(umo_rec.photo_master.source.localdata),0) < (nocompressif * 1024))
          then
           convstr := photo_convert( retval8, LNG.PHG_ALT_427,umo_rec.photo_master.compressionformat );
          else
           convstr := photo_convert( retval8, retval9,umo_rec.photo_master.compressionformat );
         end if;
         set_timestamp( v_umo, 'Start : umo_rec.photo_master.process(' || convstr || ') maxScale=(' );
         begin
          if convstr is not null then umo_rec.photo_master.process(convstr || ' maxScale=(' || to_char(umo_rec.photo_master.width) || ' ' || to_char(umo_rec.photo_master.height) || ')'); end if;
         exception when others
          then
          --rollback;
          umo_rec.photo_master.import(ctx);
          --glbx.dbg( convstr || ' maxScale=(' || to_char(umo_rec.photo_master.width) || ' ' || to_char(umo_rec.photo_master.height) || ')' );
           if image_magick_load(surl,umo_rec,parm1,parm2)
            then
             commit;
             open c1(umo_rec.umo_id);
             fetch c1 into umo_rec;
             close c1;
            else
             retval := LNG2.UMP_TXT_016 || ':' || GLBX.GLOBAL_DIR || user || to_char(v_umo) || ':' || retval1 || '-' || retval2 || ' ' || sqlerrm;
             delete from umo where umo_id = v_umo;
             commit;
             return;
           end if;
         end;
         set_timestamp( v_umo, 'Finish : umo_rec.photo_master.process(' || convstr || ')' );
      end if;
      obj_length := umo_rec.photo_master.contentlength;
      if umo_rec.photo_master.contentlength = 0 then delete_obj := TRUE; end if;
      if retval9 = 'S' -- Size Web Quality to 80k
       then
        -- Only really look at it if it is more than 90000 bytes, trying to size from 90k to 80k is risky
        if obj_length > 90000
         then
          resize_master( umo_rec.photo_master, ctx );
        end if;

      end if;

    elsif objtype in ('ADVERT','BACKGROUND','ICON','WATERMARK','SLIDE')
     then
      umo_rec.photo_master.setSource('FILE', GLBX.GLOBAL_DIR || user || to_char(v_umo), retval2);
      begin umo_rec.photo_master.import(ctx); exception when others then retval := LNG2.UMP_TXT_016 || ':' || GLBX.GLOBAL_DIR || user || to_char(v_umo) || ':' || retval2 || ' ' || sqlerrm; delete from umo where umo_id = v_umo; commit; return; end;
      if convstr is not null then umo_rec.photo_master.process(convstr); end if;

    elsif objtype = 'AUDIO'
     then
       -- Review and use Audio Support Commands
       umo_rec.audio_original.setSource('FILE', GLBX.GLOBAL_DIR || user || to_char(v_umo), retval2);
       myaudio.audio_api( origfile=>retval2, filetype=>format_type, mimetype=>mime_type );
       umo_rec.audio_original.setFormat(format_type);
       umo_rec.audio_original.setMimeType(mime_type);
       begin umo_rec.audio_original.import(ctx);exception when others then retval := LNG2.UMP_TXT_016 || ':' || GLBX.GLOBAL_DIR || user || to_char(v_umo) || ':' || retval2 || ' ' || sqlerrm; delete from umo where umo_id = v_umo; commit; return; end;
       obj_length := dbms_lob.getlength(umo_rec.audio_original.source.localdata);
       umo_rec.audio_original.description := obj_length;
       if obj_length = 0 then delete_obj := TRUE; end if;
       if retval7 = 'LOAD_AGAIN'
        then
         audio_index(v_umo, user, 'BATCH', 'UPDATE');
        else
         audio_index(v_umo, user, 'BATCH', 'INSERT');
       end if;

    elsif objtype = 'VIDEO'
     then
      document_bfile := bfilename( GLBX.GLOBAL_DIR || user || to_char(v_umo), retval2 );
      dbms_lob.fileopen( document_bfile, dbms_lob.file_readonly );
      obj_length := dbms_lob.getlength(document_bfile);
      dbms_lob.loadfromfile( umo_rec.video_original.source.localdata, document_bfile, obj_length );
      dbms_lob.fileclose(document_bfile);
      update umo um set um.video_original.description = to_char(obj_length),um.video_original_loc = photo_original_loc where umo_id = v_umo;
      commit;

      if obj_length = 0 then delete_obj := TRUE; end if;
      if retval7 = 'LOAD_AGAIN'
       then
        video_index(v_umo, user, 'BATCH', 'UPDATE');
       else
        video_index(v_umo, user, 'BATCH', 'INSERT');
      end if;

    elsif objtype = 'RELATIONAL'
     then
       if retval7 = 'LOAD_AGAIN'
        then
         relational_index(v_umo, user, 'BATCH', 'UPDATE');
        else
         relational_index(v_umo, user, 'BATCH', 'INSERT');
       end if;

    elsif objtype = 'BLUEPRINT'
     then
      document_bfile := bfilename( GLBX.GLOBAL_DIR || user || to_char(v_umo), retval2 );
      dbms_lob.fileopen( document_bfile, dbms_lob.file_readonly );
      obj_length := dbms_lob.getlength(document_bfile);
      dbms_lob.loadfromfile( umo_rec.blueprint_obj.localdata, document_bfile, obj_length );
      dbms_lob.fileclose(document_bfile);
      update umo um set um.blueprint_obj.blueprint_length = obj_length,um.blueprint_obj.blueprint_original_loc = photo_original_loc where umo_id = v_umo;
      commit;
       if retval7 = 'LOAD_AGAIN'
        then
         blueprint_index(v_umo, user, 'BATCH', 'UPDATE');
        else
         blueprint_index(v_umo, user, 'BATCH', 'INSERT');
       end if;

    elsif objtype = 'DOCUMENT'
     then
      document_bfile := bfilename( GLBX.GLOBAL_DIR || user || to_char(v_umo), retval2 );
      dbms_lob.fileopen( document_bfile, dbms_lob.file_readonly );
      obj_length := dbms_lob.getlength(document_bfile);
      dbms_lob.loadfromfile( umo_rec.doc_body, document_bfile, obj_length );
      dbms_lob.fileclose(document_bfile);
      update umo set doc_length = obj_length,document_original_loc = nvl(photo_original_loc,document_original_loc) where umo_id = v_umo;
      commit;
      if retval7 = 'LOAD_AGAIN'
       then
        document_index(v_umo, user, 'BATCH', 'UPDATE');
       else
        document_index(v_umo, user, 'BATCH', 'INSERT');
      end if;
    end if;

    if delete_obj then delete from umo where umo_id = v_umo; commit; retval := LNG2.UMP_TXT_017 || ': ' || retval1 || '-' || retval2; return; end if;
    if umo_ownr = 'PHOTOGRAPHER'
     then
      if not find_parameter( 'PHGR_ID', parm1, parm2, retval ) then return; end if;
      owner_id := to_number(retval);
     else
      owner_id := acid;
    end if;
    if not check_quota( surl,umo_ownr, owner_id, acid, obj_length, byp_quota, category, retval)
     then
     -- cleanup if quota exceeded
     rollback;
     delete from umo where umo_id = v_umo;
     retval := nvl(retval,'QUOTA EXCEEDED');
     commit;
     return;
   end if;
   insert into log_photo_mod(aid,phid,date_modified,mod_type,extra_det) values (acid,owner_id,sysdate,'FILE',retval7);
  end if;

  set_timestamp( v_umo, 'Start : Attach Metadata' );
  if objtype in ('PHOTO','GALLERY','MANUFACTURER','ADVERT','BACKGROUND','ICON','WATERMARK','SLIDE')
   then
    -- Store Photo as a Backup
    step := 'Backup';
    if not find_parameter( 'BACKUP_PHOTO', parm1, parm2, retval ) then retval := 'FALSE'; end if;
    retval1 := retval;
    if retval1 = 'TRUE'
     then
      umo_rec.photo_master.copy(umo_rec.photo_backup);
      update umo set photo_backup = umo_rec.photo_backup where umo_id = v_umo;
    end if;

    -- Resize if photo is too large
    if not find_parameter( 'SCALE_TO_SIZE', parm1, parm2, retval ) then retval := NULL; end if;
    retval1 := retval;
    if not find_parameter( 'SCALE_THRESHOLD', parm1, parm2, retval ) then retval := NULL; end if;
    retval2 := retval;
    convstr := calculate_resize( umo_rec.photo_master.width, umo_rec.photo_master.height, umo_rec.photo_master.contentlength, to_number(retval1), to_number(retval2));
    if convstr is not null
     then
      umo_rec.photo_master.process(convstr);
      insert into log_photo_mod(aid,phid,date_modified,mod_type,extra_det) values (acid,v_umo,sysdate,'SCALE',convstr );
    end if;

    -- Create Thumbnail
    if not find_parameter( 'CREATE_THUMBNAIL', parm1, parm2, retval ) then retval := 'FALSE'; end if;
    retval1 := retval;
    if retval1 = 'TRUE'
     then
      set_timestamp( v_umo, 'Start : Create Thumbnail' );
      if not find_parameter( 'THUMBNAIL_WIDTH', parm1, parm2, retval ) then retval := null; end if;
      if trim(retval) is null then retval := nvl(glbx.userpref( phgid, acid, 'THUMBNAIL_WIDTH'), '100'); end if;
      retval1 := retval;
      umo_rec.photo_master.copy(umo_rec.photo_thumbnail);
      convstr := 'fileformat=JFIF compressionFormat=JPEG compressionQuality=MAXINTEGRITY'; -- Thumbnails are alway created as JPEG
      -- Resize Option
      open c5(acid);
      fetch c5 into phgid;
      close c5;
      if not find_parameter( 'THUMBNAIL_QUALITY', parm1, parm2, retval )
       then
        thb_qual := to_number( nvl(glbx.userpref( phgid, acid, 'SUPER_THB'), '1') );
       else
        thb_qual := to_number( retval );
      end if;
      begin
       umo_rec.photo_thumbnail.process(convstr || ' maxScale=(' || to_char(to_number(retval1*thb_qual)) || ' ' || to_char(to_number(retval1*thb_qual)) || ')');
       umo_rec.photo_thumbnail.width := umo_rec.photo_thumbnail.width / thb_qual;
       umo_rec.photo_thumbnail.height := umo_rec.photo_thumbnail.height / thb_qual;
      exception
       when others then
        if image_magick_load(surl,umo_rec,parm1,parm2)
         then
           commit;
             open c1(umo_rec.umo_id);
             fetch c1 into umo_rec;
             close c1;
         else
           retval := check_image(umo_rec.photo_master,sqlerrm,sqlcode);
           new_umo_id(1) := null;
           rollback;
           if reload_photo = 'X' then delete from umo where umo_id = v_umo;  end if;
           commit;
           --if retval3 = 'FILE' and v_umo is not null then begin execute immediate 'drop directory ' || GLBX.GLOBAL_DIR || user || to_char(v_umo); exception when others then null; end;  end if;
           return;
       end if;
      end;
      update umo set photo_thumbnail = umo_rec.photo_thumbnail where umo_id = v_umo;
      set_timestamp( v_umo, 'End : Create Thumbnail' );
    end if;
  end if;

  -- Store Original
  step := 'Store Original';
  if objtype in ('PHOTO','GALLERY','MANUFACTURER','ADVERT','BACKGROUND','ICON','WATERMARK','SLIDE')
   then
    update umo set photo_master = umo_rec.photo_master where umo_id = v_umo;
  elsif objtype = 'AUDIO'
   then
    null;
  elsif objtype = 'VIDEO'
   then
    null;
  elsif objtype = 'RELATIONAL'
   then
    null;
  elsif objtype = 'BLUEPRINT'
   then
    null;
  elsif objtype = 'DOCUMENT'
   then
    null;
  end if;

  -- If Replace, then keep existing data (only changing image). Exit.
  if (substr(retval7,1,1) = 'R' or retval7 = 'LOAD AGAIN') and not initialised
   then
     commit;
     retval := NULL;
     return;
     --if retval3 = 'FILE' and v_umo is not null then begin execute immediate 'drop directory ' || GLBX.GLOBAL_DIR || user || to_char(v_umo); exception when others then null; end;  end if;
  end if;

  -- Update attributes and index
  step := 'Update UMO Attributes';
  --
  -- Fix required for non photo's as film name not being set as its not a UMO attribute
  --
  if objtype in ('AUDIO','VIDEO','DOCUMENT','RELATIONAL','BLUEPRINT')
   then
    if not find_parameter( 'FILM_NAME', parm1, parm2, retval ) then retval := NULL; end if;
    retval1 := glbx.censor(retval);
    if retval1 is not null
     then
      v_extras.film_name := substr(retval1,1,100);
      v_extras.photo_name := substr(retval1,1,100);
    end if;
  end if;

  for crec in cattr( objtype, acid ) loop
   modify_entry( v_umo, crec.attribute_id, null, acid, 1, 'DELETE', objtype, extract_numbers=>pfx.search_number_enable);
   delete from umo_attribute where umo_id = v_umo and attribute_id = crec.attribute_id;
   -- modify entry
   if not find_parameter( crec.sub_category, parm1, parm2, retval ) then retval := NULL; end if;
   retval1 := glbx.censor(retval);
   insert into umo_attribute(umo_id,attribute_id,date_made,position_id,value) values (v_umo,crec.attribute_id,sysdate,1,retval1);
   modify_entry( v_umo, crec.attribute_id, retval1, acid, 1, 'INSERT', objtype, extract_numbers=>pfx.search_number_enable);
   -- Check repeated fields

   if crec.sub_category = 'NEG_NO' then begin v_extras.orderby_nmb := to_number(retval1); exception when others then v_extras.orderby_nmb := 1; end;
   elsif crec.sub_category = 'FILM_NAME' then v_extras.film_name := substr(retval1,1,100);
   elsif crec.sub_category = 'NAME' then v_extras.photo_name := substr(retval1,1,100);
   elsif crec.sub_category = 'QUALITY' then v_extras.quality := retval1;
   elsif crec.sub_category = 'PHOTOGRAPHER' then v_extras.enabled_phg := retval1; v_extras.enabled_cus := retval1;
   elsif crec.sub_category = 'BRIDAL' then v_extras.enabled_cus := retval1;
   elsif crec.sub_category = 'FILM_TYPE' then ftype := retval1;
   elsif crec.sub_category = 'ROLL_ID' then vrollid := retval1;
   elsif crec.sub_category = 'FILM_SIZE' then vfsize := retval1;
   elsif crec.sub_category = 'SORT_PRIORITY' then srt := retval1;
   end if;
  end loop;

  update umo set extras = v_extras where umo_id = v_umo;
  if ftype is not null then update umo set extra_film_colour = ftype where umo_id = v_umo; end if; -- As I couldn't add a new field to a type, had to put this fix in when film_colour was repeated
  if vrollid is not null then update umo set extra_roll_id = vrollid where umo_id = v_umo; end if; -- As I couldn't add a new field to a type, had to put this fix in when film_colour was repeated
  if vfsize is not null then update umo set extra_film_size = vfsize where umo_id = v_umo; end if; -- As I couldn't add a new field to a type, had to put this fix in when film_colour was repeated
  if srt is not null then update umo set sort_priority = srt where umo_id = v_umo; end if;
  set_timestamp( v_umo, 'End: Attache Metadata' );
  commit;
  retval := NULL;
  --if retval3 = 'FILE' and v_umo is not null then begin execute immediate 'drop directory ' || GLBX.GLOBAL_DIR || user || to_char(v_umo); exception when others then null; end;  end if;

 exception when others then
  if image_magick_load(surl,umo_rec,parm1,parm2)
   then
    commit;
   else
    retval := step || '-' || check_image(umo_rec.photo_master,sqlerrm,sqlcode);
    new_umo_id(1) := null;
    rollback;
    if reload_photo = 'X' then delete from umo where umo_id = v_umo;  end if;
    commit;
  end if;
  if v_umo is not null
   then
    --begin execute immediate 'drop directory ' || GLBX.GLOBAL_DIR || user || to_char(v_umo); exception when others then null; end;
    null;
  end if;

 end load_uma;

 procedure modify_uma( surl varchar2,parm1 in UMP.PARAMETERS, parm2 in UMP.PARAMETERS, retval out varchar2 )
 as

  TYPE raw_arr 	IS TABLE OF raw(32767) INDEX BY BINARY_INTEGER;

  cursor c1(v_umo integer) is select ph.photo_master,ph.photo_thumbnail,ph.photo_backup from umo ph where umo_id = v_umo for update nowait;
  cursor c2(v_umo integer) is select ph.extras from umo ph where umo_id = v_umo for update nowait;
  cursor c3(acid integer) is select pid from customer_account where aid = acid;
  --cursor cattr(objtype varchar2) is select * from umo_attributes where umo_type = objtype;
  cursor cattr(objtype varchar2, acid integer) is
   select *
   from umo_attributes
   where umo_type = objtype and
         ((business_feature is null) or
          (business_feature is not null and business_feature = (select theme_type from customer_account ca where ca.aid = acid))
         );
  cursor c4 is select attribute_id from umo_attributes where umo_type = 'PHOTO' and sub_category = 'NAME';
  cursor c_check(v_umo integer, attrib integer, retval1 varchar2, posid integer) is
     select 'x'
     from umo_attribute
     where attribute_id = attrib and
           umo_id = v_umo and
           ((posid is not null and position_id = posid) or (posid is null)) and
           value = retval1;
  cursor c_max(v_umo integer, attrib integer) is
     select max(position_id) + 1 tot
     from umo_attribute
     where attribute_id = attrib and
           umo_id = v_umo;

  imagex	ORDSYS.ORDImage;
  imgx		blob;
  imaget	ORDSYS.ORDImage;
  imageb	ORDSYS.ORDImage;
  imgy		blob;
  imagez	ORDSYS.ORDImage;
  imagez1	ORDSYS.ORDImage;
  imgz		blob;
  v_extras	REPEATED_FIELDS;
  thb_qual	number;
  v_umo		integer;
  acid		integer;
  x		integer;
  m3		integer;
  m		integer;
  n		integer;
  rgb_1		integer;
  rgb_2		integer;
  rgb_3		integer;
  n_rgb_1	integer;
  n_rgb_2	integer;
  n_rgb_3	integer;
  m_rgb_1	integer;
  m_rgb_2	integer;
  m_rgb_3	integer;
  new_offset	integer;
  wait_seconds	integer;
  ph_name_id	integer;
  phgid		integer;
  srt		integer;
  pos		integer;
  status        number;
  result        number;
  v_imgchunk 	binary_integer;
  retsess	varchar2(100);
  objtype	varchar2(100);
  keep_status	varchar2(100);
  merge		varchar2(100);
  rotate	varchar2(100);
  crop		varchar2(100);
  resize_width	varchar2(100);
  resize_height	varchar2(100);
  create_tnail	varchar2(100);
  convert_to	varchar2(100);
  compression	varchar2(100);
  retval1	varchar2(4000);
  retval2	varchar2(4000);
  retval3	varchar2(4000);
  retval4	varchar2(4000);
  convstr	varchar2(100);
  grayscale	varchar2(100);
  backup_photo	varchar2(100);
  restore_photo	varchar2(100);
  attribid	varchar2(2000);
  n_buffer	raw(32767);
  r_buffer 	raw(32767);
  v_buffer	raw(32767);
  rawarr	raw_arr;
  rawarr_z	raw_arr;
  dm		integer;
  step		varchar2(100);
  pfx		theme%ROWTYPE;

 begin

  if not find_parameter( 'UMO_ID', parm1, parm2, retval ) then return; end if;
  v_umo := to_number(retval);
  if not find_parameter( 'AID', parm1, parm2, retval ) then return; end if;
  acid := to_number(retval);
  if not find_parameter( 'OBJECT_TYPE', parm1, parm2, retval ) then return; end if;
  objtype := retval;
  if not find_parameter( 'KEEP_STATUS', parm1, parm2, retval ) then retval := 'KEEP'; end if;
  keep_status := retval;

  pfx := glbx.get_thm( acid );

  if keep_status = 'DELETE'
   then
    delete from log_photo_mod where phid = v_umo;
    delete from umo_index where umo_id = v_umo;
    delete from umo_attribute where umo_id = v_umo;
    delete from umo_link um where umo_id = v_umo;
    delete from umo_link um where to_umo_id = v_umo;
    if objtype = 'AUDIO'
     then
     ump.audio_index(v_umo=>v_umo,schemaname=>user,howloaded=>NULL,action=>'DELETE');
    elsif objtype = 'VIDEO'
     then
     ump.video_index(v_umo=>v_umo,schemaname=>user,howloaded=>NULL,action=>'DELETE');
    elsif objtype = 'RELATIONAL'
     then
     ump.relational_index(v_umo=>v_umo,schemaname=>user,howloaded=>NULL,action=>'DELETE');
    elsif objtype = 'BLUEPRINT'
     then
     ump.blueprint_index(v_umo=>v_umo,schemaname=>user,howloaded=>NULL,action=>'DELETE');
    elsif objtype = 'DOCUMENT'
     then
     ump.document_index(v_umo=>v_umo,schemaname=>user,howloaded=>NULL,action=>'DELETE');
    end if;
    delete from umo where umo_id = v_umo;
    if not find_parameter( 'OWS_NAME', parm1, parm2, retval ) then retval := NULL; end if;
    retval1 := retval;
    if retval1 is not null then delete_websys(retval1); end if;
    commit;
    return;
  end if;
  if not find_parameter( 'MERGE', parm1, parm2, retval ) then retval := NULL; end if;
  merge := retval;
  if not find_parameter( 'ROTATE', parm1, parm2, retval ) then retval := NULL; end if;
  rotate := retval;
  if not find_parameter( 'CROP', parm1, parm2, retval ) then retval := NULL; end if;
  crop := retval;
  if not find_parameter( 'RESIZE_WIDTH', parm1, parm2, retval ) then retval := NULL; end if;
  resize_width := retval;
  if not find_parameter( 'RESIZE_HEIGHT', parm1, parm2, retval ) then retval := NULL; end if;
  resize_height := retval;
  if not find_parameter( 'CREATE_THUMBNAIL', parm1, parm2, retval ) then retval := NULL; end if;
  create_tnail := retval;
  if not find_parameter( 'CONVERT_TO', parm1, parm2, retval ) then retval := NULL; end if;
  convert_to := retval;
  if not find_parameter( 'COMPRESSION', parm1, parm2, retval ) then retval := NULL; end if;
  compression := retval;
  if not find_parameter( 'GRAYSCALE', parm1, parm2, retval ) then retval := NULL; end if;
  grayscale := retval;
  if not find_parameter( 'BACKUP_PHOTO', parm1, parm2, retval ) then retval := 'FALSE'; end if;
  backup_photo := retval;
  if not find_parameter( 'RESTORE_PHOTO', parm1, parm2, retval ) then retval := 'FALSE'; end if;
  restore_photo := retval;

  if (objtype in ('PHOTO','GALLERY','MANUFACTURER')) and
     (restore_photo = 'TRUE')
    then
    open c1(v_umo);
    fetch c1 into imagex,imaget,imageb;
    if c1%NOTFOUND
     then
      retval := v_umo || ' ' || LNG.GLB_TXT_122;
      close c1;
      return;
    end if;
    close c1;
    -- Only restore the photo if a backup exists
    if nvl(imageb.contentlength,0) > 0
     then
      imageb.copy(imagex);
      update umo set photo_master = imagex,version = nvl(version,1) + 1 where umo_id = v_umo;
      insert into log_photo_mod(aid,phid,date_modified,mod_type,extra_det) values
       (acid,v_umo,sysdate,'RESTORE',null);
      commit;
      create_tnail := 'TRUE';
    end if;
  end if;

  if (objtype in ('PHOTO','GALLERY','MANUFACTURER')) and
     (rotate is not null or merge is not null or grayscale is not null or crop is not null or resize_width is not null or resize_height is not null or
      nvl(create_tnail,'FALSE') = 'TRUE' or convert_to is not null or compression is not null or backup_photo = 'TRUE')
   then
      open c1(v_umo);
      fetch c1 into imagex,imaget,imageb;
      if c1%NOTFOUND
       then
        retval := v_umo || ' record in the table not found';
        close c1;
        return;
      end if;
      close c1;

    if (backup_photo = 'TRUE') and
       (rotate is not null or merge is not null or grayscale is not null or crop is not null or resize_width is not null or resize_height is not null or
        nvl(create_tnail,'FALSE') = 'TRUE' or convert_to is not null or compression is not null)
     then
      -- Only back it up, if it hasn't already been backed up
      -- If there is an error its likely to be because the backup blob has not been initialised (left over from old versions)
      if (nvl(dbms_lob.getlength(imageb.source.localdata),0) = 0)
       then
        begin
         imagex.copy(imageb);
        exception
         when others then
          update umo um set um.photo_backup = ORDSYS.ORDImage(ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,NULL,NULL,NULL,NULL,NULL) where umo_id = v_umo;
          commit;
          open c1(v_umo);
          fetch c1 into imagex,imaget,imageb;
          close c1;
          imagex.copy(imageb);
        end;
        update umo set photo_backup = imageb,version = nvl(version,1) + 1 where umo_id = v_umo;
      end if;
    end if;

  end if;

  if rotate is not null
   then
    if image_magick_rotate( surl, v_umo, acid, rotate, parm1, parm2 )
     then
       commit;
     else
      /*
      if not find_parameter( 'THUMBNAIL_WIDTH', parm1, parm2, retval ) then retval := '100'; end if;
      retval1 := retval;
      if not find_parameter( 'WAIT_SECONDS', parm1, parm2, retval ) then retval := '30'; end if;
      wait_seconds := to_number(retval);
      -- Rotate Photo
      select s_umo_sess.nextval into retsess from dual;
      -- retsess := dbms_pipe.unique_session_name;
      dm := dbms_pipe.create_pipe('CPROG',8192,FALSE);
      dbms_pipe.pack_message(retsess);
      dbms_pipe.pack_message(v_umo);
      dbms_pipe.pack_message(acid);
      dbms_pipe.pack_message(user); -- Schema Name
      dbms_pipe.pack_message(to_number(retval1));
      dbms_pipe.pack_message('ROTATE');
      dbms_pipe.pack_message(rotate);
      status := dbms_pipe.send_message('CPROG',maxpipesize=>32767);
      -- create_tnail := 'FALSE';
      commit;
      status := dbms_pipe.receive_message(retsess,wait_seconds);
      dbms_pipe.unpack_message(result);
      if result > 0
       then
        retval := LNG2.UMP_TXT_020 || ':' || c_err(to_number(result));
        return;
      end if;
      */
     null;
    end if;
      -- Photo has rotated, reload it in
    open c1(v_umo);
    fetch c1 into imagex,imaget,imageb;
    if c1%NOTFOUND
     then
      retval := v_umo || ' record in the table not found';
      close c1;
      return;
    end if;
    close c1;
    create_tnail := 'FALSE';
  end if;

  if merge is not null
   then
    if image_magick_watermark( surl, v_umo, acid, parm1, parm2 )
     then
       create_tnail := 'FALSE';
       commit;
    end if;

    -- Photo has rotated, reload it in
    open c1(v_umo);
    fetch c1 into imagex,imaget,imageb;
    if c1%NOTFOUND
     then
      retval := v_umo || ' record in the table not found';
      close c1;
      return;
    end if;
    close c1;
    -- create_tnail := 'FALSE';
  end if;

  if crop is not null
   then
     if not find_parameter( 'CROP_X_COORD', parm1, parm2, retval ) then retval := '0'; end if;
     retval1 := nvl(retval,'0');
     if not find_parameter( 'CROP_Y_COORD', parm1, parm2, retval ) then retval := '0'; end if;
     retval2 := nvl(retval,'0');
     if not find_parameter( 'CROP_M_COORD', parm1, parm2, retval ) then retval := '0'; end if;
     retval3 := nvl(retval,'0');
     if not find_parameter( 'CROP_N_COORD', parm1, parm2, retval ) then retval := '0'; end if;
     retval4 := nvl(retval,'0');
     imagex.process('cut=(' || retval1 || ' ' || retval2 || ' ' || retval3 || ' ' || retval4 || ')' );
     update umo set photo_master = imagex,version = nvl(version,1) + 1  where umo_id = v_umo;
     insert into log_photo_mod(aid,phid,date_modified,mod_type,extra_det) values
       (acid,v_umo,sysdate,'CROP','cut=(' || retval1 || ' ' || retval2 || ' ' || retval3 || ' ' || retval4 || ')' );
  end if;

 if resize_width is not null or resize_height is not null
  then
    if find_parameter( 'RESIZE_THRESHOLD', parm1, parm2, retval )
     then
       convstr := calculate_resize( imagex.width, imagex.height, imagex.contentlength, resize_width, to_number(retval));
       imagex.process( convstr );
       if imagex.contentlength > (resize_width * 1.3)
        then
         convstr := calculate_resize( imagex.width, imagex.height, imagex.contentlength, resize_width, to_number(retval));
         imagex.process( convstr );
       end if;
     else
       if resize_width is null then resize_width := imagex.width; end if;
       if resize_height is null then resize_height := imagex.height; end if;
       imagex.process('maxScale=(' || resize_width || ' ' || resize_height || ')' );
    end if;
    update umo set photo_master = imagex,version = nvl(version,1) + 1  where umo_id = v_umo;
    insert into log_photo_mod(aid,phid,date_modified,mod_type,extra_det) values
       (acid,v_umo,sysdate,'RESIZE','maxScale=(' || resize_width || ' ' || retval1 || ')' );
 end if;

 if grayscale is not null
  then
    imagex.process('contentFormat=8BITGREYSCALE' );
    update umo set photo_master = imagex,version = nvl(version,1) + 1  where umo_id = v_umo;
    insert into log_photo_mod(aid,phid,date_modified,mod_type,extra_det) values
       (acid,v_umo,sysdate,'GREYSCALE',convstr );
 end if;
 if (convert_to is not null) or (compression is not null)
  then
   if not find_parameter( 'CONVERT_TO', parm1, parm2, retval ) then retval := 'JPEG'; end if;
   retval1 := retval;
   if not find_parameter( 'COMPRESSION', parm1, parm2, retval ) then retval := 'LOW'; end if;
   retval2 := retval;
   convstr := photo_convert( retval1, retval2 );
   imagex.process( convstr );
   update umo set photo_master = imagex,version = nvl(version,1) + 1  where umo_id = v_umo;
   insert into log_photo_mod(aid,phid,date_modified,mod_type,extra_det) values (acid,v_umo,sysdate,'CONVERT',convstr );
 end if;

 -- Recreate Thumbnail
 if create_tnail = 'TRUE'
   then
    open c3(acid);
    fetch c3 into phgid;
    close c3;
    if not find_parameter( 'THUMBNAIL_WIDTH', parm1, parm2, retval )
     then
      retval := nvl(glbx.userpref( phgid, acid, 'THUMBNAIL_WIDTH' ),'100');
    end if;
    retval1 := retval;
    if imagex.mimetype = 'image/gif'
     then
      -- GIF Image
      convstr := 'fileformat=GIFF compressionFormat=GIFLZW ';
      imaget.process(convstr || ' maxScale=(' || to_char(to_number(retval1)) || ' ' || to_char(to_number(retval1)) || ')');
     else
      -- JPEG Image
      imagex.copy(imaget);
      convstr := 'fileformat=JFIF compressionFormat=JPEG compressionQuality=MAXINTEGRITY'; -- Thumbnails are alway created as JPEG, unless the original is GIF
      -- Resize Option
      if not find_parameter( 'THUMBNAIL_QUALITY', parm1, parm2, retval )
       then
        retval := nvl( glbx.userpref( phgid, acid, 'SUPER_THB'), '1');
      end if;
      thb_qual := to_number( retval );
      -- add smart ensuring cannot be bigger than original
      if (to_number(retval1*thb_qual) > imagex.width) or (to_number(retval1*thb_qual) > imagex.height)
       then
        thb_qual := greatest(round(imagex.width / retval1) - 1,1);
      end if;
      imaget.process(convstr || ' maxScale=(' || to_char(to_number(retval1*thb_qual)) || ' ' || to_char(to_number(retval1*thb_qual)) || ')');
      imaget.width := imaget.width / thb_qual;
      imaget.height := imaget.height / thb_qual;
    end if;
    update umo set photo_thumbnail = imaget,version = nvl(version,1) + 1  where umo_id = v_umo;
    insert into log_photo_mod(aid,phid,date_modified,mod_type,extra_det) values (acid,v_umo,sysdate,'THUMBNAIL',thb_qual);
 end if;

  -- Update attributes and index
  if not find_parameter( 'CHECK_EXISTS', parm1, parm2, retval ) then retval := 'FALSE'; end if;
  retval4 := retval;
  if not find_parameter( 'POSITION_ID', parm1, parm2, retval ) then retval := null; end if;
  retval2 := retval;
  x := NULL;
  if not find_parameter( 'PRICING_STRUCTURE', parm1, parm2, retval ) then retval := 'S'; end if;
  update umo um
    set
     pricing_structure = retval
    where umo_id = v_umo;

  if not find_parameter( 'ATTRIBUTE_ID', parm1, parm2, retval ) then attribid := null; end if;
  attribid := retval;
  if not find_parameter( 'POSITION', parm1, parm2, retval ) then pos := 1; end if;
  begin pos := to_number(retval); exception when others then pos := 1; end;

  open c2(v_umo);
  fetch c2 into v_extras;
  close c2;

  for crec in cattr( objtype, acid ) loop
   -- modify entry
   retval := NULL;
   if find_parameter( crec.sub_category, parm1, parm2, retval ) or
     (attribid is not null and substr(attribid,2,instr(attribid,']')-2) = crec.attribute_id)
    then

     -- Used if ATTRIBUTE_ID is passed down
     if substr(attribid,2,instr(attribid,']')-2) = crec.attribute_id
      then
       retval := substr(attribid,instr(attribid,']')+1);
     end if;

     step := 'A';
     retval1 := glbx.censor(retval,1000);
     -- Added to remove leading and trailing spaces which cause issues
     retval1 := trim(replace(retval1,chr(160),' ')); -- Convert non breaking space back to space (e.g. &nbsp;)
     if retval4 = 'FALSE'
      then
       -- htp.p( v_umo || '-' || crec.attribute_id || '-' || x || '-' || retval1); htp.nl;
       step := 'B';
       update umo_attribute
        set value = retval1,
            date_made = sysdate
         where umo_id = v_umo and
               nvl(position_id,1) = pos and
               attribute_id = crec.attribute_id;
       if sql%NOTFOUND
        then
         insert into umo_attribute(umo_id,attribute_id,date_made,position_id,value) values (v_umo,crec.attribute_id,sysdate,pos,retval1);
       end if;

       step := 'C';
       modify_entry( v_umo, crec.attribute_id, retval1, acid, pos, 'UPDATE', objtype, extract_numbers=>pfx.search_number_enable);

       -- Replicate the data appropriately
       if crec.sub_category = 'NEG_NO' then begin v_extras.orderby_nmb := to_number(retval1); exception when others then v_extras.orderby_nmb := 1; end;
       elsif crec.sub_category = 'FILM_NAME'
        then
         -- If the Customer Photo Name matches the Photographer Photo Name then modify the value
         if v_extras.film_name = v_extras.photo_name
          then
           v_extras.photo_name := substr(retval1,1,100);
           open c4;
           fetch c4 into ph_name_id;
           close c4;
           update umo_attribute
            set value = retval1,
                date_made = sysdate
             where umo_id = v_umo and
                   position_id = 1 and
                   attribute_id = ph_name_id;

           modify_entry( v_umo, ph_name_id, retval1, acid, pos, 'UPDATE', objtype, extract_numbers=>pfx.search_number_enable);

         end if;
         v_extras.film_name := substr(retval1,1,100);
       elsif crec.sub_category = 'NAME'
        then
        v_extras.photo_name := retval1;
       elsif crec.sub_category = 'FILM_TYPE'
        then
         update umo um
          set
           extra_film_colour = retval1
         where umo_id = v_umo;
       elsif crec.sub_category = 'FILM_SIZE'
        then
         update umo um
          set
           extra_film_size = retval1
         where umo_id = v_umo;
       elsif crec.sub_category = 'IMAGE CAPTION'
        then
         update umo um
          set
           image_caption = retval1
         where umo_id = v_umo;
       elsif crec.sub_category = 'ROLL_ID'
        then
         update umo um
          set
           extra_roll_id = retval1
         where umo_id = v_umo;
       elsif crec.sub_category = 'QUALITY'
        then
         v_extras.quality := retval1;
         if retval1 = 'DETAIL PHOTO'
          then
           update umo_attribute
            set
             value = 'STANDARD'
            where umo_id in (select umo_id from umo um where aid = acid and um.extras.quality = 'DETAIL PHOTO' and umo_id <> v_umo) and
                  attribute_id = crec.attribute_id;
           update umo um
            set um.extras.quality = 'STANDARD'
           where aid = acid and
                 um.extras.quality = 'DETAIL PHOTO' and
                 umo_id <> v_umo;
         end if;
       elsif crec.sub_category = 'PHOTOGRAPHER' then v_extras.enabled_phg := retval1; v_extras.enabled_cus := retval1;
       elsif crec.sub_category = 'BRIDAL' then v_extras.enabled_cus := retval1;
       end if;

      elsif retval4 = 'TRUE'
       then
        open c_check(v_umo,crec.attribute_id,retval1,to_number(retval2));
        fetch c_check into retval3;
        if c_check%NOTFOUND
         then
          open c_max(v_umo,crec.attribute_id);
          fetch c_max into x;
          if c_max%NOTFOUND then x:=1; end if;
          close c_max;
          insert into umo_attribute(umo_id,attribute_id,date_made,position_id,value) values (v_umo,crec.attribute_id,sysdate,x,retval1);
          modify_entry( v_umo, crec.attribute_id, retval1, acid, x, 'INSERT', objtype, extract_numbers=>pfx.search_number_enable);
        end if;
        close c_check;

      elsif retval4 = 'COMMENT'
       then
         if x is null
          then
           open c_max(v_umo,crec.attribute_id);
           fetch c_max into x;
           if c_max%NOTFOUND then x:=1; end if;
           close c_max;
         end if;
         x := nvl(x,1);
         -- htp.p( v_umo || '-' || crec.attribute_id || '-' || x || '-' || retval1); htp.nl;
         insert into umo_attribute(umo_id,attribute_id,date_made,position_id,value) values (v_umo,crec.attribute_id,sysdate,x,retval1);
         modify_entry( v_umo, crec.attribute_id, retval1, acid, x, 'INSERT', objtype, extract_numbers=>pfx.search_number_enable);
     end if;
   end if;
  end loop;

  -- Check for FTP_LOCATION
  if find_parameter( 'FTP_LOCATION', parm1, parm2, retval )
   then
    if not find_parameter( 'FTP_LOCATION_DIR', parm1, parm2, retval1 ) then retval1 := NULL; end if;
    update umo um
     set ftp_location = retval,
         ftp_virtual_dir = retval1
      where umo_id = v_umo;
  end if;

  -- Check for IS_GLOBAL
  if find_parameter( 'IS_GLOBAL', parm1, parm2, retval )
   then
    update umo um
     set is_global = nvl(substr(retval,1,1),'F')
      where umo_id = v_umo;
  end if;

  -- Check if the scene_name has changed
  if not find_parameter( 'SCENE_ID', parm1, parm2, retval ) then retval := NULL; end if;
  retval1 := retval;
  if retval1 is not null
   then
    v_extras.title := scene_title( to_number(retval1),v_extras.orderby_scene );
    update umo
     set
      umo_scene_id = to_number(retval1)
    where umo_id = v_umo;
  end if;
  -- Check if the scene_name has changed
  if not find_parameter( 'SORT_PRIORITY', parm1, parm2, retval ) then retval := NULL; end if;
  srt := retval;
  if srt is not null
   then
    update umo
     set
      sort_priority = srt
    where umo_id = v_umo;
  end if;
  update umo
     set
      extras = v_extras
    where umo_id = v_umo;
  commit;
  retval := NULL;
 exception when others then
  retval := 'M:' || step || '-' || sqlerrm;
  rollback;
 end modify_uma;

 procedure retrieve_uma( surl varchar2,parm1 in UMP.PARAMETERS, parm2 in UMP.PARAMETERS )
 as
  cursor c1(v_umo integer, acid integer) is
   select *
   from umo
   where umo_id = v_umo and
         ( (nvl(aid,nvl(acid,-1)) = nvl(acid,-1)) or (is_global = 'T' and (nvl(aid,nvl(acid,-1)) <> nvl(acid,-1))));

  cursor c1a(v_umo integer, utype varchar2) is select * from umo where umo_id = v_umo and umo_type = utype;
  cursor c1b(v_umo integer) is select * from umo where umo_id = v_umo;
  cursor c1p(profid integer) is select aid from customer_profile where profile_id = profid;
  cursor c2(phgr integer, acid integer) is select 'x' from customer_account where nvl(aid,-1) = nvl(acid,-1) and pid=phgr;
  cursor c2a(manid integer) is select 'x' from manufacturer where nvl(manufacturer_id,-1) = nvl(manid,-1);
  cursor c3(scard integer) is select aid,phid from ecard where eid = scard;
  cursor c3a(scard integer) is select logo_phid from photographer ph, customer_account ca, ecard ec where ec.eid = scard and ec.aid = ca.aid and ca.pid=ph.pid;
  cursor c4(v_umo integer) is select * from gallery_charge where umo_id = v_umo;
  cursor c5(phgid integer) is select logo_phid from photographer where pid = phgid;
  cursor c6(acid integer) is select umo_id from umo um where aid = acid and um.extras.quality = 'DETAIL PHOTO';
  cursor c7(acid integer) is select * from theme where theme_name = (select theme_name from customer_account where aid = acid);
  cursor c8(acid integer) is select * from theme_types where theme_type = (select theme_type from customer_account where aid = acid);
  cursor c9(v_umo integer, purchid integer) is select um.umo_id,um.aid from umo um, shopping_basket sb where sb.phid = v_umo and sb.poid = purchid and um.umo_id = sb.phid;
  cursor c10(acid integer) is select zoom_factor,background_img from customer_account where aid = acid;

  crec	 	c1%ROWTYPE;
  tmp		char(1);
  v_umo		integer;
  v_count	integer;
  c_imgchunk	binary_integer;
  v_imgchunk	binary_integer;
  acid		integer;
  phgr		integer;
  width		integer;
  height	integer;
  contentlength integer;
  background_img integer;
  sts		varchar2(200);
  retval	varchar2(4000);
  ltype		varchar2(100);
  pw		varchar2(100);
  greeting_card	integer;
  stype		integer;
  owner_id	integer;
  zoom		number;
  mimetype	varchar2(100);
  login_type	varchar2(100);
  display_what	varchar2(100);
  display_type	varchar2(100);
  overdisp	varchar2(100);
  retlink	varchar2(1000);
  detail	varchar2(100);
  v_buffer 	raw(32767);
  c_buffer 	varchar2(32767);
  isfound	boolean;
  foundrec	boolean;
  img		blob;
  cimg		clob;
  is_clob	boolean;
  zfactor	char(10);
  pfx		c7%ROWTYPE;
  ttype		varchar2(100);
  theme_rec	theme_types%ROWTYPE;

 begin

  -- Extract Parameters
  if not find_parameter( 'UMO_ID', parm1, parm2, retval ) then access_denied_image; return; end if;
  v_umo := to_number(retval);
  if not find_parameter( 'LOGIN_TYPE', parm1, parm2, retval ) then retval := 'EXTERNAL'; end if;
  login_type := retval;
  if not find_parameter( 'DISPLAY_WHAT', parm1, parm2, retval ) then retval := 'MASTER'; end if;
  display_what := retval;
  if not find_parameter( 'DISPLAY_TYPE', parm1, parm2, retval ) then retval := 'RAW'; end if;
  display_type := retval;
  if not find_parameter( 'OVERRIDE_DISPLAY', parm1, parm2, retval ) then retval := NULL; end if;
  overdisp := retval;

  -- Check security
  if login_type = 'EXTERNAL'
   then
     if not find_parameter( 'PASSWORD', parm1, parm2, retval ) then access_denied_image; return; end if;
     pw := retval;
     if not find_parameter( 'GREETING_CARD', parm1, parm2, retval ) then access_denied_image; return; end if;
     greeting_card := to_number(retval);
     if pw <> glbx.encrypt( DECS.GREETING_CARD_KEYWORD || greeting_card, TRUE )
      then
       access_denied_image;
       return;
     end if;
     if not find_parameter( 'IMG', parm1, parm2, retval ) then retval := 'STANDARD'; end if;
     if retval = 'STANDARD'
      then
       open c3(greeting_card);
       fetch c3 into acid,v_umo;
       close c3;
       display_what := 'MASTER';
       display_type := 'RAW';
      else
       open c3a(greeting_card);
       fetch c3a into v_umo;
       close c3a;
       display_what := 'MASTER';
       display_type := 'RAW';
       overdisp := 'ICON';
       acid := NULL;
     end if;
     ltype := 'CUSTOMER';
     owner_id := acid;
     stype := 1;
  elsif login_type = 'EXTERNAL_ORDER'
   then
     if not find_parameter( 'POID', parm1, parm2, retval ) then access_denied_image; return; end if;
     open c9(v_umo,retval);
     fetch c9 into v_umo,acid;
     if c9%NOTFOUND then close c9; access_denied_image; return; end if;
     close c9;
     ltype := 'CUSTOMER';
     owner_id := acid;
     stype := 1;
  elsif login_type in ('PHOTOGRAPHER','GALLERY')
   then
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'UMP.RETRIEVE_UMA', retrieved_id=>v_umo, dispwhat=>display_what, iscust=>FALSE );
    if sts is not null
     then
      access_denied_image;
      return;
    end if;
    phgr := owner_id;
    if not find_parameter( 'AID', parm1, parm2, retval ) then access_denied_image; return; end if;
    acid := to_number(retval);
    if login_type = 'PHOTOGRAPHER' and overdisp not in ('ICON','ADVERT')
     then
      open c2(phgr,acid);
      fetch c2 into tmp;
      if c2%NOTFOUND
       then
        close c2;
        access_denied_image;
        return;
      end if;
      close c2;
      if ltype <> login_type then access_denied_image; return; end if;
    end if;
  elsif login_type = 'MANUFACTURER'
   then
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'UMP.RETRIEVE_UMA', retrieved_id=>v_umo, dispwhat=>display_what, iscust=>FALSE );
    if sts is not null
     then
      access_denied_image;
      return;
    end if;
    phgr := owner_id;
    if not find_parameter( 'AID', parm1, parm2, retval ) then access_denied_image; return; end if;
    acid := to_number(retval);
    if nvl(overdisp,'IMAGE') not in ('ICON','ADVERT')
     then
      /*
      open c2a(acid);
      fetch c2a into tmp;
      if c2a%NOTFOUND
       then
        close c2a;
        access_denied_image;
        return;
      end if;
      close c2a;
      */
      if ltype <> login_type
       then
        null;
        --return;
      end if;
    end if;
  elsif login_type = 'OWNER'
   then
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'UMP.RETRIEVE_UMA', retrieved_id=>v_umo, dispwhat=>display_what );
    if sts is not null
     then
      access_denied_image;
      return;
    end if;
    acid := owner_id;
    if ltype <> login_type then access_denied_image; return; end if;
  elsif login_type in ('PROFILE','PROFILEG')
   then
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'UMP.RETRIEVE_UMA', retrieved_id=>v_umo, dispwhat=>display_what );
    if sts is not null
     then
      access_denied_image;
      return;
    end if;
    open c1p(owner_id);
    fetch c1p into acid;
    close c1p;
    if ltype <> login_type then access_denied_image; return; end if;
  elsif login_type in ('CUSTOMER','CUSTOMER_GALLERY')
   then
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'UMP.RETRIEVE_UMA', retrieved_id=>v_umo, dispwhat=>display_what );
    if sts is not null
     then
      access_denied_image;
      return;
    end if;
    acid := owner_id;
    if ltype = 'VIRTUAL' then ltype := 'CUSTOMER'; end if;
    --if (ltype <> login_type) and (login_type <> 'CUSTOMER_GALLERY') then access_denied_image; return; end if;
    if (ltype in ('CUSTOMER','OWNER','PROFILE','PROFILEG'))
     then
      null;
     else
      access_denied_image;
      return;
    end if;
  elsif login_type = 'ADMINISTRATOR'
   then
     glbx.adm_cookie_id(surl,owner_id,sts);
     if sts is not null then access_denied_image; return; end if;
     if not find_parameter( 'AID', parm1, parm2, retval ) then retval := NULL; end if;
     acid := retval;
  end if;

  -- Extract object
  if login_type in ('GALLERY','CUSTOMER_GALLERY','MANUFACTURER') or (overdisp in ('ICON','ADVERT'))
   then
    if overdisp in ('ICON','ADVERT')
     then
      open c1a(v_umo,overdisp);
     elsif login_type = 'CUSTOMER_GALLERY'
      then
      open c1a(v_umo,'GALLERY');
     elsif login_type = 'MANUFACTURER'
      then
      open c1b(v_umo);
      fetch c1b into crec;
      close c1b;
     else
      open c1a(v_umo,login_type);
    end if;
    if login_type <> 'MANUFACTURER'
     then
      fetch c1a into crec;
      if c1a%NOTFOUND
       then
        close c1a;
        access_denied_image;
        return; -- Assume the object does exist
      end if;
      close c1a;
    end if;
  else
    open c1(v_umo,acid);
    fetch c1 into crec;
    if c1%NOTFOUND
     then
      close c1;
      access_denied_image;
      return; -- Assume the object does exist
    end if;
    close c1;
  end if;

  -- Display RAW or WINDOW
  if display_type = 'RAW'
   then
    null; -- No need to do anything
  elsif display_type in ('WINDOW','WINDOWX','GALLERY')
   then
    if not find_parameter( 'ZOOM', parm1, parm2, retval ) then retval := '1'; end if;
    zoom := to_number(retval);
    open c7(acid);
    fetch c7 into pfx;
    close c7;
    open c10(acid);
    fetch c10 into zfactor,background_img;
    close c10;
    if display_type = 'GALLERY'
     then
      glbx.main_title( surl, crec.extras.photo_name,glbx.backimg(surl,acid,pfx.gallery_back),stype=>stype,sstyle=>pfx.gallery_text_font,sclr=>pfx.gallery_text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet );
      htp.title( LNG.GLB_TXT_126 );
     else
      glbx.main_title( surl, crec.extras.photo_name,glbx.backimg(surl,acid,pfx.text_back,background_img,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet );
      if crec.umo_type = 'AUDIO'
       then
        htp.title( LNG.GLB_TXT_127 );
       elsif crec.umo_type = 'VIDEO'
       then
        htp.title( LNG.GLB_TXT_128 );
      elsif crec.umo_type = 'DOCUMENT'
       then
        htp.title( LNG.GLB_TXT_129 );
      else
        htp.title( LNG.CST_TXT_072 );
     end if;
    end if;
    htp.p('<CENTER>');
    htp.tableopen( cattributes=>'border=10' );
    htp.tablerowopen;
    if nvl(crec.photo_master.contentlength,0) = 0
     then
       htp.tabledata( '<a href="" onClick="self.close()">' || '<IMG BORDER=0 SRC=' || DECS.IMAGE_LOCATION || 'admin/audio.gif alt="' || LNG.GLB_TXT_033 || '">' || '</a>' );
     else
      if display_type = 'WINDOW'
       then
        htp.tabledata( '<a href="" onClick="self.close()">' || '<IMG BORDER=0 HEIGHT=' || to_char(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) * nvl(zoom,1)) ||
                       ' SRC=ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=' || display_what || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=VERSION&parm2=' || to_char(crec.version) ||
                       ' alt="' || LNG.GLB_TXT_033 || '">' || '</a>' );
       elsif display_type = 'GALLERY'
        then
         if not find_parameter( 'RETURN_LINK', parm1, parm2, retval ) then retval := NULL; end if;
         retlink := retval;
         htp.tabledata( '<a href="' || retlink || '"><IMG BORDER=0 HEIGHT=' || to_char(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) * nvl(zoom,1)) ||
                       ' SRC=ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO' || '&parm1=VERSION&parm2=' || to_char(crec.version) ||
                       ' alt="' || LNG.GLB_TXT_032 || '"></a>' );
         htp.tablerowclose;
         htp.tablerowopen;
         htp.p( '<TD>' );
          isfound := FALSE;
          htp.bold( LNG.GLB_TXT_132 || ':' ); htp.nl;
          for c4rec in c4(v_umo) loop
           isfound := TRUE;
           --
           htp.anchor( 'ord.gallery_order?surl=' || surl || '&v_umo=' || v_umo || '&gc=' || translate( c4rec.charge_desc,' ','+' ) || '&acid=' || acid, c4rec.charge_desc || ' - ' || to_char(c4rec.charge,LNG.MONEY_FORMAT));
           htp.nl;
          end loop;
          if not isfound then htp.bold( LNG.GLB_TXT_131 ); htp.nl; end if;
         htp.p( '</TD>' );
        htp.tablerowclose;
        htp.tablerowopen;
         detail := ump.uma_attribute( surl, v_umo, 'GALLERY', 'DETAILS' );
         htp.tabledata( detail );
        htp.tablerowclose;
       else
        htp.tabledata( '<a href="" onClick="self.close()">' || '<IMG BORDER=0 HEIGHT=' || glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) ||
                       ' SRC=ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=AID&parm2=' || acid || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO' || '&parm1=VERSION&parm2=' || to_char(crec.version) ||
                       ' alt="' || LNG.GLB_TXT_033 || '">' || '</a>' );
      end if;
    end if;
    htp.tablerowclose;
    htp.tableclose;
    if substr(zfactor,1,1) = 'T' then htp.anchor( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=' || display_type || '&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=AID&parm2=' || acid || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO' || '&parm1=RETURN_LINK&parm2=' || retlink || '&parm1=ZOOM&parm2=0.25','[x 25%]' ); end if;
    if substr(zfactor,2,1) = 'T' then htp.anchor( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=' || display_type || '&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=AID&parm2=' || acid || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO' || '&parm1=RETURN_LINK&parm2=' || retlink || '&parm1=ZOOM&parm2=0.5','[x 50%]' ); end if;
    if substr(zfactor,3,1) = 'T' then htp.anchor( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=' || display_type || '&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=AID&parm2=' || acid || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO' || '&parm1=RETURN_LINK&parm2=' || retlink || '&parm1=ZOOM&parm2=0.75','[x 75%]' ); end if;
    if substr(zfactor,4,1) = 'T' then htp.anchor( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=' || display_type || '&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=AID&parm2=' || acid || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO' || '&parm1=RETURN_LINK&parm2=' || retlink || '&parm1=ZOOM&parm2=1','[x 1]' ); end if;
    if substr(zfactor,5,1) = 'T' then htp.anchor( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=' || display_type || '&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=AID&parm2=' || acid || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO' || '&parm1=RETURN_LINK&parm2=' || retlink || '&parm1=ZOOM&parm2=1.5','[x 1.5]' ); end if;
    if substr(zfactor,6,1) = 'T' then htp.anchor( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=' || display_type || '&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=AID&parm2=' || acid || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO' || '&parm1=RETURN_LINK&parm2=' || retlink || '&parm1=ZOOM&parm2=2','[x 2]' ); end if;
    if substr(zfactor,7,1) = 'T' then htp.anchor( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=' || display_type || '&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=AID&parm2=' || acid || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO' || '&parm1=RETURN_LINK&parm2=' || retlink || '&parm1=ZOOM&parm2=3','[x 3]' ); end if;
    if substr(zfactor,8,1) = 'T' then htp.anchor( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=' || display_type || '&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=AID&parm2=' || acid || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO' || '&parm1=RETURN_LINK&parm2=' || retlink || '&parm1=ZOOM&parm2=4','[x 4]' ); end if;
    if substr(zfactor,9,1) = 'T' then htp.anchor( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=' || display_type || '&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=AID&parm2=' || acid || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO' || '&parm1=RETURN_LINK&parm2=' || retlink || '&parm1=ZOOM&parm2=5','[x 5]' ); end if;
    if (display_type <> 'GALLERY')
     then
      if (crec.audio_original.format is not null)
       then
        --htp.p( '<BODY>' );
        htp.nl;
        if crec.audio_original.format = 'WAVE'
         then
          htp.p( '<EMBED SRC="ump.wav?surl=' || glbx.rndsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=' || display_what || '&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=OVERRIDE_DISPLAY&parm2=AUDIO">' );
        elsif crec.audio_original.format = 'AIFC'
         then
          htp.p( '<EMBED SRC="ump.aiff?surl=' || glbx.rndsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=' || display_what || '&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=OVERRIDE_DISPLAY&parm2=AUDIO">' );
        elsif crec.audio_original.format = 'MP3'
         then
          htp.p( '<EMBED  HEIGHT=200 WIDTH=200 SRC="ump.mp3?surl=' || glbx.rndsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=' || display_what || '&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=OVERRIDE_DISPLAY&parm2=AUDIO">' );
        end if;
        --htp.p( '</OBJECT>' );
        htp.nl;
        htp.nl;
        htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
        htp.nl;
        htp.italic( '<FONT SIZE="-1">' || LNG.GLB_TXT_070 || '</FONT>' );
        htp.nl;
       else
        htp.nl;
        htp.nl;
        htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
        htp.nl;
       end if;
    end if;

    open c8(acid);
    fetch c8 into theme_rec;
    close c8;
    -- XXX change to refer to order style
    if (substr(theme_rec.theme_data,95,1) = 'T' and login_type in ('OWNER','PROFILE')) or
       (substr(theme_rec.theme_data,96,1) = 'T' and login_type in ('CUSTOMER','PROFILEG'))
     then
      htp.nl;
      htp.bold( LNG3.ADM_TXT_602 ); htp.nl;
      htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
      foundrec := FALSE;
      if crec.photo_original.contentlength > 0
       then
        htp.tablerowopen;
         htp.tabledata( LNG3.ADM_TXT_321, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
         htp.tabledata( htf.anchor( 'ord.download_file?surl=' || surl || '&v_umo=' || crec.umo_id || '&purchid=&mthod=ORIGINAL&acid=' || acid, crec.extras.photo_name), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
         htp.tabledata( nvl(to_char(crec.photo_original.contentlength),LNG.PHG_TXT_247), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
         htp.tabledata( nvl(crec.photo_original.fileformat,LNG.PHG_TXT_247), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        htp.tablerowclose;
        foundrec := TRUE;
      end if;
      if crec.ftp_location is not null
       then
        htp.tablerowopen;
         htp.tabledata( LNG3.ADM_TXT_600, cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
         htp.tabledata( htf.anchor( 'ord.download_file?surl=' || surl || '&v_umo=' || crec.umo_id || '&purchid=&mthod=FTP&acid=' || acid, crec.extras.photo_name), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
         htp.tabledata( nvl(to_char(crec.photo_original.contentlength),LNG.PHG_TXT_247), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
         htp.tabledata( nvl(crec.photo_original.fileformat,LNG.PHG_TXT_247), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
        htp.tablerowclose;
        foundrec := TRUE;
      end if;
      htp.tableclose;
      if not foundrec then htp.bold( LNG3.ADM_TXT_603 ); htp.nl; end if;
    end if;
    htp.p( '</CENTER>' );
    htp.htmlclose;
    return;

  elsif display_type in ('IMAGE','IMAGENW')
   then
    if not find_parameter( 'RETURN_LINK', parm1, parm2, retval ) then retval := NULL; end if;
    retlink := retval;
    if not find_parameter( 'ZOOM', parm1, parm2, retval ) then retval := '1'; end if;
    zoom := to_number(retval);
    if display_what = 'ORIGINAL' then width := crec.photo_original.width; height := crec.photo_original.height;
    elsif display_what = 'MASTER' then width := crec.photo_master.width; height := crec.photo_master.height;
    elsif display_what = 'THUMBNAIL' then width := crec.photo_thumbnail.width; height := crec.photo_thumbnail.height;
    end if;
    open c7(acid);
    fetch c7 into pfx;
    close c7;
    open c10(acid);
    fetch c10 into zfactor,background_img;
    close c10;
    glbx.main_title( surl, crec.extras.photo_name,glbx.backimg(surl,acid,pfx.text_back,background_img,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet );
    htp.p( '<CENTER>' );
    htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=10' );
    htp.tablerowopen;
    if retlink is null
      then
        htp.tabledata( '<a href="" onClick="self.close()">' || '<IMG BORDER=0 HEIGHT=' || to_char(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) * nvl(zoom,1)) || ' SRC=ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=' || display_what || '&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=VERSION&parm2=' || to_char(crec.version) || ' alt="' || LNG.GLB_TXT_033 || '"></a>' );
      else
        if display_type = 'IMAGENW'
	 then
          htp.tabledata( '<a href="" onClick="self.close()">' || '<IMG BORDER=0 HEIGHT=' || to_char(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) * nvl(zoom,1)) || ' SRC=ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=' || display_what || '&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=VERSION&parm2=' || to_char(crec.version) || ' alt="' || LNG.GLB_TXT_033 || '"></a>');
	 else
          htp.tabledata( htf.anchor( translate(retlink,'~!','?&'), '<IMG BORDER=0 HEIGHT=' || to_char(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) * nvl(zoom,1)) || ' SRC=ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=' || display_what || '&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=VERSION&parm2=' || to_char(crec.version) ||' alt="' || LNG.GLB_TXT_032 || '">' ));
	end if;
    end if;
    htp.tablerowclose;
    htp.tableclose;
    if substr(zfactor,1,1) = 'T' then htp.anchor( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=' || display_type || '&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=AID&parm2=' || acid || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO' || '&parm1=RETURN_LINK&parm2=' || retlink || '&parm1=ZOOM&parm2=0.25','[x 25%]' ); end if;
    if substr(zfactor,2,1) = 'T' then htp.anchor( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=' || display_type || '&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=AID&parm2=' || acid || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO' || '&parm1=RETURN_LINK&parm2=' || retlink || '&parm1=ZOOM&parm2=0.5','[x 50%]' ); end if;
    if substr(zfactor,3,1) = 'T' then htp.anchor( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=' || display_type || '&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=AID&parm2=' || acid || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO' || '&parm1=RETURN_LINK&parm2=' || retlink || '&parm1=ZOOM&parm2=0.75','[x 75%]' ); end if;
    if substr(zfactor,4,1) = 'T' then htp.anchor( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=' || display_type || '&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=AID&parm2=' || acid || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO' || '&parm1=RETURN_LINK&parm2=' || retlink || '&parm1=ZOOM&parm2=1','[x 1]' ); end if;
    if substr(zfactor,5,1) = 'T' then htp.anchor( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=' || display_type || '&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=AID&parm2=' || acid || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO' || '&parm1=RETURN_LINK&parm2=' || retlink || '&parm1=ZOOM&parm2=1.5','[x 1.5]' ); end if;
    if substr(zfactor,6,1) = 'T' then htp.anchor( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=' || display_type || '&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=AID&parm2=' || acid || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO' || '&parm1=RETURN_LINK&parm2=' || retlink || '&parm1=ZOOM&parm2=2','[x 2]' ); end if;
    if substr(zfactor,7,1) = 'T' then htp.anchor( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=' || display_type || '&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=AID&parm2=' || acid || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO' || '&parm1=RETURN_LINK&parm2=' || retlink || '&parm1=ZOOM&parm2=3','[x 3]' ); end if;
    if substr(zfactor,8,1) = 'T' then htp.anchor( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=' || display_type || '&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=AID&parm2=' || acid || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO' || '&parm1=RETURN_LINK&parm2=' || retlink || '&parm1=ZOOM&parm2=4','[x 4]' ); end if;
    if substr(zfactor,9,1) = 'T' then htp.anchor( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=' || display_type || '&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=LOGIN_TYPE&parm2=' || login_type || '&parm1=AID&parm2=' || acid || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO' || '&parm1=RETURN_LINK&parm2=' || retlink || '&parm1=ZOOM&parm2=5','[x 5]' ); end if;
    if display_type = 'IMAGENW'
     then
      htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
    end if;
    htp.p( '</CENTER>' );
    htp.htmlclose;
    return;
  end if;


  overdisp := nvl(overdisp,crec.umo_type);
  -- Get Raw Details to Display It
  is_clob := FALSE;
  if overdisp in ('PHOTO','GALLERY','MANUFACTURER')
   then
    if display_what = 'ORIGINAL'
     then

    img := crec.photo_original.source.localdata;
    mimetype := crec.photo_original.mimetype;
    contentlength := crec.photo_original.contentlength;

    elsif display_what = 'MASTER'
     then
      img := crec.photo_master.source.localdata;
      mimetype := crec.photo_master.mimetype;
      contentlength := crec.photo_master.contentlength;

    elsif display_what = 'THUMBNAIL'
     then
      img := crec.photo_thumbnail.source.localdata;
      mimetype := crec.photo_thumbnail.mimetype;
      contentlength := crec.photo_thumbnail.contentlength;
    end if;

  elsif overdisp in ('ADVERT','BACKGROUND','ICON','WATERMARK','SLIDE')
   then
    img := crec.photo_master.source.localdata;
    mimetype := crec.photo_master.mimetype;
    contentlength := crec.photo_master.contentlength;

  elsif overdisp in ('AUDIO','AUDIO_BW') -- for black and white thumbnails
   then
    if display_what = 'ORIGINAL'
     then
      img := crec.audio_original.source.localdata;
      mimetype := crec.audio_original.mimetype;
      contentlength := dbms_lob.getlength(crec.audio_original.source.localdata);
     else
      img := crec.audio_thumbnail.source.localdata;
      mimetype := crec.audio_thumbnail.mimetype;
      contentlength := dbms_lob.getlength(crec.audio_thumbnail.source.localdata);
    end if;

  elsif overdisp = 'VIDEO'
   then
      img := crec.video_original.source.localdata;
      mimetype := crec.video_original.mimetype;
      contentlength := to_number(nvl(crec.video_original.description,'0'));

  elsif overdisp = 'BLUEPRINT'
   then
    if display_what = 'ORIGINAL'
     then
      img := crec.blueprint_obj.localdata;
      mimetype := crec.blueprint_obj.mimetype;
      contentlength := crec.blueprint_obj.blueprint_length;
     else
      img := crec.blueprint_obj.online_version;
      mimetype := crec.blueprint_obj.online_mimetype;
      contentlength := crec.blueprint_obj.online_length;
    end if;

  elsif overdisp = 'DOCUMENT'
   then
    if display_what = 'GIST'
     then
      cimg := crec.doc_gist;
      mimetype := 'text/html';
      contentlength := dbms_lob.getlength(crec.doc_gist);
      is_clob := TRUE;
    elsif display_what = 'HTML'
     then
      cimg := crec.doc_html;
      mimetype := 'text/html';
      contentlength := dbms_lob.getlength(crec.doc_html);
      is_clob := TRUE;
    elsif display_what = 'ORIGINAL'
     then
      img := crec.doc_body;
      mimetype := crec.doc_mimetype;
      contentlength := dbms_lob.getlength(crec.doc_body);
    end if;
  end if;

--htp.bold( nvl(contentlength,0) || '-' || mimetype ); htp.nl;

  if nvl(contentlength,0) = 0 then access_denied_image; return; end if;
  if overdisp not in ('AUDIO','VIDEO','DOCUMENT','BLUEPRINT')
   then
     owa_util.mime_header(nvl(mimetype,'image/jpeg'));
   elsif overdisp = 'DOCUMENT'
    then
     owa_util.mime_header(nvl(mimetype,'document/unknown'));
   elsif overdisp in ('VIDEO','AUDIO','BLUEPRINT')
    then
     owa_util.mime_header(nvl(mimetype,'video/msvideo'));
   end if;

  if is_clob
   then
    c_imgchunk := 32367; --255
    v_imgchunk := 32367; --255
    v_count := 0;
    begin
     loop
      dbms_lob.read(cimg,v_imgchunk,(v_count*c_imgchunk)+1,c_buffer);
      v_count := v_count + 1;
      htp.prn( c_buffer );
     end loop;
    exception
     when no_data_found then null;
     when others
	  then glbx.error_details( 'UMP', 'RETRIEVE_UMA',errmsg=>sqlerrm,extdet=>'Error Occurred in Program Subloop: V_COUNT:' || v_count);
    end;
   else
    --wpg_docload.download_file( to_char(v_umo) );

    wpg_docload.download_file (img);
    /*
    c_imgchunk := 32767; --255
    v_imgchunk := 32767; --255
    v_count := 0;
    begin
     loop
      dbms_lob.read(img,v_imgchunk,(v_count*c_imgchunk)+1,v_buffer);
      v_count := v_count + 1;
      htp.prn( sys.utl_raw.cast_to_varchar2(v_buffer) );
     end loop;
    exception
     when no_data_found then null;
     when others
	  then glbx.error_details( 'UMP', 'RETRIEVE_UMA',errmsg=>sqlerrm,extdet=>'Error Occurred in Program Subloop: V_COUNT:' || v_count);
    end;
    */
   end if;
   commit;

 exception when others then
  glbx.error_details( 'UMP', 'RETRIEVE_UMA',errmsg=>sqlerrm );
 end retrieve_uma;

 procedure wav( surl varchar2, parm1 in UMP.PARAMETERS, parm2 in UMP.PARAMETERS )
 as
 begin
  retrieve_uma(surl,parm1,parm2);
 end wav;

 procedure aiff( surl varchar2, parm1 in UMP.PARAMETERS, parm2 in UMP.PARAMETERS )
 as
 begin
  retrieve_uma(surl,parm1,parm2);
 end aiff;

 procedure mp3( surl varchar2, parm1 in UMP.PARAMETERS, parm2 in UMP.PARAMETERS )
 as
 begin
  retrieve_uma(surl,parm1,parm2);
 end mp3;

 function uma_attribute( surl varchar2,ump_id in integer, attrib_id in integer )
  return varchar2
 as
  cursor c1(ump_id integer, attrib_id integer) is
   select value
   from umo_attribute
   where umo_id = ump_id and
         attribute_id = attrib_id;
  c1rec	c1%ROWTYPE;
 begin
   open c1(ump_id, attrib_id);
   fetch c1 into c1rec;
   if c1%NOTFOUND
    then
     close c1;
     return(null);
   end if;
   close c1;
   return( c1rec.value );
 exception when others then
  glbx.error_details( 'UMP', 'UMA_ATTRIBUTES',errmsg=>sqlerrm, extdet=> 'UMP_ID:' || ump_id || ' ATTRIB_ID:' || attrib_id);
 end uma_attribute;

 function uma_attribute( surl varchar2,ump_id in integer, objtype in varchar2, subcat in varchar2 )
  return varchar2
 as
  cursor c2(objtype varchar2, subcat varchar2) is
   select value
   from umo_attribute ut, umo_attributes uts
   where uts.umo_type = objtype and
         uts.sub_category = subcat and
         uts.attribute_id = ut.attribute_id and
         ut.umo_id = ump_id;
  c2rec		c2%ROWTYPE;
 begin
   open c2(objtype,subcat);
   fetch c2 into c2rec;
   if c2%NOTFOUND
    then
     close c2;
     return(null);
   end if;
   close c2;
   return( c2rec.value );
 exception when others then
  glbx.error_details( 'UMP', 'UMA_ATTRIBUTES',errmsg=>sqlerrm, extdet=> 'UMP_ID:' || ump_id || ' OBJTYPE:' || objtype || ' SUBCAT:' || subcat);
 end uma_attribute;

 function uma_scene( surl varchar2,ump_id in integer, scene_id in integer )
  return varchar2
 as
 begin

   return(null);

 exception when others then
  glbx.error_details( 'UMP', 'UMA_SCENE',errmsg=>sqlerrm, extdet=> 'UMP_ID:' || ump_id || ' SCENE_ID:' || scene_id );
 end uma_scene;

 function find_parameter( parm_name in varchar2, parm1 in UMP.PARAMETERS, parm2 in UMP.PARAMETERS, retval out varchar2 )
  return boolean
 as
 begin
  retval := NULL;
  for j in parm1.first..parm1.last loop
   if parm_name = parm1(j)
    then
     retval := parm2(j);
     return( TRUE );
   end if;
  end loop;
  retval := 'Parameter: ' || parm_name || ' not found.';
  return( FALSE );
 exception when others then
  glbx.error_details( 'UMP', 'FIND_PARAMETER',errmsg=>sqlerrm, extdet=> 'PARM_NAME: ' || parm_name );
  return( NULL );
 end find_parameter;

procedure delete_websys( fname in varchar2, nocommit in varchar2 default 'COMMIT' )
as
 --cursor c1 is select oid from ows_object where name=fname;
 --c1rec	c1%ROWTYPE;
begin
   --delete from file_upload_metadata where filename = fname;
   delete from apache_ows_content where name = fname;
 /*
 if DECS.OAS_OR_APACHE = 'APACHE'
  then
   delete from file_upload_metadata where name = fname;
   delete from apache_ows_content where name = fname;
  else
   open c1;
   fetch c1 into c1rec;
   close c1;
   delete from ows_content where oid=c1rec.oid;
   delete from ows_attributes where oid=c1rec.oid;
   delete from ows_fixed_attrib where oid=c1rec.oid;
   delete from ows_object where oid=c1rec.oid;
 end if;
 */
 if nocommit = 'COMMIT' then commit; end if;
exception when others then
 glbx.error_details( 'UMP', 'DELETE_WEBSYS',errmsg=>sqlerrm,extdet=>fname);
end delete_websys;

function photo_convert( imgtype in varchar2 default 'JPEG', compr in varchar2 default 'LOW', orig in varchar2 default 'JPEG' )
 return varchar2
as
 convstr	varchar2(100);
begin
  if imgtype is null and compr is null then return( null ); end if;
  if imgtype = 'JPEG' and orig = 'JPEG'
    then
     if compr in ('S', LNG.PHG_ALT_427) then convstr := 'fileformat=JFIF'; return( convstr ); end if; -- 'Do not Compress'
     convstr := 'fileformat=JFIF compressionFormat=JPEG ';
     if compr in ('H','LOWCOMP') -- Lowest Compression (High Quality Image)
      then
        convstr := convstr || 'compressionQuality=LOWCOMP scale=2';
     elsif compr in ('M','MEDCOMP')
      then
        convstr := convstr || 'compressionQuality=MEDCOMP scale=2';
     elsif compr in ('L','HIGHCOMP') -- Compress the Image to the Max (Low Quality)
      then
        convstr := convstr || 'compressionQuality=HIGHCOMP scale=1';
     end if;

   elsif imgtype = 'JPEG' -- When another format like TIFF
    then
     if compr in ('S', LNG.PHG_ALT_427) then convstr := 'fileformat=JFIF'; return( convstr ); end if;
     convstr := 'fileformat=JFIF compressionFormat=JPEG ';
     if compr in ('H','LOWCOMP') -- Lowest Compression (High Quality Image)
      then
        convstr := convstr || 'compressionQuality=MAXINTEGRITY';
     elsif compr in ('M','MEDCOMP')
      then
        convstr := convstr || 'compressionQuality=LOWCOMP';
     elsif compr in ('L','HIGHCOMP') -- Compress the Image to the Max (Low Quality)
      then
        convstr := convstr || 'compressionQuality=HIGHCOMP';
     end if;

    else
     convstr := 'fileformat=GIFF compressionFormat=GIFLZW ';
  end if;
  return( convstr );
exception when others then
 glbx.error_details( 'UMP', 'PHOTO_CONVERT',errmsg=>sqlerrm,extdet=>'IMGTYPE:' || imgtype || ' COMPR:' || compr);
end photo_convert;

function calculate_resize( original_width in integer, original_height in integer, original_length in integer, scaleto in integer, scalethreshold in integer )
 return varchar2
as
 convstr	varchar2(100);
 nmbw		number;
begin
    if scaleto is null or scalethreshold is null then convstr := NULL; return( convstr ); end if;
    if (original_length > 0) and (original_length > scalethreshold)
     then
      if original_width > original_height
       then
        nmbw := round( ((original_width * scaleto) / original_length) * 1.1 ); -- 1.1 is a fudge factor to get it back right
        if original_length > (scaleto * 1.6) then nmbw := round(nmbw * (original_length/(scaleto * 1.6)) ); end if; -- Further fudge for larger photos
        if nmbw > original_width then nmbw := round(original_width * 0.9); end if;
       else
        nmbw := round( ((original_height * scaleto) / original_length) * 1.1 );
        if original_length > (scaleto * 1.6) then nmbw := round(nmbw * (original_length/(scaleto * 1.6)) ); end if; -- Further fudge for larger photos
--        if original_length > 100000 then nmbw := round(nmbw * 1.5); end if; -- Further fudge for larger photos
        if nmbw > original_height then nmbw := round(original_height * 0.9); end if;
      end if;
      convstr := 'maxScale=(' || to_char(nmbw) || ' ' || to_char(nmbw) || ')';
     else
      convstr := NULL;
    end if;
    --htp.bold( 'OW:' || original_width || ' OH:' || original_height || ' OL:' || original_length || ' ST:' || scaleto || ' STH:' || scalethreshold );htp.nl;
    --htp.bold( 'CONVSTR:' || convstr ); htp.nl;
  return( convstr );
exception when others then
 glbx.error_details( 'UMP', 'CALCULATE_RESIZE',errmsg=>sqlerrm);
end calculate_resize;

function extract_tokens( tval in varchar2, ctr in integer, split_numbers in boolean default FALSE, tokens in out nocopy myarray )
 return varchar2
as
begin
 if split_numbers
  then
   return(extract_tokens( tval=>tval, ctr=>ctr, split_numbers=>'T', tokens=>tokens ));
  else
   return(extract_tokens( tval=>tval, ctr=>ctr, split_numbers=>'F', tokens=>tokens ));
 end if;
end extract_tokens;

function extract_tokens( tval in varchar2, ctr in integer, split_numbers in char, tokens in out nocopy myarray )
 return varchar2
as

 m	integer;
 n	integer;
 x	integer;
 y	integer;
 z	integer;
 zc	integer;
 z1	integer;
 z2	integer;
 nmb	char(1);

begin
 if tval is null then return( null ); end if;
 -- Delimeters are space, full stop, comma and HTML line feed

 x := nvl(instr(tval,' ',1,1),0);  -- Look for Space
 y := nvl(instr(tval,'.',1,1),0);  -- Look for full stop
 z := nvl(instr(tval,',',1,1),0);  -- Look for comma
 zc := nvl(instr(tval,':',1,1),0);  -- Look for colon
 z1 := nvl(instr(tval,'<BR>',1,1),0); -- Look for HTML break tag

 -- Look for a number
 nmb := split_numbers;
 if split_numbers = 'T'
  then
   n := nvl(instr(tval,'1'),0);
   if n = 0 then z2 := 99999; else z2 := n; end if;
   n := nvl(instr(tval,'2'),0);
   if n = 0 then n := 99999; end if;
   z2 := least(z2,n);
   n := nvl(instr(tval,'3'),0);
   if n = 0 then n := 99999; end if;
   z2 := least(z2,n);
   n := nvl(instr(tval,'4'),0);
   if n = 0 then n := 99999; end if;
   z2 := least(z2,n);
   n := nvl(instr(tval,'5'),0);
   if n = 0 then n := 99999; end if;
   z2 := least(z2,n);
   n := nvl(instr(tval,'6'),0);
   if n = 0 then n := 99999; end if;
   z2 := least(z2,n);
   n := nvl(instr(tval,'7'),0);
   if n = 0 then n := 99999; end if;
   z2 := least(z2,n);
   n := nvl(instr(tval,'8'),0);
   if n = 0 then n := 99999; end if;
   z2 := least(z2,n);
   n := nvl(instr(tval,'9'),0);
   if n = 0 then n := 99999; end if;
   z2 := least(z2,n);
  else
   z2 := 0;
 end if;

 if (x = 0) and (y = 0) and (z = 0) and (zc = 0) and (z1=0) and (z2=0)
  then
   tokens(ctr) := ltrim(rtrim(tval));
   return( null );
  else
   if (x = 0) then x := 99999; end if;
   if (y = 0) then y := 99999; end if;
   if (z = 0) then z := 99999; end if;
   if (zc = 0) then zc := 99999; end if;
   if (z1 = 0) then z1 := 99999; end if;
   if (z2 = 0) then z2 := 99999; end if;
   m := least(x,y,z,zc,z1,z2);
   if m = z2 -- Once one number is found don't split anymore of them
    then
     nmb := 'F';
     tokens(ctr) := substr(tval,1,m-1);
     m := m - 1;
    else
     tokens(ctr) := substr(tval,1,m-1);
   end if;
 end if;

 if m = z1
  then
   return( extract_tokens( substr(tval,m+4),ctr+1, nmb, tokens ));
  else
   return( extract_tokens( substr(tval,m+1),ctr+1, nmb, tokens ));
 end if;

exception when others then htp.p(sqlerrm); return( null );
end extract_tokens;

procedure modify_entry( v_umo in integer, attrib_id in integer, data_value in varchar2, acid in integer, posid in integer default 1, action in varchar2 default 'INSERT', bypass_procedure in varchar2 default null, extract_numbers in char default 'F')
as

  tokens	MYARRAY;
  retstmt	varchar2(2000);

 begin
  if bypass_procedure in ('AUDIO','VIDEO','RELATIONAL','BLUEPRINT','DOCUMENT')
   then
    if bypass_procedure = 'AUDIO'
     then
      myaudio.audio_api(v_umo=>v_umo,attrib_id=>attrib_id,data_value=>data_value,acid=>acid,posid=>nvl(posid,1),action=>action);
    elsif bypass_procedure = 'VIDEO'
     then
      myvideo.video_api(v_umo=>v_umo,attrib_id=>attrib_id,data_value=>data_value,acid=>acid,posid=>nvl(posid,1),action=>action);
    elsif bypass_procedure = 'RELATIONAL'
     then
      myrelational.relational_api(v_umo=>v_umo,attrib_id=>attrib_id,data_value=>data_value,acid=>acid,posid=>nvl(posid,1),action=>action);
    elsif bypass_procedure = 'BLUEPRINT'
     then
      myblueprint.blueprint_api(v_umo=>v_umo,attrib_id=>attrib_id,data_value=>data_value,acid=>acid,posid=>nvl(posid,1),action=>action);
    elsif bypass_procedure = 'DOCUMENT'
     then
      mydocument.document_api(v_umo=>v_umo,attrib_id=>attrib_id,data_value=>data_value,acid=>acid,posid=>nvl(posid,1),action=>action);
    end if;
    return;
  end if;

  if action in ('UPDATE','DELETE')
   then
    delete from umo_index where umo_id = v_umo and attribute_id = attrib_id and aid = acid and position_id = posid;
  end if;
  if action = 'DELETE' then return; end if;
  retstmt := extract_tokens( data_value, 1, extract_numbers, tokens );
  if not tokens.exists( 1 ) then return; end if; -- Nothing extracted
  for j in tokens.first..tokens.last loop
   insert into umo_index(umo_id, aid, attribute_id, word_original,word_upper,word_soundex,ordering,position_id) values
    (v_umo, acid, attrib_id, substr(trim(tokens(j)),1,100), upper(substr(trim(tokens(j)),1,100)), soundex_api(substr(trim(tokens(j)),1,100),attrib_id), j, posid);
  end loop;
exception when others then
 glbx.error_details( 'UMP', 'MODIFY_ENTRY',errmsg=>sqlerrm, extdet=>'DATA_VALUE:' || data_value || ' ACTION:' || action);
end modify_entry;

function check_quota( surl varchar2, owner_type in varchar2, owner_id in integer, acid in integer, size_bytes in integer, bypass_check in varchar2, pname in varchar2, retval out varchar2)
 return boolean
as
  v_quota	ump.quotalist;
begin
 if bypass_check = 'TRUE' then return( TRUE ); end if;
 get_quota(surl,owner_type,owner_id,pname,acid,v_quota);
 if size_bytes > (v_quota.max_photo_size * 1024)
  then
   retval := LNG2.UMP_TXT_034 || ': ' || v_quota.max_photo_size || '. ' || LNG2.UMP_TXT_035 || ': ' || size_bytes;
   return( FALSE );
 end if;

 if (v_quota.total_asset + 1) > v_quota.max_photos
  then
   retval := LNG2.UMP_TXT_034 || ': ' || v_quota.max_photos || '. ' || LNG2.UMP_TXT_036 || ': ' || to_char(v_quota.total_asset + 1);
   return( FALSE );
 end if;

 if (v_quota.total_used + size_bytes) > (v_quota.max_storage * 1024)
  then
   retval := LNG2.UMP_TXT_037 || ': ' || v_quota.max_storage || '. ' || LNG2.UMP_TXT_038 || ': ' || to_char(v_quota.total_used + size_bytes);
   return( FALSE );
 end if;

 return( TRUE );
exception when others then
 glbx.error_details( 'UMP', 'CHECK_QUOTA',errmsg=>sqlerrm,extdet=>'OWNER_TYPE:' || owner_type || ' OWNER_ID:' || owner_id || ' BYPASS_CHECK:' || bypass_check);
end check_quota;

procedure get_quota( surl varchar2, owner_type in varchar2, owner_id in integer, pname in varchar2, acid in integer, quota out ump.quotalist )
as
 cursor c1( plan_id integer ) is
  select payment_style, max_storage, max_photos, max_photo_size, owner_plan_id, cust_plan_id, renewal_date, plan_name
  from charge_plan cp
  where cp.id = plan_id;

 cursor c3( phgr integer, acid integer ) is
  select payment_style, max_storage, max_photos, max_photo_size, owner_plan_id, cust_plan_id, renewal_date, plan_name
  from charge_plan cp, photographer ph, customer_account ca
  where ph.pid = phgr and
        ph.plan_id = cp.id and
        ca.pid = ph.pid and
        ca.aid = acid and
        plan_event is null
  union all
  select cp.payment_style, cp.max_storage, cpe.images_max max_photos, cp.max_photo_size, cp.owner_plan_id, cp.cust_plan_id, cp.renewal_date, cp.plan_name
  from charge_plan cp, photographer ph, customer_account ca, charge_plan_event cpe
  where ph.pid = phgr and
        ph.plan_id = cp.id and
        ca.pid = ph.pid and
        ca.aid = acid and
        ca.plan_event is not null and
        cpe.plan_id = cp.id and
        cpe.plan_event = ca.plan_event;

 cursor c4( acid integer, owner_type varchar2 ) is
  select sum( nvl(um.photo_original.contentlength,0) +
              nvl(um.photo_master.contentlength,0) +
              nvl(um.photo_thumbnail.contentlength,0) +
              nvl(um.photo_backup.contentlength,0) +
              nvl(to_number(um.doc_length),0) +
              nvl(to_number(um.audio_original.description),0) +
              nvl(to_number(um.audio_thumbnail.description),0) +
              nvl(to_number(um.blueprint_obj.blueprint_length),0) +
              nvl(to_number(um.blueprint_obj.online_length),0) +
              nvl(to_number(um.video_original.description),0) ) tot,
         sum(decode(nvl(um.photo_master.contentlength,0),0,0,1) +
              decode(nvl(to_number(um.doc_length),0),0,0,1) +
              decode(nvl(to_number(um.audio_original.description),0),0,0,1) +
              decode(nvl(to_number(um.audio_thumbnail.description),0),0,0,1) +
              decode(nvl(to_number(um.blueprint_obj.blueprint_length),0),0,0,1) +
              decode(nvl(to_number(um.blueprint_obj.online_length),0),0,0,1) +
              decode(nvl(to_number(um.video_original.description),0),0,0,1) ) cnt,
         sum(decode(nvl(um.photo_original.contentlength,0),0,0,1)) numb_ph_orig,
         sum(nvl(um.photo_original.contentlength,0)) size_ph_orig,
         sum(decode(nvl(um.photo_master.contentlength,0),0,0,1)) numb_ph_web,
         sum(nvl(um.photo_master.contentlength,0)) size_ph_web,
         sum(decode(nvl(um.photo_thumbnail.contentlength,0),0,0,1)) numb_ph_thmb,
         sum(nvl(um.photo_thumbnail.contentlength,0)) size_ph_thmb,
         sum(decode(nvl(um.photo_backup.contentlength,0),0,0,1)) numb_ph_back,
         sum(nvl(um.photo_backup.contentlength,0)) size_ph_back,
         sum(decode(nvl(um.audio_original.description,0),0,0,1)) numb_aud_orig,
         sum(nvl(um.audio_original.description,0)) size_aud_orig,
         sum(decode(nvl(um.doc_length,0),0,0,1)) numb_doc_orig,
         sum(nvl(um.doc_length,0)) size_doc_orig,
         sum(decode(nvl(um.video_original.description,0),0,0,1)) numb_vid_orig,
         sum(nvl(um.video_original.description,0)) size_vid_orig,
         sum(decode(nvl(um.blueprint_obj.blueprint_length,0),0,0,1)) numb_bp_orig,
         sum(nvl(um.blueprint_obj.blueprint_length,0)) size_bp_orig,
         sum(decode(nvl(um.blueprint_obj.online_length,0),0,0,1)) numb_bp_online,
         sum(nvl(um.blueprint_obj.online_length,0)) size_bp_online
  from umo um
  where aid = acid and
        umo_type in ('PHOTO','DOCUMENT','AUDIO','VIDEO','RELATIONAL','BLUEPRINT') and
        umo_owner = owner_type;

 -- XXX this statement does not scale
 cursor c5( phgr integer, owner_type varchar2, acid integer ) is
  select sum( nvl(um.photo_original.contentlength,0) +
              nvl(um.photo_master.contentlength,0) +
              nvl(um.photo_thumbnail.contentlength,0) +
              nvl(um.photo_backup.contentlength,0) +
              nvl(to_number(um.doc_length),0) +
              nvl(to_number(um.audio_original.description),0) +
              nvl(to_number(um.audio_thumbnail.description),0) +
              nvl(to_number(um.blueprint_obj.blueprint_length),0) +
              nvl(to_number(um.blueprint_obj.online_length),0) +
              nvl(to_number(um.video_original.description),0) ) tot,
         sum( decode(nvl(um.photo_master.contentlength,0),0,0,1) +
              decode(nvl(to_number(um.doc_length),0),0,0,1) +
              decode(nvl(to_number(um.audio_original.description),0),0,0,1) +
              decode(nvl(to_number(um.audio_thumbnail.description),0),0,0,1) +
              decode(nvl(to_number(um.blueprint_obj.blueprint_length),0),0,0,1) +
              decode(nvl(to_number(um.blueprint_obj.online_length),0),0,0,1) +
              decode(nvl(to_number(um.video_original.description),0),0,0,1) ) cnt,
         sum(decode(nvl(um.photo_original.contentlength,0),0,0,1)) numb_ph_orig,
         sum(nvl(um.photo_original.contentlength,0)) size_ph_orig,
         sum(decode(nvl(um.photo_master.contentlength,0),0,0,1)) numb_ph_web,
         sum(nvl(um.photo_master.contentlength,0)) size_ph_web,
         sum(decode(nvl(um.photo_thumbnail.contentlength,0),0,0,1)) numb_ph_thmb,
         sum(nvl(um.photo_thumbnail.contentlength,0)) size_ph_thmb,
         sum(decode(nvl(um.photo_backup.contentlength,0),0,0,1)) numb_ph_back,
         sum(nvl(um.photo_backup.contentlength,0)) size_ph_back,
         sum(decode(nvl(um.audio_original.description,0),0,0,1)) numb_aud_orig,
         sum(nvl(um.audio_original.description,0)) size_aud_orig,
         sum(decode(nvl(um.doc_length,0),0,0,1)) numb_doc_orig,
         sum(nvl(um.doc_length,0)) size_doc_orig,
         sum(decode(nvl(um.video_original.description,0),0,0,1)) numb_vid_orig,
         sum(nvl(um.video_original.description,0)) size_vid_orig,
         sum(decode(nvl(um.blueprint_obj.blueprint_length,0),0,0,1)) numb_bp_orig,
         sum(nvl(um.blueprint_obj.blueprint_length,0)) size_bp_orig,
         sum(decode(nvl(um.blueprint_obj.online_length,0),0,0,1)) numb_bp_online,
         sum(nvl(um.blueprint_obj.online_length,0)) size_bp_online
  from umo um, customer_account ca
  where ca.aid = um.aid and
        umo_type in ('PHOTO','DOCUMENT','AUDIO','VIDEO','RELATIONAL','BLUEPRINT') and
        umo_owner = owner_type and
        ((acid is not null and ca.aid = acid and um.aid = acid) or (acid is null)) and
        ca.pid = phgr;


  ca_rec	c1%ROWTYPE;
  cb_rec	c4%ROWTYPE;

begin

 open c3( owner_id, acid );
 fetch c3 into ca_rec;
 close c3;
 quota.plan_style := ca_rec.payment_style;
 quota.plan_name := ca_rec.plan_name;
 quota.renewal := ca_rec.renewal_date;
 quota.max_photo_size := ca_rec.max_photo_size;
 quota.max_photos := ca_rec.max_photos;
 quota.max_storage := ca_rec.max_storage;

 if owner_type = 'PHOTOGRAPHER'
  then
   open c5( owner_id, owner_type, acid );
   fetch c5 into cb_rec;
   close c5;
  else
    if owner_type = 'OWNER' and ca_rec.owner_plan_id is not null
     then
      open c1( ca_rec.owner_plan_id );
      fetch c1 into ca_rec;
      close c1;
     elsif ca_rec.cust_plan_id is not null
      then
       open c1( ca_rec.cust_plan_id );
       fetch c1 into ca_rec;
       close c1;
    end if;
   open c4( owner_id, owner_type );
   fetch c4 into cb_rec;
   close c4;
 end if;

 quota.plan_style := nvl(ca_rec.payment_style,quota.plan_style);
 quota.plan_name := nvl(ca_rec.plan_name,quota.plan_name);
 quota.renewal := nvl(ca_rec.renewal_date,quota.renewal);
 quota.max_photo_size := nvl(ca_rec.max_photo_size,quota.max_photo_size);
 quota.max_photos := nvl(ca_rec.max_photos,quota.max_photos);
 quota.max_storage := nvl(ca_rec.max_storage,quota.max_storage);

 quota.total_used := nvl(cb_rec.tot,0);
 quota.total_asset := nvl(cb_rec.cnt,0);
 quota.numb_ph_orig := cb_rec.numb_ph_orig;
 quota.size_ph_orig := cb_rec.size_ph_orig;
 quota.numb_ph_web := cb_rec.numb_ph_web;
 quota.size_ph_web := cb_rec.size_ph_web;
 quota.numb_ph_thmb := cb_rec.numb_ph_thmb;
 quota.size_ph_thmb := cb_rec.size_ph_thmb;
 quota.numb_ph_back := cb_rec.numb_ph_back;
 quota.size_ph_back := cb_rec.size_ph_back;
 quota.numb_doc_orig := cb_rec.numb_doc_orig;
 quota.size_doc_orig := cb_rec.size_doc_orig;
 quota.numb_aud_orig := cb_rec.numb_aud_orig;
 quota.size_aud_orig := cb_rec.size_aud_orig;
 quota.numb_vid_orig := cb_rec.numb_vid_orig;
 quota.size_vid_orig := cb_rec.size_vid_orig;
 quota.numb_bp_orig := cb_rec.numb_bp_orig;
 quota.size_bp_orig := cb_rec.size_bp_orig;
 quota.numb_bp_online := cb_rec.numb_bp_online;
 quota.size_bp_online := cb_rec.size_bp_online;

exception when others then
 glbx.error_details( 'UMP', 'GET_QUOTA',errmsg=>sqlerrm,extdet=>'OWNER_TYPE:' || owner_type || ' OWNER_ID:' || owner_id);
end get_quota;

function acct_details(surl varchar2,owner_id in integer, acid in integer)
 return varchar2
as
 cursor c1( phgr integer, acid integer, owner_type varchar2 ) is
  select round(sum( nvl(um.photo_original.contentlength,0) )/1024) ph_orig_sze,
         sum( decode(nvl(um.photo_original.contentlength,0),0,0,1) ) ph_orig_cnt,
         round(sum( nvl(um.photo_master.contentlength,0) )/1024) ph_mast_sze,
         sum( decode(nvl(um.photo_master.contentlength,0),0,0,1) ) ph_mast_cnt,
         round(sum( nvl(um.photo_thumbnail.contentlength,0) )/1024) ph_thumb_sze,
         sum( decode(nvl(um.photo_thumbnail.contentlength,0),0,0,1) ) ph_thumb_cnt,
         round(sum( nvl(um.photo_backup.contentlength,0) )/1024) ph_back_sze,
         sum( decode(nvl(um.photo_backup.contentlength,0),0,0,1) ) ph_back_cnt
  from umo um, customer_account ca
  where ca.aid = um.aid and
        umo_owner = owner_type and
        ca.pid = phgr and
        ((acid is not null and ca.aid = acid) or (acid is null));

 c1rec	c1%ROWTYPE;
 msg	varchar2(2000);
begin
 open c1(owner_id,acid,'PHOTOGRAPHER' );
 fetch c1 into c1rec;
 close c1;
 msg := msg || htf.tablerowopen || htf.tabledata( LNG2.UMP_TXT_026 ) || htf.tabledata( htf.bold( c1rec.ph_orig_sze ) ) || htf.tablerowclose;
 msg := msg || htf.tablerowopen || htf.tabledata( LNG2.UMP_TXT_027 ) || htf.tabledata( htf.bold( c1rec.ph_orig_cnt ) ) || htf.tablerowclose;
 msg := msg || htf.tablerowopen || htf.tabledata( LNG2.UMP_TXT_028 ) || htf.tabledata( htf.bold( c1rec.ph_mast_sze ) ) || htf.tablerowclose;
 msg := msg || htf.tablerowopen || htf.tabledata( LNG2.UMP_TXT_029 ) || htf.tabledata( htf.bold( c1rec.ph_mast_cnt ) ) || htf.tablerowclose;
 msg := msg || htf.tablerowopen || htf.tabledata( LNG2.UMP_TXT_030 ) || htf.tabledata( htf.bold( c1rec.ph_back_sze ) ) || htf.tablerowclose;
 msg := msg || htf.tablerowopen || htf.tabledata( LNG2.UMP_TXT_031 ) || htf.tabledata( htf.bold( c1rec.ph_back_cnt ) ) || htf.tablerowclose;
 msg := msg || htf.tablerowopen || htf.tabledata( LNG2.UMP_TXT_032 ) || htf.tabledata( htf.bold( c1rec.ph_thumb_sze ) ) || htf.tablerowclose;
 msg := msg || htf.tablerowopen || htf.tabledata( LNG2.UMP_TXT_033 ) || htf.tabledata( htf.bold( c1rec.ph_thumb_cnt ) ) || htf.tablerowclose;

 return( msg );
exception when others then
 glbx.error_details( 'UMP', 'ACCT_DETAILS',errmsg=>sqlerrm,extdet=>'OWNER_TYPE:' || acid || ' OWNER_ID:' || owner_id);
end acct_details;


function scene_subcategory( v_umo in integer)
 return varchar2
as
begin
 null;
end scene_subcategory;

function scene_title( scene_id in integer, scene_ord out integer)
 return varchar2
as
 cursor c1(scene_id integer) is select title,order_by from umo_scene where umo_scene_id = scene_id;
 retvar	varchar2(100);
begin
 open c1(scene_id);
 fetch c1 into retvar,scene_ord;
 close c1;
 return( retvar );
end scene_title;

function retrieve_scenes( surl varchar2,v_owner_id in integer, v_owned_by in varchar2, v_category in varchar2, v_phgr in integer, v_parent_id in integer default null, v_title_id in integer default NULL, display_style in varchar2 default 'LIST' )
 return varchar2
as
 cursor c1(v_category varchar2, v_owned_by varchar2, v_owner_id integer, v_parent_id integer) is

  select umo_scene_id,owned_by,order_by,title
  from umo_scene
  where nvl(parent_scene,0) = nvl(v_parent_id,0) and
        ((owned_by = 'PUBLIC') or
         (owned_by = v_owned_by and owner_id = v_owner_id and v_owned_by = 'PHOTOGRAPHER') or
         (owned_by = v_owned_by and owner_id = v_owner_id  and v_owned_by = 'OWNER') or
         (owned_by = 'PHOTOGRAPHER' and owner_id = v_phgr and v_owned_by = 'OWNER')) and
         category = v_category
  order by order_by;

 retvar	varchar2(8000);
begin
 for c1rec in c1(v_category, v_owned_by, v_owner_id, v_parent_id) loop
  if display_style = 'LIST'
   then
    if c1rec.umo_scene_id = nvl(v_title_id,0)
     then
      retvar := retvar || htf.formselectoption( c1rec.title, 'SELECTED', cattributes=>'VALUE="' || c1rec.umo_scene_id || '"'  );
     else
      retvar := retvar || htf.formselectoption( c1rec.title, cattributes=>'VALUE="' || c1rec.umo_scene_id || '"' );
    end if;
  elsif display_style = 'LISTALL'
   then
    if c1rec.umo_scene_id = nvl(v_title_id,0)
     then
      htp.formselectoption( c1rec.title, 'SELECTED', cattributes=>'VALUE="' || c1rec.umo_scene_id || '"'  );
     else
      htp.formselectoption( c1rec.title, cattributes=>'VALUE="' || c1rec.umo_scene_id || '"' );
    end if;
  elsif display_style = 'TABLE'
    then
      htp.tablerowopen;
       if (c1rec.owned_by = 'PUBLIC') or (c1rec.owned_by = 'PHOTOGRAPHER' and v_owned_by = 'OWNER')
        then
          htp.tabledata( c1rec.owned_by,cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
          htp.tabledata( htf.bold( c1rec.order_by ),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
          htp.tabledata( htf.italic( nvl(c1rec.title,LNG.GLB_TXT_136) ),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
        else
          htp.formhidden( 'P3', c1rec.umo_scene_id );
          htp.tabledata( c1rec.owned_by,cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
          htp.tabledata( htf.formtext( 'P1', 10, 20, c1rec.order_by ),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
          htp.tabledata( htf.formtext( 'P2', 20, 100, c1rec.title ),cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" align="LEFT"');
       end if;
      htp.tablerowclose;
  end if;
  retvar := retvar || retrieve_scenes( surl, v_owner_id, v_owned_by, v_category, v_phgr, c1rec.umo_scene_id, v_title_id );
 end loop;
 return( retvar );
exception when others then
 glbx.error_details( 'UMP', 'RETRIEVE_ERRORS',errmsg=>sqlerrm,extdet=>'V_OWNER_ID:' || v_owner_id || ' V_OWNER_BY:' || v_owned_by);
 return( NULL );
end retrieve_scenes;

procedure create_scene( v_category in varchar2, v_title in varchar2, v_owner in varchar2, v_ordering in varchar2, v_owner_id in integer, v_parent_id in integer default null )
as
 v_umo 	integer;
begin
 select s_umo_scene.nextval into v_umo from dual;
 insert into umo_scene (umo_scene_id, category, parent_scene, owned_by, owner_id, order_by, title ) values
  (v_umo, v_category, v_parent_id, v_owner, v_owner_id, v_ordering, v_title );
 commit;
end create_scene;

function check_ignore( checkval in varchar2, ignore_str in varchar2, infloop in integer default 0 )
 return boolean
as
 x	integer;
 y	integer;
 z	integer;
 nmb1	integer;
 nmb2	integer;
 tmp	varchar2(100);
begin
 -- Search for a dash, comma or end of line
  if infloop = 1000 then htp.p('Infloop: +'|| ignore_str || '+'); htp.nl; return( FALSE ); end if;
  if ignore_str is null then return( TRUE ); end if;
  x := instr(ignore_str,'-');
  y := instr(ignore_str,',');
  z := length(ignore_str);
  if z = 0 then RETURN(TRUE); end if;
  if (x=0) and(y=0)
   then
    if ignore_str = checkval then return( FALSE ); else return( TRUE ); end if;
  end if;

  if ((y < x) and (y <> 0) and (x <> 0) ) or ( (y <> 0) and (x = 0) )
   then
    tmp := substr(ignore_str,1,y-1);
    if length(tmp) = 0 then return( check_ignore( checkval, substr(ignore_str,y+1),infloop+1)); end if;
    if checkval = tmp then return( FALSE ); else return( check_ignore( checkval, substr(ignore_str,y+1),infloop+1)); end if;
  end if;

  -- Check for Dash
  if (y = 0)
   then
    z := length(ignore_str)+1;
   else
    z := y;
  end if;
  tmp := substr(ignore_str,1,z-1);
  begin nmb1 := to_number(substr(tmp,1,x-1)); exception when others then nmb1 := 0; end;
  begin nmb2 := to_number(substr(tmp,x+1)); exception when others then nmb2 := 0; end;
  if to_number(checkval) >= nmb1 and to_number(checkval) <= nmb2
    then
     return( FALSE );
    else
     return( check_ignore(checkval, substr(ignore_str,z+1),infloop+1) );
  end if;
 return( TRUE );
exception
 when others then return( TRUE );
end check_ignore;

procedure manufacturer_search_phg( surl varchar2, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null, query_date in date default SYSDATE-10000, sec_details in SECURITY_DETAILS default empty_sec )
as

 cursor c1(qry varchar2, acid integer, phgid integer, ltype varchar2, sess_id integer) is
  select *
  from manufacturer_search
  where src_name = qry and
        nvl(aid,0) = nvl(acid,0) and
        login_type = ltype and
        pid = phgid and
        ((ltype in ('CUSTOMER','PROFILEG') and (sessid = sess_id)) or (ltype in ('PHOTOGRAPHER','OWNER','PROFILE') ) )
  order by order_by;

 cursor c1_mfc(acid integer, ltype in varchar2, profid in integer, scene_id integer, keyword varchar2, isgbl char, pb in integer, bid integer, lc number, hc number, clause varchar2, ignlbox char, sess_id integer, query_date date) is
   select um.umo_id
   from umo_index ui, umo_attribute ut, umo um, umo_attributes uts, phg_price_item ppi
   where um.umo_id = ui.umo_id and
         um.aid = ui.aid and
         um.date_created > query_date and
         um.aid = acid and
         (um.umo_scene_id = scene_id or scene_id = 0) and
         nvl(nvl(bid,ppi.brand_id),0) = nvl(nvl(bid,ppi.brand_id),0) and
         nvl(lc,ppi.charge) >= ppi.charge and
         nvl(hc,ppi.charge) <= ppi.charge and
         ppi.spb = pb and
         ppi.shop_item = 'F' and
         um.is_global = isgbl and
         ui.attribute_id = ut.attribute_id and
         ut.attribute_id = uts.attribute_id and
         ( (ltype not in ('PROFILE','PROFILEG')) or
           (ltype in ('PROFILE','PROFILEG') and not exists (select count('x') tot from profile_scenes where profile_id = profid ) ) or
           (ltype in ('PROFILE','PROFILEG') and um.umo_scene_id in (select umo_scene_id from profile_scenes where profile_id = profid ) )
         ) and
         um.umo_id = ut.umo_id and
         ui.umo_id = ut.umo_id and
         ((ignlbox = 'F') or (ignlbox = 'T' and um.umo_id not in (select umo_id from lightbox where sessid = sess_id))) and
         uts.umo_type in ('PHOTO','DOCUMENT','AUDIO','VIDEO','RELATIONAL','BLUEPRINT') and
         uts.queryable = 'T' and
         decode(clause, LNG.PHG_TXT_505,ui.word_upper,LNG.PHG_TXT_507,ui.word_original,LNG.PHG_TXT_508,ui.word_soundex,ui.word_upper) like
          decode(clause, LNG.PHG_TXT_505,upper(keyword),LNG.PHG_TXT_507,keyword,LNG.PHG_TXT_508,soundex_api(keyword,uts.attribute_id),upper(keyword) || '%' )
   union all
    select ppi.umo_id
    from phg_price_item ppi
    where shop_item = 'T' and
          spb = pb and
          nvl(nvl(bid,ppi.brand_id),0) = nvl(nvl(bid,ppi.brand_id),0) and
          nvl(lc,ppi.charge) >= ppi.charge and
          nvl(hc,ppi.charge) <= ppi.charge and
          decode(clause, LNG.PHG_TXT_505,upper(ppi.name),LNG.PHG_TXT_507,ppi.name,LNG.PHG_TXT_508,soundex(ppi.name),upper(ppi.name)) like
           decode(clause, LNG.PHG_TXT_505,upper(keyword),LNG.PHG_TXT_507,keyword,LNG.PHG_TXT_508,soundex(keyword),upper(keyword) || '%' )
   order by 1;

 cursor c1_mfc_tot(acid integer, ltype in varchar2, profid in integer, scene_id integer, keyword varchar2, isgbl char, pb in integer, bid integer, lc number, hc number, clause varchar2, ignlbox char, sess_id integer, query_date date) is
  select /*+ ALL_ROWS */ count(umo_id)
  from
  (
   select um.umo_id
   from umo_index ui, umo_attribute ut, umo um, umo_attributes uts, phg_price_item ppi
   where um.umo_id = ui.umo_id and
         um.aid = ui.aid and
         um.date_created > query_date and
         um.aid = acid and
         (um.umo_scene_id = scene_id or scene_id = 0) and
         nvl(nvl(bid,ppi.brand_id),0) = nvl(nvl(bid,ppi.brand_id),0) and
         nvl(lc,ppi.charge) >= ppi.charge and
         nvl(hc,ppi.charge) <= ppi.charge and
         ppi.spb = pb and
         ppi.shop_item = 'F' and
         um.is_global = isgbl and
         ui.attribute_id = ut.attribute_id and
         ut.attribute_id = uts.attribute_id and
         ( (ltype not in ('PROFILE','PROFILEG')) or
           (ltype in ('PROFILE','PROFILEG') and not exists (select count('x') tot from profile_scenes where profile_id = profid ) ) or
           (ltype in ('PROFILE','PROFILEG') and um.umo_scene_id in (select umo_scene_id from profile_scenes where profile_id = profid ) )
         ) and
         um.umo_id = ut.umo_id and
         ui.umo_id = ut.umo_id and
         ((ignlbox = 'F') or (ignlbox = 'T' and um.umo_id not in (select umo_id from lightbox where sessid = sess_id))) and
         uts.umo_type in ('PHOTO','DOCUMENT','AUDIO','VIDEO','RELATIONAL','BLUEPRINT') and
         uts.queryable = 'T' and
         decode(clause, LNG.PHG_TXT_505,ui.word_upper,LNG.PHG_TXT_507,ui.word_original,LNG.PHG_TXT_508,ui.word_soundex,ui.word_upper) like
          decode(clause, LNG.PHG_TXT_505,upper(keyword),LNG.PHG_TXT_507,keyword,LNG.PHG_TXT_508,soundex_api(keyword,uts.attribute_id),upper(keyword) || '%' )
   union all
    select ppi.umo_id
    from phg_price_item ppi
    where shop_item = 'T' and
          spb = pb and
          nvl(nvl(bid,ppi.brand_id),0) = nvl(nvl(bid,ppi.brand_id),0) and
          nvl(lc,ppi.charge) >= ppi.charge and
          nvl(hc,ppi.charge) <= ppi.charge and
          decode(clause, LNG.PHG_TXT_505,upper(ppi.name),LNG.PHG_TXT_507,ppi.name,LNG.PHG_TXT_508,soundex(ppi.name),upper(ppi.name)) like
           decode(clause, LNG.PHG_TXT_505,upper(keyword),LNG.PHG_TXT_507,keyword,LNG.PHG_TXT_508,soundex(keyword),upper(keyword) || '%' )
  );

 cursor c3(v_umo integer) is select * from umo um where umo_id = v_umo;
 cursor c4(void integer) is select spb from order_style where oid = void;
 cursor c5(stm varchar2) is
  select term tm from dictionary where term like stm || '%' and association_type = 'D'
  union
  select association tm from dictionary where association_type = 'A' and term = stm;
 cursor c7( sess_id integer) is select aid,pid from customer_account where aid = (select aid from login_session where sessid = sess_id);
 cursor c7a( sess_id integer) is select aid,pid from customer_profile where profile_id = (select aid from login_session where sessid = sess_id);
 cursor c11( acid integer ) is select * from customer_account where aid = acid;

 c1rec		c1%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c11rec		c11%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 spb		integer;
 sts		varchar2(100);
 last_clause	varchar2(20);
 ctr		integer;
 ntot		integer;
 profid		integer;
 isgbl		char(1);
 totrec		integer;
 totrecx	integer;
 check_gbl	integer;
 numb_photos	integer;
 maxret         integer;
 void		integer;
 b2c_value	char(1);
 result_list	UMP.SEARCH_RESULT_PHG;

begin
 if sec_details.ltype is null
  then
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'UMP.MANUFACTURER_SEARCH_PHG', reset=>FALSE );
   if sts is not null
    then
      glbx.redisplay_login_page( sts, TRUE );
      return;
   end if;
 end if;

 if sec_details.ltype is null
  then
   c11rec := glbx.get_cusrec( owner_id, ltype, substr(left_api_parm,2,instr(left_api_parm,']')-2), profid );
  else
   ltype := sec_details.ltype;
   profid := sec_details.profid;
   c11rec.pid := sec_details.pid;
   c11rec.aid := sec_details.aid;
 end if;

 maxret := nvl(to_number(glbx.userpref(c11rec.pid,c11rec.aid,'SRC')),100);
 begin numb_photos := glbx.saved_preference_value(acid, profid, ltype, 'DISPLAY_NUMBER' ); exception when others then numb_photos := NULL; end;

 if numb_photos is null
  then
   if ltype = 'PHOTOGRAPHER'
    then
     numb_photos := to_number(glbx.photo_pref(c11rec.pid,c11rec.aid,'PHOTO_DISPLAY'));
     numb_photos := nvl(numb_photos,10);
    else
     numb_photos := to_number(glbx.photo_pref(c11rec.pid,c11rec.aid,'NUMBER_PHOTOS'));
     numb_photos := nvl(numb_photos,10);
   end if;
 end if;

 open c1(substr(left_api_parm,instr(left_api_parm,']')+1),c11rec.aid,c11rec.pid,ltype,owner_id);
 fetch c1 into c1rec;
 close c1;
 void := glbx.get_order_style(c11rec.aid, profid, ltype, b2c_value);
 open c4(void);
 fetch c4 into spb;
 close c4;

 ctr := 0;
 /*
 htp.p( acid || '-' || c1rec.umo_scene_id || '-' || c1rec.keyword || '-' || c1rec.is_global );
 htp.nl;
 htp.p(spb || '-' || c1rec.brand || '-' || c1rec.price_from || '-' || c1rec.price_to || '-' || c1rec.clause );
 htp.nl;
 htp.bold( 'Results2:' ); htp.nl;
 */

 totrec := 0;
 if c1rec.stem = 'T'
  then
   for c5rec in c5(upper(c1rec.keyword)) loop
    for cmfc_rec in c1_mfc(c11rec.aid, ltype, profid, c1rec.umo_scene_id, c5rec.tm, c1rec.is_global, spb, c1rec.brand, c1rec.price_from, c1rec.price_to, c1rec.clause, c1rec.ignore_lightbox, owner_id, query_date) loop
     open c3(cmfc_rec.umo_id);
     fetch c3 into c3rec;
     close c3;
     -- htp.bold(cmfc_rec.umo_id); htp.nl;
     ctr := ctr + 1;
    if ctr < start_from
     then
      null;
     else
      if ctr >= (start_from + numb_photos) or ctr >= maxret
       then
        exit;
       else
        result_list(ctr) := c3rec;
        if ctr >= maxret then exit; end if;
      end if;
    end if;
    end loop;
    -- Calculate total number of records
    -- Continue looping through stem search to work out real total
    if ctr >= maxret
     then
      totrec := maxret;
     else
      open c1_mfc_tot(c11rec.aid, ltype, profid, c1rec.umo_scene_id, c1rec.keyword, c1rec.is_global, spb, c1rec.brand, c1rec.price_from, c1rec.price_to, c1rec.clause, c1rec.ignore_lightbox,owner_id,query_date);
      fetch c1_mfc_tot into totrecx;
      close c1_mfc_tot;
    end if;
    totrec := totrec + totrecx;
   end loop;
  else
   if totrec > maxret then totrec := maxret; end if;
   for cmfc_rec in c1_mfc(c11rec.aid, ltype, profid, c1rec.umo_scene_id, c1rec.keyword, c1rec.is_global, spb, c1rec.brand, c1rec.price_from, c1rec.price_to, c1rec.clause, c1rec.ignore_lightbox,owner_id,query_date) loop
    open c3(cmfc_rec.umo_id);
    fetch c3 into c3rec;
    close c3;
    -- htp.bold(cmfc_rec.umo_id); htp.nl;
    ctr := ctr + 1;
    if ctr < start_from
     then
      null;
     else
      if ctr >= (start_from + numb_photos) or ctr >= maxret
       then
        exit;
       else
        result_list(ctr) := c3rec;
        if ctr >= maxret then exit; end if;
      end if;
    end if;
   end loop;
   -- Calculate total number of records
   if ctr >= maxret
    then
     totrec := maxret;
    else
     open c1_mfc_tot(c11rec.aid, ltype, profid, c1rec.umo_scene_id, c1rec.keyword, c1rec.is_global, spb, c1rec.brand, c1rec.price_from, c1rec.price_to, c1rec.clause, c1rec.ignore_lightbox,owner_id,query_date);
     fetch c1_mfc_tot into totrec;
     close c1_mfc_tot;
     if totrec > maxret then totrec := maxret; end if;
   end if;
 end if;

 update manufacturer_search
  set
   date_updated = sysdate,
   rows_returned = nvl(totrec,0)
 where
  src_name = substr(left_api_parm,instr(left_api_parm,']')+1) and
  nvl(aid,0) = nvl(c11rec.aid,0) and
  pid = c11rec.pid and
  ((ltype in ('CUSTOMER','PROFILEG') and (sessid = owner_id)) or (ltype in ('PHOTOGRAPHER','OWNER','PROFILE') ) );

 if sec_details.ltype is null
  then
   glbx.extended_search_api( surl, ltype, result_list, totrec,
                             display_detail, title=>LNG.GLB_TXT_100, help_file_code=>NULL,
                             left_api=>NULL, left_api_parm=>left_api_parm, footer_api=>'ump.manufacturer_search_phg',
                             current_page_number=>start_from,no_results_message=>LNG.PHG_ALT_388,acid=>acid) ;
  else
   new_images_email( sec_details, result_list, totrec );
 end if;

exception when others then
 glbx.error_details( 'UMP', 'MANUFACTURER_SEARCH_PHG',errmsg=>sqlerrm);
end manufacturer_search_phg;

procedure advanced_search_phg( surl varchar2, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null, query_date in date default SYSDATE-10000, sec_details in SECURITY_DETAILS default empty_sec, ctx in char default 'F' )
as

 cursor c1(qry varchar2, acid integer, phgid integer, ltype varchar2, sess_id integer, query_date date) is
  select *
  from advanced_search
  where src_name = qry and
        nvl(aid,0) = nvl(acid,0) and
        login_type = ltype and
        ((pid = phgid and ltype = 'PHOTOGRAPHER') or (pid = 0 and ltype in ('OWNER','PROFILE','CUSTOMER','PROFILEG'))) and
        ((ltype in ('CUSTOMER','PROFILEG') and (sessid = sess_id)) or (ltype in ('PHOTOGRAPHER','OWNER','PROFILE') ) )
  order by order_by;

 cursor c1_standard_scene(acid integer, scene_id integer, keyword varchar2,isgbl char, query_date date, img_age integer, cpx varchar2, pdim char, psorton char, ltype varchar2 ) is
   select /*+ ALL_ROWS */ um.umo_id,
          decode(substr(psorton,1,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) ||
          decode(substr(psorton,2,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) ||
          decode(substr(psorton,3,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) sorton
   from umo_index ui, umo_attribute ut, umo um, umo_attributes uts
   where um.umo_id = ui.umo_id and
         um.aid = ui.aid and
         um.date_created > query_date and
         um.aid = acid and
         ((( cpx is not null) and instr(',' || cpx || ',' , ',' || um.umo_scene_id || ',') > 0) or
          (( cpx is null) and (um.umo_scene_id = scene_id))
         ) and
         um.is_global = isgbl and
         ui.attribute_id = ut.attribute_id and
         ut.attribute_id = uts.attribute_id and
         um.umo_id = ut.umo_id and
         ui.umo_id = ut.umo_id and
         um.date_created + img_age >= sysdate and
         uts.umo_type in ('PHOTO','DOCUMENT','AUDIO','VIDEO','RELATIONAL','BLUEPRINT') and
         uts.queryable = 'T' and
         ((pdim = 'A') or (pdim = 'P' and nvl(um.photo_master.height,0) >= nvl(um.photo_master.width,0)) or (pdim = 'L' and nvl(um.photo_master.height,0) <= nvl(um.photo_master.width,0)) or (pdim = 'S' and nvl(um.photo_master.height,0) = nvl(um.photo_master.width,0)) ) and
         (ui.word_upper = upper(keyword)) and
         ((ltype = 'PHOTOGRAPHER') or
          ((ltype = 'OWNER' or ltype = 'PROFILE') and um.extras.enabled_phg='TRUE') or
          ((ltype = 'CUSTOMER' or ltype = 'PROFILG') and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE'))
   order by um.umo_id;

 cursor c1_exact_scene(acid integer, scene_id integer, keyword varchar2,isgbl char, query_date date, img_age integer, cpx varchar2, pdim char, psorton char, ltype varchar2) is
   select /*+ ALL_ROWS */ um.umo_id,
          decode(substr(psorton,1,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) ||
          decode(substr(psorton,2,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) ||
          decode(substr(psorton,3,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) sorton
   from umo_index ui, umo_attribute ut, umo um, umo_attributes uts
   where um.umo_id = ui.umo_id and
         um.aid = ui.aid and
         um.aid = acid and
         um.date_created > query_date and
         ((( cpx is not null) and instr(',' || cpx || ',' , ',' || um.umo_scene_id || ',') > 0) or
          (( cpx is null) and (um.umo_scene_id = scene_id))
         ) and
         um.is_global = isgbl and
         ui.attribute_id = ut.attribute_id and
         ut.attribute_id = uts.attribute_id and
         um.umo_id = ut.umo_id and
         um.date_created + img_age >= sysdate and
         ui.umo_id = ut.umo_id and
         uts.umo_type in ('PHOTO','DOCUMENT','AUDIO','VIDEO','RELATIONAL','BLUEPRINT') and
         uts.queryable = 'T' and
         ((pdim = 'A') or (pdim = 'P' and nvl(um.photo_master.height,0) >= nvl(um.photo_master.width,0)) or (pdim = 'L' and nvl(um.photo_master.height,0) <= nvl(um.photo_master.width,0)) or (pdim = 'S' and nvl(um.photo_master.height,0) = nvl(um.photo_master.width,0)) ) and
         (ui.word_original = keyword) and
         ((ltype = 'PHOTOGRAPHER') or
          ((ltype = 'OWNER' or ltype = 'PROFILE') and um.extras.enabled_phg='TRUE') or
          ((ltype = 'CUSTOMER' or ltype = 'PROFILG') and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE'))
   order by um.umo_id;

 cursor c1_sounds_scene(acid integer, scene_id integer, keyword varchar2, isgbl char, query_date date, img_age integer, cpx varchar2, pdim char, psorton char, ltype varchar2) is
   select /*+ ALL_ROWS */ um.umo_id,
          decode(substr(psorton,1,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) ||
          decode(substr(psorton,2,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) ||
          decode(substr(psorton,3,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) sorton
   from umo_index ui, umo_attribute ut, umo um, umo_attributes uts
   where um.umo_id = ui.umo_id and
         um.aid = ui.aid and
         um.aid = acid and
         um.date_created > query_date and
         ((( cpx is not null) and instr(',' || cpx || ',' , ',' || um.umo_scene_id || ',') > 0) or
          (( cpx is null) and (um.umo_scene_id = scene_id))
         ) and
         um.is_global = isgbl and
         ui.attribute_id = ut.attribute_id and
         ut.attribute_id = uts.attribute_id and
         um.umo_id = ut.umo_id and
         um.date_created + img_age >= sysdate and
         ui.umo_id = ut.umo_id and
         uts.umo_type in ('PHOTO','DOCUMENT','AUDIO','VIDEO','RELATIONAL','BLUEPRINT') and
         uts.queryable = 'T' and
         ((pdim = 'A') or (pdim = 'P' and nvl(um.photo_master.height,0) >= nvl(um.photo_master.width,0)) or (pdim = 'L' and nvl(um.photo_master.height,0) <= nvl(um.photo_master.width,0)) or (pdim = 'S' and nvl(um.photo_master.height,0) = nvl(um.photo_master.width,0)) ) and
         (ui.word_soundex = keyword) and
         ((ltype = 'PHOTOGRAPHER') or
          ((ltype = 'OWNER' or ltype = 'PROFILE') and um.extras.enabled_phg='TRUE') or
          ((ltype = 'CUSTOMER' or ltype = 'PROFILG') and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE'))
   order by um.umo_id;

 cursor c1_starts_scene(acid integer, scene_id integer, keyword varchar2,isgbl char, query_date date, img_age integer, cpx varchar2, pdim char, psorton char, ltype varchar2) is
   select /*+ ALL_ROWS */ um.umo_id,
          decode(substr(psorton,1,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) ||
          decode(substr(psorton,2,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) ||
          decode(substr(psorton,3,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) sorton
   from umo_index ui, umo_attribute ut, umo um, umo_attributes uts
   where um.umo_id = ui.umo_id and
         um.aid = ui.aid and
         um.aid = acid and
         um.date_created > query_date and
         ((( cpx is not null) and instr(',' || cpx || ',' , ',' || um.umo_scene_id || ',') > 0) or
          (( cpx is null) and (um.umo_scene_id = scene_id))
         ) and
         ui.attribute_id = ut.attribute_id and
         um.is_global = isgbl and
         ut.attribute_id = uts.attribute_id and
         um.umo_id = ut.umo_id and
         um.date_created + img_age >= sysdate and
         ui.umo_id = ut.umo_id and
         uts.umo_type in ('PHOTO','DOCUMENT','AUDIO','VIDEO','RELATIONAL','BLUEPRINT') and
         uts.queryable = 'T' and
         ((pdim = 'A') or (pdim = 'P' and nvl(um.photo_master.height,0) >= nvl(um.photo_master.width,0)) or (pdim = 'L' and nvl(um.photo_master.height,0) <= nvl(um.photo_master.width,0)) or (pdim = 'S' and nvl(um.photo_master.height,0) = nvl(um.photo_master.width,0)) ) and
         (ui.word_upper like upper(keyword) || '%') and
         ((ltype = 'PHOTOGRAPHER') or
          ((ltype = 'OWNER' or ltype = 'PROFILE') and um.extras.enabled_phg='TRUE') or
          ((ltype = 'CUSTOMER' or ltype = 'PROFILG') and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE'))
   order by um.umo_id;

  cursor c1_standard_noscene(acid integer, keyword varchar2,isgbl char, query_date date, img_age integer, pdim char, psorton char, ltype varchar2) is
   select /*+ ALL_ROWS */ um.umo_id,
          decode(substr(psorton,1,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) ||
          decode(substr(psorton,2,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) ||
          decode(substr(psorton,3,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) sorton
   from umo_index ui, umo_attribute ut, umo um, umo_attributes uts
   where um.umo_id = ui.umo_id and
         um.aid = ui.aid and
         um.date_created > query_date and
         um.aid = acid and
         um.umo_id = ut.umo_id and
         um.is_global = isgbl and
         ui.attribute_id = ut.attribute_id and
         ut.attribute_id = uts.attribute_id and
         um.date_created + img_age >= sysdate and
         ui.umo_id = ut.umo_id and
         uts.umo_type in ('PHOTO','DOCUMENT','AUDIO','VIDEO','RELATIONAL','BLUEPRINT') and
         uts.queryable = 'T' and
         ((pdim = 'A') or (pdim = 'P' and nvl(um.photo_master.height,0) >= nvl(um.photo_master.width,0)) or (pdim = 'L' and nvl(um.photo_master.height,0) <= nvl(um.photo_master.width,0)) or (pdim = 'S' and nvl(um.photo_master.height,0) = nvl(um.photo_master.width,0)) ) and
         (ui.word_upper = upper(keyword)) and
         ((ltype = 'PHOTOGRAPHER') or
          ((ltype = 'OWNER' or ltype = 'PROFILE') and um.extras.enabled_phg='TRUE') or
          ((ltype = 'CUSTOMER' or ltype = 'PROFILG') and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE'))
   order by um.umo_id;

  cursor c1_exact_noscene(acid integer, keyword varchar2,isgbl char, query_date date, img_age integer, pdim char, psorton char, ltype varchar2) is
   select /*+ ALL_ROWS */ um.umo_id,
          decode(substr(psorton,1,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) ||
          decode(substr(psorton,2,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) ||
          decode(substr(psorton,3,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) sorton
   from umo_index ui, umo_attribute ut, umo um, umo_attributes uts
   where um.umo_id = ui.umo_id and
         um.aid = ui.aid and
         um.aid = acid and
         um.date_created > query_date and
         um.umo_id = ut.umo_id and
         um.is_global = isgbl and
         ui.attribute_id = ut.attribute_id and
         ut.attribute_id = uts.attribute_id and
         um.date_created + img_age >= sysdate and
         ui.umo_id = ut.umo_id and
         uts.umo_type in ('PHOTO','DOCUMENT','AUDIO','VIDEO','RELATIONAL','BLUEPRINT') and
         uts.queryable = 'T' and
         ((pdim = 'A') or (pdim = 'P' and nvl(um.photo_master.height,0) >= nvl(um.photo_master.width,0)) or (pdim = 'L' and nvl(um.photo_master.height,0) <= nvl(um.photo_master.width,0)) or (pdim = 'S' and nvl(um.photo_master.height,0) = nvl(um.photo_master.width,0)) ) and
         (ui.word_original = keyword) and
         ((ltype = 'PHOTOGRAPHER') or
          ((ltype = 'OWNER' or ltype = 'PROFILE') and um.extras.enabled_phg='TRUE') or
          ((ltype = 'CUSTOMER' or ltype = 'PROFILG') and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE'))
   order by um.umo_id;

  cursor c1_sounds_noscene(acid integer, keyword varchar2,isgbl char, query_date date, img_age integer, pdim char, psorton char, ltype varchar2) is
   select /*+ ALL_ROWS */ um.umo_id,
          decode(substr(psorton,1,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) ||
          decode(substr(psorton,2,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) ||
          decode(substr(psorton,3,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) sorton
   from umo_index ui, umo_attribute ut, umo um, umo_attributes uts
   where um.umo_id = ui.umo_id and
         um.aid = ui.aid and
         um.aid = acid and
         um.date_created > query_date and
         um.umo_id = ut.umo_id and
         um.is_global = isgbl and
         ui.attribute_id = ut.attribute_id and
         ut.attribute_id = uts.attribute_id and
         um.date_created + img_age >= sysdate and
         ui.umo_id = ut.umo_id and
         uts.umo_type in ('PHOTO','DOCUMENT','AUDIO','VIDEO','RELATIONAL','BLUEPRINT') and
         uts.queryable = 'T' and
         ((pdim = 'A') or (pdim = 'P' and nvl(um.photo_master.height,0) >= nvl(um.photo_master.width,0)) or (pdim = 'L' and nvl(um.photo_master.height,0) <= nvl(um.photo_master.width,0)) or (pdim = 'S' and nvl(um.photo_master.height,0) = nvl(um.photo_master.width,0)) ) and
         (ui.word_soundex = keyword) and
         ((ltype = 'PHOTOGRAPHER') or
          ((ltype = 'OWNER' or ltype = 'PROFILE') and um.extras.enabled_phg='TRUE') or
          ((ltype = 'CUSTOMER' or ltype = 'PROFILG') and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE'))
   order by um.umo_id;

  cursor c1_starts_noscene(acid integer, keyword varchar2,isgbl char, query_date date, img_age integer, pdim char, psorton char, ltype varchar2) is
   select  /*+ ALL_ROWS */ um.umo_id,
          decode(substr(psorton,1,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) ||
          decode(substr(psorton,2,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) ||
          decode(substr(psorton,3,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) sorton
   from umo_index ui, umo_attribute ut, umo um, umo_attributes uts
   where um.umo_id = ui.umo_id and
         um.aid = ui.aid and
         um.aid = acid and
         um.date_created > query_date and
         um.is_global = isgbl and
         um.umo_id = ut.umo_id and
         ui.attribute_id = ut.attribute_id and
         ut.attribute_id = uts.attribute_id and
         um.date_created + img_age >= sysdate and
         ui.umo_id = ut.umo_id and
         uts.umo_type in ('PHOTO','DOCUMENT','AUDIO','VIDEO','RELATIONAL','BLUEPRINT') and
         uts.queryable = 'T' and
         ((pdim = 'A') or (pdim = 'P' and nvl(um.photo_master.height,0) >= nvl(um.photo_master.width,0)) or (pdim = 'L' and nvl(um.photo_master.height,0) <= nvl(um.photo_master.width,0)) or (pdim = 'S' and nvl(um.photo_master.height,0) = nvl(um.photo_master.width,0)) ) and
         (ui.word_upper like upper(keyword) || '%') and
         ((ltype = 'PHOTOGRAPHER') or
          ((ltype = 'OWNER' or ltype = 'PROFILE') and um.extras.enabled_phg='TRUE') or
          ((ltype = 'CUSTOMER' or ltype = 'PROFILG') and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE'))
   order by um.umo_id;

  cursor c1_ctx(acid integer, keyword varchar2, isgbl char, query_date date, img_age integer, psorton char, ltype varchar2) is
   select um.umo_id,
          decode(substr(psorton,1,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) ||
          decode(substr(psorton,2,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) ||
          decode(substr(psorton,3,1),'N',lpad('0',3, to_char(um.sort_priority)), 'S', lpad('0',3, to_char(um.extras.orderby_nmb)), 'I', upper(um.extras.film_name), 'A', to_char(date_created,'YYYYMMDD'), NULL) sorton
   from umo um
   where um.aid = acid and
         um.date_created > query_date and
         um.is_global = isgbl and
         um.date_created + img_age >= sysdate and
         um.umo_type = 'DOCUMENT' and
         ((ltype = 'PHOTOGRAPHER') or
          ((ltype = 'OWNER' or ltype = 'PROFILE') and um.extras.enabled_phg='TRUE') or
          ((ltype = 'CUSTOMER' or ltype = 'PROFILG') and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE')) and
         contains( um.doc_body, keyword )  > 0
   order by um.umo_id;

 cursor c2(phgid integer) is select aid from customer_account where pid = phgid;
 cursor c3(v_umo integer) is select * from umo um where umo_id = v_umo;
 cursor c4(stm varchar2) is
  select term tm from dictionary where term like stm || '%' and association_type = 'D'
  union
  select association tm from dictionary where association_type = 'A' and term = stm;

 cursor c5(ignlbox char, sess_id integer) is
  select distinct umo_id,sort_value
  from advanced_query_temp_result_a
  where ((ignlbox = 'F') or (ignlbox = 'T' and umo_id not in (select umo_id from lightbox where sessid = sess_id)))
  order by 2,1;

 cursor c5_tot(ignlbox char, sess_id integer) is
  select count(distinct umo_id) tot
  from advanced_query_temp_result_a
  where ((ignlbox = 'F') or (ignlbox = 'T' and umo_id not in (select umo_id from lightbox where sessid = sess_id)));

 cursor c6(ignlbox char, sess_id integer) is
  select distinct umo_id ,sort_value
  from advanced_query_temp_result_b
  where ((ignlbox = 'F') or (ignlbox = 'T' and umo_id not in (select umo_id from lightbox where sessid = sess_id)))
  order by 2,1;

 cursor c6_tot(ignlbox char, sess_id integer) is
  select count(distinct umo_id) tot
  from advanced_query_temp_result_b
  where ((ignlbox = 'F') or (ignlbox = 'T' and umo_id not in (select umo_id from lightbox where sessid = sess_id)));

 cursor c7( sess_id integer) is select aid,pid from customer_account where aid = (select aid from login_session where sessid = sess_id);
 cursor c7a( sess_id integer) is select aid,pid from customer_profile where profile_id = (select aid from login_session where sessid = sess_id);
 cursor c8( profid integer) is select count('x') from profile_scenes where profile_id = profid;
 cursor c9( profid integer) is select umo_scene_id from profile_scenes where profile_id = profid;
 cursor c10( sess_id integer ) is select aid from login_session where sessid = sess_id;
 cursor c11( acid integer ) is select * from customer_account where aid = acid;
 cursor c12(sess_id integer, v_umo integer) is select lightid from lightbox where sessid = sess_id and umo_id = v_umo;

 c3rec		c3%ROWTYPE;
 c10rec		c10%ROWTYPE;
 c11rec		c11%ROWTYPE;
 c12rec		c12%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 cpx		varchar2(1000);
 last_clause	varchar2(20);
 ctr		integer;
 ntot		integer;
 profid		integer;
 isgbl		char(1);
 check_gbl	integer;
 numb_photos	integer;
 maxret         integer;
 totrec		integer;
 agval		integer;
 pdim		char(1);
 psorton	char(10);
 ignlbox	char(1);
 lsterm		varchar2(1000);
 result_list	UMP.SEARCH_RESULT_PHG;

 procedure pop_tbl(in_acid in integer, c1rec in c1%ROWTYPE, tbl in varchar2, acid in integer, query_date in date, img_age in integer, cpx varchar2, pdim char, psorton char, ctx char, ltype varchar2)
 as
 begin
  -- htp.p( in_acid || '-' || tbl || '-' || c1rec.clause || '+' );htp.nl;

  -- If Context Search is Enabled
  -- insert into temp values ('XX:' || ctx ); commit;
  if ctx = 'T'
    then
      if c1rec.is_global = 'T' and in_acid <> acid then isgbl := 'T'; else isgbl := 'F'; end if;
      -- insert into temp values (in_acid || '-' || c1rec.keyword || ':' || isgbl || '-' || query_date || ':' || img_age || '-' || psorton ); commit;
      for crec in c1_ctx(in_acid,replace(c1rec.keyword,'%',''),isgbl,query_date,img_age,psorton,ltype) loop
       if tbl = 'A'
        then
         insert into advanced_query_temp_result_a(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       elsif tbl = 'C'
        then
         insert into advanced_query_temp_result_c(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       end if;
     end loop;
  end if;
  --glbx.dbg( c1rec.clause );

  if c1rec.clause = LNG.PHG_TXT_505 -- 'Matches'
   then
    isgbl := NULL;
    if c1rec.is_global = 'T' and in_acid <> acid then isgbl := 'T'; else isgbl := 'F'; end if;
    --glbx.dbg( 'M:' || c1rec.umo_scene_id || '-' || in_acid || '-' || c1rec.keyword);htp.nl;
    if nvl(c1rec.umo_scene_id,0) = 0
     then
      --glbx.dbg( 'XZ:' || in_acid || '-' || c1rec.umo_scene_id || '-' || c1rec.keyword || '+' ); htp.nl;
      for crec in c1_standard_noscene(in_acid,c1rec.keyword,isgbl,query_date,img_age, pdim, psorton,ltype) loop
       if tbl = 'A'
        then
        --glbx.dbg('MA:' || crec.umo_id); htp.nl;
         insert into advanced_query_temp_result_a(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       elsif tbl = 'C'
        then
        --glbx.dbg('MC:' || crec.umo_id); htp.nl;
         insert into advanced_query_temp_result_c(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       end if;
      end loop;
     else
      --glbx.dbg( 'XX:' || in_acid || '-' || c1rec.umo_scene_id || '-' || c1rec.keyword || '+' ); htp.nl;
      for crec in c1_standard_scene(in_acid,c1rec.umo_scene_id,c1rec.keyword,isgbl,query_date,img_age,cpx, pdim, psorton,ltype) loop
       if tbl = 'A'
        then
         --glbx.dbg('LMA:' || crec.umo_id); htp.nl;
         insert into advanced_query_temp_result_a(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       elsif tbl = 'C'
        then
         --glbx.dbg('LMC:' || crec.umo_id); htp.nl;
         insert into advanced_query_temp_result_c(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       end if;
      end loop;
    end if;

  elsif c1rec.clause = LNG.PHG_TXT_507 -- 'Exactly Matches'
   then
    isgbl := NULL;
    if c1rec.is_global = 'T' and in_acid <> acid then isgbl := 'T'; else isgbl := 'F'; end if;
    if nvl(c1rec.umo_scene_id,0) = 0
     then
      for crec in c1_exact_noscene(in_acid,c1rec.keyword,isgbl,query_date,img_age, pdim, psorton,ltype) loop
       if tbl = 'A'
        then
         insert into advanced_query_temp_result_a(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       elsif tbl = 'C'
        then
         insert into advanced_query_temp_result_c(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       end if;
      end loop;
     else
      for crec in c1_exact_scene(in_acid,c1rec.umo_scene_id,c1rec.keyword,isgbl,query_date,img_age,cpx, pdim, psorton,ltype) loop
       if tbl = 'A'
        then
         insert into advanced_query_temp_result_a(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       elsif tbl = 'C'
        then
         insert into advanced_query_temp_result_c(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       end if;
      end loop;
    end if;

  elsif c1rec.clause = LNG.PHG_TXT_508 -- 'Sounds Like'
   then
    isgbl := NULL;
    if c1rec.is_global = 'T' and in_acid <> acid then isgbl := 'T'; else isgbl := 'F'; end if;
    -- htp.p( 'SD:' || c1rec.umo_scene_id || '-' || in_acid || '-' || c1rec.keyword);htp.nl;
    if nvl(c1rec.umo_scene_id,0) = 0
     then
      -- do not embed soundex_api in query as it runs too slow
      for crec in c1_sounds_noscene(in_acid,soundex_api(c1rec.keyword,null),isgbl,query_date,img_age, pdim, psorton,ltype) loop
       if tbl = 'A'
        then
         -- htp.p('DA:' || crec.umo_id); htp.nl;
         insert into advanced_query_temp_result_a(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       elsif tbl = 'C'
        then
         -- htp.p('DC:' || crec.umo_id); htp.nl;
         insert into advanced_query_temp_result_c(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       end if;
      end loop;

     else
      -- do not embed soundex_api in query as it runs too slow
      --insert into temp values (in_acid || '-' || c1rec.umo_scene_id || '-' || soundex_api(c1rec.keyword,null) || '-' || isgbl || '-' || query_date || '-' || img_age || '-' || cpx || '-' || pdim || '-' || psorton ); commit;
      for crec in c1_sounds_scene(in_acid,c1rec.umo_scene_id,soundex_api(c1rec.keyword,null),isgbl,query_date,img_age,cpx, pdim, psorton,ltype) loop
       if tbl = 'A'
        then
         -- htp.p('DA:' || crec.umo_id); htp.nl;
         insert into advanced_query_temp_result_a(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       elsif tbl = 'C'
        then
         -- htp.p('DC:' || crec.umo_id); htp.nl;
         insert into advanced_query_temp_result_c(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       end if;
      end loop;
    end if;

  elsif c1rec.clause = LNG.PHG_TXT_506 -- 'Starts With'
   then
    isgbl := NULL;
    if c1rec.is_global = 'T' and in_acid <> acid then isgbl := 'T'; else isgbl := 'F'; end if;
    --glbx.dbg( 'SW:' || c1rec.umo_scene_id || '-' || in_acid || '-' || c1rec.keyword || '-' || in_acid || '-' || acid);htp.nl;
    if nvl(c1rec.umo_scene_id,0) = 0
     then
      --glbx.dbg( 'SWA:' || in_acid || '-' || c1rec.keyword || ':' || isgbl || '-' || query_date || ':' || img_age || '-' || pdim || ':' || ltype);htp.nl;
      for crec in c1_starts_noscene(in_acid,c1rec.keyword,isgbl,query_date,img_age, pdim, psorton,ltype) loop
       --glbx.dbg( 'Z:' || crec.umo_id );
       if tbl = 'A'
        then
         --glbx.dbg('XA:' || crec.umo_id); htp.nl;
         insert into advanced_query_temp_result_a(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       elsif tbl = 'C'
        then
         --glbx.dbg('XC:' || crec.umo_id); htp.nl;
         insert into advanced_query_temp_result_c(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       end if;
      end loop;
     else
      for crec in c1_starts_scene(in_acid,c1rec.umo_scene_id,c1rec.keyword,isgbl,query_date,img_age,cpx, pdim, psorton,ltype) loop
       if tbl = 'A'
        then
         --glbx.dbg('XA:' || crec.umo_id); htp.nl;
         insert into advanced_query_temp_result_a(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       elsif tbl = 'C'
        then
         --glbx.dbg('XC:' || crec.umo_id); htp.nl;
         insert into advanced_query_temp_result_c(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       end if;
      end loop;
    end if;

  elsif c1rec.clause = 'N' || LNG.PHG_TXT_505 -- 'Matches' but is a number, so found them either side +- 1
   then
    isgbl := NULL;
    if c1rec.is_global = 'T' and in_acid <> acid then isgbl := 'T'; else isgbl := 'F'; end if;
    -- htp.p( 'M:' || c1rec.umo_scene_id || '-' || in_acid || '-' || c1rec.keyword);htp.nl;
    if nvl(c1rec.umo_scene_id,0) = 0
     then
      -- htp.p( 'XZ:' || in_acid || '-' || c1rec.umo_scene_id || '-' || c1rec.keyword || '+' ); htp.nl;
      for crec in c1_standard_noscene(in_acid,to_char(to_number(c1rec.keyword)),isgbl,query_date,img_age, pdim, psorton,ltype) loop
       if tbl = 'A'
        then
        -- htp.p('MA:' || crec.umo_id); htp.nl;
         insert into advanced_query_temp_result_a(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       elsif tbl = 'C'
        then
        -- htp.p('MC:' || crec.umo_id); htp.nl;
         insert into advanced_query_temp_result_c(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       end if;
      end loop;
     else
      -- htp.p( 'XX:' || in_acid || '-' || c1rec.umo_scene_id || '-' || c1rec.keyword || '+' ); htp.nl;
      for crec in c1_standard_scene(in_acid,c1rec.umo_scene_id,to_char(to_number(c1rec.keyword)),isgbl,query_date,img_age,cpx, pdim, psorton,ltype) loop
       if tbl = 'A'
        then
         -- htp.p('LMA:' || crec.umo_id); htp.nl;
         insert into advanced_query_temp_result_a(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       elsif tbl = 'C'
        then
         -- htp.p('LMC:' || crec.umo_id); htp.nl;
         insert into advanced_query_temp_result_c(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       end if;
      end loop;
    end if;

    -- Look for +1
    if c1rec.is_global = 'T' and in_acid <> acid then isgbl := 'T'; else isgbl := 'F'; end if;
    -- htp.p( 'M:' || c1rec.umo_scene_id || '-' || in_acid || '-' || c1rec.keyword);htp.nl;
    if nvl(c1rec.umo_scene_id,0) = 0
     then
      -- htp.p( 'XZ:' || in_acid || '-' || c1rec.umo_scene_id || '-' || c1rec.keyword || '+' ); htp.nl;
      for crec in c1_standard_noscene(in_acid,to_char(to_number(c1rec.keyword)+1),isgbl,query_date,img_age, pdim, psorton,ltype) loop
       if tbl = 'A'
        then
        -- htp.p('MA:' || crec.umo_id); htp.nl;
         insert into advanced_query_temp_result_a(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       elsif tbl = 'C'
        then
        -- htp.p('MC:' || crec.umo_id); htp.nl;
         insert into advanced_query_temp_result_c(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       end if;
      end loop;
     else
      -- htp.p( 'XX:' || in_acid || '-' || c1rec.umo_scene_id || '-' || c1rec.keyword || '+' ); htp.nl;
      for crec in c1_standard_scene(in_acid,c1rec.umo_scene_id,to_char(to_number(c1rec.keyword)+1),isgbl,query_date,img_age,cpx, pdim, psorton,ltype) loop
       if tbl = 'A'
        then
         -- htp.p('LMA:' || crec.umo_id); htp.nl;
         insert into advanced_query_temp_result_a(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       elsif tbl = 'C'
        then
         -- htp.p('LMC:' || crec.umo_id); htp.nl;
         insert into advanced_query_temp_result_c(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       end if;
      end loop;
    end if;

    -- Look for -1
    if c1rec.is_global = 'T' and in_acid <> acid then isgbl := 'T'; else isgbl := 'F'; end if;
    -- htp.p( 'M:' || c1rec.umo_scene_id || '-' || in_acid || '-' || c1rec.keyword);htp.nl;
    if nvl(c1rec.umo_scene_id,0) = 0
     then
      -- htp.p( 'XZ:' || in_acid || '-' || c1rec.umo_scene_id || '-' || c1rec.keyword || '+' ); htp.nl;
      for crec in c1_standard_noscene(in_acid,to_char(to_number(c1rec.keyword)-1),isgbl,query_date,img_age, pdim, psorton,ltype) loop
       if tbl = 'A'
        then
        -- htp.p('MA:' || crec.umo_id); htp.nl;
         insert into advanced_query_temp_result_a(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       elsif tbl = 'C'
        then
        -- htp.p('MC:' || crec.umo_id); htp.nl;
         insert into advanced_query_temp_result_c(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       end if;
      end loop;
     else
      -- htp.p( 'XX:' || in_acid || '-' || c1rec.umo_scene_id || '-' || c1rec.keyword || '+' ); htp.nl;
      for crec in c1_standard_scene(in_acid,c1rec.umo_scene_id,to_char(to_number(c1rec.keyword)-1),isgbl,query_date,img_age,cpx, pdim, psorton,ltype) loop
       if tbl = 'A'
        then
         -- htp.p('LMA:' || crec.umo_id); htp.nl;
         insert into advanced_query_temp_result_a(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       elsif tbl = 'C'
        then
         -- htp.p('LMC:' || crec.umo_id); htp.nl;
         insert into advanced_query_temp_result_c(umo_id,sort_value) values (crec.umo_id,crec.sorton);
       end if;
      end loop;
    end if;

  end if;
    --glbx.dbg('End pop_tbl');
 end pop_tbl;

 procedure stm(in_acid in integer, c1rec in c1%ROWTYPE, tbl in varchar2, acid in integer, query_date in date, img_age integer, cpx varchar2, pdim char, psorton char, ctx char, ltype varchar2)
 as
  ctrec	c1%ROWTYPE;
 begin
  ctrec := c1rec;
  for c4rec in c4(upper(c1rec.keyword)) loop
    ctrec.keyword := c4rec.tm;
    pop_tbl(in_acid,ctrec,tbl,acid,query_date,img_age,cpx,pdim,psorton,ctx,ltype);
  end loop;
 end stm;

begin
 if sec_details.ltype is null
  then
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'UMP.ADVANCED_SEARCH_PHG', reset=>FALSE );
   if sts is not null
    then
      glbx.redisplay_login_page( sts, TRUE );
      return;
   end if;
 end if;

 if sec_details.ltype is null
  then
   c11rec := glbx.get_cusrec( owner_id, ltype, substr(left_api_parm,2,instr(left_api_parm,']')-2), profid );
  else
   ltype := sec_details.ltype;
   profid := sec_details.profid;
   c11rec.pid := sec_details.pid;
   c11rec.aid := sec_details.aid;
 end if;

 if sec_details.ltype is null
  then
   maxret := nvl(to_number(glbx.userpref(c11rec.pid,c11rec.aid,'SRC')),100);
   begin numb_photos := glbx.saved_preference_value(acid, profid, ltype, 'DISPLAY_NUMBER' ); exception when others then numb_photos := NULL; end;
  else
   maxret := 20000;
   numb_photos := 20000;
 end if;

 if numb_photos is null
  then
   if ltype = 'PHOTOGRAPHER'
    then
     numb_photos := to_number(glbx.photo_pref(c11rec.pid,c11rec.aid,'PHOTO_DISPLAY'));
     numb_photos := nvl(numb_photos,10);
    else
     numb_photos := to_number(glbx.photo_pref(c11rec.pid,c11rec.aid,'NUMBER_PHOTOS'));
     numb_photos := nvl(numb_photos,10);
   end if;
 end if;

 execute immediate 'truncate table advanced_query_temp_result_a';
 execute immediate 'truncate table advanced_query_temp_result_b';
 execute immediate 'truncate table advanced_query_temp_result_c';
 --glbx.dbg( 'A:' || substr(left_api_parm,instr(left_api_parm,']')+1) );
 --glbx.dbg( 'B:' || c11rec.aid );
 --glbx.dbg( 'C:' || c11rec.pid);
 --glbx.dbg( 'D:' || ltype );
 --glbx.dbg( 'E:' || owner_id );
 for c1rec in c1(substr(left_api_parm,instr(left_api_parm,']')+1),c11rec.aid,c11rec.pid,ltype,owner_id,query_date) loop
 -- glbx.dbg( 'B1:' || c1rec.umo_scene_ids );
 -- glbx.dbg( 'B2:' || c1rec.keyword );
  check_gbl := c1rec.cust_id;
  ignlbox := c1rec.ignore_lightbox;
  cpx := c1rec.umo_scene_ids;

  agval := NULL;
  if substr(c1rec.age,length(c1rec.age),1) = 'D'
   then
    agval := to_number(substr(c1rec.age,1,length(c1rec.age)-1));
  elsif substr(c1rec.age,length(c1rec.age),1) = 'W'
   then
    agval := to_number(substr(c1rec.age,1,length(c1rec.age)-1))*7;
  elsif substr(c1rec.age,length(c1rec.age),1) = 'M'
   then
    agval := add_months(sysdate,to_number(substr(c1rec.age,1,length(c1rec.age)-1))) - sysdate;
  elsif substr(c1rec.age,length(c1rec.age),1) = 'Y'
   then
    agval := add_months(sysdate,to_number(substr(c1rec.age,1,length(c1rec.age)-1))*12) - sysdate;
  elsif substr(c1rec.age,length(c1rec.age),1) = 'X'
   then
    agval := glbx.since_last_session( surl ); -- If not found then nothing should be returned (Note: This query will not work in batch mode)
  end if;
  agval := nvl(agval,999999);

  if c1rec.is_global = 'T' then check_gbl := 0; end if; -- If Global Search look across all
  pdim := c1rec.photo_dimension;
  psorton := c1rec.sort_on;

  ctr := c1%ROWCOUNT;
  -- htp.p( 'c1rec.aid:' || c1rec.cust_id || '-' || c1rec.keyword || '-' || c1%ROWCOUNT || '-' || c1rec.join_clause);htp.nl;

  if c1%ROWCOUNT = 1 /* If ABC */
   then
    lsterm := c1rec.keyword;
    if nvl(c1rec.cust_id,0) = 0 or check_gbl = 0
     then
      for c2rec in c2(c11rec.pid) loop
       if c1rec.stem = 'T'
        then
         stm(c2rec.aid,c1rec,'A',c11rec.aid,query_date,agval,cpx,pdim,psorton,ctx,ltype);
        else
         pop_tbl(c2rec.aid,c1rec,'A',c11rec.aid,query_date,agval,cpx,pdim,psorton,ctx,ltype);
       end if;
      end loop;
     else
       if c1rec.stem = 'T'
        then
         stm(c1rec.cust_id,c1rec,'A',c11rec.aid,query_date,agval,cpx,pdim,psorton,ctx,ltype);
        else
         pop_tbl(c1rec.cust_id,c1rec,'A',c11rec.aid,query_date,agval,cpx,pdim,psorton,ctx,ltype);
       end if;
    end if;
    last_clause := c1rec.join_clause;

   else /* ABC */

    if nvl(c1rec.cust_id,0) = 0 or check_gbl = 0
     then
      for c2rec in c2(c11rec.pid) loop
       if c1rec.stem = 'T'
        then
         stm(c2rec.aid,c1rec,'C',c11rec.aid,query_date,agval,cpx,pdim,psorton,ctx,ltype);
        else
         pop_tbl(c2rec.aid,c1rec,'C',c11rec.aid,query_date,agval,cpx,pdim,psorton,ctx,ltype);
       end if;
      end loop;
     else
       if c1rec.stem = 'T'
        then
         stm(c1rec.cust_id,c1rec,'C',c11rec.aid,query_date,agval,cpx,pdim,psorton,ctx,ltype);
        else
         pop_tbl(c1rec.cust_id,c1rec,'C',c11rec.aid,query_date,agval,cpx,pdim,psorton,ctx,ltype);
       end if;
    end if;

    if last_clause = 'Or'
     then
      if mod(c1%ROWCOUNT,2) = 0
       then
        execute immediate 'truncate table advanced_query_temp_result_b';
        insert into advanced_query_temp_result_b (umo_id,sort_value)
         select umo_id,sort_value from advanced_query_temp_result_a union select umo_id,sort_value from advanced_query_temp_result_c;
        execute immediate 'truncate table advanced_query_temp_result_c';
       else
        execute immediate 'truncate table advanced_query_temp_result_a';
        insert into advanced_query_temp_result_a (umo_id,sort_value)
         select umo_id,sort_value from advanced_query_temp_result_b union select umo_id,sort_value from advanced_query_temp_result_c;
        execute immediate 'truncate table advanced_query_temp_result_c';
      end if;
    elsif last_clause = 'And'
     then
      if mod(c1%ROWCOUNT,2) = 0
       then

         /*
         for xrec in (select umo_id from advanced_query_temp_result_a) loop
           htp.p( 'X2:AND-C5:' || xrec.umo_id);htp.nl;
         end loop;
         for xrec in (select umo_id from advanced_query_temp_result_b) loop
           htp.p( 'Y2:AND-C5:' || xrec.umo_id);htp.nl;
         end loop;
         for xrec in (select umo_id from advanced_query_temp_result_c) loop
           htp.p( 'Z2:AND-C5:' || xrec.umo_id);htp.nl;
         end loop;
         */
        execute immediate 'truncate table advanced_query_temp_result_b';
        insert into advanced_query_temp_result_b (umo_id,sort_value)
         select umo_id,sort_value from advanced_query_temp_result_a intersect select umo_id,sort_value from advanced_query_temp_result_c;
         /*
         for arec in (select umo_id from advanced_query_temp_result_b) loop
           htp.p( '2:AND-C5:' || arec.umo_id);htp.nl;
         end loop;
         */
        execute immediate 'truncate table advanced_query_temp_result_c';
       else
        execute immediate 'truncate table advanced_query_temp_result_a';
        insert into advanced_query_temp_result_a (umo_id,sort_value)
         select umo_id,sort_value from advanced_query_temp_result_b intersect select umo_id,sort_value from advanced_query_temp_result_c;
         for arec in c6(ignlbox,owner_id) loop
          htp.p( '1:AND-C6:' || arec.umo_id);htp.nl;
         end loop;
        execute immediate 'truncate table advanced_query_temp_result_c';
      end if;
    elsif last_clause = 'Not'
     then
      if mod(c1%ROWCOUNT,2) = 0
       then
        execute immediate 'truncate table advanced_query_temp_result_b';
        insert into advanced_query_temp_result_b (umo_id,sort_value)
         select umo_id,sort_value from advanced_query_temp_result_a minus select umo_id ,sort_value from advanced_query_temp_result_c;
        execute immediate 'truncate table advanced_query_temp_result_c';
       else
        execute immediate 'truncate table advanced_query_temp_result_a';
        insert into advanced_query_temp_result_a (umo_id,sort_value)
         select umo_id,sort_value from advanced_query_temp_result_b minus select umo_id,sort_value from advanced_query_temp_result_c;
        execute immediate 'truncate table advanced_query_temp_result_c';
      end if;
    end if;
    /*
    htp.p('Dump Tables:');htp.nl;
    for arec in c5 loop
     htp.p( 'C5A:' || arec.umo_id);htp.nl;
    end loop;
    for arec in c6 loop
     htp.p( 'C6B:' || arec.umo_id);htp.nl;
    end loop;
    */

    last_clause := c1rec.join_clause;

  end if; /* End if ABC */

 end loop;

 /*
 if ctr > 1
  then
    ctr := ctr + 1;
 end if;
 */

if ltype in ('PROFILE','PROFILEG')
  then
   open c8( profid );
   fetch c8 into ntot;
   close c8;
   if ntot > 0
    then
     delete from advanced_query_temp_result_c;
     if mod(ctr,2) = 0
      then
       for c9rec in c9( profid ) loop
        insert into advanced_query_temp_result_c (umo_id,sort_value)
         select ab.umo_id, ab.sort_value
         from umo um, advanced_query_temp_result_b ab
         where um.umo_id = ab.umo_id and
               um.umo_scene_id = c9rec.umo_scene_id;
       end loop;
       delete from advanced_query_temp_result_b;
       insert into advanced_query_temp_result_b (umo_id,sort_value) select umo_id,sort_value from advanced_query_temp_result_c;
      else
       for c9rec in c9( profid ) loop
        insert into advanced_query_temp_result_c (umo_id,sort_value)
         select aa.umo_id, aa.sort_value
         from umo um, advanced_query_temp_result_a aa
         where um.umo_id = aa.umo_id and
               um.umo_scene_id = c9rec.umo_scene_id;
       end loop;
       delete from advanced_query_temp_result_a;
       insert into advanced_query_temp_result_a (umo_id,sort_value) select umo_id,sort_value from advanced_query_temp_result_c;
     end if;
   end if;
 end if;

 if mod(ctr,2) = 0
  then
   for c6rec in c6(ignlbox,owner_id) loop
    ctr := c6%ROWCOUNT;
    open c3(c6rec.umo_id);
    fetch c3 into c3rec;
    close c3;
    if ctr < start_from
     then
      null;
     else
      if ctr >= (start_from + numb_photos) or ctr >= maxret
       then
        exit;
       else
        result_list(ctr) := c3rec;
        open c12(owner_id,c3rec.umo_id);
        fetch c12 into c12rec;
        if c12%FOUND
         then
          result_list( ctr ).attribute1 := nvl(to_char(c12rec.lightid),'~');
        end if;
        close c12;
        if ctr >= maxret then exit; end if;
      end if;
    end if;
   end loop;
   if ctr >= maxret
    then
     totrec := maxret;
    else
     open c6_tot(ignlbox,owner_id);
     fetch c6_tot into totrec;
     close c6_tot;
     if totrec > maxret then totrec := maxret; end if;
   end if;

  else

   for c5rec in c5(ignlbox,owner_id) loop
    ctr := c5%ROWCOUNT;
    open c3(c5rec.umo_id);
    fetch c3 into c3rec;
    close c3;
    if ctr < start_from
     then
      null;
     else
      if ctr >= (start_from + numb_photos) or ctr >= maxret
       then
        exit;
       else
        result_list(ctr) := c3rec;
        open c12(owner_id,c3rec.umo_id);
        fetch c12 into c12rec;
        if c12%FOUND
         then
          result_list( ctr ).attribute1 := nvl(to_char(c12rec.lightid),'~');
        end if;
        close c12;
        if ctr >= maxret then exit; end if;
      end if;
    end if;
   end loop;
   if ctr >= maxret
    then
     totrec := maxret;
    else
     open c5_tot(ignlbox,owner_id);
     fetch c5_tot into totrec;
     close c5_tot;
     if totrec > maxret then totrec := maxret; end if;
   end if;

 end if;

 update advanced_search
  set
   date_updated = sysdate,
   rows_returned = nvl(totrec,0)
 where
  src_name = substr(left_api_parm,instr(left_api_parm,']')+1) and
  nvl(aid,0) = nvl(c11rec.aid,0) and
  ((pid = c11rec.pid and ltype = 'PHOTOGRAPHER') or (pid = 0 and ltype in ('OWNER','PROFILE','CUSTOMER','PROFILEG'))) and
  ((ltype in ('CUSTOMER','PROFILEG') and (sessid = owner_id)) or (ltype in ('PHOTOGRAPHER','OWNER','PROFILE') ) );
 if sec_details.ltype is null
  then
   glbx.extended_search_api( surl, ltype, result_list, totrec,
                             display_detail, title=>LNG.GLB_TXT_100, help_file_code=>NULL,
                             left_api=>NULL, left_api_parm=>left_api_parm, footer_api=>'ump.advanced_search_phg',
                             current_page_number=>start_from,no_results_message=>LNG.PHG_ALT_388, acid=>acid, extra_term=>lsterm) ;

 elsif GLOBAL_OUTPUT in ('XML','HTML')
  then
   webservice_search( surl, result_list );

 else
   new_images_email( sec_details, result_list, totrec );
 end if;

exception when others then
 glbx.error_details( 'UMP', 'ADVANCED_SEARCH_PHG',errmsg=>sqlerrm);
end advanced_search_phg;

procedure meta_tag_search( surl varchar2, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null, query_date in date default SYSDATE-10000, sec_details in SECURITY_DETAILS default empty_sec )
as

 cursor c1(ignlbox char, sess_id integer) is
  select distinct umo_id
  from advanced_query_temp_result_c
  where  ((ignlbox = 'F') or (ignlbox = 'T' and umo_id not in (select umo_id from lightbox where sessid = sess_id))) and
         umo_id is not null;

 cursor c1_tot(ignlbox char, sess_id integer) is
  select count(distinct umo_id ) tot
  from advanced_query_temp_result_c
  where  ((ignlbox = 'F') or (ignlbox = 'T' and umo_id not in (select umo_id from lightbox where sessid = sess_id))) and
         umo_id is not null;

 cursor c3( v_umo integer) is select * from umo um where umo_id = v_umo;
 cursor c4(qry varchar2, acid integer, phgid integer, ltype varchar2, sess_id integer) is
  select *
  from meta_tag_query
  where src_name = qry and
        nvl(aid,0) = nvl(acid,0) and
        login_type = ltype and
        pid = decode(ltype,'PHOTOGRAPHER',phgid,0) and
        ((sessid is not null and sessid = sess_id) or (ltype in ('PHOTOGRAPHER','OWNER','PROFILE') and sessid is null ) )
  order by order_by;
 cursor c7( sess_id integer) is select aid,pid from customer_account where aid = (select aid from login_session where sessid = sess_id);
 cursor c7a( sess_id integer) is select aid,pid from customer_profile where profile_id = (select aid from login_session where sessid = sess_id);

 cursor c8( profid integer) is select count('x') from profile_scenes where profile_id = profid;
 cursor c9( profid integer) is select umo_scene_id from profile_scenes where profile_id = profid;
 cursor c10( sess_id integer ) is select aid from login_session where sessid = sess_id;
 cursor c11( acid integer ) is select * from customer_account where aid = acid;

 c3rec		c3%ROWTYPE;
 c10rec		c10%ROWTYPE;
 c11rec		c11%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 ctr		integer;
 phgid		integer;
 profid		integer;
 ntot		integer;
 x		integer;
 y		integer;
 totrec		integer;
 numb_photos	integer;
 maxret         integer;
 tmpid		integer;
 tmpid1		integer;
 tmpid2		integer;
 ignlbox	char(1);
 last_andor	varchar2(10);
 qname		varchar2(100);
 result_list	UMP.SEARCH_RESULT_PHG;

begin
 if sec_details.ltype is null
  then
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'UMP.META_TAG_SEARCH', reset=>FALSE );
   if sts is not null
    then
      glbx.redisplay_login_page( sts, TRUE );
      return;
   end if;
 end if;
 -- insert into temp values(owner_id|| '-' ||  ltype|| '-' ||  substr(left_api_parm,2,instr(left_api_parm,']')-2)); commit;

 if sec_details.ltype is null
  then
   if instr(left_api_parm,'][') > 0
    then
     x := instr(left_api_parm,'][') + 2;
     y := instr(left_api_parm,']',x );
     c11rec := glbx.get_cusrec( owner_id, ltype, substr(left_api_parm,x,(y-x)), profid );
     qname := substr(left_api_parm,y+1);
    else
     c11rec := glbx.get_cusrec( owner_id, ltype, substr(left_api_parm,2,instr(left_api_parm,']')-2), profid );
     qname := substr(left_api_parm,instr(left_api_parm,']')+1);
   end if;
 else
   ltype := sec_details.ltype;
   profid := sec_details.profid;
   c11rec.pid := sec_details.pid;
   c11rec.aid := sec_details.aid;
   owner_id := sec_details.sessid;
   qname := sec_details.query;
 end if;

 maxret := nvl(to_number(glbx.userpref(c11rec.pid,c11rec.aid,'SRC')),100);
 begin numb_photos := glbx.saved_preference_value(acid, profid, ltype, 'DISPLAY_NUMBER' ); exception when others then numb_photos := NULL; end;

 if numb_photos is null
  then
   if ltype = 'PHOTOGRAPHER'
    then
     numb_photos := to_number(glbx.photo_pref(c11rec.pid,c11rec.aid,'PHOTO_DISPLAY'));
     numb_photos := nvl(numb_photos,10);
    else
     numb_photos := to_number(glbx.photo_pref(c11rec.pid,c11rec.aid,'NUMBER_PHOTOS'));
     numb_photos := nvl(numb_photos,10);
   end if;
 end if;
 execute immediate 'truncate table advanced_query_temp_result_a';
 execute immediate 'truncate table advanced_query_temp_result_b';
 execute immediate 'truncate table advanced_query_temp_result_c';
 -- insert into temp values(c11rec.aid); commit;

 if c11rec.aid = 0
  then
   for c4rec in c4(qname,c11rec.aid,c11rec.pid,ltype,owner_id) loop
     ignlbox := c4rec.ignore_lightbox;
     execute immediate 'truncate table advanced_query_temp_result_a';
     if c4rec.search_type = 'VARCHAR'
     then
      insert into advanced_query_temp_result_a (umo_id)
      select ui.umo_id
      from umo_index ui, customer_account ca
      where ui.aid = ca.aid and
            ca.pid = phgid and
            ui.attribute_id = c4rec.attribute_id and
           ((c4rec.search_item = LNG.PHG_TXT_507 and c4rec.value_a = ui.word_original) or
             (c4rec.search_item = LNG.PHG_TXT_505 and upper(c4rec.value_a) = ui.word_upper) or
             (c4rec.search_item = LNG.PHG_TXT_508 and soundex_api(c4rec.value_a,ui.attribute_id) = ui.word_soundex) or
             (c4rec.search_item = LNG.PHG_TXT_506 and ui.word_upper like upper(c4rec.value_a) || '%')
            );
    elsif c4rec.search_type = 'LOV'
     then
      insert into advanced_query_temp_result_a (umo_id)
      select ui.umo_id
      from umo_index ui, customer_account ca
      where ui.aid = ca.aid and
            ca.pid = phgid and
            ui.attribute_id = c4rec.attribute_id and
            c4rec.value_a = ui.word_original;
    elsif c4rec.search_type = 'INTEGER'
     then
      insert into advanced_query_temp_result_a (umo_id)
      select ui.umo_id
      from umo_index ui, customer_account ca
      where ui.aid = ca.aid and
            ca.pid = phgid and
            ui.attribute_id = c4rec.attribute_id and
            to_number(ui.word_original) between to_number(c4rec.value_b) and to_number(c4rec.value_a);
     elsif c4rec.search_type = 'NUMBER'
     then
      insert into advanced_query_temp_result_a (umo_id)
      select ui.umo_id
      from umo_index ui, customer_account ca
      where ui.aid = ca.aid and
            ca.pid = phgid and
            ui.attribute_id = c4rec.attribute_id and
            ((c4rec.search_item = '<' and to_number(ui.word_original) < to_number(c4rec.value_a) ) or
             (c4rec.search_item = '<=' and to_number(ui.word_original) <= to_number(c4rec.value_a) ) or
             (c4rec.search_item = '>' and to_number(ui.word_original) > to_number(c4rec.value_a) ) or
             (c4rec.search_item = '>=' and to_number(ui.word_original) >= to_number(c4rec.value_a) ) or
             (c4rec.search_item = '<>' and to_number(ui.word_original) <> to_number(c4rec.value_a) )
            );
    end if;
    if c4%ROWCOUNT = 1
     then
      insert into advanced_query_temp_result_c (umo_id) select umo_id from advanced_query_temp_result_a;
     else
      execute immediate 'truncate table advanced_query_temp_result_b';
      if last_andor = 'AND'
       then
        insert into advanced_query_temp_result_b (umo_id) select umo_id from advanced_query_temp_result_a intersect select umo_id from advanced_query_temp_result_c;
       else
        insert into advanced_query_temp_result_b (umo_id) select umo_id from advanced_query_temp_result_a union select umo_id from advanced_query_temp_result_c;
      end if;
      execute immediate 'truncate table advanced_query_temp_result_c';
      insert into advanced_query_temp_result_c (umo_id) select umo_id from advanced_query_temp_result_b;
    end if;
    last_andor := upper(c4rec.andor);
   end loop;

  else
   --glbx.dbg( qname || '-' || c11rec.aid || ':' || c11rec.pid || '-' || ltype || ':' || owner_id );
   for c4rec in c4(qname,c11rec.aid,c11rec.pid,ltype,owner_id) loop
     ignlbox := c4rec.ignore_lightbox;
     execute immediate 'truncate table advanced_query_temp_result_a';
     if c4rec.search_type in ('VARCHAR','EMAIL','LINK','DATE','TIME','Keyword')
     then
      --glbx.dbg( c4rec.search_item );
      --glbx.dbg( c4rec.value_a );
      --glbx.dbg( 'X1:' || c4rec.attribute_id );
      insert into advanced_query_temp_result_a (umo_id)
      select ui.umo_id
      from umo_index ui
      where ui.aid = c11rec.aid and
            ui.attribute_id = c4rec.attribute_id and
            ((c4rec.search_item = LNG.PHG_TXT_507 and c4rec.value_a = ui.word_original) or
             (c4rec.search_item = LNG.PHG_TXT_505 and upper(c4rec.value_a) = ui.word_upper) or
             (c4rec.search_item = LNG.PHG_TXT_508 and soundex_api(c4rec.value_a,ui.attribute_id) = ui.word_soundex) or
             (c4rec.search_item = LNG.PHG_TXT_506 and ui.word_upper like upper(c4rec.value_a) || '%')
            );
      --glbx.dbg( 'XX:' || sql%rowcount );
    elsif c4rec.search_type in ('LOV','SQL','Boolean')
     then
      insert into advanced_query_temp_result_a (umo_id)
      select ui.umo_id
      from umo_index ui
      where ui.aid = c11rec.aid and
            ui.attribute_id = c4rec.attribute_id and
            c4rec.value_a = ui.word_original;
    elsif c4rec.search_type = 'INTEGER'
     then
      insert into advanced_query_temp_result_a (umo_id)
      select ui.umo_id
      from umo_index ui
      where  ui.aid = c11rec.aid and
             ui.attribute_id = c4rec.attribute_id and
             to_number(ui.word_original) between to_number(c4rec.value_b) and to_number(c4rec.value_a);
     elsif c4rec.search_type = 'NUMBER'
     then
      insert into advanced_query_temp_result_a (umo_id)
      select ui.umo_id
      from umo_index ui
      where ui.aid = c11rec.aid and
            ui.attribute_id = c4rec.attribute_id and
           ((c4rec.search_item = '<' and to_number(ui.word_original) < to_number(c4rec.value_a) ) or
            (c4rec.search_item = '<=' and to_number(ui.word_original) <= to_number(c4rec.value_a) ) or
            (c4rec.search_item = '>' and to_number(ui.word_original) > to_number(c4rec.value_a) ) or
            (c4rec.search_item = '>=' and to_number(ui.word_original) >= to_number(c4rec.value_a) ) or
            (c4rec.search_item = '<>' and to_number(ui.word_original) <> to_number(c4rec.value_a) )
           );
    end if;
    if c4%ROWCOUNT = 1
     then
      insert into advanced_query_temp_result_c (umo_id) select umo_id from advanced_query_temp_result_a;
     else
      execute immediate 'truncate table advanced_query_temp_result_b';
      if last_andor = 'AND'
       then
        insert into advanced_query_temp_result_b (umo_id) select umo_id from advanced_query_temp_result_a intersect select umo_id from advanced_query_temp_result_c;
       else
        insert into advanced_query_temp_result_b (umo_id) select umo_id from advanced_query_temp_result_a union select umo_id from advanced_query_temp_result_c;
      end if;
      execute immediate 'truncate table advanced_query_temp_result_c';
      insert into advanced_query_temp_result_c (umo_id) select umo_id from advanced_query_temp_result_b;
    end if;
    last_andor := upper(c4rec.andor);
   end loop;
 end if;

 if ltype in ('PROFILE','PROFILEG')
  then
   open c8( profid );
   fetch c8 into ntot;
   close c8;
   if ntot > 0
    then
     delete from advanced_query_temp_result_c;
     if mod(ctr,2) = 0
      then
       for c9rec in c9( profid ) loop
        insert into advanced_query_temp_result_c (umo_id)
         select ab.umo_id
         from umo um, advanced_query_temp_result_b ab
         where um.umo_id = ab.umo_id and
               um.umo_scene_id = c9rec.umo_scene_id;
       end loop;
       delete from advanced_query_temp_result_b;
       insert into advanced_query_temp_result_b (umo_id) select umo_id from advanced_query_temp_result_c;
      else
       for c9rec in c9( profid ) loop
        insert into advanced_query_temp_result_c (umo_id)
         select aa.umo_id
         from umo um, advanced_query_temp_result_a aa
         where um.umo_id = aa.umo_id and
               um.umo_scene_id = c9rec.umo_scene_id;
       end loop;
       delete from advanced_query_temp_result_a;
       insert into advanced_query_temp_result_a (umo_id) select umo_id from advanced_query_temp_result_c;
     end if;
   end if;
 end if;

 -- Delete disabled images
 if ltype in ('PROFILEG','CUSTOMER')
  then
   delete from advanced_query_temp_result_c
    where umo_id in
     (select um.umo_id
      from umo um, advanced_query_temp_result_c uc
      where um.umo_id = uc.umo_id and
            um.extras.enabled_cus = 'FALSE');
 end if;

 if ltype in ('OWNER','PROFILE','PROFILEG','CUSTOMER')
  then
   delete from advanced_query_temp_result_c
    where umo_id in
     (select um.umo_id
      from umo um, advanced_query_temp_result_c uc
      where um.umo_id = uc.umo_id and
            um.extras.enabled_phg = 'FALSE');
 end if;

 -- Delete if Date Created is less than query date
 delete from advanced_query_temp_result_c
  where umo_id in
     (select um.umo_id
      from umo um, advanced_query_temp_result_c uc
      where um.umo_id = uc.umo_id and
            um.date_created <= query_date);

 for c1rec in c1(ignlbox,owner_id) loop
    ctr := c1%ROWCOUNT;
    if ctr < start_from
     then
      null;
     else
      if ctr >= (start_from + numb_photos) or ctr >= maxret
       then
        exit;
       else
        open c3(c1rec.umo_id);
        fetch c3 into c3rec;
        if c3%FOUND
         then
          close c3;
          result_list(ctr) := c3rec;
          if ctr >= maxret then exit; end if;
         else
          close c3;
        end if;
      end if;
    end if;
 end loop;
 if ctr >= maxret
  then
   totrec := maxret;
  else
   open c1_tot(ignlbox,owner_id);
   fetch c1_tot into totrec;
   close c1_tot;
   if totrec > maxret then totrec := maxret; end if;
 end if;

 update meta_tag_query
  set
   date_updated = sysdate,
   rows_returned = nvl(totrec,0)
 where
  src_name = substr(left_api_parm,instr(left_api_parm,']')+1) and
  nvl(aid,0) = nvl(c11rec.aid,0) and
  pid = decode(ltype,'PHOTOGRAPHER',c11rec.pid,0) and
  ((ltype in ('CUSTOMER','PROFILEG') and (sessid = owner_id)) or (ltype in ('PHOTOGRAPHER','OWNER','PROFILE') ) );

 if sec_details.ltype is null
  then
   glbx.extended_search_api( surl, ltype, result_list, totrec,
                             display_detail, title=>LNG.GLB_TXT_100, help_file_code=>NULL,
                             left_api=>NULL, left_api_parm=>left_api_parm, footer_api=>'ump.meta_tag_search',
                             current_page_number=>start_from,no_results_message=>LNG.PHG_ALT_388,acid=>acid);
  elsif sec_details.returnto = 'GLB_META'
   then
    tmpid := sec_details.sessid;
    delete from customer_meta_data_query where sessid = tmpid;
    if result_list.count = 0 then return; end if;
    for j in result_list.first..result_list.last loop
     tmpid1 := (j - result_list.first) + 1;
     tmpid2 := result_list(j).umo_id;
     insert into customer_meta_data_query(order_by,sessid,umo_id) values
      (tmpid1, tmpid, tmpid2);
    end loop;
    return;
  else
   new_images_email( sec_details, result_list, totrec );
 end if;

exception when others then
 glbx.error_details( 'UMP', 'META_TAG_SEARCH',errmsg=>sqlerrm);
end meta_tag_search;

function conv_compr( compr in varchar2 )
 return varchar2
as
begin
 if compr = NULL then return( NULL ); end if;
 if compr in (LNG.PHG_ALT_427,'N') then return(LNG.PHG_ALT_427 ); end if; -- No Compress
 if compr in (LNG.PHG_TXT_308,'L') then return( 'LOWCOMP' ); end if;
 if compr in (LNG.PHG_TXT_309,'M') then return( 'MEDCOMP' ); end if;
 if compr in (LNG.PHG_TXT_310,'H') then return( 'HIGHCOMP' ); end if;
 return( compr );
exception when others then
 glbx.error_details( 'UMP', 'CONV_COMPR',errmsg=>sqlerrm,extdet=>'COMPR:' || compr);
end conv_compr;

procedure image_prescript( retsess out varchar2, cmd out integer, vblob out blob, v_umo out integer, reload_images out integer, input_file out varchar2, output_file out varchar2, montage_file out varchar2, montage_blob out blob, visual_output_file out varchar2, numbparms out integer, myindex in out UMP.MYARRAY, schemaname out varchar2, extra_parms out integer, extra_umo in out UMP.MYARRAY, extra_umo_file in out UMP.MYARRAY )
as

 cursor c2(v_umo integer) is select um.photo_master.mimetype mtype from umo um where umo_id = v_umo for update;

 TYPE MyCurTyp IS REF CURSOR;  -- define weak REF CURSOR type

 c1            		MyCurTyp;
 status       		number;
 additional_umo		integer;
 ctr			integer;
 acid			integer;
 msg			varchar2(4000);
 mtype			varchar2(4000);
 ext			varchar2(100);
 uniqueval		varchar2(100);
 origloc		varchar2(100);

begin

 status := dbms_pipe.receive_message('IMAGE_MAGICK');
 commit; -- Release anything locked
 dbms_pipe.unpack_message(retsess);
 dbms_pipe.unpack_message(cmd);
 dbms_pipe.unpack_message(schemaname);
 dbms_pipe.unpack_message(acid);
 dbms_pipe.unpack_message(v_umo);
 dbms_pipe.unpack_message(reload_images);

 cmd := nvl(cmd,1);
 schemaname := nvl(schemaname,user);
 extra_parms := 0;
 extra_umo(1) := 0;
 extra_umo_file(1) := 'dummy';
 reload_images := nvl(reload_images,1);

 if cmd = 0 or cmd = 99
  then
   input_file := 'dummy';
   output_file := 'dummy';
   montage_file := 'dummy';
   visual_output_file := 'dummy';
   numbparms := 1;
   vblob := empty_blob;
   montage_blob := empty_blob;
   myindex(1) := 'quit' || chr(0);
   return;
 end if;

 begin
  -- open c1(v_umo);
  open c1 FOR 'select um.photo_original_loc,um.photo_master.source.localdata phgm, um.photo_master.mimetype mtype from ' || schemaname || '.umo um where umo_id = :1 for update nowait' using v_umo;
  fetch c1 into origloc,vblob,mtype;
  close c1;
 exception
  when others then
   rollback;
   cmd := 89;
   input_file := 'dummy';
   output_file := 'dummy';
   montage_file := 'dummy';
   visual_output_file := 'dummy';
   numbparms := 1;
   vblob := empty_blob;
   montage_blob := empty_blob;
   myindex(1) := 'cantlock' || chr(0);
   return;
 end;

 /*
 open c1( v_umo );
 fetch c1 into vblob, mtype;
 close c1;
 */

 -- Currently only supported data types
 if mtype = 'image/gif' then ext := 'gif'; else ext := 'jpg'; end if;

 input_file := ump.random_file_location( ext );
 if upper(glbx.extract_fname(origloc)) = 'WMF'
  then
   output_file := ump.random_file_location( 'gif' ); -- WMF Files are better as GIF's
  else
   output_file := ump.random_file_location( 'jpg' ); -- In this release we always want a JPG file produced as the output file
 end if;
 montage_file := 'dummy';
 visual_output_file := 'c:\temp\stream_output.txt';
 montage_blob := empty_blob();

 if cmd in (4,5)
  then
   dbms_pipe.unpack_message(additional_umo);
   --open c1( additional_umo );
   --fetch c1 into montage_blob,mtype;
   --close c1;
   begin
    open c1 FOR 'select um.photo_master.source.localdata phgm, um.photo_master.mimetype mtype from ' || schemaname || '.umo um where umo_id = :1 for update nowait' using additional_umo;
    fetch c1 into montage_blob,mtype;
    close c1;
   exception
    when others then
     rollback;
     cmd := 89;
     input_file := 'dummy';
     output_file := 'dummy';
     montage_file := 'dummy';
     visual_output_file := 'dummy';
     numbparms := 1;
     vblob := empty_blob;
     montage_blob := empty_blob;
     myindex(1) := 'cantlock' || chr(0);
     return;
   end;
   if mtype = 'image/gif' then ext := 'gif'; else ext := 'jpg'; end if;
   montage_file := ump.random_file_location( ext );
 end if;

 myindex.delete;
 if cmd = 0
  then
   myindex(1) := 'quit' || chr(0);
 elsif cmd = 1
  then
   myindex(1) := 'identify' || chr(0);
 elsif cmd = 2
  then
   myindex(1) := 'mogrify' || chr(0);
 elsif cmd in (3,6)
  then
   myindex(1) := 'convert' || chr(0);
 elsif cmd = 4
  then
   myindex(1) := 'montage' || chr(0);
 elsif cmd = 5
  then
   myindex(1) := 'composite' || chr(0);
 elsif cmd = 6
  then
   myindex(1) := 'convert' || chr(0);
 end if;

 ctr := 1;
 loop
  ctr := ctr + 1;
  if ctr > 100 then exit; end if; -- Infinite Loop Protection
  dbms_pipe.unpack_message(msg);
  if msg in ('FINISH','MORE_UMO') then exit; end if;
  myindex(ctr) := replace(msg,'<PICTION_PARAMETER=INPUT_FILE>',input_file);
  myindex(ctr) := replace(myindex(ctr),'<PICTION_PARAMETER=OUTPUT_FILE>',output_file);
  myindex(ctr) := replace(myindex(ctr),'<PICTION_PARAMETER=MONTAGE_FILE>',montage_file);
 end loop;
 numbparms := myindex.count;

 ctr := 1;
 if msg = 'MORE_UMO'
  then
   dbms_pipe.unpack_message(uniqueval);
   loop
    if ctr > 1000 then exit; end if; -- Infinite Loop Protection
    dbms_pipe.unpack_message(msg);
    if msg in ('FINISH') then exit; end if;
    extra_umo(ctr) := msg || chr(0);
    open c2( to_number(msg) );
    fetch c2 into mtype;
    close c2;
    if mtype = 'image/gif' then ext := 'gif'; else ext := 'jpg'; end if;
    extra_umo_file(ctr) :=  ump.random_file_location( ext, uniqueval ) || chr(0);
    ctr := ctr + 1;
   end loop;
   for j in myindex.first..myindex.last loop
    myindex(j) := replace(myindex(j),'<PICTION_PARAMETER=WILDCARD>',glbx.extract_master_parameter( 'WORK_DIRECTORY' ) || DECS.UNIX_OR_NT || uniqueval) || chr(0);
   end loop;
   extra_parms := ctr - 1;
  else
   for j in myindex.first..myindex.last loop
    myindex(j) := myindex(j) || chr(0);
   end loop;
 end if;

 --return_parms.delete;
 -- 	identify -verbose C:\temp\scan2.jpg
 /*
 myindex(1) := 'identify' || chr(0);
 myindex(2) := '-debug' || chr(0);
 myindex(3) := 'C:\temp\scan2.jpg' || chr(0);
 myindex(4) := 'C:\temp\scan2.jpg' || chr(0);
 myindex(5) := 'C:\temp\scan2.jpg' || chr(0);
 numbparms := myindex.count;
 --insert into temp values ('X');
 */

 /*
 myindex(1) := 'mogrify' || chr(0);
 myindex(2) := '-rotate' || chr(0);
 myindex(3) := '90' || chr(0);
 myindex(4) := input_file || chr(0);
 numbparms := myindex.count;
 */

 /*
 myindex(1) := 'convert' || chr(0);
 myindex(2) := '-charcoal' || chr(0);
 myindex(3) := '10' || chr(0);
 myindex(4) := input_file || chr(0);
 myindex(5) := output_file || chr(0);
 numbparms := myindex.count;
 */

 /*
 myindex(1) := 'montage' || chr(0);
 myindex(2) := '-adjoin' || chr(0);
 myindex(3) := input_file || chr(0);
 myindex(4) := montage_file || chr(0);
 myindex(5) := output_file || chr(0);
 numbparms := myindex.count;

 open c1( 78766 );
 fetch c1 into montage_blob;
 close c1;
 */

 /*
 myindex(1) := 'composite' || chr(0);
 myindex(2) := '-geometry' || chr(0);
 myindex(3) := '+100+150' || chr(0);
 myindex(4) := input_file || chr(0);
 myindex(5) := montage_file || chr(0);
 myindex(6) := output_file || chr(0);
 numbparms := myindex.count;
 open c1( 78766 );
 fetch c1 into montage_blob;
 close c1;
 */

 /*
  myindex(1) := 'mogrify' || chr(0);
  myindex(2) := '-comment' || chr(0);
  myindex(3) := '"Piction"' || chr(0);
  myindex(4) := '-font' || chr(0);
  myindex(5) := 'Arial.ttf' || chr(0);
  myindex(6) := input_file || chr(0);
  numbparms := myindex.count;
 */

end image_prescript;

/*
procedure image_postscript( retsess in varchar2, return_parms in out UMP.MYARRAY )
as

 status         NUMBER;
 result         NUMBER;
 lock_ctr   	integer;
 dm		integer;
 errm		varchar2(1000);

begin

 DBMS_PIPE.RESET_BUFFER;
 dm := dbms_pipe.create_pipe(retsess,8192,FALSE);

 if return_parms.count > 0
  then
   for j in return_parms.first..return_parms.last loop
    if ascii(substr(return_parms(j),1,1)) <> 0
     then
      dbms_pipe.pack_message(replace(replace(return_parms(j),chr(0),''),chr(10),''));
      --insert into temp values( replace(replace(return_parms(j),chr(0),''),chr(10),'') );
    end if;
   end loop;
 end if;
 dbms_pipe.pack_message('FINISH');
 status := dbms_pipe.send_message(retsess);
 commit;
exception
 when others then commit;
end image_postscript;
*/

procedure audio_index( v_umo in integer, schemaname in varchar2, howloaded in varchar2 default 'BATCH', action in varchar2 default 'INSERT' )
as

begin
 myaudio.audio_api(v_umo=>v_umo,schemaname=>schemaname,howloaded=>howloaded,action=>action);
end audio_index;

procedure video_index( v_umo in integer, schemaname in varchar2, howloaded in varchar2 default 'BATCH', action in varchar2 default 'INSERT' )
as

begin
 myvideo.video_api(v_umo=>v_umo,schemaname=>schemaname,howloaded=>howloaded,action=>action);
end video_index;

procedure relational_index( v_umo in integer, schemaname in varchar2, howloaded in varchar2 default 'BATCH', action in varchar2 default 'INSERT' )
as

begin
 myrelational.relational_api(v_umo=>v_umo,schemaname=>schemaname,howloaded=>howloaded,action=>action);
end relational_index;

procedure blueprint_index( v_umo in integer, schemaname in varchar2, howloaded in varchar2 default 'BATCH', action in varchar2 default 'INSERT' )
as

begin
 myblueprint.blueprint_api(v_umo=>v_umo,schemaname=>schemaname,howloaded=>howloaded,action=>action);
end blueprint_index;

procedure document_index( v_umo in integer, schemaname in varchar2, howloaded in varchar2 default 'BATCH', action in varchar2 default 'INSERT' )
as

 cursor c1(v_umo integer) is select * from umo where umo_id = v_umo for update nowait;
 cursor c2(v_umo integer) is select gist from ctx_gist where query_id = v_umo;
 cursor c3(v_umo integer) is select document from filtertab where query_id = v_umo;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 objlength	integer;
 document_api	varchar2(1000);

begin

   mydocument.document_api(v_umo=>v_umo,schemaname=>schemaname,howloaded=>howloaded,action=>action);

end document_index;


function c_err(code in integer)
 return varchar2
as
begin
if code = 1
 then
  return( LNG2.UMP_TXT_001 );
elsif code = 2
 then
  return( LNG2.UMP_TXT_002 );
elsif code = 3
 then
  return( LNG2.UMP_TXT_003 );
elsif code = 4
 then
  return( LNG2.UMP_TXT_004 );
elsif code = 5
 then
  return( LNG2.UMP_TXT_005 );
elsif code = 6
 then
  return( LNG2.UMP_TXT_006 );
elsif code = 7
 then
  return( LNG2.UMP_TXT_007 );
elsif code = 8
 then
  return( LNG2.UMP_TXT_008 );
elsif code = 9
 then
  return( LNG2.UMP_TXT_009 );
elsif code = 10
 then
  return( LNG2.UMP_TXT_010 );
elsif code = 11
 then
  return( LNG2.UMP_TXT_011 );
elsif code = 12
 then
  return( LNG2.UMP_TXT_012 );
elsif code = 13
 then
  return( LNG2.UMP_TXT_013 );
elsif code = 14
 then
  return( LNG2.UMP_TXT_014 );
elsif code = 15
 then
  return( LNG2.UMP_TXT_015 );
elsif code = 18
 then
  return( LNG2.UMP_TXT_018 );
end if;
return( NULL );
exception when others then
 glbx.error_details( 'UMP', 'C_ERR',errmsg=>sqlerrm,extdet=>'CODE:' || code);
end c_err;

function extract_fname( nme in varchar2 )
 return varchar2
as
begin
 for j in REVERSE 1..length( nme ) loop
  if substr(nme,j,1) in ('/','\')
   then
    return( substr(nme,j+1) );
  end if;
 end loop;
 return( nme );
end extract_fname;

function umo_modify_entry( v_umo in integer, attribid in integer, key_val in varchar2, acid in integer, position in integer, actual_api in varchar2, extract_numbers in char)
 return boolean
as

 cursor c4(v_umo integer, attr integer) is
  select 'x' cnt
  from umo_attribute
  where umo_id = v_umo and
        attribute_id = attr and
        nvl(position_id,1) = nvl(position,1);

 c4rec		c4%ROWTYPE;

begin
   open c4(v_umo,attribid);
   fetch c4 into c4rec;
   if c4%FOUND
    then
     close c4;
     update umo_attribute set value = key_val where attribute_id = attribid and umo_id = v_umo and nvl(position_id,1) = nvl(position,1);
     modify_entry( v_umo, attribid, key_val, acid, position, 'UPDATE',actual_api, extract_numbers=>extract_numbers);
    else
     close c4;
     insert into umo_attribute(umo_id,attribute_id,value,position_id,date_made) values (v_umo,attribid,key_val,position,sysdate);
     modify_entry( v_umo, attribid, key_val, acid, position, 'INSERT',actual_api, extract_numbers=>extract_numbers);
   end if;
   return( TRUE );
exception
 when others then return( FALSE );
end umo_modify_entry;

procedure meta_tag_api( password in varchar2, tag_option in varchar2, v_umo in integer, tag_type in varchar2, tag_name in varchar2, tag_value in varchar2 default null, result out varchar2 )
as
 --  cursor c1 is select admin_pw from master_piction;
 cursor c2(ttype varchar2, tname varchar2) is
  select attribute_id
  from umo_attributes
  where umo_type = ttype and
        sub_category = tname;
 cursor c3(v_umo integer) is
  select aid, umo_type
  from umo
  where umo_id = v_umo;
 cursor c4(v_umo integer, attr integer) is
  select 'x' cnt
  from umo_attribute
  where umo_id = v_umo and
        attribute_id = attr;

 -- c1rec	c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 tval		varchar2(1000);
 admin_pw	varchar2(100);
 pfx		theme%ROWTYPE;

begin
 -- Password: Admin Password
 result := NULL;
 --open c1;
 --fetch c1 into c1rec;
 --close c1;
 admin_pw := glbx.extract_master_parameter('ADMIN_PW');
 if nvl(admin_pw,'x') <> nvl( glbx.encrypt(upper(password),special_key=>DECS.ADMIN_ENCRYPT_KEY), 'y' )
  then
   result := 'Invalid Password for the ' || DECS.ADMIN_USERNAME || ' Account.';
   return;
 end if;

 open c2(tag_type,tag_name);
 fetch c2 into c2rec;
 if c2%NOTFOUND
  then
   close c2;
   result := 'Could not find the tag ' || tag_name || ' for the type ' || tag_type;
   return;
 end if;
 close c2;

 open c3(v_umo);
 fetch c3 into c3rec;
 if c3%NOTFOUND
  then
   close c3;
   result := 'Could not find the UMO_ID ' || v_umo;
   return;
 end if;
 close c3;

 pfx := glbx.get_thm( c3rec.aid );
 tval := substr(tag_value,1,1000);

 if upper(tag_option) = 'INSERT'
  then
   open c4(v_umo,c2rec.attribute_id);
   fetch c4 into c4rec;
   if c4%FOUND
    then
     close c4;
     result := 'This Tag Already Exists. Cannot INSERT. UPDATE or DELETE instead';
     return;
    end if;
    close c4;
   insert into umo_attribute(umo_id,attribute_id,value,position_id,date_made) values
    (v_umo,c2rec.attribute_id,tval,1,sysdate);

   modify_entry( v_umo, c2rec.attribute_id, tval, c3rec.aid, 1, 'INSERT',c3rec.umo_type, extract_numbers=>pfx.search_number_enable);

 elsif upper(tag_option) = 'UPDATE'
  then
   update umo_attribute set value = tval where attribute_id = c2rec.attribute_id and umo_id = v_umo;
   if SQL%NOTFOUND
    then
     rollback;
     result := 'No Value Found for this UMO_ID ' || v_umo || ' (Attribute Id:' || c2rec.attribute_id || ')';
     return;
   end if;
   modify_entry( v_umo, c2rec.attribute_id, tval, c3rec.aid, 1, 'UPDATE',c3rec.umo_type, extract_numbers=>pfx.search_number_enable);
 elsif upper(tag_option) = 'DELETE'
  then
   delete from umo_attribute where attribute_id = c2rec.attribute_id and umo_id = v_umo;
   if SQL%NOTFOUND
    then
     rollback;
     result := 'No Value Found for this UMO_ID ' || v_umo || ' (Attribute Id:' || c2rec.attribute_id || ')';
     return;
   end if;
   --delete from umo_index where attribute_id = c2rec.attribute_id and umo_id = v_umo;
   modify_entry( v_umo, c2rec.attribute_id, tval, c3rec.aid, 1, 'DELETE',c3rec.umo_type, extract_numbers=>pfx.search_number_enable);
 else
  result := 'Tag Option must be one of INSERT, UPDATE, DELETE and not the value ' || tag_option;
  return;
 end if;

 -- commit;

end meta_tag_api;

procedure meta_tag_api( password in varchar2, primary_key_tag in varchar2, primary_key_tag_value in varchar2, tag_option in varchar2, customer_username in varchar2, tag_type in varchar2, tag_name in varchar2, tag_value in varchar2 default null, create_if_not_exist in boolean default FALSE, result out varchar2 )
as

 cursor c1(tag varchar2, tagval varchar2, ttype varchar2, uname varchar2) is
  select um.umo_id
  from umo um, umo_attribute ua, umo_attributes uat
  where um.aid in (select aid from customer_account where username = uname ) and
        uat.sub_category = tag and
        uat.umo_type = ttype and
        ua.attribute_id = uat.attribute_id and
        ua.value = tagval and
        ua.umo_id = um.umo_id;

 cursor c2(tag1 varchar2, tagval1 varchar2, tag2 varchar2, tagval2 varchar2, ttype varchar2, uname varchar2) is
  select um.umo_id
  from umo um, umo_attribute ua1, umo_attributes uat1, umo_attribute ua2, umo_attributes uat2
  where um.aid in (select aid from customer_account where username = uname ) and
        uat1.sub_category = tag1 and
        uat1.umo_type = ttype and
        uat2.sub_category = tag2 and
        uat2.umo_type = ttype and
        ua1.attribute_id = uat1.attribute_id and
        ua1.value = tagval1 and
        ua1.umo_id = um.umo_id and
        ua2.attribute_id = uat2.attribute_id and
        ua2.value = tagval2 and
        ua2.umo_id = um.umo_id;

 cursor c3(uname varchar2) is select aid from customer_account where username = uname;

 c1rec	c1%ROWTYPE;
 c3rec	c3%ROWTYPE;
 pk1	varchar2(100);
 pv1	varchar2(4000);
 pk2	varchar2(100);
 pv2	varchar2(4000);

begin
 if instr(primary_key_tag,'~') = 0
  then
   open c1(primary_key_tag, primary_key_tag_value, tag_type, customer_username);
   fetch c1 into c1rec;
   if c1%NOTFOUND
    then
     close c1;
     if create_if_not_exist
      then
       -- Create Initial UMO
       open c3(customer_username);
       fetch c3 into c3rec;
       if c3%FOUND
        then
         close c3;
         init(c3rec.aid, tag_type, c1rec.umo_id );
        else
         close c3;
         result := 'The Username was not found.';
         return;
       end if;
      else
       result := 'The UMO_ID for this Customer Username and Primary Key Tag Value was not found.';
       return;
     end if;
   end if;
   close c1;
   meta_tag_api(password=>password,tag_option=>tag_option,v_umo=>c1rec.umo_id,tag_type=>tag_type,tag_name=>tag_name,tag_value=>tag_value,result=>result);
   return;
 end if;

 -- Primary Key Tag Contains Multiple Primary Keys (currently only support reference to two Primary Keys
 pk1 := substr(primary_key_tag,1,instr(primary_key_tag,'~')-1);
 pk2 := substr(primary_key_tag,instr(primary_key_tag,'~')+1);
 pv1 := substr(primary_key_tag_value,1,instr(primary_key_tag_value,'~')-1);
 pv2 := substr(primary_key_tag_value,instr(primary_key_tag_value,'~')+1);
 open c2(pk1, pv1, pk2, pv2, tag_type, customer_username);
 fetch c2 into c1rec;
 if c2%NOTFOUND
  then
   close c2;
     if create_if_not_exist
      then
       -- Create Initial UMO
       open c3(customer_username);
       fetch c3 into c3rec;
       if c3%FOUND
        then
         close c3;
         init(c3rec.aid, tag_type, c1rec.umo_id );
        else
         close c3;
         result := 'The Username was not found.';
         return;
       end if;
      else
       result := 'The UMO_ID for this Customer Username and Primary Key Tag Value was not found.';
       return;
    end if;
 end if;
 close c2;
 meta_tag_api(password=>password,tag_option=>tag_option,v_umo=>c1rec.umo_id,tag_type=>tag_type,tag_name=>tag_name,tag_value=>tag_value,result=>result);

end meta_tag_api;

procedure meta_tag_api( password in varchar2, search_on in varchar2, search_parameter in varchar2, tag_option in varchar2, customer_username in varchar2, tag_type in varchar2, tag_name in varchar2, tag_value in varchar2 default null, result out varchar2 )
as

 cursor c1(usrname varchar2, origloc varchar2) is
  select umo_id
  from umo um
  where aid in (select aid from customer_account where username = usrname ) and
        um.photo_original_loc = origloc;

 cursor c2(usrname varchar2, flm varchar2) is
  select umo_id
  from umo um
  where aid in (select aid from customer_account where username = usrname ) and
        um.extras.film_name = flm;
 c1rec	c1%ROWTYPE;

begin
 if search_on = 'ORIGINAL_LOCATION'
  then
   open c1(customer_username,search_parameter);
   fetch c1 into c1rec;
   if c1%NOTFOUND
    then
     close c1;
     result := 'The UMO_ID for this Customer Username and Original File Location was not found.';
     return;
   end if;
   close c1;
 elsif search_on = 'FILM_NAME'
  then
   open c2(customer_username,search_parameter);
   fetch c2 into c1rec;
   if c2%NOTFOUND
    then
     close c2;
     result := 'The UMO_ID for this Customer Username and Film Name was not found.';
     return;
   end if;
   close c2;
 end if;
 meta_tag_api(password=>password,tag_option=>tag_option,v_umo=>c1rec.umo_id,tag_type=>tag_type,tag_name=>tag_name,tag_value=>tag_value,result=>result);
end meta_tag_api;

function recurse_ahead( v_umo integer, lktype char, infctr in integer default 50 )
 return integer
as
  cursor c1( v_umo integer, lktype char ) is select * from umo_link where umo_id = v_umo and link_type = lktype;
  cursor c2( v_umo integer ) is select is_global from umo where umo_id = v_umo;
  c2rec c2%ROWTYPE;
  vl    integer;
 begin
  if infctr = 0 then return( null ); end if;
  for c1rec in c1( v_umo, lktype ) loop
   open c2(c1rec.to_umo_id);
   fetch c2 into c2rec;
   close c2;
   if c2rec.is_global = 'T' then return( c1rec.to_umo_id ); end if;
   vl := recurse_ahead(c1rec.to_umo_id, lktype, infctr-1);
   if vl is not null then return( vl ); end if;
  end loop;
  return( null );
end recurse_ahead;

function show_public_image( v_umo in integer, call in varchar2 default 'STANDARD' )
 return umo%ROWTYPE
as

 cursor c1( v_umo integer ) is select * from umo where umo_id = v_umo;

 c1rec		c1%ROWTYPE;
 v_count	integer;
 c_imgchunk	binary_integer;
 v_imgchunk	binary_integer;
 img		blob;
 v_buffer 	raw(32367);
 mimetype	varchar2(100);
 contentlength  integer;
 newid		integer;

begin

 open c1( v_umo );
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   return( c1rec );
 end if;
 close c1;

 -- Only Images marked as Global can be displayed
 if nvl(c1rec.is_global,'F') = 'F'
  then
   -- Check if cyclic
   newid := recurse_ahead( c1rec.umo_id, 'V' );
   if newid is null then return( c1rec ); end if;
   open c1( newid );
   fetch c1 into c1rec;
   close c1;
 end if;

 return( c1rec );

exception
 when others then return( c1rec );
end show_public_image;

procedure show_public_image( v_umo in integer, call in varchar2 default 'STANDARD' )
as

 c1rec		umo%ROWTYPE;
 v_count	integer;
 c_imgchunk	binary_integer;
 v_imgchunk	binary_integer;
 img		blob;
 v_buffer 	raw(32367);
 mimetype	varchar2(100);
 contentlength  integer;
 newid		integer;

begin

 c1rec := ump.show_public_image( v_umo, call );

 -- This procedure only supports Photo's
 if c1rec.umo_type <> 'PHOTO'
  then
   return;
 end if;

 img := c1rec.photo_master.source.localdata;
 mimetype := c1rec.photo_master.mimetype;
 contentlength := to_number(nvl(c1rec.photo_master.contentlength,'0'));
 if call = 'STANDARD'
  then
   owa_util.mime_header(nvl(mimetype,'image/jpeg'));
  else
   htp.prn( '--MIME_boundary' );
   owa_util.mime_header(nvl(mimetype,'image/jpeg'),bclose_header=>FALSE);
   htp.prn('Content-ID: ' || call || chr(10));
   owa_util.http_header_close;
 end if;
 c_imgchunk := 32367;
 v_imgchunk := 32367;
 v_count := 0;

 if call = 'STANDARD'
  then
   wpg_docload.download_file (img);

 else
   begin
    loop
     dbms_lob.read(img,v_imgchunk,(v_count*c_imgchunk)+1,v_buffer);
     v_count := v_count + 1;
     htp.prn( sys.utl_raw.cast_to_varchar2(v_buffer) );
    end loop;
   exception
    when no_data_found then null;
    when others
     then htp.p( sqlerrm );
   end;
   htp.prn( '--MIME_boundary--' );

 end if;

exception
 when others then htp.p( sqlerrm );
end show_public_image;

procedure show_public_image( name in varchar2, ctr in integer default 1, call in varchar2 default 'STANDARD' )
as

 cursor c1(name varchar2) is select umo_id from umo um where um.extras.film_name = name and is_global = 'T' order by umo_id;

 ret	 c1%ROWTYPE;
 dec_ctr integer;

begin
 dec_ctr := ctr;
 if dec_ctr < 1 then dec_ctr := 1; end if;

 for c1rec in c1(name) loop
  ret := c1rec;
  dec_ctr := dec_ctr - 1;
  if dec_ctr = 0 then exit; end if;
 end loop;
 if ret.umo_id is not null
  then
   show_public_image( ret.umo_id, call=>call );
 end if;
exception
 when others then htp.p( sqlerrm );
end show_public_image;

procedure webservice_search( surl in varchar2, result_list in UMP.SEARCH_RESULT_PHG )
as

 cursor c4(v_umo integer, utype varchar2) is
   select category, sub_category, value, edit_type, lov_list, umo_type, external_query, sql_select_mask
   from umo_attribute uta, umo_attributes ut
   where ut.attribute_id = uta.attribute_id and
         ((ut.umo_type = utype) or (ut.umo_type = 'ALL')) and
         uta.umo_id = v_umo and
         ut.displayed = 'T'
   order by ut.order_by,sub_category;

 value		varchar2(4000);
 output		varchar2(100);
 metadata	boolean;

begin
 output := GLOBAL_OUTPUT;
 metadata := GLOBAL_METADATA;

 if output = 'XML'
  then
   htp.p( '<?xml version = "1.0"?>' );
   htp.p( '<SEARCH>' );
 elsif output = 'HTML'
  then
   htp.tableopen;
 end if;

 if result_list.count >= 1
  then

   for j in result_list.first..result_list.last loop

     if output = 'XML'
      then
       htp.p( '<ROWSET>' );
     elsif output = 'HTML'
      then
        htp.tablerowopen;
     end if;

     if output = 'XML'
      then
       htp.p( '<UMO_ID>' || result_list(j).umo_id || '</UMO_ID>' );
       htp.p( '<UMO_TYPE>' || result_list(j).umo_type || '</UMO_TYPE>' );
       htp.p( '<THUMBNAIL_SIZE>' || result_list(j).photo_thumbnail.contentlength || '</THUMBNAIL_SIZE>' );
       htp.p( '<MASTER_SIZE>' || result_list(j).photo_master.contentlength || '</MASTER_SIZE>' );
       htp.p( '<ORIGINAL_SIZE>' || result_list(j).photo_original.contentlength || '</ORIGINAL_SIZE>' );
       htp.p( '<FTP_LOCATION>' || result_list(j).ftp_location || '</FTP_LOCATION>' );
       htp.p( '<FTP_DIRECTORY>' || result_list(j).ftp_virtual_dir || '</FTP_DIRECTORY>' );
       htp.p( '<PUBLIC_THUMBNAIL>' || glbx.extract_master_parameter('MERCHANT_RETURNTO_URL') || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'ump.show_public_image?v_umo=' || result_list(j).umo_id || '</PUBLIC_THUMBNAIL>' );
       htp.p( '<SECURE_THUMBNAIL>' || glbx.extract_master_parameter('MERCHANT_RETURNTO_URL') || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || owa_util.get_cgi_env('SCRIPT_NAME') || '/' ||
        soap.xmlconv( 'ump.retrieve_uma?surl=<SURL/>&parm1=UMO_ID&parm2=' || result_list(j).umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL'  || '&parm1=VERSION&parm2=' || result_list(j).version ||
                 '&parm1=LOGIN_TYPE&parm2=CUSTOMER&parm1=AID&parm2=' || to_char(result_list(j).aid)) || '</SECURE_THUMBNAIL>' );
     elsif output = 'HTML'
      then
        htp.tabledata( result_list(j).umo_id );
        htp.tabledata( result_list(j).umo_type );
        htp.tabledata( result_list(j).photo_thumbnail.contentlength );
        htp.tabledata( result_list(j).photo_master.contentlength );
        htp.tabledata( result_list(j).photo_original.contentlength );
        htp.tabledata( result_list(j).ftp_location );
        htp.tabledata( result_list(j).ftp_virtual_dir );
     end if;

     if metadata
      then
       if output = 'XML'
        then
         htp.p( '<METADATA>' );
       elsif output = 'HTML'
        then
         htp.p( '<TD>' );
         htp.tableopen;
       end if;
       for c4rec in c4( result_list(j).umo_id, result_list(j).umo_type ) loop
        value := glbx.external_query_show( result_list(j).umo_id, result_list(j).umo_type, c4rec.value, c4rec.edit_type, c4rec.lov_list, c4rec.sql_select_mask, c4rec.external_query );
        if output = 'XML'
         then
          htp.p( '<' || soap.xmlname(c4rec.sub_category) || '>' || soap.xmlconv(value) || '</' || soap.xmlname(c4rec.sub_category) || '>' );
        elsif output = 'HTML'
          then
           htp.p( '<TD>' );
           htp.tablerowopen;
            htp.tabledata( c4rec.sub_category );
            htp.tabledata( nvl(value, '&nbsp;' ) );
           htp.tablerowclose;
        end if;
       end loop;

       if output = 'XML'
        then
         htp.p( '</METADATA>' );
       elsif output = 'HTML'
        then
         htp.p( '</TD>' );
         htp.tableclose;
       end if;
     end if;

     if output = 'XML'
      then
       htp.p( '</ROWSET>' );
     elsif output = 'HTML'
      then
        htp.tablerowclose;
     end if;

    end loop;

 end if;

 if output = 'XML'
  then
   htp.p( '</SEARCH>' );
 elsif output = 'HTML'
  then
   htp.tableclose;
 end if;

end webservice_search;

--  http://mars.piction.com/pls/demo/ump.webservice?parm1=IMAGEID&parm2=15441&parm1=output&parm2=XML&parm1=METADATA&parm2=TRUE
--  http://mars.piction.com/pls/demo/ump.webservice?parm1=output&parm2=XML&parm1=METADATA&parm2=TRUE&parm1=SEARCH&parm2=herbarium&parm1=account&parm2=lcare

procedure webservice( parm1 in ump.parameters, parm2 in ump.parameters )
as

 cursor c1( v_umo integer ) is select * from umo where umo_id = v_umo;

 cursor c2(v_umo integer, utype varchar2) is
   select category, sub_category, value, edit_type, lov_list, umo_type, external_query, sql_select_mask
   from umo_attribute uta, umo_attributes ut
   where ut.attribute_id = uta.attribute_id and
         ((ut.umo_type = utype) or (ut.umo_type = 'ALL')) and
         uta.umo_id = v_umo and
         ut.displayed = 'T'
   order by ut.order_by,sub_category;

 cursor c3( acct in varchar2 ) is select * from customer_account where upper(username) = upper(acct);
 cursor c3a( acct in varchar2 ) is select * from customer_profile where upper(username) = upper(acct);

 c1rec		c1%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c3arec		c3a%ROWTYPE;
 newid		integer;

 output		varchar2(100);
 metadata	boolean;
 imageid	varchar2(100);
 value		varchar2(4000);
 src		varchar2(4000);
 acct		varchar2(4000);
 cl		varchar2(100);
 local_sec	SECURITY_DETAILS;
 vp3		GLBX.MYARRAY;

begin

 output := 'HTML';
 metadata := FALSE;
 cl := 'STANDARD';

 for j in parm1.first..parm1.last loop
  begin

   if upper(parm1(j)) = 'OUTPUT'
    then
    if upper(parm2(j)) = 'XML' then output := 'XML'; end if;
    if upper(parm2(j)) = 'HTML' then output := 'HTML'; end if;
   end if;

   if upper(parm1(j)) = 'METADATA'
    then
     if upper(parm2(j)) = 'TRUE' then metadata := TRUE; end if;
     if upper(parm2(j)) = 'FALSE' then metadata := FALSE; end if;
   end if;

   if upper(parm1(j)) = 'IMAGEID'
    then
     imageid := upper(parm2(j));
   end if;

   if upper(parm1(j)) = 'SEARCH'
    then
     src := parm2(j);
   end if;

   if upper(parm1(j)) = 'ACCOUNT'
    then
     acct := parm2(j);
   end if;

   if upper(parm1(j)) = 'CALL'
    then
     cl := parm2(j);
   end if;

  exception
   when others then null;
  end;
 end loop;

 if src is not null
  then
   open c3(acct);
   fetch c3 into c3rec;
   close c3;
   if c3rec.aid is null
    then
     open c3a(acct);
     fetch c3a into c3arec;
     close c3a;
     local_sec.ltype := 'PROFILE';
     local_sec.aid := c3arec.aid;
     local_sec.pid := c3arec.pid;
    else
     local_sec.ltype := 'OWNER';
     local_sec.aid := c3rec.aid;
     local_sec.pid := '0';
   end if;

   if local_sec.aid is not null
    then
     local_sec.query := LNG.PHG_TXT_055;
     GLOBAL_OUTPUT := output;
     GLOBAL_METADATA := metadata;
     cst.simple_search(null, p1=>trim(src), p2=>'N', p3=>vp3, acid=>local_sec.aid, age=>null, umoids=>',0,', find=>null, display_number=>null, sorton=>'N', image_dim=>'A', sec_details=>local_sec);
     /*
     delete from advanced_search where pid = local_sec.pid and aid = local_sec.aid and src_name = LNG.PHG_TXT_055 and login_type = local_sec.ltype;
     insert into advanced_search(pid,aid,order_by,src_name,keyword,clause,join_clause,
                                  umo_scene_id,cust_id,login_type,sessid,stem,is_global,ignore_lightbox,adjacent_term,notify_on_new,age,umo_scene_ids,photo_dimension,sort_on) values
       (local_sec.pid,local_sec.aid,1,LNG.PHG_TXT_055,trim(src),LNG.PHG_TXT_505,LNG.PHG_TXT_509,
        null,local_sec.aid,local_sec.ltype, null, 'F', 'F', 'F', 'F', 'F', null, null, 'A', 'N');
     ump.advanced_search_phg( surl=>null, left_api_parm=>'[' || local_sec.aid || ']' || LNG.PHG_TXT_055, start_from =>1, display_detail=>NULL, acid=>local_sec.aid, query_date=>(SYSDATE-1000), sec_details=>local_sec );
     */
     return;
   end if;
 end if;

 open c1( imageid );
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   return;
 end if;
 close c1;

 -- Only Images marked as Global can be displayed
 if nvl(c1rec.is_global,'F') = 'F'
  then
   -- Check if cyclic
   newid := recurse_ahead( c1rec.umo_id, 'V' );
   if newid is null then return; end if;
   open c1( newid );
   fetch c1 into c1rec;
   close c1;
 end if;

 if output = 'XML'
  then
   if cl = 'WEBSERVICE'
    then
     null;
    else
     htp.p( '<?xml version = "1.0"?>' );
   end if;
   htp.p( '<METADATA>' );
 elsif output = 'HTML'
  then
   htp.tableopen;
 end if;

 for c2rec in c2( c1rec.umo_id, c1rec.umo_type ) loop
  value := glbx.external_query_show( c1rec.umo_id, c1rec.umo_type, c2rec.value, c2rec.edit_type, c2rec.lov_list, c2rec.sql_select_mask, c2rec.external_query );
  if output = 'XML'
   then
    htp.p( '<' || soap.xmlname(c2rec.sub_category) || '>' || soap.xmlconv(value) || '</' || soap.xmlname(c2rec.sub_category) || '>' );
  elsif output = 'HTML'
    then
     htp.tablerowopen;
      htp.tabledata( c2rec.sub_category );
      htp.tabledata( nvl(value, '&nbsp;' ) );
     htp.tablerowclose;
  end if;
 end loop;

 if output = 'XML'
  then
   htp.p( '</METADATA>' );
 elsif output = 'HTML'
  then
   htp.tableclose;
 end if;

exception
 when others then htp.p( sqlerrm );
end webservice;

function check_image( pmaster in ORDSYS.ORDIMAGE, serrm in varchar2, scode in number )
 return varchar2
as
 retval	varchar2(1000);
 rw	raw(2);
 len	integer;
 retlen	integer;
begin
 -- Try and Attache Two Bytes FFD9 to the end of the Lob
 if sqlcode = -29400 then retval := LNG2.PBK_TXT_092; else retval := serrm; end if;
 if pmaster.mimetype not in ('image/jpeg') then return( retval ); end if; -- Only Looking at JPEG Mime Type
 len := dbms_lob.getlength(pmaster.source.localdata);
 retlen := 2;
 dbms_lob.read(pmaster.source.localdata,retlen,len-1,rw);

/*
 if not (asciistr(utl_raw.cast_to_varchar2(rw)) = '\FFFD')
  then
   retval := 'The End of File Marker in the JPEG Image was not found. Suspect that the Image File is Corrupted.';
 end if;
*/
 if not (ascii(substr(utl_raw.cast_to_varchar2(rw),1,1)) = 255 and ascii(substr(utl_raw.cast_to_varchar2(rw),2,1)) = 217)
  then
     retval := 'The End of File Marker in the JPEG Image was not found. Suspect that the Image File is Corrupted.';
 end if;

 return( retval );
exception
 when others
  then return( serrm );
end check_image;

function image_magick_load( surl in varchar2, umo_rec in umo%ROWTYPE, parm1 in UMP.PARAMETERS, parm2 in UMP.PARAMETERS )
 return boolean
as
 cursor c1( acid integer ) is select pid from customer_account where aid = acid;
 cursor c2( ext varchar2, oscmd char ) is select * from extensible_formats where file_extension = ext and os = decode(oscmd, '/', 'U', '\', 'W', 'W' );

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 retarr		UMP.MYARRAY;
 p2		UMP.MYARRAY;
 p3		UMP.MYARRAY;
 extra_umo	UMP.MYARRAY_INT;
 sfx		varchar2(100);
 cmd		integer;
 retval	        varchar2(100);

begin
 if nvl(glbx.extract_master_parameter('ENABLE_IMAGE_PROG'),'FALSE') = 'FALSE'
  then
   return( FALSE );
 end if;

 -- Try and Convert the Image as is.
 --glbx.dbg( 'IML:' || umo_rec.umo_id );
 --glbx.dbg( umo_rec.umo_id || ':' || to_char(sysdate,LNG.TSMASK));
 commit; -- release the locks on the image
 extra_umo(1) := umo_rec.umo_id;
 open c1(umo_rec.aid);
 fetch c1 into c1rec;
 close c1;

 -- This will do a straight conversion to JPEG
 -- 140, 160, 180 are reserved IMG Call Commands. 170 is for documents.

 if not find_parameter( 'MAGICK_CONVERT_ID', parm1, parm2, retval ) then retval := null; end if;
 cmd := retval;

 sfx := upper(nvl(glbx.extract_fname( umo_rec.photo_original_loc,'SUFFIX'),'JPG'));
 open c2( lower( sfx ), DECS.UNIX_OR_NT );
 fetch c2 into c2rec;
 if c2%NOTFOUND
  then
   close c2;
   return( FALSE );
 end if;
 close c2;
 p2(1) := 'P1';
 p3(1) := lower(sfx);
 p2(2) := 'P2';
 p3(2) := lower(c2rec.cvt_to);
 retarr := ump.process_image_magick( surl, c1rec.pid, umo_rec.aid, extra_umo, null, nvl(cmd,c2rec.img_cmd), 'T', 'F', p2, p3 );

 if retarr.count > 1 then return( FALSE ); else return( TRUE ); end if;
end image_magick_load;

function image_magick_watermark( surl in varchar2, v_umo in integer, acid in integer, parm1 in UMP.PARAMETERS, parm2 in UMP.PARAMETERS )
 return boolean
as
 cursor c1( acid integer ) is select pid from customer_account where aid = acid;

 c1rec		c1%ROWTYPE;
 retarr		UMP.MYARRAY;
 p2		UMP.MYARRAY;
 p3		UMP.MYARRAY;
 extra_umo	UMP.MYARRAY_INT;
 merge_id	integer;
 retval		varchar2(1000);

begin
 if nvl(glbx.extract_master_parameter('ENABLE_IMAGE_PROG'),'FALSE') = 'FALSE'
  then
   return( FALSE );
 end if;

 -- Try and Convert the Image as is.
 commit; -- release the locks on the image
 extra_umo(1) := v_umo;
 open c1(acid);
 fetch c1 into c1rec;
 close c1;
 if not find_parameter( 'MERGE_UMO_ID', parm1, parm2, retval ) then return( FALSE ); end if;
 if substr(retval,1,1) = 'T'
  then
   p2(1) := 'P1';
   p2(2) := 'P2';
   p2(3) := 'P3';
   p2(4) := 'P4';
   p2(5) := 'P5';
   if    retval = 'Text - Arial 10pt Black' then p3(1) := 'arial'; p3(2) := 'black'; p3(5) := '20';
   elsif retval = 'Text - Arial 10pt White' then p3(1) := 'arial'; p3(2) := 'white'; p3(5) := '20';
   elsif retval = 'Text - Arial 10pt Blue'  then p3(1) := 'arial'; p3(2) := 'blue';  p3(5) := '20';
   elsif retval = 'Text - Arial 12pt Black' then p3(1) := 'arial'; p3(2) := 'black'; p3(5) := '30';
   elsif retval = 'Text - Arial 12pt White' then p3(1) := 'arial'; p3(2) := 'white'; p3(5) := '30';
   elsif retval = 'Text - Arial 12pt Blue'  then p3(1) := 'arial'; p3(2) := 'blue';  p3(5) := '30';
   elsif retval = 'Text - Arial 14pt Black' then p3(1) := 'arial'; p3(2) := 'black'; p3(5) := '40';
   elsif retval = 'Text - Arial 14pt White' then p3(1) := 'arial'; p3(2) := 'white'; p3(5) := '40';
   elsif retval = 'Text - Arial 14pt Blue'  then p3(1) := 'arial'; p3(2) := 'blue';  p3(5) := '40';
   else  p3(1) := 'arial'; p3(2) := 'black'; p3(5) := '20';
   end if;
   if not find_parameter( 'MERGE_X_COORD', parm1, parm2, retval ) then retval := '0'; end if;
   p3(3) := retval;
   if not find_parameter( 'MERGE_Y_COORD', parm1, parm2, retval ) then retval := '0'; end if;
   p3(3) := p3(3) || ',' || retval;
   if not find_parameter( 'MERGE_TEXT', parm1, parm2, retval ) then retval := null; end if;
   p3(4) := replace(replace(retval,'''',''),'"','');	 -- Quotes cause problems within DOS
   if p3(4) is null then return( FALSE ); end if;
   retarr := ump.process_image_magick( surl, c1rec.pid, acid, extra_umo, null, 200, 'F', 'F', p2, p3 );

  else
   merge_id := to_number(retval);
   p3(3) := retval;
   p2(1) := 'P1';
   p2(2) := 'P2';
   p2(3) := 'WATERMARK';
   if not find_parameter( 'MERGE_X_COORD', parm1, parm2, retval ) then retval := '0'; end if;
   p3(1) := '+' || retval;
   if not find_parameter( 'MERGE_Y_COORD', parm1, parm2, retval ) then retval := '0'; end if;
   p3(1) := p3(1) || '+' || retval;
   if not find_parameter( 'MERGE_LUCENT_OFFSET', parm1, parm2, retval ) then retval := 100; end if;
   p3(2) := retval;
   retarr := ump.process_image_magick( surl, c1rec.pid, acid, extra_umo, merge_id, 100, 'F', 'F', p2, p3 );
 end if;
 insert into log_photo_mod(aid,phid,date_modified,mod_type,extra_det) values (acid,v_umo,sysdate,'WATERMARK',p3(2));
 if retarr.count > 1 then return( FALSE ); else return( TRUE ); end if;
end image_magick_watermark;

function identify_image( surl in varchar2, acid in integer, v_umo in integer, parmarr1 in out nocopy ump.parameters, parmarr2 in out nocopy  ump.parameters )
 return boolean
as
 cursor c1( acid integer ) is select pid from customer_account where aid = acid;

 c1rec		c1%ROWTYPE;
 retarr		UMP.MYARRAY;
 p2		UMP.MYARRAY;
 p3		UMP.MYARRAY;
 extra_umo	UMP.MYARRAY_INT;
 retval		varchar2(1000);
begin
 if nvl(glbx.extract_master_parameter('ENABLE_IMAGE_PROG'),'FALSE') = 'FALSE'
  then
   return( FALSE );
 end if;
 commit; -- release the locks on the image
 extra_umo(1) := v_umo;
 open c1(acid);
 fetch c1 into c1rec;
 close c1;
 p2(1) := 'P1';
 p3(1) := null;
 retarr := ump.process_image_magick( surl, c1rec.pid, acid, extra_umo, null, 810, 'F', 'F', p2, p3 );
 parmarr1 := Gparmarr1;
 parmarr2 := Gparmarr2;
 if retarr.count > 1 then return( FALSE ); else return( TRUE ); end if;
end identify_image;

function image_magick_rotate( surl in varchar2, v_umo in integer, acid in integer, rotate in varchar2, parm1 in UMP.PARAMETERS, parm2 in UMP.PARAMETERS )
 return boolean
as
 cursor c1( acid integer ) is select pid from customer_account where aid = acid;

 c1rec		c1%ROWTYPE;
 retarr		UMP.MYARRAY;
 p2		UMP.MYARRAY;
 p3		UMP.MYARRAY;
 extra_umo	UMP.MYARRAY_INT;
 retval		varchar2(1000);
 nmb		integer;

begin
 if nvl(glbx.extract_master_parameter('ENABLE_IMAGE_PROG'),'FALSE') = 'FALSE'
  then
   return( FALSE );
 end if;

 -- Try and Convert the Image as is.
 commit; -- release the locks on the image
 extra_umo(1) := v_umo;
 open c1(acid);
 fetch c1 into c1rec;
 close c1;
 p2(1) := 'P1';
 if rotate = LNG.PHG_TXT_466
  then
   p3(1) := '90';
   nmb := 110;
 elsif rotate = LNG.PHG_TXT_467
  then
   p3(1) := '270';
   nmb := 110;
 elsif rotate = LNG.PHG_TXT_468
  then
   p3(1) := '180';
   nmb := 110;
 elsif rotate = LNG.PHG_TXT_469
  then
   p3(1) := '0';
   nmb := 380; -- Special Flip Command
 end if;
 retarr := ump.process_image_magick( surl, c1rec.pid, acid, extra_umo, null, nmb, 'T', 'F', p2, p3 );
 insert into log_photo_mod(aid,phid,date_modified,mod_type,extra_det) values (acid,v_umo,sysdate,'ROTATE',p3(1));
 if retarr.count > 1 then return( FALSE ); else return( TRUE ); end if;
end image_magick_rotate;

function retrieve_email( acid integer, phgid integer, ltype varchar2 )
 return varchar2
as

 cursor c1(phgid integer) is select contact_email from photographer where pid = phgid;
 cursor c2(owner_id integer, ltype varchar2) is select contact_email from customer_contact where login_type = ltype and aid = owner_id;

 em	varchar2(100);

begin
 if ltype = 'PHOTOGRAPHER'
  then
   open c1(phgid);
   fetch c1 into em;
   close c1;
  else
   open c2(acid,ltype);
   fetch c2 into em;
   close c2;
 end if;
 return( em );
exception
 when others
  then
   glbx.error_details( 'UMP', 'RETRIEVE_EMAIL',null,null,errmsg=>sqlerrm,extdet=>'ACID:' || acid || ' PHGID:' || phgid || ' LTYPE:' || ltype);
   return( NULL );
end retrieve_email;

function check_daily_queries
 return boolean
as

 cursor c1 is
   select distinct src_name, aid, pid, login_type, date_updated, order_by
   from advanced_search
   where notify_on_new = 'T' and login_type not in ('CUSTOMER','PROFILEG')
   order by order_by;

 cursor c2(acid integer) is select pid from customer_account where aid = acid;
 cursor c3(profid integer) is select pid,aid,profile_id from customer_profile where profile_id = profid;

 cursor c4 is
   select distinct src_name, aid, pid, login_type, date_updated, order_by
   from manufacturer_search
   where notify_on_new = 'T' and login_type not in ('CUSTOMER','PROFILEG')
   order by order_by;

 cursor c5 is
   select distinct src_name, aid, pid, login_type, date_updated, order_by
   from meta_tag_query
   where notify_on_new = 'T' and login_type not in ('CUSTOMER','PROFILEG')
   order by order_by;

 em		varchar2(100);
 local_sec	SECURITY_DETAILS;
 acid		integer;

begin

 -- Check Advanced Search Queries
 for c1rec in c1 loop

   em := retrieve_email( c1rec.aid, c1rec.pid, c1rec.login_type );
   -- Run Query
   if em is not null
    then
     local_sec.ltype := c1rec.login_type;
     local_sec.aid := c1rec.aid;
     local_sec.query := c1rec.src_name;
     if nvl(c1rec.pid,0) = 0
      then
       if c1rec.login_type = 'OWNER'
        then
         open c2(c1rec.aid);
         fetch c2 into local_sec.pid;
         close c2;
        else
         open c3(c1rec.aid);
         fetch c3 into local_sec.pid,local_sec.aid,local_sec.profid;
         close c3;
       end if;
      else
       local_sec.pid := c1rec.pid;
     end if;
     local_sec.em := em;
     acid := c1rec.aid;
     ump.advanced_search_phg( surl=>null, left_api_parm=>'[' || c1rec.aid || ']' || nvl(c1rec.src_name,LNG.PHG_TXT_055), start_from =>1, display_detail=>NULL, acid=>acid, query_date=>c1rec.date_updated, sec_details=>local_sec );
   end if;
 end loop;

 -- Check Manufacturer Search Queries
 for c4rec in c4 loop

   em := retrieve_email( c4rec.aid, c4rec.pid, c4rec.login_type );
   -- Run Query
   if em is not null
    then
     local_sec.ltype := c4rec.login_type;
     local_sec.aid := c4rec.aid;
     local_sec.query := c4rec.src_name;
     if nvl(c4rec.pid,0) = 0
      then
       if c4rec.login_type = 'OWNER'
        then
         open c2(c4rec.aid);
         fetch c2 into local_sec.pid;
         close c2;
        else
         open c3(c4rec.aid);
         fetch c3 into local_sec.pid,local_sec.aid,local_sec.profid;
         close c3;
       end if;
      else
       local_sec.pid := c4rec.pid;
     end if;
     local_sec.em := em;
     acid := c4rec.aid;
     ump.manufacturer_search_phg( surl=>null, left_api_parm=>'[' || c4rec.aid || ']' || nvl(c4rec.src_name,LNG.PHG_TXT_055), start_from =>1, display_detail=>NULL, acid=>acid, query_date=>c4rec.date_updated, sec_details=>local_sec );
   end if;
 end loop;

 -- Check Meta Tag Query Search Queries
 for c5rec in c5 loop

   em := retrieve_email( c5rec.aid, c5rec.pid, c5rec.login_type );
   -- Run Query
   if em is not null
    then
     local_sec.ltype := c5rec.login_type;
     local_sec.aid := c5rec.aid;
     local_sec.query := c5rec.src_name;
     if nvl(c5rec.pid,0) = 0
      then
       if c5rec.login_type = 'OWNER'
        then
         open c2(c5rec.aid);
         fetch c2 into local_sec.pid;
         close c2;
        else
         open c3(c5rec.aid);
         fetch c3 into local_sec.pid,local_sec.aid,local_sec.profid;
         close c3;
       end if;
      else
       local_sec.pid := c5rec.pid;
     end if;
     local_sec.em := em;
     acid := c5rec.aid;
     ump.meta_tag_search( surl=>null, left_api_parm=>'[' || c5rec.aid || ']' || nvl(c5rec.src_name,LNG.PHG_TXT_055), start_from =>1, display_detail=>NULL, acid=>acid, query_date=>c5rec.date_updated, sec_details=>local_sec );
   end if;
 end loop;
 return( TRUE );
exception
 when others then
  glbx.error_details( 'UMP', 'CHECK_DAILY_QUERIES',null,null,errmsg=>sqlerrm);
  return( FALSE );
end check_daily_queries;

procedure new_images_email( sec_details in SECURITY_DETAILS, result_list in UMP.SEARCH_RESULT_PHG, totrec in integer )
as

 cursor c1(acid integer) is select * from customer_account where aid = acid;

 c1rec		c1%ROWTYPE;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;
 imgdet		varchar2(10000);

begin
 if nvl(totrec,0) = 0 then return; end if; -- Nothing to email about

 -- Called by each of the Search Procedures if a batch call is made
 open c1(sec_details.aid);
 fetch c1 into c1rec;
 close c1;
 for j in result_list.first..result_list.last loop
  imgdet := imgdet || result_list(j).extras.film_name || CHR(13) || CHR(10);
 end loop;
 gcode(1) := 'ACCOUNT_NAME';
 gparam(1) := c1rec.account_name;
 gcode(2) := 'IMAGE_DETAILS';
 gparam(2) := imgdet;
 gcode(3) := 'TOTAL_NEW_IMAGES';
 gparam(3) := totrec;
 gcode(4) := 'QUERY';
 gparam(4) := sec_details.query;
 gcode(5) := 'SIGNATURE';
 gparam(5) := glbx.extract_master_parameter('MAIL SIGNATURE');

 glbx.send( gcode, gparam, 'new_images.tmp', sec_details.em, LNG4.AHC_TXT_999 || ':' || c1rec.account_name, glbx.extract_master_parameter('MAIL_FROM'), scode=>'NI1');

end new_images_email;

procedure access_denied_image
as
fl	UTL_FILE.FILE_TYPE;
bfr	varchar2(32767);
loc	varchar2(1000);
begin
 -- Read in GIF and then dump it out
 owa_util.mime_header('image/gif');
 loc := glbx.extract_fname(glbx.extract_master_parameter('HELP_DIR'),'PWD');
 fl := utl_file.fopen( loc || 'images', '/admin/denied.gif', 'r', 32767 );
 utl_file.get_line( fl, bfr );
 utl_file.fclose(fl);
 htp.prn( bfr );
exception
 when others
  then begin utl_file.fclose(fl); exception when others then null; end; return;
end access_denied_image;

function file_copy( source in varchar2, destination in varchar2 )
 return boolean
as
  display_output GLBX.MYARRAY;
  /*
  sts 		integer;
  dm		integer;
  retsess	varchar2(100);
  result        number;
  status        number;
  */
 begin
  /*
  select s_umo_sess.nextval into retsess from dual;
  dm := dbms_pipe.create_pipe('CPROG',8192,FALSE);
  --dbms_output.put_line(dm);
  dbms_pipe.pack_message(retsess);
  dbms_pipe.pack_message(1); -- dummy value
  dbms_pipe.pack_message(1); -- dummy value
  dbms_pipe.pack_message(user); -- Schema Name
  dbms_pipe.pack_message(1);
  dbms_pipe.pack_message('COPY');
  dbms_pipe.pack_message(source);
  dbms_pipe.pack_message(destination);
  sts := dbms_pipe.send_message('CPROG',maxpipesize=>32767);
  commit;
  status := dbms_pipe.receive_message(retsess,30);
  dbms_pipe.unpack_message(result);
  if result = 994 then return( FALSE ); else return( TRUE ); end if;
  */
  return( os_command.copy( source, destination, display_output ) );
exception when others then
 return( FALSE );
end file_copy;

function file_remove( source in varchar2 )
 return boolean
as
  display_output GLBX.MYARRAY;
  /*
  sts 		integer;
  dm		integer;
  retsess	varchar2(100);
  result        number;
  status        number;
  */
 begin
  /*
  select s_umo_sess.nextval into retsess from dual;
  dm := dbms_pipe.create_pipe('CPROG',8192,FALSE);
  --dbms_output.put_line(dm);
  dbms_pipe.pack_message(retsess);
  dbms_pipe.pack_message(1); -- dummy value
  dbms_pipe.pack_message(1); -- dummy value
  dbms_pipe.pack_message(user); -- Schema Name
  dbms_pipe.pack_message(1);
  dbms_pipe.pack_message('REMOVE');
  dbms_pipe.pack_message(source);
  sts := dbms_pipe.send_message('CPROG',maxpipesize=>32767);
  commit;
  status := dbms_pipe.receive_message(retsess,30);
  dbms_pipe.unpack_message(result);
  if result = 994 then return( FALSE ); else return( TRUE ); end if;
  */
  return( os_command.delete_file( source, display_output ) );
exception when others then
 return( FALSE );
end file_remove;

function file_rename( source in varchar2, destination in varchar2 )
 return boolean
as
  display_output GLBX.MYARRAY;
  /*
  sts 		integer;
  dm		integer;
  retsess	varchar2(100);
  result        number;
  status        number;
  */
 begin
  /*
  select s_umo_sess.nextval into retsess from dual;
  dm := dbms_pipe.create_pipe('CPROG',8192,FALSE);
  --dbms_output.put_line(dm);
  dbms_pipe.pack_message(retsess);
  dbms_pipe.pack_message(1); -- dummy value
  dbms_pipe.pack_message(1); -- dummy value
  dbms_pipe.pack_message(user); -- Schema Name
  dbms_pipe.pack_message(1);
  dbms_pipe.pack_message('RENAME');
  dbms_pipe.pack_message(source);
  dbms_pipe.pack_message(destination);
  sts := dbms_pipe.send_message('CPROG',maxpipesize=>32767);
  commit;
  status := dbms_pipe.receive_message(retsess,30);
  dbms_pipe.unpack_message(result);
  if result = 994 then return( FALSE ); else return( TRUE ); end if;
  */
  return( os_command.rename_file( source, destination, display_output ) );
exception when others then
 return( FALSE );
end file_rename;

function file_extract_source( v_umo in integer, acid in integer, utype in varchar2, destination in varchar2 )
 return boolean
as
  cursor c1(v_umo integer) is select * from umo where umo_id = v_umo;
  c1rec  c1%ROWTYPE;
  status integer;
  /*
  sts 	integer;
  dm	integer;
  */
 begin
   /*
   dbms_pipe.pack_message('WRITE');
   dbms_pipe.pack_message(v_umo);
   dbms_pipe.pack_message(acid);
   dbms_pipe.pack_message(user); -- Schema Name
   dbms_pipe.pack_message(v_umo);
   dbms_pipe.pack_message('WRITE');
   dbms_pipe.pack_message(destination);
   dbms_pipe.pack_message(nvl(utype,'MASTER'));
   sts := dbms_pipe.send_message('CPROG',maxpipesize=>32767);
   return( TRUE );
   */
   open c1(v_umo);
   fetch c1 into c1rec;
   close c1;
   if c1rec.umo_type = 'PHOTO'
    then
     if utype = 'ORIGINAL'
      then
       utl_lob.unloadtofile(c1rec.photo_original.source.localdata, destination, status);
     elsif utype = 'MASTER'
      then
       utl_lob.unloadtofile(c1rec.photo_master.source.localdata, destination, status);
     elsif utype = 'THUMBNAIL'
      then
       utl_lob.unloadtofile(c1rec.photo_thumbnail.source.localdata, destination, status);
     end if;
   elsif c1rec.umo_type = 'VIDEO'
    then
     utl_lob.unloadtofile(c1rec.video_original.source.localdata, destination, status);
   elsif c1rec.umo_type = 'AUDIO'
    then
     if utype = 'ORIGINAL'
      then
       utl_lob.unloadtofile(c1rec.audio_original.source.localdata, destination, status);
     elsif utype = 'MASTER'
      then
       utl_lob.unloadtofile(c1rec.audio_original.source.localdata, destination, status);
     elsif utype = 'THUMBNAIL'
      then
       utl_lob.unloadtofile(c1rec.audio_thumbnail.source.localdata, destination, status);
     end if;
   end if;
exception when others then
 return( FALSE );
end file_extract_source;

function file_printer_template( template in varchar2, destination in varchar2, destfilename in varchar2, parm1 in UMP.MYARRAY, parm2 in UMP.MYARRAY )
 return boolean
as

    l_output          utl_file.file_type;
    l_template        utl_file.file_type;
    vbuffer           varchar2(32767);
    p_body	      varchar2(32767);

begin
   -- Template is found in report_load directory
   l_template := utl_file.fopen( glbx.extract_master_parameter('MAIL_TEMPLATE_DIR'), template, 'r', max_linesize=>32767 );
   l_output := utl_file.fopen( destination, destfilename, 'w', max_linesize=>32767 );
   loop
    begin
     p_body := NULL;
     utl_file.get_line(l_template,vbuffer);
     p_body := vbuffer;
     for j in parm1.first..parm1.last loop
      if parm1(j) is not null
       then
         p_body := replace( p_body, '<' || parm1(j) || '>', parm2(j));
      end if;
     end loop;
     utl_file.put_line( l_output, p_body);
    exception
      when others then exit;
    end;
   end loop;
   utl_file.fclose( l_output );
   utl_file.fclose( l_template );

   return( TRUE );

exception when others then
 glbx.dbg( sqlerrm );
 begin utl_file.fclose( l_output ); exception when others then null; end;
 begin utl_file.fclose( l_template ); exception when others then null; end;
 return( FALSE );
end file_printer_template;

function file_print( printer_name in varchar2, print_template in varchar2, lptid in integer default 1, parm1 in UMP.MYARRAY, parm2 in UMP.MYARRAY )
 return boolean
as
  display_output GLBX.MYARRAY;
  sts 		integer;
  dm		integer;
  retsess	varchar2(100);
  result        number;
  status        number;
  destination	varchar2(1000);
  destfilename	varchar2(1000);
 begin
  select s_umo_sess.nextval into retsess from dual;
  destination := glbx.extract_master_parameter('MAIL_OUTPUT_DIR');
  select 'P' || ltrim(to_char(mailto_seq.nextval,'0000009')) || '.txt' into destfilename from dual;
  if file_printer_template(print_template, destination, destfilename, parm1, parm2 )
   then
    /*
    dm := dbms_pipe.create_pipe('CPROG',8192,FALSE);
    --dbms_output.put_line(dm);
    dbms_pipe.pack_message(retsess);
    dbms_pipe.pack_message(1); -- dummy value
    dbms_pipe.pack_message(1); -- dummy value
    dbms_pipe.pack_message(user); -- Schema Name
    dbms_pipe.pack_message(1);
    dbms_pipe.pack_message('PRINT');
    -- dbms_pipe.pack_message('net use lpt1 ' || replace(printer_name,'\','\\'));
    dbms_pipe.pack_message('net use lpt' || to_char(lptid) || ' ' || printer_name);
    dbms_pipe.pack_message(destination || DECS.UNIX_OR_NT || destfilename);
    dbms_pipe.pack_message('LPT' || to_char(lptid) );
    dbms_pipe.pack_message('net use lpt' || to_char(lptid) || ' /d');
    if lptid = 1
     then
      -- Portrait
       dbms_pipe.pack_message('PORTRAIT' );
     else
      -- Landscape
      dbms_pipe.pack_message('LANDSCAPE' );
    end if;
    sts := dbms_pipe.send_message('CPROG',maxpipesize=>32767);
    commit;
    status := dbms_pipe.receive_message(retsess,30);
    dbms_pipe.unpack_message(result);
    if result = 994 then return( FALSE ); else return( TRUE ); end if;
    */
    return( os_command.fileprint( printer_name, destination, destfilename, lptid, display_output ));
   else
    return( FALSE );
  end if;
exception when others then
 return( FALSE );
end file_print;

function zip_wildcard( store_path_name in boolean, search_sub_directories in boolean, zip_filename in varchar2, zip_files_wildcard in varchar2 )
 return boolean
as

  cursor c6( retsess varchar2 ) is select fname,fsize from dir_results where id = retsess order by fname;

  display_output GLBX.MYARRAY;

  retsess	varchar2(100);
  bsts 		boolean;
  zip_files	UMP.MYARRAY;
  pwd		varchar2(1000);
  /*
  dm		integer;
  result        number;
  status        number;
  tot		integer;
  */

begin
   select s_umo_sess.nextval into retsess from dual;
   /*
   dm := dbms_pipe.create_pipe('CPROG',8192,FALSE);
   dbms_pipe.pack_message(retsess);
   dbms_pipe.pack_message(1);
   dbms_pipe.pack_message(1);
   dbms_pipe.pack_message(user); -- Schema Name
   dbms_pipe.pack_message(1);
   dbms_pipe.pack_message('DIRECTORY');
   dbms_pipe.pack_message(zip_files_wildcard);
   sts := dbms_pipe.send_message('CPROG',maxpipesize=>32767);
   commit;
   sts := dbms_pipe.receive_message(retsess,30);
   dbms_pipe.unpack_message(result);
   dbms_pipe.unpack_message(tot);
   */
   bsts := directory_listing( zip_files_wildcard, retsess );
   pwd := glbx.extract_fname( zip_files_wildcard, 'PWD' );
   for c6rec in c6(retsess) loop
    zip_files(c6%ROWCOUNT) := pwd || c6rec.fname;
   end loop;
   delete from dir_results where id = retsess;
   commit;

   return( zip( store_path_name, search_sub_directories, zip_filename, zip_files ));

exception when others then
 return( FALSE );
end zip_wildcard;

function zip( store_path_name in boolean, search_sub_directories in boolean, zip_filename in varchar2, zip_files in UMP.MYARRAY )
 return boolean
as
  display_output GLBX.MYARRAY;
  files_to_zip	 varchar2(30000);
  /*
  sts 		integer;
  dm		integer;
  retsess	varchar2(100);
  result        number;
  status        number;
  merge_height	integer;
  merge_x	integer;
  */
 begin
  /*
  if store_path_name then merge_height := 1; else merge_height := 0; end if;
  if search_sub_directories then merge_x := 1; else merge_x := 0; end if;
  if zip_files.count = 0 then return( FALSE ); end if;
  if zip_filename is null then return( FALSE ); end if;

  select s_umo_sess.nextval into retsess from dual;
  dm := dbms_pipe.create_pipe('CPROG',8192,FALSE);
  --dbms_output.put_line(dm);
  dbms_pipe.pack_message(retsess);
  dbms_pipe.pack_message(1); -- dummy value
  dbms_pipe.pack_message(1); -- dummy value
  dbms_pipe.pack_message(user); -- Schema Name
  dbms_pipe.pack_message(1);
  dbms_pipe.pack_message('ZIP');
  -- dbms_pipe.pack_message('net use lpt1 ' || replace(printer_name,'\','\\'));
  dbms_pipe.pack_message(merge_height);
  dbms_pipe.pack_message(merge_x);
  dbms_pipe.pack_message('myzip');
  dbms_pipe.pack_message(zip_filename );
  for j in zip_files.first..least(zip_files.last,100) loop
   dbms_pipe.pack_message(zip_files(j));
  end loop;
  dbms_pipe.pack_message('FINISH');
  sts := dbms_pipe.send_message('CPROG',maxpipesize=>32767);
  commit;
  status := dbms_pipe.receive_message(retsess,30);
  dbms_pipe.unpack_message(result);
  if result = 994 then return( FALSE ); else return( TRUE ); end if;
  */
  for j in zip_files.first..zip_files.last loop
   files_to_zip := files_to_zip || ' ' || zip_files(j);
  end loop;
  return( os_command.zip( zip_filename, search_sub_directories, store_path_name, files_to_zip, display_output ) );
exception when others then
 return( FALSE );
end zip;

function unzip( store_path_name in boolean, unzip_filename in varchar2, unzip_directory in varchar2 )
 return boolean
as
  display_output GLBX.MYARRAY;
  store_path	integer;
  /*
  sts 		integer;
  dm		integer;
  retsess	varchar2(100);
  result        number;
  status        number;
  */
 begin
  if store_path_name then store_path := 1; else store_path := 0; end if;
  if unzip_filename is null then return( FALSE ); end if;

  /*
  select s_umo_sess.nextval into retsess from dual;
  dm := dbms_pipe.create_pipe('CPROG',8192,FALSE);
  --dbms_output.put_line(dm);
  dbms_pipe.pack_message(retsess);
  dbms_pipe.pack_message(1); -- dummy value
  dbms_pipe.pack_message(1); -- dummy value
  dbms_pipe.pack_message(user); -- Schema Name
  dbms_pipe.pack_message(1);
  dbms_pipe.pack_message('UNZIP');
  dbms_pipe.pack_message(unzip_directory);
  dbms_pipe.pack_message(merge_height);
  dbms_pipe.pack_message('myunzip');
  dbms_pipe.pack_message(unzip_filename );
  dbms_pipe.pack_message('FINISH');
  sts := dbms_pipe.send_message('CPROG',maxpipesize=>32767);
  commit;
  status := dbms_pipe.receive_message(retsess,30);
  dbms_pipe.unpack_message(result);
  if result = 994 then return( FALSE ); else return( TRUE ); end if;
  */
  return( os_command.unzip( unzip_filename, unzip_directory, store_path, display_output ) );
exception when others then
 return( FALSE );
end unzip;

function random_file_name( ext in varchar2 default 'jpg' )
 return varchar2
as
 retvar	varchar2(100);
begin

 select 'tempfile_' || trim(to_char(s_filename.nextval)) || '.' || ext into retvar from dual;
 return( retvar );

exception
 when others then return( 'error.jpg' );
end random_file_name;

function random_file_location( ext in varchar2, file_suffix in varchar2 default null )
 return varchar2
as
begin
 return( glbx.extract_master_parameter( 'WORK_DIRECTORY' ) || DECS.UNIX_OR_NT || file_suffix || random_file_name( ext ) );
exception
 when others then return( 'c:\temp\error.txt' );
end random_file_location;

function random_directory
 return varchar2
as
  display_output GLBX.MYARRAY;
  source	varchar2(1000);
  bl		boolean;
  /*
  sts 		integer;
  dm		integer;
  retsess	varchar2(100);
  result        number;
  status        number;
  */
 begin
  select 'tempfile_' || trim(to_char(s_filename.nextval)) into source from dual;
  source := glbx.extract_master_parameter( 'WORK_DIRECTORY' ) || DECS.UNIX_OR_NT || source;
  bl := os_command.make_directory( source, display_output );
  return( source || DECS.UNIX_OR_NT );

exception when others then
 return( null );
end random_directory;

function directory_delete(source in varchar2)
 return boolean
as
  display_output GLBX.MYARRAY;
  /*
  sts 		integer;
  dm		integer;
  retsess	varchar2(100);
  result        number;
  status        number;
  */
 begin

  /*
  select s_umo_sess.nextval into retsess from dual;
  dm := dbms_pipe.create_pipe('CPROG',8192,FALSE);
  --dbms_output.put_line(dm);
  dbms_pipe.pack_message(retsess);
  dbms_pipe.pack_message(1); -- dummy value
  dbms_pipe.pack_message(1); -- dummy value
  dbms_pipe.pack_message(user); -- Schema Name
  dbms_pipe.pack_message(1);
  dbms_pipe.pack_message('DIRECTORY_DELETE');
  dbms_pipe.pack_message(source);
  sts := dbms_pipe.send_message('CPROG',maxpipesize=>32767);
  commit;
  status := dbms_pipe.receive_message(retsess,30);
  dbms_pipe.unpack_message(result);
  if result = 994 then return( FALSE ); else return( TRUE ); end if;
  */
  return( os_command.remove_directory( source, display_output,remove_all=>TRUE ) );
exception when others then
 return( FALSE );
end directory_delete;

procedure process_display_output( display_output GLBX.MYARRAY )
as
 x integer;
 ctr integer;
 bfr varchar2(10000);
begin
 Gparmarr1.delete;
 Gparmarr2.delete;
 if display_output.count = 0 then return; end if;
 ctr := 0;
 for j in display_output.first..display_output.last loop
  bfr := trim(display_output(j));
  x := instr(bfr,'=');
  if x > 0
   then
    ctr := ctr + 1;
    Gparmarr1(ctr) := substr(upper(bfr),1,x-1);
    Gparmarr2(ctr) := substr(bfr,x+1);
    --glbx.dbg( 'X1:' || parmarr1(ctr) );
    --glbx.dbg( 'X2:' || parmarr2(ctr) );
  end if;
 end loop;
end process_display_output;

function rip_audio( surl in varchar2, phgid in integer, jarr in integer, vparm1 in UMP.PARAMETERS, vparm2 in UMP.PARAMETERS, new_umo_id out myarray_int )
 return varchar2
as

  cursor c6( retsess varchar2 ) is select fname,fsize from dir_results where id = retsess order by fname;

  retsess	 varchar2(100);
  status         NUMBER;
  result         NUMBER;
  sts 		 integer;
  dm		 integer;
  fname		 varchar2(1000);
  fdir		 varchar2(1000);
  res		 boolean;
  ctr		 integer;
  tot		 integer;
  retval	 varchar2(1000);
  vretval	 varchar2(1000);
  e1 		 UMP.MYARRAY;
  e2 		 UMP.MYARRAY;
  parm1		 UMP.PARAMETERS;
  parm2		 UMP.PARAMETERS;
  newid_arr	 ump.myarray_int;
  display_output GLBX.MYARRAY;
  v_umo 	 ump.myarray_int;
  v 	 	 UMP.MYARRAY;
  bsts		 boolean;
  use_cddb	 varchar2(1000);
  br		 varchar2(1000);
  frm		 varchar2(1000);
  drv		 varchar2(1000);
  trks		 varchar2(1000);
  acid		 integer;
  objclass	 varchar2(100);

begin
   commit; -- Free any locks
   fdir := random_directory;
   bsts := find_parameter( 'USE_CDDB', vparm1, vparm2, use_cddb );
   if use_cddb = 'F' then use_cddb := null; else use_cddb := ' -u'; end if;
   bsts := find_parameter( 'BITRATE', vparm1, vparm2, br );
   if br = 'No Conversion' then br := null; else br := ' -b ' || br; end if;
   bsts := find_parameter( 'TRACKS', vparm1, vparm2, trks );
   if trks is not null then trks := ' "--tracks=' || trks || '"'; end if;
   bsts := find_parameter( 'AUDIO_CONVERT', vparm1, vparm2, frm );
   if br = 'No Conversion'
    then frm := null;
   elsif br = 'WMA'
    then br := ' "--output-fmt=Windows Media"';
    else br := ' -f ' || frm;
   end if;
   bsts := find_parameter( '[' || to_char(jarr) || ']FILE', vparm1, vparm2, drv );
   bsts := find_parameter( 'AUDIO_CLASS', vparm1, vparm2, objclass );
   glbx.dbg( ' "--drive=' || drv || '" -u' || br || use_cddb || trks || ' "--naming-scheme=' || fdir || '<artist>_<title>"' );
   res := os_command.audcmd_wait(' "--drive=' || drv || '" -u' || br || use_cddb || trks || ' "--naming-scheme=' || fdir || '<artist>_<title>"' , display_output );

   select s_umo_sess.nextval into retsess from dual;
   bsts := directory_listing(fdir || '*.*', retsess );
   ctr := 0;
   for c6rec in c6(retsess) loop
    if not (c6rec.fsize = 0 or
            upper(nvl(glbx.extract_fname(c6rec.fname,'SUFFIX'),'ZIP')) in ('ZIP','GZ','Z') or
            nvl(glbx.extract_fname(c6rec.fname,'NO_EXTENSION'),'.') in ('.','..')
            )
     then
       parm1.delete;
       parm2.delete;
       parm1(1)  := 'AID';
       if not find_parameter( 'AID', vparm1, vparm2, retval ) then retval := NULL; end if;
       acid := retval;
       parm2(1)  := retval;
       parm1(2)  := 'OBJECT_TYPE';
       if not find_parameter( 'OBJECT_TYPE', vparm1, vparm2, retval ) then retval := 'AUDIO'; end if;
       parm2(2)  := retval;
       parm1(3)  := 'LOAD_FROM_FILE_OR_UPLOAD';
       parm2(3)  := 'FILE';
       parm1(4)  := 'CONVERT_TO';
       if not find_parameter( 'CONVERT_TO', vparm1, vparm2, retval ) then retval := 'MP3'; end if;
       parm2(4)  := retval;
       parm1(5)  := 'COMPRESSION';
       if not find_parameter( 'COMPRESSION', vparm1, vparm2, retval ) then retval := null; end if;
       parm2(5)  := retval;
       parm1(6)  := 'LOAD_DIRECTORY';
       parm2(6)  := substr(fdir,1,length(fdir)-1);
       parm1(7)  := 'FILE_NAME';
       parm2(7)  := c6rec.fname;
       parm1(8)  := 'STORE_ORIGINAL';
       if not find_parameter( 'STORE_ORIGINAL', vparm1, vparm2, retval ) then retval := 'FALSE'; end if;
       parm2(8)  := retval;
       parm1(9)  := 'CREATE_THUMBNAIL';
       parm1(9)  := 'FALSE';
       parm1(10)  := '';
       parm1(10)  := '';
       parm1(11)  := '';
       parm1(11)  := '';
       parm1(12) := 'KEEP_STATUS';
       if not find_parameter( 'KEEP_STATUS', vparm1, vparm2, retval ) then retval := 'K'; end if;
       parm2(12) := retval;
       parm1(13) := 'ORIGINAL_LOCATION';
       parm2(13) := fdir || c6rec.fname;
       parm1(14) := 'PARENT_UMO_ID';
       if not find_parameter( 'PARENT_UMO_ID', vparm1, vparm2, retval ) then retval := null; end if;
       parm2(14) := retval;
       parm1(15) := 'SCENE_ID';
       if not find_parameter( '[' || to_char(jarr) || ']CATEGORY', vparm1, vparm2, retval ) then retval := '0'; end if;
       parm2(15) := retval;
       parm1(16) := 'UMO_OWNER';
       parm2(16) := 'PHOTOGRAPHER';
       parm1(17) := 'BYPASS_QUOTA_CHECK';
       if not find_parameter( 'BYPASS_QUOTA_CHECK', vparm1, vparm2, retval ) then retval := 'FALSE'; end if;
       parm2(17) := retval;
       parm1(18) := 'ROLL_ID';
       if not find_parameter( 'ROLL_ID', vparm1, vparm2, retval ) then retval := null; end if;
       parm2(18) := retval;
       parm1(19) := 'FILM_TYPE';
       if not find_parameter( 'FILM_TYPE', vparm1, vparm2, retval ) then retval := null; end if;
       parm2(19) := retval;
       parm1(20) := 'FILM_NAME';
       parm2(20) := glbx.extract_fname(c6rec.fname,'NO_EXTENSION');
       parm1(21) := 'NEG_NO';
       parm2(21) := to_char(c6%ROWCOUNT);
       parm1(22) := 'PHGR_ID';
       if not find_parameter( 'PHGR_ID', vparm1, vparm2, retval ) then retval := null; end if;
       parm2(22) := retval;
       parm1(23) := 'NAME';
       if not find_parameter( 'NAME', vparm1, vparm2, retval ) then retval := c6rec.fname; end if;
       parm2(23) := retval;
       parm1(24) := 'PHOTO ALBUM';
       if not find_parameter( 'PHOTO ALBUM', vparm1, vparm2, retval ) then retval := 'FALSE'; end if;
       parm2(24) := retval;
       parm1(25) := 'BRIDAL';
       if not find_parameter( 'BRIDAL', vparm1, vparm2, retval ) then retval := 'TRUE'; end if;
       parm2(25) := retval;
       parm1(26) := 'PHOTOGRAPHER';
       if not find_parameter( 'PHOTOGRAPHER', vparm1, vparm2, retval ) then retval := 'TRUE'; end if;
       parm2(26) := retval;
       parm1(27) := 'QUALITY';
       if not find_parameter( 'QUALITY', vparm1, vparm2, retval ) then retval := 'STANDARD'; end if;
       parm2(27) := retval;
       parm1(28) := 'PHOTOGRAPHER';
       if not find_parameter( 'PHOTOGRAPHER', vparm1, vparm2, retval ) then retval := 'TRUE'; end if;
       parm2(28) := retval;
       retval := null;

       ump.load_uma( surl, parm1, parm2, vretval, newid_arr );
       retval := nvl(vretval,retval);
       ctr := ctr + 1;
       new_umo_id(ctr) := newid_arr(1);
       update umo set object_class = objclass where umo_id = new_umo_id(ctr);
       if find_parameter( 'PHOTOGRAPHER', vparm1, vparm2, retval )
        then
         if not find_parameter( 'AUDIO_FORMAT', vparm1, vparm2, retval ) then retval := null; end if;
         if retval is not null
          then
           e1(1) := 'IS_TNAIL';
           e2(1) := 'TRUE';
           e1(2) := 'FORMAT';
           if retval = 'WMA' then retval := 'Windows Media'; end if;
           e2(2) := retval;
           if not find_parameter( 'AUDIO_LENGTH', vparm1, vparm2, retval ) then retval := '10'; end if;
           e1(3) := 'DURATION';
           e2(3) := retval;
           if not find_parameter( 'BITRATE', vparm1, vparm2, retval ) then retval := '128'; end if;
           e1(4) := 'BITRATE';
           e2(4) := retval;
           v_umo(1) := newid_arr(1);
           v := ump.process_audcmd( surl, phgid, acid, v_umo, 'F', e1, e2 );
         end if;
       end if;
      -- Step 9: Delete the file
      res := file_remove( fdir || c6rec.fname );
    end if;
   end loop;

   -- Step 10: Empty Directory of Results
   delete from dir_results where id = retsess;

   -- Step 11: Delete the temporary directory
   res := directory_delete( substr(fdir,1,length(fdir)-1) ); -- Remove trailing slash

   -- Step 12: Commit and Exit
   commit;
   return( retval );
exception
 when others then return( sqlerrm );
end rip_audio;

function process_audcmd( surl in varchar2, phgid in integer, acid in integer, v_umo in myarray_int, show_params in char default 'F', entered_params_p1 in UMP.MYARRAY, entered_params_p2 in UMP.MYARRAY )
 return UMP.MYARRAY
as

 cursor c4(v_umo integer) is select * from umo um where umo_id = v_umo for update nowait;
 cursor c7(acid integer) is select * from theme_types tt where theme_type in (select theme_type from customer_account where aid=acid);

 c4rec		c4%ROWTYPE;
 uniqueval	varchar2(100);
 bitrate	integer;
 format		varchar2(100);
 ext		varchar2(20);
 temp_umo	integer;
 founderr	boolean;
 tm_start	varchar2(20);
 tm_end		varchar2(20);
 cmd_call	varchar2(1000);
 cmd_call2	varchar2(1000);
 retarr		UMP.MYARRAY;
 display_output GLBX.MYARRAY;
 ifile		varchar2(4000);
 ofile		varchar2(4000);
 sts 		integer;
 load_file	bfile;
 load_dir	varchar2(4000);
 obj_length	integer;
 is_tnail	boolean;
 bl             boolean;
 ctx		raw(1000);

begin

 --bitrate := 128;
 format := 'MP3';
 ext := 'MP3';
 is_tnail := FALSE;

 for j in entered_params_p1.first..entered_params_p1.last loop
  if entered_params_p1(j) = 'IS_TNAIL' then is_tnail := TRUE; end if;
  if entered_params_p1(j) = 'BITRATE' then bitrate := glbx.guess_number(entered_params_p2(j)); end if;
  if entered_params_p1(j) = 'FORMAT'
   then
    ext := entered_params_p2(j);
    if ext = 'WMA' then format := 'Windows Media'; else format := ext; end if;
  end if;
  if entered_params_p1(j) = 'DURATION'
   then
    tm_start := '0';
    tm_end := to_char(to_number(entered_params_p2(j)) * 1000);
  end if;

 end loop;

 temp_umo := v_umo(v_umo.first);
 open c4(temp_umo);
 fetch c4 into c4rec;
 close c4;

 -- Make directory (input and output interestingly enough cannot be in the same directory)
 bl := os_command.make_directory( glbx.extract_master_parameter( 'WORK_DIRECTORY' ) || DECS.UNIX_OR_NT || 'audio', display_output );
 ofile := random_file_name( glbx.extract_fname( nvl(c4rec.audio_original_loc,'x.wav'), 'SUFFIX' ) );
 ifile := glbx.extract_master_parameter( 'WORK_DIRECTORY' ) || DECS.UNIX_OR_NT || 'audio' || DECS.UNIX_OR_NT || ofile;
 ofile := glbx.extract_master_parameter( 'WORK_DIRECTORY' ) || DECS.UNIX_OR_NT || ofile;
 utl_lob.UnloadToFile( c4rec.audio_original.source.localdata, ifile, sts );

 cmd_call := ' ' || ifile || ' "--output-fmt=' || format || '" -o "--naming-scheme=' || glbx.extract_master_parameter( 'WORK_DIRECTORY' ) || DECS.UNIX_OR_NT || '<sourcename>' || '"';
 if tm_start is not null
  then
   cmd_call := cmd_call || ' --start-time=' || tm_start || ' --end-time=' || tm_end;
 end if;
 if bitrate is not null
  then
   cmd_call := cmd_call || ' "--bitrate=' || bitrate || '"';
 end if;

 --glbx.dbg(cmd_call);
 founderr := os_command.audcmd(cmd_call, null, display_output );
 if cmd_call2 is not null
  then
   dbms_lock.sleep( 10 );
   founderr := os_command.audcmd(cmd_call2, null, display_output );
 end if;

 load_dir := glbx.extract_fname( ofile, 'PWD' );
 execute immediate 'create or replace directory ' || GLBX.GLOBAL_DIR || user || to_char(temp_umo) || ' as ''' || load_dir || '''';
 load_file := bfilename( GLBX.GLOBAL_DIR || user || to_char(temp_umo), glbx.extract_fname( ofile, 'FILE' ) );
 open c4(temp_umo);
 fetch c4 into c4rec;
 close c4;

 -- Keep looping just in case the file can be opened but not read (still writing to it)
 for j in 1..10 loop
  begin
   dbms_lob.fileopen( load_file, dbms_lob.file_readonly );
   obj_length := dbms_lob.getlength(load_file);
   exit;
  exception when others then dbms_lock.sleep(.1);
  end;
 end loop;

 for j in 1..5 loop
  begin
   if is_tnail
    then
     dbms_lob.loadfromfile( c4rec.audio_thumbnail.source.localdata, load_file, obj_length );
     update umo um set version = nvl(version,0) + 1, audio_thumbnail = c4rec.audio_thumbnail where umo_id = temp_umo;
    else
     dbms_lob.loadfromfile( c4rec.audio_original.source.localdata, load_file, obj_length );
     update umo um set version = nvl(version,0) + 1, audio_original = c4rec.audio_original where umo_id = temp_umo;
   end if;
   exit;
  exception when others then dbms_lock.sleep(.1);
  end;
 end loop;

 dbms_lob.fileclose(load_file);
 commit;

 open c4(temp_umo);
 fetch c4 into c4rec;
 close c4;
 begin
  if is_tnail
   then
    c4rec.audio_thumbnail.setproperties(ctx,TRUE);
    update umo um set version = nvl(version,0) + 1, audio_thumbnail = c4rec.audio_thumbnail where umo_id = temp_umo;
   else
    c4rec.audio_original.setproperties(ctx,TRUE);
    update umo um set version = nvl(version,0) + 1, audio_original = c4rec.audio_original where umo_id = temp_umo;
  end if;
 exception
  when others then
   retarr(retarr.count+1) := 'Main Image Set Properties:' || sqlerrm;
 end;

 founderr := os_command.delete_file( ifile, display_output, TRUE );
 founderr := os_command.delete_file( ofile, display_output, TRUE );
 -- xxx (this hangs in 10g) execute immediate 'drop directory ' || GLBX.GLOBAL_DIR || user || to_char(temp_umo);

 return( retarr );

exception
 when others then retarr(1) := sqlerrm; return( retarr );
end process_audcmd;

function process_image_magick( surl in varchar2, phgid in integer, acid in integer, v_umo in myarray_int, montage_id in integer, v_magick in integer, recreate_tnail in char, show_params in char default 'F', entered_params_p1 in UMP.MYARRAY, entered_params_p2 in UMP.MYARRAY )
 return UMP.MYARRAY
as

  cursor c1(v_magick integer) is select * from image_magick_definition where magid = v_magick;
  cursor c2(v_magick integer) is select * from image_magick_call where magid = v_magick order by order_by;
  cursor c3(v_magick integer) is select * from image_magick_param where magid = v_magick order by order_by;
  cursor c4(v_umo integer) is select * from umo um where umo_id = v_umo for update nowait;
  cursor c5(v_magick integer, parmname varchar2) is select param_type from image_magick_param where magid = v_magick and param_name = parmname;
  cursor c6(phgid integer) is select ftp_load_dir from photographer where pid = phgid;
  cursor c7(acid integer) is select * from theme_types tt where theme_type in (select theme_type from customer_account where aid=acid);

  c1rec		c1%ROWTYPE;
  c4rec		c4%ROWTYPE;
  c5rec		c5%ROWTYPE;
  c6rec		c6%ROWTYPE;
  theme_rec	theme_types%ROWTYPE;
  sts 		integer;
  wait_seconds 	integer := 30;
  retsess 	integer;
  result 	varchar2(4000);
  ctr		integer := 1;
  dm		integer;
  lockctr	integer;
  temp_umo	integer;
  uniqueval	varchar2(100);
  retarr	UMP.MYARRAY;
  parm		varchar2(1000);
  parm1		ump.parameters;
  parm2		ump.parameters;
  retval	varchar2(1000);
  founderr	boolean;
  bl		boolean;
  cmd_call	varchar2(4000);
  display_output GLBX.MYARRAY;
  calltype	varchar2(100);
  ifile		varchar2(4000);
  ofile		varchar2(4000);
  mfile		varchar2(4000);
  lfile		varchar2(4000);
  load_file	bfile;
  load_dir	varchar2(4000);
  obj_length	integer;
  ext		varchar2(100);
  ran_dir	varchar2(4000);
  fl		UTL_FILE.FILE_TYPE;
  foundfile	boolean;

 begin
 --
 -- xxx backup image if need be
 -- add audit
 --
  select s_umo_sess.nextval into retsess from dual;
  --dm := dbms_pipe.create_pipe('IMAGE_MAGICK',8192,FALSE);

    open c1(v_magick);
    fetch c1 into c1rec;
    close c1;
    temp_umo := v_umo(v_umo.first);
    --htp.bold( 'xxxx:' || c1rec.utility || '-' || v_umo(v_umo.first) || '-' || montage_id ); htp.nl;
    --dbms_pipe.pack_message(to_char(retsess));
    --dbms_pipe.pack_message(c1rec.utility); -- Command Call

    if c1rec.utility = 1
     then
      calltype := 'identify';
    elsif c1rec.utility = 2
     then
      calltype := 'mogrify';
    elsif c1rec.utility = 3
     then
      calltype := 'convert';
    elsif c1rec.utility = 4
     then
      calltype := 'montage';
    elsif c1rec.utility = 5
     then
      calltype := 'composite';
    elsif c1rec.utility = 6
     then
      calltype := 'montage'; --'convert';
    elsif c1rec.utility = 20
     then
      calltype := 'NCONVERT'; --Other Utility for Converting
    end if;
    --dbms_pipe.pack_message(user); -- Schema
    --dbms_pipe.pack_message(acid); -- ACID
    --dbms_pipe.pack_message(v_umo(v_umo.first));
    --dbms_pipe.pack_message(c1rec.reload_images);
    --if c1rec.utility in (4,5)
    -- then
    --  dbms_pipe.pack_message(montage_id);
    --end if;

  --
  -- Validate Parameters
  --
  -- xxx to be completed
  founderr := FALSE;
  for j in entered_params_p1.first..entered_params_p1.last loop
   open c5(v_magick,entered_params_p1(j));
   fetch c5 into c5rec;
   close c5;
   if c5rec.param_type = 1 -- Geometry +x+y
    then
     null;
   elsif c5rec.param_type = 2 -- Number 0-100
    then
     null;
   elsif c5rec.param_type = 3 -- Watermark UMO ID
    then
     null;
   elsif c5rec.param_type = 4 -- Number 0-360
    then
     null;
   elsif c5rec.param_type = 5 -- Number widthxheight
    then
     null;
   elsif c5rec.param_type = 6 -- Number 0-100 Compression
    then
     null;
   elsif c5rec.param_type = 7 -- Font
    then
     null;
   elsif c5rec.param_type = 8 -- Colour
    then
     null;
   elsif c5rec.param_type = 9 -- Image or Text Positioning x,y
    then
     null;
   elsif c5rec.param_type = 10 -- Free Form Text
    then
     null;
   elsif c5rec.param_type = 11 -- Pointsize/Pitch 0-100
    then
     null;
   elsif c5rec.param_type = 12 -- RadiusxSigma <2x[y]
    then
     null;
   elsif c5rec.param_type = 13 -- Frame Width XxY[+m+n]
    then
     null;
   elsif c5rec.param_type = 14 -- Photographer Directory
    then
     null;
   elsif c5rec.param_type = 15 -- Image Type
    then
     null;
   end if;

  end loop;
  if founderr then return( retarr ); end if;

  for c2rec in c2(v_magick) loop
   parm := c2rec.cmd;
   for c3rec in c3(v_magick) loop
    if entered_params_p1.count > 0
     then
      for j in entered_params_p1.first..entered_params_p1.last loop
       if entered_params_p1(j) = c3rec.param_name
        then
         parm := replace(parm, '<PICTION_PARAMETER=' || c3rec.param_name || '>',entered_params_p2(j));
       end if;
      end loop;
      if c3rec.param_type = 14 and instr(c2rec.cmd,c3rec.param_name) > 0
       then
         open c6(phgid);
         fetch c6 into c6rec;
         close c6;
         parm := c6rec.ftp_load_dir || parm;
      end if;
    end if;
   end loop;
   --dbms_pipe.pack_message( parm );
   cmd_call := cmd_call || ' ' || parm;
   if show_params = 'T' then glbx.dbg(parm ); htp.nl; end if;
  end loop;

  open c4(temp_umo);
  fetch c4 into c4rec;
  close c4;
  -- htp.p('Finish' ); htp.nl;
  if v_umo.count > 1
   then

    -- Check if Image needs to be backed up
    open c7(acid);
    fetch c7 into theme_rec;
    close c7;
    if substr(theme_rec.theme_data,64,1) = 'T' and c1rec.utility > 1 and c1rec.reload_images = 1
     then
      if (nvl(dbms_lob.getlength(c4rec.photo_backup.source.localdata),0) = 0)
       then
        begin
         c4rec.photo_master.copy(c4rec.photo_backup);
         update umo um set um.photo_backup = c4rec.photo_backup,version = nvl(version,1) + 1 where umo_id = temp_umo;
        exception
         when others then null;
        end;
        --commit;
      end if;
    end if;

    --select 'xxx_' || to_char(s_umo_sess.nextval) into uniqueval from dual;
    --dbms_pipe.pack_message( 'MORE_UMO' );
    --dbms_pipe.pack_message( uniqueval );
    --for j in (v_umo.first+1)..v_umo.last loop
    -- dbms_pipe.pack_message( to_char(v_umo(j)) ); -- Because I don't know if the type is char or number
    --end loop;
  end if;
  --dbms_pipe.pack_message( 'FINISH' );

  -- unload file to temporary directory for processing

  if instr(cmd_call,'<PICTION_PARAMETER=INPUT_FILE>') > 0
   then
    if c4rec.photo_master.mimetype = 'image/gif' then ext := 'gif'; elsif c4rec.photo_master.mimetype = 'image/png' then ext := 'png';  else ext := 'jpg'; end if;
    ifile := ump.random_file_location( ext, uniqueval );
    utl_lob.UnloadToFile( c4rec.photo_master.source.localdata, ifile, sts );
    if v_magick = 170 -- 170 is loading a document converted
     then
      ifile := '"' || ifile || '[0]' || '"'; -- Tell it to only extract the first page from the document, but only after it has downloaded it.
    end if;
    cmd_call := replace(cmd_call,'<PICTION_PARAMETER=INPUT_FILE>',ifile);
  end if;

  if instr(cmd_call,'<PICTION_PARAMETER=OUTPUT_FILE>') > 0
   then
     if c4rec.photo_master.mimetype = 'image/gif' then ext := 'gif'; elsif c4rec.photo_master.mimetype = 'image/png' then ext := 'png'; else ext := 'jpg'; end if;
     ofile := ump.random_file_location( ext, uniqueval );
     cmd_call := replace(cmd_call,'<PICTION_PARAMETER=OUTPUT_FILE>',ofile);
  end if;

  -- Create Sub directory for all these images (creating a thumbnail montage)
  if c1rec.utility = 6
   then
    ran_dir := random_directory;
    cmd_call := replace(cmd_call,'<PICTION_PARAMETER=WILDCARD>',ran_dir);

    if v_umo.first < v_umo.last
     then
      for j in v_umo.first+1..v_umo.last loop
       open c4( v_umo(j) );
       fetch c4 into c4rec;
       close c4;
       if c4rec.photo_master.mimetype = 'image/gif' then ext := 'gif'; elsif c4rec.photo_master.mimetype = 'image/png' then ext := 'png'; else ext := 'jpg'; end if;
       ifile :=  ran_dir || random_file_name(ext);
       if show_params = 'T' then glbx.dbg( 'Unloading UMO_ID ' || c4rec.umo_id || ' to ' || ifile ); htp.nl; end if;
       utl_lob.UnloadToFile( c4rec.photo_master.source.localdata, ifile, sts );
      end loop;
    end if;
  end if;

  if instr(cmd_call,'<PICTION_PARAMETER=MONTAGE_FILE>') > 0
   then
    if c1rec.utility in (4,5) and montage_id is not null
    then
     open c4( montage_id );
     fetch c4 into c4rec;
     close c4;
     if c4rec.photo_master.mimetype = 'image/gif' then ext := 'gif'; elsif c4rec.photo_master.mimetype = 'image/png' then ext := 'png'; else ext := 'jpg'; end if;
     mfile := ump.random_file_location( ext, uniqueval );
     utl_lob.UnloadToFile( c4rec.photo_master.source.localdata, mfile, sts );
    else
     if c4rec.photo_master.mimetype = 'image/gif' then ext := 'gif'; elsif c4rec.photo_master.mimetype = 'image/png' then ext := 'png'; else ext := 'jpg'; end if;
     mfile := ump.random_file_location( ext, uniqueval );
    end if;
    cmd_call := replace(cmd_call,'<PICTION_PARAMETER=MONTAGE_FILE>',mfile);
  end if;

  -- Make call to OS_COMMAND
  if show_params = 'T'
   then
    htp.nl;
    htp.italic( 'Actual Command Call:' ); htp.nl;
    glbx.dbg( calltype ); htp.nl;
    glbx.dbg( cmd_call );
  end if;
  if calltype = 'identify'
   then
    founderr := os_command.image_magick_trap_output(calltype, cmd_call, display_output );
    process_display_output( display_output );
   else
    founderr := os_command.image_magick(calltype, cmd_call, display_output );
  end if;

  if display_output.count > 0 and show_params = 'T'
   then
    htp.italic( 'Output from Command:' ); htp.nl;
    for j in display_output.first..display_output.last loop
     glbx.dbg( display_output(j) ); htp.nl;
    end loop;
  end if;

  -- reload processed file from directory

  insert into audit_image_magick(magid,pid,aid,umo_id,timestamp) values ( v_magick,phgid,acid,temp_umo,sysdate);

  if ofile is not null
   then
    lfile := ofile;
  elsif ifile is not null
   then
    lfile := ifile;
  end if;

  -- Just wait for the file to appear before trying to reverse it back
  /* --wait_not_used
  if v_magick = 170 -- 170 is loading a document converted
   then
    fl := os_command.openwait2( substr(glbx.extract_fname( lfile, 'PWD'),1,length(glbx.extract_fname( lfile, 'PWD'))-1), glbx.extract_fname( lfile, 'FILE'), 'r', 4000, maxwaits=>20, otherext=>'.0', lfile=>lfile );
   else
    fl := os_command.openwait( substr(glbx.extract_fname( lfile, 'PWD'),1,length(glbx.extract_fname( lfile, 'PWD'))-1), glbx.extract_fname( lfile, 'FILE'), 'r', 4000, maxwaits=>40 );
  end if;
  utl_file.fclose(fl);
  */

  --
  if c1rec.utility > 1 and c1rec.reload_images = 1
   then
    load_dir := glbx.extract_fname( lfile, 'PWD' );
    --
    -- This statement releases any locks so beware
    --
    execute immediate 'create or replace directory ' || GLBX.GLOBAL_DIR || user || to_char(temp_umo) || ' as ''' || load_dir || '''';
    load_file := bfilename( GLBX.GLOBAL_DIR || user || to_char(temp_umo), glbx.extract_fname( lfile, 'FILE' ) );
    -- Has to be here otherwise it complains the row is not locked
    open c4(temp_umo);
    fetch c4 into c4rec;
    close c4;

    -- Keep looping just in case the file can be opened but not read (still writing to it)
    foundfile := FALSE;
    for j in 0..10 loop
     begin
      if v_magick = 140
       then
        if j > 0
         then
          -- If multiple files are created, try finding file.3 file.2 file.1
          load_file := bfilename( GLBX.GLOBAL_DIR || user || to_char(temp_umo), glbx.extract_fname( lfile, 'FILE' ) || '.' || to_char(10-j) );
        end if;
        dbms_lob.fileopen( load_file, dbms_lob.file_readonly );
       else
        dbms_lob.fileopen( load_file, dbms_lob.file_readonly );
      end if;
      obj_length := dbms_lob.getlength(load_file);
      foundfile := TRUE;
      exit;
     exception when others then dbms_lock.sleep(.1);
     end;
    end loop;

    if foundfile
     then
      for j in 1..5 loop
       begin
        dbms_lob.loadfromfile( c4rec.photo_master.source.localdata, load_file, obj_length );
        exit;
       exception when others then dbms_lock.sleep(.1);
       end;
      end loop;

      dbms_lob.fileclose(load_file);
      begin
       c4rec.photo_master.setproperties;
       update umo um set version = nvl(version,0) + 1, photo_master = c4rec.photo_master where umo_id = temp_umo;
      exception
       when others then retarr(retarr.count+1) := 'Main Image Set Properties:' || sqlerrm;
       begin dbms_lob.fileclose(load_file); exception when others then null; end;
      end;
    end if;

    -- Free up lock
    commit;
    -- execute immediate 'drop directory ' || GLBX.GLOBAL_DIR || user || to_char(temp_umo);

    -- Cleanup Badly Loaded Image, only if it does not exist
    if not foundfile
     then
      retarr(retarr.count+1) := 'Could not find image to load:' || GLBX.GLOBAL_DIR || user || to_char(temp_umo) || DECS.UNIX_OR_NT || glbx.extract_fname( lfile, 'FILE' );
      commit;
      open c4(temp_umo);
      fetch c4 into c4rec;
      close c4;
      if dbms_lob.getlength(c4rec.photo_master.source.localdata) = 0
       then
        delete from umo_index where umo_id = temp_umo;
        delete from umo_attribute where umo_id = temp_umo;
        delete from umo where umo_id = temp_umo;
      end if;
      commit;
    end if;
   else
    foundfile := TRUE;
  end if;

  if c1rec.utility = 6
   then
    bl := directory_delete( ran_dir );
  end if;

  if recreate_tnail = 'T' and foundfile
   then
    begin
     retval := NULL;
     parm1(1) := 'UMO_ID';
     parm2(1) := v_umo(v_umo.first);
     parm1(2) := 'AID';
     parm2(2) := to_char(acid);
     parm1(3) := 'OBJECT_TYPE';
     parm2(3) := 'PHOTO';
     parm1(4) := 'KEEP_STATUS';
     parm2(4) := 'KEEP';
     parm1(5) := 'CREATE_THUMBNAIL';
     parm2(5) := 'TRUE';
     parm1(6) := 'THUMBNAIL_WIDTH';
     parm2(6) := nvl( glbx.userpref(phgid,acid,'THUMBNAIL_WIDTH'), to_char(nvl(c4rec.photo_thumbnail.width,100)) );
     parm1(7) := 'THUMBNAIL_QUALITY';
     parm2(7) := nvl( glbx.userpref(phgid,acid,'SUPER_THB'),'2');
     ump.modify_uma(surl,parm1,parm2,retval);
     if retval is not null then retarr(retarr.count+1) := 'Thumbnail Error Recreate:' || retval; end if;
    exception
     when others then retarr(retarr.count+1) := 'Thumbnail Error Recreated:' || sqlerrm;
    end;
  end if;

  commit;
  --
  -- Delete temp files
  --

  if ifile is not null and v_magick = 170
   then
    founderr := os_command.delete_file( replace(replace(ifile,'"',''),'[0]',''), display_output, TRUE );
  elsif ifile is not null
   then
    founderr := os_command.delete_file( ifile, display_output, TRUE );
  end if;

  if ofile is not null
   then
    founderr := os_command.delete_file( ofile, display_output, TRUE );
  end if;

  if mfile is not null
   then
    founderr := os_command.delete_file( mfile, display_output, TRUE );
  end if;

  if lfile is not null
   then
    founderr := os_command.delete_file( lfile, display_output, TRUE );
    if v_magick = 140
     then
      for j in 0..10 loop
       founderr := os_command.delete_file( lfile || '.' || to_char(j), display_output, TRUE );
      end loop;
    end if;
  end if;

  return( retarr );

exception
 when others then retarr(1) := sqlerrm; return( retarr );
end process_image_magick;

procedure upload_zip( surl in varchar2, ows_name in varchar2, vparm1 in UMP.PARAMETERS, vparm2 in UMP.PARAMETERS, retval out varchar2, new_umo_id out myarray_int )
as
  cursor c3( nme varchar2 ) is select blob_content from apache_ows_content where name = nme;
  cursor c6( retsess varchar2 ) is select fname,fsize from dir_results where id = retsess order by fname;

  blb		blob;
  retsess	varchar2(100);
  status        NUMBER;
  result        NUMBER;
  sts 		integer;
  dm		integer;
  fname		varchar2(1000);
  fdir		varchar2(1000);
  res		boolean;
  ctr		integer;
  tot		integer;
  vretval	varchar2(1000);
  parm1		UMP.PARAMETERS;
  parm2		UMP.PARAMETERS;
  newid_arr	ump.myarray_int;


 begin
   commit; -- Free any locks
   -- Step 1: Determine unload zip file name
   fname := random_file_name( glbx.extract_fname(ows_name,'SUFFIX') );

   -- Step 2: Determine a temporary unzip directory
   fdir := random_directory;

   -- Step 3: Unload the Zip file into a temporary area
   open c3(ows_name);
   fetch c3 into blb;
   close c3;

   utl_lob.unloadtofile(blb, fdir || fname, status);

   -- Step 4: Delete the zip file from apache_ows_content
   delete_websys( ows_name );

   -- Step 5: Unpack the zip file
   res := unzip( store_path_name=>FALSE, unzip_filename=>fdir || fname, unzip_directory=>fdir );
   -- Step 6: Delete the zip file
   -- Need to sleep five seconds just to be sure the unzip process takes place before the request to delete the file.
   --dbms_lock.sleep(5);
   res := file_remove( fdir || fname );

   -- Step 7: Get a Directory Listing of all the images
   select s_umo_sess.nextval into retsess from dual;

   -- Wait one second just to ensure the delete command has time to process the action
   -- dbms_lock.sleep(1); -- redundant with new java call that waits always for it to finish
   res := directory_listing( fdir || '*.*', retsess );
   ---htp.nl; htp.p(    fdir || '*.*' );
   ctr := 0;
   for c6rec in c6(retsess) loop
    if not (c6rec.fsize = 0 or
            upper(nvl(glbx.extract_fname(c6rec.fname,'SUFFIX'),'ZIP')) in ('ZIP','GZ','Z') or
            nvl(glbx.extract_fname(c6rec.fname,'NO_EXTENSION'),'.') in ('.','..')
            )
     then
      -- Step 8: Load the file
       parm1.delete;
       parm2.delete;
       parm1(1)  := 'AID';
       if not find_parameter( 'AID', vparm1, vparm2, retval ) then retval := NULL; end if;
       parm2(1)  := retval;
       parm1(2)  := 'OBJECT_TYPE';
       if not find_parameter( 'OBJECT_TYPE', vparm1, vparm2, retval ) then retval := 'PHOTO'; end if;
       parm2(2)  := retval;
       parm1(3)  := 'LOAD_FROM_FILE_OR_UPLOAD';
       parm2(3)  := 'FILE';
       parm1(4)  := 'CONVERT_TO';
       if not find_parameter( 'CONVERT_TO', vparm1, vparm2, retval ) then retval := 'JPEG'; end if;
       parm2(4)  := retval;
       parm1(5)  := 'COMPRESSION';
       if not find_parameter( 'COMPRESSION', vparm1, vparm2, retval ) then retval := null; end if;
       parm2(5)  := retval;
       parm1(6)  := 'LOAD_DIRECTORY';
       parm2(6)  := substr(fdir,1,length(fdir)-1);
       parm1(7)  := 'FILE_NAME';
       parm2(7)  := c6rec.fname;
       parm1(8)  := 'STORE_ORIGINAL';
       if not find_parameter( 'STORE_ORIGINAL', vparm1, vparm2, retval ) then retval := 'FALSE'; end if;
       parm2(8)  := retval;
       parm1(9)  := 'CREATE_THUMBNAIL';
       if not find_parameter( 'CREATE_THUMBNAIL', vparm1, vparm2, retval ) then retval := 'TRUE'; end if;
       parm2(9)  := retval;
       parm1(10) := 'THUMBNAIL_WIDTH';
       if not find_parameter( 'THUMBNAIL_WIDTH', vparm1, vparm2, retval ) then retval := '100'; end if;
       parm2(10) := retval;
       parm1(11) := 'THUMBNAIL_QUALITY';
       if not find_parameter( 'THUMBNAIL_QUALITY', vparm1, vparm2, retval ) then retval := null; end if;
       parm2(11) := retval;
       parm1(12) := 'KEEP_STATUS';
       if not find_parameter( 'KEEP_STATUS', vparm1, vparm2, retval ) then retval := 'K'; end if;
       parm2(12) := retval;
       parm1(13) := 'ORIGINAL_LOCATION';
       parm2(13) := fdir || c6rec.fname;
       parm1(14) := 'PARENT_UMO_ID';
       if not find_parameter( 'PARENT_UMO_ID', vparm1, vparm2, retval ) then retval := null; end if;
       parm2(14) := retval;
       parm1(15) := 'SCENE_ID';
       if not find_parameter( 'SCENE_ID', vparm1, vparm2, retval ) then retval := '0'; end if;
       parm2(15) := retval;
       parm1(16) := 'UMO_OWNER';
       parm2(16) := 'PHOTOGRAPHER';
       parm1(17) := 'BYPASS_QUOTA_CHECK';
       if not find_parameter( 'BYPASS_QUOTA_CHECK', vparm1, vparm2, retval ) then retval := 'FALSE'; end if;
       parm2(17) := retval;
       parm1(18) := 'ROLL_ID';
       if not find_parameter( 'ROLL_ID', vparm1, vparm2, retval ) then retval := null; end if;
       parm2(18) := retval;
       parm1(19) := 'FILM_TYPE';
       if not find_parameter( 'FILM_TYPE', vparm1, vparm2, retval ) then retval := null; end if;
       parm2(19) := retval;
       parm1(20) := 'FILM_NAME';
       parm2(20) := glbx.extract_fname(c6rec.fname,'NO_EXTENSION');
       parm1(21) := 'NEG_NO';
       parm2(21) := to_char(c6%ROWCOUNT);
       parm1(22) := 'PHGR_ID';
       if not find_parameter( 'PHGR_ID', vparm1, vparm2, retval ) then retval := null; end if;
       parm2(22) := retval;
       parm1(23) := 'NAME';
       if not find_parameter( 'NAME', vparm1, vparm2, retval ) then retval := c6rec.fname; end if;
       parm2(23) := retval;
       parm1(24) := 'PHOTO ALBUM';
       parm2(24) := 'FALSE';
       parm1(25) := 'BRIDAL';
       parm2(25) := 'TRUE';
       parm1(26) := 'PHOTOGRAPHER';
       parm2(26) := 'TRUE';
       parm1(27) := 'QUALITY';
       parm2(27) := 'STANDARD';
       parm1(28) := 'PHOTOGRAPHER';
       parm2(28) := 'TRUE';
       retval := null;

       ump.load_uma( surl, parm1, parm2, vretval, newid_arr );
       retval := nvl(vretval,retval);
       ctr := ctr + 1;
       new_umo_id(ctr) := newid_arr(1);

      -- Step 9: Delete the file
      res := file_remove( fdir || c6rec.fname );
    end if;
   end loop;

   -- Step 10: Empty Directory of Results
   delete from dir_results where id = retsess;

   -- Step 11: Delete the temporary directory
   res := directory_delete( substr(fdir,1,length(fdir)-1) ); -- Remove trailing slash

   -- Step 12: Commit and Exit
   commit;

exception
 when others then retval := sqlerrm;
end upload_zip;

function directory_listing(fdir in varchar2, ptr in integer )
 return boolean
as

sts 		boolean;
display_output  GLBX.MYARRAY;
arrlist 	ump.directory_list_arr;

begin
 sts := os_command.directory_listing( fdir, arrlist );
 if arrlist.count > 0
  then
   for j in arrlist.first..arrlist.last loop
    if arrlist(j).filetype = 'DIRECTORY'
     then
      insert into dir_results(uniqueid,id,fname,fsize,file_type) values (s_dir_results.nextval,ptr,arrlist(j).filename,arrlist(j).filesize,'D');
     else
      insert into dir_results(uniqueid,id,fname,fsize) values (s_dir_results.nextval,ptr,arrlist(j).filename,arrlist(j).filesize);
    end if;
   end loop;
 end if;
 return( sts );
end directory_listing;

function directory_listing(fdir in varchar2, arrlist in out NOCOPY ump.directory_list_arr)
 return boolean
as

sts 		boolean;
display_output  GLBX.MYARRAY;

begin
 sts := os_command.directory_listing( fdir, arrlist );
 return( sts );
end directory_listing;

-- xxx not yet completed
procedure unload_zip( surl in varchar2, zipfile_location in varchar2, vparm1 in UMP.PARAMETERS, vparm2 in UMP.PARAMETERS, retval out varchar2, new_umo_id out myarray_int )
as

  cursor c6( retsess varchar2 ) is select fname,fsize from dir_results where id = retsess order by fname;

  retsess	varchar2(100);
  status        NUMBER;
  result        NUMBER;
  sts 		integer;
  dm		integer;
  fname		varchar2(1000);
  fdir		varchar2(1000);
  res		boolean;
  ctr		integer;
  tot		integer;
  vretval	varchar2(1000);
  parm1		UMP.PARAMETERS;
  parm2		UMP.PARAMETERS;
  newid_arr	ump.myarray_int;
  bsts		boolean;

 begin
   commit; -- Free any locks
   -- Step 1: Determine unload zip file name
   -- Not needed, see zipfile_location
   --fname := random_file_name( glbx.extract_fname(ows_name,'SUFFIX') );

   -- Step 2: Determine a temporary unzip directory
   fdir := random_directory;

   -- Step 3: Unload the Zip file into a temporary area
   -- Not needed

   -- Step 4: Delete the zip file from apache_ows_content
   -- Not needed
   --delete_websys( ows_name );

   -- Step 5: Unpack the zip file
   res := unzip( store_path_name=>FALSE, unzip_filename=>zipfile_location, unzip_directory=>fdir );

   -- Step 6: Delete the zip file
   -- Not needed
   --res := file_remove( fdir || fname );

   -- Step 7: Get a Directory Listing of all the images
   select s_umo_sess.nextval into retsess from dual;

   /*
   dm := dbms_pipe.create_pipe('CPROG',8192,FALSE);
   dbms_pipe.pack_message(retsess);
   dbms_pipe.pack_message(1);
   dbms_pipe.pack_message(1);
   dbms_pipe.pack_message(user); -- Schema Name
   dbms_pipe.pack_message(1);
   dbms_pipe.pack_message('DIRECTORY');
   dbms_pipe.pack_message(fdir || '*.*');
   sts := dbms_pipe.send_message('CPROG',maxpipesize=>32767);
   commit;
   sts := dbms_pipe.receive_message(retsess,30);
   dbms_pipe.unpack_message(result);
   dbms_pipe.unpack_message(tot);
   */
   bsts := directory_listing(fdir || '*.*', retsess );
   ctr := 0;
   for c6rec in c6(retsess) loop
    if not (c6rec.fsize = 0 or
            upper(nvl(glbx.extract_fname(c6rec.fname,'SUFFIX'),'ZIP')) in ('ZIP','GZ','Z') or
            nvl(glbx.extract_fname(c6rec.fname,'NO_EXTENSION'),'.') in ('.','..')
            )
     then
      -- Step 8: Load the file
       parm1.delete;
       parm2.delete;
       parm1(1)  := 'AID';
       if not find_parameter( 'AID', vparm1, vparm2, retval ) then retval := NULL; end if;
       parm2(1)  := retval;
       parm1(2)  := 'OBJECT_TYPE';
       if not find_parameter( 'OBJECT_TYPE', vparm1, vparm2, retval ) then retval := 'PHOTO'; end if;
       parm2(2)  := retval;
       parm1(3)  := 'LOAD_FROM_FILE_OR_UPLOAD';
       parm2(3)  := 'FILE';
       parm1(4)  := 'CONVERT_TO';
       if not find_parameter( 'CONVERT_TO', vparm1, vparm2, retval ) then retval := 'JPEG'; end if;
       parm2(4)  := retval;
       parm1(5)  := 'COMPRESSION';
       if not find_parameter( 'COMPRESSION', vparm1, vparm2, retval ) then retval := null; end if;
       parm2(5)  := retval;
       parm1(6)  := 'LOAD_DIRECTORY';
       parm2(6)  := substr(fdir,1,length(fdir)-1);
       parm1(7)  := 'FILE_NAME';
       parm2(7)  := c6rec.fname;
       parm1(8)  := 'STORE_ORIGINAL';
       if not find_parameter( 'STORE_ORIGINAL', vparm1, vparm2, retval ) then retval := 'FALSE'; end if;
       parm2(8)  := retval;
       parm1(9)  := 'CREATE_THUMBNAIL';
       if not find_parameter( 'CREATE_THUMBNAIL', vparm1, vparm2, retval ) then retval := 'TRUE'; end if;
       parm2(9)  := retval;
       parm1(10) := 'THUMBNAIL_WIDTH';
       if not find_parameter( 'THUMBNAIL_WIDTH', vparm1, vparm2, retval ) then retval := '100'; end if;
       parm2(10) := retval;
       parm1(11) := 'THUMBNAIL_QUALITY';
       if not find_parameter( 'THUMBNAIL_QUALITY', vparm1, vparm2, retval ) then retval := null; end if;
       parm2(11) := retval;
       parm1(12) := 'KEEP_STATUS';
       if not find_parameter( 'KEEP_STATUS', vparm1, vparm2, retval ) then retval := 'K'; end if;
       parm2(12) := retval;
       parm1(13) := 'ORIGINAL_LOCATION';
       parm2(13) := fdir || c6rec.fname;
       parm1(14) := 'PARENT_UMO_ID';
       if not find_parameter( 'PARENT_UMO_ID', vparm1, vparm2, retval ) then retval := null; end if;
       parm2(14) := retval;
       parm1(15) := 'SCENE_ID';
       if not find_parameter( 'SCENE_ID', vparm1, vparm2, retval ) then retval := '0'; end if;
       parm2(15) := retval;
       parm1(16) := 'UMO_OWNER';
       parm2(16) := 'PHOTOGRAPHER';
       parm1(17) := 'BYPASS_QUOTA_CHECK';
       if not find_parameter( 'BYPASS_QUOTA_CHECK', vparm1, vparm2, retval ) then retval := 'FALSE'; end if;
       parm2(17) := retval;
       parm1(18) := 'ROLL_ID';
       if not find_parameter( 'ROLL_ID', vparm1, vparm2, retval ) then retval := null; end if;
       parm2(18) := retval;
       parm1(19) := 'FILM_TYPE';
       if not find_parameter( 'FILM_TYPE', vparm1, vparm2, retval ) then retval := null; end if;
       parm2(19) := retval;
       parm1(20) := 'FILM_NAME';
       parm2(20) := glbx.extract_fname(c6rec.fname,'NO_EXTENSION');
       parm1(21) := 'NEG_NO';
       parm2(21) := to_char(c6%ROWCOUNT);
       parm1(22) := 'PHGR_ID';
       if not find_parameter( 'PHGR_ID', vparm1, vparm2, retval ) then retval := null; end if;
       parm2(22) := retval;
       parm1(23) := 'NAME';
       if not find_parameter( 'NAME', vparm1, vparm2, retval ) then retval := c6rec.fname; end if;
       parm2(23) := retval;
       parm1(24) := 'PHOTO ALBUM';
       if not find_parameter( 'PHOTO ALBUM', vparm1, vparm2, retval ) then retval := 'FALSE'; end if;
       parm2(24) := retval;
       parm1(25) := 'BRIDAL';
       if not find_parameter( 'BRIDAL', vparm1, vparm2, retval ) then retval := 'TRUE'; end if;
       parm2(25) := retval;
       parm1(26) := 'PHOTOGRAPHER';
       if not find_parameter( 'PHOTOGRAPHER', vparm1, vparm2, retval ) then retval := 'TRUE'; end if;
       parm2(26) := retval;
       parm1(27) := 'QUALITY';
       if not find_parameter( 'QUALITY', vparm1, vparm2, retval ) then retval := 'STANDARD'; end if;
       parm2(27) := retval;
       parm1(28) := 'PHOTOGRAPHER';
       if not find_parameter( 'PHOTOGRAPHER', vparm1, vparm2, retval ) then retval := 'TRUE'; end if;
       parm2(28) := retval;
       retval := null;

       ump.load_uma( surl, parm1, parm2, vretval, newid_arr );
       retval := nvl(vretval,retval);
       ctr := ctr + 1;
       new_umo_id(ctr) := newid_arr(1);

      -- Step 9: Delete the file
      res := file_remove( fdir || c6rec.fname );
    end if;
   end loop;

   -- Step 10: Empty Directory of Results
   delete from dir_results where id = retsess;

   -- Step 11: Delete the temporary directory
   res := directory_delete( substr(fdir,1,length(fdir)-1) ); -- Remove trailing slash

   -- Step 12: Commit and Exit
   commit;

exception
 when others then retval := sqlerrm;
end unload_zip;

procedure set_timestamp( v_umo in integer, com in varchar2 )
as
begin
 null;
 --insert into timings( debug_step, load_id, step_time) values (com, v_umo, systimestamp );
end set_timestamp;

procedure load_uma_exit( password in varchar2, parm1 in UMP.PARAMETERS, parm2 in UMP.PARAMETERS, retval out varchar2, new_umo_id out myarray_int )
as

 admin_pw	varchar2(100);

begin
 admin_pw := glbx.extract_master_parameter('ADMIN_PW');
 if nvl(admin_pw,'x') <> nvl( glbx.encrypt(upper(password),special_key=>DECS.ADMIN_ENCRYPT_KEY), 'y' )
  then
   retval := 'Invalid Password for the ' || DECS.ADMIN_USERNAME || ' Account.';
   return;
 end if;

 load_uma( null, parm1, parm2, retval, new_umo_id, TRUE );

end load_uma_exit;

procedure resize_master( pimg in out ORDSYS.ORDIMAGE, ctx in out raw )
as

 rt	number;
 smsg	varchar2(1000);
 tblob	blob;
 x	integer;
 y	integer;
 sml	boolean;

begin
 dbms_lob.createtemporary(tblob, FALSE);
 dbms_lob.copy(tblob, pimg.source.localdata, 1, dbms_lob.getlength( pimg.source.localdata ) );

 -- First Attempt
 rt := round( 80000 / pimg.contentlength, 2 ) * 1.5;
 pimg.process( 'scale=' || trim(to_char(rt,'990.99')) );

 if pimg.contentlength < 65000
  then
   -- Back it out
   dbms_lob.copy(pimg.source.localdata, tblob, 1, dbms_lob.getlength( tblob ) );
   pimg.setproperties;
 elsif pimg.contentlength > 95000
  then
   null; -- Lets try again
 else
  dbms_lob.freetemporary( tblob );
  return;
 end if;

 -- Second Attempt
 -- rt := round( 80000 / pimg.contentlength, 2 );
 pimg.process( 'maxscale=(500 500)');

 if pimg.contentlength < 65000
  then
   -- Back it out
   dbms_lob.copy(pimg.source.localdata, tblob, 1, dbms_lob.getlength( tblob ) );
   pimg.setproperties;
   sml := TRUE;
 elsif pimg.contentlength > 95000
  then
   sml := FALSE; -- Lets try again
 else
  dbms_lob.freetemporary( tblob );
  return;
 end if;

 -- Third Attempt
 if sml
  then
   pimg.process( 'maxscale=(750 750)');
  else
   pimg.process( 'maxscale=(400 400)');
 end if;

 if pimg.contentlength < 65000
  then
   -- Back it out
   dbms_lob.copy(pimg.source.localdata, tblob, 1, dbms_lob.getlength( tblob ) );
   pimg.setproperties;
 elsif pimg.contentlength > 95000
  then
   null; -- Lets try again
 else
  dbms_lob.freetemporary( tblob );
  return;
 end if;

 -- Fourth Attempt
 if sml
  then
   pimg.process( 'maxscale=(1000 1000)');
  else
   pimg.process( 'maxscale=(250 250)');
 end if;

 -- We live with the result
 dbms_lob.freetemporary( tblob );

exception
 when others then
  smsg := sqlerrm;
  insert into debug(inf) values ( smsg );
  dbms_lob.freetemporary( tblob );
end resize_master;

function create_document_tnail( surl varchar2, v_umo integer )
 return varchar2
as
 cursor c1(v_umo integer) is select * from umo where umo_id = v_umo for update;

 umo_rec	c1%ROWTYPE;
 parm1		UMP.PARAMETERS;
 parm2		UMP.PARAMETERS;
 bl		boolean;

begin
 --
 open c1(v_umo);
 fetch c1 into umo_rec;
 close c1;
 parm1(1) := 'MAGICK_CONVERT_ID';
 parm2(1) := '170';
 dbms_lob.copy(umo_rec.photo_master.source.localdata, umo_rec.doc_body, dbms_lob.getlength(umo_rec.doc_body) );
 bl := image_magick_load(surl, umo_rec, parm1, parm2);
 if bl
  then
   commit;
   return( null );
  else
   return( 'Failed to Create' );
 end if;
exception
 when others then return( sqlerrm );
end create_document_tnail;

function create_directory_images(surl in varchar2, acid in integer )
 return boolean
as

 cursor c1(acid integer) is
  select distinct umo_scene_id, um.extras.orderby_scene usc1, um.extras.title usc2
  from umo um
  where um.aid = acid and
        um.umo_type in ('PHOTO','DOCUMENT');

 cursor c2(acid integer, uscid integer) is
  select umo_id, attribute2
  from umo um
  where umo_scene_id = uscid and
        um.aid = acid and
        object_class = 'DIRECTORY';

 cursor c3(v_umo integer, uscid integer, acid integer) is
  select umo_id
  from umo um
  where umo_scene_id = uscid and
        aid = acid and
        umo_id <> v_umo and
        nvl(object_class,'!') <> 'DIRECTORY' and
        umo_type in ('PHOTO','DOCUMENT')
  order by um.extras.orderby_scene;

 cursor c4( acid integer ) is select pid from customer_account where aid = acid;

 c2rec		c2%ROWTYPE;
 vpid		integer;
 v_umo		integer;
 retarr		UMP.MYARRAY;
 extra_umo	UMP.MYARRAY_INT;
 p2		UMP.MYARRAY;
 p3		UMP.MYARRAY;

begin
 open c4(acid);
 fetch c4 into vpid;
 close c4;

 for c1rec in c1( acid ) loop
  c2rec.umo_id := null;
  open c2( acid, c1rec.umo_scene_id );
  fetch c2 into c2rec;
  close c2;
  if c2rec.umo_id is null
   then
    init( acid, utype=>'PHOTO', v_umo=>v_umo );
    update umo
     set
      object_class = 'DIRECTORY',
      attribute2 = 'F',
      sort_priority = 0,
      umo_scene_id = c1rec.umo_scene_id
    where
     umo_id = v_umo;
    c2rec.attribute2 := 'F';
   else
    v_umo := c2rec.umo_id;
  end if;
  if nvl(c2rec.attribute2,'F') = 'F'
   then
    extra_umo.delete;
    extra_umo(1) := v_umo;
    for c3rec in c3(v_umo,c1rec.umo_scene_id,acid) loop
     extra_umo( c3%ROWCOUNT + 1 ) := c3rec.umo_id;
     if c3%ROWCOUNT >= 18 then exit; end if; -- To ensure it is neat and tidy
    end loop;
    p2(1) := 'P1';
    p3(1) := '4';
    p2(2) := 'P2';
    p3(2) := '400x600';
    if extra_umo.count > 2 -- Need more than one image to create a visual directory
     then
      retarr := ump.process_image_magick( surl, vpid, acid, extra_umo, v_umo, 130, 'T', 'F', p2, p3 );
      if retarr.count = 1 then glbx.dbg( retarr(1) ); end if;
      update umo um
       set
        um.extras.orderby_nmb = 0,
        um.extras.photo_name = 'Directory',
        um.extras.film_name = 'Directory',
        um.extras.orderby_scene = c1rec.usc1,
        um.extras.title = c1rec.usc2,
        um.extras.quality = 'STANDARD',
        version = 1,
        attribute2 = 'T'
      where
       umo_id = v_umo;
    end if;
    delete from umo um where umo_id = v_umo and dbms_lob.getlength(um.photo_master.source.localdata) = 0;
    commit;
  end if;
 end loop;
 return( TRUE );
exception when others then
 glbx.error_details( 'UMP', 'CREATE_DIRECTORY_IMAGES',acid,errmsg=>sqlerrm);
end create_directory_images;

function attach_metadata( surl in varchar2, doc in sys.xmldom.DOMDocument, v_umo in integer)
 return boolean
as

cursor c1( tag in varchar2, v_umo in integer ) is
 select uas.attribute_id
 from umo_attribute ua, umo_attributes uas
 where ua.attribute_id = uas.attribute_id and
       ua.umo_id = v_umo and
       upper(uas.sub_category) = upper(tag);

cursor c2( v_umo integer ) is select umo_type, aid from umo where umo_id = v_umo;

c1rec		c1%ROWTYPE;
c2rec		c2%ROWTYPE;
nl 		sys.xmldom.DOMNodeList;
len1 		number;
n 		sys.xmldom.DOMNode;
e 		sys.xmldom.DOMElement;
n_child 	sys.xmldom.DOMNode;
lasttag		varchar2(1000);
tag		varchar2(1000);
val		varchar2(1000);
pfx		theme%ROWTYPE;

function getval( n_child in sys.xmldom.DOMNode )
 return varchar2
as
begin
  if not sys.xmldom.IsNull(n_child)
   then
    return( sys.xmldom.getNodeValue(n_child) );
   else
    return( NULL );
  end if;
end getval;

begin

 open c2(v_umo);
 fetch c2 into c2rec;
 close c2;
 pfx := glbx.get_thm( c2rec.aid );

 nl := sys.xmldom.getElementsByTagName(doc, '*');
 len1 := sys.xmldom.getLength(nl);
 lasttag := NULL;

 -- loop through elements
 for j in 0..len1-1 loop
  n := sys.xmldom.item(nl, j);
  e := sys.xmldom.makeElement(n);
  n_child:= sys.xmldom.getFirstChild(n);
  tag := sys.xmldom.getTagName(e);

  if getval(n_child) is not null
   then
    val := getval(n_child);
  end if;
  -- tag is attribute_name
  -- val is its value
  if upper(tag) = 'METADATA'
   then
    null;
   else
    c1rec.attribute_id := null;
    open c1( tag, v_umo );
    fetch c1 into c1rec;
    close c1;
    if c1rec.attribute_id is not null
     then
      if umo_modify_entry(v_umo, c1rec.attribute_id, val, c2rec.aid, 1, c2rec.umo_type, pfx.search_number_enable ) then null; end if;
     end if;
  end if;
 end loop;
 commit;
 return( TRUE );
exception
 when others then return( FALSE );
end attach_metadata;

end ump;

/
