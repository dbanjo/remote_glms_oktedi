CREATE OR REPLACE package body WEBSYS.xml
as

NL_CHAR constant char(1) := chr(10);

TYPE myarray 	   IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
TYPE upd_arr IS RECORD
   (
    table_name	varchar2(100),
    cmd		varchar2(20),
    ev1		varchar2(100),
    ev2		varchar2(100),
    ignore_rec	boolean,
    stage	boolean,
    pkcols	myarray,
    pkids	myarray,
    cols	myarray,
    ctype	myarray,
    vals	myarray,
    fks		myarray,
    rep_cols	myarray,
    rep_vals	myarray,
    rem_col	myarray,
    rem_oldv	myarray,
    rem_newv	myarray
   );

tblob		blob;
tclob		clob;
download_method	varchar2(20);
upload_method	varchar2(20);

function base64( nmb integer ) return varchar2;
function reverse_base64( val varchar2 ) return integer;
function extract_parameter( extra_value_1 in varchar2, extra_value_2 in varchar2, tag_input in varchar2 ) return varchar2;
function colexists(tname in varchar2, cname in varchar2 ) return boolean;
function check_pk_exists( vls in out NOCOPY upd_arr ) return boolean;
function check_pk_exists2( vls in out NOCOPY upd_arr ) return boolean;

procedure pline( fl in out UTL_FILE.FILE_TYPE, buffer in varchar2 );
procedure main( cmd in varchar2, downtype in varchar2, directory in varchar2, filename in varchar2, driver in varchar2, nparms in myarray, nvls in myarray );
procedure dump_set( fl in out UTL_FILE.FILE_TYPE, dump_type in varchar2, fname in varchar2 default null, umo_from in integer default null, umo_to in integer default null, nparms in myarray, nvls in myarray );
procedure dump_blob( fl in out UTL_FILE.FILE_TYPE, img in blob, fname in varchar2 default null, display_mime_header in boolean default FALSE );
procedure dump_clob( fl in out UTL_FILE.FILE_TYPE, img in clob, fname in varchar2 default null, display_mime_header in boolean default FALSE );
procedure dump_stmt( fl in out UTL_FILE.FILE_TYPE, sqlstmt in varchar2, tname in varchar2, fname in varchar2 default null, cattributes in varchar2 default null );
procedure dump_umo(fl in out UTL_FILE.FILE_TYPE, cls in varchar2, fname in varchar2 default null, umo_from in integer default null, umo_to in integer default null );
procedure write_transactionopen( fl in out UTL_FILE.FILE_TYPE, cattributes in varchar2 default null );
procedure write_transactionclose( fl in out UTL_FILE.FILE_TYPE );
procedure write_tableheaderopen( fl in out UTL_FILE.FILE_TYPE, tname in varchar2, cattributes in varchar2 default null );
procedure write_tableheaderclose( fl in out UTL_FILE.FILE_TYPE, tname in varchar2 );
procedure write_rowheaderopen( fl in out UTL_FILE.FILE_TYPE, cattributes in varchar2 default null );
procedure write_rowheaderclose( fl in out UTL_FILE.FILE_TYPE );
procedure write_columnheaderopen( fl in out UTL_FILE.FILE_TYPE, cname in varchar2, cattributes in varchar2 default null );
procedure write_columnheaderclose( fl in out UTL_FILE.FILE_TYPE, cname in varchar2 );
procedure write_column( fl in out UTL_FILE.FILE_TYPE, cname in varchar2, cval in varchar2, cattributes in varchar2 default null );
procedure write_column_blob( fl in out UTL_FILE.FILE_TYPE, cname in varchar2, cval in blob, cattributes in varchar2 default null );
procedure write_column_clob( fl in out UTL_FILE.FILE_TYPE, cname in varchar2, cval in clob, cattributes in varchar2 default null );
procedure write_column_rfield( fl in out UTL_FILE.FILE_TYPE, cname in varchar2, cval in repeated_fields, cattributes in varchar2 default null );
procedure write_column_blueprint( fl in out UTL_FILE.FILE_TYPE, cname in varchar2, cval in blueprint_type, cattributes in varchar2 default null );
procedure write_column_ordsource( fl in out UTL_FILE.FILE_TYPE, cname in varchar2, cval in ordsys.ordsource, cattributes in varchar2 default null );
procedure write_column_photo( fl in out UTL_FILE.FILE_TYPE, cname in varchar2, cval in ordsys.ordimage, cattributes in varchar2 default null );
procedure write_column_video( fl in out UTL_FILE.FILE_TYPE, cname in varchar2, cval in ordsys.ordvideo, cattributes in varchar2 default null );
procedure write_column_audio( fl in out UTL_FILE.FILE_TYPE, cname in varchar2, cval in ordsys.ordaudio, cattributes in varchar2 default null );
procedure write_column_program( fl in out UTL_FILE.FILE_TYPE, cname in varchar2, cval in program_type, cattributes in varchar2 default null );
procedure dump_blob_full( fl in out UTL_FILE.FILE_TYPE, img in blob, fname in varchar2 default null, display_mime_header in boolean default FALSE );
procedure dump_clob_full( fl in out UTL_FILE.FILE_TYPE, img in clob, fname in varchar2 default null, display_mime_header in boolean default FALSE );

procedure extract_tag( fl in out UTL_FILE.FILE_TYPE, tag_type out varchar2, tag_name out varchar2, tag_value out varchar2, extra_value_1 out varchar2, extra_value_2 out varchar2, error out varchar2 );
procedure load_set( fl in out UTL_FILE.FILE_TYPE, load_method in varchar2, ncols in myarray, nvals in myarray );
procedure extract_tag_header( tag_input in varchar2, tag_name out varchar2, extra_value_1 out varchar2, extra_value_2 out varchar2 );
procedure extract_tag_body( tag_input in varchar2, tag_name in varchar2, tag_value out varchar2, error out varchar2 );
procedure extract_transaction( fl in out UTL_FILE.FILE_TYPE, tvers in varchar2, trep in varchar2, vls in out NOCOPY upd_arr );
procedure extract_pkval( vls in out upd_arr, stage in varchar2 );
procedure extract_record( fl in out UTL_FILE.FILE_TYPE, tvers in varchar2, trep in varchar2, tname in varchar2, lobcol in varchar2 default null, vls in out NOCOPY upd_arr );
procedure extract_column( fl in out UTL_FILE.FILE_TYPE, tvers in varchar2, trep in varchar2, tname in varchar2, vls in out NOCOPY upd_arr );
procedure extract_blob( fl in out UTL_FILE.FILE_TYPE, tvers in varchar2, tag_name in varchar2, extra_value_1 in varchar2, vls in out NOCOPY upd_arr );
procedure extract_clob( fl in out UTL_FILE.FILE_TYPE, tvers in varchar2, trep in varchar2, tname in varchar2, vls in out NOCOPY upd_arr );
procedure add_record(tvers in varchar2, trep in varchar2, vls in out NOCOPY upd_arr );

function loadimg(surl in varchar2, cusrec in customer_account%ROWTYPE, temp_dir in varchar2, new_img in varchar2, full_path in varchar2, subj in varchar2, negno in integer, origfname in varchar2, v_umo out integer) return varchar2;
function email_receive_load( surl in varchar2, cusrec in customer_account%ROWTYPE, email_dir in varchar2, email_name in varchar2, temp_dir in varchar2, temp_name in varchar2, new_image_name in varchar2, negno in integer, full_path in varchar2 ) return varchar2;
function is_metadata_xml( txt in out varchar2 ) return boolean;
function open_xml( txt in varchar2, doc in out sys.xmldom.DOMDocument ) return boolean;

function colexists(tname in varchar2, cname in varchar2 )
 return boolean
as
 cursor c1(tname varchar2, cname varchar2) is select 'x' exst from user_tab_columns where table_name = tname and column_name = cname;
 c1rec c1%ROWTYPE;
begin
 open c1(upper(tname),upper(cname));
 fetch c1 into c1rec;
 if c1%FOUND
  then
   close c1;
   return( TRUE );
  else
   close c1;
   return( FALSE );
 end if;
end colexists;

procedure dump_set( fl in out UTL_FILE.FILE_TYPE, dump_type in varchar2, fname in varchar2 default null, umo_from in integer default null, umo_to in integer default null, nparms in myarray, nvls in myarray )
as

 cursor c1(dtype varchar2) is select * from dump_driver where driver_type = dtype;

 function replace_restrict(restrict in varchar2, nparms in myarray, nvls in myarray )
  return varchar2
 as
  retvar	varchar2(4000);
 begin
  retvar := restrict;
  for j in nparms.first..nparms.last loop
   if nparms(j) not in ('FROM-UMO','TO-UMO')
    then
     retvar := replace(retvar,'<' || nparms(j) || '>', nvls(j));
   end if;
  end loop;
  return(retvar);
 end replace_restrict;

begin
 write_transactionopen( fl, cattributes=>'DRIVER="' || dump_type || '" VERSION="' || GLBX.CURRENT_VERSION || '"' );
 for c1rec in c1(dump_type) loop
  if c1rec.driver_table = 'UMO'
   then
    if c1rec.restrict_clause is null
     then
      dump_umo( fl, null, fname, umo_from, umo_to );
     else
      dump_umo( fl, replace_restrict(c1rec.restrict_clause,nparms,nvls), fname, umo_from, umo_to );
    end if;
   else
    if c1rec.restrict_clause is null
     then
      dump_stmt( fl, 'select * from ' || c1rec.driver_table, c1rec.driver_table, fname, c1rec.attribs );
     else
      dump_stmt( fl, 'select * from ' || c1rec.driver_table || ' where ' || replace_restrict(c1rec.restrict_clause,nparms,nvls), c1rec.driver_table, fname, c1rec.attribs );
    end if;
  end if;
 end loop;
 write_transactionclose( fl );
end dump_set;

procedure dump_stmt( fl in out UTL_FILE.FILE_TYPE, sqlstmt in varchar2, tname in varchar2, fname in varchar2 default null, cattributes in varchar2 default null )
as

  cursor c1(coln varchar2) is select dquery from dump_driver_unique_column where cname = coln and dtype = 'F';

  c1rec		c1%ROWTYPE;
  cursor_name	integer;
  dummy 	integer;
  col_count	integer;
  desc_t	dbms_sql.desc_tab;
  common_nmb	number;
  common_vc2	varchar2(4000);
  common_dte	date;
  common_blob	blob;
  common_clob	clob;
  tmpval	varchar2(4000);
  fk		varchar2(100);
  vl2		varchar2(4000);
  x		integer;

begin

  /*
 	Char - 96
  	VC2  - 1
        Nmb  - 2
        Date - 12
        Type - 109
        Blob - 113
        Clob - 112
  */

   x := instr(cattributes,'FK="');
   if x > 0
    then
     fk := substr( cattributes, x+4 );
     x := instr(fk,'"');
     fk := substr( fk, 1, x-1 );
    else
     fk := NULL;
   end if;

   cursor_name := dbms_sql.open_cursor;
   dbms_sql.parse( cursor_name, sqlstmt, dbms_sql.native );
   dbms_sql.describe_columns(cursor_name,col_count,desc_t);

   for j in 1..col_count loop
    if desc_t(j).col_type in (1,96)
     then
      dbms_sql.define_column_char(cursor_name,j,common_vc2,desc_t(j).col_max_len);
    elsif desc_t(j).col_type = 2
     then
      dbms_sql.define_column(cursor_name,j,common_nmb);
    elsif desc_t(j).col_type = 12
     then
      dbms_sql.define_column(cursor_name,j,common_dte);
    elsif desc_t(j).col_type = 113
     then
      dbms_sql.define_column(cursor_name,j,common_blob);
    elsif desc_t(j).col_type = 112
     then
      dbms_sql.define_column(cursor_name,j,common_clob);
    end if;
   end loop;
   dummy := dbms_sql.execute( cursor_name );

   write_tableheaderopen( fl, TNAME, cattributes );
   loop
     dummy := dbms_sql.fetch_rows(cursor_name);
     if dummy = 0 then exit; end if;
     write_rowheaderopen( fl );

     for j in 1..col_count loop
      tmpval := NULL;
      common_vc2 := NULL;
      common_nmb := NULL;
      common_dte := NULL;
      common_blob := NULL;
      common_clob := NULL;
      vl2 := NULL;

      if fk is not null and desc_t(j).col_name = fk
       then
        c1rec.dquery := NULL;
        open c1( fk );
        fetch c1 into c1rec;
        close c1;
      end if;

      if desc_t(j).col_type in (1,96)
       then
        dbms_sql.column_value_char(cursor_name,j,common_vc2);
        tmpval := rtrim( common_vc2 );
        if c1rec.dquery is not null
         then
          begin
           execute immediate replace(c1rec.dquery,'<' || fk || '>', tmpval) into vl2;
           vl2 := 'FK="' || replace(vl2,'"','') || '" ';
          exception when others then null;
          end;
        end if;
        write_column( fl, desc_t(j).col_name, tmpval, vl2 );

       elsif desc_t(j).col_type = 2
        then
         dbms_sql.column_value(cursor_name,j,common_nmb);
         tmpval := to_char( common_nmb );
         if c1rec.dquery is not null
         then
          begin
           execute immediate replace(c1rec.dquery,'<' || fk || '>', tmpval) into vl2;
           vl2 := 'FK="' || replace(vl2,'"','') || '" ';
          exception when others then null;
          end;
         end if;
         vl2 := vl2 || 'TYPE="NUMBER"';
         write_column( fl, desc_t(j).col_name, tmpval, vl2 );

       elsif desc_t(j).col_type = 12
        then
         dbms_sql.column_value(cursor_name,j,common_dte);
         tmpval := to_char( common_dte,LNG.TSMASK );
         if c1rec.dquery is not null
         then
          begin
           execute immediate replace(c1rec.dquery,'<' || fk || '>', tmpval) into vl2;
           vl2 := 'FK="' || replace(vl2,'"','') || '" ';
          exception when others then null;
          end;
         end if;
         vl2 := vl2 || 'TYPE="DATE"';
         write_column( fl, desc_t(j).col_name, tmpval, vl2);

       elsif desc_t(j).col_type = 113
        then
         dbms_sql.column_value(cursor_name,j,common_blob);
         write_column_blob( fl, desc_t(j).col_name, common_blob );

       elsif desc_t(j).col_type = 112
        then
         dbms_sql.column_value(cursor_name,j,common_clob);
         write_column_clob( fl, desc_t(j).col_name, common_clob );
      end if;
     end loop;

     write_rowheaderclose( fl );
   end loop;
   write_tableheaderclose( fl, tname );
   dbms_sql.close_cursor( cursor_name );

end dump_stmt;

