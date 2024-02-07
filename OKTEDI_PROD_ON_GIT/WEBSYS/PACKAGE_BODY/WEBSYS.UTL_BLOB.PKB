CREATE OR REPLACE package body WEBSYS.utl_blob as

function extract_fname( fname in varchar2, ftype in varchar2 DEFAULT 'NO_EXTENSION', maxlength in integer DEFAULT 100)
 return varchar2
as

 jctr   integer;
 vname  varchar2(4000);
 stp	varchar2(100);
 x	integer;
 y	integer;

begin
 stp := 'A';
 jctr := NULL;
 if fname is null then return( null ); end if;
 stp := 'B';
 if ftype = 'FILE_NO_EXT_SMART' -- Designed for when a filename has two full stops in it
  then
   vname := fname;
   x := instr(vname,'.',-1);
   if x > 0
    then
     vname := substr(vname,1,x-1);
   end if;
   x := instr(vname,'\',-1);
   if x > 0
    then
     vname := substr(vname,x+1);
     return( vname );
   end if;
   x := instr(vname,'/',-1);
   if x > 0
    then
     vname := substr(vname,x+1);
     return( vname );
   end if;
   return( vname );
 end if;

 if ftype = 'PARENT'
  then
   if decs.unix_or_nt = '\' and substr(fname,1,2) = '\\'
    then
     jctr := instr(fname,'\',1,3) - 1;
     if jctr < 1 then jctr := instr(fname,'\',1,1)-1; end if;
     return(substr(fname,1,jctr));
   elsif decs.unix_or_nt = '\'
    then
     jctr := instr(fname,'\',1,2) - 1;
     if jctr < 1 then jctr := instr(fname,'\',1,1)-1; end if;
     return(substr(fname,1,jctr));
    else
     jctr := instr(fname,'/',1,3) - 1;
     if jctr < 1 then jctr := instr(fname,'\',1,3)-1; end if;
     return(substr(fname,1,jctr));
   end if;
 end if;

 stp := 'C';

 x := instr(fname,'/',-1);
 y := instr(fname,'\',-1);
 if x > 0 and y > 0 and x > y then jctr := x + 1;
 elsif x > 0 and y > 0 and y >= x then jctr := y + 1;
 elsif x > 0 then jctr := x + 1;
 elsif y > 0 then jctr := y + 1;
 else jctr := 0;
 end if;

 /*
 for j in REVERSE 1..length(fname) loop
  if substr(fname,j,1) in ('/','\')
   then
    jctr := j+1;
    exit;
  end if;
 end loop;
 jctr := nvl(jctr,0);
 */

 stp := 'D';
 if jctr = 0
  then
   vname := fname;
  else
   vname := substr(fname,jctr);
 end if;

 stp := 'E';
 if ftype = 'FILE_NO_EXTENSION'
  then
   vname := substr(vname,instr(vname,DECS.UNIX_OR_NT,-1)+1);
   if instr(vname,'.') = 0 then return( vname); end if;
   return( substr(vname,1,instr(vname,'.')-1));
 end if;

 stp := 'F';
 if ftype in ('SUFFIX','NO_EXTENSION','FILE_NO_EXTENSION')
  then
 stp := 'F1:' || length(vname);
   jctr := NULL;
   jctr := instr(vname,'.',-1);
   jctr := nvl(jctr,0);
   /*
   for j in REVERSE 1..length(vname) loop
 stp := 'F2:' || j;
    if substr(vname,j,1) = '.'
     then
 stp := 'F3:' || j;
      jctr := j;
      exit;
    end if;
   end loop;
   */
   stp := 'G';
   if ftype = 'SUFFIX'
    then
     if jctr = 0 then return(null); end if;
     return( substr(vname,jctr+1) );
   end if;
   stp := 'H';
   if jctr = 0
    then
     return(vname);
    else
     vname := substr(vname,1,jctr-1);
   end if;
 end if;

   stp := 'I';
 if ftype = 'PWD'
  then
   return( substr(fname,1,jctr-1) );
 elsif ftype = 'PWD_NOTRAIL'
  then
   return( substr(fname,1,jctr-2) );
 elsif ftype = 'PWD_NOSUFFIX'
  then
   jctr := instr(fname,'.',-1);
   return( substr(fname,1,jctr-1) );
  elsif ftype = 'FILE' or ftype = 'FILENAME'
   then
   return( substr(fname,jctr) );
  else
   stp := 'J';
   return( substr(vname,1,maxlength) );
 end if;

exception when others then
 if ftype = 'SUFFIX' then return( 'txt' ); end if;
 glbx.error_details( 'GLBX', 'EXTRACT_FNAME', errmsg=>sqlerrm, extdet=>'Extract Fname:[' || fname || ':' || ftype || ':' || length( fname ) || '-' || stp || ']');
 return(fname);
end extract_fname;

procedure blobtofile(src in BLOB, filename in varchar2, append in boolean)
is

 u		    utl_file.file_type;
 v_count	integer;
 v_int		integer;
 r_buffer	raw(32767);

begin
 if append
  then
   u := utl_file.fopen( extract_fname(filename,'PWD_NOTRAIL'), extract_fname(filename,'FILENAME'), 'ab', 32767 );
  else
   u := utl_file.fopen( extract_fname(filename,'PWD_NOTRAIL'), extract_fname(filename,'FILENAME'), 'wb', 32767 );
 end if;
 v_count := 0;
 v_int := 32767;
 begin
  loop
   dbms_lob.read(src,v_int,(v_count*32767)+1,r_buffer);
   v_count := v_count + 1;
   utl_file.put_raw( u, r_buffer, autoflush=>TRUE );
  end loop;
 exception
  when no_data_found then null;
 end;

 utl_file.fclose(u);
 return;
exception
 when others then
  begin utl_file.fclose(u); exception when others then null; end;
  glbx.dbg('BLOBTOFILE: ' || sqlerrm);
end blobtofile;
end utl_blob;
/


GRANT EXECUTE ON WEBSYS.UTL_BLOB TO STRANG;

GRANT EXECUTE ON WEBSYS.UTL_BLOB TO STX1;
