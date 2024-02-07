CREATE OR REPLACE function STRANG.containerdays( ondte in date, ofdate in date, dte in date )
 return number
is
begin

 if (ondte <= dte) and (ofdate > last_day(dte))
  then
     return ( ((last_day(dte) - dte) + 1) );
 elsif
   (ondte <= dte) and (ofdate <= last_day(dte)) then
      return( (ofdate - dte) + 1 ) ;
 elsif
  (ondte > dte) and (ofdate > last_day(dte)) then
     return ( (last_day(dte) - ondte + 1 ) );
 else
     return( (ofdate - ondte) + 1);
 end if;

end containerdays;
/


GRANT EXECUTE ON STRANG.CONTAINERDAYS TO WEBSYS;
