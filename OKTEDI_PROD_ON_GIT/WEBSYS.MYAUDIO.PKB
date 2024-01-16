CREATE OR REPLACE package body WEBSYS.myaudio as

 function findparm( vload_id integer, p1 in varchar2 ) return varchar2;
 function findparm3( vload_id integer, p3 in varchar2 ) return varchar2;

 -- Test if extension of filename is a audio one
 function audio_api( v_filename varchar2 )
  return char
 as

  ext	varchar2(100);

 begin
  ext := upper(glbx.extract_fname( v_filename, 'SUFFIX' ));
  if ext in ('AFF','AFT','AU','MP3','WAV')
   then
    return( 'T' ); -- Note: Cannot return a boolean due to the limitations of dynamic SQL and booleans
   else
    return( 'F' );
  end if;

 end audio_api;

 -- Modify Meta Tag
 procedure audio_api(v_umo integer, attrib_id integer, data_value varchar2, acid integer, posid integer, action varchar2 )
 as
  tokens	ump.myarray;
  retstmt	varchar2(100);

 begin
  if action in ('UPDATE','DELETE')
   then
    delete from umo_index where umo_id = v_umo and attribute_id = attrib_id and aid = acid and position_id = posid;
  end if;
  if action = 'DELETE' then return; end if;
  retstmt := ump.extract_tokens( data_value, 1, FALSE, tokens );
  if not tokens.exists( 1 ) then return; end if; -- Nothing extracted
  for j in tokens.first..tokens.last loop
   insert into umo_index(umo_id, aid, attribute_id, word_original,word_upper,word_soundex,ordering,position_id) values
    (v_umo, acid, attrib_id, tokens(j), upper(tokens(j)), soundex_api(tokens(j),attrib_id), j, posid);
  end loop;
 end audio_api;

 -- Mass Modification
 procedure audio_api(v_umo integer, new_acid integer, old_acid integer, action varchar2 )
 as
 begin
  null;
 end audio_api;

 -- This API is called whilst loading the audio
 -- How Loaded is BATCH or BROWSER
 -- ACTION is INSERT, UPDATE, DELETE

 procedure audio_api(v_umo integer, schemaname varchar2, howloaded varchar2, action varchar2 )
 as

  cursor c1(v_umo integer) is select * from umo where umo_id = v_umo for update;
  cursor c2 is select to_number(substr(version,1,instr(version,'.')-1)) vrs from v$instance;

  c1rec  c1%ROWTYPE;
  c2rec  c2%ROWTYPE;

  ext	varchar2(100);
  mtype	varchar2(100);
  ctx	raw(64) := NULL;

 begin
  -- Step 1: Extract the suffix and set the mime type
  open c1(v_umo);
  fetch c1 into c1rec;
  close c1;
  ext := upper(glbx.extract_fname( c1rec.audio_original_loc, 'SUFFIX' ));
  if ext in ('AFF','AIF','AIFF')    then mtype := 'audio/x-aiff';
  elsif ext in ('AFT') then mtype := 'audio/x-aiff';
  elsif ext in ('AU')  then mtype := 'audio/basic';
  elsif ext in ('MP3') then mtype := 'audio/mpeg3';
  elsif ext in ('WAV') then mtype := 'audio/x-wav';
  elsif ext in ('ASF') then mtype := 'audio/x-asf';
  end if;

  open c2;
  fetch c2 into c2rec;
  close c2;

  if mtype is not null and c2rec.vrs < 10
   then
    update umo um
     set
      um.audio_original.mimetype = mtype,
      um.extras.film_name = glbx.extract_fname( c1rec.audio_original_loc, 'NO_EXTENSION' ),
      um.extras.photo_name = glbx.extract_fname( c1rec.audio_original_loc, 'NO_EXTENSION' )
    where
     umo_id = v_umo;
    commit;
   else
    dbms_output.put_line('Length:' || dbms_lob.getlength(c1rec.audio_original.source.localdata));
    c1rec.audio_original.setproperties(ctx, TRUE);
    update umo um
     set
      um.extras.film_name = glbx.extract_fname( c1rec.audio_original_loc, 'NO_EXTENSION' ),
      um.extras.photo_name = glbx.extract_fname( c1rec.audio_original_loc, 'NO_EXTENSION' ),
      um.audio_original = c1rec.audio_original
    where
     umo_id = v_umo;
    commit;
  end if;

 exception
  when ordsys.ordaudioexceptions.method_not_supported then
   dbms_output.put_line('ORDAudioExceptions.METHOD_NOT_SUPPORTED caught');
  --when others then glbx.dbg( 'Audio Set Properties:' || sqlerrm );
 end audio_api;

 procedure audio_api(origfile in varchar2, filetype out varchar2, mimetype out varchar2 )
 as
  extn	varchar2(1000);
 begin
  extn := upper(glbx.extract_fname( origfile, 'SUFFIX' ));
  if extn is NULL or origfile is null
   then
    extn := 'WAVE';
  end if;
 -- Oracle Supported file types: MPGA,RMFF,WAVE,AIFC,AIFF,ASF,AUFF,MP4

 filetype := extn;
 if extn in ('MP3')
  then
   mimetype := 'audio/mpeg3';
   filetype := 'MPGA';
  elsif extn in ('WAVE','WAV')
  then
   mimetype := 'audio/x-wav';
   filetype := 'WAVE';
  elsif extn in ('AFF','AIF','AIFF')
  then
   mimetype := 'audio/x-aiff';
   filetype := 'AIFF';
  elsif extn in ('AU')
  then
   mimetype := 'audio/aiff';
   filetype := 'AUFF';
  elsif extn in ('ASF')
  then
   mimetype := 'audio/x-asf';
   filetype := 'ASF';
  else
   mimetype := 'audio/x-wav';
   filetype := 'WAVE';
 end if;

