CREATE OR REPLACE function STRANG.containerhiredfrom( startdate in date, dhired in date )
 return date
is
begin

 if dhired > startdate
  then
   return( dhired );
  else
   return( startdate );
 end if;

end containerhiredfrom;
/


GRANT EXECUTE ON STRANG.CONTAINERHIREDFROM TO WEBSYS;
