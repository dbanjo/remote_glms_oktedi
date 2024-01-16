CREATE OR REPLACE package body WEBSYS.os_command
as

TEMPORARY_FILE	varchar2(1000);

procedure tempfile( ext in varchar2 default 'txt', short_name in boolean default false );
procedure deltmpfile;
function convbool( val in varchar2 ) return boolean;
function tempfile_contents return GLBX.MYARRAY;
function strip_nt_dir( dirloc in varchar2, bfr in varchar2 ) return ump.directory_list;
function source_directory( with_shell in boolean default FALSE ) return varchar2;
function source_call return varchar2;

function source_directory( with_shell in boolean default FALSE )
 return varchar2
as
begin
 if DECS.UNIX_OR_NT = '\'
  then
   if with_shell
    then
     return( glbx.extract_master_parameter( 'BIN_DIR' ) || DECS.UNIX_OR_NT || 'dos_shell' || DECS.UNIX_OR_NT );
    else
     return( glbx.extract_master_parameter( 'BIN_DIR' ) || DECS.UNIX_OR_NT );
   end if;
  else
   return( glbx.extract_master_parameter( 'BIN_DIR' ) || DECS.UNIX_OR_NT || 'unix_shell' || DECS.UNIX_OR_NT );
 end if;
end source_directory;

function source_call
 return varchar2
as
begin
 if DECS.UNIX_OR_NT = '\'
  then
   return( glbx.extract_master_parameter( 'WINDOWS_SHELL' ) || ' ' );
  else
   return( glbx.extract_master_parameter( 'UNIX_SHELL' ) || ' ' );
 end if;
end source_call;

procedure tempfile( ext in varchar2 default 'txt', short_name in boolean default false )
as
 retvar varchar2(1000);
begin
 if short_name
  then
   select 't_' || trim(to_char(s_filename.nextval)) || '.' || ext into retvar from dual;
  else
   select 'tempfile_' || trim(to_char(s_filename.nextval)) || '.' || ext into retvar from dual;
 end if;
 TEMPORARY_FILE := glbx.extract_master_parameter( 'WORK_DIRECTORY' ) || DECS.UNIX_OR_NT || retvar;
end tempfile;

procedure deltmpfile
as
 x integer;
begin
 if DECS.UNIX_OR_NT = '\'
  then
   -- x := OSCommand_NoWait_Run(source_call || 'del ' || TEMPORARY_FILE );
   utl_os.OSCmdDirectWait(source_call || 'del ' || TEMPORARY_FILE );
  else
   x := OSCommand_NoWait_Run(source_call || source_directory || 'rm2.sh ' || TEMPORARY_FILE );
 end if;
exception
 when others then null;
end deltmpfile;

function openwait( dr in varchar2, fn in varchar2, ty in varchar2, len integer, maxwaits integer default 20 )
 return utl_file.file_type
as
 fl	utl_file.file_type;
begin
 dbms_lock.sleep(.1);
 for j in 1..maxwaits loop
  begin
   fl := utl_file.fopen( dr, fn, ty, len );
   exit;
  exception
   when others then
    dbms_lock.sleep(round(j/10,1));
  end;
 end loop;

 return( fl );
end openwait;

function openwait2( dr in varchar2, fn in varchar2, ty in varchar2, len integer, maxwaits integer default 20, otherext in varchar2, lfile in out varchar2 )
 return utl_file.file_type
as
 fl	utl_file.file_type;
 xt	boolean;
begin
 -- This routine tries two different file types to see which one exists and return that one
 dbms_lock.sleep(.1);
 for j in 1..maxwaits loop
  begin
   begin
    xt := FALSE;
    fl := utl_file.fopen( dr, fn, ty, len );
    exit;
    exception when others then null;
   end;
   xt := TRUE;
   fl := utl_file.fopen( dr, fn || otherext, ty, len );
   exit;
  exception
   when others then
    dbms_lock.sleep(round(j/10,1));
  end;
 end loop;
 if xt
  then
   lfile := dr || DECS.UNIX_OR_NT || fn || otherext;
  else
   lfile := dr || DECS.UNIX_OR_NT || fn;
 end if;
 return( fl );

end openwait2;

function convbool( val in varchar2 )
 return boolean
as
 vl integer;
begin
 begin vl := to_number(val); exception when others then return( FALSE ); end;
 if vl = 1 then return( FALSE ); else return( TRUE ); end if;

exception
 when others then
  deltmpfile;
  return( FALSE );
end convbool;

function tempfile_contents
 return GLBX.MYARRAY
as
 fl	UTL_FILE.FILE_TYPE;
 retarr GLBX.MYARRAY;
 bfr    varchar2(4000);
begin
 fl := openwait( substr(glbx.extract_fname( TEMPORARY_FILE, 'PWD'),1,length(glbx.extract_fname( TEMPORARY_FILE, 'PWD'))-1), glbx.extract_fname( TEMPORARY_FILE, 'FILE'), 'r',4000);
 loop
  begin
   utl_file.get_line( fl, bfr );
   retarr(retarr.count+1) := bfr;
  exception when others then exit;
  end;
 end loop;
 utl_file.fclose( fl );
 return( retarr );
exception
 when others then
  retarr(retarr.count+1) := sqlerrm;
  return( retarr );
end tempfile_contents;

function copy( source in varchar2, destination in varchar2, display_output out GLBX.MYARRAY )
 return boolean
