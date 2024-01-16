CREATE OR REPLACE FUNCTION STRANG."F_SACL_DESCRIPTION" ( sa in varchar2, cl in varchar2 )
   return varchar2
  as

   begin
    if sa = 'S' and cl = 'L' then
     return('BREAK BULK');
    elsif sa = 'S' and cl = 'C' then
     return('CONTAINERISED');
    elsif sa = 'A' then
     return('AIRFREIGHT');
    else
     return('N/A');
    end if;
     return( null );
 end f_sacl_description;
/
