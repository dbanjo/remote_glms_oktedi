CREATE OR REPLACE function STRANG.containerhiredto( enddate in date, ofdate in date )
 return date
is
begin

 if ofdate < enddate
  then
   return( ofdate );
 else
   return( enddate );
 end if;

end containerhiredto;
/


GRANT EXECUTE ON STRANG.CONTAINERHIREDTO TO WEBSYS;