exception when others then
 glbx.error_details( 'MYAUDIO', 'AUDIO_API',errmsg=>sqlerrm, extdet=>'ORIGFILE:' || origfile);
end audio_api;

 -- This Object Displays the UMO Thumbnail Representation
 function reformat( p1 in varchar2 )
  return varchar2
 as
 begin
  if p1 = 'MPGA' then return( 'MP3' ); end if;
  if p1 = 'WAVE' then return( 'Wave' ); end if;
  if p1 = 'AIFF' then return( 'Aiff' ); end if;
  if p1 = 'AUFF' then return( 'Au' ); end if;
  if p1 = 'ASF' then return( 'Asf' ); end if;
 end reformat;

 procedure audio_api(surl in varchar2, umo_rec in integer, theme_data in CHAR, left_api_parm in VARCHAR2, current_page_number in integer, display_detail in varchar2, footer_api in varchar2, ltype in varchar2, acid in integer )
 as

  cursor c1(v_umo integer) is
   select aid,
          object_class,
          um.audio_original.mimetype mtype,
          um.photo_thumbnail.contentlength cl,
          version,
          um.photo_thumbnail.width width,
          um.photo_thumbnail.height height,
          audio_original aol,
          audio_thumbnail atl
   from umo um
   where umo_id = v_umo;
  cursor c2(acid integer) is select * from theme where theme_name in (select theme_name from customer_account where aid = acid );

  c1rec	 c1%ROWTYPE;

  url_phg	 varchar2(1000);
  url_ori 	varchar2(1000);
  url_thb 	varchar2(1000);
  trg	 	varchar2(100);
  alt	 	varchar2(100);
  pfx	 	THEME%ROWTYPE;
  xltype 	varchar2(100);

 begin
  htp.p( '<CENTER>' );
  open c1(umo_rec);
  fetch c1 into c1rec;
  close c1;
  open c2(c1rec.aid);
  fetch c2 into pfx;
  close c2;

  xltype := ltype;
  if xltype = 'PHOTOGRAPHERX' then xltype := 'PHOTOGRAPHER'; end if;

  trg := 'PlayAudio' ;
  url_phg := 'phg.phg_modify?surl=' || glbx.rndsurl(surl) || '&phgid=' || umo_rec || '&acid=' || acid || '&msg=&footer_api=' || replace(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail;
  url_ori := 'myaudio.embed_tag?surl=' || surl || '&v_umo=' || umo_rec || '&acid=' || acid || '&image_type=ORIGINAL';
  url_thb := 'myaudio.embed_tag?surl=' || surl || '&v_umo=' || umo_rec || '&acid=' || acid || '&image_type=THUMBNAIL';
  htp.tableopen( cattributes=>'cellspacing=1 cellpadding=1 border=0' );
     htp.tablerowopen;

      htp.p( '<TD VALIGN="TOP" ALIGN="CENTER">' );
      if nvl(c1rec.cl,0) = 0
      then
       if nvl(c1rec.atl.AUDIODURATION,0) = 0
        then
         htp.anchor2( url_ori, htf.img( DECS.IMAGE_LOCATION || 'admin/audio_' || c1rec.object_class || '.gif',cattributes=>'border=0',calt=>'Click to Play Full Audio Track' ), ctarget=>trg);
        else
         htp.anchor2( url_thb, htf.img( DECS.IMAGE_LOCATION || 'admin/audio_' || c1rec.object_class || '.gif',cattributes=>'border=0',calt=>'Click to Play Audio Thumbnail' ), ctarget=>trg);
       end if;
      else
       if nvl(c1rec.atl.AUDIODURATION,0) = 0
        then
         glbx.image_matte(pfx=>pfx,wd=>c1rec.width,hg=>c1rec.height,
           trg=>url_ori,
           trgdisp=>'<IMG BORDER=0 WIDTH=' || c1rec.width || ' HEIGHT=' || c1rec.height || ' SRC="' ||
           'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umo_rec || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=LOGIN_TYPE&parm2=' || xltype || '&parm1=VERSION&parm2=' || c1rec.version || '&parm1=AID&parm2=' || acid ||
           '" ALT="' || 'Click to Play Full Audio Track' || '" ' || 'STYLE="display:block;">',
           ctarget=>trg );
        else
         glbx.image_matte(pfx=>pfx,wd=>c1rec.width,hg=>c1rec.height,
           trg=>url_thb,
           trgdisp=>'<IMG BORDER=0 WIDTH=' || c1rec.width || ' HEIGHT=' || c1rec.height || ' SRC="' ||
           'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umo_rec || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=LOGIN_TYPE&parm2=' || xltype || '&parm1=VERSION&parm2=' || c1rec.version || '&parm1=AID&parm2=' || acid ||
           '" ALT="' || 'Click to Play Audio Thumbnail' || '" ' || 'STYLE="display:block;">',
           ctarget=>trg );
        end if;
      end if;
      htp.p( '</TD>' );

      htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );
      if ltype = 'PHOTOGRAPHER'
       then
        htp.anchor( url_phg, 'Edit' );
        htp.p( ' ' );
        htp.anchor( 'myaudio.embed_tag?surl=' || surl || '&v_umo=' || umo_rec || '&acid=' || acid || '&image_type=XML', '(XML)' );
        htp.nl;
      end if;
      if nvl(c1rec.atl.AUDIODURATION,0) > 0
       then
         htp.anchor2( url_thb, c1rec.atl.AUDIODURATION || 'sec' || ' (' || reformat(c1rec.atl.format) || ')', ctarget=>trg);
         htp.nl;
      end if;
      htp.anchor2( url_ori, c1rec.aol.AUDIODURATION || 'sec' || ' (' || reformat(c1rec.aol.format) || ')', ctarget=>trg);
      htp.p( '</TD>' );

     htp.tablerowclose;
    htp.tableclose;

  htp.p( '</CENTER>' );

 end audio_api;

 procedure audio_api(v_umo integer, ltype varchar2, left_api varchar2,left_api_parm varchar2, footer_api varchar2)
 as
 begin
  null;
 end audio_api;

 -- Used on Mass load to perform specific options and processing
 function audio_api(surl in varchar2, phgid in integer, acid in integer, v_umo integer, vload_id integer, action varchar2)
  return boolean
 as

  cursor c1(v_umo integer) is select um.audio_original.format fmt from umo um where umo_id = v_umo;

  aclass	varchar2(100);
  fmt		varchar2(100);
  lng		integer;
  e1 		 UMP.MYARRAY;
  e2 		 UMP.MYARRAY;
  retval	 varchar2(1000);
  v 	 	 UMP.MYARRAY;
  v_umox 	 ump.myarray_int;

 begin
 -- AUDIO_CONVERT, EXTRACT_FROM_CD, USE_CDDB, BITRATE, AUDIO_FORMAT, AUDIO_LENGTH, AUDIO_CLASS
  if action <> 'MAIN_LOAD' then return( FALSE ); end if;
  aclass := findparm( vload_id, 'AUDIO_CLASS' );
  update umo set object_class = aclass where umo_id = v_umo;
  commit;

  -- Main Audio Generation
  if findparm( vload_id, 'AUDIO_CONVERT' ) = 'No Conversion'
   then
    null;
   else
      e1(1) := 'FORMAT';
      retval := findparm( vload_id, 'AUDIO_CONVERT' );
      if retval = 'WMA' then retval := 'Windows Media'; end if;
      e2(1) := retval;
      retval := nvl(findparm( vload_id, 'BITRATE' ),'128' );
      if retval = 'No Conversion'
       then
        null;
       else
        e1(2) := 'BITRATE';
        e2(2) := retval;
      end if;
      v_umox(1) := v_umo;
      v := ump.process_audcmd( surl, phgid, acid, v_umox, 'F', e1, e2 );
  end if;

  -- Thumbnail generation
  lng := glbx.guess_number(findparm( vload_id, 'AUDIO_LENGTH' ));
  if findparm( vload_id, 'AUDIO_FORMAT' ) = 'No Conversion' and nvl(lng,0) = 0
   then
    return( TRUE );
  end if;

  fmt := findparm( vload_id, 'AUDIO_FORMAT' );
  if fmt = 'No Conversion'
   then
    open c1(v_umo);
    fetch c1 into fmt;
    close c1;
    if fmt = 'MPGA' then fmt := 'MP3';
    elsif fmt = 'AUFF' then fmt := 'AIFF';
    end if;
  end if;

  if lng is not null
   then
      e1(1) := 'IS_TNAIL';
      e2(1) := 'TRUE';
      e1(2) := 'FORMAT';
      if fmt = 'WMA' then fmt := 'Windows Media'; end if;
      e2(2) := fmt;
      e1(3) := 'DURATION';
      e2(3) := lng;
      retval := nvl(findparm( vload_id, 'BITRATE' ),'128' );
      if retval = 'No Conversion'
       then
        null;
       else
        e1(4) := 'BITRATE';
        e2(4) := retval;
      end if;
      v_umox(1) := v_umo;
      v := ump.process_audcmd( surl, phgid, acid, v_umox, 'F', e1, e2 );
  end if;
  return( TRUE );
 exception
  when others then glbx.dbg( 'Xe:' || sqlerrm ); return( FALSE );
 end audio_api;