procedure dump_umo(fl in out UTL_FILE.FILE_TYPE, cls in varchar2, fname in varchar2 default null, umo_from in integer default null, umo_to in integer default null )
as

  cursor c1( uscid integer ) is select title from umo_scene where umo_scene_id = uscid;

  TYPE REPCurTyp IS REF CURSOR RETURN UMO%ROWTYPE;
  rep_cv   	REPCurTyp;
  urec		UMO%ROWTYPE;
  c1rec		c1%ROWTYPE;
  acid		integer;
  utype		varchar2(100);

begin

 -- Because the UMO Table has objects in it, DBMS_SQL cannot deal with, so must do it manually
 acid := substr(cls,2,instr(cls,']')-2);
 utype := substr(cls,instr(cls,']')+1);
 open rep_cv for
  select *
  from umo um
  where aid = acid and
        ((utype='ALL') or (umo_type=utype) or (utype='IMAGES' and umo_type in ('PHOTO','DOCUMENT','AUDIO','VIDEO','BLUEPRINT','RELATIONAL'))) and
        nvl(um.extras.orderby_nmb,0) >= nvl(umo_from,0) and
        nvl(um.extras.orderby_nmb,0) <= nvl(umo_to,999999)
  order by umo_id;
 write_tableheaderopen( fl, 'UMO','PRIMARY_KEY=UMO_ID' );
 loop
  fetch rep_cv into urec;
  exit when rep_cv%NOTFOUND;
  write_rowheaderopen( fl );
  write_column(fl, 'UMO_ID', urec.UMO_ID, 'TYPE="NUMBER"' );
  write_column(fl, 'PARENT_ID', urec.PARENT_ID, 'TYPE="NUMBER"' );
  write_column(fl, 'AID', urec.AID, 'TYPE="NUMBER"' );
  write_column(fl, 'UMO_TYPE', urec.UMO_TYPE );
  write_column(fl, 'UMO_OWNER', urec.UMO_OWNER );
  open c1(urec.umo_scene_id);
  fetch c1 into c1rec;
  close c1;

  -- Note: The order in which these columns are extracted is important.
  -- As the LOC values are used as an alternative primary key, they have to appear before the first blob/clob download, because thats when the first primary key is calculated

  write_column(fl, 'UMO_SCENE_ID', c1rec.title, 'TYPE="VARCHAR2"' );
  write_column(fl, 'VERSION', urec.VERSION );
  write_column_rfield(fl, 'EXTRAS', urec.EXTRAS );
  write_column(fl, 'PHOTO_ORIGINAL_LOC', urec.PHOTO_ORIGINAL_LOC );
  write_column(fl, 'AUDIO_ORIGINAL_LOC', urec.AUDIO_ORIGINAL_LOC );
  write_column(fl, 'VIDEO_ORIGINAL_LOC', urec.VIDEO_ORIGINAL_LOC );
  write_column(fl, 'DOCUMENT_ORIGINAL_LOC', urec.DOCUMENT_ORIGINAL_LOC );
  write_column_blueprint(fl, 'BLUEPRINT_OBJ', urec.BLUEPRINT_OBJ );
  write_column_photo(fl, 'PHOTO_ORIGINAL', urec.PHOTO_ORIGINAL );
  write_column_photo(fl, 'PHOTO_MASTER', urec.PHOTO_MASTER );
  write_column_photo(fl, 'PHOTO_THUMBNAIL', urec.PHOTO_THUMBNAIL );
  write_column_photo(fl, 'PHOTO_BACKUP', urec.PHOTO_BACKUP );
  write_column_audio(fl, 'AUDIO_ORIGINAL', urec.AUDIO_ORIGINAL );
  write_column_audio(fl, 'AUDIO_THUMBNAIL', urec.AUDIO_THUMBNAIL );
  write_column_video(fl, 'VIDEO_ORIGINAL', urec.VIDEO_ORIGINAL );
  write_column(fl, 'DOC_MIMETYPE', urec.DOC_MIMETYPE );
  write_column(fl, 'DOC_TYPE', urec.DOC_TYPE );
  write_column(fl, 'DOC_POV', urec.DOC_POV );
  write_column(fl, 'DOC_LENGTH', urec.DOC_LENGTH );
  write_column_blob(fl, 'DOC_BODY', urec.DOC_BODY );
  write_column_clob(fl, 'DOC_HTML', urec.DOC_HTML );
  write_column_clob(fl, 'DOC_GIST', urec.DOC_GIST );
  write_column(fl, 'EXTRA_FILM_COLOUR', urec.EXTRA_FILM_COLOUR );
  write_column(fl, 'EXTRA_ROLL_ID', urec.EXTRA_ROLL_ID );
  write_column(fl, 'EXTRA_FILM_SIZE', urec.EXTRA_FILM_SIZE );
  write_column(fl, 'FTP_LOCATION', urec.FTP_LOCATION );
  write_column(fl, 'FTP_VIRTUAL_DIR', urec.FTP_VIRTUAL_DIR );
  write_column(fl, 'IS_GLOBAL', urec.IS_GLOBAL );
  write_column(fl, 'DATE_CREATED', urec.DATE_CREATED, 'TYPE="DATE"' );
  write_column(fl, 'DATE_UPDATED', urec.DATE_UPDATED, 'TYPE="DATE"' );
  write_column(fl, 'EXPIRE_DATE', urec.EXPIRE_DATE, 'TYPE="DATE"' );
  write_column(fl, 'REPORT_ID', urec.REPORT_ID, 'TYPE="NUMBER"' );
  write_column(fl, 'PRICING_STRUCTURE', urec.PRICING_STRUCTURE );
  write_column(fl, 'IMAGE_CAPTION', urec.IMAGE_CAPTION );
  write_column(fl, 'SESSID', urec.SESSID );
  write_column(fl, 'ATTRIBUTE1', urec.ATTRIBUTE1 );
  write_column(fl, 'ATTRIBUTE2', urec.ATTRIBUTE2 );
  write_column(fl, 'ATTRIBUTE3', urec.ATTRIBUTE3 );
  write_column(fl, 'ATTRIBUTE4', urec.ATTRIBUTE4 );
  write_column(fl, 'ATTRIBUTE5', urec.ATTRIBUTE5 );
  write_column(fl, 'ATTRIBUTE6', urec.ATTRIBUTE6 );
  write_column(fl, 'SORT_PRIORITY', urec.SORT_PRIORITY );
  write_column(fl, 'EXCLUSIVE_PURCHASED', urec.exclusive_purchased );
-- xxx fix for v9
--  write_column(fl, 'SIGNATURE', urec.signature );
  write_column_program(fl, 'PROGRAM_OBJ', urec.program_obj );
  write_rowheaderclose( fl );

 end loop;
 close rep_cv;
 write_tableheaderclose( fl, 'UMO' );
end dump_umo;

procedure pline( fl in out UTL_FILE.FILE_TYPE, buffer in varchar2 )
as
begin
 if download_method = 'FILE'
  then
   utl_file.put_line( fl, buffer );
  else
   htp.p( buffer );
 end if;
end pline;

procedure write_transactionopen( fl in out UTL_FILE.FILE_TYPE, cattributes in varchar2 default null )
as
begin
 if cattributes is null
  then
   pline( fl, '<TRANSACTION>' );
  else
   pline( fl, '<TRANSACTION ' || cattributes || '>' );
 end if;
end write_transactionopen;

procedure write_transactionclose( fl in out UTL_FILE.FILE_TYPE )
as
begin
 pline( fl, '</TRANSACTION>' );
end write_transactionclose;

procedure write_tableheaderopen( fl in out UTL_FILE.FILE_TYPE, tname in varchar2, cattributes in varchar2 default null )
as
begin
 if cattributes is null
  then
   pline( fl, '<' || upper(tname) || '>' );
  else
   pline( fl, '<' || upper(tname) || ' ' || cattributes || '>' );
 end if;
end write_tableheaderopen;

procedure write_tableheaderclose( fl in out UTL_FILE.FILE_TYPE, tname in varchar2 )
as
begin
 pline( fl, '</' || upper(tname) || '>' );
end write_tableheaderclose;

procedure write_rowheaderopen( fl in out UTL_FILE.FILE_TYPE, cattributes in varchar2 default null )
as
begin
 if cattributes is null
  then
   pline( fl, '<REC>' );
  else
   pline( fl, '<REC ' || cattributes || '>' );
 end if;
end write_rowheaderopen;

procedure write_rowheaderclose( fl in out UTL_FILE.FILE_TYPE )
as
begin
 pline( fl, '</REC>' );
end write_rowheaderclose;

procedure write_columnheaderopen( fl in out UTL_FILE.FILE_TYPE, cname in varchar2, cattributes in varchar2 default null )
as
begin
 if cattributes is null
  then
   pline( fl, '<' || upper(cname) || '>' );
  else
   pline( fl, '<' || upper(cname) || ' ' || cattributes || '>' );
 end if;
end write_columnheaderopen;

procedure write_columnheaderclose( fl in out UTL_FILE.FILE_TYPE, cname in varchar2 )
as
begin
 pline( fl, '</' || upper(cname) || '>' );
end write_columnheaderclose;

procedure write_column( fl in out UTL_FILE.FILE_TYPE, cname in varchar2, cval in varchar2, cattributes in varchar2 default null )
as
begin

 if cattributes is null
  then
   pline( fl, '<' || upper(cname) || '>' || cval || '</' || upper(cname) || '>' );
  else
   pline( fl, '<' || upper(cname) || ' ' || cattributes || '>' || cval || '</' || upper(cname) || '>' );
 end if;

end write_column;

procedure write_column_blob( fl in out UTL_FILE.FILE_TYPE, cname in varchar2, cval in blob, cattributes in varchar2 default null )
as
begin

 write_columnheaderopen( fl, cname, 'TYPE="BLOB"' );
 if dbms_lob.getlength( cval ) < 10000
  then
   write_columnheaderopen( fl, 'BLOB', 'TYPE="BASE64"' );
  else
   write_columnheaderopen( fl, 'BLOB', 'TYPE="MIME64"' );
 end if;
 dump_blob_full( fl, cval );
 write_columnheaderclose( fl, 'BLOB' );
 write_columnheaderclose( fl, cname );

end write_column_blob;

procedure write_column_clob( fl in out UTL_FILE.FILE_TYPE, cname in varchar2, cval in clob, cattributes in varchar2 default null )
as
begin

 write_columnheaderopen( fl, cname, 'TYPE="CLOB"' );
 write_columnheaderopen( fl, 'CLOB' );
 dump_clob_full( fl, cval );
 write_columnheaderclose( fl, 'CLOB' );
 write_columnheaderclose( fl, cname );

end write_column_clob;

procedure write_column_rfield( fl in out UTL_FILE.FILE_TYPE, cname in varchar2, cval in repeated_fields, cattributes in varchar2 default null )
as
begin

  write_column(fl, cname || '.' || 'ORDERBY_NMB', cval.ORDERBY_NMB,'TYPE="NUMBER"' );
  write_column(fl, cname || '.' || 'ORDERBY_CHAR', cval.ORDERBY_CHAR );
  write_column(fl, cname || '.' || 'ORDERBY_SCENE', cval.ORDERBY_SCENE,'TYPE="NUMBER"' );
  write_column(fl, cname || '.' || 'TITLE', cval.TITLE );
  write_column(fl, cname || '.' || 'QUALITY', cval.QUALITY );
  write_column(fl, cname || '.' || 'PHOTO_NAME', cval.PHOTO_NAME );
  write_column(fl, cname || '.' || 'FILM_NAME', cval.FILM_NAME );
  write_column(fl, cname || '.' || 'ENABLED_PHG', cval.ENABLED_PHG );
  write_column(fl, cname || '.' || 'ENABLED_CUS', cval.ENABLED_CUS );

end write_column_rfield;

procedure write_column_blueprint( fl in out UTL_FILE.FILE_TYPE, cname in varchar2, cval in blueprint_type, cattributes in varchar2 default null )
as
begin

  write_column(fl, cname || '.' || 'MIMETYPE', cval.MIMETYPE );
  write_column(fl, cname || '.' || 'ONLINE_MIMETYPE', cval.ONLINE_MIMETYPE );
  write_column(fl, cname || '.' || 'BLUEPRINT_ORIGINAL_LOC', cval.BLUEPRINT_ORIGINAL_LOC );
  write_column(fl, cname || '.' || 'BLUEPRINT_LENGTH', cval.BLUEPRINT_LENGTH,'TYPE="NUMBER"' );
  write_column(fl, cname || '.' || 'ONLINE_LENGTH', cval.ONLINE_LENGTH,'TYPE="NUMBER"' );
  write_column(fl, cname || '.' || 'DETAILS', cval.DETAILS );
  write_column_blob(fl, cname || '.' || 'LOCALDATA', cval.LOCALDATA );
  write_column_blob(fl, cname || '.' || 'ONLINE_VERSION', cval.ONLINE_VERSION );

end write_column_blueprint;

procedure write_column_ordsource( fl in out UTL_FILE.FILE_TYPE, cname in varchar2, cval in ordsys.ordsource, cattributes in varchar2 default null )
as
begin

write_column_blob(fl, cname || '.' || 'LOCALDATA', cval.localdata );
write_column(fl, cname || '.' || 'SRCTYPE', cval.SRCTYPE );
write_column(fl, cname || '.' || 'SRCLOCATION', cval.SRCLOCATION );
write_column(fl, cname || '.' || 'SRCNAME', cval.SRCNAME );
write_column(fl, cname || '.' || 'UPDATETIME', to_char(cval.UPDATETIME,LNG.TSMASK),'TYPE="DATE"' );
write_column(fl, cname || '.' || 'LOCAL', cval.LOCAL,'TYPE="NUMBER"' );

end write_column_ordsource;

procedure write_column_photo( fl in out UTL_FILE.FILE_TYPE, cname in varchar2, cval in ordsys.ordimage, cattributes in varchar2 default null )
as
begin

 write_column_ordsource(fl, cname || '.' || 'SOURCE', cval.SOURCE  );
 write_column(fl, cname || '.' || 'HEIGHT', cval.HEIGHT,'TYPE="NUMBER"' );
 write_column(fl, cname || '.' || 'WIDTH', cval.WIDTH,'TYPE="NUMBER"' );
 write_column(fl, cname || '.' || 'CONTENTLENGTH', cval.CONTENTLENGTH,'TYPE="NUMBER"' );
 write_column(fl, cname || '.' || 'FILEFORMAT', cval.FILEFORMAT );
 write_column(fl, cname || '.' || 'CONTENTFORMAT', cval.CONTENTFORMAT );
 write_column(fl, cname || '.' || 'COMPRESSIONFORMAT', cval.COMPRESSIONFORMAT );
 write_column(fl, cname || '.' || 'MIMETYPE', cval.MIMETYPE );

end write_column_photo;

