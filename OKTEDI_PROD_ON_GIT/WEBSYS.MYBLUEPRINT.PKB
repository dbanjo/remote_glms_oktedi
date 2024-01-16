CREATE OR REPLACE package body WEBSYS.myblueprint as

 -- Test if extension of filename is a blueprint one
 function blueprint_api( v_filename varchar2 )
  return char
 as

  ext	varchar2(100);

 begin

  ext := upper(glbx.extract_fname( v_filename, 'SUFFIX' ));
  if ext in ('MPEG','MPG','MPE','AVI','ASF','DVX','DIVX','MPV2','MP2V','QT','MOV','MOVIE','VDO','RA','RM')
   then
    return( 'T' ); -- Note: Cannot return a boolean due to the limitations of dynamic SQL and booleans
   else
    return( 'F' );
  end if;

 end blueprint_api;

 -- Modify Meta Tag
 procedure blueprint_api(v_umo integer, attrib_id integer, data_value varchar2, acid integer, posid integer, action varchar2 )
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
 end blueprint_api;

 -- Mass Modification
 procedure blueprint_api(v_umo integer, new_acid integer, old_acid integer, action varchar2 )
 as
 begin
  null;
 end blueprint_api;

 -- This API is called whilst loading the blueprint
 -- How Loaded is BATCH or BROWSER
 -- ACTION is INSERT, UPDATE, DELETE

 procedure blueprint_api(v_umo integer, schemaname varchar2, howloaded varchar2, action varchar2 )
 as

  cursor c1(v_umo integer) is select * from umo where umo_id = v_umo;
  c1rec  c1%ROWTYPE;

  ext	varchar2(100);
  mtype	varchar2(100);

 begin
  -- Step 1: Extract the suffix and set the mime type
  open c1(v_umo);
  fetch c1 into c1rec;
  close c1;
  ext := upper(glbx.extract_fname( c1rec.blueprint_obj.blueprint_original_loc, 'SUFFIX' ));
  if ext in ('MPEG','MPG','MPE') then mtype := 'blueprint/mpeg';
  elsif ext in ('MPV2','MP2V') then mtype := 'blueprint/mpeg2';
  elsif ext in ('QT','MOV') then mtype := 'blueprint/quicktime';
  elsif ext in ('AVI','ASF','DVX','DIVX') then mtype := 'blueprint/x-msblueprint';
  elsif ext in ('MOVIE') then mtype :=   'blueprint/x-sgi-movie';
  elsif ext in ('VDO') then mtype := 'blueprint/vdo';
  elsif ext in ('VDO') then mtype := 'blueprint/vdo';
  elsif ext in ('RA') then mtype := 'blueprint/x-pn-realblueprint';
  elsif ext in ('RM') then mtype := 'blueprint/x-pn-realblueprint';
  end if;

  if mtype is not null
   then
    update umo um
     set
      um.blueprint_obj.mimetype = mtype,
      um.extras.film_name = glbx.extract_fname( c1rec.blueprint_obj.blueprint_original_loc, 'NO_EXTENSION' ),
      um.extras.photo_name = glbx.extract_fname( c1rec.blueprint_obj.blueprint_original_loc, 'NO_EXTENSION' )
    where
     umo_id = v_umo;
  commit;
  end if;

 exception
  when others then
   null;
 end blueprint_api;

 -- This Object Displays the UMO Thumbnail Representation
 procedure blueprint_api(surl in varchar2, umo_rec in integer, theme_data in CHAR, left_api_parm in VARCHAR2, current_page_number in integer, display_detail in varchar2, footer_api in varchar2, ltype in varchar2, acid in integer )
 as

  cursor c1(v_umo integer) is select aid,um.blueprint_obj.mimetype mtype,um.photo_thumbnail.contentlength cl, version, um.photo_thumbnail.width width, um.photo_thumbnail.height height from umo um where umo_id = v_umo;
  cursor c2(acid integer) is select * from theme where theme_name in (select theme_name from customer_account where aid = acid );

  c1rec	 c1%ROWTYPE;

  url	 varchar2(1000);
  trg	 varchar2(100);
  alt	 varchar2(100);
  pfx	 THEME%ROWTYPE;
  xltype varchar2(100);

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

  if ltype = 'PHOTOGRAPHER'
   then
    trg := NULL;
    alt := 'Click to Edit blueprint Details';
    if display_detail = 'S'
     then
      url := footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=[' || umo_rec || ']' || replace(left_api_parm,' ','+') || '&start_from=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid;
     else
      url := 'phg.phg_modify?surl=' || glbx.rndsurl(surl) || '&phgid=' || umo_rec || '&acid=' || acid || '&msg=&footer_api=' || replace(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail;
    end if;

   else

    -- If streaming blueprint need to call the Real Player API else just dump it out
    alt := 'Click to Play blueprint';
    if c1rec.mtype = 'blueprint/x-pn-realblueprint'
     then
      url := 'rtsp://' || substr( glbx.extract_master_parameter('PICTION_HOME_PAGE'),8) || ':554/dbproc/' || umo_rec;
      trg := NULL;
     else
      url := 'myblueprint.embed_tag?surl=' || surl || '&v_umo=' || umo_rec || '&acid=' || acid;
      trg := 'Play blueprint' ;
    end if;

  end if;

  if nvl(c1rec.cl,0) = 0
   then
    htp.anchor2( url, htf.img( DECS.IMAGE_LOCATION || 'admin/big_acct.gif',cattributes=>'border=0',calt=>'Click to Play blueprint' ), ctarget=>trg);
   else
    glbx.image_matte(pfx=>pfx,wd=>c1rec.width,hg=>c1rec.height,
           trg=>url,
           trgdisp=>'<IMG BORDER=0 WIDTH=' || c1rec.width || ' HEIGHT=' || c1rec.height || ' SRC="' ||
           'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umo_rec || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=LOGIN_TYPE&parm2=' || xltype || '&parm1=VERSION&parm2=' || c1rec.version || '&parm1=AID&parm2=' || acid ||
           '" ALT="' || alt || '" ' || 'STYLE="display:block;">',
           ctarget=>trg );
  end if;

  htp.nl;
  htp.p( '</CENTER>' );

 end blueprint_api;

 procedure blueprint_api(v_umo integer, ltype varchar2, left_api varchar2,left_api_parm varchar2, footer_api varchar2)
 as
 begin
  null;
 end blueprint_api;

 -- Used on Mass load to perform specific options and processing
 procedure blueprint_api(v_umo integer, vload_id integer, action varchar2)
 as
 begin
  null;
 end blueprint_api;

 procedure embed_tag(surl in varchar2, v_umo in integer, acid in integer )
 as

 begin
  play_blueprint( surl, v_umo, acid );
 end embed_tag;

 procedure play_blueprint(surl in varchar2, v_umo in integer, acid in integer )
 as

   c1rec		customer_account%ROWTYPE;
   ump_param_types 	UMP.PARAMETERS;
   ump_param_values 	UMP.PARAMETERS;
   ltype		varchar2(100);
   stype		integer;
   owner_id		integer;
   profid		integer;
   sts			varchar2(100);

 begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'MYblueprint.PLAY_blueprint' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 --
 -- Set up the param arrays used in ump.retrieve
 --
 ump_param_types(1) := 'UMO_ID';
 ump_param_values(1) := v_umo;
 ump_param_types(2) := 'DISPLAY_TYPE';
 ump_param_values(2) := 'RAW';
 ump_param_types(3) := 'DISPLAY_WHAT';
 ump_param_values(3) := 'MASTER';
 ump_param_types(4) := 'LOGIN_TYPE';
 ump_param_values(4) := ltype;
 ump_param_types(5) := 'AID';
 ump_param_values(5) := c1rec.aid;


 ump.retrieve_uma(surl=> glbx.truncsurl(surl)
               ,parm1=> ump_param_types
               ,parm2=> ump_param_values);

 end play_blueprint;

 procedure getblueprint( data out blob, mimetype out varchar2, id in number )
 as

  cursor c1 is select * from umo um where umo_id = id;
  c1rec  c1%ROWTYPE;

 begin
  -- Need a call to protect this...
  open c1;
  fetch c1 into c1rec;
  close c1;
  data := c1rec.blueprint_obj.localdata;
  mimetype := c1rec.blueprint_obj.mimetype;

 end getblueprint;

end myblueprint;

/