function findparm( vload_id integer, p1 in varchar2 )
  return varchar2
 as
  cursor c1(vload_id integer, p1 varchar2 ) is select parm2 from phg_batch_upload_parms where load_id = vload_id and parm1 = p1;
  c1rec	 c1%ROWTYPE;
 begin
  open c1(vload_id, p1);
  fetch c1 into c1rec;
  close c1;
  return( c1rec.parm2 );
 end findparm;

function findparm3( vload_id integer, p3 in varchar2 )
  return varchar2
 as
  cursor c1(vload_id integer, p3 varchar2 ) is select 'T' vl from phg_batch_upload_parms where load_id = vload_id and parm3 = p3;
  c1rec	 c1%ROWTYPE;
 begin
  open c1(vload_id, p3);
  fetch c1 into c1rec;
  if c1%FOUND then close c1; return( 'T' ); else close c1; return( 'F' ); end if;
end findparm3;

 procedure embed_tag(surl in varchar2, v_umo in integer, acid in integer, image_type in varchar2 )
 as

 begin
  play_audio( surl, v_umo, acid, image_type );
 end embed_tag;

 procedure play_audio(surl in varchar2, v_umo in integer, acid in integer, image_type in varchar2 )
 as

   cursor c2(acid integer, v_umo integer) is select um.audio_original.comments cmt from umo um where aid = acid and umo_id = v_umo;

   c2rec		c2%ROWTYPE;
   c1rec		customer_account%ROWTYPE;
   ump_param_types 	UMP.PARAMETERS;
   ump_param_values 	UMP.PARAMETERS;
   ltype		varchar2(100);
   stype		integer;
   owner_id		integer;
   profid		integer;
   v_imgchunk		integer;
   sts			varchar2(100);
   vl			varchar2(32767);

 begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'MYaudio.PLAY_audio' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 --
 -- Set up the param arrays used in ump.retrieve
 --
 if image_type = 'XML'
  then
   open c2(acid, v_umo);
   fetch c2 into c2rec;
   close c2;
   v_imgchunk := 32767;
   dbms_lob.read(c2rec.cmt,v_imgchunk,32767,vl);
   htp.p( vl );
   return;
 end if;
 ump_param_types(1) := 'UMO_ID';
 ump_param_values(1) := v_umo;
 ump_param_types(2) := 'DISPLAY_TYPE';
 ump_param_values(2) := 'RAW';
 ump_param_types(3) := 'DISPLAY_WHAT';
 ump_param_values(3) := image_type;
 ump_param_types(4) := 'LOGIN_TYPE';
 ump_param_values(4) := ltype;
 ump_param_types(5) := 'AID';
 ump_param_values(5) := c1rec.aid;

 ump.retrieve_uma(surl=> glbx.truncsurl(surl)
               ,parm1=> ump_param_types
               ,parm2=> ump_param_values);

 end play_audio;

end myaudio;

/