as
 x	varchar2(1000);

begin

 if DECS.UNIX_OR_NT = '\'
  then
   x := oscommand_run(source_call || 'copy ' || source || ' ' || destination );
  else
   x := oscommand_run(source_call || source_directory || 'cp.sh ' || source || ' ' || destination );
 end if;
 return( convbool( x ) );

exception
 when others then
  return( FALSE );
end copy;

function move( source in varchar2, destination in varchar2, display_output out GLBX.MYARRAY )
 return boolean
as
 x	varchar2(1000);

begin

 if DECS.UNIX_OR_NT = '\'
  then
   x := oscommand_run(source_call || 'move ' || source || ' ' || destination  );
  else
   x := oscommand_run(source_call || source_directory || 'mv.sh ' || source || ' ' || destination );
 end if;
 return( convbool( x ) );

exception
 when others then
  return( FALSE );
end move;

function rename_file( source in varchar2, destination in varchar2, display_output out GLBX.MYARRAY )
 return boolean
as
 x	varchar2(1000);

begin

 if DECS.UNIX_OR_NT = '\'
  then
   x := oscommand_run(source_call || 'ren "' || source || '" "' || destination || '"' );
  else
   x := oscommand_run(source_call || source_directory || 'mv.sh ' || source || ' ' || destination );
 end if;
 return( convbool( x ) );

exception
 when others then
  deltmpfile;
  return( FALSE );
end rename_file;

function delete_file( source in varchar2, display_output out GLBX.MYARRAY, just_do_it in boolean default FALSE )
 return boolean
as
 x	varchar2(1000);

begin

 if just_do_it
  then
   if DECS.UNIX_OR_NT = '\'
    then
     x := OSCommand_NoWait_Run(source_call || 'del ' || source );
    else
     x := OSCommand_NoWait_Run(source_call || source_directory || 'rm.sh' || source );
   end if;
   return( convbool( x ) );
  else
   if DECS.UNIX_OR_NT = '\'
    then
     x := oscommand_run(source_call || 'del ' || source );
    else
     x := oscommand_run(source_call || source_directory || 'rm.sh' || source );
   end if;
   return( convbool( x ) );
 end if;

exception
 when others then
  return( FALSE );
end delete_file;

function make_directory( source in varchar2, directory_name in varchar2, display_output out GLBX.MYARRAY )
 return boolean
as
 x	varchar2(1000);

begin
 return( make_directory( source || DECS.UNIX_OR_NT || directory_name, display_output ) );
exception
 when others then
  deltmpfile;
  return( FALSE );
end make_directory;

function make_directory( source in varchar2, display_output out GLBX.MYARRAY )
 return boolean
as
 x	varchar2(1000);

begin

 tempfile;
 if DECS.UNIX_OR_NT = '\'
  then
   x := oscommand_run(source_call || 'mkdir ' || source || ' >' || TEMPORARY_FILE );
  else
   x := oscommand_run(source_call || source_directory || 'mkdir.sh ' || source || ' ' || TEMPORARY_FILE );
 end if;
 display_output := tempfile_contents;
 deltmpfile;
 return( convbool( x ) );

exception
 when others then
  deltmpfile;
  return( FALSE );
end make_directory;

function remove_directory( source in varchar2, directory_name in varchar2, display_output out GLBX.MYARRAY, remove_all in boolean default false )
 return boolean
as
 x	varchar2(1000);

begin
 return( remove_directory( source || DECS.UNIX_OR_NT || directory_name, display_output, remove_all ) );
exception
 when others then
  deltmpfile;
  return( FALSE );
end remove_directory;

function remove_directory( source in varchar2, display_output out GLBX.MYARRAY, remove_all in boolean default false )
 return boolean
as
 x	varchar2(1000);

begin

 if DECS.UNIX_OR_NT = '\'
  then
   if remove_all
    then
     x := oscommand_run(source_call || 'rmdir /S /Q ' || source );
    else
     x := oscommand_run(source_call || 'rmdir ' || source );
   end if;
  else
   x := oscommand_run(source_call || source_directory || 'rmdir.sh ' || source );
 end if;
 return( convbool( x ) );

exception
 when others then
  return( FALSE );
end remove_directory;

function strip_nt_dir( dirloc in varchar2, bfr in varchar2 )
 return ump.directory_list
as

 vl	ump.directory_list;
 tmp1	varchar2(100);
 tmp2	varchar2(100);
 tmp3	varchar2(100);
 x	integer;
 comma_delim	GLBX.MYARRAY;
 vbfr		varchar2(4000);
 fnm		varchar2(1000);

 function find_name( k in integer, nme in varchar2 )
  return varchar2
 as
  vfnm 	varchar2(1000);
  x	integer;
 begin
  vfnm := null;
  x := instr( bfr, nme );
  return( trim(substr(bfr,x)) );

  --for m in k..comma_delim.last loop
  -- vfnm := vfnm || ' ' || comma_delim(m);
  --end loop;
  --return( substr( vfnm, 2) );
 end find_name;

