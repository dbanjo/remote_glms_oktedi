CREATE OR REPLACE package WEBSYS.sur
as

 TYPE myarray 	IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;

 procedure display_survey1;
 procedure accept_survey1( id in varchar2, p1 in MYARRAY, p2 in MYARRAY, p3 in MYARRAY );

end sur;

/
