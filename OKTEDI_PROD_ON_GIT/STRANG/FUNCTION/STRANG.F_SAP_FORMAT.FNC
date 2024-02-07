CREATE OR REPLACE function STRANG.f_sap_format( v in varchar2,typ in varchar2 )
 return varchar2
as
 vv	number;
begin
if v is null then
  return(v);
end if;
IF TRIM(TRANSLATE(TRANSLATE(TRIM(v), ' ', 'x'), '0123456789', ' ')) IS NULL THEN
  vv := TO_NUMBER(v);
else return(v);
END IF;

case upper(typ)
when 'PO' 		then
--			 if vv < 4500000000 then
--			  vv:= 4500000000 + vv;
--			 end if;
--			return(to_char(vv));
			return(rtrim(to_char(v)));   -- Delete this row and uncomment above lines when ready.
when 'DELIVERYNO'       then
			if vv < 80000000 then
			  vv:= 80000000 + vv;
			 end if;
			 return(to_number(vv));
when 'HANDLING_UNIT'       then
			if vv < 1000000000 then
			  vv:= 1000000000 + vv;
			 end if;
			 return(to_number(vv));
when 'GRN'       then
			if vv < 5000000000 then
			  vv:= 5000000000 + vv;
			 end if;
			 return(to_number(vv));
when 'INVENTORYNO'      then
--			 if vv < 10000000 then
--			  vv:= 10000000 + vv;
-- 			 end if;
--			return(to_char(vv));
			return(to_char(v));   -- Delete this row and uncomment above lines when ready.
else
 return(to_char(vv));
end case;
end f_sap_format;
/


GRANT EXECUTE ON STRANG.F_SAP_FORMAT TO WEBSYS;