begin
 vbfr := bfr;
  for j in 1..5 loop
   vbfr := replace(vbfr,'  ',' ');
  end loop;
  glbx.comma_delimited(bfr=>vbfr, comma_delim=>comma_delim, delimchar=>' ');
  if comma_delim.count = 0 then return( vl ); end if;

  if upper(substr(comma_delim(2),length(comma_delim(2)),1)) in ('A','P') or
    (upper(comma_delim(3)) not in ('AM','PM'))
   then
    -- Win 2000
    begin vl.datetime := to_date( comma_delim(1) || ' ' || replace(replace(comma_delim(2),'a',' am'),'p', ' pm'), 'DD/MM/YYYY HH:MI:SS am' ); exception when others then null; end;
    if comma_delim(3) = '<DIR>'
     then
      vl.filetype := 'DIRECTORY';
      vl.filesize := 0;
      vl.security := null;
      vl.directory := dirloc;
      fnm := find_name(4,comma_delim(4));
      vl.filename := fnm;
      vl.fullpath := dirloc || DECS.UNIX_OR_NT || fnm;
     else
      vl.filetype := 'FILE';
      vl.filesize := glbx.guess_number(comma_delim(3));
      vl.security := null;
      vl.directory := dirloc;
      fnm := find_name(4,comma_delim(4));
      vl.filename := fnm;
      vl.fullpath := dirloc || DECS.UNIX_OR_NT || fnm;
    end if;
    return( vl );
   else
    -- Win XP
    begin vl.datetime := to_date( comma_delim(1) || ' ' || comma_delim(2) || ' ' || comma_delim(3), 'DD/MM/YYYY HH:MI:SS am' ); exception when others then null; end;
    if comma_delim(4) = '<DIR>'
     then
      vl.filetype := 'DIRECTORY';
      vl.filesize := 0;
      vl.security := null;
      vl.directory := dirloc;
      fnm := find_name(5,comma_delim(5));
      vl.filename := fnm;
      vl.fullpath := dirloc || DECS.UNIX_OR_NT || fnm;
     else
      vl.filetype := 'FILE';
      vl.filesize := glbx.guess_number(comma_delim(4));
      vl.security := null;
      vl.directory := dirloc;
      fnm := find_name(5,comma_delim(5));
      vl.filename := fnm;
      vl.fullpath := dirloc || DECS.UNIX_OR_NT || fnm;
    end if;
    return( vl );
  end if;

end strip_nt_dir;

function strip_unix_dir( dirloc in varchar2, bfr in varchar2 )
 return ump.directory_list
as

 vl	ump.directory_list;
 tmp1	varchar2(4000);
 tmp2	varchar2(4000);
 tmp3	varchar2(4000);
 x	integer;

begin
  if upper(substr(bfr,1,1)) = 'D'
   then
    vl.filetype := 'DIRECTORY';
   else
    vl.filetype := 'FILE';
  end if;

  x := instr(bfr,' ' );
  tmp1 := trim(substr(bfr,1,x));
  tmp3 := trim(substr(bfr,x+1));
  vl.security := tmp1;

  -- Ignore the second value
  x := instr(tmp3,' ' );
  tmp1 := trim(substr(tmp3,1,x));
  tmp3 := trim(substr(tmp3,x+1));

  x := instr(tmp3,' ' );
  tmp1 := trim(substr(tmp3,1,x));
  tmp3 := trim(substr(tmp3,x+1));
  vl.security := vl.security || ' ' || tmp1;

  x := instr(tmp3,' ' );
  tmp1 := trim(substr(tmp3,1,x));
  tmp3 := trim(substr(tmp3,x+1));
  vl.security := vl.security || ' ' || tmp1;
  x := instr(tmp3,' ' );
  tmp1 := trim(substr(tmp3,1,x));
  tmp3 := trim(substr(tmp3,x+1));
  begin vl.filesize := tmp1; exception when others then vl.filesize := null; end;

  x := instr(tmp3,' ' );
  tmp1 := trim(substr(tmp3,1,x));
  tmp3 := trim(substr(tmp3,x+1));
  x := instr(tmp3,' ' );
  tmp1 := tmp1 || ' ' || trim(substr(tmp3,1,x));
  tmp3 := trim(substr(tmp3,x+1));
  x := instr(tmp3,' ' );
  tmp2 := trim(substr(tmp3,1,x));
  tmp3 := trim(substr(tmp3,x+1));

  begin
   vl.datetime := to_date( tmp1 || ' ' || tmp2, 'Mon DD HH24:MI' );
  exception
   when others then
    begin
      vl.datetime := to_date( tmp1 || ' ' || tmp2, 'Mon DD YYYY' );
    exception
     when others then null;
    end;
  end;

  x := instr(bfr,'/' );
  if x = 0
   then
    x := instr(tmp3,' ' );
    tmp3 := trim(substr(tmp3,x+1));
    vl.fullpath := tmp3;
    vl.directory := dirloc;
    vl.filename := glbx.extract_fname( tmp3, 'FILE');
   else
    tmp3 := trim(substr(bfr,x));
    vl.fullpath := tmp3;
    vl.directory := glbx.extract_fname( tmp3, 'PWD');
    vl.filename := glbx.extract_fname( tmp3, 'FILE');
  end if;

  if vl.filetype = 'DIRECTORY' then vl.filesize := 0; end if; -- Needed so that trigger of directory in load works
  return( vl );
exception
 when others then dbms_output.put_line(sqlerrm);
end strip_unix_dir;


function directory_listing( source in varchar2, arrlist in out NOCOPY ump.directory_list_arr )
 return boolean
