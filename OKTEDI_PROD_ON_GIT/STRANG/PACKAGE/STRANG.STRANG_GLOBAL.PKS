CREATE OR REPLACE package STRANG.strang_global
as

 TYPE entrylist IS RECORD
  (
    rnumb	integer,
    entryno 	varchar2(100),
    tariff	varchar2(100),
    entryitem	integer
  );

 TYPE myarray 	   IS TABLE OF entrylist INDEX BY BINARY_INTEGER;


 GLOBAL_VARS	myarray;
 pgtotalduty    number;
 pgtotalexcise  number;
 pgtotalgst     number;
 pgtotallevy      number;
 pgglobaltotal  number;

end;
/
