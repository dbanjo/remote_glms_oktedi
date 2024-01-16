CREATE OR REPLACE FUNCTION WEBSYS."V_BLOBTOCLOB" (v_blob_in in blob)
return clob is

v_file_clob clob;
v_file_size integer := dbms_lob.lobmaxsize;
v_dest_offset integer := 1;
v_src_offset integer := 1;
v_blob_csid number := dbms_lob.default_csid;
v_lang_context number := dbms_lob.default_lang_ctx;
v_warning integer;
v_length number;

begin

dbms_lob.createtemporary(v_file_clob, true);

dbms_lob.converttoclob(v_file_clob,
v_blob_in,
v_file_size,
v_dest_offset,
v_src_offset,
v_blob_csid,
v_lang_context,
v_warning);

return v_file_clob;

exception
when others then
dbms_output.put_line('Error found');

end;
/