as

 x	varchar2(1000);

 fl	UTL_FILE.FILE_TYPE;
 bfr    varchar2(4000);
 vl	ump.directory_list;
 tmp	varchar2(1000);

begin
 tempfile;
 if DECS.UNIX_OR_NT = '\'
  then
   --glbx.dbg( source_call || 'dir /n "' || source || '" >' || TEMPORARY_FILE );
   x := oscommand_run(source_call || 'dir /n "' || source || '" >' || TEMPORARY_FILE );
   -- x := oscommand_run(source_call || 'dir /n /q "' || source || '" >' || TEMPORARY_FILE ); -- when running with W2K /q is not supported
  else
   x := oscommand_run(source_call || source_directory || 'ls.sh ' || source || ' ' || TEMPORARY_FILE );
 end if;

 fl := openwait( substr(glbx.extract_fname( TEMPORARY_FILE, 'PWD'),1,length(glbx.extract_fname( TEMPORARY_FILE, 'PWD'))-1), glbx.extract_fname( TEMPORARY_FILE, 'FILE'), 'r', 4000, maxwaits=>6 );
 loop
  begin
   utl_file.get_line( fl, bfr );
   if DECS.UNIX_OR_NT = '\'
    then
     if substr(bfr,1,1) = ' '
      then
       if instr(bfr,'Directory of') > 0 then tmp := trim(substr(bfr,instr(bfr,'Directory of')+1+length('Directory of'))); end if;
      else
       vl := strip_nt_dir( tmp, bfr );
       if vl.filename in ('.','..')
        then
         null;
        else
         if vl.filename is not null
          then
            arrlist(arrlist.count+1) := vl;
         end if;
       end if;
     end if;

    else
     tmp := substr(glbx.extract_fname( source, 'PWD'),1,length(glbx.extract_fname( source, 'PWD'))-1);
     if upper(substr( trim(bfr), 1, 5 )) = 'TOTAL'
      then
       null;
      else
       vl := strip_unix_dir( tmp, bfr );
       if vl.filename in ('.','..')
        then
         null;
        else
         arrlist(arrlist.count+1) := vl;
       end if;
     end if;
   end if;

  exception when others then exit;
  end;
 end loop;
 utl_file.fclose( fl );
 deltmpfile;
 return( TRUE );

exception
 when others then
  deltmpfile;
  return( FALSE );
end directory_listing;

function stop_oracle_process( pid in varchar2, display_output out GLBX.MYARRAY )
 return boolean
as
 cursor c1 is select instance_name from v$instance;
 c1rec  c1%ROWTYPE;
 x	varchar2(1000);

begin

 open c1;
 fetch c1 into c1rec;
 close c1;
 tempfile;
 if DECS.UNIX_OR_NT = '\'
  then
   x := OSCommand_NoWait_Run('orakill ' || c1rec.instance_name || ' ' || pid || ' >' || TEMPORARY_FILE );
  else
   x := OSCommand_NoWait_Run(source_call || source_directory || 'kill.sh ' || pid || ' >' || TEMPORARY_FILE );
 end if;
 display_output := tempfile_contents;
 deltmpfile;
 return( convbool( x ) );

exception
 when others then
  deltmpfile;
  return( FALSE );
end stop_oracle_process;

function dosprint( cmd in varchar2, display_output out GLBX.MYARRAY )
 return boolean
as
 x	varchar2(1000);

begin

 -- xxxx
 tempfile;
 if DECS.UNIX_OR_NT = '\'
  then
   x := OSCommand_NoWait_Run(source_call || 'print ' || ' >' || TEMPORARY_FILE );
  else
   x := OSCommand_NoWait_Run('/bin/xx ' || ' >' || TEMPORARY_FILE );
 end if;
 display_output := tempfile_contents;
 deltmpfile;
 return( convbool( x ) );

exception
 when others then
  deltmpfile;
  return( FALSE );
end dosprint;

function wordprint( cmd in varchar2, display_output out GLBX.MYARRAY )
 return boolean
as
 x	varchar2(1000);

begin

 tempfile;
 if DECS.UNIX_OR_NT = '\'
  then
   x := oscommand_run(source_call || 'pstat ' || ' >' || TEMPORARY_FILE );
  else
   x := oscommand_run('/bin/? ' || ' >' || TEMPORARY_FILE );
 end if;
 display_output := tempfile_contents;
 deltmpfile;
 return( convbool( x ) );

exception
 when others then
  deltmpfile;
  return( FALSE );
end wordprint;

function ping( site in varchar2, times in integer default 10, display_output out GLBX.MYARRAY )
 return boolean
as
 x	varchar2(1000);

begin

 tempfile;
 if DECS.UNIX_OR_NT = '\'
  then
   x := oscommand_run(source_call || 'ping -r ' || times || ' ' || site || ' >' || TEMPORARY_FILE );
  else
   x := oscommand_run(source_call || source_directory || 'ping.sh ' || site || ' ' || TEMPORARY_FILE );
 end if;
 display_output := tempfile_contents;
 deltmpfile;
 return( convbool( x ) );

exception
 when others then
  deltmpfile;
  return( FALSE );
end ping;

function performance( time_period in integer default 10, display_output out GLBX.MYARRAY )
 return boolean
as
 x	varchar2(1000);

