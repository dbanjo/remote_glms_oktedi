CREATE OR REPLACE function STRANG.t1 return varchar2 as
 begin
  return( rpad('x',6000,'y') );
end;

/
