CREATE OR REPLACE function STRANG.containerlease( ondte in date, ofdate in date, dte in date , lcost in number )
 return number
is
begin

 if (ondte <= dte) and (ofdate > last_day(dte))
  then
     return ( lcost*(((last_day(dte) - dte) + 1)) );
 elsif
   (ondte <= dte) and (ofdate <= last_day(dte)) then
      return( lcost*((ofdate - dte) + 1) );
 elsif
  (ondte > dte) and (ofdate > last_day(dte)) then
     return ( lcost*((last_day(dte) - ondte + 1 )) );
 else
     return( lcost*((ofdate - ondte) + 1) );
 end if;

end containerlease;
/


GRANT EXECUTE ON STRANG.CONTAINERLEASE TO WEBSYS;
