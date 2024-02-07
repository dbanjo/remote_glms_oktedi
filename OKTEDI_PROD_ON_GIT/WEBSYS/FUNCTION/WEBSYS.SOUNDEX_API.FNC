CREATE OR REPLACE function WEBSYS.soundex_api(data_value in varchar2, attrib_id in integer)
 return varchar2
as
begin
 return( soundex(data_value) );
exception
 when others then return( soundex(data_value) );
end soundex_api;

/
