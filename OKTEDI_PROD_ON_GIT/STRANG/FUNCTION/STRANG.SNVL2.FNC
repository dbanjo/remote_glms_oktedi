CREATE OR REPLACE function STRANG.snvl2( str1 in varchar2, str2 in varchar2, str3 in varchar2, last in integer )
 return varchar2
as
 tmp	varchar2(56);
begin
tmp:='';
 if last = 0
 then
   if str1 is null
    then
     if substr(tmp, length(tmp)-3,4) = ', , '
      then
      tmp:=(substr(tmp,1,length(tmp)-2));
    end if;
    return( str3);
   else
    return( str2);
   end if;
 else
   if str1 is null
    then
    tmp:= str3;
   else
    tmp:= str2;
   end if;
   while substr(tmp, length(tmp)-1,2) = ', ' loop
    tmp:= substr(tmp,1,length(tmp)-2);
   end loop;
   return(tmp);
 end if;
end snvl2;
/


GRANT EXECUTE ON STRANG.SNVL2 TO WEBSYS;