procedure write_column_video( fl in out UTL_FILE.FILE_TYPE, cname in varchar2, cval in ordsys.ordvideo, cattributes in varchar2 default null )
as
begin

 write_column(fl, cname || '.' || 'DESCRIPTION', cval.DESCRIPTION );
 write_column_ordsource(fl, cname || '.' || 'SOURCE', cval.SOURCE  );
 write_column(fl, cname || '.' || 'FORMAT', cval.FORMAT );
 write_column(fl, cname || '.' || 'MIMETYPE', cval.MIMETYPE );
 write_column_clob(fl, cname || '.' || 'COMMENTS', cval.COMMENTS );
 write_column(fl, cname || '.' || 'HEIGHT', cval.HEIGHT,'TYPE="NUMBER"' );
 write_column(fl, cname || '.' || 'WIDTH', cval.WIDTH,'TYPE="NUMBER"' );
 write_column(fl, cname || '.' || 'FRAMERESOLUTION', cval.FRAMERESOLUTION,'TYPE="NUMBER"' );
 write_column(fl, cname || '.' || 'FRAMERATE', cval.FRAMERATE,'TYPE="NUMBER"' );
 write_column(fl, cname || '.' || 'VIDEODURATION', cval.VIDEODURATION,'TYPE="NUMBER"' );
 write_column(fl, cname || '.' || 'NUMBEROFFRAMES', cval.NUMBEROFFRAMES,'TYPE="NUMBER"' );
 write_column(fl, cname || '.' || 'COMPRESSIONTYPE', cval.COMPRESSIONTYPE );
 write_column(fl, cname || '.' || 'NUMBEROFCOLORS', cval.NUMBEROFCOLORS,'TYPE="NUMBER"' );
 write_column(fl, cname || '.' || 'BITRATE', cval.BITRATE,'TYPE="NUMBER"' );

end write_column_video;

procedure write_column_audio( fl in out UTL_FILE.FILE_TYPE, cname in varchar2, cval in ordsys.ordaudio, cattributes in varchar2 default null )
as
begin

 write_column(fl, cname || '.' || 'DESCRIPTION', cval.DESCRIPTION );
 write_column_ordsource(fl, cname || '.' || 'SOURCE', cval.SOURCE  );
 write_column(fl, cname || '.' || 'FORMAT', cval.FORMAT );
 write_column(fl, cname || '.' || 'MIMETYPE', cval.MIMETYPE );
 write_column_clob(fl, cname || '.' || 'COMMENTS', cval.COMMENTS );
 write_column(fl, cname || '.' || 'ENCODING', cval.ENCODING );
 write_column(fl, cname || '.' || 'NUMBEROFCHANNELS', cval.NUMBEROFCHANNELS,'TYPE="NUMBER"' );
 write_column(fl, cname || '.' || 'SAMPLINGRATE', cval.SAMPLINGRATE,'TYPE="NUMBER"' );
 write_column(fl, cname || '.' || 'SAMPLESIZE', cval.SAMPLESIZE,'TYPE="NUMBER"' );
 write_column(fl, cname || '.' || 'COMPRESSIONTYPE', cval.COMPRESSIONTYPE );
 write_column(fl, cname || '.' || 'AUDIODURATION', cval.AUDIODURATION,'TYPE="NUMBER"' );

end write_column_audio;

procedure write_column_program( fl in out UTL_FILE.FILE_TYPE, cname in varchar2, cval in program_type, cattributes in varchar2 default null )
as
begin

 write_column(fl, cname || '.' || 'PROGRAM_NAME', cval.PROGRAM_NAME );
 write_column(fl, cname || '.' || 'PROGRAM_DESCRIPTION', cval.PROGRAM_DESCRIPTION );
 write_column(fl, cname || '.' || 'DURATION', cval.DURATION );
 write_column(fl, cname || '.' || 'COST_PER_HEAD', cval.COST_PER_HEAD,'TYPE="NUMBER"' );
 write_column(fl, cname || '.' || 'SCHOOL_YEAR', cval.SCHOOL_YEAR );
 write_column(fl, cname || '.' || 'WARS_COVERED', cval.WARS_COVERED );
 write_column(fl, cname || '.' || 'PROGRAM_TYPE', cval.PROGRAM_TYPE );
 write_column(fl, cname || '.' || 'URL', cval.URL );
 write_column(fl, cname || '.' || 'CURRICULUM_LINK', cval.CURRICULUM_LINK );
 write_column(fl, cname || '.' || 'ATTRIBUTE1', cval.ATTRIBUTE1 );
 write_column(fl, cname || '.' || 'ATTRIBUTE2', cval.ATTRIBUTE2 );
 write_column(fl, cname || '.' || 'ATTRIBUTE3', cval.ATTRIBUTE3 );

end write_column_program;

function base64( nmb integer ) return varchar2
 as
 begin
  return( substr('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/',nvl(nmb,0)+1,1) );
end base64;

function reverse_base64( val varchar2 ) return integer
 as
 begin
  return( instr('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/', val) - 1 );
end reverse_base64;

function conv_3bytes( fbytes varchar2 ) return varchar2
 as
  nmb 	integer;
  x	integer;
  y	integer;
  z	integer;
  a	integer; --4867657
 begin
  nmb := (65536*ascii(substr(fbytes,1,1))) + (256*ascii(substr(fbytes,2,1))) + ascii(substr(fbytes,3,1));
  --dbms_output.put_line( 'X1:' || nmb );
  x := trunc(nmb/262144);
  y := trunc((nmb - (x*262144))/4096);
  z := trunc(((nmb - (x*262144) - (y*4096)))/64);
  a := nmb - (x*262144) - (y*4096) - (z*64);
  return( base64(x) || base64(y) || base64(z) || base64(a)); -- || ':' || to_char(x) || '-' || to_char(y) || '-' || to_char(z) || '-' || to_char(a)
end conv_3bytes;

function conv_back_3bytes( fbytes varchar2 ) return raw
 as
  nmb 	integer;
  x	integer;
  y	integer;
  z	integer;
  val	char(4);
  ctr	integer;
  rw	raw(1000);
 begin
  rw := null;
  for j in 1..(length(fbytes)/4) loop
   val := substr(fbytes,((j-1)*4)+1,4);
   -- (ascii(substr(val,1,1)) - 65)
   nmb := (reverse_base64(substr(val,1,1))*262144) + (reverse_base64(substr(val,2,1))*4096) + (reverse_base64(substr(val,3,1))*64) + reverse_base64(substr(val,4,1));
   x := trunc(nmb/65536);
   y := trunc((nmb-(x*65536))/256);
   z := nmb - (x*65536) - (y*256);
   rw := utl_raw.concat( rw, utl_raw.cast_to_raw(chr(x) || chr(y) || chr(z)) );
  end loop;
  return( rw );
exception
 when others then
  glbx.dbg( 'C3B:' || '-' || sqlerrm );
  return( null );
end conv_back_3bytes;

procedure dump_blob( fl in out UTL_FILE.FILE_TYPE, img in blob, fname in varchar2 default null, display_mime_header in boolean default FALSE )
as

 v_count	integer;
 c_imgchunk	binary_integer;
 v_imgchunk	binary_integer;
 v_buffer 	raw(255);
 contentlength  integer;
 bfr		varchar2(2000);
 xbufr		varchar2(2000);

begin
 if dbms_lob.getlength(img) = 0 then return; end if;

 if display_mime_header
  then
   pline( fl,'--');
   pline( fl,'Content-Type: APPLICATION/octet-stream; name="' || fname || '"' );
   pline( fl,'Content-Transfer-Encoding: BASE64' );
   pline( fl,'Content-Description:' );
   pline( fl,'' );
  end if;

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
    pline( fl, bfr );
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
  pline( fl, bfr );
exception
 when others then return;
end dump_blob;

procedure dump_blob_full( fl in out UTL_FILE.FILE_TYPE, img in blob, fname in varchar2 default null, display_mime_header in boolean default FALSE )
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
   pline( fl,'--');
   pline( fl,'Content-Type: APPLICATION/octet-stream; name="' || fname || '"' );
   pline( fl,'Content-Transfer-Encoding: BASE64' );
   pline( fl,'Content-Description:' );
   pline( fl,'' );
  end if;

  if dbms_lob.getlength( img ) < 10000
   then
    -- Its quicker to manually do it
   if dbms_lob.getlength( img ) = 0 then return; end if;

    c_imgchunk := 57;
    v_imgchunk := 57;
    v_count := 0;
    begin
     loop
      dbms_lob.read(img, v_imgchunk,(v_count*c_imgchunk)+1,v_buffer);
      v_count := v_count + 1;
      bfr := NULL;
      xbufr := sys.utl_raw.cast_to_varchar2(v_buffer);
      for j in 1..19 loop
       bfr := bfr || conv_3bytes(substr(xbufr,((j-1)*3)+1,3));
      end loop;
      pline( fl, bfr );
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
    pline( fl, bfr );

   else

    -- Go to the OS and use the converter utility
    bl := os_command.extract_mime64( img, fl );

  end if;

exception
 when others then return;
end dump_blob_full;

procedure dump_clob( fl in out UTL_FILE.FILE_TYPE, img in clob, fname in varchar2 default null, display_mime_header in boolean default FALSE )
as

 v_count	integer;
 c_imgchunk	binary_integer;
 v_imgchunk	binary_integer;
 v_buffer 	varchar2(255);
 contentlength  integer;
 bfr		varchar2(2000);
 xbufr		varchar2(2000);

begin
 if dbms_lob.getlength(img) = 0 then return; end if;
 if display_mime_header
  then
   pline( fl,'--');
   pline( fl,'Content-Type: APPLICATION/octet-stream; name="' || fname || '"' );
   pline( fl,'Content-Transfer-Encoding: BASE64' );
   pline( fl,'Content-Description:' );
   pline( fl,'' );
  end if;

  c_imgchunk := 57;
  v_imgchunk := 57;
  v_count := 0;
  begin
   loop
    dbms_lob.read(img,v_imgchunk,(v_count*c_imgchunk)+1,v_buffer);
    v_count := v_count + 1;
    bfr := NULL;
    xbufr := v_buffer;
    for j in 1..19 loop
     bfr := bfr || conv_3bytes(substr(xbufr,((j-1)*3)+1,3));
    end loop;
    pline( fl, bfr );
   end loop;
  exception
   when no_data_found then null;
   when others
    then return;
  end;
  bfr := NULL;
  xbufr := v_buffer;
  if mod(length(xbufr),3) = 1 then xbufr := xbufr || chr(0) || chr(0);
  elsif mod(length(xbufr),3) = 2 then xbufr := xbufr || chr(0);
  end if;
  for j in 1..length(trunc(length(v_buffer)/3)) loop
   bfr := bfr || conv_3bytes(substr(xbufr,((j-1)*3)+1,3));
  end loop;
  pline( fl, bfr );
  commit;
exception
 when others then return;
end dump_clob;

procedure dump_clob_full( fl in out UTL_FILE.FILE_TYPE, img in clob, fname in varchar2 default null, display_mime_header in boolean default FALSE )
as

 v_count	integer;
 c_imgchunk	binary_integer;
 v_imgchunk	binary_integer;
 v_buffer 	raw(32767);

begin
 if dbms_lob.getlength(img) = 0 then return; end if;

 if display_mime_header
  then
   pline( fl,'--');
   pline( fl,'Content-Type: APPLICATION/octet-stream; name="' || fname || '"' );
   pline( fl,'Content-Transfer-Encoding: BASE64' );
   pline( fl,'Content-Description:' );
   pline( fl,'' );
  end if;

  c_imgchunk := 1000;
  v_imgchunk := 1000;
  v_count := 0;
  begin
   loop
    dbms_lob.read(img,v_imgchunk,(v_count*c_imgchunk)+1,v_buffer);
    v_count := v_count + 1;
    pline( fl, v_buffer);
   end loop;
  exception
   when no_data_found then null;
   when others
    then return;
  end;
exception
 when others then return;
end dump_clob_full;

procedure extract_tag( fl in out UTL_FILE.FILE_TYPE, tag_type out varchar2, tag_name out varchar2, tag_value out varchar2, extra_value_1 out varchar2, extra_value_2 out varchar2, error out varchar2 )
as

 cursor c1(tname varchar2) is select table_name from user_tables where table_name = tname;

 c1rec	c1%ROWTYPE;
 bfr	varchar2( 32767 );
 vbfr	varchar2( 32767 );
 tname	varchar2(100);

begin
 utl_file.get_line( fl, vbfr );
 bfr := trim(vbfr);
 if substr( bfr, 1, 2 ) = '</'
  then
   if upper(bfr) = '</REC>'
    then
     tag_type := 'END_REC';
     tag_name := NULL;
     tag_value := NULL;
     extra_value_1 := NULL;
     extra_value_2 := NULL;
     error := NULL;
   elsif upper(bfr) = '</TRANSACTION>'
    then
     tag_type := 'END_TRANSACTION';
     tag_name := NULL;
     tag_value := NULL;
     extra_value_1 := NULL;
     extra_value_2 := NULL;
     error := NULL;
   elsif upper(bfr) = '</BLOB>'
    then
     tag_type := 'END_BLOB';
     tag_name := NULL;
     tag_value := NULL;
     extra_value_1 := NULL;
     extra_value_2 := NULL;
     error := NULL;
   elsif upper(bfr) = '</CLOB>'
    then
     tag_type := 'END_CLOB';
     tag_name := NULL;
     tag_value := NULL;
     extra_value_1 := NULL;
     extra_value_2 := NULL;
     error := NULL;
   else
     -- Must be an end Table Name Marker
     -- Validate the Table Name
     tag_type := 'END_TABLE';
     tname := upper(substr(bfr,3));
     tname := substr(tname,1,length(tname)-1);
     open c1(tname);
     fetch c1 into c1rec;
     close c1;
     if c1rec.table_name is null
      then
       tag_value := tname;
       error := 'Table Not Found';
       return;
     end if;
     tag_name := NULL;
     tag_value := tname;
     extra_value_1 := NULL;
     extra_value_2 := NULL;
     error := NULL;
   end if;
   return;
 end if;

 if substr( bfr, 1, 1 ) = '<'
  then
   if upper(bfr) = '<REC>'
    then
     tag_type := 'REC';
     tag_name := NULL;
     tag_value := NULL;
     extra_value_1 := NULL;
     extra_value_2 := NULL;
     error := NULL;
   elsif substr(upper(bfr),1,12) = '<TRANSACTION'
    then
     tag_type := 'TRANSACTION';
     extract_tag_header( substr(bfr,2,instr(bfr,'>')-2),tag_name,extra_value_1,extra_value_2);
     extract_tag_body( substr(bfr,instr(bfr,'>')+1),tag_name,tag_value,error);
   elsif upper(substr(bfr,1,5)) = '<BLOB'
    then
     tag_type := 'BLOB';
     extract_tag_header( substr(bfr,2,instr(bfr,'>')-2),tag_name,extra_value_1,extra_value_2);
     tag_value := NULL;
     error := NULL;
   elsif upper(substr(bfr,1,5)) = '<CLOB'
    then
     tag_type := 'CLOB';
     extract_tag_header( substr(bfr,2,instr(bfr,'>')-2),tag_name,extra_value_1,extra_value_2);
     tag_value := NULL;
     error := NULL;
   else
    -- Extract Table or Column Value
     extract_tag_header( substr(bfr,2,instr(bfr,'>')-2),tag_name,extra_value_1,extra_value_2);
     extract_tag_body( substr(bfr,instr(bfr,'>')+1),tag_name,tag_value,error);
     if error is null
      then
       tag_type := 'COLUMN';
     else
       if extra_value_1 = 'TYPE="BLOB'
        then
         tag_type := 'BLOB_COLUMN';
       elsif extra_value_1 = 'TYPE="CLOB'
        then
         tag_type := 'CLOB_COLUMN';
       elsif substr(upper(bfr),2,length(tag_name)) = tag_name
        then
         tag_type := 'TABLE';
       else
         tag_type := 'ERROR';
       end if;
     end if;
   end if;
   return;
 end if;

 -- Must be a Blob or Clob Value. Return with it.
 tag_type := 'UNKNOWN';
 tag_value := vbfr;

