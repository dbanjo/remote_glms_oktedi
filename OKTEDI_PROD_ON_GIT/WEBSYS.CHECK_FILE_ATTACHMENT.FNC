CREATE OR REPLACE FUNCTION WEBSYS."CHECK_FILE_ATTACHMENT" (file_type in varchar2, deliveryno in varchar2)
return varchar2
is
v_check varchar2(1000);
begin

if websys.file_exists(glbx.extract_master_parameter('STRANG_RECEIVALS_DIR') || '\'|| deliveryno|| '\'||UPPER(trim(file_type)),deliveryno||'_'||lower(trim(file_type))||'.pdf') = true then

v_check := 'true';
else 
v_check := 'false';
end if;

--dbms_output.put_line(v_check);
return v_check;

end;
/
