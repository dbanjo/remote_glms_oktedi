CREATE OR REPLACE function STRANG.chargeable_weight( part_weight in number, part_volume in number )
 return number
as
 ret_value	number;
begin
 ret_value := greatest( part_weight, part_volume * 167 );
 if ret_value < 1 then ret_value := 1; end if;
 return( ret_value );
end chargeable_weight;
/


GRANT EXECUTE ON STRANG.CHARGEABLE_WEIGHT TO STX1;

GRANT EXECUTE ON STRANG.CHARGEABLE_WEIGHT TO WEBSYS;