end extract_tag;

function extract_parameter( extra_value_1 in varchar2, extra_value_2 in varchar2, tag_input in varchar2 )
 return varchar2
as

 x	integer;
 retvar	varchar2(1000);

begin
 x := instr(extra_value_1,tag_input);
 if x > 0
  then
   retvar := substr(extra_value_1,instr(extra_value_1,'"') + 1 );
   return( substr(retvar,1,length(retvar)) );
 end if;

 x := instr(extra_value_2,tag_input);
 if x > 0
  then
   retvar := substr(extra_value_2,instr(extra_value_2,'"') + 1 );
   return( substr(retvar,1,length(retvar)) );
 end if;

 return( NULL );

end extract_parameter;

procedure extract_tag_header( tag_input in varchar2, tag_name out varchar2, extra_value_1 out varchar2, extra_value_2 out varchar2 )
as

 x		integer;
 y		integer;
 leftover	varchar2(32767);

begin
 x := instr(tag_input,' ');
 if x = 0 then tag_name := upper(tag_input); extra_value_1 := NULL; extra_value_2 := NULL; return; end if;

 tag_name := upper(substr(tag_input,1,x - 1 ));
 leftover := substr(tag_input, x + 1 );
 y := instr(leftover,'"');
 if y = 0 then return; end if;

 x := instr(leftover,'"',1,2);
 extra_value_1 := trim(substr(leftover,1,x-1));
 leftover := substr(leftover,x+1);

 y := instr(leftover,'"');
 if y = 0 then return; end if;

 x := instr(leftover,'"',1,2);
 extra_value_2 := trim(substr(leftover,1,x-1));
 leftover := substr(leftover,x+1);

end extract_tag_header;

procedure extract_tag_body( tag_input in varchar2, tag_name in varchar2, tag_value out varchar2, error out varchar2 )
as

 x		integer;
 y		integer;
 leftover	varchar2(32767);

begin
 x := nvl(instr(upper(tag_input),'</' || tag_name || '>'),0);
 if x = 0 then tag_value := tag_input; error := 'Unable to find Tag End Marker'; return; end if;

 tag_value := substr(tag_input,1,x-1);

end extract_tag_body;

procedure load_set( fl in out UTL_FILE.FILE_TYPE, load_method in varchar2, ncols in myarray, nvals in myarray )
as

 tag_type	varchar2(1000);
 tag_name	varchar2(1000);
 tag_value	varchar2(32767);
 extra_value_1	varchar2(1000);
 extra_value_2	varchar2(1000);
 error		varchar2(1000);
 trep		varchar2(100);
 tvers		varchar2(100);
 vls		upd_arr;

begin
 extract_tag( fl, tag_type, tag_name, tag_value, extra_value_1, extra_value_2, error);
 if tag_type = 'TRANSACTION'
  then
   vls.rem_col.delete;
   vls.rem_oldv.delete;
   vls.rem_newv.delete;
   vls.rem_col(0) := NULL;
   vls.rem_oldv(0) := NULL;
   vls.rem_newv(0) := NULL;
   vls.rep_cols := ncols;
   vls.rep_vals := nvals;
   tvers := upper(nvl(extract_parameter(upper(extra_value_1),upper(extra_value_2),'VERSION' ),'V.4.5.V'));
   trep := upper(nvl(extract_parameter(upper(extra_value_1),upper(extra_value_2),'DRIVER' ),'REPLACE'));
   extract_transaction( fl, tvers, trep, vls );
   load_set( fl, load_method, ncols, nvals ); -- Recursive Call
  else
   return;
 end if;
end load_set;

procedure extract_transaction( fl in out UTL_FILE.FILE_TYPE, tvers in varchar2, trep in varchar2, vls in out NOCOPY upd_arr )
as

 cursor c1( tname varchar2 ) is select 'x' exst from user_tables where table_name = tname;

 c1rec		c1%ROWTYPE;
 tag_type	varchar2(1000);
 tag_name	varchar2(1000);
 tag_value	varchar2(32767);
 extra_value_1	varchar2(1000);
 extra_value_2	varchar2(1000);
 error		varchar2(1000);

begin
 extract_tag( fl, tag_type, tag_name, tag_value, extra_value_1, extra_value_2, error);
 if tag_type = 'TABLE'
  then
   open c1( tag_name );
   fetch c1 into c1rec;
   close c1;
   if c1rec.exst is null
    then
     --dbms_output.put_line('Unknown Table: ' || tag_name );
     -- Table Unknown
     return;
   end if;
   vls.table_name := tag_name;
   vls.ev1 := extra_value_1;
   vls.ev2 := extra_value_2;
   extract_record( fl, tvers, trep, tag_name, null, vls );
   extract_transaction( fl, tvers, trep, vls ); -- Recursive Call
 end if;

 extract_tag( fl, tag_type, tag_name, tag_value, extra_value_1, extra_value_2, error);
 if tag_type = 'END_TRANSACTION' then return; end if;
 -- If not End Transaction Tag have to return anyway.

exception when others then dbms_output.put_line( 'Extract Transaction:' || sqlerrm );
end extract_transaction;

procedure extract_pkval( vls in out NOCOPY upd_arr, stage in varchar2 )
as

val1		varchar2(1000);
val2		varchar2(1000);
nkey		integer;
pkexists	boolean;
v_umo		integer;
tot		integer;

function umo_exists( vls in out NOCOPY upd_arr, v_umo out integer )
 return boolean
is
 utype	varchar2(100);
 fval	varchar2(100);
 val	varchar2(4000);
begin
 -- First Find the UMO Type
 for j in vls.cols.first..vls.cols.last loop
  if vls.cols(j) = 'UMO_TYPE'
   then
    utype := vls.vals(j);
  end if;
 end loop;
 utype := nvl(utype,'PHOTO');
 -- Now determine the other unique column to search on based on this value
 if utype = 'AUDIO'
  then
   fval := 'AUDIO_ORIGINAL_LOC';
 elsif utype = 'VIDEO'
  then
   fval := 'VIDEO_ORIGINAL_LOC';
 elsif utype = 'DOCUMENT'
  then
   fval := 'DOCUMENT_ORIGINAL_LOC';
 elsif utype = 'BLUEPRINT'
  then
   fval := 'BLUEPRINT_OBJ.BLUEPRINT_ORIGINAL_LOC';
 else
  fval := 'PHOTO';
 end if;
 -- Now find the value of this column
 for j in vls.cols.first..vls.cols.last loop
  if vls.cols(j) = fval
   then
    val := vls.vals(j);
  end if;
 end loop;
 -- Now see if it already exists
 begin
  execute immediate 'select umo_id from umo um where um.' || fval || ' = :1'
   into tot
   using val;
 exception
  when others then
   return( FALSE );
 end;
 if tot is null
  then
   return( FALSE );
  else
   v_umo := tot;
   return( TRUE );
 end if;
exception
 when others then
  htp.bold( 'Error in UMO_EXISTS:' || sqlerrm ); htp.nl;
  return( FALSE );
end umo_exists;

begin
 -- Check if the row already exists at this point

 -- Currently this supports the concept of only one primary key
 if vls.table_name = 'UMO' and stage = 'STAGE2'
  then
   if vls.stage then return; end if; -- Have already calculate this step.

   pkexists := umo_exists( vls, v_umo ); -- Currently the only way to see if the row exists is to use the LOC value.

   -- Check if Row Already Exists and then act accordingly
   if upload_method = 'A' -- Ignore
     then
      if pkexists
       then
        vls.cmd := 'UPDATE';
        vls.ignore_rec := TRUE;
       else
        ump.init( 0, 'UNKNOWN', vls.pkids(1) ); -- Marked as Unknown during replication stage
        vls.pkcols(1) := 'UMO_ID';
        vls.cmd := 'UPDATE';
        vls.ignore_rec := FALSE;
      end if;

   elsif upload_method = 'B' -- Replace
     then
      -- In this version, cannot delete the old UMO record. Just have to update it. Hence it is exactly the same as overwrite
      if pkexists
       then
        vls.pkcols(1) := 'UMO_ID';
        vls.pkids(1) := v_umo;
        vls.cmd := 'UPDATE';
        vls.ignore_rec := FALSE;
       else
        ump.init( 0, 'UNKNOWN', vls.pkids(1) ); -- Marked as Unknown during replication stage
        vls.pkcols(1) := 'UMO_ID';
        vls.cmd := 'UPDATE';
        vls.ignore_rec := FALSE;
      end if;

   elsif upload_method = 'C' -- Copy
     then
      if pkexists
       then
        ump.init( 0, 'UNKNOWN', vls.pkids(1) ); -- Marked as Unknown during replication stage
        vls.pkcols(1) := 'UMO_ID';
        vls.cmd := 'UPDATE';
        vls.ignore_rec := FALSE;
       else
        ump.init( 0, 'UNKNOWN', vls.pkids(1) ); -- Marked as Unknown during replication stage
        vls.pkcols(1) := 'UMO_ID';
        vls.cmd := 'UPDATE';
        vls.ignore_rec := FALSE;
      end if;

   elsif upload_method = 'D' -- Overwrite (Do not create new record as it already exists)
     then
      if pkexists
       then
        vls.pkcols(1) := 'UMO_ID';
        vls.pkids(1) := v_umo;
        vls.cmd := 'UPDATE';
        vls.ignore_rec := FALSE;
       else
        ump.init( 0, 'UNKNOWN', vls.pkids(1) ); -- Marked as Unknown during replication stage
        vls.pkcols(1) := 'UMO_ID';
        vls.cmd := 'UPDATE';
        vls.ignore_rec := FALSE;
      end if;
   end if;
   vls.stage := TRUE;
   return;

  elsif vls.table_name = 'UMO' and stage = 'STAGE1'
   then
    return;

  elsif stage = 'STAGE2'
   then
    return;

  else
   vls.cmd := 'INSERT';
 end if;

 if vls.ev1 is null then return; end if;
 if upper(substr(vls.ev1,1,3)) = 'PK='
  then
   val1 := upper(replace(replace(vls.ev1,'"',''),' ',''));
   val1 := substr(val1,instr(val1,'=')+1);
   if vls.rep_cols.count > 0
    then
     for j in vls.rep_cols.first..vls.rep_cols.last loop
      if vls.rep_cols(j) = val1
       then
        -- add primary key here so an update only updates the value
        vls.pkcols(vls.pkcols.count+1) := val1;
        vls.pkids(vls.pkids.count+1) := vls.rep_vals(j);
        glbx.dbg( 'VV:' || val1 || '-' || vls.rep_vals(j) );
        return; -- Primary Key Override is specified, do not try and calculate the values of the primary key
      end if;
     end loop;
   end if;
   if upper(substr(vls.ev2,1,8)) = 'SEQUENCE'
    then
     val2 := upper(replace(replace(vls.ev2,'"',''),' ',''));
     val2 := substr(val2,instr(val2,'=')+1);
     if val2 is not null
      then
       begin execute immediate 'select ' || val2 || '.nextval from dual' into nkey; exception when others then null; end;
     end if;

     if nkey is not null
      then
       vls.pkcols(1) := val1;
       vls.pkids(1) := nkey;
     end if;
   end if;
 end if;
end extract_pkval;

procedure extract_record( fl in out UTL_FILE.FILE_TYPE, tvers in varchar2, trep in varchar2, tname in varchar2, lobcol in varchar2 default null, vls in out NOCOPY upd_arr )
as

 tag_type	varchar2(1000);
 tag_name	varchar2(1000);
 tag_value	varchar2(32767);
 extra_value_1	varchar2(1000);
 extra_value_2	varchar2(1000);
 error		varchar2(1000);
 ulob		blob;
 uclob		clob;

begin
 extract_tag( fl, tag_type, tag_name, tag_value, extra_value_1, extra_value_2, error);
 --glbx.dbg( 'X1A:' || tag_type );
 --glbx.dbg( 'X1B:' || tag_name );
 --glbx.dbg( 'X1C:' || tag_value );
 --glbx.dbg( 'X1D:' || extra_value_1);
 --glbx.dbg( 'X1E:' || extra_value_2 );
 --glbx.dbg( 'X1F:' || error );

 if tag_type = 'REC' or (tag_type = 'TABLE' and tag_name = 'REC' )
  then
   vls.pkids.delete;
   vls.pkcols.delete;
   vls.cols.delete;
   vls.ctype.delete;
   vls.vals.delete;
   vls.fks.delete;
   vls.cols(0) := NULL;
   vls.fks(0) := NULL;
   vls.ctype(0) := NULL;
   vls.vals(0) := NULL;
   vls.ignore_rec := FALSE;
   vls.stage := FALSE;
   extract_pkval( vls, 'STAGE1' );
    extract_column( fl, tvers, trep, tname, vls );
    --glbx.dbg('A1:' || vls.pkcols.count );
   add_record( tvers, trep, vls );
   extract_record( fl, tvers, trep, tname, lobcol, vls ); -- Recursive Call

 elsif tag_type = 'CLOB'
  then
   if vls.table_name = 'UMO' then extract_pkval( vls, 'STAGE2' ); end if; -- Delay the checking for the primary key until this stage

   if not vls.ignore_rec then dbms_lob.createtemporary(tclob, TRUE); end if;
   extract_clob( fl, tvers, trep, tname, vls );
   if dbms_lob.getlength(tclob) > 0 and not vls.ignore_rec
    then

     execute immediate 'select um.' || vls.cols(vls.cols.last) || ' from umo um where umo_id = :1 for update'
      into uclob
      using to_number(vls.pkids(1));
     execute immediate
      'begin dbms_lob.copy(:1,:2,dbms_lob.getlength(:3)); end;'
      using in out uclob, tclob, tclob;
     execute immediate
      'update umo um set um.' || vls.cols(vls.cols.last) || ' = :1 where umo_id = :2'
      using uclob, to_number(vls.pkids(1));

     commit;
   end if;
   if not vls.ignore_rec then dbms_lob.freetemporary(tclob);  end if;
   extract_record( fl, tvers, trep, tname, lobcol, vls ); -- Recursive Call

 elsif tag_type = 'BLOB'
  then
   -- Declare Blob as Temporary
   if vls.table_name = 'UMO' then extract_pkval( vls, 'STAGE2' ); end if; -- Delay the checking for the primary key until this stage
   if vls.ignore_rec then glbx.dbg( 'Record Ignored' ); end if;
   if not vls.ignore_rec then dbms_lob.createtemporary(tblob, TRUE);  end if;
   extract_blob( fl, tvers, tag_name, extra_value_1, vls );
   -- Add Blob. In this version only the UMO table is allowed to contain blobs
    --glbx.dbg('A1:' || dbms_lob.getlength(tblob) );
   if dbms_lob.getlength(tblob) > 0 and not vls.ignore_rec
    then
    --glbx.dbg('A2:' || dbms_lob.getlength(tblob) );

     execute immediate 'select um.' || vls.cols(vls.cols.last) || ' from umo um where umo_id = :1 for update'
      into ulob
      using to_number(vls.pkids(1));
     execute immediate
      'begin dbms_lob.copy(:1,:2,dbms_lob.getlength(:3)); end;'
      using in out ulob, tblob, tblob;
     execute immediate
      'update umo um set um.' || vls.cols(vls.cols.last) || ' = :1 where umo_id = :2'
      using ulob, to_number(vls.pkids(1));

     commit;
   end if;
   if not vls.ignore_rec then dbms_lob.freetemporary(tblob);  end if;
   extract_record( fl, tvers, trep, tname, lobcol, vls ); -- Recursive Call

 elsif lobcol is not null and lobcol = tag_value
  then
   -- End of LOB Found, continue on
   extract_column( fl, tvers, trep, tname, vls ); -- Recursive Call

 else
  null;
  -- dbms_output.put_line( 'L:' || tag_name || '-' || lobcol || '-' || error );
 end if;

 if tag_type = 'END_TABLE' then return; end if;
 -- If not End Transaction Tag have to return anyway.