begin

 tempfile;
 if DECS.UNIX_OR_NT = '\'
  then
   --x := oscommand_run(source_call || '/ a ' || source_directory || ' system_tools\psinfo ' || ' > ' || TEMPORARY_FILE );
   x := oscommand_run(source_call || '/a pstat ' || ' > ' || TEMPORARY_FILE );
   dbms_lock.sleep(3);
  else
   --dbms_output.put_line( source_call || source_directory || 'vmstat.sh ' || time_period|| ' ' || TEMPORARY_FILE );
   x := oscommand_run(source_call || source_directory || 'vmstat.sh ' || time_period|| ' ' || TEMPORARY_FILE );
   dbms_lock.sleep( time_period );
 end if;
 display_output := tempfile_contents;
 deltmpfile;
 return( convbool( x ) );

exception
 when others then
  deltmpfile;
  return( FALSE );
end performance;

function zip( string in varchar2, recursive in boolean, include_dir in boolean, files_to_zip in varchar2, display_output out GLBX.MYARRAY, move_files in BOOLEAN default FALSE)
 return boolean
as
 x	varchar2(1000);

 y	integer;
 z	integer;
 fl	utl_file.file_type;
 prm	varchar2(100);
begin

 if include_dir then y := 0; else y := 1; end if;
 if recursive then z := 1; else z := 0; end if;
 --tempfile;
 if DECS.UNIX_OR_NT = '\'
  then
   -- Windows XP has built in ZIP capabilities. Use that as myzip2 now gives errors.
  -- if recursive then prm := ' -r '; end if;
   if not include_dir then prm := prm || ' -j '; end if;
   if move_files then prm := prm || ' -m '; end if;
   x := oscommand_run(source_call || 'zip ' || prm || string || ' ' || ' ' || files_to_zip );
  -- x := oscommand_run(source_call || 'myzip2 ' || string || ' ' || z || ' ' || y || ' ' || files_to_zip );
   --wait_not_used fl := openwait( substr(glbx.extract_fname( string, 'PWD'),1,length(glbx.extract_fname( string, 'PWD'))-1), glbx.extract_fname( string, 'FILE'), 'r',32767,20);
   --wait_not_used utl_file.fclose(fl);
  else
   x := oscommand_run(source_call || source_directory || 'zip.sh ' || string );
 end if;
 --display_output := tempfile_contents;
 --deltmpfile;
 return( convbool( x ) );

exception
 when others then
  --deltmpfile;
  return( FALSE );
end zip;

function unzip( unzip_file in varchar2, unzip_directory in varchar2, usepath in varchar2, display_output out GLBX.MYARRAY )
 return boolean
as
 x	varchar2(1000);

begin

 --tempfile;
 if DECS.UNIX_OR_NT = '\'
  then
   --glbx.dbg( source_call || 'myunzip ' || unzip_file || ' ' || unzip_directory || ' ' || usepath || ' >' || TEMPORARY_FILE  );
   -- myunzip v482source.zip p:\piction\source_demo 0
   x := oscommand_run(source_call || 'myunzip ' || unzip_file || ' ' || unzip_directory || ' ' || usepath );
  else
   if usepath = '0'
    then
     x := oscommand_run(source_call || source_directory || 'unzip1.sh ' || unzip_file || ' ' || unzip_directory );
    else
     x := oscommand_run(source_call || source_directory || 'unzip2.sh ' || unzip_file || ' ' || unzip_directory );
   end if;
 end if;
 --display_output := tempfile_contents;
 --deltmpfile;
 return( convbool( x ) );

exception
 when others then
  --deltmpfile;
  return( FALSE );
end unzip;

function mime64_encode( file_in in varchar2, file_out in varchar2, display_output out GLBX.MYARRAY )
 return boolean
as
 x	varchar2(1000);

begin

 if DECS.UNIX_OR_NT = '\'
  then
   x := oscommand_run(source_call || 'mime64 -e ' || file_in || ' ' ||  file_out );
  else
   x := oscommand_run(source_call || source_directory || 'mime64_encode.sh ' || file_in || ' ' ||  file_out || ' ' || TEMPORARY_FILE );
 end if;
 --display_output := tempfile_contents;
 return( convbool( x ) );

exception
 when others then
  deltmpfile;
  return( FALSE );
end mime64_encode;

function mime64_decode( file_in in varchar2, file_out in varchar2, display_output out GLBX.MYARRAY )
 return boolean
as
 x	varchar2(1000);

begin

-- tempfile;
 if DECS.UNIX_OR_NT = '\'
  then
   x := oscommand_run(source_call || ' ' || 'mime64 ' || file_in || ' ' ||  file_out );
  else
   x := oscommand_run(source_call || source_directory || 'mime64_decode.sh ' || file_in || ' ' ||  file_out || ' ' || TEMPORARY_FILE );
 end if;
 --display_output := tempfile_contents;
 return( convbool( x ) );

exception
 when others then
  deltmpfile;
  return( FALSE );
end mime64_decode;

function extract_mime64( blb in blob, fl in out utl_file.file_type )
 return boolean
as

 display_output 	GLBX.MYARRAY;
 tfile1			varchar2(1000);
 tfile2			varchar2(1000);
 status 		number;
 bl			boolean;
 fl2			utl_file.file_type;
 bfr			varchar2(4000);
 x			integer;

