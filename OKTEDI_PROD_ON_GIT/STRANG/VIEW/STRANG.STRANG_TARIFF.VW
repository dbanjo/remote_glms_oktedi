CREATE OR REPLACE FORCE VIEW STRANG.STRANG_TARIFF
(TARIFF, RATE, UNIT, OLD_RATE, EXCISE)
AS 
select code tariff, description rate, cola unit, colb old_rate, colc excise
from lov
where lov_name = 'TARIFF';


GRANT SELECT ON STRANG.STRANG_TARIFF TO WEBSYS;
