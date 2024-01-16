CREATE OR REPLACE package WEBSYS.strang_global
as

 TYPE entrylist IS RECORD
  (
    rnumb integer,
    entryno  varchar2(100),
    tariff varchar2(100)
  );

 TYPE myarray     IS TABLE OF entrylist INDEX BY BINARY_INTEGER;


 GLOBAL_VARS myarray;

end;

/