begin

 tempfile( short_name=>TRUE);
 tfile1 := TEMPORARY_FILE;
 tempfile( short_name=>TRUE);
 tfile2 := TEMPORARY_FILE;

 -- Unload Blob
 utl_lob.unloadtofile(blb, tfile1, status);

 -- Convert to Mime
 bl := mime64_encode( tfile1, tfile2, display_output );

 -- Loop until the file can be accessed
 fl2 := openwait( substr(glbx.extract_fname( tfile2, 'PWD'),1,length(glbx.extract_fname( tfile2, 'PWD'))-1), glbx.extract_fname( tfile2, 'FILE'), 'r', 4000, maxwaits=>20 );
 -- Ignore the first 3 lines
 utl_file.get_line(fl2, bfr );
 utl_file.get_line(fl2, bfr );
 utl_file.get_line(fl2, bfr );
 loop
  begin
   utl_file.get_line(fl2, bfr );
   if trim(bfr) is not null
    then
     utl_file.put_line(fl, bfr );
   end if;
  exception
   when others then exit;
  end;
 end loop;
 utl_file.fclose( fl2 );

 -- Del the files
 if DECS.UNIX_OR_NT = '\'
  then
   x := oscommand_run(source_call || 'del ' || tfile1 );
  else
   x := oscommand_run(source_call || source_directory || 'rm2.sh ' || tfile1 );
 end if;
 if DECS.UNIX_OR_NT = '\'
  then
   x := oscommand_run(source_call || 'del ' || tfile2 );
  else
   x := oscommand_run(source_call || source_directory || 'rm2.sh ' || tfile2 );
 end if;
 return( TRUE );

end extract_mime64;

function reassemble_mime64( blb in out blob, fl in out utl_file.file_type, endmarker in varchar2 )
 return boolean
as

 display_output 	GLBX.MYARRAY;
 tfile1			varchar2(1000);
 tfile2			varchar2(1000);
 status 		number;
 bl			boolean;
 fl2			utl_file.file_type;
 bfr			varchar2(4000);
 tblob			blob;
 document_bfile 	bfile;
 x			integer;
 obj_length		integer;
 foundrec		boolean;

