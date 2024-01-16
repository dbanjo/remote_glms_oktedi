CREATE OR REPLACE function STRANG.revenue_tonne( part_weight in number, part_volume in number )
 return number
is
begin

 if (part_weight/1000) >= part_volume
  then
   return( part_weight/1000 );
  else
   return( part_volume );
 end if;

end revenue_tonne;
/


GRANT EXECUTE ON STRANG.REVENUE_TONNE TO STX1;

GRANT EXECUTE ON STRANG.REVENUE_TONNE TO WEBSYS;
