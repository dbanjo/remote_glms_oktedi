CREATE OR REPLACE function WEBSYS.check_invoice_attachment (deliveryno in varchar2)
return varchar2
is
v_check varchar2(1000);
begin

if websys.file_exists(glbx.extract_master_parameter('STRANG_RECEIVALS_DIR') || '\'|| deliveryno|| '\'||'INVOICE',deliveryno||'_invoice.pdf') = true then

v_check := 'true';
else 
v_check := 'false';
end if;

return v_check;

end;
/
