CREATE OR REPLACE function WEBSYS.file_exists_tf(fdir in varchar2, fname in varchar default null) return varchar
as

location VARCHAR2(4000);
filename VARCHAR2(4000);
fexists BOOLEAN;
chk varchar2(1);
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

 if fexists then 
   return 'Y';
 else return 'N';
 end if;


exception when others then
 return('N');
end file_exists_tf;
/
