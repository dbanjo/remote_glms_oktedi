CREATE OR REPLACE procedure WEBSYS.conv_blob_clob( blb in blob, clb in out clob )
as

 r_buffer     raw(32767);
 v_buffer     varchar2(32767);
 c_imgchunk   integer;
 v_imgchunk   integer;
 v_count      integer;

begin
-- convert from blob to clob
dbms_lob.createtemporary(clb,TRUE);
c_imgchunk := 32767;
v_imgchunk := 32767;
v_count := 0;
begin
 loop
   dbms_lob.read(blb,v_imgchunk,(v_count*c_imgchunk)+1,r_buffer);
   v_count := v_count + 1;
   v_buffer := utl_raw.cast_to_varchar2( r_buffer );
   if v_buffer is null then exit; end if;
   dbms_lob.writeappend(clb,length(v_buffer), v_buffer);
 end loop;
exception when others then null;
end;
end conv_blob_clob;
/