exception when others then dbms_output.put_line( 'Extract Record:' || sqlerrm );
end extract_record;

procedure extract_column( fl in out UTL_FILE.FILE_TYPE, tvers in varchar2, trep in varchar2, tname in varchar2, vls in out NOCOPY upd_arr )
as

 tag_type	varchar2(1000);
 tag_name	varchar2(1000);
 tag_value	varchar2(32767);
 extra_value_1	varchar2(1000);
 extra_value_2	varchar2(1000);
 error		varchar2(1000);
 nmb		integer;
 val		varchar2(1000);
 x		integer;

begin
 extract_tag( fl, tag_type, tag_name, tag_value, extra_value_1, extra_value_2, error);
 if tag_type = 'COLUMN'
  then
   --insert into temp values (tname || '-' || tag_name );
   nmb := vls.cols.last+1;
   vls.cols(nmb) := tag_name;
   if upper(substr(extra_value_1,1,4)) = 'TYPE'
    then
     val := trim(replace(extra_value_1,'"',''));
     vls.ctype(nmb) := substr(val,instr(val,'=')+1);
    else
     if upper(substr(extra_value_2,1,4)) = 'TYPE'
      then
       val := trim(replace(extra_value_2,'"',''));
       vls.ctype(nmb) := substr(val,instr(val,'=')+1);
      else
       vls.ctype(nmb) := 'VARCHAR2';
     end if;
   end if;
   if upper(substr(extra_value_1,1,2)) = 'FK'
    then
     val := trim(replace(extra_value_1,'"',''));
     vls.fks(nmb) := substr(val,instr(val,'=')+1);
    else
     vls.fks(nmb) := null;
   end if;
   vls.vals(nmb) := tag_value;
   extract_column( fl, tvers, trep, tname, vls ); -- Recursive Call

 elsif tag_type = 'BLOB_COLUMN'
  then
   -- insert into temp values ( tname || '-' || tag_name );
   nmb := vls.cols.last+1;
   vls.cols(nmb) := tag_name;
   vls.ctype(nmb) := 'BLOB';
   vls.vals(nmb) := NULL;
   extract_record( fl, tvers, trep, tname, tag_name, vls ); -- Recursive Call

 elsif tag_type = 'CLOB_COLUMN'
  then
   --insert into temp values ( tname || '-' || tag_name );
   nmb := vls.cols.last+1;
   vls.cols(nmb) := tag_name;
   vls.ctype(nmb) := 'CLOB';
   vls.vals(nmb) := NULL;
   extract_record( fl, tvers, trep, tname, tag_name, vls ); -- Recursive Call
 end if;

 if tag_type = 'END_REC' then return; end if;
exception when others then dbms_output.put_line( 'Extract Column:' || sqlerrm );
end extract_column;

procedure extract_blob( fl in out UTL_FILE.FILE_TYPE, tvers in varchar2, tag_name in varchar2, extra_value_1 in varchar2, vls in out NOCOPY upd_arr )
as

 bl		boolean;
 inf_ctr	integer;
 error		varchar2(1000);
 rdata		raw(32767);
 bfr		varchar2(32767);
 ev		varchar2(1000);

begin
 --
 -- Check the blob type.
 --

 inf_ctr := 0;
 ev := trim(replace(extra_value_1,'TYPE="',''));
 -- If it is HEX then just convert it
 glbx.dbg( 'EV: ' || '+' || ev || '+' );
 if ev = 'HEX'
  then
   loop
    inf_ctr := inf_ctr + 1;
    if inf_ctr > 100000 then exit; end if;
    utl_file.get_line( fl, bfr );
    bfr := trim(bfr);
    if bfr = '</BLOB>' then exit; end if;
    rdata := bfr;
    if utl_raw.length(rdata) > 0 and not vls.ignore_rec
     then
      dbms_lob.writeappend( tblob, utl_raw.length(rdata), rdata );
    end if;
   end loop;

 -- If it is TYPE="MIME64", then use MIME utility to convert it and read in the file
 elsif ev = 'MIME64'
   then
    bl := os_command.reassemble_mime64( tblob, fl, '</BLOB>' );

 -- If it is TYPE="BASE64", then use PL/SQL to convert it. Its less then 32K so no need for fancy stuff in conversion
 elsif ev = 'BASE64'
   then
   loop
    inf_ctr := inf_ctr + 1;
    if inf_ctr > 100000 then exit; end if;
    utl_file.get_line( fl, bfr );
    bfr := trim(bfr);
    if bfr = '</BLOB>' then exit; end if;
    rdata := conv_back_3bytes(bfr);
    if utl_raw.length(rdata) > 0 and not vls.ignore_rec
     then
      dbms_lob.writeappend( tblob, utl_raw.length(rdata), rdata );
    end if;
   end loop;

 end if;

exception
 when others then glbx.dbg( 'extract_blob:' || sqlerrm );
end extract_blob;

procedure extract_clob( fl in out UTL_FILE.FILE_TYPE, tvers in varchar2, trep in varchar2, tname in varchar2, vls in out NOCOPY upd_arr )
as

 tag_type	varchar2(1000);
 tag_name	varchar2(1000);
 tag_value	varchar2(32767);
 extra_value_1	varchar2(1000);
 extra_value_2	varchar2(1000);
 error		varchar2(1000);
 etxt		varchar2(1000);

begin
 extract_tag( fl, tag_type, tag_name, tag_value, extra_value_1, extra_value_2, error);
 if tag_type = 'END_CLOB'
  then
   return;
 else
   if length(tag_value) > 0 and not vls.ignore_rec
    then
     dbms_lob.writeappend( tclob, length(tag_value), tag_value );
     extract_clob( fl, tvers, trep, tname, vls ); -- Recursive Call
   end if;
 end if;
end extract_clob;

 function check_pk_exists( vls in out NOCOPY upd_arr )
  return boolean
 as
  tot	integer;
 begin
   if vls.pkcols.count > 0
    then
     glbx.dbg( 'XP:' || 'select count(''x'') tot from ' || vls.table_name || ' where ' || vls.pkcols(1) || ' = :1' );
     glbx.dbg( 'XP2:' || vls.pkids(1) );
      execute immediate 'select count(''x'') tot from ' || vls.table_name || ' where ' || vls.pkcols(1) || ' = :1'
       into tot
       using vls.pkids(1);
      if tot > 0 then return( TRUE ); else return( FALSE ); end if;
    else
     return( FALSE );
   end if;
 exception
  when others then return( FALSE );
 end check_pk_exists;

 function check_pk_exists2( vls in out NOCOPY upd_arr )
  return boolean
 as

  cursor c1(tbl varchar2, ctype char) is select cname, dquery from dump_driver_unique_column where tname = tbl and dtype = ctype;
  tot		integer;

 begin

  for c1rec in c1(vls.table_name, 'P') loop
   for j in vls.cols.first..vls.cols.last loop

    if vls.cols(j) = c1rec.cname and vls.vals(j) is not null
     then
      -- Check the value doesn't already exist in the database
      glbx.dbg( 'TN2:' || 'select count(''x'') tot from ' || vls.table_name || ' where ' || vls.cols(j) || ' = :1' || '-' || vls.vals(j) );

      execute immediate 'select count(''x'') tot from ' || vls.table_name || ' where ' || vls.cols(j) || ' = :1'
       into tot
       using vls.vals(j);

      if tot > 0 then return( TRUE ); else return( FALSE ); end if;

    end if;
   end loop;
  end loop;
  return( FALSE );
 end check_pk_exists2;

procedure add_record(tvers in varchar2, trep in varchar2, vls in out NOCOPY upd_arr )
as

 --TYPE varchar2s IS TABLE OF VARCHAR2(256) INDEX BY BINARY_INTEGER;

 stmt		dbms_sql.varchar2s;
 c		number;
 lb		integer;
 ub		integer;
 dummy 		number;
 nmb		integer;
 pkexists	boolean;
 tvar		varchar2(4000);
 bfr		varchar2(32767);

 -- Insert and Update Statements might be longer than 32K. As such have to load them into an array and pass this to the database.
 procedure conv_stmt( st in varchar2, stmt in out dbms_sql.varchar2s )
 as
  curr	integer;
  j	integer;
  ret	varchar2(4000);
 begin
  if stmt.count = 0
   then
    curr := 1;
   else
    curr := stmt.last + 1;
  end if;
  j := 0;
  loop
   ret := substr(st,(j*256)+1,256);
   if ret is null then exit; end if;
   stmt(curr) := ret;
   curr := curr + 1;
   j := j + 1;
   if j > 1000 then exit; end if; -- Infinite Loop Protection
  end loop;
 end conv_stmt;

 -- Replace any values with new ones (foreign key replacement)
 procedure replace_vals( vls in out NOCOPY upd_arr )
 as
  cursor c1(acid integer) is select username from customer_account where aid = acid;
  c1rec  c1%ROWTYPE;
 begin
  if vls.rep_cols.count = 0 then return; end if;
  for j in vls.rep_cols.first..vls.rep_cols.last loop
   for k in vls.cols.first..vls.cols.last loop
    if vls.rep_cols(j) = vls.cols(k)
     then
      vls.vals(k) := vls.rep_vals(j);
      exit;
    end if;
   end loop;
  end loop;

  -- Specialised Exceptions
  if vls.table_name = 'CUSTOMER_ACCOUNT'
   then
    for j in vls.cols.first..vls.cols.last loop
     if vls.cols(j) = 'AID'
      then
       for k in vls.rep_cols.first..vls.rep_cols.last loop
        if vls.rep_cols(k) = 'AID'
         then
          for m in vls.cols.first..vls.cols.last loop
           if vls.cols(m) = 'AID' then vls.vals(m) := vls.rep_vals(k);  end if;
          end loop;
        end if;
       end loop;

     elsif vls.cols(j) = 'USERNAME'
      then
       for k in vls.rep_cols.first..vls.rep_cols.last loop
        if vls.rep_cols(k) = 'AID'
         then
          open c1( vls.rep_vals(k) );
          fetch c1 into c1rec;
          close c1;
        end if;
       end loop;
       for k in vls.cols.first..vls.cols.last loop
        if vls.cols(k) = 'USERNAME'
         then
          vls.vals(j) := c1rec.username;
        end if;
       end loop;
     end if;
    end loop;
  end if;

 end replace_vals;

 -- Change the Primary Key value, and put quotes around it if it is a varchar
 procedure adjust_pkval( vls in out NOCOPY upd_arr )
 as
  x	integer;
 begin
  if vls.pkcols.count = 0 then return; end if;
  for j in vls.pkcols.first..vls.pkcols.last loop
   for k in vls.cols.first..vls.cols.last loop
    if vls.pkcols(j) = vls.cols(k)
     then
      -- Note what the old and new primary keys are, subsequently they might need to be modified
      x := vls.rem_col.last + 1;
      vls.rem_col(x) := vls.pkcols(j);
      vls.rem_oldv(x) := vls.vals(k);
      vls.rem_newv(x) := vls.pkids(j);
      vls.vals(k) := vls.pkids(j);
      if vls.ctype(k) = 'VARCHAR2'
       then
        vls.pkids(j) := '''' || replace(vls.pkids(j),'''','''''') || '''';
      end if;
      exit;
    end if;
   end loop;
  end loop;
 end adjust_pkval;

 -- All the old Primary Keys are stored in an array with the new ones used, go through and replace them all
 procedure remember_old_pk( vls in out NOCOPY upd_arr )
 as
 begin
  -- Note: This statement could be the cause of grief later on
  if vls.ev2 is not null then return; end if;  -- Return if there is a sequence number of the column

  -- Go through and replace all old primary key values with the new one
  for j in vls.cols.first..vls.cols.last loop
   for k in vls.rem_col.first..vls.rem_col.last loop
    if vls.rem_col(k) = vls.cols(j) and
       vls.rem_oldv(k) = vls.vals(j)
     then
      vls.vals(j) := vls.rem_newv(k);
    end if;
   end loop;
  end loop;
 end remember_old_pk;

 -- Replace UMO_SCENE_ID in the UMO_SCENE table (UMO Table Only)
 procedure replace_umo( vls in out NOCOPY upd_arr )
 as
  cursor c1( ttl varchar2 ) is select umo_scene_id from umo_scene where upper(title) = upper(ttl) and owned_by = 'PUBLIC';
  cursor c2( ttl varchar2 ) is select umo_scene_id from umo_scene where upper(title) = upper(ttl) and owned_by = 'PHOTOGRAPHER';
 begin
  if vls.table_name <> 'UMO' then return; end if;
  for j in vls.cols.first..vls.cols.last loop
   if vls.cols(j) = 'UMO_SCENE_ID'
    then
     open c1(vls.vals(j));
     fetch c1 into vls.vals(j);
     if c1%NOTFOUND
      then
       open c2(vls.vals(j));
       fetch c2 into vls.vals(j);
       if c2%NOTFOUND
        then
         vls.vals(j) := 0;
       end if;
       close c2;
     end if;
     close c1;
     vls.ctype(j) := 'NUMBER';
   end if;
  end loop;
 end replace_umo;

 -- Unique columns are not primary key ones, but have to be unique for the table (ie USERNAME). If they are not unique append to them the sequence number
 procedure check_unique_columns( vls in out NOCOPY upd_arr )
 as

  cursor c1(tbl varchar2, ctype char) is select cname, dquery from dump_driver_unique_column where tname = tbl and dtype = ctype;
  tot		integer;
  newseq	integer;
  x		integer;
  rowid1	rowid;
  rowid2	rowid;
  fval		varchar2(4000);

 begin
  -- Used for Inserts Only and Update when Replace, Copy, Overwrite
  -- If Update - Replace/Overwrite then the duplicate can only exist in the current row.

  -- First replace Unique Sequences
  --glbx.dbg( 'TN:' || vls.table_name );

  for c1rec in c1(vls.table_name, 'P') loop
   for j in vls.cols.first..vls.cols.last loop

    if vls.cols(j) = c1rec.cname and vls.vals(j) is not null
     then
      -- Check the value doesn't already exist in the database
      --glbx.dbg( 'TN2:' || 'select count(''x'') tot from ' || vls.table_name || ' where ' || vls.cols(j) || ' = :1' || '-' || vls.vals(j) );

      execute immediate 'select count(''x'') tot from ' || vls.table_name || ' where ' || vls.cols(j) || ' = :1'
       into tot
       using vls.vals(j);

      -- If we are inserting and the row is already there, then aren't we going to do an update instead?
      -- if tot > 0 and vls.cmd = 'INSERT' then vls.cmd := 'UPDATE'; end if;

      if tot > 0
       then
        if vls.cmd = 'INSERT'
         then
          -- Make the Value Unique
          select s_dump_driver.nextval into newseq from dual;
          vls.vals(j) := vls.vals(j) || '_' || to_char(newseq);

        elsif vls.cmd = 'UPDATE'
         then
          -- Extract the rowid from the duplicated row and the current row to be update. If they match ignore the duplication, otherwise make it unique.
          -- If no primary key value has been extracted then ignore it for now.
          if vls.pkcols.count > 0
           then
            execute immediate 'select rowid from ' || vls.table_name || ' where ' || vls.pkcols(1) || ' = :1'
            into rowid1
            using vls.pkids(1);
            execute immediate 'select rowid from ' || vls.table_name || ' where ' || vls.cols(j) || ' = :1 and rownum < 2'
            into rowid2
            using vls.vals(j);
            --glbx.dbg( 'R1:' || rowid1 );
            --glbx.dbg( 'R2:' || rowid2 );
            --glbx.dbg( 'S1:' || vls.pkids(1) );
            --glbx.dbg( 'S2:' || vls.vals(j) );
            if rowid1 <> rowid2
             then
              select s_dump_driver.nextval into newseq from dual;
              --glbx.dbg('S3:' || vls.vals(j) || '_' || to_char(newseq) );
              vls.vals(j) := vls.vals(j) || '_' || to_char(newseq);
            end if;
          end if; -- pkcols.count > 0
        end if; -- vls.cmd = INSERT
      end if; -- tot > 0
    end if; -- vls.cols(j) = c1rec.cname

   end loop;
  end loop;

  -- Second replace Foreign Keys with the appropriate values (eg. umo_attribute - meta tag id)
  for c1rec in c1(vls.table_name, 'V') loop
   for j in vls.cols.first..vls.cols.last loop

    if vls.cols(j) = c1rec.cname and vls.vals(j) is not null
     then
      fval := vls.fks(j);
      begin
       execute immediate replace(c1rec.dquery,'<' || c1rec.cname || '>', fval)
        into vls.vals(j);
      exception
       when others then vls.vals(j) := null;
      end;
    end if;

   end loop;
  end loop;

 end check_unique_columns;