begin

 tempfile( short_name=>TRUE);
 tfile1 := TEMPORARY_FILE;
 tempfile( short_name=>TRUE);
 tfile2 := TEMPORARY_FILE;

 fl2 := utl_file.fopen( substr(glbx.extract_fname( tfile2, 'PWD'),1,length(glbx.extract_fname( tfile2, 'PWD'))-1), glbx.extract_fname( tfile2, 'FILE'), 'w', 4000 );
 -- Ignore the first 3 lines
 utl_file.put_line(fl2, 'Content-Type: text/plain; charset=US-ASCII; name=' || tfile1 );
 utl_file.put_line(fl2, 'Content-transfer-encoding: base64' );
 utl_file.put_line(fl2, chr(10) );
 foundrec := FALSE;
 loop
  begin
   utl_file.get_line(fl, bfr );
   if endmarker is not null and bfr = endmarker then exit; end if;
   if trim(bfr) is not null
    then
     utl_file.put_line(fl2, bfr );
     foundrec := TRUE;
   end if;
  exception
   when others then null;
  end;
 end loop;
 utl_file.put_line(fl2, chr(10) );
 utl_file.fclose( fl2 );

 -- Convert file back from from Mime
 if foundrec
  then
   bl := mime64_decode( tfile2, tfile1, display_output );

   -- Loop until the file can be accessed
   --wait_not_used fl2 := openwait( substr(glbx.extract_fname( tfile1, 'PWD'),1,length(glbx.extract_fname( tfile1, 'PWD'))-1),upper( glbx.extract_fname( tfile1, 'FILE') ), 'r', 4000, maxwaits=>20 );
   --wait_not_used utl_file.fclose( fl2 );

   --change load directory to
   execute immediate 'create or replace directory ' || GLBX.GLOBAL_DIR || ' as ''' || substr(glbx.extract_fname( tfile1, 'PWD'),1,length(glbx.extract_fname( tfile1, 'PWD'))-1) || '''';

   -- Upload Blob
   document_bfile := bfilename( GLBX.GLOBAL_DIR, glbx.extract_fname( tfile1, 'FILE') );
   dbms_lob.fileopen( document_bfile, dbms_lob.file_readonly );
   obj_length := dbms_lob.getlength(document_bfile);
   dbms_lob.createtemporary(tblob, TRUE);
   dbms_lob.loadfromfile( tblob, document_bfile, obj_length );
   dbms_lob.append( blb, tblob );
   dbms_lob.fileclose(document_bfile);
   dbms_lob.freetemporary( tblob );
 end if;

 -- Del the files
 if DECS.UNIX_OR_NT = '\'
  then
   x := oscommand_run(source_call || 'del ' || tfile1 );
  else
   x := oscommand_run(source_call || source_directory || 'rm2.sh ' || tfile1 );
 end if;
 if DECS.UNIX_OR_NT = '\'
  then
   x := oscommand_run(source_call || 'del ' || tfile2 );
  else
   x := oscommand_run(source_call || source_directory || 'rm2.sh ' || tfile2 );
 end if;

 return( TRUE );
exception
 when others then
  -- Del the files
  if DECS.UNIX_OR_NT = '\'  then  x := oscommand_run(source_call || 'del ' || tfile1 ); else  x := oscommand_run(source_call || source_directory || 'rm2.sh ' || tfile1 ); end if;
  if DECS.UNIX_OR_NT = '\'  then  x := oscommand_run(source_call || 'del ' || tfile2 ); else  x := oscommand_run(source_call || source_directory || 'rm2.sh ' || tfile2 ); end if;
  return( FALSE );
end reassemble_mime64;

function fileprint( printer_name in varchar2, destination in varchar2, destfilename in varchar2, lptid in varchar2, display_output out GLBX.MYARRAY )
 return boolean
as
 x	varchar2(1000);

begin

 --tempfile;
 if DECS.UNIX_OR_NT = '\'
  then
   x := oscommand_run(source_call || source_directory( TRUE ) || 'line_print.bat' || ' ' || lptid || ' "' ||  printer_name || '" "' ||  destination || DECS.UNIX_OR_NT || destfilename ||  '" ' );
  else
   x := oscommand_run(source_call || source_directory || 'fileprint.sh ' || printer_name || ' ' ||  destination || DECS.UNIX_OR_NT || destfilename || ' ' || lptid );
 end if;
 --display_output := tempfile_contents;
 return( convbool( x ) );

exception
 when others then
  --deltmpfile;
  return( FALSE );
end fileprint;

function image_magick( calltype in varchar2, cmd in varchar2, display_output out GLBX.MYARRAY )
 return boolean
as
 x	varchar2(1000);
 fl	utl_file.file_type;
begin
 if DECS.UNIX_OR_NT = '\'
  then
   if calltype = 'NCONVERT'
    then
     if DECS.OS = 'NT'
      then
       x := oscommand_run(source_call || source_directory( TRUE ) || 'nconvert_nt.bat ' || ' ' ||  cmd );
      else
       x := oscommand_run(source_call || source_directory( TRUE ) || 'nconvert.bat ' || ' "' ||  cmd ||  '"' );
     end if;
    else
       if instr(cmd,'"') > 0
        then
         -- Have to dynamically create a BAT file
         tempfile('bat',TRUE);
         fl := utl_file.fopen( substr(glbx.extract_fname( TEMPORARY_FILE, 'PWD'),1,length(glbx.extract_fname( TEMPORARY_FILE, 'PWD'))-1), glbx.extract_fname( TEMPORARY_FILE, 'FILE'), 'w',4000);
         utl_file.put_line( fl, 'set MAGICK_HOME=' || glbx.extract_master_parameter( 'PICTION_DIRECTORY' ) || '\ImageMagick\VisualMagick\bin' );
         utl_file.put_line( fl, '%MAGICK_HOME%\' || calltype || ' ' ||  cmd );
         utl_file.put_line( fl, 'echo [Completed]' );
         utl_file.put_line( fl, 'exit' );
         utl_file.fclose(fl);
         --glbx.dbg(source_call || TEMPORARY_FILE);
         x := oscommand_run(source_call || TEMPORARY_FILE  );
         deltmpfile;
        else
         if DECS.OS = 'NT'
          then
           -- Call the NT which just accepts all the parameters as is
           x := oscommand_run(source_call || source_directory( TRUE ) || 'image_magick_nt.bat ' || calltype || ' ' ||  cmd );
          else
           x := oscommand_run(source_call || source_directory( TRUE ) || 'image_magick.bat ' || calltype || ' "' ||  cmd ||  '"' );
         end if;
       end if;
   end if;
  else
   x := oscommand_run(source_call || source_directory || 'image_magick.sh ' || calltype || ' ' ||  cmd );
 end if;
 --display_output := tempfile_contents;
 --deltmpfile;
 return( convbool( x ) );

exception
 when others then
  --deltmpfile;
  glbx.dbg( sqlerrm );
  return( FALSE );
end image_magick;

function image_magick_trap_output( calltype in varchar2, cmd in varchar2, display_output out GLBX.MYARRAY )
 return boolean
as
 x	varchar2(1000);
begin
 tempfile;
 if DECS.UNIX_OR_NT = '\'
  then
   if calltype = 'NCONVERT'
    then
     if DECS.OS = 'NT'
      then
       x := oscommand_run(source_call || source_directory( TRUE ) || 'nconvert_nt.bat ' || ' ' ||  cmd );
      else
       x := oscommand_run(source_call || source_directory( TRUE ) || 'nconvert.bat ' || ' "' ||  cmd ||  '"' );
     end if;
    else
     if DECS.OS = 'NT'
      then
       x := oscommand_run(source_call || source_directory( TRUE ) || 'image_magick_nt.bat ' || calltype || ' ' ||  cmd || ' ' || TEMPORARY_FILE );
      else
       if instr(cmd,'"') > 0
        then
         -- Call the NT which just accepts all the parameters as is
         x := oscommand_run(source_call || source_directory( TRUE ) || 'image_magick_nt.bat ' || calltype || ' ' ||  cmd || ' ' || TEMPORARY_FILE );
        else
         -- glbx.dbg(source_call || source_directory( TRUE ) || 'image_magick_output2.bat ' || calltype || ' "' || cmd || ' ' || TEMPORARY_FILE || '"' );
         x := oscommand_run(source_call || source_directory( TRUE ) || 'image_magick.bat ' || calltype || ' "' || cmd || ' ' || TEMPORARY_FILE || '"' );
       end if;
     end if;
   end if;
  else
   x := oscommand_run(source_call || source_directory || 'image_magick.sh ' || calltype || ' ' ||  cmd );
 end if;
 display_output := tempfile_contents;
 deltmpfile;
 return( convbool( x ) );

exception
 when others then
  --deltmpfile;
  glbx.dbg( sqlerrm );
  return( FALSE );
end image_magick_trap_output;

function sqlplus_odbc( calltype in varchar2, cmd in varchar2, display_output out GLBX.MYARRAY )
 return boolean
as
 x	varchar2(1000);

begin
--tempfile;
 if DECS.UNIX_OR_NT = '\'
  then
   -- sqlplus_odbc.bat "x/x@odbc:powerhouse @c:\temp\script.sql"
  if DECS.OS = 'NT'
   then
    x := oscommand_run(source_call || source_directory( TRUE ) || 'sqlplus_odbc_nt.bat ' || ' ' ||  cmd );
   else
    x := oscommand_run(source_call || source_directory( TRUE ) || 'sqlplus_odbc.bat ' || ' "' ||  cmd ||  '"');
  end if;
  else
   x := oscommand_run(source_call || source_directory || 'image_magick.sh ' || calltype || ' ' ||  cmd );
 end if;
 --display_output := tempfile_contents;
 return( convbool( x ) );

exception
 when others then
  --deltmpfile;
  return( FALSE );
end sqlplus_odbc;

function audcmd( cmd in varchar2, cmd2 in varchar2, display_output out GLBX.MYARRAY )
 return boolean
as
 x	varchar2(1000);
 fl	utl_file.file_type;
begin
 if DECS.UNIX_OR_NT = '\'
  then
    -- Have to dynamically create a BAT file
    tempfile('bat',TRUE);
    fl := utl_file.fopen( substr(glbx.extract_fname( TEMPORARY_FILE, 'PWD'),1,length(glbx.extract_fname( TEMPORARY_FILE, 'PWD'))-1), glbx.extract_fname( TEMPORARY_FILE, 'FILE'), 'w',4000);
    utl_file.put_line( fl, 'set AUDIO_HOME="p:\program files\audio converter 4.2\audcmd.exe"' );
    utl_file.put_line( fl, '%AUDIO_HOME% ' || cmd );
    if cmd2 is not null
     then
      utl_file.put_line( fl, '%AUDIO_HOME% ' || cmd2 );
    end if;
    utl_file.put_line( fl, 'echo [Completed]' );
    utl_file.put_line( fl, 'exit' );
    utl_file.fclose(fl);
    --glbx.dbg(source_call || TEMPORARY_FILE);
    x := oscommand_run(source_call || TEMPORARY_FILE  );
    deltmpfile;
  else
   null;
   -- Not Supported on Unix
 end if;
 return( convbool( x ) );

exception
 when others then
  --deltmpfile;
  glbx.dbg( sqlerrm );
  return( FALSE );
end audcmd;

function audcmd_wait( cmd in varchar2, display_output out GLBX.MYARRAY )
 return boolean
as
 x	  varchar2(1000);
 fl	  utl_file.file_type;
 tfile1	  varchar2(1000);
 tfile2	  varchar2(1000);
 ctr	  integer;
 bfr	  varchar2(32767);
 foundrec boolean;
begin
 if DECS.UNIX_OR_NT = '\'
  then
    -- Have to dynamically create a BAT file
    tempfile('bat',TRUE);
    tfile1 := TEMPORARY_FILE;
    tempfile('txt',TRUE);
    tfile2 := TEMPORARY_FILE;
    fl := utl_file.fopen( substr(glbx.extract_fname( tfile1, 'PWD'),1,length(glbx.extract_fname( tfile1, 'PWD'))-1), glbx.extract_fname( tfile1, 'FILE'), 'w',4000);
    utl_file.put_line( fl, 'set AUDIO_HOME="p:\program files\audio converter 4.2\audcmd.exe"' );
    utl_file.put_line( fl, '%AUDIO_HOME% ' || cmd || ' >' || tfile2 );
    utl_file.put_line( fl, 'echo [Completed]' );
    utl_file.put_line( fl, 'exit' );
    utl_file.fclose(fl);
    --glbx.dbg(source_call || TEMPORARY_FILE);
    x := oscommand_run(source_call || tfile1 );

    -- keep looping through the log file until we see 100% then exit
    ctr := 0;
    loop
     ctr := ctr + 1; if ctr > 1000 then exit; end if;
     fl := utl_file.fopen( substr(glbx.extract_fname( tfile2, 'PWD'),1,length(glbx.extract_fname( tfile2, 'PWD'))-1), glbx.extract_fname( tfile2, 'FILE'), 'r',32767);
     loop
      begin
       utl_file.get_line( fl, bfr );
       if instr(bfr,'100%') > 0 then foundrec := TRUE; exit; end if;
      exception when others then foundrec := FALSE; exit;
      end;
     end loop;
     utl_file.fclose(fl);
     if foundrec then exit; end if;
     dbms_lock.sleep(1);
    end loop;

    TEMPORARY_FILE := tfile1;
    deltmpfile;
    TEMPORARY_FILE := tfile2;
    deltmpfile;
  else
   null;
   -- Not Supported on Unix
 end if;
 --display_output := tempfile_contents;
 --deltmpfile;
 return( convbool( x ) );

exception
 when others then
  --deltmpfile;
  glbx.dbg( sqlerrm );
  return( FALSE );
end audcmd_wait;

end os_command;
/
