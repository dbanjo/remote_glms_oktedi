CREATE OR REPLACE function STRANG.file_exists(fdir in varchar2, fname in varchar default null) return boolean
as

location VARCHAR2(4000);
filename VARCHAR2(4000);
fexists BOOLEAN;
file_length NUMBER;
block_size BINARY_INTEGER;

begin
 if fname is null
  then
   filename := glbx.extract_fname(fdir, 'FILE');
   location := glbx.extract_fname(fdir, 'PWD');
 else
   filename := fname;
   location := fdir;
 end if;

 utl_file.fgetattr(location, filename, fexists, file_length, block_size);

 return(fexists);

exception when others then
 return(FALSE);
end file_exists;
/