begin

 --glbx.dbg('B1:' || vls.table_name );
 --glbx.dbg('B2:' || upload_method );
 -- Need smarts here to work out which statement is to be run
 stmt.delete;
 if vls.ignore_rec then return; end if;

 pkexists := check_pk_exists( vls );
 if not pkexists then pkexists := check_pk_exists2( vls ); end if;

 -- Look at the Upload Method and determine the course of Action.
 --glbx.dbg('B1:' || vls.table_name );
 --glbx.dbg('B2:' || upload_method );
 if vls.table_name <> 'UMO' -- UMO Table Operation has already been calculated in extract_pkval
  then

   if upload_method = 'A' -- Ignore
    then
     if pkexists then return; end if;

   elsif upload_method = 'B' -- Replace
    then
     if pkexists
      then
       -- Delete
       begin
        execute immediate 'delete from ' || vls.table_name || ' where ' || vls.pkcols(1) || ' = :1'
         using vls.pkids(1);
       exception
        when others then
         htp.bold( 'Error: Deleting from ' || vls.table_name|| ' where ' || vls.pkcols(1) || ' = ' || vls.pkids(1) ); htp.nl;
         htp.bold( 'Error Stmt: ' || sqlerrm );
         return;
       end;
       -- Insert
       vls.cmd := 'INSERT';
     end if;

   elsif upload_method = 'C' -- Copy
    then
     if pkexists
      then
       -- Note: Duplicate Columns Need to be fixed. Add Sequence Number to original primary key values.
       for j in vls.pkcols.first..vls.pkcols.last loop
        for k in vls.cols.first..vls.cols.last loop
         if vls.cols(k) = vls.pkcols(j)
          then
           select s_dump_driver.nextval into nmb from dual;
           vls.vals(j) := vls.vals(j) || '_' || to_char(nmb);
         end if;
        end loop;
       end loop;
     end if;
     vls.cmd := 'INSERT';

   elsif upload_method = 'D' -- Overwrite (Simple Update is all that is required)
    then
     if pkexists then vls.cmd := 'UPDATE'; end if;

   end if;

 end if;

 --glbx.dbg( 'B2:' || vls.cmd );
 if vls.cmd = 'INSERT'
  then

   bfr := NULL;
   replace_vals(vls);
   adjust_pkval(vls);
   remember_old_pk(vls);
   replace_umo(vls);
   check_unique_columns(vls);

   for j in vls.cols.first..vls.cols.last loop
    if vls.cols(j) is not null and vls.ctype(j) in ('VARCHAR2','NUMBER','DATE')
     then
      if colexists(vls.table_name,vls.cols(j))
       then
        bfr := bfr || ',' || vls.cols(j);
      end if;
    end if;
   end loop;
   bfr := 'insert into ' || vls.table_name || '(' || substr(bfr,2) || ') values (';
   conv_stmt(bfr,stmt);
   --glbx.dbg( 'Y1:' || stmt(1) );

   bfr := NULL;
   for j in vls.cols.first..vls.cols.last loop
    if colexists(vls.table_name,vls.cols(j))
    then
    if vls.cols(j) is not null
     then
      if vls.ctype(j) = 'VARCHAR2'
       then
        if vls.vals(j) is null
         then
          conv_stmt( bfr || 'NULL',stmt);
         else
          conv_stmt( bfr || '''' || replace(vls.vals(j),'''','''''') || '''',stmt);
        end if;
        bfr := ',';
      elsif vls.ctype(j) = 'NUMBER'
       then
        if vls.vals(j) is null
         then
          conv_stmt( bfr || 'NULL',stmt);
         else
          conv_stmt( bfr || nvl(replace(replace(vls.vals(j),'''',''),',',''),'NULL'),stmt);
        end if;
        bfr := ',';
      elsif vls.ctype(j) = 'DATE'
       then
        if vls.vals(j) is null
         then
          conv_stmt( bfr || 'NULL',stmt);
         else
          conv_stmt( bfr || 'to_date(''' || replace(vls.vals(j),'''','''''') || ''',''' || LNG.TSMASK || ''')',stmt);
        end if;
        bfr := ',';
      end if;
    end if;
    end if;
   end loop;
   conv_stmt(')',stmt);

 elsif vls.cmd = 'UPDATE'
  then

   bfr := NULL;
   replace_vals(vls);
   adjust_pkval(vls);
   remember_old_pk(vls);
   replace_umo(vls);
   check_unique_columns(vls);
   conv_stmt('update ' || vls.table_name || ' als set ',stmt);

   for j in vls.cols.first..vls.cols.last loop
    if vls.cols(j) is not null and vls.ctype(j) in ('VARCHAR2','NUMBER','DATE')
     then
      if vls.ctype(j) = 'VARCHAR2'
       then
        if vls.vals(j) is null
         then
          conv_stmt( bfr || 'als.' || vls.cols(j) || ' = ' || 'NULL',stmt);
         else
          conv_stmt( bfr || 'als.' || vls.cols(j) || ' = ' || '''' || replace(vls.vals(j),'''','''''') || '''',stmt);
        end if;
        bfr := ',';
      elsif vls.ctype(j) = 'NUMBER'
       then
        if vls.vals(j) is null
         then
          conv_stmt( bfr || 'als.' || vls.cols(j) || ' = ' || 'NULL',stmt);
         else
          conv_stmt( bfr || 'als.' || vls.cols(j) || ' = ' || nvl(replace(replace(vls.vals(j),'''',''),',',''),'NULL'),stmt);
        end if;
        bfr := ',';
      elsif vls.ctype(j) = 'DATE'
       then
        if vls.vals(j) is null
         then
          conv_stmt( bfr || 'als.' || vls.cols(j) || ' = ' || 'NULL',stmt);
         else
          conv_stmt( bfr || 'als.' || vls.cols(j) || ' = ' || 'to_date(''' || replace(vls.vals(j),'''','''''') || ''',''' || LNG.TSMASK || ''')',stmt);
        end if;
        bfr := ',';
      end if;
    end if;
   end loop;
   if vls.pkcols.count > 0
    then
     bfr := NULL;
     for j in vls.pkcols.first..vls.pkcols.last loop
      bfr := bfr || 'and ' || 'als.' || vls.pkcols(j) || '=' || vls.pkids(j);
     end loop;
     bfr := substr(bfr,4);
     conv_stmt( ' where ' || bfr, stmt );
   end if;

 elsif vls.cmd = 'DELETE'
  then
   -- Handle this later
   null;
 end if;

 lb := stmt.first;
 ub := stmt.last;

   -- for j in stmt.first..stmt.last loop
   -- glbx.dbg( 'STMT: ' || stmt(j) );
   -- end loop;

 begin
  c := dbms_sql.open_cursor;
  dbms_sql.parse(c, stmt, lb, ub, FALSE, dbms_sql.native );
  dummy := dbms_sql.execute(c);
  dbms_sql.close_cursor(c);
  if vls.cmd = 'INSERT'
   then
    htp.p( 'Inserted Record into ' || vls.table_name ); htp.nl;
  elsif vls.cmd = 'UPDATE'
   then
    htp.p( 'Updated Record in ' || vls.table_name ); htp.nl;
  end if;
 exception
  when others
   then
    tvar := sqlerrm;
    begin dbms_sql.close_cursor(c); exception when others then null; end;
    htp.bold( 'Error: Statement Failed: ' || sqlerrm ); htp.nl;
    for j in stmt.first..stmt.last loop
     htp.bold( stmt(j) ); htp.nl;
    end loop;
 end;

 commit;

exception
 when others then
  htp.bold( 'Error in Add_Record: ' || sqlerrm ); htp.nl;
  htp.bold( 'Table: ' || vls.table_name ); htp.nl;
  htp.bold( 'Column Info Dump' ); htp.nl;
  for j in vls.cols.first..vls.cols.last loop
   htp.bold( vls.cols(j) || '-' || vls.ctype(j) || '-' || vls.vals(j) ); htp.nl;
  end loop;
end add_record;

procedure display_download(surl in varchar2)
as

 cursor c1 is select distinct driver_type from dump_driver_stmt;

 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'XML.DISPLAY_DOWNLOAD');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 adm.main_title( surl, sessid, 'XML Unload Screen', helpid=>'A93');
 htp.p( '<CENTER>' );
 htp.nl;
 htp.formopen( 'xml.display_download_main' );
 htp.formhidden( 'SURL', surl );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Download Driver' ) );
   htp.p( '<TD>' );
   htp.formselectopen( 'DRIVER' );
   for c1rec in c1 loop
    htp.formselectoption( c1rec.driver_type );
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, 'Choose Download Driver' );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
end display_download;

procedure display_download_main(surl in varchar2, driver in varchar2)
as

 cursor c1 is select p.username,p.pid,a.username auser, a.aid from customer_account a, photographer p where a.pid = p.pid order by p.username,a.username;
 cursor c2(driver varchar2) is select * from dump_driver_stmt where driver_type = driver;
 cursor c3(driver varchar2) is select count('x') tot from dump_driver_stmt where driver_type = driver and extract_images = 'T';

 TYPE DCurTyp IS REF CURSOR;  -- define weak REF CURSOR type

 dcurs  	DCurTyp;
 sessid		integer;
 sts		varchar2(200);
 c3rec		c3%ROWTYPE;
 val1		varchar2(4000);
 val2		varchar2(4000);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'XML.DISPLAY_DOWNLOAD_MAIN');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 adm.main_title( surl, sessid, 'XML Unload Screen', helpid=>'A93');
 htp.p( '<CENTER>' );
 open c3(driver);
 fetch c3 into c3rec;
 close c3;
 htp.formopen( 'xml.accept_display_download' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'DRIVER', driver );
 htp.formhidden( 'P7', null );
 htp.formhidden( 'P8', null );
 htp.nl;
 htp.bold( driver );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.formradio('P1','F','CHECKED'),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
   htp.tabledata( htf.bold( 'Download to a file on the Server' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Directory' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"' );
   htp.tabledata( htf.formtext( 'P3', 30, 100, glbx.extract_master_parameter('REPORTS_DIRECTORY') ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'File Name' || htf.nl || '(Without Extension)' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"' );
   htp.tabledata( htf.formtext( 'P4', 30, 100, 'extract' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formradio('P1','B'),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
   htp.tabledata( htf.bold( 'Download file through Browser' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  for c2rec in c2(driver) loop
  htp.tablerowopen;
   htp.tabledata( htf.bold( initcap(replace(c2rec.parameter_name,'_',' ')) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="LEFT"');
   htp.formhidden( 'P7', c2rec.parameter_name );
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="LEFT">' );
   htp.formselectopen( 'P8' );
   open dcurs for c2rec.sql_stmt;
   loop
    fetch dcurs into val1,val2;
    if dcurs%NOTFOUND then exit; end if;
    htp.formselectoption( val2, cattributes=>'VALUE="' || val1 || '"' );
   end loop;
   close dcurs;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  end loop;

  if c3rec.tot > 0
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold( 'From UMO Image Id' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="LEFT"' );
     htp.tabledata( htf.formtext( 'P5', 10, 20 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( 'To UMO Image Id' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="LEFT"' );
     htp.tabledata( htf.formtext( 'P6', 10, 20 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="LEFT"');
    htp.tablerowclose;
  end if;
 htp.tableclose;
 htp.nl;
 htp.tableopen;
 htp.tablerowopen;
  htp.tabledata(htf.formsubmit( null, 'Unload to XML File' ) || htf.formclose);
  htp.tabledata(htf.formopen('xml.display_download') || htf.formhidden('SURL',surl) || htf.formsubmit( null, LNG.ORD_ALT_062 ) || htf.formclose);
 htp.tablerowclose;
 htp.tableclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception
 when others then
 glbx.error_details( 'XML', 'DISPLAY_DOWNLOAD_MAIN',errmsg=>sqlerrm,extdet=>'SESSID:' || sessid);
end display_download_main;

procedure accept_display_download( surl in varchar2, driver in varchar2, p1 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2 default null, p6 in varchar2 default null, p7 in GLBX.MYARRAY, p8 in GLBX.MYARRAY )
as

  sessid	integer;
  sts		varchar2(200);
  ncols		myarray;
  nvals		myarray;
  ctr		integer;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'XML.ACCEPT_DISPLAY_DOWNLOAD');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 ctr := 0;
 if p5 is not null
  then
   ctr := ctr + 1;
   ncols(ctr) := 'FROM-UMO';
   nvals(ctr) := p5;
 end if;
 if p6 is not null
  then
   ctr := ctr + 1;
   ncols(ctr) := 'TO-UMO';
   nvals(ctr) := p6;
 end if;
 for j in p7.first..p7.last loop
  if p7(j) is not null
   then
    ctr := ctr + 1;
    ncols(ctr) := p7(j);
    nvals(ctr) := p8(j);
  end if;
 end loop;
main( 'UNLOAD', p1, p3, glbx.extract_fname(p4,'NO_EXTENSION'), driver, ncols, nvals );
if p1 = 'B' then return; end if;

adm.main_title( surl, sessid, 'XML Downloaded', helpid=>'A93');
htp.p( '<CENTER>' );
htp.bold( 'Downloaded to : ' || p3 || '-' || p4 );
htp.p( '</CENTER>' );
htp.htmlclose;
end accept_display_download;

procedure main( cmd in varchar2, downtype in varchar2, directory in varchar2, filename in varchar2, driver in varchar2, nparms in myarray, nvls in myarray )
as

  fl 		UTL_FILE.FILE_TYPE;
  v_count	integer;
  c_imgchunk	binary_integer;
  v_imgchunk	binary_integer;
  buffer 	varchar2(32767);
  ncols		myarray;
  nvals		myarray;
  frm		integer;
  uto		integer;
  res		boolean;
  zip_files	UMP.MYARRAY;
  vdir		varchar2(1000);
  vfl		varchar2(1000);
  bfl		bfile;
  dispout	GLBX.MYARRAY;

begin

 if cmd = 'UNLOAD'
  then
   download_method := 'FILE';
   /*
   if downtype = 'F'
    then
   elsif downtype = 'B'
    then
     download_method := 'BROWSER';
   end if;
   */

   frm := NULL;
   uto := NULL;
   for j in nparms.first..nparms.last loop
    if nparms(j) = 'FROM-UMO' then frm := nvls(j); end if;
    if nparms(j) = 'TO-UMO' then uto := nvls(j); end if;
   end loop;

   if downtype = 'F'
    then
     fl := utl_file.fopen( directory, filename || '.txt', 'w', 32767);
    else
     select 'tempfile_' || trim(to_char(s_filename.nextval)) into vfl from dual;
     vdir := glbx.extract_master_parameter( 'WORK_DIRECTORY' );
     fl := utl_file.fopen( vdir, vfl || '.txt', 'w', 32767);
   end if;
   dump_set(fl, driver, filename || '.txt', frm, uto, nparms, nvls);

   utl_file.fclose(fl);

   -- Only zip the file if it is greater than 100K
   if downtype = 'F'
    then
     execute immediate 'create or replace directory ' || GLBX.GLOBAL_DIR || ' as ''' || directory || '''';
     bfl := bfilename( GLBX.GLOBAL_DIR, filename || '.txt' );
    else
     execute immediate 'create or replace directory ' || GLBX.GLOBAL_DIR || ' as ''' || vdir || '''';
     bfl := bfilename( GLBX.GLOBAL_DIR, vfl || '.txt' );
   end if;

   if dbms_lob.getlength( bfl ) < 100000
    then
     -- Just pass it down as is
     if downtype = 'F'
      then
       null;
      else
       htp.prn('Content-type: ' || 'bad/type' || NL_CHAR);
       htp.prn('Content-Disposition: attachment; filename=' || filename || '.txt' || NL_CHAR); -- '"' || instead of attachment file
       htp.prn('Content-Transfer-Encoding: binary' || NL_CHAR);
       htp.prn(NL_CHAR);
       wpg_docload.download_file( bfl );
       res := os_command.delete_file(vdir || DECS.UNIX_OR_NT || vfl || '.txt', dispout, TRUE );
     end if;

    else

     -- Zip It
     if downtype = 'F'
      then
       zip_files(1) := directory || DECS.UNIX_OR_NT || filename || '.txt';
       res := ump.zip( FALSE, FALSE, directory || DECS.UNIX_OR_NT || filename || '.zip', zip_files );
      else
       htp.prn('Content-type: ' || 'bad/type' || NL_CHAR);
       htp.prn('Content-Disposition: attachment; filename=' || filename || '.zip' || NL_CHAR); -- '"' || instead of attachment file
       htp.prn('Content-Transfer-Encoding: binary' || NL_CHAR);
       htp.prn(NL_CHAR);
       zip_files(1) := vdir || DECS.UNIX_OR_NT || vfl || '.txt';
       res := ump.zip( FALSE, FALSE, vdir || DECS.UNIX_OR_NT || vfl || '.zip', zip_files );
       download_method := 'BROWSER';
       bfl := bfilename( GLBX.GLOBAL_DIR, vfl || '.zip' );
       wpg_docload.download_file( bfl );
       res := os_command.delete_file(vdir || DECS.UNIX_OR_NT || vfl || '.txt', dispout, TRUE );
       res := os_command.delete_file(vdir || DECS.UNIX_OR_NT || vfl || '.zip', dispout, TRUE );
     end if;
   end if;

 elsif cmd = 'LOAD'
  then
   upload_method := driver;
    --glbx.dbg( directory );
    --glbx.dbg( filename );
   fl := utl_file.fopen( directory, filename, 'r', 32767);

   --load_set(fl,driver,ncols,nvals);
   load_set(fl,driver,nparms,nvls);
   for j in nparms.first..nparms.last loop
    glbx.dbg( 'P1:' || nparms(j) || '-' || nvls(j) );
   end loop;
   utl_file.fclose(fl);
 end if;

exception
 when others then utl_file.fclose(fl);
  glbx.dbg( sqlerrm );
  dbms_output.put_line( sqlerrm );
end main;

procedure run_upload(surl in varchar2)
as

 cursor c1 is select manufacturer_id,name,username from manufacturer order by name;
 cursor c2 is select pid,business_name,username from photographer order by business_name;
 cursor c3 is select p.pid,c.aid,c.username,p.business_name from customer_account c, photographer p where c.pid = p.pid order by p.business_name,c.username;

 sessid	integer;
 sts	varchar2(200);

begin
 glbx.adm_cookie_id( surl,sessid,sts,'XML.RUN_UPLOAD');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 adm.main_title( surl, sessid, 'XML Upload Screen', helpid=>'A92');
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'xml.accept_run_upload', cattributes=>'enctype="multipart/form-data"' );
 htp.formhidden( 'SURL', surl );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.formradio('P1','F','CHECKED'),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
   htp.tabledata( htf.bold( 'Load using File Located on Server' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Directory' ), cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
   htp.tabledata( htf.formtext( 'P2', 30, 100, glbx.extract_master_parameter('REPORTS_DIRECTORY') ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'File Name' ), cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"' );
   htp.tabledata( htf.formtext( 'P3', 30, 100, 'extract.txt' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formradio('P1','B'),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
   htp.tabledata( htf.bold( 'Upload using file from Browser' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'File Name' ), cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"' );
   htp.tabledata( GLBX.UPLOAD_NAME,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="LEFT"' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( '&nbsp;',cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
   htp.tabledata( htf.bold( 'Load Options'),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
   htp.tabledata( '&nbsp;', cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formradio('P4','A','CHECKED'),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
   htp.tabledata( htf.bold( 'Ignore'),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Bypass the create of a new record if the original record already exists.' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formradio('P4','B'),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
   htp.tabledata( htf.bold( 'Replace'),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Replace the Record with the new one if the original record already exists.' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formradio('P4','C'),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
   htp.tabledata( htf.bold( 'Copy'),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Create a new record if the original record already exists.' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formradio('P4','D'),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
   htp.tabledata( htf.bold( 'Overwrite'),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Update the record with new details if the original record already exists.' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold('Optional'),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
   htp.tabledata( htf.bold( 'Specify Accounts to Load into' ), cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Client/Photographer' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="LEFT">');
   htp.formselectopen( 'P5' );
   -- htp.formselectoption( NULL );
   for c2rec in c2 loop
    htp.formselectoption( c2rec.business_name || '-' || c2rec.username, cattributes=>'VALUE="' || c2rec.pid || '"' );
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Manufacturer' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="LEFT">');
   htp.formselectopen( 'P6' );
   -- htp.formselectoption( NULL );
   for c1rec in c1 loop
    htp.formselectoption( c1rec.name || '-' || c1rec.username, cattributes=>'VALUE="' || c1rec.manufacturer_id || '"' );
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Customer' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
   htp.p( '<TD ' || GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="LEFT">');
   htp.formselectopen( 'P7' );
   --htp.formselectoption( NULL );
   for c3rec in c3 loop
    htp.formselectoption( c3rec.business_name || '-' || c3rec.username, cattributes=>'VALUE="[' || c3rec.pid || ']' || c3rec.aid || '"' );
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, 'Upload XML File' );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
end run_upload;

procedure accept_run_upload( surl in varchar2, file in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2 default null, p6 in varchar2 default null, p7 in varchar2 default null )
as

  cursor c2(uname varchar2) is select blob_content from apache_ows_content where name = uname;

  ncols		myarray;
  nvals		myarray;
  v_umo 	integer;
  blb		blob;
  dm		integer;
  dump_dir	varchar2(1000);
  fname		varchar2(100);
  wait_seconds 	integer := 30;
  result 	integer;
  retsess	integer;
  ctr		integer;
  sessid	integer;
  sts		varchar2(200);
  fl 		UTL_FILE.FILE_TYPE;
  bfr		varchar2( 32767 );
  res		boolean;

begin
 glbx.adm_cookie_id( surl,sessid,sts,'XML.ACCEPT_RUN_UPLOAD');
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 if p1 = 'B'
  then
   fname := glbx.extract_fname(file,'FILENAME');
   dump_dir := glbx.extract_master_parameter( 'WORK_DIRECTORY' );
   glbx.external_file_load( surl, file, dump_dir, fname );

 elsif p1 = 'F'
  then
   dump_dir := p2;
   fname := p3;
 end if;

 -- Unzip the file if the extension is zip
 if upper(glbx.extract_fname( fname, 'SUFFIX' )) in ('ZIP')
  then
   res := ump.unzip( store_path_name=>FALSE, unzip_filename=>dump_dir || DECS.UNIX_OR_NT || fname, unzip_directory=>dump_dir );
   fname := glbx.extract_fname(fname,'NO_EXTENSION') || '.txt';
 end if;

 -- Check file and see if it is the old style.
 begin
 fl := utl_file.fopen( dump_dir, fname, 'r', 32767);
 utl_file.get_line( fl, bfr );
 bfr := trim(bfr);
 if substr(upper(bfr),1,7) = '<TABLE>'
  then
   utl_file.fclose(fl);
   adm.accept_upload_defn(surl,fname,'F','F',dump_dir);
   return;
 end if;
 utl_file.fclose(fl);
 exception
  when others
   then htp.htmlopen;
         htp.bold( 'Error accessing file: ' || sqlerrm );
        htp.htmlclose;
    begin utl_file.fclose(fl); exception when others then null;
    end;
    return;
 end;

 adm.main_title( surl, sessid, 'Results from XML Upload', helpid=>'A92');
 htp.nl;

 ctr := 0;
 if p5 is not null
  then
   ctr := ctr + 1;
   ncols(ctr) := 'PID';
   nvals(ctr) := p5;
 end if;
 if p6 is not null
  then
   ctr := ctr + 1;
   ncols(ctr) := 'MANUFACTURER_ID';
   nvals(ctr) := p6;
 end if;
 if p7 is not null
  then
   if ncols.count > 0
    then
     if ncols(1) = 'PID'
      then
       nvals(1) := substr(p7,2,instr(p7,']')-2);
      else
       ctr := ctr + 1;
       ncols(ctr) := 'PID';
       nvals(ctr) := substr(p7,2,instr(p7,']')-2);
     end if;
    else
       ctr := ctr + 1;
       ncols(ctr) := 'PID';
       nvals(ctr) := substr(p7,2,instr(p7,']')-2);
   end if;
   ctr := ctr + 1;
   ncols(ctr) := 'AID';
   nvals(ctr) := substr(p7,instr(p7,']')+1);
 end if;
main( 'LOAD', p1, dump_dir, fname, p4, ncols, nvals );

htp.bold( 'Uploaded Finished' );
htp.nl;
htp.htmlclose;
exception when others then htp.p( sqlerrm );
end accept_run_upload;

function loadimg(surl in varchar2, cusrec in customer_account%ROWTYPE, temp_dir in varchar2, new_img in varchar2, full_path in varchar2, subj in varchar2, negno in integer, origfname in varchar2, v_umo out integer)
 return varchar2
as

 cursor c1( utype varchar2, uscid in integer, acid in integer, fpath varchar2 ) is
  select 'x' exst
  from umo um
  where aid = acid and
        umo_scene_id = uscid and
        (
         (utype = 'PHOTO' and photo_original_loc = fpath) or
         (utype = 'DOCUMENT' and document_original_loc = fpath) or
         (utype = 'VIDEO' and video_original_loc = fpath) or
         (utype = 'AUDIO' and audio_original_loc = fpath) or
         (utype = 'BLUEPRINT' and um.blueprint_obj.blueprint_original_loc = fpath)
        );

 c1rec		c1%ROWTYPE;
 founderr	boolean;
 parm1 		ump.parameters;
 parm2 		ump.parameters;
 newid_arr	ump.myarray_int;
 display_output GLBX.MYARRAY;
 retval		varchar2(1000);

begin
  -- Safeguard to ensure the same image does not get accidently reloaded.
  --glbx.dbg('A:' || nvl(glbx.auto_file_type(origfname),'PHOTO'));
  --glbx.dbg('B:' || cusrec.receive_image_umo_scene);
  --glbx.dbg('C:' || cusrec.aid);
  --glbx.dbg('D:' || full_path || '-' || origfname);
  open c1(nvl(glbx.auto_file_type(origfname),'PHOTO'), cusrec.receive_image_umo_scene, cusrec.aid, full_path || '-' || origfname );
  fetch c1 into c1rec;
  close c1;
  if c1rec.exst = 'x' then return( 'Exists' ); end if;
  --glbx.dbg('E:' || full_path || '-' || origfname);

  parm1(1)  := 'AID';
  parm2(1)  := cusrec.aid;
  parm1(2)  := 'OBJECT_TYPE';
  parm2(2)  := nvl(glbx.auto_file_type(origfname),'PHOTO');
  parm1(3)  := 'LOAD_FROM_FILE_OR_UPLOAD';
  parm2(3)  := 'FILE';
  parm1(4)  := 'CONVERT_TO';
  parm2(4)  := 'JPEG';
  parm1(5)  := 'COMPRESSION';
  parm2(5)  := LNG.PHG_ALT_427;
  parm1(6)  := 'LOAD_DIRECTORY';
  parm2(6)  := temp_dir;
  parm1(7)  := 'FILE_NAME';
  parm2(7)  := new_img;
  parm1(8)  := 'STORE_ORIGINAL';
  parm2(8)  := 'FALSE';
  parm1(9)  := 'CREATE_THUMBNAIL';
  parm2(9)  := 'TRUE';
  parm1(10) := 'THUMBNAIL_WIDTH';
  parm2(10) := nvl( glbx.userpref( cusrec.pid, cusrec.aid, 'THUMBNAIL_WIDTH' ),'140');
  parm1(11) := 'THUMBNAIL_QUALITY';
  parm2(11) := nvl(glbx.userpref( cusrec.pid, cusrec.aid, 'SUPER_THB' ),'1');
  parm1(12) := 'KEEP_STATUS';
  parm2(12) := 'K';
  parm1(13) := 'ORIGINAL_LOCATION';
  parm2(13) := temp_dir || DECS.UNIX_OR_NT || new_img;
  parm1(14) := 'PARENT_UMO_ID';
  parm2(14) := NULL;
  parm1(15) := 'SCENE_ID';
  parm2(15) := cusrec.receive_image_umo_scene;
  parm1(16) := 'UMO_OWNER';
  parm2(16) := 'PHOTOGRAPHER';
  parm1(17) := 'BYPASS_QUOTA_CHECK';
  parm2(17) := 'TRUE';
  parm1(18) := 'ROLL_ID';
  parm2(18) := '1';
  parm1(19) := 'FILM_TYPE';
  parm2(19) := 'ALL';
  parm1(20) := 'FILM_NAME';
  if nvl(substr(cusrec.receive_image_options,1,1),'F') = 'F'
   then
    parm2(20) := subj;
   else
    parm2(20) := origfname;
  end if;
  parm1(21) := 'NEG_NO';
  parm2(21) := negno;
  parm1(22) := 'PHGR_ID';
  parm2(22) := to_char(cusrec.pid);
  parm1(23) := 'NAME';
  parm2(23) := subj;
  parm1(24) := 'PHOTO ALBUM';
  parm2(24) := 'FALSE';
  parm1(25) := 'BRIDAL';
  parm2(25) := 'TRUE';
  parm1(26) := 'PHOTOGRAPHER';
  parm2(26) := 'TRUE';
  parm1(27) := 'QUALITY';
  parm2(27) := 'STANDARD';
  parm1(28) := 'NOCOMPRESSIF';
  parm2(28) := NULL;
  parm1(29) := 'SCALE_TO_SIZE';
  parm2(29) := NULL;
  parm1(30) := 'SCALE_THRESHOLD';
  parm2(30) := NULL;
  parm1(31) := 'FTPLOC';
  parm2(31) := null;
  parm1(32) := 'PHOTOGRAPHER';
  parm2(32) := 'TRUE';
  ump.load_uma( surl, parm1, parm2, retval, newid_arr );
  founderr := os_command.delete_file( temp_dir || DECS.UNIX_OR_NT || new_img, display_output, TRUE );
  if newid_arr.count > 0
   then
    v_umo := newid_arr(1);
    update umo um set photo_original_loc = full_path || '-' || origfname where umo_id = v_umo and umo_type = 'PHOTO';
    update umo um set audio_original_loc = full_path || '-' || origfname where umo_id = v_umo and umo_type = 'AUDIO';
    update umo um set document_original_loc = full_path || '-' || origfname where umo_id = v_umo and umo_type = 'DOCUMENT';
    update umo um set video_original_loc = full_path || '-' || origfname where umo_id = v_umo and umo_type = 'VIDEO';
    update umo um set um.blueprint_obj.blueprint_original_loc = full_path || '-' || origfname where umo_id = v_umo and umo_type = 'BLUEPRINT';
    commit;
  end if;
  return( retval );
end loadimg;

-- procedure to read in directory and look for new emails (keep last one)
function findscene( cusrec in customer_account%ROWTYPE, subj in varchar2 )
 return integer
as

 cursor c1( ctg varchar2, ttl varchar2 ) is
  select umo_scene_id
  from umo_scene
  where category = ctg and
        upper(title) = ttl;

 c1rec c1%ROWTYPE;

begin
 if nvl(substr(cusrec.receive_image_options,1,1),'F') = 'F' then return( cusrec.receive_image_umo_scene ); end if;
 if subj is null then return( cusrec.receive_image_umo_scene ); end if;
 open c1(cusrec.scene_name , upper(subj) );
 fetch c1 into c1rec;
 close c1;
 if c1rec.umo_scene_id is null  then return( cusrec.receive_image_umo_scene ); end if;
 return( c1rec.umo_scene_id );
end findscene;

function email_receive_load( surl in varchar2, cusrec in customer_account%ROWTYPE, email_dir in varchar2, email_name in varchar2, temp_dir in varchar2, temp_name in varchar2, new_image_name in varchar2, negno in integer, full_path in varchar2 )
 return varchar2
as

  vcusrec	 customer_account%ROWTYPE;
  fl 		 UTL_FILE.FILE_TYPE;
  fl2 		 UTL_FILE.FILE_TYPE;
  bl		 boolean;
  bfr		 varchar2(32767);
  txt		 varchar2(32767);
  mime_bdry	 varchar2(1000);
  filename	 varchar2(1000);
  fname	 	 varchar2(1000);
  subj	 	 varchar2(1000);
  retval 	 varchar2(1000);
  cte		 varchar2(1000);
  v_umo		 integer;
  x		 integer;
  y		 integer;
  z		 integer;
  attachctr	 integer;
  frow		 boolean;
  founderr	 boolean;
  display_output GLBX.MYARRAY;
  doc		 sys.xmldom.DOMDocument;

begin
 -- note: Only handles one attachment and assume it is JPG
  vcusrec := cusrec;
  fl := utl_file.fopen( substr(email_dir,1,length(email_dir)-1), email_name, 'r', 32767);

  -- Find Subject
  loop
   begin
    utl_file.get_line( fl, bfr );
    if instr(upper(bfr),'SUBJECT:') > 0 then exit; end if;
   exception
    when others then exit;
   end;
  end loop;
  if instr(upper(bfr),'SUBJECT:') > 0
   then
    subj := trim(substr(bfr,instr(upper(bfr),'SUBJECT:') + length('Subject:') + 1));
  end if;

  -- Find boundary="
  loop
   begin
    utl_file.get_line( fl, bfr );
    if instr(replace(upper(bfr),' ',''),'BOUNDARY="') > 0 then exit; end if;
   exception
    when others then exit;
   end;
  end loop;
  if instr(replace(upper(bfr),' ',''),'BOUNDARY="')  > 0
   then
    x := instr(replace(upper(bfr),' ',''),'BOUNDARY="');
    y := instr(bfr,'"',x,1);
    z := instr(bfr,'"',x,2);
    mime_bdry := '--' || substr(bfr,y+1,(z-y)-1);
  end if;
  if mime_bdry is null then return ('Unable to find Boundary Clause' ); end if;
  -- Find first boundry
  loop
   begin
    utl_file.get_line( fl, bfr );
    if instr(bfr,mime_bdry) > 0 then exit; end if;
   exception
    when others then return('Unable to find Starting Boundary' );
   end;
  end loop;

  -- Find Second boundry
  txt := null;
  loop
   begin
    utl_file.get_line( fl, bfr );
    if instr(bfr,mime_bdry) > 0 then exit; end if;
    if substr(upper(bfr),1,8) = 'CONTENT-'
     then
      null;
    else
     begin
      txt := txt || chr(13) || bfr;
     exception when others then null;
     end;
    end if;
   exception
    when others then return('Unable to find Secondary Boundary' );
   end;
  end loop;

  attachctr := 0;
  loop
   attachctr := attachctr + 1;
   if attachctr > 100 then exit; end if; -- Maximum of 100 attachments per file
   fl2 := utl_file.fopen( temp_dir, temp_name, 'w', 32767);
   -- Copy to end of file
   frow := FALSE;
   fname := null;
   filename := null;

   -- Loop through receiving multiple attachments
   loop
    begin
     utl_file.get_line( fl, bfr );
     utl_file.put_line( fl2, bfr );
     if instr(bfr,mime_bdry) > 0 then exit; end if;
     x := instr(upper(replace(bfr,' ','')),'FILENAME="');
     if x > 0
      then
        y := instr(bfr,'"',x,1);
        z := instr(bfr,'"',x,2);
        filename := substr(bfr,y+1,(z-y)-1);
     end if;
     x := instr(upper(bfr),' NAME="');
     if x > 0
      then
        y := instr(bfr,'"',x,1);
        z := instr(bfr,'"',x,2);
        fname := substr(bfr,y+1,(z-y)-1);
     end if;
     x := instr(upper(bfr),'CONTENT-TRANSFER-ENCODING:');
     if x > 0
      then
        cte := upper(trim(substr(bfr,x+length('Content-transfer-encoding:')+1)));
     end if;
     frow := TRUE;
    exception
     when others then return('Unable to find Closing Boundary' );
    end;
   end loop;
   utl_file.fclose( fl2 );
   fname := nvl(nvl(fname,filename),'myfile.jpg');
   retval := null;

   -- Convert Mime File
   if frow and nvl(cte,'BASE64') = 'BASE64'
    then
     bl := os_command.mime64_decode( temp_dir || DECS.UNIX_OR_NT || temp_name,  temp_dir || DECS.UNIX_OR_NT || new_image_name, display_output );
     founderr := os_command.delete_file( temp_dir || DECS.UNIX_OR_NT || temp_name, display_output, TRUE );
    else
     founderr := os_command.delete_file( temp_dir || DECS.UNIX_OR_NT || temp_name, display_output, TRUE );
     -- return('Unable to Extract Mime Image' );
     -- Ignore any none base64 structures.
    end if;

    vcusrec.receive_image_umo_scene := findscene( vcusrec, subj );
    retval := loadimg(surl, vcusrec, temp_dir, new_image_name, full_path, subj, negno, fname, v_umo );
    if retval is null
     then
      -- Attach TXT to the image. It is XML.
      if is_metadata_xml( txt ) -- Update txt and strip out the core tags, then add XML header.
       then
        -- process xml
        if open_xml( txt, doc )
         then
          if ump.attach_metadata( surl, doc, v_umo )
           then
            null; -- if it works or fails, so be it
          end if;
        end if;
      end if;
    end if;

    if instr(bfr,mime_bdry || '--') > 0 then exit; end if;
   end loop;

   utl_file.fclose( fl );
   return( retval );

exception
 when others then return( sqlerrm );
end email_receive_load;

procedure dir_email_receive( surl in varchar2, cusrec in customer_account%ROWTYPE )
as

 cursor c1( acid integer, retsess varchar2 ) is
  select uniqueid,id,fname,fsize,file_type,directory_name,full_path
  from dir_results
  where id = retsess and
        file_type = 'F' and
        fsize > 0 and
        fname not in (select fname from dir_results_email where aid = acid)
  order by fname;

 email_dir	varchar2(1000);
 temp_dir	varchar2(1000);
 temp_name	varchar2(1000);
 new_img	varchar2(1000);
 retval		varchar2(4000);
 retsess	varchar2(100);
 bsts		boolean;

begin
 email_dir := glbx.extract_master_parameter( 'EMAIL_DIECTORY' );
 if email_dir is null then return; end if;
 if substr(email_dir,length(email_dir),1) in ('/','\')
  then
   null;
  else
   email_dir := email_dir || DECS.UNIX_OR_NT;
 end if;
 select s_umo_sess.nextval into retsess from dual;
 bsts := ump.directory_listing(email_dir || cusrec.receive_image_account || '*.*', retsess );
 select 't_' || trim(to_char(s_filename.nextval)) || '.' || 'mme' into temp_name from dual;
 select 't_' || trim(to_char(s_filename.nextval)) || '.' || 'jpg' into new_img from dual;
 temp_dir := glbx.extract_master_parameter( 'WORK_DIRECTORY' );

 for c1rec in c1(cusrec.aid,retsess) loop
  retval := null;
  retval := email_receive_load( surl=>surl, cusrec=>cusrec, email_dir=>email_dir, email_name=>c1rec.fname, temp_dir=>temp_dir, temp_name=>temp_name, new_image_name=>new_img, negno=>c1%ROWCOUNT, full_path=>email_dir || c1rec.fname );
 end loop;

 delete from dir_results_email where aid = cusrec.aid;
 insert into dir_results_email(aid,uniqueid,id,fname,fsize,file_type,directory_name,full_path)
 select cusrec.aid,uniqueid,id,fname,fsize,file_type,directory_name,full_path
 from dir_results
 where id = retsess and
        file_type = 'F' and
        fsize > 0;
 delete from dir_results where id = retsess;
 commit;
end dir_email_receive;

function is_metadata_xml( txt in out varchar2 )
 return boolean
as
 x	integer;
 y	integer;
begin


 x := instr(txt,'<METADATA>' );
 if x = 0 then return( FALSE ); end if;
 y := instr(txt,'</METADATA>' );
 if x = 0 then return( FALSE ); end if;

 txt := substr(txt,1,y+length('</METADATA>'));
 txt := '<?xml version = "1.0"?>' || substr(txt,x);
 return( TRUE );
exception
 when others then return( FALSE );
end is_metadata_xml;

function open_xml( txt in varchar2, doc in out sys.xmldom.DOMDocument )
 return boolean
as

 p 		sys.xmlparser.parser;

begin
p := sys.xmlparser.newParser;
sys.xmlparser.setValidationMode(p, FALSE);
sys.xmlparser.parsebuffer(p, txt );
doc := sys.xmlparser.getDocument(p);
return( TRUE );
exception
 when others then return( FALSE );
end open_xml;

end xml;

/
